package doido;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import haxe.io.Bytes;
#if MODS_FOLDER
import polymod.util.VersionUtil;
import polymod.format.ParseRules;
import polymod.Polymod;
import polymod.PolymodConfig;
import thx.semver.Version;
import sys.io.File;

typedef Mod =
{
	var name:String;
	var enabled:Bool;
}

typedef ModList =
{
	var mods:Array<Mod>;
}

/*
 * This is a very early version of Doido's new Mod API.
 * Please keep in mind a lot of things are not yet implemented
 * and others may break when we change stuff.
 * TO-DO
 * - Mod Settings
 * - Credits
 * - Better Meta
 * - Better Mod Manager
 * - Support for more soft-coded things
 */
class Mods
{
	public static var modList:ModList = {mods: []};
	public static var modMetas:Array<ModMetadata> = [];
	static final API_VERSION:Version = "0.1.0";
	static final ignoredFiles:Array<String> = [
		"assets/data/weeks/order.json",
		"assets/data/credits/order.json",
		"assets/data/credits/doido.json",
		"mods/mods.json"
	];

	public static function init()
	{
		PolymodConfig.modMetadataFile = 'meta.json';
		PolymodConfig.modIconFile = 'icon.png';
		Polymod.init({
			modRoot: "mods",
			dirs: [],
			frameworkParams: {
				coreAssetRedirect: "assets"
			},
			apiVersionRule: VersionUtil.anyPatch(API_VERSION),
			errorCallback: onError,
			parseRules: new ParseRules(), // disables it i hope
			ignoredFiles: ignoredFiles,
			useScriptedClasses: false
		});
		loadJson();
		scan();
	}

	// scans the mods folder for new mods n stuff
	public static function scan()
	{
		modMetas = []; // just to be sure
		modMetas = Polymod.scan({modRoot: "mods"});
		var scanned:Array<String> = [];
		for (meta in modMetas)
		{
			if (!exists(meta.id))
				setMod(meta.id); // just to be safe
			scanned.push(meta.id);
		}

		for (mod in modList.mods)
			if (!scanned.contains(mod.name))
				modList.mods.remove(mod);

		saveJson();
		loadMods();
	}

	public static function loadJson()
	{
		try
		{
			modList = cast haxe.Json.parse(openfl.Assets.getText("mods/mods.json").trim());
		}
		catch (e)
		{
			Logs.print('Error loading Mod List: $e', ERROR);
			modList = {mods: []};
		}
	}

	public static function saveJson()
	{
		var data:String = haxe.Json.stringify(modList, "\t");
		File.saveContent("mods/mods.json", data);
	}

	public static function loadMods()
	{
		var enabledMods:Array<String> = [];
		for (mod in modList.mods)
			if (mod.enabled)
				enabledMods.push(mod.name);
		Polymod.loadOnlyMods(enabledMods);
	}

	public static function getMod(mod:String)
	{
		var index:Int = getIndex(mod);
		return index == -1 ? false : modList.mods[index].enabled;
	}

	public static function setMod(mod:String, ?enable:Bool, save:Bool = false)
	{
		var index:Int = getIndex(mod);

		if (index == -1)
			addMod(mod);
		else
			modList.mods[index].enabled = enable ?? modList.mods[index].enabled;

		if (save)
		{
			saveJson();
			loadMods();
		}
	}

	// unsafe, dont use
	public static function addMod(mod:String)
	{
		modList.mods.push({
			name: mod,
			enabled: true
		});
	}

	public static function getIndex(mod:String)
	{
		for (i in 0...modList.mods.length)
			if (mod == modList.mods[i].name)
				return i;

		return -1;
	}

	public static function exists(mod:String)
		return getIndex(mod) >= 0;

	public static function move(index:Int, offset:Int)
	{
		// check if its in bounds
		if (index + offset >= modList.mods.length || index + offset < 0)
			return;

		trace("um");

		var temp = modList.mods[index];
		modList.mods[index] = modList.mods[index + offset];
		modList.mods[index + offset] = temp;
		saveJson();
		loadMods();
	}

	static var skippedErrors:Array<PolymodErrorType> = [NOTICE];

	public static function onError(err:PolymodError):Void
	{
		if (skippedErrors.contains(err.severity))
			return;

		Logs.print('Polymod.${(cast err.origin).toUpperCase()} | ${err.message}', POLYMOD, true, true, false);
	}

	public static function getIcon(mod:String)
	{
		var icon:Bytes = null;
		for (meta in modMetas)
		{
			if (meta.id == mod)
			{
				icon = meta.icon;
				break;
			}
		}

		if(icon == null)
			return Assets.image("icon");
		else
			return FlxGraphic.fromBitmapData(BitmapData.fromBytes(icon));
	}

	public static function getJSON(key:String, mod:String):Dynamic
		return haxe.Json.parse(Polymod.getFileSystem().getFileContent(getPath('$key.json', mod)).trim());

	public static inline function getPath(key:String, mod:String):String
		return 'mods/$mod/$key';
}
#end
