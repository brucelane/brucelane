import events.DonneesEvent;

import flash.events.MouseEvent;

import fr.batchass.*;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.events.IndexChangeEvent;
import spark.events.TextOperationEvent;
import spark.events.ViewNavigatorEvent;

import views.VueNumeroVoie;

private var db:Database = Database.getInstance();

[Bindable]
private var numerosVoies:ArrayList = new ArrayList();
private var sauveNumeros:ArrayList = new ArrayList();
private var rivoli:String;
private var termLength:int = 0;

protected function NumeroVoie_viewActivateHandler(event:ViewNavigatorEvent):void
{
	rivoli =  new String(event.target.data);
	db.addEventListener( DonneesEvent.ON_NUMEROVOIE, bindNumerosVoie );
	db.getNumerosVoie(rivoli);
}
private function bindNumerosVoie(event:DonneesEvent):void
{
	//Util.log("TYPE: " + event.type + "\nTARGET: " + event.target + "\n");
	numerosVoies.addAll(db.acNomVoies);
}
protected function terme_changeHandler(event:TextOperationEvent):void
{
	var term:String = terme.text.toUpperCase();
	if (term.length < termLength)
	{
		// recharger la sauvegarde
		numerosVoies.removeAll();
		numerosVoies.addAll(sauveNumeros);
	}
	termLength = term.length;
	if (term.length > 0)
	{
		var i:int = numerosVoies.length-1;
		while (i > -1)
		{
			var o:Object = (numerosVoies.getItemAt(i) as Object);
			var nomvoie:String = o.nomvoie as String;
			if (nomvoie.toUpperCase().indexOf(term)<0)
			{
				numerosVoies.removeItemAt(i);
				if (i<numerosVoies.length-1) i++;
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
		numerosVoies.removeAll();
		numerosVoies.addAll(sauveNumeros);
	}
	
}
protected function valider_clickHandler(event:MouseEvent):void
{
	//this.navigator.pushView(VueNumeroVoie, rivoli);
	
}