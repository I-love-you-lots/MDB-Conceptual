package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	//This class is easy to understand if you study the State class.
	public class DisplayList extends State
	{
		public var Layers:Array = [0, int.MAX_VALUE];
		public var Bitmaps:Array = [0, int.MAX_VALUE];
		public function DisplayList(id:String, manager_id:String) 
		{
			super(id, manager_id);
		}
		
		public function AddLayer(id:String):void
		{
			if (Layers.indexOf(id) < 0)
			{
				var temp_sprite:Sprite = new Sprite;
				Layers.push(id, temp_sprite, []);
				Manager.stage.addChild(temp_sprite);
			}
		}
		//This for loop which removes the bitmaps associated with the layer.
		public function RemoveLayer(id:String):void
		{
			var i:int = Layers.indexOf(id);
			if (i > -1)
			{
				Manager.stage.removeChild(Layers[i + 1]);
				for (var j:int = Layers[i + 2].length - 1; j > -1; j--) { RemoveBitmap(Layers[i + 2][j]); }
				Layers[i]= undefined;
				Layers[i + 1] = undefined;
				Layers[i + 2] = undefined;
				Layers[0] += 3;
			}
		}
		
		public function SetLayerIndex(id:String, new_index:int):void
		{
			var i:int = Layers.indexOf(id);
			if (i > -1) Manager.stage.setChildIndex(Layers[i + 1], new_index);
		}
		
		public function GetLayer(id:String):*
		{
			var i:int = Layers.indexOf(id);
			if (i > -1) return Layers[i + 1];
		}
		
		public function AddBitmap(id:String, layer_id:String, x:Number, y:Number, width:Number, height:Number, alphachannel:Boolean, color:uint, scalex:Number = 1, scaley:Number = 1, pixelsnapping:String = "auto", smoothing:Boolean = false):*
		{
			if (Bitmaps.indexOf(id) < 0)
			{
				var i:int = Layers.indexOf(layer_id);
				if (i > -1)
				{
					var temp_bitmap:Bitmap = new Bitmap(new BitmapData(width, height, alphachannel, color), pixelsnapping, smoothing);
					temp_bitmap.x = x;
					temp_bitmap.y = y;
					temp_bitmap.scaleX = scalex;
					temp_bitmap.scaleY = scaley;
					Bitmaps.push(id, layer_id, temp_bitmap);
					Layers[i + 1].addChild(temp_bitmap);
					Layers[i + 2].push(id);
					return temp_bitmap;
				}
			}
		}
		
		public function RemoveBitmap(id:String):void
		{
			var i:int = Bitmaps.indexOf(id);
			if (i > -1)
			{
				var j:int = Layers.indexOf(Bitmaps[i + 1]);
				Layers[j + 1].removeChild(Bitmaps[i + 2]);
				var k:int = Layers[j + 2].indexOf(id);
				Layers[j + 2][k] = undefined;
				Bitmaps[i] = undefined;
				Bitmaps[i + 1] = undefined;
				Bitmaps[i + 2] = undefined;
				Layers[0]++;
				Bitmaps[0] += 3;
			}
		}
		
		public function GetBitmap(id:String):*
		{
			var i:int = Bitmaps.indexOf(id);
			if (i > -1) return Bitmaps[i + 2];
		}
		
		public function CollectGarbageLayers():void
		{
			Layers = Utilities.CollectGarbage(Layers);
			Layers[0] = 0;
		}
		
		public function CollectGarbageBitmaps():void
		{
			Bitmaps = Utilities.CollectGarbage(Bitmaps);
			Bitmaps[0] = 0;
		}
		
		public function get LayerLitter():int { return Layers[0]; }
		
		public function get LayerLitterThreshold():int { return Layers[1]; }
		
		public function set LayerLitterThreshold(i:int):void { Layers[1] = i; }
		
		public function get BitmapLitter():int { return Bitmaps[0]; }
		
		public function get BitmapLitterThreshold():int { return Bitmaps[1]; }
		
		public function set BitmapLitterThreshold(i:int):void { Bitmaps[1] = 1; }
		
		override public function EnterFrame(E:Event):void 
		{
			super.EnterFrame(E);
			if (Layers[0] > Layers[1]) CollectGarbageLayers();
			if (Bitmaps[0] > Bitmaps[1]) CollectGarbageBitmaps();
		} 
	}
}