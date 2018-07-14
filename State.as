package
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	public class State
	{
		public static const ENTER_FRAME:String = "EnterFrame";
		public static const EXIT_FRAME :String = "ExitFrame";
		public static const KEY_DOWN   :String = "KeyDown";
		public static const KEY_UP     :String = "KeyUp";
		public static const MOUSE_DOWN :String = "MouseDown";
		public static const MOUSE_UP   :String = "MouseUp";
		public static const MOUSE_MOVE :String = "MouseMove";
		public static var All:Array = [];
		public var ID:String;
		public var Manager:StateManager;
		public var Activated:Boolean;
		//'Events' and 'Tasks' both feature two header variables which track amount of garbage and the threshold
		//at which that garbage will be collected.
		public var Events:Array = [0, int.MAX_VALUE];
		public var EventBuffer:Array = [];
		public var Tasks:Array = [0, int.MAX_VALUE];
		public var Utilities:Scratchpad = Scratchpad.This;
		//auxilliary information about tasks.
		private var TaskLookup:Array = [];
		//initialize with a unique id and link to a manager. Throws an error if A) the referenced manager doesn't
		//exist, or B) a state already exists with supplied name.
		public function State(id:String, manager_id:String)
		{
			ID = id;
			//gets manager, checks manager, throw error or continue.
			var i:* = StateManager.Get(manager_id);
			if (i) Manager = i;
			else throw new Error("StateManager '".concat(manager_id, "' does not exist."));
			//check state id.
			i = All.indexOf(ID);
			if (i < 0) All.push(ID, this);
			else throw new Error("State '".concat(ID, "' already exists."));
		}
		
		public function Activate():void  { Manager.Activate(ID); }
		
		public function Deactivate():void  { Manager.Deactivate(ID); }
		//the buffering option allows a paused event to be suspended until unpaused.
		public function AddEvent(events_id:String, buffering:Boolean = false):void  { if (Events.indexOf(events_id) == -1) Events.push(events_id, false, buffering, []); }
		
		public function RemoveEvent(events_id:String):void
		{
			var i:int = Events.indexOf(events_id);
			if (i > -1)
			{
				Events[i] = undefined;
				Events[i + 1] = undefined;
				Events[i + 2] = undefined;
				Events[i + 3] = undefined;
				Events[0] += 4;
			}
		}
		
		public function AddListener(events_id:String, funct:Function):void
		{
			var i:int = Events.indexOf(events_id);
			if (i > -1) Events[i + 3].push(funct);
		}
		//increment litter.
		public function RemoveListener(event_id:String, funct:Function):void
		{
			var i:int = Events.indexOf(event_id);
			if (i > -1)
			{
				var j:int = Events[i + 3].indexOf(funct);
				if (j > -1) Events[i + 3][j] = undefined;
				Events[0]++;
			}
		}
		
		public function PauseEvent(event_id:String):void
		{
			var i:int = Events.indexOf(event_id);
			if (i > -1) Events[i + 1] = true;
		}
		
		public function UnpauseEvent(event_id:String):void
		{
			var i:int = Events.indexOf(event_id);
			if (i > -1) Events[i + 1] = false;
		}
		
		public function EventPaused(event_id:String):Boolean
		{
			var i:int = Events.indexOf(event_id);
			if (i > -1)
			return Events[i + 1];
			return false;
		}
		
		public function InvokeEvent(event_id:String, ...params:Array):*
		{
			var i:int = Events.indexOf(event_id);
			var Position:int;
			var Length:int;
			var ArrayReturn:Array = [];
			var TempAny:*;
			if (i > -1)
			{
				if (!Events[i + 1])
				{
					Length = Events[i + 3].length;
					while (Position < Length)
					{
						if (Events[i + 3][Position] != undefined)
						{
							TempAny = Events[i + 3][Position].apply(null, params);
							if (TempAny)
							{
								ArrayReturn.push(TempAny);
							}
						}
						Position++;
					}
				}
				else if (Events[i + 2]) EventBuffer.push(event_id, params);
			}
			i = ArrayReturn.length;
			if (i > 1)
			return ArrayReturn;
			return ArrayReturn[0];
		}
		//rational order values begin at 2 so i adjust the given value by +2.
		public function AddTask(funct:Function, order:int, rate:int):void
		{
			if (TaskLookup.indexOf(funct) < 0) 
			{
				if (Tasks[order + 2] == undefined) Tasks[order + 2] = [];
				Tasks[order + 2].push(funct, rate, rate);
				TaskLookup.push(funct, order);
			}
		}
		
		public function RemoveTask(funct:Function):void
		{
			//check that funct exists.
			var i:int = TaskLookup.indexOf(funct);
			var order:int;
			if (i > -1)
			{
				//get layer from tasklookup.
				order = TaskLookup[i + 1]; 
				//delete everything.
				TaskLookup[i] = undefined;
				TaskLookup[i + 1] = undefined;
				Tasks[order][i] = undefined;
				Tasks[order][i + 1] = undefined;
				Tasks[order][i + 2] = undefined;
				//increment litter.
				Tasks[0] += 5;
			}
		}
		
		public function EditTask(funct:Function, new_order:int, new_rate:int):void
		{
			RemoveTask(funct);
			AddTask(funct, new_order, new_rate);
		}
		
		public function get EventLitter():int  { return Events[0]; }
		
		public function get EventLitterThreshold():int { return Events[1]; }
		
		public function set EventLitterThreshold(i:int):void { Events[1] = i; }
		
		public function get TaskLitter():int  { return Tasks[0]; }
		
		public function get TaskLitterThreshold():int { return Tasks[1]; }
		
		public function set TaskLitterThreshold(i:int):void { Tasks[1] = i; }
		
		public function CollectGarbageTasks():void
		{
			Tasks = Utilities.CollectGarbage(Tasks);
			TaskLookup = Utilities.CollectGarbage(TaskLookup);
			Tasks[0] = 0;
		}
		
		public function CollectGarbageEvents():void
		{
			Events = Utilities.CollectGarbage(Events);
			EventBuffer = Utilities.CollectGarbage(EventBuffer);
			Events[0] = 0;
		}
		
		public function KeyDown(E:KeyboardEvent):void  { InvokeEvent("KeyDown", E.keyCode, E.shiftKey, E.altKey); }
		
		public function KeyUp(E:KeyboardEvent):void  { InvokeEvent("KeyUp", E.keyCode, E.shiftKey, E.altKey); }
		
		public function MouseDown(E:MouseEvent):void  { InvokeEvent("MouseDown", E.shiftKey, E.altKey); }
		
		public function MouseUp(E:MouseEvent):void  { InvokeEvent("MouseUp", E.shiftKey, E.altKey); }
		
		public function MouseMove(E:MouseEvent):void  { InvokeEvent("MouseMove", E.shiftKey, E.altKey); }
		
		public function EnterFrame(E:Event):void
		{
			InvokeEvent(ENTER_FRAME);
			//check litter or garbage collect.
			if (Events[0] >= Events[1]) CollectGarbageEvents();
			var TaskPosition:int;
			var TaskLength:int = EventBuffer.length;
			while (TaskPosition < TaskLength)
			{
				if (EventBuffer[TaskPosition] != undefined)
				{
					if (!EventPaused(EventBuffer[TaskPosition]))
					{
						EventBuffer[TaskPosition + 1].unshift(EventBuffer[TaskPosition]);
						InvokeEvent.apply(null, EventBuffer[TaskPosition + 1]);
						EventBuffer[TaskPosition] = undefined;
						EventBuffer[TaskPosition + 1] = undefined;
						Events[0] += 2;
					}
				}
				TaskPosition += 2;
			}
			if (Tasks[0] >= Tasks[1]) CollectGarbageTasks();
			//LayerPosition adjusted to skip litter values.
			var LayerPosition:int = 2;
			var LayerLength:int = Tasks.length;
			while (LayerPosition < LayerLength)
			{
				TaskPosition = 0;
				TaskLength = Tasks[LayerPosition].length;
				while (TaskPosition < TaskLength)
				{
					if (Tasks[LayerPosition][TaskPosition + 2] <= 0)
					{
						Tasks[LayerPosition][TaskPosition]();
						Tasks[LayerPosition][TaskPosition + 2] = Tasks[LayerPosition][TaskPosition + 1];
					}
					else Tasks[LayerPosition][TaskPosition + 2]--;
					TaskPosition += 3;
				}
				LayerPosition++;
			}
			//an exit-stantial event.
			InvokeEvent(EXIT_FRAME);
		}
		
		public static function Get(id:String):*
		{
			var i:int = All.indexOf(id);
			if (i > -1)
			return All[i + 1];
		}
	}
}