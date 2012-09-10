import mx.collections.ArrayCollection;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

private var session:Session = Session.getInstance();

[Bindable]
private var sharePointList:ArrayCollection;
[Bindable]
private var siteAddress:String = session.urlSite;
private var list:String = "7A38E1D8-83F8-4A27-843A-4038D669CD66";
private var view:String = "4A2F9D51-ACB0-4EA4-B9CA-99593C9D5E8D";


private function searchItems():void
{
	httpService.send();
}
private function faultHandler(event:FaultEvent):void
{
	trace(event.fault.message);
}
private function searchResultHandler(event:ResultEvent):void
{
	if(event.result.xml.data)
	{
		var rows:Object = event.result.xml.data.row;
		sharePointList = rows is ArrayCollection? rows as ArrayCollection: new ArrayCollection([rows]);
	}
}
private function updateItem():void
{
	var request:String =  "<Batch OnError='Continue' ListVersion='1' ViewName='"+ view +"'> \n"+
		"  <Method ID='1' Cmd='Update'>                                        \n"+
		"    <Field Name='ID'>"+idField.text+"</Field>                         \n"+
		"    <Field Name='Title'>"+titleField.text+"</Field>                   \n"+
		"  </Method>                                                           \n"+
		"</Batch>                                                              \n";
	webService.UpdateListItems.send(list, new XML(request));
}
private function updateItemResultHandler(event:ResultEvent):void
{
	trace(event.result);
	allItems.selectedItem.ows_Title = titleField.text;
	sharePointList.refresh();
}