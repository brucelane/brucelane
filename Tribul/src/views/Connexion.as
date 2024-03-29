import flash.events.*;
import flash.filesystem.*;

import fr.batchass.*;

import mx.collections.IViewCursor;
import mx.events.FlexEvent;
import mx.rpc.soap.mxml.WebService;

import spark.components.View;
import spark.events.ViewNavigatorEvent;

import views.VueAccueil;
import views.VueCommunes;

private var session:Session = Session.getInstance();

private var sp:Sharepoint;

protected function onViewActivate(event:ViewNavigatorEvent):void
{
	session = Session.getInstance();
	urlsite.text = session.urlSite;
	user.text = session.userName;
	pwd.text = session.password;
}
protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{	
	/*urlsite.text = session.urlSite;
	user.text = session.userName;
	pwd.text = session.password;*/
	
}
protected function cnx_clickHandler(event:MouseEvent):void
{
	sp = new Sharepoint( urlsite.text, user.text, pwd.text );
	sp.addEventListener( Event.COMPLETE, connectComplete );
	sp.addEventListener( Event.CLOSE, connectErr );
	sp.Connect(); //Listes	 
}


private function err( event:Event ):void 
{
	txt.text = "Erreur pour " + urlsite.text + "\n" + event;
	Util.log( txt.text);
}
private function connectErr( event:Event ):void 
{
	txt.text = "Utilisateur ou mot de passe incorrect pour " + urlsite.text + "\n" + event;
	Util.log( txt.text);
}
private function connectComplete( event:Event ):void 
{
	txt.text = "Connecté, chargement des communes";
	
	Util.log( "Connecté à " + urlsite.text );
	
	sp.removeEventListener( Event.COMPLETE, connectComplete );
	
	sp.addEventListener( Event.COMPLETE, communesComplete );
	var db:Database = Database.getInstance();
	sp.GetList( session.dictListes["Communes"] );
	//this.navigator.pushView(VueCommunes);
}
private function communesComplete( event:Event ):void 
{
	txt.text = "Communes chargées";
	
	Util.log( "Connecté à " + urlsite.text );
	
	sp.removeEventListener( Event.COMPLETE, communesComplete );
	
	//this.navigator.pushView(CommunesView, event.target.data);
	this.navigator.pushView(VueCommunes);
}

