package server.net;

/**
 * NovaServer —— 直接内置在 NF Fusion 里的联机服务器。
 *
 * 纯 Haxe stdlib（sys.net.Socket + sys.thread），只走 TCP：
 * 本工程 Macros.hx 里 sys.net.UdpSocket 是禁用的（会触发
 * "Failed to load function std@socket_set_broadcast"）。
 *
 * 用法（游戏里）：
 *   NovaServer.start(27310);      // 后台线程开始监听
 *   NovaServer.clientCount;       // 当前连进来的人数
 *   NovaServer.stop();
 *
 * 协议跟 NovaNet.hx 完全一致，跟独立版 Python 服务器也一致
 * （账号/排行榜存同目录的 novaserver_data.json）。
 */
#if sys
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Thread;
import sys.thread.Mutex;
import sys.io.File;
#end
import haxe.Json;
import haxe.crypto.Sha256;
import StringTools;

private class NovaClientObj
{
	public var s:Socket;
	public var user:String = "";
	public var roomId:Int = -1;
	public var slot:Int = -1;
	public var spectator:Bool = false;
	public var team:Int = 0;
	public var alive:Bool = true;

	public function new(sock:Socket)
	{
		s = sock;
	}

	public function send(line:String):Void
	{
		if (!alive)
			return;
		try
		{
			s.output.writeString(line + "\n");
			s.output.flush();
		}
		catch (e:Dynamic)
		{
			alive = false;
		}
	}
}

private class NovaRoomObj
{
	public var id:Int = -1;
	public var code:String = "";      // 6 位房间码，由服务器分配
	public var name:String = "";
	public var song:String = "";
	public var diff:String = "normal";
	public var max:Int = 2;
	public var host:String = "";
	public var started:Bool = false;
	public var t0:Float = 0;
	public var players:Array<String> = [];
	public var slots:Array<Int> = [];      // 跟 players 一一对应的座位号
	public var spectators:Array<String> = [];

	public function new() {}
}

class NovaServer
{
	public static var running:Bool = false;
	public static var port:Int = 27310;
	public static var clientCount:Int = 0;
	public static var lastError:String = "";

	static var lock:Mutex = new Mutex();
	static var listen:Socket = null;
	static var clients:Array<NovaClientObj> = [];
	static var rooms:Array<NovaRoomObj> = [];
	static var accounts:Array<Dynamic> = [];
	static var leaderboard:Array<Dynamic> = [];
	static var nextRoomId:Int = 1;
	static var tokens:Array<String> = [];   // token[i] 对应 accounts[i].u
	static var tokenUser:Array<String> = [];

	static var DATA_FILE:String = "novaserver_data.json";

	static function now():Float
	{
		return Date.now().getTime() / 1000.0;
	}

	/** 生成 6 位房间码（去掉易混字符 I/O/0/1） */
	static function makeCode():String
	{
		var cs:String = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
		var s:String = "";
		for (i in 0...6)
			s += cs.charAt(Std.random(cs.length));
		for (r in rooms)
			if (r.code == s)
				return makeCode();
		return s;
	}

	static function clean(s:String):String
	{
		if (s == null)
			return "";
		return StringTools.replace(StringTools.replace(StringTools.replace(s, "|", " "), "\n", " "), "\r", " ");
	}

	static function field(msg:String, key:String, def:String = ""):String
	{
		var prefix:String = key + "=";
		for (p in msg.split("|"))
			if (p.indexOf(prefix) == 0)
				return p.substring(prefix.length);
		return def;
	}

	static function typeOf(msg:String):String
	{
		var i:Int = msg.indexOf("|");
		return i < 0 ? msg : msg.substring(0, i);
	}

	static function randStr(n:Int):String
	{
		var s:String = "";
		for (i in 0...n)
			s += String.fromCharCode(97 + Std.random(26));
		return s;
	}

	// ------------------------------------------------------------ 存档
	static function loadData():Void
	{
		try
		{
			var o:Dynamic = Json.parse(File.getContent(Sys.getCwd() + DATA_FILE));
			if (o.accounts != null)
				accounts = o.accounts;
			if (o.leaderboard != null)
				leaderboard = o.leaderboard;
		}
		catch (e:Dynamic) {}
	}

	static function saveData():Void
	{
		try
		{
			File.saveContent(Sys.getCwd() + DATA_FILE,
				Json.stringify({accounts: accounts, leaderboard: leaderboard}));
		}
		catch (e:Dynamic) {}
	}

