package states.netMenuState;

import flixel.text.FlxText;
import flixel.addons.ui.FlxInputText;
import flixel.ui.FlxButton;
import states.mainMenuState.MainMenuState;
import server.net.NovaNet;
import server.net.NovaServer;
import games.backend.Song;
import games.backend.StageData;
import games.backend.Highscore;
import games.backend.WeekData;
import StringTools;

/**
 * NetMenuState —— 联机页（主菜单 NET PLAY 或 Freeplay 选歌后进入）
 *
 * 流程：
 *   1) 没连服务器 → 点"开服/连本机"一键本机开服并自连；或输 IP 连接别人
 *   2) 选歌页：↑↓ 选歌，点"进房间"进这首歌的房间（有就加入，没有就建，人数/队伍可在这里选）
 *   3) 房间页：成员榜(实时分数) / 聊天tab / 开始(数字键1) / 观战切换 / 排行榜 / 离开
 *   4) 房主点开始 → 两边自动进歌
 *
 * UI 全部用可触摸/可点击的 FlxButton 控件；从 Freeplay 带进来的歌名+难度直接进房，房间内不再重选难度。
 */
class NetMenuState extends MusicBeatState
{
	static inline var PAGE_CONNECT:Int = 0;
	static inline var PAGE_SONGS:Int = 1;
	static inline var PAGE_ROOM:Int = 2;
	static inline var PAGE_LB:Int = 3;

	/** 从 Freeplay 选完歌跳进来时带的歌名（已 formatToSongPath）。 */
	public static var nextSong:String = "";
	/** 从 Freeplay 带进来的难度（已 formatToSongPath），进房直接用，房间内不再重选。 */
	public static var nextDiff:String = "";
	static var lanUser:String = "";

	var page:Int = 0;
	var lastChoice:Int = 0;
	var titleTxt:FlxText;
	var bodyTxt:FlxText;
	var hintTxt:FlxText;
	var input:FlxInputText;

	// 触摸按钮栏
	var btns:Array<FlxButton> = [];
	var currentFuncs:Array<Void->Void> = [];
	var tabMode:Int = 0; // 0=成员信息, 1=聊天

	var hostIP:String = "127.0.0.1";
	var port:Int = 27310;
	var user:String = "";
	var pass:String = "";
	var status:String = "";
	var diff:String = "normal";
	var wantSpectate:Bool = false;
	var wantCode:Bool = false;      // 输入框是否处于「输房间码」模式

	var songNames:Array<String> = [];
	var songCursor:Int = 0;
	var pendingSong:String = "";
	var pendingDiff:String = "";

	// 多人房设置
	var wantMax:Int = 2;
	var wantTeam:Int = 0;
	static var maxList:Array<Int> = [2, 4, 6, 8, 10];

	var roomLines:Array<String> = [];
	var lbLines:Array<String> = [];
	var chatLines:Array<String> = [];

