package states.menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import doido.objects.Alphabet;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

typedef CreditData =
{
	var name:String;
	var icon:String;
	var color:FlxColor;
	var info:String;
	var ?link:String;
}

class CreditsState extends MusicBeatState
{
	// use this to toggle on icons instead of chars for the credits!
	final classic:Bool = FlxG.random.bool(1);

	public var creditList:Array<CreditData> = [];
	public var curSelected:Int = 0;

	// ANGLE STUFF
	public var rawSelected:Int = 0;
	public var lerpSelected:Float = 0;
	public var angleStep:Float = 360;

	public var bg:FlxSprite;
	public var creditGuys:FlxTypedGroup<CreditChar>;
	public var txtBG:FlxSprite;
	public var nameTxt:Alphabet;
	public var descTxt:Alphabet;

	public var leaving:Bool = false;
	public var holdTimer:Float = 0.0;
	public var holdMax:Float = 0.55;

	var astraEasterEgg:Bool = false;

	function addCredit(name:String, icon:String = "", color:FlxColor, info:String = "", ?link:String)
	{
		creditList.push({
			name: name,
			icon: icon,
			color: color,
			info: info,
			link: link,
		});
	}

	override function create()
	{
		super.create();
		final specialPeople = 'Anakim, ArturYoshi, BeastlyChip, Bnyu, Pi3tr0, Raphalitos, ZieroSama';
		final specialCoders = 'ShadzXD, pisayesiwsi, Lasystuff, Gazozoz, Joalor64GH, LeonGamerPS1';
		// yes, this implies coders aren't people :D

		// btw you dont need to credit everyone here on your mod
		// just credit doido engine as a whole and we're good
		addCredit('DiogoTV', 'diogotv', 0xFF624998, "Doido Engine's Owner and Main Coder", 'https://bsky.app/profile/diogotv.bsky.social');
		addCredit('teles', 'teles', 0xFFFF95AC, "Doido Engine's Co-Owner and Additional Coder", 'https://youtube.com/@telesfnf');
		addCredit('GoldenFoxy', 'anna', 0xFFFFE100, "Main designer of Doido Engine's chart editor", 'https://bsky.app/profile/goldenfoxy.bsky.social');
		addCredit('yoisabo', 'yoisabo', 0xFFAE314A, "Main artist and designer of Doido Engine's chart editor", 'https://bsky.app/profile/yoisabo.bsky.social');
		addCredit('doubleonikoo', 'nikoo', 0xFF624998, "Doido Engine's credits sprite artist", 'https://bsky.app/profile/doubleonikoo.bsky.social');
		addCredit('UTAstra', 'astra', 0xFFCE7299, "Coding help on Doido Engine", "https://x.com/utastra");
		addCredit('JulianoBeta', 'juyko', 0xFF0BA5FF, "Composed Doido Engine's offset menu music", 'https://www.youtube.com/@prodjuyko');
		addCredit('crowplexus', 'crowplexus', 0xFF313538, "Creator of HScript Iris", 'https://github.com/crowplexus/hscript-iris');
		addCredit('mochoco', 'mochoco', 0xFFFBFFA7, "Doido Engine's Mobile Button Artist", 'https://x.com/mochocofrappe');
		addCredit('Github Contributors', 'github', 0xFFFFFFFF, 'THANKS TO:\n${specialCoders}\nfor helping out doido engine!!', 'https://github.com/DoidoTeam/FNF-Doido-Engine/graphs/contributors');
		addCredit('Special Thanks', 'heart', 0xFFAE314A, 'THANK YOU:\n${specialPeople}!!\nfor being cool friends <33', "https://youtu.be/N0IkgKHdgIc");
		
		/*
		*	Don't modify the rest of the code unless you know what you're doing!!
		*/
		persistentUpdate = true;
		DiscordIO.changePresence("Credits - Thanks!!");
		MusicBeat.playMusic("girlfriendsRingtone");

		bg = new FlxSprite().loadGraphic(Assets.image('menuDesat'));
		bg.alpha = 0.6;
		bg.screenCenter();
		add(bg);

		add(creditGuys = new FlxTypedGroup<CreditChar>());

		txtBG = new FlxSprite().loadImage('credits/text-bg');
		txtBG.alpha = 0.5;
		add(txtBG);

		nameTxt = new Alphabet(FlxG.width / 2, 500, "A", true, CENTER);
		add(nameTxt);

		descTxt = new Alphabet(FlxG.width / 2, nameTxt.y + nameTxt.height + 10, "B", false, CENTER);
		descTxt.scale.set(0.5, 0.5);
		descTxt.updateHitbox();
		add(descTxt);

		angleStep = (360 / creditList.length);
		for (i in 0...creditList.length)
		{
			var newChar = new CreditChar(creditList[i].icon, classic);
			newChar.ID = i;
			creditGuys.add(newChar);
		}
		changeSelection();
	}

