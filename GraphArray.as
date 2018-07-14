package 
{
	import adobe.utils.CustomActions;
	import flash.accessibility.Accessibility;
	
	public class GraphArray 
	{
		public var Symbols:Array = [0];
		public var Utilities:Scratchpad = Scratchpad.This;
		public function AddGet(symbol:*):Array
		{
			var i:int = Symbols.indexOf(symbol);
			if (i < 0)
			{
				Symbols.push(symbol, [0]);
				i = Symbols.length - 2;
			}
			return [Symbols[i], Symbols[i + 1]];
		}
		
		public function Delete(symbol:*):void
		{
			var i:int = Symbols.indexOf(symbol);
			if (i > 0)
			{
				Symbols[i] = undefined;
				Symbols[i + 1] = undefined;
			}
		}
		//allows multiple perceptions of the same symbol
		public function Trap(master_symbol:*, slave_symbol:*, slave_percieved_as:String):Boolean
		{
			master_symbol = AddGet(master_symbol);
			slave_symbol = AddGet(slave_symbol);
			var i:int = master_symbol[1].indexOf(slave_percieved_as);
			if (i < 0)
			{
				master_symbol[1].push(slave_percieved_as, slave_symbol[0]);
				return true;
			}
			return false;
		}
		
		public function Relate(symbolA:*, symbolA_percieved_as:String, symbolB:*, symbolB_percieved_as:String):void
		{
			if (Trap(symbolA, symbolB, symbolB_percieved_as)) if (!Trap(symbolB, symbolA, symbolA_percieved_as)) Derelate(symbolA, symbolB);
		}
		
		public function Derelate(symbolA:*, symbolB:*):void
		{
			symbolA = AddGet(symbolA);
			symbolB = AddGet(symbolB);
			var i :int = symbolA[1].indexOf(symbolB[0]);
			if (i > 0)
			{
				symbolA[1][i] = undefined;
				symbolA[1][i - 1] = undefined;
			}
			i = symbolB[1].indexOf(symbolA[0]);
			if (i > 0)
			{
				symbolB[1][i] = undefined;
				symbolB[1][i - 1] = undefined;
			}
		}
		
		public function CollectGarbage():void
		{
			Symbols = Utilities.CollectGarbage(Symbols);
		}
	}
}