	// ------------------------------------------------------------ 开关
	public static function start(p:Int = 27310):Bool
	{
		#if !sys
		lastError = "no sys target";
		return false;
		#end
		if (running)
			return true;

		port = p;
		lastError = "";
		loadData();

		try
		{
			listen = new Socket();
			listen.setFastSend(true);
			try
			{
				listen.bind(new Host("0.0.0.0"), port);
			}
			catch (e:Dynamic)
			{
				listen.bind(null, port);
			}
			listen.listen(16);
		}
		catch (e:Dynamic)
		{
			lastError = "bind failed: " + e + " (port " + port + " maybe in use)";
			listen = null;
			return false;
		}

		running = true;
		Thread.create(acceptLoop);
		return true;
	}

	public static function stop():Void
	{
		if (!running)
			return;
		running = false;
		try
		{
			if (listen != null)
				listen.close();
		}
		catch (e:Dynamic) {}
		listen = null;

		lock.acquire();
		var copy:Array<NovaClientObj> = clients.copy();
		clients = [];
		clientCount = 0;
		lock.release();

		for (c in copy)
		{
			try
			{
				c.s.close();
			}
			catch (e:Dynamic) {}
		}
	}

	static function acceptLoop():Void
	{
		var s:Socket = listen;
		while (running)
		{
			var c:Socket = null;
			try
			{
				c = s.accept();
			}
			catch (e:Dynamic)
			{
				break;
			}
			if (c == null)
				break;

			try
			{
				c.setFastSend(true);
			}
			catch (e:Dynamic) {}

			var cli:NovaClientObj = new NovaClientObj(c);
			lock.acquire();
			clients.push(cli);
			clientCount = clients.length;
			lock.release();

			cli.send('HELLO|v=1|name=NF-Fusion-BuiltIn|t=' + Std.int(now()));
			var me:NovaClientObj = cli;
			Thread.create(function()
			{
				clientLoop(me);
			});
		}
		running = false;
	}

	static function dropClient(c:NovaClientObj):Void
	{
		lock.acquire();
		if (clients.remove(c))
			clientCount = clients.length;
		lock.release();
		try
		{
			c.s.close();
		}
		catch (e:Dynamic) {}
	}

	static function clientLoop(c:NovaClientObj):Void
	{
		while (running && c.alive)
		{
			var line:String = null;
			try
			{
				line = c.s.input.readLine();
			}
			catch (e:Dynamic)
			{
				break;
			}
			if (line == null)
				break;
			line = StringTools.trim(line);
			if (line.length == 0)
				continue;
			handle(c, line);
		}

		// 掉线：从房间摘掉
		lock.acquire();
		if (c.roomId >= 0)
		{
			var r:NovaRoomObj = roomById(c.roomId);
			if (r != null)
				leaveRoom(c, r);
			c.roomId = -1;
		}
		lock.release();

		dropClient(c);
	}

	// ------------------------------------------------------------ 房间工具（调用方必须已持锁）
	static function roomById(id:Int):NovaRoomObj
	{
		for (r in rooms)
			if (r.id == id)
				return r;
		return null;
	}

	static function roomOf(user:String):NovaRoomObj
	{
		for (r in rooms)
		{
			if (r.players.indexOf(user) >= 0)
				return r;
			if (r.spectators.indexOf(user) >= 0)
				return r;
		}
		return null;
	}

	static function roomBroadcast(r:NovaRoomObj, line:String, ?exclude:String):Void
	{
		for (c in clients)
		{
			if (!c.alive)
				continue;
			if (c.roomId != r.id)
				continue;
			if (exclude != null && c.user == exclude)
				continue;
			c.send(line);
		}
	}

	static function roomLine(r:NovaRoomObj):String
	{
		return 'ROOM|id=' + r.id + '|name=' + r.name + '|song=' + r.song
			+ '|d=' + r.diff + '|players=' + r.players.length
			+ '|max=' + r.max + '|spec=' + r.spectators.length + '|host=' + r.host
			+ '|code=' + r.code;
	}

	static function slotOf(r:NovaRoomObj, user:String):Int
	{
		var i:Int = r.players.indexOf(user);
		if (i >= 0)
			return r.slots[i];
		return -1;
	}

