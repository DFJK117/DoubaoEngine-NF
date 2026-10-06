package general.backend;

import haxe.Exception;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import states.titleState.TitleState;

import games.backend.ExtraKeysHandler.EKNoteColor;

import lime.system.Display;

#if mobile
import general.objects.screen.MouseEffect;
import general.shaders.MobileShaderConverter;
#end

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables
{
	//更新这个直接原地爆破所有人设置
	public var prefsVersion:Int = 120;
	//更新这个能让性能相关的强制更新
	public var performanceDefaultsVersion:Int = 8;

	// General
	public var framerate:Int = 1000;
	public var drawFramerate:Int = 1000;
	public var lockRender:Bool = true;
	public var renderThread:Bool = true;
	public var resolution:String = 'Native';
	public var colorblindMode:String = 'None';
	public var lowQuality:Bool = false;
	public var gameQuality:Int = #if mobile 0 #else 1 #end;
	public var antialiasing:Bool = true;
	public var flashing:Bool = true;
	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = false;
	public var autoPause:Bool = true;
	public var gcFreeZone:Bool = true;
	#if mobile
	public var autoOrientation:Bool = false;
	public var autoShaderConversion:Bool = true;
	public var mouseTrailEffect:Bool = true;
	#end

	// Gameplay
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var flipChart:Bool = false;
	public var ghostTapping:Bool = true;
	public var guitarHeroSustains:Bool = true;
	public var noReset:Bool = false;
	// Opponent s
	public var playOpponent:Bool = false;
	public var opponentCodeFix:Bool = false;
	public var botOpponentFix:Bool = true;
	public var healthDrainOPPOMult:Float = 0.5;
	public var healthDrainOPPO:Bool = false;

	// Backend
	// Gameplay backend s
	public var gameplayGC:Bool = false;
	public var fixLNL:Int = 0; // fix long note length
	public var saveScoreBase:String = 'Score';
	public var mainMusic:String = 'None';
	public var optionMusic:String = 'None';
	public var pauseMusic:String = 'Tea Time';
	public var hitsoundType:String = 'Default';
	public var hitsoundVolume:Float = 0;
	public var oldHscriptVersion:Bool = false;
	public var pauseButton:Bool = #if mobile true #else false #end;
	public var compulsionPause:Bool = false;
	public var compulsionPauseNumber:Int = 3;
	public var gameOverVibration:Bool = false;
	public var ratingOffset:Int = 0;
	public var noteOffset:Int = 0;
	public var replayQuality:Bool = true;
	public var showReplayWatermark:Bool = true;
	public var marvelousWindow:Int = 15;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
	public var marvelousRating:Bool = true;
	public var marvelousSprite:Bool = true;

	// App backend s
	public var discordRPC:Bool = true;
	public var checkForUpdates:Bool = true;
	public var screensaver:Bool = false;
	public var githubCheck:Bool = false;
	public var filesCheck:Bool = true;
	public var quotaGCIncreace:Float = 1;

	// Game UI
	// Visble s
	public var hideHud:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;
	public var opponentStrums:Bool = true;
	public var judgementCounter:Bool = false;
	public var keyboardViewer:Bool = true;
	// TimeBar s
	public var timeBarType:String = 'Time Left';
	// HealthBar s
	public var healthBarAlpha:Float = 1;
	public var oldHealthBarVersion:Bool = false;
	// Combe s
	public var comboStacking:Bool = true;
	public var comboColor:Bool = true;
	public var comboOffsetFix:Bool = true;
	// KeyBoard s
	public var keyboardAlpha:Float = 0.8;
	public var keyboardTimeDisplay:Bool = true;
	public var keyboardTime:Float = 500;
	public var keyboardBGColor:String = 'WHITE';
	public var keyboardTextColor:String = 'BLACK';
	// Camera s
	public var camZooms:Bool = true;
	public var scoreZoom:Bool = true;

	// Skin
	public var noteSkin:String = 'Default';
	public var noteRGB:Bool = true;
	public var noteColorSwap:Bool = false;
	// splash s
	public var splashSkin:String = 'Psych';
	public var splashRGB:Bool = true;
	public var showSplash:Bool = true;
	public var splashAlpha:Float = 0.6;

	// Input
	// Moblie Input Backend s
	public var dynamicColors:Bool = true;
	public var needMobileControl:Bool = true; // work for desktop
	public var hitboxLocation:String = 'Bottom';
	public var controlsAlpha:Float = 0.6;
	public var playControlsAlpha:Float = 0.2;
	public var hideHitboxHints:Bool = false;

	public var extraKey:Int = 4;
	public var extraKeyReturn1:String = 'Space';
	public var extraKeyReturn2:String = 'Space';
	public var extraKeyReturn3:String = 'Shift';
	public var extraKeyReturn4:String = 'Shift';

	// User Interface
	public var uiScale:Float = 1;

	public var customFade:String = 'Move';
	public var customFadeSound:Float = 0.5;
	public var customFadeText:Bool = true;
	public var skipTitleVideo:Bool = false;
	public var audioDisplayQuality:Int = 1;
	public var audioDisplayUpdate:Int = 50;
	public var resultsScreen:Bool = true;
	public var loadingScreen:Bool = false;
	public var loadThreads:Int = #if mobile 2 #else 4 #end;
	public var useFlixelCoords:Bool = true;

	// Watermark
	public var showFPS:Bool = true;
	public var rainbowFPS:Bool = true;
	public var fpsDisplayMode:String = 'TPS';
	public var memoryType:String = 'Usage';
	public var fpsScale:Float = 1;
	public var watermarkScale:Float = 1;
	public var showWatermark:Bool = true;

	public var comboOffset:Array<Int> = [0, 0, 0, 0, 530, 470];

	public var language:String = 'English';

	public var storageFolder:String = 'NovaFlare Engine';

	public var developerMode:Bool = false;
	public var devConScale:Float = #if mobile 1.8 #else 1.5 #end;
	public var deepDebug:Bool = false;

	// 维护设置 - Lua 语法错误提示。
	// ★ 只管"脚本报错"这一条通道（PlayState.addScriptErrorToDebug）：开启后 Lua 报错会像以前那样
	//   一条条铺在屏幕左上角，关闭（默认）则只写进日志。
	//   debugPrint / luaTrace / 引擎自身的缺 shader、缺视频等报错走的是 addTextToDebug，
	//   不受这个开关影响，始终照常显示。
	public var luaErrorOverlay:Bool = false;

	// 维护设置 - HScript 语法错误提示（与上面那条各自独立，互不影响）。
	// ★ 先澄清一件事：HScript 脚本自身的报错（Iris.error / Iris.warn）**本来就不上屏** ——
	//   链路是 Iris.logLevel → Sys.println + 开发者控制台 + 1145 trace 客户端，里面没有
	//   addTextToDebug。真正会铺到屏幕上的 HScript 红字只有 HScriptBase 里那几处脚本报错，
	//   这个开关管的就是它们（PlayState.addHScriptErrorToDebug）。
	public var hscriptErrorOverlay:Bool = false;

	// Trace Console / LOG 悬浮按钮的位置与尺寸记忆（-1 = 未自定义，用默认位置）
	public var consoleButtonX:Float = -1;
	public var consoleButtonY:Float = -1;
	public var consoleX:Float = -1;
	public var consoleY:Float = -1;
	public var consoleW:Float = -1;
	public var consoleH:Float = -1;

	// 维护设置 - 调整移动端各Editor键位（开启后隐藏默认Editor虚拟按键并启用外部按键编辑器）
	public var adjustMobileEditorKeys:Bool = false;

	// 一次性迁移标记：移动端首次运行（或从旧版升级）自动开启上面这项，
	// 让 APK 内置的 Editor 键位开箱即用；只生效一次，之后尊重用户手动开关。
	public var emkDefaultsVersion:Int = 0;

	//For Extra Keys (maybe)
	public var showKeybinds:Bool = false;
	
	public var enableRecordRotation:Bool = true;
	public var enableBpmZoom:Bool = true;
	
	//public var theme:Array<String> = ["Circle", "Straight", "None"];
	//public var songInfo:Array<String> = ["None", "Middle", "topLeft", "downLeft", "topRight", "downRight"];
	public var theme:String = "Circle";
	public var songInfo:String = "None";
	
	//////////////////////////////////////////////////////////////////////////////////////

	//Psych引擎的箭头RGB可以扔了，已经几乎被PsychEK代替了————卡昔233
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
	];

	//其实这个也可以扔了,我们有多k，，，，，
	public var arrowHSV:Array<Array<Float>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];

	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];
}

