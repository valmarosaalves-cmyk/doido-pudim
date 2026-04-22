package doido.objects.ui.buttons;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;

class DoidoTextButton extends FlxSpriteGroup
{
	public var button:DoidoAnimatedButton;
	public var label:FlxBitmapText;

	public var text(default, set):String;
	public var textScale:Float = 0.625;

	public function new(text:String = "", sprite:String = "big", ?onUp:Void->Void, ?onDown:Void->Void)
	{
		super();
		@:bypassAccessor this.text = text;

		button = new DoidoAnimatedButton('editors/charting/button_$sprite', 'button$sprite', onUp, onDown);
		add(button);

		label = new FlxBitmapText(0, 0, Assets.bitmapFont("phantommuff"));
		label.color = 0xFF000000;
		label.alignment = CENTER;
		label.text = text;
		add(label);
		updateText();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!button.disabled)
			updateText();
	}

	public function updateText()
	{
		var targetScale = textScale * button.scale.x;
		if (label.scale.x != targetScale)
		{
			label.scale.set(targetScale, targetScale);
			label.updateHitbox();
		}

		label.x = button.x + (button.width / 2) - (label.width / 2);
		label.y = button.y + (button.height / 2) - (label.height / 2);
	}

	public function set_text(v:String)
	{
		text = v;
		label.text = text;
		updateText();
		return text;
	}
}
