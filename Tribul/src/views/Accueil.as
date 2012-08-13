import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestDefaults;

import fr.batchass.*;

import mx.events.FlexEvent;
import mx.rpc.soap.mxml.WebService;

import spark.components.View;

import views.CommunesView;
import views.AccueilView;

private var defaultConfigXmlPath:String = 'config' + File.separator + 'config.xml';
public var CONFIG_XML:XML;
[Bindable]
private var session:Session = Session.getInstance();

public var siteSP:String = "http://www.agglo-sophia-antipolis.fr/";
private var configFile:File = File.applicationStorageDirectory.resolvePath( defaultConfigXmlPath );


protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
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
			
			urlsite.text = session.urlSite = siteSP = CONFIG_XML..urlsite[0].toString();
			user.text = session.userName = CONFIG_XML..username[0].toString();
			pwd.text = session.password = CONFIG_XML..pwd[0].toString();

		}
	}
	catch ( e:Error )
	{	
		var msg:String = 'Error loading config.xml file: ' + e.message;
		Util.log( msg );
	}
	
}

protected function cnx_clickHandler(event:MouseEvent):void
{
	//valid values are portal or team
	var siteType:String = "portal";
	//List Id configuration 
	//update listid to appropriate list id in sharepoint
	//to locate list id browse to sharepoint list and select modify columns/settings and 
	//copy listid from URL
	//change listId to image list GUID
	// liste: Listes
	var listId:String = "{13B37348-6007-42E6-9E00-FC4876F0CB2C}";
	// liste:  Communes var listId:String = "{7A38E1D8-83F8-4A27-843A-4038D669CD66}";
	//*********Team Site Specific Configuration(Required for teamsites only************
	//change site to site name in URL
	var site:String = "[sitename]";
	//*****End configuration area **************
	var GetURL:String = urlsite.text;
	
	//switch for whether this is a team or portal site to obtain the correct URL 
	if(siteType == "portal")
	{
		GetURL += "_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
		//GetURL += "_vti_bin/ListData.svc/Listes";
		Util.log( "Tentative de connection à " + GetURL );
	}
	else
	{
		GetURL += "sites" + "/" + site + "/_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
	}
	
	URLRequestDefaults.authenticate = true;
	URLRequestDefaults.setLoginCredentialsForHost(siteSP, user.text, pwd.text)
	
	var chargeur:URLLoader = new URLLoader ();
	var adresse:URLRequest = new URLRequest (GetURL);
	//adresse.authenticate = true;
	var format:String = URLLoaderDataFormat.TEXT;
	chargeur.dataFormat = format;
	chargeur.load(adresse);
	chargeur.addEventListener(Event.COMPLETE, complete);
	chargeur.addEventListener(ProgressEvent.PROGRESS, progress);
	chargeur.addEventListener(IOErrorEvent.IO_ERROR, erreur);	
}


private function progress( event:ProgressEvent):void {
	trace(event.bytesLoaded+" chargés sur "+event.bytesTotal);
}

// fonction indiquant si une erreur de chargement survient :
private function erreur( event:Event ):void {
	txt.text = "Utilisateur ou mot de passe incorrect pour " + urlsite.text + " " + event.currentTarget.data + "\n" + event;
	Util.log( txt.text);
}
private function complete( event:Event ):void {
	//retour pour Listes: <z:row ows_Attachments='0' ows_LinkTitle='{7A38E1D8-83F8-4A27-843A-4038D669CD66}' ows_Description='Communes' />
	txt.text = "Connecté";
	if ( session.userName != user.text || session.password != pwd.text  || session.urlSite != urlsite.text ) 
	{
		writeFolderXmlFile();
	}
	session.userName = user.text;
	session.password = pwd.text;
	session.urlSite = urlsite.text;
	Util.log( "Connecté à " + urlsite.text );
	
	
	
	this.navigator.pushView(CommunesView, event.target.data);
}
private function writeFolderXmlFile():void
{
	CONFIG_XML = <config> 
					<urlsite>{urlsite.text}</urlsite>
					<username>{user.text}</username>
					<pwd>{pwd.text}</pwd>
				 </config>;
	// write the text file
	writeTextFile( configFile, CONFIG_XML );					
}
