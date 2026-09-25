package server.net;

/**
 * NovaNet —— NF Fusion (NovaFlare) 的联机客户端。
 *
 * 只依赖 haxe stdlib（sys.net.Socket / sys.thread），不碰 UDP：
 * 本工程的 Macros.hx 里 sys.net.UdpSocket 是禁用的（会触发
 * "Failed to load function std@socket_set_broadcast"），所以实时数据走 TCP +
 * TCP_NODELAY(setFastSend)，小包 20Hz，局域网延迟 <5ms，公网也就一个 RTT。
 *
 * 用法：
 *   NovaNet.connect("1.2.3.4", 27310);
 *   NovaNet.login("alice", sha256("密码"));
 *   NovaNet.createRoom("我的房", "bopeebo", "normal", 2);
 *   // 每帧：
 *   for (m in NovaNet.poll()) NovaNet.apply(m);
 *   NovaNet.sendRealtime(combo, misses, accuracy, songScore, health);
 */
#if sys
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Mutex;
import sys.thread.Thread;
#end
import haxe.io.Bytes;
import haxe.Http;
import StringTools;

typedef NovaMember = {
	var slot:Int;
	var team:Int;
	var name:String;
	var combo:Int;
	var miss:Int;
	var acc:Float;
	var score:Int;
	var health:Float;
	var spec:Bool;
};

class NovaNet
{
	public static var connected(default, null):Bool = false;
	public static var inRoom(default, null):Bool = false;

	public static var userName:String = "PLAYER";
	public static var token:String = "";
	public static var selfSlot:Int = 0;        // 0 = 房主(对手侧), 1 = 客人(BF侧), -1 = 观战
	public static var roomId:Int = -1;
	public static var roomSong:String = "";
	public static var roomDiff:String = "normal";
	public static var roomHost:String = "";
	public static var roomCode:String = "";      // 服务器下发的 6 位房间码
	public static var startAt:Float = 0;       // 服务器下发的开局时间(秒, unix)
	public static var localTimeOffset:Float = 0;

	// 对手实时状态
	public static var peerCombo:Int = 0;
	public static var peerMiss:Int = 0;
	public static var peerAcc:Float = 100;
	public static var peerScore:Int = 0;
	public static var peerHealth:Float = 1;
	public static var peerSlot:Int = -1;

	// 最近一次 Ping 的 RTT(毫秒)
	public static var pingMs:Int = -1;
	public static var members:Map<Int, NovaMember> = new Map();
	public static var selfTeam:Int = 0;

	static var sock:Socket = null;
	static var mtx:Mutex = new Mutex();
	static var inbound:Array<String> = [];
	static var rooms:Array<String> = [];       // 最近一次 LISTROOMS 的结果
	static var lb:Array<String> = [];          // 最近一次排行榜结果
	static var lastPingSent:Float = 0;

	// ------------------------------------------------------------ 连接
	public static function connect(host:String, port:Int = 27310):Bool
	{
		#if !sys
		return false;
		#end
		disconnect();
		try
		{
			sock = new Socket();
			sock.setFastSend(true);            // TCP_NODELAY
			sock.connect(new Host(host), port);
			connected = true;
			Thread.create(readerLoop);
			return true;
		}
		catch (e:Dynamic)
		{
			connected = false;
			sock = null;
			return false;
		}
	}

	public static function disconnect():Void
	{
		connected = false;
		inRoom = false;
		roomId = -1;
		try
		{
			if (sock != null)
				sock.close();
		}
		catch (e:Dynamic) {}
		sock = null;
	}

	static function readerLoop():Void
	{
		var s:Socket = sock;
		while (connected)
		{
			var line:String = null;
			try
			{
				line = s.input.readLine();
			}
			catch (e:Dynamic)
			{
				break;
			}
			if (line == null || line.length == 0)
				continue;
			mtx.acquire();
			inbound.push(StringTools.trim(line));
			mtx.release();
		}
		connected = false;
	}

	/** 每帧调用一次，取出服务器推来的消息。 */
	public static function poll():Array<String>
	{
		mtx.acquire();
		var out:Array<String> = inbound.copy();
		inbound = [];
		mtx.release();
		return out;
	}

