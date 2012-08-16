package
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import fr.batchass.*;
	import fr.batchass.Util;
	
	import mx.collections.ArrayList;
	
	[Bindable]
	public class Session
	{
		private static var instance:Session = new Session();
		private var _connected:Boolean;
		private var _userName:String = "CASA\\";
		private var _password:String;
		private var _urlSite:String = "http://www.agglo-sophia-antipolis.fr/";
		private var defaultConfigXmlPath:String = 'config' + File.separator + 'config.xml';
		public var CONFIG_XML:XML;
		private var configFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );
		//private var _communes:String;
		//[Bindable]//useless?
		public var listCommunes:ArrayList = new ArrayList();
		//[Bindable]
		public var dictListes:Dictionary = new Dictionary();
		
		public function Session()
		{
			if ( instance == null ) 
			{
				try
				{		
					if ( !configFile.exists )
					{
						Util.log( "config.xml does not exist" );
					}
					else
					{
						Util.log( "config.xml exists, load the file xml" );
						CONFIG_XML = new XML( readTextFile( configFile ) );
						
						urlSite = CONFIG_XML..urlsite[0].toString();
						userName = CONFIG_XML..username[0].toString();
						password = CONFIG_XML..pwd[0].toString();					
					}
				}
				catch ( e:Error )
				{	
					var msg:String = 'Error loading config.xml file: ' + e.message;
					Util.log( msg );
				}			
						
			}
			else trace( "Session already instanciated." );
		}
		
		public static function getInstance():Session 
		{
			return instance;
		}	
		private function writeFolderXmlFile():void
		{
			CONFIG_XML = <config> 
							<urlsite>{_urlSite}</urlsite>
							<username>{_userName}</username>
							<pwd>{_password}</pwd>
						 </config>;
			// write the text file
			writeTextFile( configFile, CONFIG_XML );					
		}		
		public function get userName():String
		{
			return _userName;
		}
		
		public function set userName(value:String):void
		{
			/*if ( _userName != value  ) 
			{
				writeFolderXmlFile();
			}*/
			_userName = value;
		}
		
		public function get password():String
		{
			return _password;
		}
		
		public function set password(value:String):void
		{
			if ( _password != value ) 
			{
				_password = value;
				writeFolderXmlFile();
			}
		}

		public function get urlSite():String
		{
			return _urlSite;
		}
		
		public function set urlSite(value:String):void
		{
			/*if ( _urlSite != value ) 
			{
				writeFolderXmlFile();
			}*/
			_urlSite = value;
		}

		/*public function get communes():String
		{
			return _communes;
		}

		public function set communes(value:String):void
		{
			_communes = value;
		}*/

	
	}
}