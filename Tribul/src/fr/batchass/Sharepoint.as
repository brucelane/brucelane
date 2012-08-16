package fr.batchass
{
	import flash.events.*;
	import flash.net.*;
	
	import mx.collections.ArrayList;

	//List Id configuration 
	//update listid to appropriate list id in sharepoint
	//to locate list id browse to sharepoint list and select modify columns/settings and 
	//copy listid from URL
	//change listId to image list GUID
	
	public class Sharepoint implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private var session:Session = Session.getInstance();
		private var _urlsite:String;
		private var _urlsiteWithoutHttp:String;
		private var _siteType:String;
		private var _user:String;
		private var _pwd:String;
		private var _error:String = "";
		//*********Team Site Specific Configuration(Required for teamsites only************
		private var siteName:String = "[sitename]";
		private const listesListId:String = "{13B37348-6007-42E6-9E00-FC4876F0CB2C}";
		private var myXML:XML;
		private var arColumns:Array = new Array();
		private var arTemp:Array = new Array();
		
		public function Sharepoint(url:String, user:String, password:String, portalORteam:String = "portal", siteNameIfTeam:String = "")
		{
			dispatcher = new EventDispatcher(this);
			// remove last slash
			if ( url.lastIndexOf( "/") == url.length - 1 ) url = url.substr( 0, url.length - 1 );
			if ( url.indexOf( "http://" ) > -1 )
			{
				_urlsite = url + "/";
				_urlsiteWithoutHttp = url.substr( 7, url.length-1);
			}
			else
			{
				_urlsite = "http://" + url + "/";
				_urlsiteWithoutHttp = url;
			}
			
			_siteType = portalORteam;
			_user = user;
			_pwd = password;
		}
		
		//Connection et recup liste Listes
		public function Connect():void
		{
			// liste: Listes
			//var listId:String = "{13B37348-6007-42E6-9E00-FC4876F0CB2C}";
			//*****End configuration area **************
			var GetURL:String = _urlsite;
			
			//switch for whether this is a team or portal site to obtain the correct URL 
			if(_siteType == "portal")
			{
				GetURL += "_vti_bin/owssvr.dll?Cmd=Display&List=" + listesListId + "&XMLDATA=TRUE";
				//GetURL += "_vti_bin/ListData.svc/Listes";
			}
			else
			{ //team
				GetURL += "sites" + "/" + siteName + "/_vti_bin/owssvr.dll?Cmd=Display&List=" + listesListId + "&XMLDATA=TRUE";
			}
			Util.log( "Tentative de connection à " + GetURL );
			
			URLRequestDefaults.authenticate = true;
			URLRequestDefaults.setLoginCredentialsForHost(_urlsiteWithoutHttp, _user, _pwd)
			
			var ldr:URLLoader = new URLLoader ();
			var adresse:URLRequest = new URLRequest (GetURL);
			adresse.authenticate = true;
			var format:String = URLLoaderDataFormat.TEXT;
			ldr.dataFormat = format;
			ldr.load(adresse);
			ldr.addEventListener(Event.COMPLETE, connectComplete);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, connectErr);				
		}
		
		public function GetList(listId:String):void
		{
			// liste:  Communes var listId:String = "{7A38E1D8-83F8-4A27-843A-4038D669CD66}";
			var GetURL:String = _urlsite;
			
			//switch for whether this is a team or portal site to obtain the correct URL 
			if(_siteType == "portal")
			{
				GetURL += "_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
				//GetURL += "_vti_bin/ListData.svc/Listes";
			}
			else
			{ //team
				GetURL += "sites" + "/" + siteName + "/_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
			}
			Util.log( "Tentative de connection à " + GetURL );
			
			URLRequestDefaults.authenticate = true;
			URLRequestDefaults.setLoginCredentialsForHost(_urlsiteWithoutHttp, _user, _pwd)
			
			var ldr:URLLoader = new URLLoader ();
			var adresse:URLRequest = new URLRequest (GetURL);
			adresse.authenticate = true;
			var format:String = URLLoaderDataFormat.TEXT;
			ldr.dataFormat = format;
			ldr.load(adresse);
			ldr.addEventListener(Event.COMPLETE, complete);
			ldr.addEventListener(ProgressEvent.PROGRESS, progress);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, err);				
		}
		
		private function progress( event:ProgressEvent):void {
			trace(event.bytesLoaded+" chargés sur "+event.bytesTotal);
		}
		
		// fonction indiquant si une erreur de chargement survient :
		private function err( event:Event ):void 
		{
			error = "Erreur pour " + _urlsite + " " + event.currentTarget.data + "\n" + event;
			Util.log( error);
			dispatchEvent( new Event(Event.CANCEL) );
		}
		private function connectErr( event:Event ):void 
		{
			error = "Utilisateur ou mot de passe incorrect pour " + _urlsite + " " + event.currentTarget.data + "\n" + event;
			Util.log( error);
			dispatchEvent( new Event(Event.CLOSE) );
		}
		private function connectComplete( event:Event ):void 
		{
			//retour pour Listes: <z:row ows_Attachments='0' ows_LinkTitle='{7A38E1D8-83F8-4A27-843A-4038D669CD66}' ows_Description='Communes' />
			var myXML:XML = new XML( event.target.data );
			
			session.userName = _user;
			session.password = _pwd;
			session.urlSite = _urlsite;
			Util.log( "connectComplete, connecté à " + _urlsite );
			
			myXML.ignoreWhite = true;
			
			var rsNS:Namespace = myXML.namespace("rs");
			var zNS:Namespace = myXML.namespace("z");
			var sNS:Namespace = myXML.namespace("s")
			
			// get the headings and column titles from the sNSAttributeType
			var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType;
			
			getRSAttributes(sAttributeType, arColumns);			
			
			var rows:XMLList = myXML.rsNS::data;
			var sRef:String;
			
			for each (var zRow:XML in rows.zNS::row) 
			{
				var listGuid:String;
				var name:String;
				for (var col:Number = 0; col < arColumns.length; col++)
				{
					sRef = "@" + arColumns[col][0][0];
					trace(arColumns[col][0][1] + " = " + zRow[sRef]);
					if (arColumns[col][0][1] == "Titre") listGuid = zRow[sRef];
					if (arColumns[col][0][1] == "Description") name = zRow[sRef];					
				}
				if ( listGuid && name )
				{
					//session.dictListes.addItem({guid:listGuid,nom:name});
					session.dictListes[name]=listGuid;
					//if (name=="Communes") session.communes = listGuid;
				}
			}		

			dispatchEvent( new Event(Event.COMPLETE) );
		}
		private function complete( event:Event ):void {
			var myXML:XML = new XML( event.target.data );

			Util.log( "Liste chargée " + _urlsite );
			myXML.ignoreWhite = true;
			
			var rsNS:Namespace = myXML.namespace("rs");
			var zNS:Namespace = myXML.namespace("z");
			var sNS:Namespace = myXML.namespace("s")
			
			// get the headings and column titles from the sNSAttributeType
			var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType;
			
			getRSAttributes(sAttributeType, arColumns);			
			
			var rows:XMLList = myXML.rsNS::data;
			
			var sRef:String;
			
			for each (var zRow:XML in rows.zNS::row) 
			{
				for (var col:Number = 0; col < arColumns.length; col++)
				{
					sRef = "@" + arColumns[col][0][0];
					trace(arColumns[col][0][1] + " = " + zRow[sRef]);
					if (arColumns[col][0][1] == "Commune") session.listCommunes.addItem({Commune:zRow[sRef]});
				}
				
			}			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		private function getRSAttributes(attributes_XML:XMLList, headings_ar:Array):void
		{
			/* 
			first create an array to keep the info in then
			get the attribute elements from the XML like this:
			var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType
			
			then call funtion like this: getRSAttribues(sAttributeType, arColumns);
			*/
			var arTemp:Array = new Array();
			
			for (var j:Number = 0; j < attributes_XML.length(); j++)
			{
				
				arTemp = new Array();
				
				for each (var attr:String in attributes_XML[j].attributes())
				{
					arTemp.push(attr);
				}
				headings_ar[j] = new Array();
				headings_ar[j].push(arTemp);
			}
			
		}	
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}

		public function get error():String
		{
			return _error;
		}

		public function set error(value:String):void
		{
			_error = value;
		}

		
	}
}