package 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	public class StateManager 
	{
		public static var All:Array = [];
		public var ID:String;
		public var stage:Stage;
		public function StateManager(id:String, _stage:Stage) 
		{
			ID = id;
			stage = _stage;
			if (All.indexOf(id) == -1) All.push(ID, this); else throw new Error("State '".concat(ID, "' already exists."));
		}
		
		public function Activate(state_id:String):void
		{
			var i:* = State.Get(state_id);
			if (i)
			{
				(i as State).Activated = true;
				stage.addEventListener(Event.EXIT_FRAME, i.EnterFrame);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, i.KeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, i.KeyUp);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, i.MouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, i.MouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, i.MouseMove);
			}
		}
		
		public function Deactivate(state_id:String):void
		{
			var i:* = State.Get(state_id);
			if (i)
			{
				(i as State).Activated = false;
				stage.removeEventListener(Event.EXIT_FRAME, i.EnterFrame);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, i.KeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, i.KeyUp);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, i.MouseDown);
				stage.removeEventListener(MouseEvent.MOUSE_UP, i.MouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, i.MouseMove);
				
			}
		}
		
		public static function Get(id:String):*
		{
			var i:int = All.indexOf(id);
			if (i > -1)
			return All[i + 1];
		}
	}
}