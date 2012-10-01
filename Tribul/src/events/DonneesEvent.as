package events
{
	import flash.events.Event;
	
	public class DonneesEvent extends Event
	{
		public static const DEFAULT_NAME:String = "fr.batchass.DonneesEvent";
		
		// event constants
		public static const ON_COMMUNES:String = "onCommunes";
		public static const ON_NOMVOIES:String = "onNomVoies";
		public static const ON_OPEN:String = "onOpen";

		
		public var params:Object;
		
		public function DonneesEvent(type:String, params:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		
			this.params = params;
		}
		
		public override function clone():Event
		{
			return new DonneesEvent(type, this.params, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("DonneesEvent", "params", "type", "bubbles", "cancelable");
		}
	
	}
}