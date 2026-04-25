package states;

import hscript.iris.Iris;

using doido.utils.ScriptUtil;

class ScriptedState extends MusicBeatState
{
	public var script:String = "";
	public var loadedScript:Iris = null;

	public function new(script:String = "")
	{
		super();
		this.script = script;
		initScript();
	}

	public function initScript()
	{
		var path = 'data/states/$script';
		loadedScript = new Iris(Assets.getAsset(path, SCRIPT), this, {name: path, autoRun: false, autoPreset: true});
		loadedScript.setDefaults();
		loadedScript.execute();
		callScript("new");
	}

	override function create()
	{
		super.create();
		callScript("create");
	}

	override function update(elapsed:Float)
	{
		callScript("update", [elapsed]);
		super.update(elapsed);
	}

	override function stepHit()
	{
		super.stepHit();
		callScript("stepHit", [curStep]);
	}

	override function beatHit()
	{
		super.beatHit();
		callScript("beatHit", [curBeat]);
	}

	override function destroy()
	{
		callScript("destroy");
		super.destroy();
	}

	public function callScript(fun:String, ?args:Array<Dynamic>)
	{
		if (loadedScript == null)
			return;
		@:privateAccess {
			var ny:Dynamic = loadedScript.interp.variables.get(fun);
			try
			{
				if (ny != null && Reflect.isFunction(ny))
					loadedScript.call(fun, args);
			}
			catch (e)
			{
				Logs.print('error parsing state script: ' + e, ERROR);
			}
		}
	}

	// ???
	override function resetState()
	{
		MusicBeat.skipTrans = true;
		MusicBeat.skipClearCache = (!FlxG.keys.pressed.SHIFT);
		MusicBeat.switchState(new ScriptedState(script));
	}
}
