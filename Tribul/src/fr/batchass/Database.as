package fr.batchass
{
	import events.DonneesEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.desktop.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	
	import fr.batchass.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	public class Database implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private static var instance:Database;
		private var sqlAsyncConn:SQLConnection;
		private var sqlFile:File;
		private var _acCommunes:ArrayCollection;

		private var defaultDbXmlPath:String = 'config' + File.separator + 'db.xml';
		public var cheminBase:String;
		private static var DB_XML:XML;

		//constructeur
		public function Database()
		{
			Util.log( "Database, constructor" );
			cheminBase = File.applicationStorageDirectory.resolvePath( "import" ).nativePath;
			// cree et/ou ouvre dossier et la base de donnees dedans
			ouvreDb();
		
			dispatcher = new EventDispatcher(this);
		}
		public function ouvreDb():void
		{
			var folderPath:String = File.applicationStorageDirectory.resolvePath("db").nativePath;
			var folder:File = new File( folderPath );
			// creates folder if it does not exists
			if (!folder.exists) 
			{
				Util.log('Creating folder: ' + folderPath);
				// create the directory
				folder.createDirectory();
				if (!folder.exists) Util.log('Could not create: ' + folderPath);
			}
			sqlFile = File.applicationStorageDirectory.resolvePath("db" + File.separator + "tribul.sqlite");
			if (!sqlFile.exists) 
			{
				Util.log('tribul.sqlite existe pas on copie celle par défaut: ');
				//copie à partir du dossier progFiles
				var sourceFile:File = File.applicationDirectory.resolvePath( "db" + File.separator + "tribul.sqlite" );
				if ( sourceFile.exists )
				{
					sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					try 
					{
						sourceFile.copyTo( sqlFile );
					}
					catch (error:Error)
					{
						Util.log( "copie tribul.sqlite erreur:" + error.message );
					}
				}
				else Util.log( "tribul.sqlite existe pas" );	
			}
			Util.log('Ouverture: ' + folderPath);
			sqlAsyncConn = new SQLConnection();
			sqlAsyncConn.addEventListener( SQLEvent.OPEN, verifieTables );
			sqlAsyncConn.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			sqlAsyncConn.openAsync( sqlFile, SQLMode.CREATE );
		}
		public function ouvrirBDParDefaut():void
		{
			Util.log("ouvrirBDParDefaut, fermeture connections" );	
			sqlAsyncConn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			sqlAsyncConn.addEventListener(SQLEvent.CLOSE, fermeBDetSupprimeBD);	
			sqlAsyncConn.close();
		}
		private function fermeBDetSupprimeBD(ev:SQLEvent):void
		{
			Util.log("fermeBDetSupprimeBD" );	
			if (sqlAsyncConn) sqlAsyncConn.removeEventListener(SQLEvent.CLOSE, fermeBDetSupprimeBD);
			//fermeDb();
			var sourceFile:File = File.applicationDirectory.resolvePath( "db" + File.separator + "tribul.sqlite" );
			if ( sourceFile.exists )
			{
				sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				try 
				{
					sqlFile.deleteFile();
					sourceFile.copyTo( sqlFile );
				}
				catch (error:Error)
				{
					Util.log( "copie tribul.sqlite erreur:" + error.message );
				}
				sqlAsyncConn = new SQLConnection();
				sqlAsyncConn.addEventListener( SQLEvent.OPEN, verifieTables );
				sqlAsyncConn.addEventListener( SQLErrorEvent.ERROR, errorHandler );
				sqlAsyncConn.openAsync( sqlFile, SQLMode.CREATE );

			}
			else Util.log( "tribul.sqlite existe pas" );				
		}
		
		private function errorHandler( error:SQLErrorEvent ):void
		{
			Util.log( "Sqlite error id:" + error.errorID );
			Util.log( "Sqlite error message:" + error.error.message );
			Util.log( "Sqlite error details:" + error.error.details );
			if ( error.currentTarget && error.currentTarget.text ) Util.log( "Sqlite error statement:" + error.currentTarget.text );
		}
		public function fermeDb():void
		{
			Util.log("fermeDb, fermeture connections" );	
			sqlAsyncConn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			sqlAsyncConn.close();
		}
		
		private function supprimeTable(nomTable:String):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = "DROP TABLE IF EXISTS " + nomTable;
			stmt.execute();			
			var result:SQLResult = stmt.getResult();
		}
		private function effaceContenuTable(nomTable:String):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = "DELETE FROM " + nomTable;
			stmt.execute();			
			var result:SQLResult = stmt.getResult();
		}
		private function verifieTables( event:SQLEvent ):void
		{
			creeTables(false);				
		}		
		public function creeTables(suppression:Boolean):void
		{
			Util.log('creeTables: ' + defaultDbXmlPath);
			var dbFile:File = File.applicationStorageDirectory.resolvePath( defaultDbXmlPath );
			
			if ( !dbFile.exists )
			{
				Util.log( "db.xml existe pas" );				
				//copie à partir du dossier progFiles
				var sourceFile:File = File.applicationDirectory.resolvePath( defaultDbXmlPath );
				Util.log("creeTables, fichier inexistant on copie à partir de: " + sourceFile.nativePath );					
				if ( sourceFile.exists )
				{
					sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					try 
					{
						sourceFile.copyTo( dbFile );
					}
					catch (error:Error)
					{
						Util.log( "copie db.xml erreur:" + error.message );
					}
				}
				else Util.log( "db.xml existe pas" );	
			}
			if ( dbFile.exists )
			{
				Util.log( "db.xml existe, chargement fichier xml" );
				DB_XML = new XML( readTextFile( dbFile ) );
				var tableListe:XMLList = DB_XML..table as XMLList;
				for each ( var table:XML in tableListe )
				{
					var dejaImporte:Boolean = false;
					var nom:String = table.@nom;
					if ( suppression )
					{
						/*Util.log( "Suppression table: " + nom );
						supprimeTable(nom);*/
						/*Util.log( "effaceContenuTable table: " + nom );
						effaceContenuTable(nom);*/
					}
					var stmt:SQLStatement = new SQLStatement();
					stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
					var statement:String = "CREATE TABLE IF NOT EXISTS " + nom + " ("; 
					var clesEtrangeres:String = ""; 
					var champsAcreer:Array = new Array();// "ref_commune","commune")			
					var champListe:XMLList = table..champ as XMLList;
					var premierChamp:Boolean = true;
					var clesPrimaires:String = "";
					
					for each ( var champ:XML in champListe )
					{
						var nomChamp:String = champ.@nom.toString();
						var cleChamp:String = champ.@cle.toString();
						var cleEtrangereChamp:String = champ.@cle_etrangere.toString();
						var clesPrim:String = champ.@cles_primaires.toString();
						var nouveauNom:String = champ.@nouveaunom.toString();
						if ( clesPrim.length > 0 ) clesPrimaires = clesPrim;						
						if ( premierChamp ) premierChamp = false else statement += ",";
						switch ( cleChamp )
						{
							case "PK":
								champsAcreer.push(nomChamp);
								statement += nomChamp + " TEXT PRIMARY KEY ON CONFLICT REPLACE ";
								break;
							case "PKAI":
								statement += nomChamp + " INTEGER PRIMARY KEY AUTOINCREMENT ";
								break;
							case "FK":
								champsAcreer.push(nomChamp);
								statement += nomChamp + " TEXT ";
								clesEtrangeres += ", FOREIGN KEY(" + nomChamp + ") REFERENCES " + cleEtrangereChamp; 
								break;
							default:
								champsAcreer.push(nomChamp);
								statement += nomChamp + " TEXT";
								break;
						}
					}
					if ( !dejaImporte ) 
					{
						statement += clesEtrangeres;
						statement += clesPrimaires;
						statement += ")";
						Util.log( "SQL creation table: " + statement );
						stmt.text = statement;
						stmt.sqlConnection = sqlAsyncConn;
						stmt.execute();

					}
				}
			}
		}
		public function insert( nomTable:String, champ:String, valeur:String ):void
		{
			"INSERT INTO "+ nomTable + " (" + 
				champ +
				") VALUES (" + 
				valeur +
				")";
		}

		public function getCommunes():void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLEvent.RESULT, remplitCommunes );
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = 'SELECT DISTINCT commune FROM communes';

			stmt.execute();
		}	
		private function remplitCommunes( event:SQLEvent ):void
		{
			var stmt:SQLStatement = SQLStatement(event.target);
			var result:SQLResult = stmt.getResult();
			acCommunes = new ArrayCollection();	
			if (result.data)
			{
				var numResults:int = result.data.length;
				Util.log('remplitCommunes, nb: ' + numResults.toString() );
				for (var i:int = 0; i < numResults; i++)
				{
					var row:Object = result.data[i];
					var id_moteur:String = row.id_moteur;
					if ( id_moteur.length > 0 ) acCommunes.addItem({id_moteur: row.id_moteur, din:row.din});
				}
			}	
			dispatchEvent( new Event(Event.COMPLETE) );							
			dispatchEvent( new DonneesEvent(DonneesEvent.ON_COMMUNES, acCommunes) );
		}


		public static function getInstance():Database
		{
			if (instance == null)
			{
				instance = new Database();
			}
			
			return instance;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		private function ioErrorHandler( event:IOErrorEvent ):void
		{
			Util.log( 'Database, An IO Error has occured: ' + event.text );
		}    
		// only called if a security error detected by flash player such as a sandbox violation
		private function securityErrorHandler( event:SecurityErrorEvent ):void
		{
			Util.log( "Database, securityErrorHandler: " + event.text );
		}
		private function onExit(evt:NativeProcessExitEvent):void
		{
			Util.log( "Process ended with code: " + evt.exitCode); 
		}

		[Bindable]
		public function get acCommunes():ArrayCollection
		{
			return _acCommunes;
		}

		public function set acCommunes(value:ArrayCollection):void
		{
			_acCommunes = value;
		}


	}//class end
}//package end