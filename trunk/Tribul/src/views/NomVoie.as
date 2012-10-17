import events.DonneesEvent;

import flash.events.MouseEvent;

import fr.batchass.*;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;

private var db:Database = Database.getInstance();

[Bindable]
private var nomVoies:ArrayList;
private var rivoli:String;
private var code_insee:String;

protected function NomVoie_viewActivateHandler(event:ViewNavigatorEvent):void
{
	code_insee =  new String(event.target.data);
	db.addEventListener( DonneesEvent.ON_NOMVOIES, bindNomVoies );
	db.getNomVoies(code_insee);
}
protected function NomVoie_creationCompleteHandler(event:FlexEvent):void
{

}

private function bindNomVoies(event:DonneesEvent):void
{
	Util.log("TYPE: " + event.type + "\nTARGET: " + event.target + "\n");
	nomVoies = db.acNomVoies;
}
protected function spinNomVoie_changeHandler(event:IndexChangeEvent):void
{
	if (event.currentTarget.selectedItem)
	{
		rivoli = event.currentTarget.selectedItem.code_rivoli;
		txt.text = "Code:" + event.currentTarget.selectedItem.code_rivoli;
	}
}

protected function valider_clickHandler(event:MouseEvent):void
{
	//this.navigator.pushView(numero, rivoli);
	
}