package states.menus;

import objects.Character;
import doido.song.Highscore;
import doido.song.Highscore.ScoreData;
import doido.song.Week;
import doido.objects.DoidoSprite;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxStringUtil;

class StoryMenuState extends MusicBeatState
{
	var weekList:Array<WeekData> = [];
	var curWeek:Int = 0;
	var curDiff:Int = 0;

	var grpChars:FlxTypedGroup<StoryChar>;
	var grpWeeks:FlxTypedGroup<FlxSprite>;
	var diffSelector:DiffSelector;

	var trackTxt:FlxText;
	var weekNameTxt:FlxText;
	var weekScoreTxt:FlxText;

	// var resetTxt:FlxText;

	override function create()
	{
		super.create();
		DiscordIO.changePresence("In the Story Menu");

		weekList = Week.weekList(true, false);
		trace(weekList);

		grpWeeks = new FlxTypedGroup<FlxSprite>();
		add(grpWeeks);

		for (i in 0...weekList.length)
		{
			var weekSpr = new FlxSprite().loadImage('menu/story/week/${weekList[i].weekFile}');
			weekSpr.ID = i;
			weekSpr.screenCenter(X);
			grpWeeks.add(weekSpr);
		}
		updateWeekPos(1);

		var blackMf = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, 60, 0xFF000000);
		blackMf.screenCenter(X);
		add(blackMf);

		var yellowMf = new FlxSprite(0, 50).makeGraphic(FlxG.width * 2, 392, 0xFFF9CF51);
		yellowMf.screenCenter(X);
		add(yellowMf);

		weekScoreTxt = new FlxText(8, 8, 0, "");
		weekScoreTxt.setFormat(Main.globalFont, 36, 0xFFFFFFFF, LEFT);
		add(weekScoreTxt);

		weekNameTxt = new FlxText(8, 8, 0, "");
		weekNameTxt.setFormat(Main.globalFont, 36, 0xFFFFFFFF, RIGHT);
		weekNameTxt.alpha = 0.8;
		add(weekNameTxt);

		var trackTitle = new FlxText(0, 0, 0, "TRACKS");
		trackTitle.setFormat(Main.globalFont, 48, 0xFFE55777, CENTER);
		trackTitle.setPosition(200 - trackTitle.width / 2, yellowMf.y + yellowMf.height + 20);
		add(trackTitle);

		trackTxt = new FlxText(0, 0, 0, "what the hell");
		trackTxt.setFormat(Main.globalFont, 36, 0xFFE55777, CENTER);
		trackTxt.y = (trackTitle.y + trackTitle.height + 12);
		add(trackTxt);

		diffSelector = new DiffSelector();
		diffSelector.diffPos.y = yellowMf.y + yellowMf.height + 30; // 20
		diffSelector.diffPos.x = (FlxG.width - 200);
		diffSelector.updateHitbox();
		add(diffSelector);

		grpChars = new FlxTypedGroup<StoryChar>();
		add(grpChars);

		var posits:Array<StoryCharPos> = [DAD, BF, GF];
		for (i in 0...posits.length)
		{
			var char = new StoryChar(posits[i]);
			char.ID = i;
			grpChars.add(char);
		}

		changeWeek();
	}

	public function updateWeekPos(lerp:Float = 0)
	{
		for (week in grpWeeks.members)
			week.y = FlxMath.lerp(week.y, 402 + 60 + (week.ID - curWeek) * 120, lerp);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateWeekPos(elapsed * 12);

		if (Controls.justPressed(UI_UP))
			changeWeek(-1);
		if (Controls.justPressed(UI_DOWN))
			changeWeek(1);
		if (Controls.justPressed(UI_LEFT))
			changeDiff(-1);
		if (Controls.justPressed(UI_RIGHT))
			changeDiff(1);

		if (Controls.justPressed(BACK))
			MusicBeat.switchState(new states.DebugMenu());

		var animL:String = "idle";
		if (Controls.pressed(UI_LEFT))
			animL = "push";

		var animR:String = "idle";
		if (Controls.pressed(UI_RIGHT))
			animR = "push";

		diffSelector.arrowL.animation.play(animL);
		diffSelector.arrowR.animation.play(animR);

		if (Controls.justPressed(ACCEPT))
		{
			try
			{
				PlayState.loadWeek(week, diff);
				MusicBeat.switchState(new states.LoadingState());
			}
			catch (e)
			{
				FlxG.sound.play(Assets.sound('beep'));
				Logs.print(e);
			}
		}
	}

	public function changeWeek(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Assets.sound('scroll'));

		curWeek += change;
		curWeek = FlxMath.wrap(curWeek, 0, weekList.length - 1);

		for (week in grpWeeks.members)
		{
			week.alpha = 0.4;
			if (week.ID == curWeek)
				week.alpha = 1;
		}

		for (char in grpChars.members)
		{
			char.visible = true;
			if (week.chars[char.ID] == "")
				char.visible = false;
			else if (week.chars[char.ID] != char.curChar)
				char.reloadChar(week.chars[char.ID]);
		}

		trackTxt.text = "";
		for (song in week.songs)
			trackTxt.text += song.song.toUpperCase() + '\n';
		trackTxt.x = 200 - (trackTxt.width / 2);

		weekNameTxt.text = week.weekName.toUpperCase();
		weekNameTxt.x = FlxG.width - weekNameTxt.width - 8;

		changeDiff();
	}

	public function changeDiff(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Assets.sound('scroll'));

		curDiff += change;
		curDiff = FlxMath.wrap(curDiff, 0, week.storyDiffs.length - 1);
		diffSelector.changeDiff(diff);

		var score:Float = Highscore.getScore('week-${week.weekFile}-$diff').score;
		weekScoreTxt.text = "WEEK SCORE: " + FlxStringUtil.formatMoney(Math.floor(score), false, true);
	}

	var week(get, never):WeekData;
	var diff(get, never):String;

	function get_week():WeekData
		return weekList[curWeek] ?? Week.defaultWeek();

	function get_diff():String
		return week.storyDiffs[curDiff] ?? 'normal';
}