	override public function create():Void
	{
		super.create();

		var cnFont:String = Paths.font("Lang-ZH.ttf");

		titleTxt = new FlxText(40, 24, 1200, "联机", 36);
		titleTxt.setFormat(cnFont, 36, 0xFFFFFFFF);
		add(titleTxt);

		bodyTxt = new FlxText(40, 90, 1200, "", 20);
		bodyTxt.setFormat(cnFont, 20, 0xFFDDDDDD);
		add(bodyTxt);

		input = new FlxInputText(40, 620, 700, "");
		input.setFormat(cnFont, 20, 0xFFFFFFFF);
		input.backgroundColor = 0x66000000;
		input.fieldBorderColor = 0xFFFFFFFF;
		input.caretColor = 0xFFFFFFFF;
		add(input);

		hintTxt = new FlxText(40, 690, 1200, "", 16);
		hintTxt.setFormat(cnFont, 16, 0xFF9AA0A6);
		add(hintTxt);

		// 触摸按钮栏（一排 6 个，鼠标/触摸均可点）
		for (i in 0...6)
		{
			var idx:Int = i; var b = new FlxButton(40 + i * 200, 668, "", function() { if (currentFuncs != null && idx < currentFuncs.length && currentFuncs[idx] != null) currentFuncs[idx](); });
			b.setGraphicSize(186, 34);
			b.updateHitbox();
			b.label.setFormat(cnFont, 16, 0xFFFFFFFF);
			add(b);
			btns.push(b);
		}

		loadSongs();

		// 从 Freeplay 选完歌跳进来：直接进这首歌的房间（带难度）
		if (nextSong.length > 0)
		{
			var want:String = nextSong;
			nextSong = "";
			var d:String = nextDiff;
			nextDiff = "";
			pendingSong = want;
			pendingDiff = (d.length > 0) ? d : diff;
			if (NovaNet.connected)
			{
				status = "正在找这首歌的房间...";
				setPage(PAGE_SONGS);
				return;
			}
			status = "未连接（已记住歌名/难度），启用局域网后自动进房";
			setPage(PAGE_CONNECT);
			return;
		}

		if (!NovaNet.connected)
			setPage(PAGE_CONNECT);
		else if (NovaNet.inRoom)
			setPage(PAGE_ROOM);
		else
			setPage(PAGE_SONGS);
	}

	function setBtns(labels:Array<String>, funcs:Array<Void->Void>):Void
	{
		currentFuncs = funcs;
		for (i in 0...btns.length)
		{
			if (i < labels.length && labels[i].length > 0)
			{
			btns[i].visible = true;
			btns[i].label.text = labels[i];
			btns[i].label.dirty = true;
			
		}
		else
		{
			btns[i].visible = false;
			
		}
		}
	}

	function tabInfo():Void { tabMode = 0; redraw(); }
	function tabChat():Void { tabMode = 1; redraw(); FlxG.stage.focus = input.textField; }
	function cycleMax():Void
	{
		var i:Int = maxList.indexOf(wantMax);
		if (i < 0) i = 0;
		wantMax = maxList[(i + 1) % maxList.length];
		redraw();
	}
	function cycleTeam():Void { wantTeam = 1 - wantTeam; redraw(); }

	/** 切到「输房间码」模式：在下方输入框打码后回车即可进房 */
	function askCode():Void
	{
		wantCode = true;
		input.text = "";
		status = "请输入房间码后回车（6 位）";
		try { FlxG.stage.focus = input.textField; } catch (e:Dynamic) {}
		redraw();
	}

	function setPage(p:Int):Void
	{
		page = p;
		wantCode = false;
		lastChoice = 0;
		input.text = "";
		if (p == PAGE_SONGS)
			NovaNet.listRooms();
		redraw();
	}

	function loadSongs():Void
	{
		songNames = [];
		try
		{
			WeekData.reloadWeekFiles(false);
			for (w in WeekData.weeksList)
			{
				var wd:WeekData = WeekData.weeksLoaded.get(w);
				if (wd == null) continue;
				if (wd.hideFreeplay == true) continue;
				for (s in wd.songs)
					songNames.push(Std.string(s[0]));
			}
		}
		catch (e:Dynamic) {}
		if (songNames.length == 0) songNames.push("Bopeebo");
		if (songCursor >= songNames.length) songCursor = 0;
	}

	function currentSong():String
	{
		if (songNames.length == 0) return "";
		return Paths.formatToSongPath(songNames[songCursor]);
	}

	function pickSong(song:String):Void
	{
		pendingSong = song;
		// 不覆盖难度：保留来自选歌的 pendingDiff；只有主菜单直进时才用本地默认
		if (pendingDiff.length == 0) pendingDiff = diff;
		status = "looking for a room...";
		NovaNet.listRooms();
	}

