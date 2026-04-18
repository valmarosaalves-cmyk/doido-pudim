package doido.utils;

import flixel.FlxBasic;
import flixel.util.FlxSort;

// does this suck?
class ZIndex
{
	public static var zMap:Map<FlxBasic, Int> = new Map<FlxBasic, Int>();

	public static inline function getZ(bas:FlxBasic):Int
	{
		if (bas == null)
			return 0;

		return zMap.get(bas) ?? 0;
	}

	public static inline function setZ(bas:FlxBasic, val:Int):Void
	{
		if (bas == null)
			return;

		zMap.set(bas, val);
	}

	public static inline function removeZ(bas:FlxBasic)
	{
		if (bas == null)
			return;

		zMap.remove(bas);
	}

	public static inline function sort(a:Int, bas1:FlxBasic, bas2:FlxBasic):Int
		return FlxSort.byValues(a, getZ(bas1) ?? 0, getZ(bas2) ?? 0);

	public static inline function sortAscending(bas1:FlxBasic, bas2:FlxBasic):Int
		return sort(-1, bas1, bas2);

	public static inline function sortDescending(bas1:FlxBasic, bas2:FlxBasic):Int
		return sort(1, bas1, bas2);
}
