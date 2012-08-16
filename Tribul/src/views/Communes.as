import mx.collections.ArrayList;
import mx.events.FlexEvent;
import mx.states.AddItems;

import spark.components.List;
import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;

private var session:Session = Session.getInstance();

protected function onViewActivate(event:ViewNavigatorEvent):void
{
	/*myXML = new XML( event.target.data );
	
	*/
	spinCommune.dataProvider = session.listCommunes;
}
protected function spinCommune_changeHandler(event:IndexChangeEvent):void
{
	txt.text += "Event: " + event.type + " (selectedItem: " + event.currentTarget.selectedItem.Commune + ")\n";
	
}
protected function Communes_creationCompleteHandler(event:FlexEvent):void
{
	
}