	function redraw():Void
	{
		var b:String = "";

		if (page == PAGE_CONNECT)
		{
			titleTxt.text = "联机 · 未连接";
			b += "未连接到服务器。点下方按钮开服或连接。\n\n";
			b += "端口 " + port + "  " + (NovaServer.running
				? ("服务器运行中 - " + NovaServer.clientCount + " 人在线, " + NovaServer.roomCount() + " 个房间")
				: "服务器: 未开启") + "\n";
			b += "本机名: " + localName() + "\n";
			if (NovaServer.lastError.length > 0)
				b += "   " + NovaServer.lastError + "\n";
			b += "\n状态: " + status + "\n";
			hintTxt.text = "点按钮操作  |  ESC = 回主菜单";
			setBtns(
				["开服/连本机", "输IP连接", "只开服", "人数:" + wantMax, "队伍:" + (wantTeam == 0 ? "A" : "B"), ""],
				[function() { doChoice(1); }, function() { doChoice(2); }, function() { doChoice(6); }, cycleMax, cycleTeam, function() {}]
			);
		}
		else if (page == PAGE_SONGS)
		{
			titleTxt.text = "联机 · 选择歌曲";
			b += "玩家: " + NovaNet.userName + "   服务器: " + hostIP + ":" + port
				+ "   延迟: " + NovaNet.pingMs + "ms\n";
			if (NovaServer.running)
				b += "(本机已开服: " + NovaServer.clientCount + " 人在线, " + NovaServer.roomCount() + " 个房间)\n";
			b += "难度(来自选歌): " + pendingDiff + (wantSpectate ? "   [观战模式]" : "") + "\n";
			b += "状态: " + status + "\n\n";

			var start:Int = songCursor - 6;
			if (start < 0) start = 0;
			var end:Int = start + 14;
			if (end > songNames.length) end = songNames.length;
			for (i in start...end)
				b += (i == songCursor ? "  > " : "    ") + i + ". " + songNames[i] + "\n";

			b += "\n人数: " + wantMax + "   队伍: " + (wantTeam == 0 ? "A" : "B") + "\n";
			hintTxt.text = "上下键选歌   点按钮操作   ESC 返回";
			setBtns(
				["刷新", "进房间", "人数:" + wantMax, "队伍:" + (wantTeam == 0 ? "A" : "B"), "断开", "输房间码"],
				[function() { doChoice(1); }, function() { doChoice(3); }, cycleMax, cycleTeam, function() { doChoice(6); }, askCode]
			);
		}
		else if (page == PAGE_ROOM)
		{
			titleTxt.text = "联机 · 房间";
			b += "座位: " + NovaNet.selfSlot + (NovaNet.isSpectator() ? " (观战)" : "")
				+ "   延迟: " + NovaNet.pingMs + "ms\n";
			b += "状态: " + status + "\n\n";
			b += "房间 #" + NovaNet.roomId + "   歌曲: " + NovaNet.roomSong
				+ "   难度: " + NovaNet.roomDiff + "   房主: " + NovaNet.roomHost + "\n";
			b += "房间码: " + (NovaNet.roomCode.length > 0 ? NovaNet.roomCode : "-") + "   (把房间码告诉队友即可直接进房)\n\n";

			if (tabMode == 0)
			{
				var cnt:Int = 0;
				for (_ in NovaNet.members.keys()) cnt++;
				b += "成员(" + cnt + "):\n";
				for (m in NovaNet.members)
				{
					b += "  " + (m.slot == NovaNet.selfSlot ? "★" : " ") + "[" + (m.team == 0 ? "A" : "B") + "] "
						+ m.name + "  连击 " + m.combo + "  失误 " + m.miss
						+ "  准确 " + m.acc + "%  分 " + m.score + (m.spec ? " (观战)" : "") + "\n";
				}
				b += "\n(房主点[开始]即可开赛，数字键 1 = 开始)\n";
			}
			else
			{
				b += "聊天:\n";
				for (i in 0...chatLines.length)
					b += chatLines[i] + "\n";
				b += "\n(在下方输入框打字，回车发送)\n";
			}
			hintTxt.text = "点按钮操作  |  数字1=开始  |  ESC=回选歌";
			setBtns(
				["信息", "聊天", "开始", "观战/上场", "排行榜", "离开"],
				[tabInfo, tabChat, function() { doChoice(3); }, function() { doChoice(4); }, function() { doChoice(5); }, function() { doChoice(6); }]
			);
		}
		else
		{
			titleTxt.text = "联机 · 排行榜";
			b += "状态: " + status + "\n\n";
			if (lbLines.length == 0)
				b += "  (暂无成绩)\n";
			for (i in 0...lbLines.length)
				b += lbLines[i] + "\n";
			hintTxt.text = "点[返回] 或 ESC";
			setBtns(["返回", "", "", "", "", ""],
				[function() { setPage(PAGE_ROOM); }, function() {}, function() {}, function() {}, function() {}, function() {}]);
		}

		bodyTxt.text = b;
	}

