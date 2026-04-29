package substates.menus;

#if MODS_FOLDER
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import doido.objects.Alphabet;
import doido.Mods;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

typedef ModOption =
{
	var id:String;
	var name:String;
	var icon:String;
	var ?enabled:Bool;
}

class ModSubState extends MusicBeatSubState
{
	public var bg:FlxSprite;
	public var namesGrp:FlxTypedGroup<ModAlphabet>;
	public var mods:Array<ModOption>;
	public var systemOptions:Array<String> = ["reload list", #if windows "open folder" #end];

	var curSelected:Int = 0;

	public function new()
	{
		super();
		bg = new FlxSprite().makeColor(FlxG.width + 10, FlxG.height + 10, 0xFF000000);
		bg.screenCenter();
		bg.alpha = 0.4;
		add(bg);

		add(namesGrp = new FlxTypedGroup<ModAlphabet>());

		var bottomBar = new FlxSprite().makeColor(FlxG.width + 10, 50, 0xFF000000);
		bottomBar.screenCenter(X);
		bottomBar.y = FlxG.height - bottomBar.height;
		bottomBar.alpha = 0.4;
		add(bottomBar);

		var reorderTxt = new FlxText(8, 8, 0, "HOLD SHIFT TO REORDER MODS");
		reorderTxt.setFormat(Main.globalFont, 36, 0xFFFFFFFF, CENTER);
		reorderTxt.screenCenter(X);
		reorderTxt.y = FlxG.height - reorderTxt.height - 8;
		add(reorderTxt);

		reloadMods();
	}

	public function reloadMods()
	{
		mods = [];
		for (mod in Mods.modList.mods)
		{
			mods.push({
				id: mod.name,
				name: Mods.getTitle(mod.name),
				icon: mod.name,
				enabled: mod.enabled
			});
		}

		for (opt in systemOptions)
		{
			mods.push({
				id: opt,
				name: opt,
				icon: "-",
				enabled: null
			});
		}

		namesGrp.killMembers();
		var i = 0;
		for (mod in mods)
		{
			var name:ModAlphabet = namesGrp.recycle(ModAlphabet);

			name.text = mod.name;
			name.reloadIcon(mod.icon, mod.enabled);
			name.ID = i;

			if (!namesGrp.members.contains(name))
				namesGrp.add(name);
			i++;
		}
		changeSelection();
		updatePos();
	}

	public function updatePos(lerp:Float = 1)
	{
		namesGrp.forEachAlive((alphabet) ->
		{
			var daPos:Int = (alphabet.ID - curSelected);

			var xOffset:Float = Math.pow(3, Math.min(Math.abs(daPos), 3)) * 10;
			var yOffset:Float = (150 * daPos);

			alphabet.setPosition(FlxMath.lerp(alphabet.x, 280 - xOffset, lerp), FlxMath.lerp(alphabet.y, (FlxG.height / 2) - 30 + yOffset, lerp));
		});
	}

	public function changeSelection(?change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Assets.sound("scroll"));

		if (FlxG.keys.pressed.SHIFT && change != 0 && !isSystem)
		{
			Mods.move(curSelected, change);
			reloadMods();
		}

		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, mods.length - 1);

		namesGrp.forEachAlive((alphabet) ->
		{
			if (alphabet.ID == curSelected)
				alphabet.alpha = 1.0;
			else
				alphabet.alpha = 0.4;
		});
	}

	var holdTimer:Float = 0.0;
	var holdMax:Float = 0.5;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.justPressed(BACK))
		{
			FlxG.sound.play(Assets.sound("options/options-close"));
			close();
		}

		var change:Int = (Controls.pressed(UI_DOWN) ? 1 : 0) - (Controls.pressed(UI_UP) ? 1 : 0);
		if (change != 0)
			holdTimer += elapsed;
		else
			holdTimer = 0.0;
		if (Controls.justPressed(UI_UP) || Controls.justPressed(UI_DOWN) || holdTimer >= holdMax)
		{
			changeSelection(change);
			if (holdTimer >= holdMax)
				holdTimer = holdMax - 0.12;
		}

		if (Controls.justPressed(ACCEPT))
			toggleMod();

		updatePos(elapsed * 8);
	}

	public function toggleMod()
	{
		if (isSystem)
		{
			switch (curMod.id)
			{
				case "open folder":
					#if windows
					Sys.command("explorer.exe /n, /e, \"" + Sys.getCwd().substring(0, Sys.getCwd().length - 1) + "\\" + Mods.MOD_ROOT + "\"");
					#end
				case "reload list":
					Mods.scan();
					reloadMods();
					curSelected = mods.length - 2;
					changeSelection();
					updatePos();
			}
		}
		else
		{
			curMod.enabled = !curMod.enabled;
			Mods.setMod(curMod.id, curMod.enabled, true);
			namesGrp.forEachAlive((alphabet) ->
			{
				if (alphabet.ID == curSelected)
					alphabet.checkmark.animation.play(Std.string(curMod.enabled));
			});
		}
	}

	var curMod(get, never):ModOption;
	var isSystem(get, never):Bool;

	function get_curMod():ModOption
		return mods[curSelected];

	function get_isSystem():Bool
		return systemOptions.contains(curMod.id);
}

class ModAlphabet extends Alphabet
{
	public var icon:FlxSprite;
	public var checkmark:FlxSprite;

	public function new()
	{
		super(0, 0, "", true);
		icon = new FlxSprite();

		checkmark = new FlxSprite();
		checkmark.loadSparrow("menu/checkmark");
		checkmark.animation.addByPrefix("false", "false", 24, false);
		checkmark.animation.addByPrefix("true", "true", 24, false);
		checkmark.animation.play("true");
		checkmark.updateHitbox();
	}

	public function reloadIcon(mod:String, ?check:Bool)
	{
		if (check == null)
			checkmark.visible = false;
		else
		{
			checkmark.visible = true;
			checkmark.animation.play(Std.string(check), true, false, checkmark.animation.getByName(Std.string(check)).frames.length - 1);
		}

		if (mod == "-")
		{
			icon.visible = false;
		}
		else
		{
			icon.visible = true;
			icon.loadGraphic(Mods.getIcon(mod));
			icon.scale.set(0.9, 0.9);
			icon.updateHitbox();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (checkmark.visible)
			checkmark.update(elapsed);
	}

	override function draw()
	{
		if (icon.visible)
		{
			icon.alpha = alpha;
			icon.setPosition(x - icon.width - 16, y + (height - icon.height) / 2);
			icon.draw();
		}
		if (checkmark.visible)
		{
			checkmark.alpha = alpha;
			checkmark.setPosition(x + width + 16, y + ((height - checkmark.height) / 2) - 14);
			checkmark.draw();
		}
		super.draw();
	}
}
#end
