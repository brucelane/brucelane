
import flash.events.MouseEvent;

import mx.events.FlexEvent;

import views.VueConnexion;
import views.VueGeolocalisation;

protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{	
	
	
}
protected function activer_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueGeolocalisation);
	
}
protected function cnx_clickHandler(event:MouseEvent):void
{
	
	this.navigator.pushView(VueConnexion);
	
	
}