package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	public class Main extends Sprite 
	{
		public function Main() 
		{
			if (stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		private function Init(E:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			var graph:GraphArray = new GraphArray;
			
			graph.Relate("chad", "husband", "susan", "wife")
			graph.Delete("chad");
			graph.CollectGarbage();
			trace(graph.AddGet("susan")[1][2]);
		}
	}
}