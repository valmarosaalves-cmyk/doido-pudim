package doido.objects.ui.buttons;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxSignal;

typedef ButtonSignal = FlxTypedSignal<Void->Void>;

class DoidoButton extends FlxSprite
{
	public var onUp(default, null):ButtonSignal = new ButtonSignal();
	public var onDown(default, null):ButtonSignal = new ButtonSignal();
	public var onHover(default, null):ButtonSignal = new ButtonSignal();
	public var onOut(default, null):ButtonSignal = new ButtonSignal();
	public var onDisable(default, null):ButtonSignal = new ButtonSignal();

	public var disabled(default, set):Bool;

	public var maxScale:Float = 1.15;
	public var minScale:Float = 0.9;
	public var idleScale:Float = 1;
	public var changeScale:Bool = true;

	private var storedMax:Float = 1;
	private var storedMin:Float = 1;
	private var hovering:Bool = false;
	private var prevPressed:Bool = false;

	public function new(?onUp:Void->Void, ?onDown:Void->Void)
	{
		super();
		this.onUp.add(onUp);
		this.onDown.add(onDown);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var targetScale:Float = idleScale;
		if (!disabled)
		{
			if (FlxG.mouse.overlaps(this, MusicBeat.getTopCamera()) && !prevPressed)
			{
				if (maxScale != 1 || minScale != 1)
					targetScale = FlxG.mouse.pressed ? minScale : maxScale;

				if (FlxG.mouse.justPressed)
					onDown.dispatch();
				if (FlxG.mouse.justReleased)
					onUp.dispatch();
				if (!hovering)
				{
					onHover.dispatch();
					hovering = true;
				}
			}
			else
			{
				if (FlxG.mouse.justPressed)
					prevPressed = true;
				else if (FlxG.mouse.released && prevPressed)
					prevPressed = false;

				if (hovering)
				{
					onOut.dispatch();
					hovering = false;
					prevPressed = true;
				}
			}
		}

		if (changeScale)
			scale.set(FlxMath.lerp(scale.x, targetScale, elapsed * 8), FlxMath.lerp(scale.y, targetScale, elapsed * 8));
	}

	public function set_disabled(b:Bool)
	{
		disabled = b;

		if (disabled)
		{
			storedMax = maxScale;
			storedMin = minScale;
			maxScale = 1;
			minScale = 1;
		}
		else
		{
			maxScale = storedMax;
			minScale = storedMin;
		}

		onDisable.dispatch();
		return b;
	}
}