class ClientPrefs
{
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};
	public static var modsData:Map<String, Map<String, Dynamic>>= [];

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [K, UP],
		'note_right' => [L, RIGHT],

		'0_key_0' => [SPACE],

		'1_key_0' => [D, LEFT],
		'1_key_1' => [K, RIGHT],

		'2_key_0' => [D],
		'2_key_1' => [SPACE],
		'2_key_2' => [K],

		'4_key_0' => [D],
		'4_key_1' => [F],
		'4_key_2' => [SPACE],
		'4_key_3' => [J],
		'4_key_4' => [K],

		'5_key_0' => [S],
		'5_key_1' => [D],
		'5_key_2' => [F],
		'5_key_3' => [J],
		'5_key_4' => [K],
		'5_key_5' => [L],

		'6_key_0' => [S],
		'6_key_1' => [D],
		'6_key_2' => [F],
		'6_key_3' => [SPACE],
		'6_key_4' => [J],
		'6_key_5' => [K],
		'6_key_6' => [L],

		'7_key_0' => [A],
		'7_key_1' => [S],
		'7_key_2' => [D],
		'7_key_3' => [F],
		'7_key_4' => [J],
		'7_key_5' => [K],
		'7_key_6' => [L],
		'7_key_7' => [SEMICOLON],

		'8_key_0' => [A],
		'8_key_1' => [S],
		'8_key_2' => [D],
		'8_key_3' => [F],
		'8_key_4' => [SPACE],
		'8_key_5' => [J],
		'8_key_6' => [K],
		'8_key_7' => [L],
		'8_key_8' => [SEMICOLON],

		'9_key_0' => [A],
		'9_key_1' => [S],
		'9_key_2' => [D],
		'9_key_3' => [F],
		'9_key_4' => [V],
		'9_key_5' => [N],
		'9_key_6' => [J],
		'9_key_7' => [K],
		'9_key_8' => [L],
		'9_key_9' => [SEMICOLON],
		'10_key_0' => [A],
		'10_key_1' => [S],
		'10_key_2' => [D],
		'10_key_3' => [F],
		'10_key_4' => [G],
		'10_key_5' => [H],
		'10_key_6' => [J],
		'10_key_7' => [K],
		'10_key_8' => [L],
		'10_key_9' => [Z],
		'10_key_10' => [X],
		'11_key_0' => [A],
		'11_key_1' => [S],
		'11_key_2' => [D],
		'11_key_3' => [F],
		'11_key_4' => [G],
		'11_key_5' => [H],
		'11_key_6' => [J],
		'11_key_7' => [K],
		'11_key_8' => [L],
		'11_key_9' => [Z],
		'11_key_10' => [X],
		'11_key_11' => [C],
		'12_key_0' => [A],
		'12_key_1' => [S],
		'12_key_2' => [D],
		'12_key_3' => [F],
		'12_key_4' => [G],
		'12_key_5' => [H],
		'12_key_6' => [J],
		'12_key_7' => [K],
		'12_key_8' => [L],
		'12_key_9' => [Z],
		'12_key_10' => [X],
		'12_key_11' => [C],
		'12_key_12' => [V],
		'13_key_0' => [A],
		'13_key_1' => [S],
		'13_key_2' => [D],
		'13_key_3' => [F],
		'13_key_4' => [G],
		'13_key_5' => [H],
		'13_key_6' => [J],
		'13_key_7' => [K],
		'13_key_8' => [L],
		'13_key_9' => [Z],
		'13_key_10' => [X],
		'13_key_11' => [C],
		'13_key_12' => [V],
		'13_key_13' => [B],
		'14_key_0' => [A],
		'14_key_1' => [S],
		'14_key_2' => [D],
		'14_key_3' => [F],
		'14_key_4' => [G],
		'14_key_5' => [H],
		'14_key_6' => [J],
		'14_key_7' => [K],
		'14_key_8' => [L],
		'14_key_9' => [Z],
		'14_key_10' => [X],
		'14_key_11' => [C],
		'14_key_12' => [V],
		'14_key_13' => [B],
		'14_key_14' => [N],
		'15_key_0' => [A],
		'15_key_1' => [S],
		'15_key_2' => [D],
		'15_key_3' => [F],
		'15_key_4' => [G],
		'15_key_5' => [H],
		'15_key_6' => [J],
		'15_key_7' => [K],
		'15_key_8' => [L],
		'15_key_9' => [Z],
		'15_key_10' => [X],
		'15_key_11' => [C],
		'15_key_12' => [V],
		'15_key_13' => [B],
		'15_key_14' => [N],
		'15_key_15' => [M],
		'16_key_0' => [A],
		'16_key_1' => [S],
		'16_key_2' => [D],
		'16_key_3' => [F],
		'16_key_4' => [G],
		'16_key_5' => [H],
		'16_key_6' => [J],
		'16_key_7' => [K],
		'16_key_8' => [L],
		'16_key_9' => [Z],
		'16_key_10' => [X],
		'16_key_11' => [C],
		'16_key_12' => [V],
		'16_key_13' => [B],
		'16_key_14' => [N],
		'16_key_15' => [M],
		'16_key_16' => [Q],
		'17_key_0' => [A],
		'17_key_1' => [S],
		'17_key_2' => [D],
		'17_key_3' => [F],
		'17_key_4' => [G],
		'17_key_5' => [H],
		'17_key_6' => [J],
		'17_key_7' => [K],
		'17_key_8' => [L],
		'17_key_9' => [Z],
		'17_key_10' => [X],
		'17_key_11' => [C],
		'17_key_12' => [V],
		'17_key_13' => [B],
		'17_key_14' => [N],
		'17_key_15' => [M],
		'17_key_16' => [Q],
		'17_key_17' => [W],
		'18_key_0' => [A],
		'18_key_1' => [S],
		'18_key_2' => [D],
		'18_key_3' => [F],
		'18_key_4' => [G],
		'18_key_5' => [H],
		'18_key_6' => [J],
		'18_key_7' => [K],
		'18_key_8' => [L],
		'18_key_9' => [Z],
		'18_key_10' => [X],
		'18_key_11' => [C],
		'18_key_12' => [V],
		'18_key_13' => [B],
		'18_key_14' => [N],
		'18_key_15' => [M],
		'18_key_16' => [Q],
		'18_key_17' => [W],
		'18_key_18' => [E],
		'19_key_0' => [A],
		'19_key_1' => [S],
		'19_key_2' => [D],
		'19_key_3' => [F],
		'19_key_4' => [G],
		'19_key_5' => [H],
		'19_key_6' => [J],
		'19_key_7' => [K],
		'19_key_8' => [L],
		'19_key_9' => [Z],
		'19_key_10' => [X],
		'19_key_11' => [C],
		'19_key_12' => [V],
		'19_key_13' => [B],
		'19_key_14' => [N],
		'19_key_15' => [M],
		'19_key_16' => [Q],
		'19_key_17' => [W],
		'19_key_18' => [E],
		'19_key_19' => [R],
		'20_key_0' => [A],
		'20_key_1' => [S],
		'20_key_2' => [D],
		'20_key_3' => [F],
		'20_key_4' => [G],
		'20_key_5' => [H],
		'20_key_6' => [J],
		'20_key_7' => [K],
		'20_key_8' => [L],
		'20_key_9' => [Z],
		'20_key_10' => [X],
		'20_key_11' => [C],
		'20_key_12' => [V],
		'20_key_13' => [B],
		'20_key_14' => [N],
		'20_key_15' => [M],
		'20_key_16' => [Q],
		'20_key_17' => [W],
		'20_key_18' => [E],
		'20_key_19' => [R],
		'20_key_20' => [T],
		'21_key_0' => [A],
		'21_key_1' => [S],
		'21_key_2' => [D],
		'21_key_3' => [F],
		'21_key_4' => [G],
		'21_key_5' => [H],
		'21_key_6' => [J],
		'21_key_7' => [K],
		'21_key_8' => [L],
		'21_key_9' => [Z],
		'21_key_10' => [X],
		'21_key_11' => [C],
		'21_key_12' => [V],
		'21_key_13' => [B],
		'21_key_14' => [N],
		'21_key_15' => [M],
		'21_key_16' => [Q],
		'21_key_17' => [W],
		'21_key_18' => [E],
		'21_key_19' => [R],
		'21_key_20' => [T],
		'21_key_21' => [Y],
		'22_key_0' => [A],
		'22_key_1' => [S],
		'22_key_2' => [D],
		'22_key_3' => [F],
		'22_key_4' => [G],
		'22_key_5' => [H],
		'22_key_6' => [J],
		'22_key_7' => [K],
		'22_key_8' => [L],
		'22_key_9' => [Z],
		'22_key_10' => [X],
		'22_key_11' => [C],
		'22_key_12' => [V],
		'22_key_13' => [B],
		'22_key_14' => [N],
		'22_key_15' => [M],
		'22_key_16' => [Q],
		'22_key_17' => [W],
		'22_key_18' => [E],
		'22_key_19' => [R],
		'22_key_20' => [T],
		'22_key_21' => [Y],
		'22_key_22' => [U],
		'23_key_0' => [A],
		'23_key_1' => [S],
		'23_key_2' => [D],
		'23_key_3' => [F],
		'23_key_4' => [G],
		'23_key_5' => [H],
		'23_key_6' => [J],
		'23_key_7' => [K],
		'23_key_8' => [L],
		'23_key_9' => [Z],
		'23_key_10' => [X],
		'23_key_11' => [C],
		'23_key_12' => [V],
		'23_key_13' => [B],
		'23_key_14' => [N],
		'23_key_15' => [M],
		'23_key_16' => [Q],
		'23_key_17' => [W],
		'23_key_18' => [E],
		'23_key_19' => [R],
		'23_key_20' => [T],
		'23_key_21' => [Y],
		'23_key_22' => [U],
		'23_key_23' => [I],
		'24_key_0' => [A],
		'24_key_1' => [S],
		'24_key_2' => [D],
		'24_key_3' => [F],
		'24_key_4' => [G],
		'24_key_5' => [H],
		'24_key_6' => [J],
		'24_key_7' => [K],
		'24_key_8' => [L],
		'24_key_9' => [Z],
		'24_key_10' => [X],
		'24_key_11' => [C],
		'24_key_12' => [V],
		'24_key_13' => [B],
		'24_key_14' => [N],
		'24_key_15' => [M],
		'24_key_16' => [Q],
		'24_key_17' => [W],
		'24_key_18' => [E],
		'24_key_19' => [R],
		'24_key_20' => [T],
		'24_key_21' => [Y],
		'24_key_22' => [U],
		'24_key_23' => [I],
		'24_key_24' => [O],
		'25_key_0' => [A],
		'25_key_1' => [S],
		'25_key_2' => [D],
		'25_key_3' => [F],
		'25_key_4' => [G],
		'25_key_5' => [H],
		'25_key_6' => [J],
		'25_key_7' => [K],
		'25_key_8' => [L],
		'25_key_9' => [Z],
		'25_key_10' => [X],
		'25_key_11' => [C],
		'25_key_12' => [V],
		'25_key_13' => [B],
		'25_key_14' => [N],
		'25_key_15' => [M],
		'25_key_16' => [Q],
		'25_key_17' => [W],
		'25_key_18' => [E],
		'25_key_19' => [R],
		'25_key_20' => [T],
		'25_key_21' => [Y],
		'25_key_22' => [U],
		'25_key_23' => [I],
		'25_key_24' => [O],
		'25_key_25' => [P],
		'26_key_0' => [A],
		'26_key_1' => [S],
		'26_key_2' => [D],
		'26_key_3' => [F],
		'26_key_4' => [G],
		'26_key_5' => [H],
		'26_key_6' => [J],
		'26_key_7' => [K],
		'26_key_8' => [L],
		'26_key_9' => [Z],
		'26_key_10' => [X],
		'26_key_11' => [C],
		'26_key_12' => [V],
		'26_key_13' => [B],
		'26_key_14' => [N],
		'26_key_15' => [M],
		'26_key_16' => [Q],
		'26_key_17' => [W],
		'26_key_18' => [E],
		'26_key_19' => [R],
		'26_key_20' => [T],
		'26_key_21' => [Y],
		'26_key_22' => [U],
		'26_key_23' => [I],
		'26_key_24' => [O],
		'26_key_25' => [P],
		'26_key_26' => [ONE],
		'27_key_0' => [A],
		'27_key_1' => [S],
		'27_key_2' => [D],
		'27_key_3' => [F],
		'27_key_4' => [G],
		'27_key_5' => [H],
		'27_key_6' => [J],
		'27_key_7' => [K],
		'27_key_8' => [L],
		'27_key_9' => [Z],
		'27_key_10' => [X],
		'27_key_11' => [C],
		'27_key_12' => [V],
		'27_key_13' => [B],
		'27_key_14' => [N],
		'27_key_15' => [M],
		'27_key_16' => [Q],
		'27_key_17' => [W],
		'27_key_18' => [E],
		'27_key_19' => [R],
		'27_key_20' => [T],
		'27_key_21' => [Y],
		'27_key_22' => [U],
		'27_key_23' => [I],
		'27_key_24' => [O],
		'27_key_25' => [P],
		'27_key_26' => [ONE],
		'27_key_27' => [TWO],
		'28_key_0' => [A],
		'28_key_1' => [S],
		'28_key_2' => [D],
		'28_key_3' => [F],
		'28_key_4' => [G],
		'28_key_5' => [H],
		'28_key_6' => [J],
		'28_key_7' => [K],
		'28_key_8' => [L],
		'28_key_9' => [Z],
		'28_key_10' => [X],
		'28_key_11' => [C],
		'28_key_12' => [V],
		'28_key_13' => [B],
		'28_key_14' => [N],
		'28_key_15' => [M],
		'28_key_16' => [Q],
		'28_key_17' => [W],
		'28_key_18' => [E],
		'28_key_19' => [R],
		'28_key_20' => [T],
		'28_key_21' => [Y],
		'28_key_22' => [U],
		'28_key_23' => [I],
		'28_key_24' => [O],
		'28_key_25' => [P],
		'28_key_26' => [ONE],
		'28_key_27' => [TWO],
		'28_key_28' => [THREE],
		'29_key_0' => [A],
		'29_key_1' => [S],
		'29_key_2' => [D],
		'29_key_3' => [F],
		'29_key_4' => [G],
		'29_key_5' => [H],
		'29_key_6' => [J],
		'29_key_7' => [K],
		'29_key_8' => [L],
		'29_key_9' => [Z],
		'29_key_10' => [X],
		'29_key_11' => [C],
		'29_key_12' => [V],
		'29_key_13' => [B],
		'29_key_14' => [N],
		'29_key_15' => [M],
		'29_key_16' => [Q],
		'29_key_17' => [W],
		'29_key_18' => [E],
		'29_key_19' => [R],
		'29_key_20' => [T],
		'29_key_21' => [Y],
		'29_key_22' => [U],
		'29_key_23' => [I],
		'29_key_24' => [O],
		'29_key_25' => [P],
		'29_key_26' => [ONE],
		'29_key_27' => [TWO],
		'29_key_28' => [THREE],
		'29_key_29' => [FOUR],
		'30_key_0' => [A],
		'30_key_1' => [S],
		'30_key_2' => [D],
		'30_key_3' => [F],
		'30_key_4' => [G],
		'30_key_5' => [H],
		'30_key_6' => [J],
		'30_key_7' => [K],
		'30_key_8' => [L],
		'30_key_9' => [Z],
		'30_key_10' => [X],
		'30_key_11' => [C],
		'30_key_12' => [V],
		'30_key_13' => [B],
		'30_key_14' => [N],
		'30_key_15' => [M],
		'30_key_16' => [Q],
		'30_key_17' => [W],
		'30_key_18' => [E],
		'30_key_19' => [R],
		'30_key_20' => [T],
		'30_key_21' => [Y],
		'30_key_22' => [U],
		'30_key_23' => [I],
		'30_key_24' => [O],
		'30_key_25' => [P],
		'30_key_26' => [ONE],
		'30_key_27' => [TWO],
		'30_key_28' => [THREE],
		'30_key_29' => [FOUR],
		'30_key_30' => [FIVE],
		'31_key_0' => [A],
		'31_key_1' => [S],
		'31_key_2' => [D],
		'31_key_3' => [F],
		'31_key_4' => [G],
		'31_key_5' => [H],
		'31_key_6' => [J],
		'31_key_7' => [K],
		'31_key_8' => [L],
		'31_key_9' => [Z],
		'31_key_10' => [X],
		'31_key_11' => [C],
		'31_key_12' => [V],
		'31_key_13' => [B],
		'31_key_14' => [N],
		'31_key_15' => [M],
		'31_key_16' => [Q],
		'31_key_17' => [W],
		'31_key_18' => [E],
		'31_key_19' => [R],
		'31_key_20' => [T],
		'31_key_21' => [Y],
		'31_key_22' => [U],
		'31_key_23' => [I],
		'31_key_24' => [O],
		'31_key_25' => [P],
		'31_key_26' => [ONE],
		'31_key_27' => [TWO],
		'31_key_28' => [THREE],
		'31_key_29' => [FOUR],
		'31_key_30' => [FIVE],
		'31_key_31' => [SIX],
		'32_key_0' => [A],
		'32_key_1' => [S],
		'32_key_2' => [D],
		'32_key_3' => [F],
		'32_key_4' => [G],
		'32_key_5' => [H],
		'32_key_6' => [J],
		'32_key_7' => [K],
		'32_key_8' => [L],
		'32_key_9' => [Z],
		'32_key_10' => [X],
		'32_key_11' => [C],
		'32_key_12' => [V],
		'32_key_13' => [B],
		'32_key_14' => [N],
		'32_key_15' => [M],
		'32_key_16' => [Q],
		'32_key_17' => [W],
		'32_key_18' => [E],
		'32_key_19' => [R],
		'32_key_20' => [T],
		'32_key_21' => [Y],
		'32_key_22' => [U],
		'32_key_23' => [I],
		'32_key_24' => [O],
		'32_key_25' => [P],
		'32_key_26' => [ONE],
		'32_key_27' => [TWO],
		'32_key_28' => [THREE],
		'32_key_29' => [FOUR],
		'32_key_30' => [FIVE],
		'32_key_31' => [SIX],
		'32_key_32' => [SEVEN],
		'33_key_0' => [A],
		'33_key_1' => [S],
		'33_key_2' => [D],
		'33_key_3' => [F],
		'33_key_4' => [G],
		'33_key_5' => [H],
		'33_key_6' => [J],
		'33_key_7' => [K],
		'33_key_8' => [L],
		'33_key_9' => [Z],
		'33_key_10' => [X],
		'33_key_11' => [C],
		'33_key_12' => [V],
		'33_key_13' => [B],
		'33_key_14' => [N],
		'33_key_15' => [M],
		'33_key_16' => [Q],
		'33_key_17' => [W],
		'33_key_18' => [E],
		'33_key_19' => [R],
		'33_key_20' => [T],
		'33_key_21' => [Y],
		'33_key_22' => [U],
		'33_key_23' => [I],
		'33_key_24' => [O],
		'33_key_25' => [P],
		'33_key_26' => [ONE],
		'33_key_27' => [TWO],
		'33_key_28' => [THREE],
		'33_key_29' => [FOUR],
		'33_key_30' => [FIVE],
		'33_key_31' => [SIX],
		'33_key_32' => [SEVEN],
		'33_key_33' => [EIGHT],
		'34_key_0' => [A],
		'34_key_1' => [S],
		'34_key_2' => [D],
		'34_key_3' => [F],
		'34_key_4' => [G],
		'34_key_5' => [H],
		'34_key_6' => [J],
		'34_key_7' => [K],
		'34_key_8' => [L],
		'34_key_9' => [Z],
		'34_key_10' => [X],
		'34_key_11' => [C],
		'34_key_12' => [V],
		'34_key_13' => [B],
		'34_key_14' => [N],
		'34_key_15' => [M],
		'34_key_16' => [Q],
		'34_key_17' => [W],
		'34_key_18' => [E],
		'34_key_19' => [R],
		'34_key_20' => [T],
		'34_key_21' => [Y],
		'34_key_22' => [U],
		'34_key_23' => [I],
		'34_key_24' => [O],
		'34_key_25' => [P],
		'34_key_26' => [ONE],
		'34_key_27' => [TWO],
		'34_key_28' => [THREE],
		'34_key_29' => [FOUR],
		'34_key_30' => [FIVE],
		'34_key_31' => [SIX],
		'34_key_32' => [SEVEN],
		'34_key_33' => [EIGHT],
		'34_key_34' => [NINE],
		'35_key_0' => [A],
		'35_key_1' => [S],
		'35_key_2' => [D],
		'35_key_3' => [F],
		'35_key_4' => [G],
		'35_key_5' => [H],
		'35_key_6' => [J],
		'35_key_7' => [K],
		'35_key_8' => [L],
		'35_key_9' => [Z],
		'35_key_10' => [X],
		'35_key_11' => [C],
		'35_key_12' => [V],
		'35_key_13' => [B],
		'35_key_14' => [N],
		'35_key_15' => [M],
		'35_key_16' => [Q],
		'35_key_17' => [W],
		'35_key_18' => [E],
		'35_key_19' => [R],
		'35_key_20' => [T],
		'35_key_21' => [Y],
		'35_key_22' => [U],
		'35_key_23' => [I],
		'35_key_24' => [O],
		'35_key_25' => [P],
		'35_key_26' => [ONE],
		'35_key_27' => [TWO],
		'35_key_28' => [THREE],
		'35_key_29' => [FOUR],
		'35_key_30' => [FIVE],
		'35_key_31' => [SIX],
		'35_key_32' => [SEVEN],
		'35_key_33' => [EIGHT],
		'35_key_34' => [NINE],
		'35_key_35' => [ZERO],
		'36_key_0' => [A],
		'36_key_1' => [S],
		'36_key_2' => [D],
		'36_key_3' => [F],
		'36_key_4' => [G],
		'36_key_5' => [H],
		'36_key_6' => [J],
		'36_key_7' => [K],
		'36_key_8' => [L],
		'36_key_9' => [Z],
		'36_key_10' => [X],
		'36_key_11' => [C],
		'36_key_12' => [V],
		'36_key_13' => [B],
		'36_key_14' => [N],
		'36_key_15' => [M],
		'36_key_16' => [Q],
		'36_key_17' => [W],
		'36_key_18' => [E],
		'36_key_19' => [R],
		'36_key_20' => [T],
		'36_key_21' => [Y],
		'36_key_22' => [U],
		'36_key_23' => [I],
		'36_key_24' => [O],
		'36_key_25' => [P],
		'36_key_26' => [ONE],
		'36_key_27' => [TWO],
		'36_key_28' => [THREE],
		'36_key_29' => [FOUR],
		'36_key_30' => [FIVE],
		'36_key_31' => [SIX],
		'36_key_32' => [SEVEN],
		'36_key_33' => [EIGHT],
		'36_key_34' => [NINE],
		'36_key_35' => [ZERO],
		'36_key_36' => [SPACE],
		'37_key_0' => [A],
		'37_key_1' => [S],
		'37_key_2' => [D],
		'37_key_3' => [F],
		'37_key_4' => [G],
		'37_key_5' => [H],
		'37_key_6' => [J],
		'37_key_7' => [K],
		'37_key_8' => [L],
		'37_key_9' => [Z],
		'37_key_10' => [X],
		'37_key_11' => [C],
		'37_key_12' => [V],
		'37_key_13' => [B],
		'37_key_14' => [N],
		'37_key_15' => [M],
		'37_key_16' => [Q],
		'37_key_17' => [W],
		'37_key_18' => [E],
		'37_key_19' => [R],
		'37_key_20' => [T],
		'37_key_21' => [Y],
		'37_key_22' => [U],
		'37_key_23' => [I],
		'37_key_24' => [O],
		'37_key_25' => [P],
		'37_key_26' => [ONE],
		'37_key_27' => [TWO],
		'37_key_28' => [THREE],
		'37_key_29' => [FOUR],
		'37_key_30' => [FIVE],
		'37_key_31' => [SIX],
		'37_key_32' => [SEVEN],
		'37_key_33' => [EIGHT],
		'37_key_34' => [NINE],
		'37_key_35' => [ZERO],
		'37_key_36' => [SPACE],
		'37_key_37' => [SEMICOLON],
		'38_key_0' => [A],
		'38_key_1' => [S],
		'38_key_2' => [D],
		'38_key_3' => [F],
		'38_key_4' => [G],
		'38_key_5' => [H],
		'38_key_6' => [J],
		'38_key_7' => [K],
		'38_key_8' => [L],
		'38_key_9' => [Z],
		'38_key_10' => [X],
		'38_key_11' => [C],
		'38_key_12' => [V],
		'38_key_13' => [B],
		'38_key_14' => [N],
		'38_key_15' => [M],
		'38_key_16' => [Q],
		'38_key_17' => [W],
		'38_key_18' => [E],
		'38_key_19' => [R],
		'38_key_20' => [T],
		'38_key_21' => [Y],
		'38_key_22' => [U],
		'38_key_23' => [I],
		'38_key_24' => [O],
		'38_key_25' => [P],
		'38_key_26' => [ONE],
		'38_key_27' => [TWO],
		'38_key_28' => [THREE],
		'38_key_29' => [FOUR],
		'38_key_30' => [FIVE],
		'38_key_31' => [SIX],
		'38_key_32' => [SEVEN],
		'38_key_33' => [EIGHT],
		'38_key_34' => [NINE],
		'38_key_35' => [ZERO],
		'38_key_36' => [SPACE],
		'38_key_37' => [SEMICOLON],
		'38_key_38' => [COMMA],
		'39_key_0' => [A],
		'39_key_1' => [S],
		'39_key_2' => [D],
		'39_key_3' => [F],
		'39_key_4' => [G],
		'39_key_5' => [H],
		'39_key_6' => [J],
		'39_key_7' => [K],
		'39_key_8' => [L],
		'39_key_9' => [Z],
		'39_key_10' => [X],
		'39_key_11' => [C],
		'39_key_12' => [V],
		'39_key_13' => [B],
		'39_key_14' => [N],
		'39_key_15' => [M],
		'39_key_16' => [Q],
		'39_key_17' => [W],
		'39_key_18' => [E],
		'39_key_19' => [R],
		'39_key_20' => [T],
		'39_key_21' => [Y],
		'39_key_22' => [U],
		'39_key_23' => [I],
		'39_key_24' => [O],
		'39_key_25' => [P],
		'39_key_26' => [ONE],
		'39_key_27' => [TWO],
		'39_key_28' => [THREE],
		'39_key_29' => [FOUR],
		'39_key_30' => [FIVE],
		'39_key_31' => [SIX],
		'39_key_32' => [SEVEN],
		'39_key_33' => [EIGHT],
		'39_key_34' => [NINE],
		'39_key_35' => [ZERO],
		'39_key_36' => [SPACE],
		'39_key_37' => [SEMICOLON],
		'39_key_38' => [COMMA],
		'39_key_39' => [PERIOD],
		'40_key_0' => [A],
		'40_key_1' => [S],
		'40_key_2' => [D],
		'40_key_3' => [F],
		'40_key_4' => [G],
		'40_key_5' => [H],
		'40_key_6' => [J],
		'40_key_7' => [K],
		'40_key_8' => [L],
		'40_key_9' => [Z],
		'40_key_10' => [X],
		'40_key_11' => [C],
		'40_key_12' => [V],
		'40_key_13' => [B],
		'40_key_14' => [N],
		'40_key_15' => [M],
		'40_key_16' => [Q],
		'40_key_17' => [W],
		'40_key_18' => [E],
		'40_key_19' => [R],
		'40_key_20' => [T],
		'40_key_21' => [Y],
		'40_key_22' => [U],
		'40_key_23' => [I],
		'40_key_24' => [O],
		'40_key_25' => [P],
		'40_key_26' => [ONE],
		'40_key_27' => [TWO],
		'40_key_28' => [THREE],
		'40_key_29' => [FOUR],
		'40_key_30' => [FIVE],
		'40_key_31' => [SIX],
		'40_key_32' => [SEVEN],
		'40_key_33' => [EIGHT],
		'40_key_34' => [NINE],
		'40_key_35' => [ZERO],
		'40_key_36' => [SPACE],
		'40_key_37' => [SEMICOLON],
		'40_key_38' => [COMMA],
		'40_key_39' => [PERIOD],
		'40_key_40' => [SLASH],
		'41_key_0' => [A],
		'41_key_1' => [S],
		'41_key_2' => [D],
		'41_key_3' => [F],
		'41_key_4' => [G],
		'41_key_5' => [H],
		'41_key_6' => [J],
		'41_key_7' => [K],
		'41_key_8' => [L],
		'41_key_9' => [Z],
		'41_key_10' => [X],
		'41_key_11' => [C],
		'41_key_12' => [V],
		'41_key_13' => [B],
		'41_key_14' => [N],
		'41_key_15' => [M],
		'41_key_16' => [Q],
		'41_key_17' => [W],
		'41_key_18' => [E],
		'41_key_19' => [R],
		'41_key_20' => [T],
		'41_key_21' => [Y],
		'41_key_22' => [U],
		'41_key_23' => [I],
		'41_key_24' => [O],
		'41_key_25' => [P],
		'41_key_26' => [ONE],
		'41_key_27' => [TWO],
		'41_key_28' => [THREE],
		'41_key_29' => [FOUR],
		'41_key_30' => [FIVE],
		'41_key_31' => [SIX],
		'41_key_32' => [SEVEN],
		'41_key_33' => [EIGHT],
		'41_key_34' => [NINE],
		'41_key_35' => [ZERO],
		'41_key_36' => [SPACE],
		'41_key_37' => [SEMICOLON],
		'41_key_38' => [COMMA],
		'41_key_39' => [PERIOD],
		'41_key_40' => [SLASH],
		'41_key_41' => [QUOTE],
		'42_key_0' => [A],
		'42_key_1' => [S],
		'42_key_2' => [D],
		'42_key_3' => [F],
		'42_key_4' => [G],
		'42_key_5' => [H],
		'42_key_6' => [J],
		'42_key_7' => [K],
		'42_key_8' => [L],
		'42_key_9' => [Z],
		'42_key_10' => [X],
		'42_key_11' => [C],
		'42_key_12' => [V],
		'42_key_13' => [B],
		'42_key_14' => [N],
		'42_key_15' => [M],
		'42_key_16' => [Q],
		'42_key_17' => [W],
		'42_key_18' => [E],
		'42_key_19' => [R],
		'42_key_20' => [T],
		'42_key_21' => [Y],
		'42_key_22' => [U],
		'42_key_23' => [I],
		'42_key_24' => [O],
		'42_key_25' => [P],
		'42_key_26' => [ONE],
		'42_key_27' => [TWO],
		'42_key_28' => [THREE],
		'42_key_29' => [FOUR],
		'42_key_30' => [FIVE],
		'42_key_31' => [SIX],
		'42_key_32' => [SEVEN],
		'42_key_33' => [EIGHT],
		'42_key_34' => [NINE],
		'42_key_35' => [ZERO],
		'42_key_36' => [SPACE],
		'42_key_37' => [SEMICOLON],
		'42_key_38' => [COMMA],
		'42_key_39' => [PERIOD],
		'42_key_40' => [SLASH],
		'42_key_41' => [QUOTE],
		'42_key_42' => [MINUS],
		'43_key_0' => [A],
		'43_key_1' => [S],
		'43_key_2' => [D],
		'43_key_3' => [F],
		'43_key_4' => [G],
		'43_key_5' => [H],
		'43_key_6' => [J],
		'43_key_7' => [K],
		'43_key_8' => [L],
		'43_key_9' => [Z],
		'43_key_10' => [X],
		'43_key_11' => [C],
		'43_key_12' => [V],
		'43_key_13' => [B],
		'43_key_14' => [N],
		'43_key_15' => [M],
		'43_key_16' => [Q],
		'43_key_17' => [W],
		'43_key_18' => [E],
		'43_key_19' => [R],
		'43_key_20' => [T],
		'43_key_21' => [Y],
		'43_key_22' => [U],
		'43_key_23' => [I],
		'43_key_24' => [O],
		'43_key_25' => [P],
		'43_key_26' => [ONE],
		'43_key_27' => [TWO],
		'43_key_28' => [THREE],
		'43_key_29' => [FOUR],
		'43_key_30' => [FIVE],
		'43_key_31' => [SIX],
		'43_key_32' => [SEVEN],
		'43_key_33' => [EIGHT],
		'43_key_34' => [NINE],
		'43_key_35' => [ZERO],
		'43_key_36' => [SPACE],
		'43_key_37' => [SEMICOLON],
		'43_key_38' => [COMMA],
		'43_key_39' => [PERIOD],
		'43_key_40' => [SLASH],
		'43_key_41' => [QUOTE],
		'43_key_42' => [MINUS],
		'43_key_43' => [PLUS],
		'44_key_0' => [A],
		'44_key_1' => [S],
		'44_key_2' => [D],
		'44_key_3' => [F],
		'44_key_4' => [G],
		'44_key_5' => [H],
		'44_key_6' => [J],
		'44_key_7' => [K],
		'44_key_8' => [L],
		'44_key_9' => [Z],
		'44_key_10' => [X],
		'44_key_11' => [C],
		'44_key_12' => [V],
		'44_key_13' => [B],
		'44_key_14' => [N],
		'44_key_15' => [M],
		'44_key_16' => [Q],
		'44_key_17' => [W],
		'44_key_18' => [E],
		'44_key_19' => [R],
		'44_key_20' => [T],
		'44_key_21' => [Y],
		'44_key_22' => [U],
		'44_key_23' => [I],
		'44_key_24' => [O],
		'44_key_25' => [P],
		'44_key_26' => [ONE],
		'44_key_27' => [TWO],
		'44_key_28' => [THREE],
		'44_key_29' => [FOUR],
		'44_key_30' => [FIVE],
		'44_key_31' => [SIX],
		'44_key_32' => [SEVEN],
		'44_key_33' => [EIGHT],
		'44_key_34' => [NINE],
		'44_key_35' => [ZERO],
		'44_key_36' => [SPACE],
		'44_key_37' => [SEMICOLON],
		'44_key_38' => [COMMA],
		'44_key_39' => [PERIOD],
		'44_key_40' => [SLASH],
		'44_key_41' => [QUOTE],
		'44_key_42' => [MINUS],
		'44_key_43' => [PLUS],
		'44_key_44' => [F1],
		'45_key_0' => [A],
		'45_key_1' => [S],
		'45_key_2' => [D],
		'45_key_3' => [F],
		'45_key_4' => [G],
		'45_key_5' => [H],
		'45_key_6' => [J],
		'45_key_7' => [K],
		'45_key_8' => [L],
		'45_key_9' => [Z],
		'45_key_10' => [X],
		'45_key_11' => [C],
		'45_key_12' => [V],
		'45_key_13' => [B],
		'45_key_14' => [N],
		'45_key_15' => [M],
		'45_key_16' => [Q],
		'45_key_17' => [W],
		'45_key_18' => [E],
		'45_key_19' => [R],
		'45_key_20' => [T],
		'45_key_21' => [Y],
		'45_key_22' => [U],
		'45_key_23' => [I],
		'45_key_24' => [O],
		'45_key_25' => [P],
		'45_key_26' => [ONE],
		'45_key_27' => [TWO],
		'45_key_28' => [THREE],
		'45_key_29' => [FOUR],
		'45_key_30' => [FIVE],
		'45_key_31' => [SIX],
		'45_key_32' => [SEVEN],
		'45_key_33' => [EIGHT],
		'45_key_34' => [NINE],
		'45_key_35' => [ZERO],
		'45_key_36' => [SPACE],
		'45_key_37' => [SEMICOLON],
		'45_key_38' => [COMMA],
		'45_key_39' => [PERIOD],
		'45_key_40' => [SLASH],
		'45_key_41' => [QUOTE],
		'45_key_42' => [MINUS],
		'45_key_43' => [PLUS],
		'45_key_44' => [F1],
		'45_key_45' => [F2],
		'46_key_0' => [A],
		'46_key_1' => [S],
		'46_key_2' => [D],
		'46_key_3' => [F],
		'46_key_4' => [G],
		'46_key_5' => [H],
		'46_key_6' => [J],
		'46_key_7' => [K],
		'46_key_8' => [L],
		'46_key_9' => [Z],
		'46_key_10' => [X],
		'46_key_11' => [C],
		'46_key_12' => [V],
		'46_key_13' => [B],
		'46_key_14' => [N],
		'46_key_15' => [M],
		'46_key_16' => [Q],
		'46_key_17' => [W],
		'46_key_18' => [E],
		'46_key_19' => [R],
		'46_key_20' => [T],
		'46_key_21' => [Y],
		'46_key_22' => [U],
		'46_key_23' => [I],
		'46_key_24' => [O],
		'46_key_25' => [P],
		'46_key_26' => [ONE],
		'46_key_27' => [TWO],
		'46_key_28' => [THREE],
		'46_key_29' => [FOUR],
		'46_key_30' => [FIVE],
		'46_key_31' => [SIX],
		'46_key_32' => [SEVEN],
		'46_key_33' => [EIGHT],
		'46_key_34' => [NINE],
		'46_key_35' => [ZERO],
		'46_key_36' => [SPACE],
		'46_key_37' => [SEMICOLON],
		'46_key_38' => [COMMA],
		'46_key_39' => [PERIOD],
		'46_key_40' => [SLASH],
		'46_key_41' => [QUOTE],
		'46_key_42' => [MINUS],
		'46_key_43' => [PLUS],
		'46_key_44' => [F1],
		'46_key_45' => [F2],
		'46_key_46' => [F3],
		'47_key_0' => [A],
		'47_key_1' => [S],
		'47_key_2' => [D],
		'47_key_3' => [F],
		'47_key_4' => [G],
		'47_key_5' => [H],
		'47_key_6' => [J],
		'47_key_7' => [K],
		'47_key_8' => [L],
		'47_key_9' => [Z],
		'47_key_10' => [X],
		'47_key_11' => [C],
		'47_key_12' => [V],
		'47_key_13' => [B],
		'47_key_14' => [N],
		'47_key_15' => [M],
		'47_key_16' => [Q],
		'47_key_17' => [W],
		'47_key_18' => [E],
		'47_key_19' => [R],
		'47_key_20' => [T],
		'47_key_21' => [Y],
		'47_key_22' => [U],
		'47_key_23' => [I],
		'47_key_24' => [O],
		'47_key_25' => [P],
		'47_key_26' => [ONE],
		'47_key_27' => [TWO],
		'47_key_28' => [THREE],
		'47_key_29' => [FOUR],
		'47_key_30' => [FIVE],
		'47_key_31' => [SIX],
		'47_key_32' => [SEVEN],
		'47_key_33' => [EIGHT],
		'47_key_34' => [NINE],
		'47_key_35' => [ZERO],
		'47_key_36' => [SPACE],
		'47_key_37' => [SEMICOLON],
		'47_key_38' => [COMMA],
		'47_key_39' => [PERIOD],
		'47_key_40' => [SLASH],
		'47_key_41' => [QUOTE],
		'47_key_42' => [MINUS],
		'47_key_43' => [PLUS],
		'47_key_44' => [F1],
		'47_key_45' => [F2],
		'47_key_46' => [F3],
		'47_key_47' => [F4],
		'48_key_0' => [A],
		'48_key_1' => [S],
		'48_key_2' => [D],
		'48_key_3' => [F],
		'48_key_4' => [G],
		'48_key_5' => [H],
		'48_key_6' => [J],
		'48_key_7' => [K],
		'48_key_8' => [L],
		'48_key_9' => [Z],
		'48_key_10' => [X],
		'48_key_11' => [C],
		'48_key_12' => [V],
		'48_key_13' => [B],
		'48_key_14' => [N],
		'48_key_15' => [M],
		'48_key_16' => [Q],
		'48_key_17' => [W],
		'48_key_18' => [E],
		'48_key_19' => [R],
		'48_key_20' => [T],
		'48_key_21' => [Y],
		'48_key_22' => [U],
		'48_key_23' => [I],
		'48_key_24' => [O],
		'48_key_25' => [P],
		'48_key_26' => [ONE],
		'48_key_27' => [TWO],
		'48_key_28' => [THREE],
		'48_key_29' => [FOUR],
		'48_key_30' => [FIVE],
		'48_key_31' => [SIX],
		'48_key_32' => [SEVEN],
		'48_key_33' => [EIGHT],
		'48_key_34' => [NINE],
		'48_key_35' => [ZERO],
		'48_key_36' => [SPACE],
		'48_key_37' => [SEMICOLON],
		'48_key_38' => [COMMA],
		'48_key_39' => [PERIOD],
		'48_key_40' => [SLASH],
		'48_key_41' => [QUOTE],
		'48_key_42' => [MINUS],
		'48_key_43' => [PLUS],
		'48_key_44' => [F1],
		'48_key_45' => [F2],
		'48_key_46' => [F3],
		'48_key_47' => [F4],
		'48_key_48' => [F5],
		'49_key_0' => [A],
		'49_key_1' => [S],
		'49_key_2' => [D],
		'49_key_3' => [F],
		'49_key_4' => [G],
		'49_key_5' => [H],
		'49_key_6' => [J],
		'49_key_7' => [K],
		'49_key_8' => [L],
		'49_key_9' => [Z],
		'49_key_10' => [X],
		'49_key_11' => [C],
		'49_key_12' => [V],
		'49_key_13' => [B],
		'49_key_14' => [N],
		'49_key_15' => [M],
		'49_key_16' => [Q],
		'49_key_17' => [W],
		'49_key_18' => [E],
		'49_key_19' => [R],
		'49_key_20' => [T],
		'49_key_21' => [Y],
		'49_key_22' => [U],
		'49_key_23' => [I],
		'49_key_24' => [O],
		'49_key_25' => [P],
		'49_key_26' => [ONE],
		'49_key_27' => [TWO],
		'49_key_28' => [THREE],
		'49_key_29' => [FOUR],
		'49_key_30' => [FIVE],
		'49_key_31' => [SIX],
		'49_key_32' => [SEVEN],
		'49_key_33' => [EIGHT],
		'49_key_34' => [NINE],
		'49_key_35' => [ZERO],
		'49_key_36' => [SPACE],
		'49_key_37' => [SEMICOLON],
		'49_key_38' => [COMMA],
		'49_key_39' => [PERIOD],
		'49_key_40' => [SLASH],
		'49_key_41' => [QUOTE],
		'49_key_42' => [MINUS],
		'49_key_43' => [PLUS],
		'49_key_44' => [F1],
		'49_key_45' => [F2],
		'49_key_46' => [F3],
		'49_key_47' => [F4],
		'49_key_48' => [F5],
		'49_key_49' => [F6],
		'50_key_0' => [A],
		'50_key_1' => [S],
		'50_key_2' => [D],
		'50_key_3' => [F],
		'50_key_4' => [G],
		'50_key_5' => [H],
		'50_key_6' => [J],
		'50_key_7' => [K],
		'50_key_8' => [L],
		'50_key_9' => [Z],
		'50_key_10' => [X],
		'50_key_11' => [C],
		'50_key_12' => [V],
		'50_key_13' => [B],
		'50_key_14' => [N],
		'50_key_15' => [M],
		'50_key_16' => [Q],
		'50_key_17' => [W],
		'50_key_18' => [E],
		'50_key_19' => [R],
		'50_key_20' => [T],
		'50_key_21' => [Y],
		'50_key_22' => [U],
		'50_key_23' => [I],
		'50_key_24' => [O],
		'50_key_25' => [P],
		'50_key_26' => [ONE],
		'50_key_27' => [TWO],
		'50_key_28' => [THREE],
		'50_key_29' => [FOUR],
		'50_key_30' => [FIVE],
		'50_key_31' => [SIX],
		'50_key_32' => [SEVEN],
		'50_key_33' => [EIGHT],
		'50_key_34' => [NINE],
		'50_key_35' => [ZERO],
		'50_key_36' => [SPACE],
		'50_key_37' => [SEMICOLON],
		'50_key_38' => [COMMA],
		'50_key_39' => [PERIOD],
		'50_key_40' => [SLASH],
		'50_key_41' => [QUOTE],
		'50_key_42' => [MINUS],
		'50_key_43' => [PLUS],
		'50_key_44' => [F1],
		'50_key_45' => [F2],
		'50_key_46' => [F3],
		'50_key_47' => [F4],
		'50_key_48' => [F5],
		'50_key_49' => [F6],
		'50_key_50' => [F7],
		'51_key_0' => [A],
		'51_key_1' => [S],
		'51_key_2' => [D],
		'51_key_3' => [F],
		'51_key_4' => [G],
		'51_key_5' => [H],
		'51_key_6' => [J],
		'51_key_7' => [K],
		'51_key_8' => [L],
		'51_key_9' => [Z],
		'51_key_10' => [X],
		'51_key_11' => [C],
		'51_key_12' => [V],
		'51_key_13' => [B],
		'51_key_14' => [N],
		'51_key_15' => [M],
		'51_key_16' => [Q],
		'51_key_17' => [W],
		'51_key_18' => [E],
		'51_key_19' => [R],
		'51_key_20' => [T],
		'51_key_21' => [Y],
		'51_key_22' => [U],
		'51_key_23' => [I],
		'51_key_24' => [O],
		'51_key_25' => [P],
		'51_key_26' => [ONE],
		'51_key_27' => [TWO],
		'51_key_28' => [THREE],
		'51_key_29' => [FOUR],
		'51_key_30' => [FIVE],
		'51_key_31' => [SIX],
		'51_key_32' => [SEVEN],
		'51_key_33' => [EIGHT],
		'51_key_34' => [NINE],
		'51_key_35' => [ZERO],
		'51_key_36' => [SPACE],
		'51_key_37' => [SEMICOLON],
		'51_key_38' => [COMMA],
		'51_key_39' => [PERIOD],
		'51_key_40' => [SLASH],
		'51_key_41' => [QUOTE],
		'51_key_42' => [MINUS],
		'51_key_43' => [PLUS],
		'51_key_44' => [F1],
		'51_key_45' => [F2],
		'51_key_46' => [F3],
		'51_key_47' => [F4],
		'51_key_48' => [F5],
		'51_key_49' => [F6],
		'51_key_50' => [F7],
		'51_key_51' => [F8],
		'52_key_0' => [A],
		'52_key_1' => [S],
		'52_key_2' => [D],
		'52_key_3' => [F],
		'52_key_4' => [G],
		'52_key_5' => [H],
		'52_key_6' => [J],
		'52_key_7' => [K],
		'52_key_8' => [L],
		'52_key_9' => [Z],
		'52_key_10' => [X],
		'52_key_11' => [C],
		'52_key_12' => [V],
		'52_key_13' => [B],
		'52_key_14' => [N],
		'52_key_15' => [M],
		'52_key_16' => [Q],
		'52_key_17' => [W],
		'52_key_18' => [E],
		'52_key_19' => [R],
		'52_key_20' => [T],
		'52_key_21' => [Y],
		'52_key_22' => [U],
		'52_key_23' => [I],
		'52_key_24' => [O],
		'52_key_25' => [P],
		'52_key_26' => [ONE],
		'52_key_27' => [TWO],
		'52_key_28' => [THREE],
		'52_key_29' => [FOUR],
		'52_key_30' => [FIVE],
		'52_key_31' => [SIX],
		'52_key_32' => [SEVEN],
		'52_key_33' => [EIGHT],
		'52_key_34' => [NINE],
		'52_key_35' => [ZERO],
		'52_key_36' => [SPACE],
		'52_key_37' => [SEMICOLON],
		'52_key_38' => [COMMA],
		'52_key_39' => [PERIOD],
		'52_key_40' => [SLASH],
		'52_key_41' => [QUOTE],
		'52_key_42' => [MINUS],
		'52_key_43' => [PLUS],
		'52_key_44' => [F1],
		'52_key_45' => [F2],
		'52_key_46' => [F3],
		'52_key_47' => [F4],
		'52_key_48' => [F5],
		'52_key_49' => [F6],
		'52_key_50' => [F7],
		'52_key_51' => [F8],
		'52_key_52' => [F9],
		'53_key_0' => [A],
		'53_key_1' => [S],
		'53_key_2' => [D],
		'53_key_3' => [F],
		'53_key_4' => [G],
		'53_key_5' => [H],
		'53_key_6' => [J],
		'53_key_7' => [K],
		'53_key_8' => [L],
		'53_key_9' => [Z],
		'53_key_10' => [X],
		'53_key_11' => [C],
		'53_key_12' => [V],
		'53_key_13' => [B],
		'53_key_14' => [N],
		'53_key_15' => [M],
		'53_key_16' => [Q],
		'53_key_17' => [W],
		'53_key_18' => [E],
		'53_key_19' => [R],
		'53_key_20' => [T],
		'53_key_21' => [Y],
		'53_key_22' => [U],
		'53_key_23' => [I],
		'53_key_24' => [O],
		'53_key_25' => [P],
		'53_key_26' => [ONE],
		'53_key_27' => [TWO],
		'53_key_28' => [THREE],
		'53_key_29' => [FOUR],
		'53_key_30' => [FIVE],
		'53_key_31' => [SIX],
		'53_key_32' => [SEVEN],
		'53_key_33' => [EIGHT],
		'53_key_34' => [NINE],
		'53_key_35' => [ZERO],
		'53_key_36' => [SPACE],
		'53_key_37' => [SEMICOLON],
		'53_key_38' => [COMMA],
		'53_key_39' => [PERIOD],
		'53_key_40' => [SLASH],
		'53_key_41' => [QUOTE],
		'53_key_42' => [MINUS],
		'53_key_43' => [PLUS],
		'53_key_44' => [F1],
		'53_key_45' => [F2],
		'53_key_46' => [F3],
		'53_key_47' => [F4],
		'53_key_48' => [F5],
		'53_key_49' => [F6],
		'53_key_50' => [F7],
		'53_key_51' => [F8],
		'53_key_52' => [F9],
		'53_key_53' => [F10],
		'54_key_0' => [A],
		'54_key_1' => [S],
		'54_key_2' => [D],
		'54_key_3' => [F],
		'54_key_4' => [G],
		'54_key_5' => [H],
		'54_key_6' => [J],
		'54_key_7' => [K],
		'54_key_8' => [L],
		'54_key_9' => [Z],
		'54_key_10' => [X],
		'54_key_11' => [C],
		'54_key_12' => [V],
		'54_key_13' => [B],
		'54_key_14' => [N],
		'54_key_15' => [M],
		'54_key_16' => [Q],
		'54_key_17' => [W],
		'54_key_18' => [E],
		'54_key_19' => [R],
		'54_key_20' => [T],
		'54_key_21' => [Y],
		'54_key_22' => [U],
		'54_key_23' => [I],
		'54_key_24' => [O],
		'54_key_25' => [P],
		'54_key_26' => [ONE],
		'54_key_27' => [TWO],
		'54_key_28' => [THREE],
		'54_key_29' => [FOUR],
		'54_key_30' => [FIVE],
		'54_key_31' => [SIX],
		'54_key_32' => [SEVEN],
		'54_key_33' => [EIGHT],
		'54_key_34' => [NINE],
		'54_key_35' => [ZERO],
		'54_key_36' => [SPACE],
		'54_key_37' => [SEMICOLON],
		'54_key_38' => [COMMA],
		'54_key_39' => [PERIOD],
		'54_key_40' => [SLASH],
		'54_key_41' => [QUOTE],
		'54_key_42' => [MINUS],
		'54_key_43' => [PLUS],
		'54_key_44' => [F1],
		'54_key_45' => [F2],
		'54_key_46' => [F3],
		'54_key_47' => [F4],
		'54_key_48' => [F5],
		'54_key_49' => [F6],
		'54_key_50' => [F7],
		'54_key_51' => [F8],
		'54_key_52' => [F9],
		'54_key_53' => [F10],
		'54_key_54' => [F11],
		'55_key_0' => [A],
		'55_key_1' => [S],
		'55_key_2' => [D],
		'55_key_3' => [F],
		'55_key_4' => [G],
		'55_key_5' => [H],
		'55_key_6' => [J],
		'55_key_7' => [K],
		'55_key_8' => [L],
		'55_key_9' => [Z],
		'55_key_10' => [X],
		'55_key_11' => [C],
		'55_key_12' => [V],
		'55_key_13' => [B],
		'55_key_14' => [N],
		'55_key_15' => [M],
		'55_key_16' => [Q],
		'55_key_17' => [W],
		'55_key_18' => [E],
		'55_key_19' => [R],
		'55_key_20' => [T],
		'55_key_21' => [Y],
		'55_key_22' => [U],
		'55_key_23' => [I],
		'55_key_24' => [O],
		'55_key_25' => [P],
		'55_key_26' => [ONE],
		'55_key_27' => [TWO],
		'55_key_28' => [THREE],
		'55_key_29' => [FOUR],
		'55_key_30' => [FIVE],
		'55_key_31' => [SIX],
		'55_key_32' => [SEVEN],
		'55_key_33' => [EIGHT],
		'55_key_34' => [NINE],
		'55_key_35' => [ZERO],
		'55_key_36' => [SPACE],
		'55_key_37' => [SEMICOLON],
		'55_key_38' => [COMMA],
		'55_key_39' => [PERIOD],
		'55_key_40' => [SLASH],
		'55_key_41' => [QUOTE],
		'55_key_42' => [MINUS],
		'55_key_43' => [PLUS],
		'55_key_44' => [F1],
		'55_key_45' => [F2],
		'55_key_46' => [F3],
		'55_key_47' => [F4],
		'55_key_48' => [F5],
		'55_key_49' => [F6],
		'55_key_50' => [F7],
		'55_key_51' => [F8],
		'55_key_52' => [F9],
		'55_key_53' => [F10],
		'55_key_54' => [F11],
		'55_key_55' => [F12],
		'56_key_0' => [A],
		'56_key_1' => [S],
		'56_key_2' => [D],
		'56_key_3' => [F],
		'56_key_4' => [G],
		'56_key_5' => [H],
		'56_key_6' => [J],
		'56_key_7' => [K],
		'56_key_8' => [L],
		'56_key_9' => [Z],
		'56_key_10' => [X],
		'56_key_11' => [C],
		'56_key_12' => [V],
		'56_key_13' => [B],
		'56_key_14' => [N],
		'56_key_15' => [M],
		'56_key_16' => [Q],
		'56_key_17' => [W],
		'56_key_18' => [E],
		'56_key_19' => [R],
		'56_key_20' => [T],
		'56_key_21' => [Y],
		'56_key_22' => [U],
		'56_key_23' => [I],
		'56_key_24' => [O],
		'56_key_25' => [P],
		'56_key_26' => [ONE],
		'56_key_27' => [TWO],
		'56_key_28' => [THREE],
		'56_key_29' => [FOUR],
		'56_key_30' => [FIVE],
		'56_key_31' => [SIX],
		'56_key_32' => [SEVEN],
		'56_key_33' => [EIGHT],
		'56_key_34' => [NINE],
		'56_key_35' => [ZERO],
		'56_key_36' => [SPACE],
		'56_key_37' => [SEMICOLON],
		'56_key_38' => [COMMA],
		'56_key_39' => [PERIOD],
		'56_key_40' => [SLASH],
		'56_key_41' => [QUOTE],
		'56_key_42' => [MINUS],
		'56_key_43' => [PLUS],
		'56_key_44' => [F1],
		'56_key_45' => [F2],
		'56_key_46' => [F3],
		'56_key_47' => [F4],
		'56_key_48' => [F5],
		'56_key_49' => [F6],
		'56_key_50' => [F7],
		'56_key_51' => [F8],
		'56_key_52' => [F9],
		'56_key_53' => [F10],
		'56_key_54' => [F11],
		'56_key_55' => [F12],
		'56_key_56' => [F1],
		'57_key_0' => [A],
		'57_key_1' => [S],
		'57_key_2' => [D],
		'57_key_3' => [F],
		'57_key_4' => [G],
		'57_key_5' => [H],
		'57_key_6' => [J],
		'57_key_7' => [K],
		'57_key_8' => [L],
		'57_key_9' => [Z],
		'57_key_10' => [X],
		'57_key_11' => [C],
		'57_key_12' => [V],
		'57_key_13' => [B],
		'57_key_14' => [N],
		'57_key_15' => [M],
		'57_key_16' => [Q],
		'57_key_17' => [W],
		'57_key_18' => [E],
		'57_key_19' => [R],
		'57_key_20' => [T],
		'57_key_21' => [Y],
		'57_key_22' => [U],
		'57_key_23' => [I],
		'57_key_24' => [O],
		'57_key_25' => [P],
		'57_key_26' => [ONE],
		'57_key_27' => [TWO],
		'57_key_28' => [THREE],
		'57_key_29' => [FOUR],
		'57_key_30' => [FIVE],
		'57_key_31' => [SIX],
		'57_key_32' => [SEVEN],
		'57_key_33' => [EIGHT],
		'57_key_34' => [NINE],
		'57_key_35' => [ZERO],
		'57_key_36' => [SPACE],
		'57_key_37' => [SEMICOLON],
		'57_key_38' => [COMMA],
		'57_key_39' => [PERIOD],
		'57_key_40' => [SLASH],
		'57_key_41' => [QUOTE],
		'57_key_42' => [MINUS],
		'57_key_43' => [PLUS],
		'57_key_44' => [F1],
		'57_key_45' => [F2],
		'57_key_46' => [F3],
		'57_key_47' => [F4],
		'57_key_48' => [F5],
		'57_key_49' => [F6],
		'57_key_50' => [F7],
		'57_key_51' => [F8],
		'57_key_52' => [F9],
		'57_key_53' => [F10],
		'57_key_54' => [F11],
		'57_key_55' => [F12],
		'57_key_56' => [F1],
		'57_key_57' => [F2],
		'58_key_0' => [A],
		'58_key_1' => [S],
		'58_key_2' => [D],
		'58_key_3' => [F],
		'58_key_4' => [G],
		'58_key_5' => [H],
		'58_key_6' => [J],
		'58_key_7' => [K],
		'58_key_8' => [L],
		'58_key_9' => [Z],
		'58_key_10' => [X],
		'58_key_11' => [C],
		'58_key_12' => [V],
		'58_key_13' => [B],
		'58_key_14' => [N],
		'58_key_15' => [M],
		'58_key_16' => [Q],
		'58_key_17' => [W],
		'58_key_18' => [E],
		'58_key_19' => [R],
		'58_key_20' => [T],
		'58_key_21' => [Y],
		'58_key_22' => [U],
		'58_key_23' => [I],
		'58_key_24' => [O],
		'58_key_25' => [P],
		'58_key_26' => [ONE],
		'58_key_27' => [TWO],
		'58_key_28' => [THREE],
		'58_key_29' => [FOUR],
		'58_key_30' => [FIVE],
		'58_key_31' => [SIX],
		'58_key_32' => [SEVEN],
		'58_key_33' => [EIGHT],
		'58_key_34' => [NINE],
		'58_key_35' => [ZERO],
		'58_key_36' => [SPACE],
		'58_key_37' => [SEMICOLON],
		'58_key_38' => [COMMA],
		'58_key_39' => [PERIOD],
		'58_key_40' => [SLASH],
		'58_key_41' => [QUOTE],
		'58_key_42' => [MINUS],
		'58_key_43' => [PLUS],
		'58_key_44' => [F1],
		'58_key_45' => [F2],
		'58_key_46' => [F3],
		'58_key_47' => [F4],
		'58_key_48' => [F5],
		'58_key_49' => [F6],
		'58_key_50' => [F7],
		'58_key_51' => [F8],
		'58_key_52' => [F9],
		'58_key_53' => [F10],
		'58_key_54' => [F11],
		'58_key_55' => [F12],
		'58_key_56' => [F1],
		'58_key_57' => [F2],
		'58_key_58' => [F3],
		'59_key_0' => [A],
		'59_key_1' => [S],
		'59_key_2' => [D],
		'59_key_3' => [F],
		'59_key_4' => [G],
		'59_key_5' => [H],
		'59_key_6' => [J],
		'59_key_7' => [K],
		'59_key_8' => [L],
		'59_key_9' => [Z],
		'59_key_10' => [X],
		'59_key_11' => [C],
		'59_key_12' => [V],
		'59_key_13' => [B],
		'59_key_14' => [N],
		'59_key_15' => [M],
		'59_key_16' => [Q],
		'59_key_17' => [W],
		'59_key_18' => [E],
		'59_key_19' => [R],
		'59_key_20' => [T],
		'59_key_21' => [Y],
		'59_key_22' => [U],
		'59_key_23' => [I],
		'59_key_24' => [O],
		'59_key_25' => [P],
		'59_key_26' => [ONE],
		'59_key_27' => [TWO],
		'59_key_28' => [THREE],
		'59_key_29' => [FOUR],
		'59_key_30' => [FIVE],
		'59_key_31' => [SIX],
		'59_key_32' => [SEVEN],
		'59_key_33' => [EIGHT],
		'59_key_34' => [NINE],
		'59_key_35' => [ZERO],
		'59_key_36' => [SPACE],
		'59_key_37' => [SEMICOLON],
		'59_key_38' => [COMMA],
		'59_key_39' => [PERIOD],
		'59_key_40' => [SLASH],
		'59_key_41' => [QUOTE],
		'59_key_42' => [MINUS],
		'59_key_43' => [PLUS],
		'59_key_44' => [F1],
		'59_key_45' => [F2],
		'59_key_46' => [F3],
		'59_key_47' => [F4],
		'59_key_48' => [F5],
		'59_key_49' => [F6],
		'59_key_50' => [F7],
		'59_key_51' => [F8],
		'59_key_52' => [F9],
		'59_key_53' => [F10],
		'59_key_54' => [F11],
		'59_key_55' => [F12],
		'59_key_56' => [F1],
		'59_key_57' => [F2],
		'59_key_58' => [F3],
		'59_key_59' => [F4],
		'60_key_0' => [A],
		'60_key_1' => [S],
		'60_key_2' => [D],
		'60_key_3' => [F],
		'60_key_4' => [G],
		'60_key_5' => [H],
		'60_key_6' => [J],
		'60_key_7' => [K],
		'60_key_8' => [L],
		'60_key_9' => [Z],
		'60_key_10' => [X],
		'60_key_11' => [C],
		'60_key_12' => [V],
		'60_key_13' => [B],
		'60_key_14' => [N],
		'60_key_15' => [M],
		'60_key_16' => [Q],
		'60_key_17' => [W],
		'60_key_18' => [E],
		'60_key_19' => [R],
		'60_key_20' => [T],
		'60_key_21' => [Y],
		'60_key_22' => [U],
		'60_key_23' => [I],
		'60_key_24' => [O],
		'60_key_25' => [P],
		'60_key_26' => [ONE],
		'60_key_27' => [TWO],
		'60_key_28' => [THREE],
		'60_key_29' => [FOUR],
		'60_key_30' => [FIVE],
		'60_key_31' => [SIX],
		'60_key_32' => [SEVEN],
		'60_key_33' => [EIGHT],
		'60_key_34' => [NINE],
		'60_key_35' => [ZERO],
		'60_key_36' => [SPACE],
		'60_key_37' => [SEMICOLON],
		'60_key_38' => [COMMA],
		'60_key_39' => [PERIOD],
		'60_key_40' => [SLASH],
		'60_key_41' => [QUOTE],
		'60_key_42' => [MINUS],
		'60_key_43' => [PLUS],
		'60_key_44' => [F1],
		'60_key_45' => [F2],
		'60_key_46' => [F3],
		'60_key_47' => [F4],
		'60_key_48' => [F5],
		'60_key_49' => [F6],
		'60_key_50' => [F7],
		'60_key_51' => [F8],
		'60_key_52' => [F9],
		'60_key_53' => [F10],
		'60_key_54' => [F11],
		'60_key_55' => [F12],
		'60_key_56' => [F1],
		'60_key_57' => [F2],
		'60_key_58' => [F3],
		'60_key_59' => [F4],
		'60_key_60' => [F5],

		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_mute' => [#if mobile F10 #else ZERO #end],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN],
		'debug_2' => [EIGHT],
		'fullscreen' => [F11]
	];
	public static var defaultMobileBinds:Map<String, Array<FlxKey>> = null;
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) // Null = both, False = Keyboard, True = Controller
	{
		if (controller != true)
			for (key in keyBinds.keys())
				if (defaultKeys.exists(key))
				{
					var arr = keyBinds.get(key);
					arr.resize(0);
					for (i in defaultKeys.get(key))
						arr.push(i);
				}
	}

	public static function clearInvalidKeys(key:String)
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		while (keyBind != null && keyBind.contains(NONE))
			keyBind.remove(NONE);
	}

	public static function loadDefaultKeys()
	{
		defaultKeys = [for (key => value in keyBinds) key => value.copy()];
	}

	public static function saveSettings()
	{
		for (key in Reflect.fields(data))
			if (key != 'arrowRGB' && key != 'arrowRGBPixel')
			{
				Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
			} //遍历data输入到flxsave里
		#if sys
		else if (key == 'arrowRGB')
			saveArrowRGBData('arrowRGB.json', data.arrowRGB);
		else if (key == 'arrowRGBPixel')
			saveArrowRGBData('arrowRGBPixel.json', data.arrowRGBPixel);
		#end

		FlxG.save.data.modsData = modsData;

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

		// Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v4', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;

		save.flush();
		FlxG.log.add("Settings saved!");
	}

	#if sys
	public static function saveArrowRGBData(path:String, rgbArray:Array<Array<FlxColor>>)
	{
		var saveArrowRGB:ArrowRGBSavedData;
		var colors:Array<EKNoteColor> = [];
		for (color in rgbArray)
		{
			var inner = color[0];
			var border = color[1];
			var outline = color[2];

			var resultColor = new EKNoteColor();
			resultColor.inner = inner.toHexString(false, false);
			resultColor.border = border.toHexString(false, false);
			resultColor.outline = outline.toHexString(false, false);

			colors.push(resultColor);

			// trace('Saved color ${resultColor.inner} ${resultColor.border} ${resultColor.outline}');
		}

		saveArrowRGB = new ArrowRGBSavedData(colors);
		var writer = new json2object.JsonWriter<ArrowRGBSavedData>();
		var content = writer.write(saveArrowRGB, '    ');
		File.saveContent(path, content);

		trace('Wrote to $path');
	}
	#end

	public static function loadArrowRGBData(path:String, pixel:Bool = false, defaultColors:Array<EKNoteColor>)
	{
		var savedColors:CoolUtil.ArrowRGBSavedData = CoolUtil.getArrowRGB(path, defaultColors);

		if (pixel)
			ClientPrefs.defaultData.arrowRGBPixel = [];
		else
			ClientPrefs.defaultData.arrowRGB = [];

		for (defaultColor in defaultColors)
		{
			var thisNote = [
				CoolUtil.colorFromString(defaultColor.inner),
				CoolUtil.colorFromString(defaultColor.border),
				CoolUtil.colorFromString(defaultColor.outline)
			];
			if (pixel)
				ClientPrefs.defaultData.arrowRGBPixel.push(thisNote);
			else
				ClientPrefs.defaultData.arrowRGB.push(thisNote);
		}

		if (pixel)
			ClientPrefs.data.arrowRGBPixel = [];
		else
			ClientPrefs.data.arrowRGB = [];

		for (color in savedColors.colors)
		{
			var thisNote = [
				CoolUtil.colorFromString(color.inner),
				CoolUtil.colorFromString(color.border),
				CoolUtil.colorFromString(color.outline)
			];

			// trace('Loaded color into save: $thisNote, pixel? $pixel');

			if (pixel)
				ClientPrefs.data.arrowRGBPixel.push(thisNote);
			else
				ClientPrefs.data.arrowRGB.push(thisNote);
		}
	}

	/**
	 * Guarantees that `FlxG.save.data` is a usable container.
	 *
	 * `FlxSave.bind()` calls `destroy()` first (which sets `data = null`) and only
	 * assigns a fresh value when the shared object loads successfully. So any save
	 * file that fails to load (parsing error, IO error, invalid path) leaves
	 * `FlxG.save.data` null, and reading a field off a null `Dynamic` is a hard
	 * access violation on hxcpp (`EXCEPTION_ACCESS_VIOLATION`, 0xC0000005) that
	 * kills the process before the first frame is drawn.
	 *
	 * Never let that happen: install an empty container and let the
	 * `prefsVersion` migration in `loadPrefs()` repopulate every default.
	 */
	public static function ensureSaveData():Dynamic
	{
		if (FlxG.save == null)
			return null;

		var current:Dynamic = FlxG.save.data;
		if (current == null)
		{
			current = {};
			@:privateAccess FlxG.save.data = current;
			FlxG.log.warn('[ClientPrefs] FlxG.save.data was null (save could not be loaded), starting from defaults.');
		}
		return current;
	}

	/**
	 * Recovery parser handed to `FlxSave.bind()` as its `backupParser` argument.
	 *
	 * flixel only calls this when the save file exists but cannot be unserialized
	 * (for example a save holding a class instance the runtime cannot rebuild, such
	 * as the `FlxPoint` values older builds wrote into the mobile control settings).
	 * Without a recovery parser `bind()` simply returns false and leaves `data`
	 * null, which is what used to crash the engine during boot; returning a fresh
	 * container keeps the game running, and the previous file is preserved on disk
	 * as `funkin.sol.unreadable` so nothing is lost silently.
	 */
	public static function recoverUnreadableSave(raw:String, error:Exception):Null<Dynamic>
	{
		FlxG.log.warn('[ClientPrefs] Save data could not be read ($error) - keeping a backup and starting from defaults.');

		#if sys
		try
		{
			if (raw != null && raw.length > 0)
				sys.io.File.saveContent('funkin.sol.unreadable', raw);
		}
		catch (e:Dynamic) {}
		#end

		return {};
	}

	public static function loadPrefs()
	{
		// A failed `FlxG.save.bind()` leaves `data` null; repair it before touching it.
		ensureSaveData();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		if (FlxG.save.data.prefsVersion != data.prefsVersion)
		{
			data = {};
			modsData = [];
			for (key in Reflect.fields(defaultData))
			{
				if (key == 'arrowRGB' || key == 'arrowRGBPixel' || key == 'modsData')
					continue;
				if (key == 'gameplaySettings')
				{
					data.gameplaySettings.clear();
					for (k => v in defaultData.gameplaySettings)
						data.gameplaySettings.set(k, v);
					FlxG.save.data.gameplaySettings = data.gameplaySettings;
					continue;
				}
				Reflect.setField(data, key, Reflect.field(defaultData, key));
				Reflect.setField(FlxG.save.data, key, Reflect.field(defaultData, key));
			}
			FlxG.save.data.modsData = modsData;

			#if desktop
			data.framerate = 240;
			data.drawFramerate = 1200;
			Reflect.setField(FlxG.save.data, 'framerate', data.framerate);
			Reflect.setField(FlxG.save.data, 'drawFramerate', data.drawFramerate);
			#elseif (!html5 && !switch)
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate * 2, 60, 1000));
			data.drawFramerate = Std.int(FlxMath.bound(refreshRate, 60, 1000));
			Reflect.setField(FlxG.save.data, 'framerate', data.framerate);
			Reflect.setField(FlxG.save.data, 'drawFramerate', data.drawFramerate);
			#end

			FlxG.save.flush();

			#if sys
			if (FileSystem.exists('arrowRGB.json')) FileSystem.deleteFile('arrowRGB.json');
			if (FileSystem.exists('arrowRGBPixel.json')) FileSystem.deleteFile('arrowRGBPixel.json');
			#end
			loadArrowRGBData('arrowRGB.json', false, ExtraKeysHandler.instance.data.colors);
			loadArrowRGBData('arrowRGBPixel.json', true, ExtraKeysHandler.instance.data.pixelNoteColors);

			if (defaultKeys == null)
				loadDefaultKeys();

			keyBinds.clear();
			for (name => keys in defaultKeys)
				keyBinds.set(name, keys.copy());

			var controlSave:FlxSave = new FlxSave();
			controlSave.bind('controls_v4', CoolUtil.getSavePath());
			if (controlSave != null && controlSave.data != null)
			{
				controlSave.data.keyboard = defaultKeys;
				controlSave.flush();
			}
			reloadVolumeKeys();
		}
		else
		{
			for (key in Reflect.fields(data))
				if (key != 'gameplaySettings' && 
					key != 'arrowRGB' &&
					key != 'arrowRGBPixel' &&
					// Keep the compiled migration target. Loading the saved marker
					// here makes the later comparison oldVersion < targetVersion
					// compare the old value with itself and silently skip migration.
					key != 'performanceDefaultsVersion' && Reflect.hasField(FlxG.save.data, key))
					Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
				else if (key == 'arrowRGB') 
				{
					loadArrowRGBData('arrowRGB.json', false, ExtraKeysHandler.instance.data.colors);
				} 
				else if (key == 'arrowRGBPixel') 
				{
					loadArrowRGBData('arrowRGBPixel.json', true, ExtraKeysHandler.instance.data.pixelNoteColors);
				}

			if (FlxG.save.data.modsData != null)
				modsData = FlxG.save.data.modsData;
			else modsData = [];

			var save:FlxSave = new FlxSave();
			save.bind('controls_v4', CoolUtil.getSavePath());
			if (save != null && save.data != null)
			{
				if (save.data.keyboard != null)
				{
					var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
					for (control => keys in loadedControls)
						if (keyBinds.exists(control))
						{
							var arr = keyBinds.get(control);
							arr.resize(0);
							for (i in keys)
								arr.push(i);
						}
				}
				reloadVolumeKeys();
			}
		}

		#if mobile
		// 移动端一次性迁移：首次运行（或旧版升级）自动启用“调整移动端各Editor键位”，
		// 让 APK 内置的 Editor 键位配置开箱即用；标记写入后不再强制，尊重用户手动开关。
		var savedEmkVersion:Dynamic = Reflect.field(FlxG.save.data, 'emkDefaultsVersion');
		if (savedEmkVersion == null || savedEmkVersion < data.emkDefaultsVersion)
		{
			data.adjustMobileEditorKeys = true;
			Reflect.setField(FlxG.save.data, 'adjustMobileEditorKeys', true);
			Reflect.setField(FlxG.save.data, 'emkDefaultsVersion', data.emkDefaultsVersion);
			FlxG.save.flush();
		}
		#end

		#if desktop
		// Migrate only the measured desktop scheduling defaults. Keep every other
		// preference and key binding intact.
		var savedPerformanceDefaultsVersion:Dynamic = Reflect.field(FlxG.save.data, 'performanceDefaultsVersion');
		if (savedPerformanceDefaultsVersion == null || savedPerformanceDefaultsVersion < data.performanceDefaultsVersion)
		{
			data.framerate = 240;
			data.drawFramerate = 1200;
			data.lockRender = true;
			// Lime's GL worker keeps a bounded two-frame pipeline. Keep driver
			// submission off the update thread; direct submission serializes UI
			// traversal with GL commands and causes a high-FPS regression.
			data.renderThread = true;
			// Keep desktop high-FPS mode at the engine's authored resolution.
			// Higher resolutions remain selectable, but should be an explicit
			// image-quality choice rather than a hidden cost on every interface.
			data.resolution = '720P';
			Reflect.setField(FlxG.save.data, 'framerate', data.framerate);
			Reflect.setField(FlxG.save.data, 'drawFramerate', data.drawFramerate);
			Reflect.setField(FlxG.save.data, 'lockRender', data.lockRender);
			Reflect.setField(FlxG.save.data, 'renderThread', data.renderThread);
			Reflect.setField(FlxG.save.data, 'resolution', data.resolution);
			Reflect.setField(FlxG.save.data, 'performanceDefaultsVersion', data.performanceDefaultsVersion);
			FlxG.save.flush();
		}
		#end

		if (Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		#if (!html5 && !switch)
		FlxG.autoPause = data.autoPause;

		if (FlxG.save.data.framerate == null)
		{
			#if desktop
			data.framerate = 240;
			#else
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate * 2;
			data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 1000));
			#end
		}

		if (FlxG.save.data.drawFramerate == null)
		{
			#if desktop
			data.drawFramerate = 1200;
			#else
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.drawFramerate = Std.int(FlxMath.bound(refreshRate, 60, 1000));
			#end
		}
		#end

		var useRenderThread:Bool = data.renderThread;
		#if sys
		// Keep the saved preference as the default, while allowing repeatable
		// render-path A/B tests without rewriting the user's save file.
		final renderThreadOverride:String = Sys.getEnv('NOVAFLARE_RENDER_THREAD');
		if (renderThreadOverride == '0')
			useRenderThread = false;
		else if (renderThreadOverride == '1')
			useRenderThread = true;
		#end
		lime.graphics.opengl.GL.setMultiThreaded(useRenderThread);

		#if mobile
		MobileShaderConverter.setEnabled(data.autoShaderConversion);
		MouseEffect.setUserEffectsEnabled(data.mouseTrailEffect);
		#end

		FlxG.updateFramerate = data.framerate;
		FlxG.drawFramerate = data.drawFramerate;
		FlxG.stage.application.window.lockRender = data.lockRender;

		var output:Array<Float> = [];
		switch(data.resolution) {
			case '360P':
				output = [640, 360];
			case '480P':
				output = [854, 480];
			case '540P':
				output = [960, 540];
			case '720P':
				output = [1280, 720];
			case '768P':
				output = [1366, 768];
			case '900P':
				output = [1600, 900];
			case '1080P':
				output = [1920, 1080];
			case '1440P (2K)':
				output = [2560, 1440];
			case '1600P':	
				output = [2560, 1600];
			case '1800P':
				output = [3200, 1800];
			case '2160P (4K)':	
				output = [3840, 2160];
			default:
				var display:Display = lime.system.System.getDisplay(0);
				output = [display.bounds.width, display.bounds.height];
				data.resolution = "Native: " + display.bounds.width + "x" + display.bounds.height;
		}
		openfl.Lib.current.stage.setLogicalSize(Std.int(output[0]), Std.int(output[1]));

		if (FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		#if DISCORD_ALLOWED
		DiscordClient.check();
		#end
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic
	{
		if (!customDefaultValue)
			defaultValue = defaultData.gameplaySettings.get(name);
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys()
	{
		var _mk:Array<FlxKey> = keyBinds != null ? keyBinds.get('volume_mute') : null;
		TitleState.muteKeys = _mk != null ? _mk.copy() : [];
		var _dk:Array<FlxKey> = keyBinds != null ? keyBinds.get('volume_down') : null;
		TitleState.volumeDownKeys = _dk != null ? _dk.copy() : [];
		var _uk:Array<FlxKey> = keyBinds != null ? keyBinds.get('volume_up') : null;
		TitleState.volumeUpKeys = _uk != null ? _uk.copy() : [];
		toggleVolumeKeys(true);
	}

	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		if (FlxG.sound != null) FlxG.sound.muteKeys = turnOn ? TitleState.muteKeys : [];
		if (FlxG.sound != null) FlxG.sound.volumeDownKeys = turnOn ? TitleState.volumeDownKeys : [];
		if (FlxG.sound != null) FlxG.sound.volumeUpKeys = turnOn ? TitleState.volumeUpKeys : [];
	}

	public static function get(variable:String, supportMods:Bool = true):Dynamic {
		if (supportMods) {
			if (modsData.get(Mods.currentModDirectory).get(variable) != null)
					return modsData.get(Mods.currentModDirectory).get(variable);

			if (modsData.get('Global mod').get(variable) != null)
					return modsData.get('Global mod').get(variable);

			for (mod in Mods.getGlobalMods())
			{
				if (modsData.get(mod).get(variable) != null)
					return modsData.get(mod).get(variable);
			}
		}

		if (Reflect.getProperty(ClientPrefs.data, variable) != null)
			return Reflect.getProperty(ClientPrefs.data, variable);

		return null;
	}

	public static function set(variable:String, data:Bool = true, path:String = '') {
		switch (path) {
			case '':
				if (Mods.currentModDirectory != '') {
					if (modsData.get(Mods.currentModDirectory) == null)
						modsData.set(Mods.currentModDirectory, []);
					modsData.get(Mods.currentModDirectory).set(variable, data);
				} else {
					if (modsData.get('Global mod') == null)
						modsData.set('Global mod', []);
					modsData.get('Global mod').set(variable, data);
				}
			case 'data':
				try{ Reflect.setProperty(ClientPrefs.data, variable, data); }
			case _:
				if (modsData.get(path) == null)
						modsData.set(path, []);
				modsData.get(path).set(variable, data);
		}
	}
}

