package doido;

#if MODS_FOLDER
import polymod.format.ParseRules;
import polymod.Polymod;
import sys.io.File;

// used for the list json
typedef Mod =
{
	var name:String;
	var enabled:Bool;
}

typedef ModList =
{
	var mods:Array<Mod>;
}

class Mods
{
    //idk if im gonna need this for something
	public static var modMetas:Array<ModMetadata> = [];
	public static var modList:Map<String, Bool> = [];

	public static function init()
	{
		Polymod.init({
			modRoot: "mods",
			dirs: [],
			frameworkParams: {
				coreAssetRedirect: "assets"
			},
			parseRules: new ParseRules(), // disables it i hope
			ignoredFiles: ["mods.json"],
			useScriptedClasses: false
		});
		loadJson();
		scan();
		loadMods();
	}

	// scans the mods folder for new mods n stuff
	public static function scan()
	{
		modMetas = Polymod.scan({modRoot: "mods"});
		for (meta in modMetas)
		{
			if (modList.get(meta.id) == null)
				modList.set(meta.id, true);
		}
		saveJson();
	}

	public static function loadJson()
	{
		var savedMods:ModList = cast haxe.Json.parse(openfl.Assets.getText("mods/mods.json").trim());
		for (mod in savedMods.mods)
			modList.set(mod.name, mod.enabled);
	}

	public static function saveJson()
	{
		var savedMods:ModList = {mods: []};
		for (mod => enabled in modList)
			savedMods.mods.push({name: mod, enabled: enabled});
		var data:String = haxe.Json.stringify(savedMods, "\t");
		File.saveContent("mods/mods.json", data);
	}

	public static function loadMods()
	{
		var enabledMods:Array<String> = [];
		for (mod => enabled in modList)
			if (enabled)
				enabledMods.push(mod);

		trace(enabledMods);
		Polymod.loadOnlyMods(enabledMods);
	}

	public static function setMod(mod:String, enable:Bool)
	{
		if (modList.get(mod) == null)
			return; // cant update an existing mod...
		modList.set(mod, enable);
		saveJson();
		loadMods();
	}
}
#end
