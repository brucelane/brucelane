import events.DonneesEvent;

import flash.events.MouseEvent;

import fr.batchass.*;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.components.List;
import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;

import views.*;

private var db:Database = Database.getInstance();
private var commune:String;

[Bindable]
private var communes:ArrayList;


protected function onViewActivate(event:ViewNavigatorEvent):void
{
	
}
protected function Communes_creationCompleteHandler(event:FlexEvent):void
{
	db.addEventListener( DonneesEvent.ON_COMMUNES, bindCommunes );
	db.getCommunes();
	
}
private function bindCommunes(event:DonneesEvent):void
{
	Util.log("TYPE: " + event.type + "\nTARGET: " + event.target + "\n");
	communes = db.acCommunes;
}
protected function spinCommune_changeHandler(event:IndexChangeEvent):void
{
	if (event.currentTarget.selectedItem)
	{
		commune = event.currentTarget.selectedItem.commune;
		txt.text = "Commune: " + event.currentTarget.selectedItem.commune;
	}
}

protected function valider_clickHandler(event:MouseEvent):void
{
	this.navigator.pushView(VueNomVoie, commune);
	
}

