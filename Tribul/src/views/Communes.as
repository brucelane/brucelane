import mx.events.FlexEvent;
import spark.events.ViewNavigatorEvent;

[Bindable]
private var myXML:XML;
private var arColumns:Array = new Array();
private var arTemp:Array = new Array();


protected function onViewActivate(event:ViewNavigatorEvent):void
{
	myXML = new XML( event.target.data );
	
	myXML.ignoreWhite = true;
	txt.text = myXML.toString();
	
	var rsNS:Namespace = myXML.namespace("rs");
	var zNS:Namespace = myXML.namespace("z");
	var sNS:Namespace = myXML.namespace("s")
	
	// get the headings and column titles from the sNSAttributeType
	var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType;
	
	getRSAttributes(sAttributeType, arColumns);
	
	trace('arrays created, now tring to reference them.');
	
	var rows:XMLList = myXML.rsNS::data;
	var i:Number = 0;
	var sRef:String;
	
	for each (var zRow:XML in rows.zNS::row) 
	{
		for (var col:Number = 0; col < arColumns.length; col++)
		{
			sRef = "@" + arColumns[col][0][0];
			trace(arColumns[col][0][1] + " = " + zRow[sRef]);
			txt.text += arColumns[col][0][1] + " = " + zRow[sRef];
		}
		i++;
	}
}
protected function Communes_creationCompleteHandler(event:FlexEvent):void
{
	/*var rsNS:Namespace = myXML.namespace("rs");
	var zNS:Namespace = myXML.namespace("z");
	var sNS:Namespace = myXML.namespace("s")
	
	// get the headings and column titles from the sNSAttributeType
	var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType
	
	getRSAttributes(sAttributeType, arColumns);
	
	trace('arrays created, now tring to reference them.');
	
	var rows:XMLList = myXML.rsNS::data;
	var i:Number = 0;
	var sRef:String;
	
	for each (var zRow:XML in rows.zNS::row) 
	{
	for (var col:Number = 0; col < arColumns.length; col++)
	{
	sRef = "@" + arColumns[col][0][0];
	trace(arColumns[col][0][1] + " = " + zRow[sRef]);
	txt.text += arColumns[col][0][1] + " = " + zRow[sRef];
	}
	i++;
	}*/
}

private function getRSAttributes(attributes_XML:XMLList, headings_ar:Array):void
{
	/* 
	first create an array to keep the info in then
	get the attribute elements from the XML like this:
	var sAttributeType:XMLList = myXML.sNS::Schema.sNS::ElementType.sNS::AttributeType
	
	then call funtion like this: getRSAttribues(sAttributeType, arColumns);
	*/
	var arTemp:Array = new Array();
	
	for (var j:Number = 0; j < attributes_XML.length(); j++)
	{
		
		arTemp = new Array();
		
		for each (var attr:String in attributes_XML[j].attributes())
		{
			arTemp.push(attr);
		}
		headings_ar[j] = new Array();
		headings_ar[j].push(arTemp);
	}
	
}	