	static function findAccount(u:String):Dynamic
	{
		for (a in accounts)
			if (a.u == u)
				return a;
		return null;
	}

	static function userOfToken(t:String):String
	{
		for (i in 0...tokens.length)
			if (tokens[i] == t)
				return tokenUser[i];
		return "";
	}

	// ------------------------------------------------------------ 协议处理
	static function handle(c:NovaClientObj, msg:String):Void
	{
		var t:String = typeOf(msg);

		if (t == "PING")
		{
			c.send('PONG|t=' + field(msg, "t", "0"));
			return;
		}

		if (t == "REG")
		{
			var u:String = clean(field(msg, "u"));
			if (u.length == 0)
			{
				c.send('ERR|c=BAD_INPUT');
				return;
			}
			lock.acquire();
			if (findAccount(u) != null)
			{
				lock.release();
				c.send('ERR|c=NAME_TAKEN');
				return;
			}
			var salt:String = randStr(8);
			accounts.push({u: u, salt: salt, h: Sha256.encode(salt + clean(field(msg, "p"))), mail: clean(field(msg, "e"))});
			saveData();
			loginOk(c, u);
			lock.release();
			return;
		}

		if (t == "LOGIN")
		{
			var u:String = clean(field(msg, "u"));
			lock.acquire();
			var a:Dynamic = findAccount(u);
			if (a == null || a.h != Sha256.encode(a.salt + clean(field(msg, "p"))))
			{
				lock.release();
				c.send('ERR|c=BAD_LOGIN');
				return;
			}
			loginOk(c, u);
			lock.release();
			return;
		}

		if (t == "TOKEN")
		{
			lock.acquire();
			var u:String = userOfToken(clean(field(msg, "k")));
			if (u.length == 0)
			{
				lock.release();
				c.send('ERR|c=BAD_TOKEN');
				return;
			}
			c.user = u;
			var tk:String = clean(field(msg, "k"));
			c.send('LOGINOK|token=' + tk + '|u=' + u);
			lock.release();
			return;
		}

		if (t == "MAILCODE" || t == "VERIFY")
		{
			// 内置服务器不配 SMTP，邮箱验证码只做"直接通过"
			c.send(t == "MAILCODE" ? 'OK|t=MAILCODE|sent=0' : 'OK|t=VERIFY');
			return;
		}

		if (t == "LISTROOMS")
		{
			lock.acquire();
			c.send('ROOMS|n=' + rooms.length);
			for (r in rooms)
				c.send(roomLine(r));
			c.send('ROOMSEND');
			lock.release();
			return;
		}

		if (t == "CREATEROOM")
		{
			if (c.user.length == 0)
			{
				c.send('ERR|c=NOT_LOGGED_IN');
				return;
			}
			lock.acquire();
			var old:NovaRoomObj = roomOf(c.user);
			if (old != null)
				leaveRoom(c, old);

			var r:NovaRoomObj = new NovaRoomObj();
			r.id = nextRoomId++;
			r.code = makeCode();
			r.name = clean(field(msg, "name", c.user + " 的房间"));
			r.host = c.user;
			r.song = clean(field(msg, "s"));
			r.diff = clean(field(msg, "d", "normal"));
			var mx:Null<Int> = Std.parseInt(field(msg, "max", "2"));
			r.max = (mx == null || mx < 1) ? 2 : mx;
			r.players = [c.user];
			r.slots = [0];
			rooms.push(r);

			c.roomId = r.id;
			c.slot = 0;
			c.spectator = false;
			c.team = 0;
			c.send('ROOMOK|id=' + r.id + '|slot=0' + '|code=' + r.code);
			roomBroadcast(r, 'PEERLIST|n=1|p0=' + c.user, null);
			lock.release();
			return;
		}

		// ★ 按房间码进房：解析成房间 id 后走 JOINROOM 同一条路径
		if (t == "JOINCODE")
		{
			if (c.user.length == 0)
			{
				c.send('ERR|c=NOT_LOGGED_IN');
				return;
			}
			var want:String = field(msg, "code", "").toUpperCase();
			lock.acquire();
			var tgt:NovaRoomObj = null;
			for (rr in rooms)
				if (rr.code == want) { tgt = rr; break; }
			lock.release();
			if (tgt == null)
			{
				c.send('ERR|c=NO_ROOM');
				return;
			}
			msg = 'JOINROOM|id=' + tgt.id + '|spec=' + field(msg, "spec", "0") + '|team=' + field(msg, "team", "0");
			t = "JOINROOM";
		}

		if (t == "JOINROOM")
		{
			if (c.user.length == 0)
			{
				c.send('ERR|c=NOT_LOGGED_IN');
				return;
			}
			var id:Null<Int> = Std.parseInt(field(msg, "id", "-1"));
			if (id == null)
			{
				c.send('ERR|c=BAD_ID');
				return;
			}
			var spec:Bool = field(msg, "spec", "0") == "1";
		var team:Int = Std.parseInt(field(msg, "team", "0"));

			lock.acquire();
			var old:NovaRoomObj = roomOf(c.user);
			if (old != null)
				leaveRoom(c, old);

			var r:NovaRoomObj = roomById(id);
			if (r == null)
			{
				lock.release();
				c.send('ERR|c=NO_ROOM');
				return;
			}

			if (spec)
			{
				r.spectators.push(c.user);
				c.roomId = r.id;
				c.slot = -1;
				c.spectator = true;
			c.send('JOINOK|id=' + r.id + '|slot=-1|song=' + r.song + '|d=' + r.diff + '|host=' + r.host + '|code=' + r.code);
			roomBroadcast(r, 'JOIN|u=' + c.user + '|slot=-1|spec=1|team=0', c.user);
				lock.release();
				return;
			}

			if (r.players.length >= r.max)
			{
				lock.release();
				c.send('ERR|c=ROOM_FULL');
				return;
			}

			var slot:Int = 0;
			while (r.slots.indexOf(slot) >= 0)
				slot++;
			r.players.push(c.user);
			r.slots.push(slot);
			c.roomId = r.id;
			c.slot = slot;
			c.spectator = false;
			c.team = team;
			c.send('JOINOK|id=' + r.id + '|slot=' + slot + '|song=' + r.song + '|d=' + r.diff + '|host=' + r.host + '|code=' + r.code);
			roomBroadcast(r, 'JOIN|u=' + c.user + '|slot=' + slot + '|spec=0|team=' + team, c.user);
			// 给刚进房的人发全部已有成员(含自己)的 PEER，让客户端成员表立刻完整
			for (i in 0...r.players.length)
			{
				var pu:String = r.players[i];
				var psl:Int = r.slots[i];
				var ptm:Int = 0;
				for (cc in clients)
					if (cc.user == pu) { ptm = cc.team; break; }
				c.send('PEER|slot=' + psl + '|u=' + pu + '|team=' + ptm + '|c=0|m=0|a=100|s=0|h=1');
			}
			lock.release();
			return;
		}

		if (t == "LEAVEROOM")
		{
			lock.acquire();
			var r:NovaRoomObj = roomOf(c.user);
			if (r != null)
				leaveRoom(c, r);
			c.send('OK|t=LEAVE');
			lock.release();
			return;
		}

		if (t == "CHAT")
		{
			lock.acquire();
			var r:NovaRoomObj = roomOf(c.user);
			if (r == null)
			{
				lock.release();
				c.send('ERR|c=NO_ROOM');
				return;
			}
			roomBroadcast(r, 'CHAT|u=' + c.user + '|m=' + clean(field(msg, "m")), null);
			lock.release();
			return;
		}

		if (t == "SETSONG")
		{
			lock.acquire();
			var r:NovaRoomObj = roomOf(c.user);
			if (r == null)
			{
				lock.release();
				c.send('ERR|c=NO_ROOM');
				return;
			}
			if (r.host != c.user)
			{
				lock.release();
				c.send('ERR|c=NOT_HOST');
				return;
			}
			r.song = clean(field(msg, "s"));
			r.diff = clean(field(msg, "d", "normal"));
			roomBroadcast(r, 'SONG|s=' + r.song + '|d=' + r.diff, null);
			lock.release();
			return;
		}

		if (t == "START")
		{
			lock.acquire();
			var r:NovaRoomObj = roomOf(c.user);
			if (r == null)
			{
				lock.release();
				c.send('ERR|c=NO_ROOM');
				return;
			}
			if (r.host != c.user)
			{
				lock.release();
				c.send('ERR|c=NOT_HOST');
				return;
			}
			r.started = true;
			r.t0 = now() + 3.0;
			roomBroadcast(r, 'START|s=' + r.song + '|d=' + r.diff + '|t0=' + r.t0 + '|seed=' + randStr(6), null);
			lock.release();
			return;
		}

		if (t == "RT")
		{
			// RT|combo|miss|acc|score|health  ->  房间里其他人收到 PEER|...
			var parts:Array<String> = msg.split("|");
			lock.acquire();
			var r:NovaRoomObj = roomOf(c.user);
			if (r != null)
			{
				var slot:Int = c.spectator ? -1 : slotOf(r, c.user);
				var combo:String = parts.length > 1 ? parts[1] : "0";
				var miss:String = parts.length > 2 ? parts[2] : "0";
				var acc:String = parts.length > 3 ? parts[3] : "0";
				var score:String = parts.length > 4 ? parts[4] : "0";
				var health:String = parts.length > 5 ? parts[5] : "1";
				roomBroadcast(r, 'PEER|slot=' + slot + '|u=' + c.user + '|team=' + c.team + '|c=' + combo + '|m=' + miss
					+ '|a=' + acc + '|s=' + score + '|h=' + health, c.user);
			}
			lock.release();
			return;
		}

		if (t == "SCORE")
		{
			if (c.user.length == 0)
			{
				c.send('ERR|c=NOT_LOGGED_IN');
				return;
			}
			var key:String = clean(field(msg, "s")) + "|" + clean(field(msg, "d", "normal"));
			var sc:Null<Int> = Std.parseInt(field(msg, "score", "0"));
			var ac:Float = Std.parseFloat(field(msg, "a", "0"));
			var cb:Null<Int> = Std.parseInt(field(msg, "c", "0"));
			if (sc == null)
				sc = 0;
			if (cb == null)
				cb = 0;
			if (Math.isNaN(ac))
				ac = 0;

			lock.acquire();
			var entry:Dynamic = null;
			for (l in leaderboard)
				if (l.k == key)
					entry = l;
			if (entry == null)
			{
				entry = {k: key, e: []};
				leaderboard.push(entry);
			}
			entry.e.push({u: c.user, score: sc, acc: ac, combo: cb, t: Std.int(now())});
			entry.e.sort(function(a:Dynamic, b:Dynamic):Int
			{
				return Std.int(b.score) - Std.int(a.score);
			});
			while (entry.e.length > 50)
				entry.e.pop();
			saveData();

			var rank:Int = -1;
			for (i in 0...entry.e.length)
				if (entry.e[i].u == c.user && entry.e[i].score == sc)
				{
					rank = i;
					break;
				}
			c.send('SCOREOK|rank=' + (rank + 1));
			lock.release();
			return;
		}

		if (t == "LEADERBOARD")
		{
			var key:String = clean(field(msg, "s")) + "|" + clean(field(msg, "d", "normal"));
			lock.acquire();
			var entry:Dynamic = null;
			for (l in leaderboard)
				if (l.k == key)
					entry = l;
			var list:Array<Dynamic> = new Array<Dynamic>();
			if (entry != null)
				list = entry.e;
			c.send('LB|n=' + list.length);
			var n:Int = list.length;
			if (n > 20)
				n = 20;
			for (i in 0...n)
				c.send('LBI|i=' + i + '|u=' + list[i].u + '|score=' + list[i].score
					+ '|a=' + list[i].acc + '|c=' + list[i].combo);
			c.send('LBEND');
			lock.release();
			return;
		}

		c.send('ERR|c=UNKNOWN|t=' + t);
	}

	static function loginOk(c:NovaClientObj, u:String):Void
	{
		var tk:String = randStr(24);
		tokens.push(tk);
		tokenUser.push(u);
		if (tokens.length > 500)
		{
			tokens.shift();
			tokenUser.shift();
		}
		c.user = u;
		c.send('LOGINOK|token=' + tk + '|u=' + u);
	}

	static function leaveRoom(c:NovaClientObj, r:NovaRoomObj):Void
	{
		var i:Int = r.players.indexOf(c.user);
		if (i >= 0)
		{
			r.players.splice(i, 1);
			r.slots.splice(i, 1);
		}
		r.spectators.remove(c.user);
		roomBroadcast(r, 'LEAVE|u=' + c.user, c.user);
		if (r.players.length == 0 && r.spectators.length == 0)
			rooms.remove(r);
		c.roomId = -1;
		c.slot = -1;
	}

	public static function roomCount():Int
	{
		return rooms.length;
	}
}