	static function raw(msg:String):Void
	{
		if (!connected || sock == null)
			return;
		try
		{
			sock.output.write(Bytes.ofString(msg + "\n"));
			sock.output.flush();
		}
		catch (e:Dynamic)
		{
			connected = false;
		}
	}

	// ------------------------------------------------------------ 发包
	public static function register(user:String, pwHash:String, email:String = ""):Void
		raw('REG|u=$user|p=$pwHash|e=$email');

	public static function login(user:String, pwHash:String):Void
		raw('LOGIN|u=$user|p=$pwHash');

	public static function loginWithToken(t:String):Void
		raw('TOKEN|k=$t');

	public static function requestMailCode(user:String, email:String):Void
		raw('MAILCODE|u=$user|e=$email');

	public static function verifyMail(user:String, code:String):Void
		raw('VERIFY|u=$user|c=$code');

	public static function listRooms():Void
	{
		rooms = [];
		raw('LISTROOMS');
	}

	public static function createRoom(name:String, song:String, diff:String, max:Int):Void
		raw('CREATEROOM|name=$name|s=$song|d=$diff|max=$max');

	public static function joinRoom(id:Int, spectate:Bool = false, team:Int = 0):Void
	{
		selfTeam = team;
		raw('JOINROOM|id=$id|spec=' + (spectate ? "1" : "0") + '|team=' + team);
	}

	/** 用房间码进房（服务器分配，6 位，大小写不敏感） */
	public static function joinByCode(code:String, spectate:Bool = false, team:Int = 0):Void
	{
		selfTeam = team;
		var cc:String = code.toUpperCase();
		cc = StringTools.replace(cc, "|", "");
		raw('JOINCODE|code=' + cc + '|spec=' + (spectate ? "1" : "0") + '|team=' + team);
	}

	public static function leaveRoom():Void
	{
		raw('LEAVEROOM');
		inRoom = false;
		roomId = -1;
		roomCode = "";
	}

	public static function chat(text:String):Void
		raw('CHAT|m=' + StringTools.replace(StringTools.replace(text, "|", " "), "\n", " "));

	public static function setSong(song:String, diff:String):Void
		raw('SETSONG|s=$song|d=$diff');

	public static function startMatch():Void
		raw('START');

	public static function submitScore(song:String, diff:String, score:Int, acc:Float, combo:Int):Void
		raw('SCORE|s=$song|d=$diff|score=$score|a=$acc|c=$combo');

	public static function requestLeaderboard(song:String, diff:String):Void
	{
		lb = [];
		raw('LEADERBOARD|s=$song|d=$diff');
	}

	public static function ping():Void
	{
		#if sys
		lastPingSent = Sys.time();
		#end
		raw('PING|t=' + Std.int(Sys.time() * 1000));
	}

	/** 实时状态推送，建议在 PlayState.update 里以 ~20Hz 调用。 */
	public static function sendRealtime(combo:Int, miss:Int, acc:Float, score:Int, health:Float):Void
	{
		raw('RT|$combo|$miss|$acc|$score|$health');
	}

	// ------------------------------------------------------------ 解析
	public static function typeOf(msg:String):String
	{
		var i:Int = msg.indexOf("|");
		return i < 0 ? msg : msg.substring(0, i);
	}

	public static function field(msg:String, key:String, def:String = ""):String
	{
		var prefix:String = key + "=";
		for (p in msg.split("|"))
			if (p.indexOf(prefix) == 0)
				return p.substring(prefix.length);
		return def;
	}

