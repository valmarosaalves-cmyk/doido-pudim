package doido.utils;

import hscript.iris.Iris;
import flixel.text.FlxText.FlxTextAlign;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

// Some manual fixes for abstracts n stuff

class ScriptedTextAlign
{
	public static var LEFT = FlxTextAlign.LEFT;
	public static var CENTER = FlxTextAlign.CENTER;
	public static var RIGHT = FlxTextAlign.RIGHT;
	public static var JUSTIFY = FlxTextAlign.JUSTIFY;
}

class ScriptedAxes
{
	public static var X = 1;
	public static var Y = 2;
	public static var XY = 3;
	public static var NONE = 0;
}

class ScriptUtil
{
	public static function setDefaults(script:Iris)
	{
		// import.hx
		script.set("FlxG", FlxG);
		script.set("Assets", Assets);
		script.set("Paths", Assets);
		script.set("Controls", Controls);
		script.set("MusicBeat", MusicBeat);
		script.set("Save", Save);
		script.set("Logs", Logs);
		script.set("MathUtil", MathUtil);
		script.set("ZIndex", ZIndex);

		// abstracts
		script.set("FlxTextBorderStyle", flixel.text.FlxText.FlxTextBorderStyle);
		script.set("FlxTextAlign", ScriptedTextAlign);
		script.set("FlxAxes", ScriptedAxes);

		// extras
		script.set("FlxSprite", FlxSprite);
		script.set("FlxGroup", FlxGroup);
	}
}