	function localName():String
	{
		try
		{
			return sys.net.Host.localhost();
		}
		catch (e:Dynamic)
		{
			return "unknown";
		}
	}

	function pump():Void
	{
		var msgs:Array<String> = NovaNet.poll();
		for (m in msgs)
		{
			var t:String = NovaNet.apply(m);

			if (t == "ROOM")
			{
				roomLines = [];
				for (r in NovaNet.getRooms())
					roomLines.push("#" + NovaNet.field(r, "id") + " " + NovaNet.field(r, "name")
						+ " | " + NovaNet.field(r, "song") + " | "
						+ NovaNet.field(r, "players") + "/" + NovaNet.field(r, "max")
						+ " | spec " + NovaNet.field(r, "spec"));
			}
			else if (t == "LB")
			{
				lbLines = [];
			}
			else if (t == "LBI")
			{
				lbLines.push(Std.string(lbLines.length + 1) + ". " + NovaNet.field(m, "u")
					+ "  " + NovaNet.field(m, "score")
					+ "  " + NovaNet.field(m, "a") + "%  x" + NovaNet.field(m, "c"));
			}
			else if (t == "CHAT")
			{
				chatLines.push(NovaNet.field(m, "u") + ": " + NovaNet.field(m, "m"));
				if (chatLines.length > 8) chatLines.shift();
			}
			else if (t == "LOGINOK")
			{
				status = "login ok";
			}
			else if (t == "ERR")
			{
				status = "error: " + NovaNet.field(m, "c");
			}
			else if (t == "SONG")
			{
				status = "song -> " + NovaNet.roomSong + " (" + NovaNet.roomDiff + ")";
			}
			else if (t == "JOINOK" || t == "ROOMOK")
			{
				status = NovaNet.isSpectator() ? "观战中" : "in room";
				setPage(PAGE_ROOM);
				return;
			}
			else if (t == "KICK")
			{
				status = "kicked";
				setPage(PAGE_SONGS);
				return;
			}
			else if (t == "ROOMSEND")
			{
				if (pendingSong.length > 0)
				{
					var target:Int = -1;
					for (r in NovaNet.getRooms())
					{
						if (NovaNet.field(r, "song") == pendingSong
							&& NovaNet.field(r, "d") == pendingDiff)
						{
							var pl:Null<Int> = Std.parseInt(NovaNet.field(r, "players", "0"));
							var mx:Null<Int> = Std.parseInt(NovaNet.field(r, "max", "2"));
							var id:Null<Int> = Std.parseInt(NovaNet.field(r, "id", "-1"));
							if (id != null && id >= 0 && pl != null && mx != null && pl < mx)
							{
								target = id;
								break;
							}
						}
					}
					if (target >= 0)
					{
						NovaNet.joinRoom(target, wantSpectate, wantTeam);
						status = "joining room #" + target;
					}
					else
					{
						NovaNet.createRoom(NovaNet.userName + " 的房间", pendingSong, pendingDiff, wantMax);
						status = "creating room...";
					}
					pendingSong = "";
				}
			}
			else if (t == "START")
			{
				status = "host started, loading...";
				redraw();
				var wait:Float = NovaNet.startAt - (Date.now().getTime() / 1000.0);
				if (wait > 2.0) wait = 2.0;
				if (wait > 0.15)
				{
					new FlxTimer().start(wait, function(tmr:FlxTimer)
					{
						netStartSong();
					});
				}
				else
				{
					netStartSong();
				}
				return;
			}
		}
		if (msgs.length > 0) redraw();
	}

