
import flash.events.MouseEvent;

import fr.batchass.Database;

import mx.events.FlexEvent;

import views.*;


protected function activer_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueGeolocalisation);	
}
protected function cnx_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueConnexion);	
}
protected function commune_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueCommunes);
}
protected function importer_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueImport);
	
}