	override function closeSubState()
	{
		super.closeSubState();
		MusicBeat.activateTimers(true);
	}

	var elapsedTime:Float = 0.0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		persistentUpdate = true;
		if (!leaving)
		{
			var change:Int = (Controls.pressed(UI_RIGHT) ? 1 : 0) - (Controls.pressed(UI_LEFT) ? 1 : 0);
			if (change != 0)
				holdTimer += elapsed;
			else
				holdTimer = 0.0;

			if (Controls.justPressed(UI_LEFT) || Controls.justPressed(UI_RIGHT) || holdTimer >= holdMax)
			{
				changeSelection(change);
				if (holdTimer >= holdMax)
					holdTimer = holdMax - 0.12;
			}
			if (Controls.justPressed(ACCEPT))
			{
				if (!astraEasterEgg)
				{
					persistentUpdate = false;
					var url = creditList[curSelected].link;
					if (url != null && url.length > 0)
					{
						MusicBeat.activateTimers(false);
						MusicBeat.openURL(url);
					}
				}
				else
				{
					astraEasterEgg = false;
					var chosenOne = FlxG.random.getObject(["lilith", "pearto", "two"]);
					var jumpscare = new FlxSprite().loadImage('credits/astra-eastereggs/$chosenOne');
					jumpscare.setGraphicSize(500, 500);
					jumpscare.updateHitbox();
					jumpscare.screenCenter();
					add(jumpscare);

					FlxG.sound.play(Assets.sound("options/ahh"), 0.7);
					var daScale = jumpscare.scale.x;
					jumpscare.scale.set(0, 0);
					FlxTween.tween(jumpscare.scale, {x: daScale, y: daScale}, 0.2)
						.then(FlxTween.tween(jumpscare.scale, {x: daScale * 1.2, y: daScale * 1.2}, 1.0));
					FlxTween.tween(jumpscare, {alpha: 0.0}, 0.2, {
						startDelay: 1.0,
						onComplete: (twn) ->
						{
							FlxTween.completeTweensOf(jumpscare);
							jumpscare.destroy();
						}
					});
				}
			}
			if (Controls.justPressed(BACK))
			{
				leaving = true;
				MusicBeat.switchState(new states.menus.MainMenuState());
			}
		}

