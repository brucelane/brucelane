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

import mx.events.FlexEvent;
import mx.rpc.soap.mxml.WebService;

import spark.components.View;

import views.CommunesView;
import views.SharepointAndroidAffichageAccueilView;


protected function cnx_clickHandler(event:MouseEvent):void
{
	//valid values are portal or team
	var siteType:String = "portal";
	//List Id configuration 
	//update listid to appropriate list id in sharepoint
	//to locate list id browse to sharepoint list and select modify columns/settings and 
	//copy listid from URL
	//change listId to image list GUID
	//var listId:String = "{49F4615A-A282-4E66-AC06-B07B15DC561F}";
	var listId:String = "{7A38E1D8-83F8-4A27-843A-4038D669CD66}";
	//*********Team Site Specific Configuration(Required for teamsites only************
	//change site to site name in URL
	var site:String = "[sitename]";
	//*****End configuration area **************
	var GetURL:String = urlsite.text;
	
	//switch for whether this is a team or portal site to obtain the correct URL 
	if(siteType == "team")
	{
		GetURL += "sites" + "/" + site + "/_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
	}
	else
	{
		//GetURL = "";
	}
	if(siteType == "portal")
	{
		GetURL += "_vti_bin/owssvr.dll?Cmd=Display&List=" + listId + "&XMLDATA=TRUE";
	}
	else
	{
	};
	URLRequestDefaults.authenticate = true;
	URLRequestDefaults.setLoginCredentialsForHost("www.agglo-sophia-antipolis.fr", user.text, pwd.text)
	
	var chargeur:URLLoader = new URLLoader ();
	var adresse:URLRequest = new URLRequest (GetURL);
	//adresse.authenticate = true;
	var format:String = URLLoaderDataFormat.TEXT;
	chargeur.dataFormat = format;
	chargeur.load(adresse);
	chargeur.addEventListener(Event.COMPLETE, callback);
	chargeur.addEventListener(ProgressEvent.PROGRESS, progress);
	chargeur.addEventListener(IOErrorEvent.IO_ERROR, erreur);
	
}

protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{
	
	
}

private function progress( event:ProgressEvent):void {
	trace(event.bytesLoaded+" chargés sur "+event.bytesTotal);
}

// fonction indiquant si une erreur de chargmement survient :
private function erreur( event:Event ):void {
	trace(event);
	trace(event.currentTarget.data);
}
public function callback( event:Event ):void {
	txt.text = "Connecté";
	/*myXML = new XML( event.target.data );
	
	myXML.ignoreWhite = true;
	txt.text = myXML.toString();*/
	this.navigator.pushView(CommunesView, event.target.data);
	
	
	
}
