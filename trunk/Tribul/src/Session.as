package
{
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import fr.batchass.Util;
	import flash.events.Event;
	
	[Bindable]
	public class Session
	{
		private static var instance:Session = new Session();
		private var _connected:Boolean;
		private var _userName:String;
		private var _password:String;
		private var _urlSite:String;
		
		public function Session()
		{
			if ( instance == null ) 
			{
						
			}
			else trace( "Session already instanciated." );
		}
		
		public static function getInstance():Session 
		{
			return instance;
		}	
		
		public function get userName():String
		{
			return _userName;
		}
		
		public function set userName(value:String):void
		{
			_userName = value;
		}
		
		public function get password():String
		{
			return _password;
		}
		
		public function set password(value:String):void
		{
			_password = value;
		}

		public function get urlSite():String
		{
			return _urlSite;
		}
		
		public function set urlSite(value:String):void
		{
			_urlSite = value;
		}
		
		public function get connected():Boolean
		{
			return _connected;
		}
		
		public function set connected(value:Boolean):void
		{
			_connected = value;
		}
		
	

		
		
	}
}