		elapsedTime += elapsed;
		lerpSelected = FlxMath.lerp(lerpSelected, rawSelected, elapsed * 4);
		for (char in creditGuys.members)
		{
			var daAngle = FlxAngle.asRadians((char.ID - lerpSelected) * angleStep);

			var rawScale:Float = 0.8 + Math.cos(daAngle) * 0.2;
			char.shadowBaseY = rawScale;
			var scaleX:Float = rawScale;
			var scaleY:Float = rawScale;

			var selected:Bool = (curSelected == char.ID);
			char.selected = selected;

			var whichChar = (classic ? "_classic" : char.curChar);
			switch (whichChar)
			{
				case "nikoo" | "_classic": // nothing

				default:
					if (selected)
					{
						char.selectedScaleElapsed += elapsed * 4;
						char.selectedScaleX = Math.sin(char.selectedScaleElapsed) * 0.12;
						char.selectedScaleY = Math.sin(char.selectedScaleElapsed) * -0.12;
					}
					else
					{
						char.selectedScaleElapsed = 0;
						char.selectedScaleX = FlxMath.lerp(char.selectedScaleX, 0.0, elapsed * 5);
						char.selectedScaleY = FlxMath.lerp(char.selectedScaleY, 0.0, elapsed * 5);
					}
					scaleX += char.selectedScaleX;
					scaleY += char.selectedScaleY;

					if (whichChar == "diogotv")
					{
						if (selected)
							char.angle = Math.sin(char.selectedScaleElapsed * 2) * 8;
						else
							char.angle = FlxMath.lerp(char.angle, 0, elapsed * 6);
					}
			}

			char.color = FlxColor.interpolate(FlxColor.BLACK, FlxColor.WHITE, FlxMath.bound(0.5 + Math.cos(daAngle) * 0.5, 0.4, 1.0));
			char.scale.set(scaleX, scaleY);
			char.updateHitbox();

			switch (whichChar)
			{
				case "nikoo":
					var floorOffset:Float = char.offset.y;

					if (selected && char.nikooCanJump)
					{
						char.nikooCanJump = false;
						var jumpTime:Float = FlxG.random.float(0.3, 0.8);
						FlxTween.tween(char, {
							nikooJumpOffset: -jumpTime * 300,
							angle: 360 * FlxG.random.int(-1, 1),
						}, jumpTime, {
							ease: FlxEase.cubeOut,
							onComplete: (twn) ->
							{
								FlxTween.tween(char, {
									nikooJumpOffset: 0,
								}, jumpTime * 0.7, {
									ease: FlxEase.cubeIn,
									onComplete: (twn) ->
									{
										char.nikooCanJump = true;
										char.angle = 0;
									}
								});
							}
						});
					}

					char.offset.y -= char.nikooJumpOffset * rawScale;
					char.shadowScale = Math.max(0.0, 1.0 - (char.offset.y - floorOffset) / 350);

				case "yoisabo":
					char.offset.y += (80 + Math.sin(elapsedTime) * 20) * rawScale;
					char.shadowScale = 0.8 + Math.sin(elapsedTime) * -0.1;
				case "heart":
					char.offset.y += 60 * rawScale;
					char.angle = Math.sin(elapsedTime * 4) * 8;
				case "_classic":
					var sinTime:Float = (elapsedTime * 2) + FlxAngle.asRadians(char.ID * angleStep);
					char.offset.y += (40 + Math.sin(sinTime) * 20) * rawScale;
					char.shadowScale = 1 + Math.sin(sinTime) * -0.1;
			}

			char.x = ((FlxG.width - char.width) / 2) + Math.sin(daAngle) * 400;
			char.y = (nameTxt.y - 160 - char.height) + Math.cos(daAngle) * 80;
			char.setZ(Math.floor(char.y + char.height));
		}
		creditGuys.sort(ZIndex.sort);
	}

	public function changeSelection(?change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Assets.sound("scroll"));

		rawSelected += change;
		curSelected += change;
		if (curSelected < 0)
			curSelected = creditList.length - 1;
		if (curSelected > creditList.length - 1)
			curSelected = 0;

		var curCredit = creditList[curSelected];
		nameTxt.text = curCredit.name;
		descTxt.text = '<color value=#FFFFFF>${curCredit.info}</color>';
		txtBG.setGraphicSize(
			Math.max(nameTxt.width, descTxt.width) + 80,
			(descTxt.y + descTxt.height) - nameTxt.y + 48
		);
		txtBG.updateHitbox();
		txtBG.y = nameTxt.y - 20;

		for(item in [nameTxt, descTxt, txtBG])
		{
			if (Std.isOfType(item, Alphabet))
				item.x = FlxG.width / 2;
			else
				item.screenCenter(X);
			
			item.x += change * 60;
			FlxTween.cancelTweensOf(item);
			FlxTween.tween(item, {x: item.x - change * 60}, 0.4, {ease: FlxEase.cubeOut});
		}

		FlxTween.cancelTweensOf(bg);
		FlxTween.color(bg, 0.4, bg.color, curCredit.color);

		astraEasterEgg = (curCredit.icon == "astra");
	}
}

class CreditChar extends FlxSprite
{
	public var outline:FlxSprite;
	public var shadow:FlxSprite;
	public var shadowScale:Float = 1.0;
	public var shadowBaseY:Float = 1.0;

	public var curChar:String = "";

	public var selected:Bool = false;
	public var selectedScaleElapsed:Float = 0.0;
	public var selectedScaleX:Float = 0.0;
	public var selectedScaleY:Float = 0.0;
	
	public var nikooJumpOffset:Float = 0.0;
	public var nikooCanJump:Bool = true;

	public function new(curChar:String, classic:Bool = false)
	{
		super();
		this.curChar = curChar;
		shadow = new FlxSprite();
		shadow.loadImage("credits/shadow");

		var path:String = 'credits/' + (classic ? "icons" : "char");
		switch (curChar)
		{
			default:
				if (Assets.fileExists('images/$path/$curChar', IMAGE))
					this.loadImage('$path/$curChar');
				else
					this.loadImage('$path/null');
		}
		
		outline = new FlxSprite();
		outline.loadGraphic(graphic);
		outline.setColorTransform(0, 0, 0, 1, 255, 255, 255, 0);
	}

	override function draw()
	{
		shadow.alpha = 0.4 * Math.min(shadowScale, 1.0);
		shadow.scale.set(width / shadow.frameWidth * shadowScale, shadowBaseY * shadowScale);
		shadow.updateHitbox();
		shadow.setPosition(x + (width - shadow.width) / 2, y + height - (shadow.height / 2));
		shadow.draw();

		if (curChar == "diogotv")
			origin.set(width / 2, height);

		if (selected)
		{
			var segments:Int = 16;
			var step:Float = (Math.PI * 2) / segments;
			var thickness:Float = 6;

			for (i in 0...segments)
			{
				var angle:Float = i * step;
				outline.setPosition(
					x + Math.cos(angle) * thickness,
					y + Math.sin(angle) * thickness
				);
				outline.origin.set(origin.x, origin.y);
				outline.scale.set(scale.x, scale.y);
				outline.offset.set(offset.x, offset.y);
				outline.angle = this.angle;
				outline.draw();
			}
		}

		super.draw();
	}
}