	function netStartSong():Void
	{
		var song:String = Paths.formatToSongPath(NovaNet.roomSong);
		if (song.length == 0)
		{
			status = "host has not picked a song";
			redraw();
			return;
		}

		if (Difficulty.list.length == 0) Difficulty.resetList();

		var want:String = Paths.formatToSongPath(NovaNet.roomDiff);
		var idx:Int = 0;
		for (i in 0...Difficulty.list.length)
		{
			if (Paths.formatToSongPath(Difficulty.list[i]) == want)
			{
				idx = i;
				break;
			}
		}

		try
		{
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = idx;
			PlayState.SONG = Song.loadFromJson(Highscore.formatSong(song, idx), song);
			StageData.loadDirectory(PlayState.SONG);
		}
		catch (e:Dynamic)
		{
			status = "chart load error: " + e;
			redraw();
			return;
		}

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function doChoice(n:Int):Void
	{
		lastChoice = n;

		if (page == PAGE_CONNECT)
		{
			if (n == 1 || n == 6)
			{
				if (NovaServer.running && n == 6)
				{
					NovaServer.stop();
					status = "server stopped";
				}
				else
				{
					if (NovaServer.start(port))
					{
						hostIP = "127.0.0.1";
						status = "局域网联机已开启, 端口 " + port + ", 本机名 " + localName();
						if (NovaNet.connect("127.0.0.1", port))
						{
							autoLogin();
							return;
						}
						status = "server up, but self-connect failed";
					}
					else
					{
						status = "server failed: " + NovaServer.lastError;
					}
				}
			}
			else if (n == 2)
			{
				status = "输入服务器 IP 后按回车";
			}
			redraw();
			return;
		}

		if (page == PAGE_SONGS)
		{
			if (n == 1)
			{
				loadSongs();
				status = "songs: " + songNames.length;
			}
			else if (n == 2)
			{
				// 本地默认难度（仅当没从选歌带难度时生效）；进房仍以选歌难度为准
				if (diff == "normal") diff = "hard";
				else if (diff == "hard") diff = "easy";
				else diff = "normal";
				if (pendingDiff.length == 0) pendingDiff = diff;
				status = "本地默认难度 -> " + diff + " (进房仍用选歌难度)";
			}
			else if (n == 3)
			{
				pickSong(currentSong());
			}
			else if (n == 6)
			{
				NovaNet.disconnect();
				NovaServer.stop();
				status = "disconnected";
				setPage(PAGE_CONNECT);
				return;
			}
			redraw();
			return;
		}

		if (page == PAGE_ROOM)
		{
			if (n == 3)
			{
				NovaNet.startMatch();
				status = "starting...";
			}
			else if (n == 4)
			{
				var rid:Int = NovaNet.roomId;
				NovaNet.leaveRoom();
				NovaNet.joinRoom(rid, !NovaNet.isSpectator(), wantTeam);
				status = "switching...";
			}
			else if (n == 5)
			{
				NovaNet.requestLeaderboard(NovaNet.roomSong, NovaNet.roomDiff);
				setPage(PAGE_LB);
				return;
			}
			else if (n == 6)
			{
				NovaNet.leaveRoom();
				chatLines = [];
				setPage(PAGE_SONGS);
				return;
			}
			redraw();
		}
	}

	/** 一键局域网（静态）：本机开服 + 自连 + 自动注册登录一个随机账号。主菜单 / Freeplay 都能调。 */
	public static function autoLan():Void
	{
		if (NovaNet.connected) return;
		var port:Int = 27310;
		if (NovaServer.start(port))
			NovaNet.connect("127.0.0.1", port);
		if (NovaNet.connected)
		{
			if (lanUser.length == 0)
				lanUser = "P" + Std.string(Std.random(9000) + 1000);
			NovaNet.register(lanUser, haxe.crypto.Sha256.encode("novapass"), "");
			NovaNet.login(lanUser, haxe.crypto.Sha256.encode("novapass"));
		}
	}

	/** 本机开服后自动登录，省得每次手打；若有从 Freeplay 带的歌名则直接进那首歌的房间。 */
	function autoLogin():Void
	{
		NetMenuState.autoLan();
		if (pendingSong.length > 0)
			pickSong(pendingSong);
		else
			setPage(PAGE_SONGS);
	}

	function submitTyped(typed:String):Void
	{
		if (wantCode)
		{
			if (typed.length == 0)
				return;
			wantCode = false;
			var cc:String = typed.toUpperCase();
			status = "正在用房间码 " + cc + " 进房...";
			NovaNet.joinByCode(cc, wantSpectate, wantTeam);
			redraw();
			return;
		}
		if (page == PAGE_CONNECT)
		{
			if (typed.length > 0)
			{
				var asPort:Null<Int> = Std.parseInt(typed);
				if (typed.indexOf(".") < 0 && asPort != null)
				{
					port = asPort;
					redraw();
					return;
				}
				hostIP = typed;
				status = NovaNet.connect(hostIP, port) ? "connected" : "connect failed";
				if (NovaNet.connected)
					autoLogin();
				else
					redraw();
				return;
			}
			doChoice(1);
			return;
		}

		if (page == PAGE_SONGS)
		{
			if (typed.length > 0)
			{
				var n:Null<Int> = Std.parseInt(typed);
				if (n != null && n >= 0 && n < songNames.length)
				{
					songCursor = n;
					redraw();
				}
				pickSong(currentSong());
				return;
			}
			pickSong(currentSong());
			return;
		}

		if (page == PAGE_ROOM)
		{
			if (typed.length == 0)
			{
				redraw();
				return;
			}
			if (lastChoice == 5)
			{
				var p2:Array<String> = typed.split(",");
				NovaNet.requestLeaderboard(p2[0], p2.length > 1 ? p2[1] : NovaNet.roomDiff);
				setPage(PAGE_LB);
				return;
			}
			else
			{
				NovaNet.chat(typed);
			}
			redraw();
			return;
		}

		setPage(PAGE_ROOM);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		pump();

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (page == PAGE_LB)
			{
				setPage(PAGE_ROOM);
			}
			else if (page == PAGE_ROOM)
			{
				NovaNet.leaveRoom();
				chatLines = [];
				setPage(PAGE_SONGS);
			}
			else if (page == PAGE_SONGS)
			{
				setPage(PAGE_CONNECT);
			}
			else
			{
				MusicBeatState.switchState(new MainMenuState());
			}
			return;
		}

		if (page == PAGE_SONGS)
		{
			if (FlxG.keys.justPressed.UP)
			{
				songCursor--;
				if (songCursor < 0) songCursor = songNames.length - 1;
				redraw();
			}
			else if (FlxG.keys.justPressed.DOWN)
			{
				songCursor++;
				if (songCursor >= songNames.length) songCursor = 0;
				redraw();
			}
		}

		if (page == PAGE_ROOM)
		{
			if (FlxG.keys.justPressed.ONE) doChoice(3);        // 开始 = 数字键 1
			else if (FlxG.keys.justPressed.THREE) doChoice(1); // 聊天
			else if (FlxG.keys.justPressed.FOUR) doChoice(4);
			else if (FlxG.keys.justPressed.FIVE) doChoice(5);
			else if (FlxG.keys.justPressed.SIX) doChoice(6);
		}
		else
		{
			if (FlxG.keys.justPressed.ONE) doChoice(1);
			else if (FlxG.keys.justPressed.TWO) doChoice(2);
			else if (FlxG.keys.justPressed.THREE) doChoice(3);
			else if (FlxG.keys.justPressed.FOUR) doChoice(4);
			else if (FlxG.keys.justPressed.FIVE) doChoice(5);
			else if (FlxG.keys.justPressed.SIX) doChoice(6);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			var typed:String = StringTools.trim(input.text);
			input.text = "";
			submitTyped(typed);
		}
	}
}
