import mx.collections.ArrayList;
import mx.events.FlexEvent;
import mx.states.AddItems;

import spark.components.List;
import spark.events.IndexChangeEvent;
import spark.events.ViewNavigatorEvent;


protected function onViewActivate(event:ViewNavigatorEvent):void
{
	/*myXML = new XML( event.target.data );
	
	myXML.ignoreWhite = true;

	var rsNS:Namespace = myXML.namespace("rs");
	var zNS:Namespace = myXML.namespace("z");
	var sNS:Namespace = myXML.namespace("s")
	
	// get the headings and column titles from the sNSAttributeType
	var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType;
	
	getRSAttributes(sAttributeType, arColumns);

	
	var rows:XMLList = myXML.rsNS::data;
	var i:Number = 0;
	var sRef:String;
	
	for each (var zRow:XML in rows.zNS::row) 
	{
		for (var col:Number = 0; col < arColumns.length; col++)
		{
			sRef = "@" + arColumns[col][0][0];
			trace(arColumns[col][0][1] + " = " + zRow[sRef]);
			if (arColumns[col][0][1] == "Commune") listCommunes.addItem({Commune:zRow[sRef]});
		}
		i++;
	}
	spinCommune.dataProvider = listCommunes;*/
}
protected function spinCommune_changeHandler(event:IndexChangeEvent):void
{
	txt.text += "Event: " + event.type + " (selectedItem: " + event.currentTarget.selectedItem.Commune + ")\n";
	
}
protected function Communes_creationCompleteHandler(event:FlexEvent):void
{
	
}

