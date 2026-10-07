package options.groupData;

class AudioGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var option:Option = new Option(this, 'Audio', TITLE);
		addOption(option);

		var MainMusicArray:Array<String> = ['None', 'freakyMenu'];
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'music/Main Screen', true)) {
            for (file in FileSystem.readDirectory(folder)) {
                if (file.endsWith('.ogg')) {
                    MainMusicArray.push(file.replace('.ogg', ''));
                }
            }
        }

        var option:Option = new Option(this, 'mainMusic', STRING, MainMusicArray);
        addOption(option);

        var OptionMusicArray:Array<String> = ['None'];
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'music/Options', true)) {
            for (file in FileSystem.readDirectory(folder)) {
                if (file.endsWith('.ogg')) {
                    OptionMusicArray.push(file.replace('.ogg', ''));
                }
            }
        }

        var option:Option = new Option(this, 'optionMusic', STRING, OptionMusicArray);
        addOption(option);

        var PauseMusicArray:Array<String> = ['None', 'Breakfast', 'Tea Time'];
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'music/Pause', true)) {
            for (file in FileSystem.readDirectory(folder)) {
                if (file.endsWith('.ogg')) {
                    PauseMusicArray.push(file.replace('.ogg', ''));
                }
            }
        }

        var option:Option = new Option(this, 'pauseMusic', STRING, PauseMusicArray);
        addOption(option);

        var hitsoundArray:Array<String> = ['Default'];

        // 自定义按键音效：把「所有可能放有 sounds/hitsounds/*.ogg 的目录」都扫一遍。
        // 原逻辑只扫共享目录 + 全局模组 + mods 根 + 当前载入的模组，
        // 于是玩家丢进某个（未启用/未设为全局的）模组里的打击音在下拉框里根本找不到。
        // 现在 mods 目录下**每一个**模组都会被扫到，重名只保留第一个。
        var hitsoundFolders:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'sounds/hitsounds/');
        for (mod in Mods.getModDirectories())
        {
            var folder:String = Paths.mods(mod + '/sounds/hitsounds/');
            if (FileSystem.exists(folder) && !hitsoundFolders.contains(folder))
                hitsoundFolders.push(folder);
        }

        for (folder in hitsoundFolders)
        {
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.ogg'))
					{
						var name:String = file.replace('.ogg', '');
						if (!hitsoundArray.contains(name))
							hitsoundArray.push(name);
					}
				}
			}
        }

        var option:Option = new Option(this, 'hitsoundType', STRING, hitsoundArray);
        addOption(option);
        option.onChange = function() {
        if (ClientPrefs.data.hitsoundType == ClientPrefs.defaultData.hitsoundType)
            {
                FlxG.sound.play(Paths.sound('hitsound'));
            }
            else
            {
                FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.data.hitsoundType));
            }
        };

        var option:Option = new Option(this, 'hitsoundVolume', FLOAT, [0, 1, 1]);
        addOption(option);
        option.onChange = function() {
            if (ClientPrefs.data.hitsoundType == ClientPrefs.defaultData.hitsoundType)
            {
                FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
            }
            else
            {
                FlxG.sound.play(Paths.sound('hitsounds/' + ClientPrefs.data.hitsoundType), ClientPrefs.data.hitsoundVolume);
            }
        };

		changeHeight(0); //初始化真正的height
	}
}
