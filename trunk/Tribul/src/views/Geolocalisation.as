import flash.events.GeolocationEvent;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.sensors.Geolocation;

import mx.events.FlexEvent;

private var geolocation:Geolocation;
private var lat:String;
private var long:String;

protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{	
	
	//txt.text += "Geolocation: " + Geolocation.isSupported + " en pause: " + geolocation.muted;
	if (Geolocation.isSupported)
	{
		geolocation =  new Geolocation();
		geolocation.setRequestedUpdateInterval(1000);
		geolocation.addEventListener( GeolocationEvent.UPDATE, onTravel );
		geolocation.addEventListener( StatusEvent.STATUS, onStatus );
	}
	else
	{
		
		
	}
}

private function onTravel(event:GeolocationEvent):void
{
	latlong.text = "Lat " + event.latitude + ",long " + event.longitude;
	lat = event.latitude.toString();
	long = event.longitude.toString();
}
private function onStatus(event:StatusEvent):void
{
	actif.text += "Statut " + event.code;
	
}
protected function carte_clickHandler(event:MouseEvent):void
{
	navigateToURL( new URLRequest( "http://maps.google.com/?q=" + lat + "," + long ) );
	
}