	/** 处理一条消息并更新内部状态；返回消息类型，UI 按类型做事。 */
	public static function apply(msg:String):String
	{
		var t:String = typeOf(msg);
		switch (t)
		{
			case "LOGINOK":
				token = field(msg, "token", token);
				userName = field(msg, "u", userName);
		case "ROOMOK":
			roomId = Std.parseInt(field(msg, "id", "-1"));
			roomCode = field(msg, "code", roomCode);
			selfSlot = Std.parseInt(field(msg, "slot", "0"));
			members = new Map();
			members.set(selfSlot, {slot: selfSlot, team: 0, name: userName, combo: 0, miss: 0, acc: 100, score: 0, health: 1, spec: false});
			inRoom = true;
		case "JOINOK":
			roomId = Std.parseInt(field(msg, "id", "-1"));
			roomCode = field(msg, "code", roomCode);
			selfSlot = Std.parseInt(field(msg, "slot", "0"));
			roomSong = field(msg, "song", roomSong);
			roomDiff = field(msg, "d", roomDiff);
			roomHost = field(msg, "host", roomHost);
			members = new Map();
			members.set(selfSlot, {slot: selfSlot, team: selfTeam, name: userName, combo: 0, miss: 0, acc: 100, score: 0, health: 1, spec: (selfSlot < 0)});
			inRoom = true;
			case "ROOM":
				rooms.push(msg);
			case "LBI":
				lb.push(msg);
		case "PEER":
			var slot:Int = Std.parseInt(field(msg, "slot", "-1"));
			var combo:Int = Std.parseInt(field(msg, "c", "0"));
			var miss:Int = Std.parseInt(field(msg, "m", "0"));
			var a:Null<Float> = Std.parseFloat(field(msg, "a", "100"));
			var acc:Float = (a == null) ? 100 : a;
			var score:Int = Std.parseInt(field(msg, "s", "0"));
			var h:Null<Float> = Std.parseFloat(field(msg, "h", "1"));
			var health:Float = (h == null) ? 1 : h;
			var team:Int = Std.parseInt(field(msg, "team", "0"));
			var nm:String = field(msg, "u", "");
			if (slot >= 0)
			{
				var m:NovaMember = {slot: slot, team: team, name: nm, combo: combo, miss: miss, acc: acc, score: score, health: health, spec: false};
				members.set(slot, m);
				if (slot != selfSlot)
				{
					peerSlot = slot;
					peerCombo = combo; peerMiss = miss; peerAcc = acc; peerScore = score; peerHealth = health;
				}
			}
			case "START":
				roomSong = field(msg, "s", roomSong);
				roomDiff = field(msg, "d", roomDiff);
				var t0:Null<Float> = Std.parseFloat(field(msg, "t0", "0"));
				startAt = (t0 == null) ? 0 : t0;
				#if sys
				localTimeOffset = startAt - (Date.now().getTime() / 1000.0);
				#end
			case "PONG":
				pingMs = Std.int(Sys.time() * 1000) - Std.parseInt(field(msg, "t", "0"));
			case "SONG":
				roomSong = field(msg, "s", roomSong);
				roomDiff = field(msg, "d", roomDiff);
					case "JOIN":
			var jslot:Int = Std.parseInt(field(msg, "slot", "-1"));
			var ju:String = field(msg, "u", "");
			var jsp:Bool = field(msg, "spec", "0") == "1";
			var jtm:Int = Std.parseInt(field(msg, "team", "0"));
			if (jslot >= 0)
			{
				var jm = members.get(jslot);
				if (jm == null) { jm = {slot:jslot, team:jtm, name:ju, combo:0, miss:0, acc:100, score:0, health:1, spec:jsp}; members.set(jslot, jm); }
				else { jm.name = ju; jm.spec = jsp; jm.team = jtm; }
			}
		case "LEAVE":
			var lu:String = field(msg, "u", "");
			for (k in members.keys())
				if (members.get(k).name == lu) members.remove(k);
		case "KICK":
				inRoom = false;
				roomId = -1;
		}
		return t;
	}

	public static function getRooms():Array<String>
		return rooms;

	public static function getLeaderboard():Array<String>
		return lb;

	public static function isHost():Bool
		return selfSlot == 0;

	public static function isSpectator():Bool
		return selfSlot < 0;

	// ------------------------------------------------------------ 服务器列表
	/** 从 NovaMaster 拉列表，返回原始行数组；失败返回空数组。 */
	public static function fetchServerList(url:String):Array<String>
	{
		try
		{
			var txt:String = Http.requestUrl(url);
			var out:Array<String> = [];
			for (chunk in txt.split("},{"))
				if (chunk.indexOf("\"ip\"") >= 0)
					out.push(chunk);
			return out;
		}
		catch (e:Dynamic)
		{
			return [];
		}
	}
}
