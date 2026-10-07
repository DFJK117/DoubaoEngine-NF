package options.groupData;

import sys.FileSystem;
import general.backend.Paths;
import general.backend.Mods;
import options.objects.Option;
import options.objects.OptionCata;

class CustomGroup extends OptionCata
{
	public function new(X:Float, Y:Float, width:Float, height:Float)
	{
		super(X, Y, width, height);

		var titleOpt:Option = new Option(this, 'Customize', TITLE);
		addOption(titleOpt);

		// 自定义打击音效：把 .ogg 丢进模组文件夹的 sounds/hitsounds/ 即可在「音频 → 打击音效」里出现
		// （AudioGroup 已经会扫描所有模组 + 共享目录，这里只做说明）
		var hintOpt:Option = new Option(this, 'customHitsoundHint', TEXT);
		addOption(hintOpt);

		// 自定义 Note 形态：扫描 custom_notetypes/*.txt（共享目录 + 每个模组），'None' 表示沿用谱面自带
		var noteForms:Array<String> = ['None'];
		var formFolders:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'custom_notetypes/');
		for (mod in Mods.getModDirectories())
		{
			var folder:String = Paths.mods(mod + '/custom_notetypes/');
			if (FileSystem.exists(folder) && !formFolders.contains(folder))
				formFolders.push(folder);
		}
		for (folder in formFolders)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.txt'))
					{
						var name:String = file.replace('.txt', '');
						if (!noteForms.contains(name))
							noteForms.push(name);
					}
				}
			}
		}
		var formOpt:Option = new Option(this, 'customNoteForm', STRING, noteForms);
		addOption(formOpt);

		changeHeight(0); //初始化真正的height
	}
}
