import events.DonneesEvent;

import flash.events.MouseEvent;

import fr.batchass.*;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.events.IndexChangeEvent;
import spark.events.TextOperationEvent;
import spark.events.ViewNavigatorEvent;

private var db:Database = Database.getInstance();

[Bindable]
private var nomVoies:ArrayList = new ArrayList();
private var sauveVoies:ArrayList = new ArrayList();
private var rivoli:String;
private var code_insee:String;
private var termLength:int = 0;

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
	//Util.log("TYPE: " + event.type + "\nTARGET: " + event.target + "\n");
	nomVoies.addAll(db.acNomVoies);
	sauveVoies.addAll(db.acNomVoies);
}
protected function spinNomVoie_changeHandler(event:IndexChangeEvent):void
{
	if (event.currentTarget.selectedItem)
	{
		rivoli = event.currentTarget.selectedItem.code_rivoli;
		txt.text = "Code:" + event.currentTarget.selectedItem.code_rivoli;
	}
}

protected function terme_changeHandler(event:TextOperationEvent):void
{
	var term:String = terme.text.toUpperCase();
	if (term.length < termLength)
	{
		// recharger la sauvegarde
		nomVoies.removeAll();
		nomVoies.addAll(sauveVoies);
	}
	termLength = term.length;
	if (term.length > 0)
	{
		var i:int = nomVoies.length-1;
		while (i > -1)
		{
			var o:Object = (nomVoies.getItemAt(i) as Object);
			var nomvoie:String = o.nomvoie as String;
			if (nomvoie.toUpperCase().indexOf(term)<0)
			{
				nomVoies.removeItemAt(i);
				if (i<nomVoies.length-1) i++;
			}
			else
			{
				
			}
			i--;
		}
	}
	else
	{
		// recharger la sauvegarde
		nomVoies.removeAll();
		nomVoies.addAll(sauveVoies);
	}
	
}
protected function valider_clickHandler(event:MouseEvent):void
{
	//this.navigator.pushView(numero, rivoli);
	
}