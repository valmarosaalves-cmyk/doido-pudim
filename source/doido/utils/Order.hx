package doido.utils;

typedef OrderList =
{
	var order:Array<String>;
}

class Order
{
	public static function getOrder(path:String, first:Bool = false):Array<String>
	{
		var list:Array<String> = getList(path);
		#if MODS_FOLDER
		if (first) // mods before base
		{
			var i = Mods.modList.mods.length - 1;
			while (i >= 0)
			{
                var mod = Mods.modList.mods[i];
				if (mod.enabled)
					list = getModList(path, mod.name).concat(list);
				i--;
			}
		}
		else
		{
			for (mod in Mods.modList.mods)
			{
				if (mod.enabled)
					list = list.concat(getModList(path, mod.name));
			}
		}
		#end
		return list;
	}

	public static function getList(path:String):Array<String>
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
		return order.order;
	}

	#if MODS_FOLDER
	// to-do: list folder
	public static function getModList(path:String, mod:String):Array<String>
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
		return order.order;
	}
	#end
}
