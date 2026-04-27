package doido.utils;

import flixel.math.FlxMath;

typedef OrderList =
{
	var order:Array<String>;
	var ?index:Int;
}

class Order
{
	public static function getOrder(path:String, first:Bool = false):Array<String>
	{
		var list:Array<String> = getList(path).order;
		#if MODS_FOLDER
		var lenght = list.length;
		var mods:Array<OrderList> = [];
		for (mod in Mods.modList.mods)
		{
			if (!mod.enabled)
				continue;

			var newList = getModList(path, mod.name);
			newList.index = newList.index ?? (first ? 0 : lenght);
			mods.push(newList);
		}

		mods.sort((a, b) -> a.index - b.index);
		var offset = 0;
		for (mod in mods)
		{
			var index = mod.index + offset;
			index = FlxMath.wrap(index, 0, lenght);
			list = list.slice(0, index).concat(mod.order).concat(list.slice(index));
		}
		#end
		return list;
	}

	public static function getList(path:String):OrderList
	{
		var order:OrderList = {order: []};
		try
		{
			order = cast Assets.json('$path/order');
		}
		catch (e)
		{
			Logs.print('ORDER LOAD ERROR: $e');
			order.order = Assets.list('$path/', true, ["order"], JSON);
		}
		return order;
	}

	#if MODS_FOLDER
	// to-do: list folder
	public static function getModList(path:String, mod:String):OrderList
	{
		var order:OrderList = {order: []};
		try
		{
			order = cast Mods.getJSON('$path/order', mod);
		}
		catch (e)
		{
			Logs.print('WEEK ORDER LOAD ERROR, on mod ${mod}: $e');
		}
		return order;
	}
	#end
}
