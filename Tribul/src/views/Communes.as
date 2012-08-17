import events.DonneesEvent;

import fr.batchass.*;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.events.FlexEvent;
import mx.states.AddItems;

import spark.components.List;
import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;

private var session:Session = Session.getInstance();
private var db:Database = Database.getInstance();

[Bindable]
private var communes:ArrayCollection;

protected function onViewActivate(event:ViewNavigatorEvent):void
{
	db.addEventListener( DonneesEvent.ON_COMMUNES, bindCommunes );
	db.getCommunes();
	/*myXML = new XML( event.target.data );
	
	*/
	//sp.GetList( session.dictListes["Communes"] );

	//spinCommune.dataProvider = session.Communes;
	//communes = session.Communes;
}
private function bindCommunes(event:DonneesEvent):void
{
	Util.log("TYPE: " + event.type + "\nTARGET: " + event.target + "\n");
	Util.log(event.toString());
	communes = event.params as ArrayCollection;
	
}
protected function spinCommune_changeHandler(event:IndexChangeEvent):void
{
	if (event.currentTarget.selectedItem) txt.text += "Event: " + event.type + " (selectedItem: " + event.currentTarget.selectedItem.Commune + ")\n";
	
}
protected function Communes_creationCompleteHandler(event:FlexEvent):void
{
	
}

