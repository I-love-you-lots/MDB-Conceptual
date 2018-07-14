package
{
	import flash.display.BitmapData;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class Scratchpad
	{
		private static var THIS:Scratchpad;
		public function Scratchpad()
		{
			if (!THIS) THIS = this; else throw new Error("Scratchpad is a singleton.");
		}
		
		public function VectorFromAngle(Angle:Number):Array
		{
			return [Math.cos((Angle / 180) * Math.PI), Math.sin((Angle / 180) * Math.PI)];
		}
		
		public function Distance(PointAx:Number, PointAy:Number, PointBx:Number, PointBy:Number):Number
		{
			return Math.sqrt((PointAx - PointBx) * (PointAx - PointBx) + (PointAy - PointBy) * (PointAy - PointBy));
		}
		
		public function CombineChannels(Red:int, Blue:int, Green:int, Alpha:int = 0xFF):uint
		{
			return Alpha << 24 | Red << 16 | Green << 8 | Blue;
		}
		//Credit goes to Simo Santavirta (http://www.simppa.fi/) for this port of the Bresenham line Algorithm
		public function Bresenham(Output:BitmapData, Color:uint, XA:Number, YA:Number, XB:Number, YB:Number):void
		{
			var ShortLength:int = YB - YA;
			var LongLength:int = XB - XA;
			if ((ShortLength ^ (ShortLength >> 31)) - (ShortLength >> 31) > (LongLength ^ (LongLength >> 31)) - (LongLength >> 31))
			{
				ShortLength ^= LongLength;
				LongLength ^= ShortLength;
				ShortLength ^= LongLength;
				var YLonger:Boolean = true;
			}
			else YLonger = false;
			var Inc:int = LongLength < 0 ? -1 : 1;
			var MultDiff:Number = LongLength == 0 ? ShortLength : ShortLength / LongLength;
			if (YLonger)
				for (var i:int = 0; i != LongLength; i += Inc)
				{
					Output.setPixel(XA + i * MultDiff, YA + i, Color);
				}
			else
				for (i = 0; i != LongLength; i += Inc)
				{
					Output.setPixel(XA + i, YA + i * MultDiff, Color);
				}
		}
		//Ignores 'undefined' and empty arrays. May need to cycle twice to remove arrays filled with 'undefined'. No significant performance
		//drawdowns if so. EDIT.7.9.18 well I originally said that when this was an exclusive part of the State class. I'l be working on this.
		public function CollectGarbage(input_array:Array):Array
		{
			var ArrayReturn:Array = [];
			var TempArray:Array;
			var Position:int;
			var Length:int = input_array.length;
			while (Position < Length)
			{
				if (input_array[Position] != undefined && !(input_array[Position] is Array)) ArrayReturn.push(input_array[Position]);
				else if (input_array[Position] is Array && input_array[Position].length > 0) ArrayReturn.push(CollectGarbage(input_array[Position]));
				Position++;
			}
			trace(ArrayReturn);
			return ArrayReturn;
		}
		
		public function Save(item:*, filestream:FileStream):void
		{
			if (item is String)
			{
				filestream.writeByte(0);
				filestream.writeUTF(item);
			}
			else if (item is int || item is uint || item is Number)
			{
				filestream.writeByte(1);
				filestream.writeDouble(item);
			}
			else if (item is ByteArray)
			{
				filestream.writeByte(2);
				filestream.writeDouble(item.length);
				filestream.writeBytes(item);
			}
			else if (item is Date)
			{
				filestream.writeByte(3);
				filestream.writeUTF(item.toString());
			}
			else if (item is Array)
			{
				var pos:int;
				var len:uint = item.length;
				filestream.writeByte(4);
				filestream.writeUnsignedInt(len);
				while (pos < len)
				{
					Save(item[pos], filestream);
					pos++;
				}
			}
		}
		
		public function Load(filestream:FileStream, step:int = 1, do_not_modify:Boolean = false):*
		{
			try
			{
				var arrayreturn:Array = [];
				var sign:int;
				while (step > 0 && filestream.bytesAvailable > 0)
				{
					sign = filestream.readByte();
					if 		(sign == 0) arrayreturn.push(filestream.readUTF());
					else if (sign == 1) arrayreturn.push(filestream.readDouble());
					else if (sign == 2)
					{
						var temp_bytearray:ByteArray = new ByteArray;
						filestream.readBytes(temp_bytearray, 0, filestream.readDouble());
						arrayreturn.push(temp_bytearray);
					}
					else if (sign == 3) arrayreturn.push(new Date(filestream.readUTF()));
					else if (sign == 4) arrayreturn.push(Load(filestream, filestream.readUnsignedInt(), true));
					step--;
				}
				return get_return();
			}
			catch (E:Error) 
			{
				trace(E.message)
				return get_return();
			}
			
			function get_return():Array
			{
				if (arrayreturn.length == 1 && !do_not_modify) return arrayreturn[0];
				return arrayreturn;
			}
		}
		
		public static function get This():Scratchpad
		{
			if (THIS)
			return THIS;
			return new Scratchpad;
		}
	}
}