enum StoryCharPos
{
	DAD;
	BF;
	GF;
}

// PLACEHOLDERS!!!!
class StoryChar extends Character
{
	public var position:StoryCharPos = BF;
	public var initialized:Bool = false;

	public function new(position:StoryCharPos)
	{
		super("", false);
		this.position = position;
		this.dataPath = "data/storychars/";
		this.spritePath = "menu/story/chars/";
		initialized = true;
	}

	public function reloadChar(curChar:String = "bf")
	{
		if (curChar == this.curChar)
			return;

		this.curChar = curChar;
		loadCharacter(false);
		updateHitbox();
	}

	override public function loadCharacter(reload:Bool = false)
	{
		if (initialized)
			super.loadCharacter(reload);
	}

	override function updateHitbox()
	{
		super.updateHitbox();

		x = switch (position)
		{
			case DAD:
				x = 100;
			case GF:
				x = FlxG.width - width - 100;
			default:
				x = FlxG.width / 2 - width / 2;
		};
		y = 50 + (392 / 2) - (height / 2);

		x += globalOffset.x;
		y += globalOffset.y;
	}
}

class DiffSelector extends FlxGroup
{
	public var arrowL:FlxSprite;
	public var diffSpr:FlxSprite;
	public var arrowR:FlxSprite;

	public var diffPos:FlxPoint = new FlxPoint();

	public function new()
	{
		super();
		arrowL = new FlxSprite();
		arrowL.frames = Assets.sparrow("menu/menuArrows");
		arrowL.animation.addByPrefix("idle", "arrow left", 0, false);
		arrowL.animation.addByPrefix("push", "arrow push left", 0, false);
		arrowL.scale.set(0.8, 0.8);
		arrowL.updateHitbox();
		arrowL.animation.play("idle");

		arrowR = new FlxSprite();
		arrowR.frames = Assets.sparrow("menu/menuArrows");
		arrowR.animation.addByPrefix("idle", "arrow right", 0, false);
		arrowR.animation.addByPrefix("push", "arrow push right", 0, false);
		arrowR.scale.set(0.8, 0.8);
		arrowR.updateHitbox();
		arrowR.animation.play("idle");

		add(arrowL);
		add(arrowR);

		diffSpr = new FlxSprite();
		add(diffSpr);

		changeDiff();
	}

	public var curDiff:String = "";

	var tweenShit:FlxTween;

	public function changeDiff(diff:String = "")
	{
		if (curDiff == diff)
			return;
		curDiff = diff;

		remove(diffSpr);

		diffSpr.loadGraphic(Assets.image("menu/story/diff/" + diff.toLowerCase()));

		add(diffSpr);
		updateHitbox();

		if (tweenShit != null)
			tweenShit.cancel();

		// lol
		diffSpr.y -= 20;
		diffSpr.alpha = 0;
		tweenShit = FlxTween.tween(diffSpr, {y: diffSpr.y + 20, alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
	}

	public function updateHitbox()
	{
		diffSpr.y = diffPos.y;
		diffSpr.x = (diffPos.x - (diffSpr.width / 2));
		arrowL.x = diffSpr.x - arrowL.width - 2;
		arrowR.x = diffSpr.x + diffSpr.width + 2;

		// align it
		arrowL.y = (diffSpr.y + diffSpr.height / 2 - arrowL.height / 2);
		arrowR.y = arrowL.y;
	}
}
