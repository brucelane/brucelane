package fr.batchass
{
	import events.DonneesEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.desktop.*;
	import flash.errors.SQLError;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	
	import fr.batchass.*;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	
	public class Database implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private static var instance:Database;
		private var sqlAsyncConn:SQLConnection;
		private var sqlFile:File;
		private var _acCommunes:ArrayList;

		private var defaultDbXmlPath:String = 'config' + File.separator + 'db.xml';
		public var cheminBase:String;
		private static var DB_XML:XML;
		private static var champsDictionary:Dictionary = new Dictionary();

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
			Util.log("errorHandler" );	
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
			Util.log("supprimeTable: "  + nomTable);	
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = "DROP TABLE IF EXISTS " + nomTable;
			stmt.execute();			
			var result:SQLResult = stmt.getResult();
		}
		private function effaceContenuTable(nomTable:String):void
		{
			Util.log("effaceContenuTable: "  + nomTable);	
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = "DELETE FROM " + nomTable;
			stmt.execute();			
			var result:SQLResult = stmt.getResult();
		}
		private function verifieTables( event:SQLEvent ):void
		{
			Util.log("verifieTables" );	
			creeTables(true);				
		}		
		public function creeTables(suppression:Boolean):void
		{
			Util.log( "creeTables: " + defaultDbXmlPath + " suppression: " + suppression );
			var dbXmlFile:File = File.applicationStorageDirectory.resolvePath( defaultDbXmlPath );
			
			if ( !dbXmlFile.exists )
			{
				Util.log( "db.xml existe pas dans l'appli" );
				//copie à partir du dossier progFiles
				var sourceFile:File = File.applicationDirectory.resolvePath( defaultDbXmlPath );
				Util.log("creeTables, fichier inexistant on copie à partir de: " + sourceFile.nativePath );					
				if ( sourceFile.exists )
				{
					sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
					try 
					{
						sourceFile.copyTo( dbXmlFile );
					}
					catch (error:Error)
					{
						Util.log( "copie db.xml erreur:" + error.message );
					}
				}
				else Util.log( "db.xml existe pas dans progFiles" );	
			}
			if ( dbXmlFile.exists )
			{
				Util.log( "db.xml existe, chargement fichier xml" );
				DB_XML = new XML( readTextFile( dbXmlFile ) );
				var tableListe:XMLList = DB_XML..table as XMLList;
				for each ( var table:XML in tableListe )
				{
					var nom:String = table.@nom;
					if ( suppression )
					{
						Util.log( "Suppression table: " + nom );
						supprimeTable( nom );
					}
					verifieExistenceTable( nom, table);
				} //for
			}
		}
		private function verifieExistenceTable(nomTable:String, table:XML):void
		{
			Util.log( "verifieExistenceTable" );	
			//var ev:SQLEvent = new SQLEvent(SQLEvent.RESULT);
			var st:SQLStatement = new SQLStatement();
			//test si base ouverte
			Util.log("SQL: base ouverte:" + sqlAsyncConn.connected);
			st.addEventListener( SQLEvent.RESULT, existe );
			st.addEventListener( SQLErrorEvent.ERROR, existePas );		
			st.sqlConnection = sqlAsyncConn;
			st.text = "SELECT COUNT(*) AS compte FROM " + nomTable + " /*" + table.toString() + "*/";	
			st.execute();
		}
		private function existe( event:SQLEvent )
		{
			Util.log( "existe" );	
			var nomTable:String = "";
			var st:SQLStatement = SQLStatement(event.target);
			var result:SQLResult = st.getResult();
			st.removeEventListener( SQLEvent.RESULT, existe );
			st.removeEventListener( SQLErrorEvent.ERROR, existePas );		
			if ( event.currentTarget && event.currentTarget.text && event.currentTarget.parameters.table )
			{
				nomTable = event.currentTarget.parameters.table;
				Util.log( "existe:" + nomTable );
			}
			
			if (result.data)
			{
				var numResults:int = result.data.length;
				Util.log('existe, nb: ' + numResults.toString() );
				for (var i:int = 0; i < numResults; i++)
				{
					var row:Object = result.data[i];
					var count:String = row.compte;
					Util.log("SQL: Table found " + nomTable + " count:"+ count);
					var cnt:int = count as int;
					Util.log("cnt:"+ cnt);
					if ( cnt > 0 ) 
					{
					}
					else
					{
						
					}
				}
			}	
			else
			{
				//test si base ouverte
				Util.log("SQL: base ouverte:" + sqlAsyncConn.connected);
				Util.log("SQL: base en transaction:" + sqlAsyncConn.inTransaction);
			}
			
		}
		
		private function existePas( error:SQLErrorEvent ):void
		{
			Util.log("existePas" );	
			Util.log( "Sqlite error id:" + error.errorID );
			Util.log( "Sqlite error message:" + error.error.message );
			Util.log( "Sqlite error details:" + error.error.details );
			//test si base ouverte
			Util.log("SQL: base ouverte:" + sqlAsyncConn.connected);
			Util.log("SQL: base en transaction:" + sqlAsyncConn.inTransaction);
			
			var st:SQLStatement = SQLStatement(error.target);
			var sqlText:String = st.text;
			var tableXML:XML = new XML( sqlText.substring( sqlText.lastIndexOf("/*") + 2, sqlText.length - 2 ) );

			creeTable( tableXML );
		}
		private function creeTable( table:XML ):void
		{
			Util.log("creeTable" );	
			var nomTable:String = table.@nom;
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			var statement:String = "CREATE TABLE IF NOT EXISTS " + nomTable + " ("; 
			var clesEtrangeres:String = ""; 
			var champsAcreer:Array = new Array();// "commune",etc		
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
			}//for
			champsDictionary[nomTable] = champsAcreer;
			
			statement += clesEtrangeres;
			statement += clesPrimaires;
			statement += ") --";
			statement += nomTable;
			Util.log( "SQL creation table: " + statement );
			stmt.addEventListener( SQLEvent.RESULT, succesCreationTable );
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.text = statement;
			stmt.sqlConnection = sqlAsyncConn;
			stmt.execute();
			//importCsv( nom, champsAcreer );	
		}
		private function succesCreationTable( event:SQLEvent )
		{
			var st:SQLStatement = SQLStatement(event.target);
			var result:SQLResult = st.getResult();
			var sqlText:String = st.text;
			var nomTable:String = sqlText.substr( sqlText.lastIndexOf("--") + 2 );

			importCsv( nomTable );				
		}
		private function importCsv(nomTable:String):void
		{
			var tableauChamps:Array = champsDictionary[nomTable];


			var csvFile:String = cheminBase + File.separator + nomTable + ".csv";
			var csv:File = File.applicationStorageDirectory.resolvePath(csvFile);
			Util.log("ImportCsv: " + csvFile );					
			if (!csv.exists)
			{
				//copie à partir du dossier progFiles
				var sourceFile:File = File.applicationDirectory.resolvePath(csvFile);
				Util.log("ImportCsv, fichier inexistant on copie à partir de: " + sourceFile.nativePath );					
				sourceFile.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				sourceFile.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
				try 
				{
					sourceFile.copyTo( csv );
				}
				catch (error:Error)
				{
					Util.log( "copyCsv Error:" + error.message );
				}
			}
			if (csv.exists)
			{
				var importFile:File = File.applicationStorageDirectory.resolvePath( csvFile );
				var contenu:String = readTextFile(importFile); 
				var lignes:Array = contenu.split( "\r\n" );
				var numerosChampsTrouves:Array = new Array();
				var champsTrouves:Boolean = false;
				var premiereValeur:Boolean = true;
				var insertChamps:String = "";
				var insertValeurs:String = "";
				var nombreChamps:int=0;
				var ordre_ref_bosch_fk:int = -1;
				Util.log("ImportCsv, nombre de lignes: " + lignes.length );					
				for each (var ligne:String in lignes)
				{
					
					var champs:Array = ligne.split( ";" );
					if (!champsTrouves)
					{				
						var ordre:int = 0;
						//1e ligne contient noms des champs
						for each (var champ:String in champs)
						{
							//creer tableau des ordres
							if (tableauChamps.indexOf(champ)>-1)
							{
								//if ( nomChampNumerique.length > 0 ) ordre_ref_bosch_fk = ordre;
								numerosChampsTrouves.push(ordre++);
								nombreChamps++;
								if (!champsTrouves)
								{
									insertChamps += champ;
									champsTrouves = true;							
								}
								else
								{
									insertChamps += "," + champ;							
								}							
							}
							else
							{
								if (champ.length>0)
								{
									Util.log("champ inconnu: " + champ);
									ordre++;								
								}
							}
						}//for
						Util.log("ImportCsv, champs 1e ligne: " + insertChamps );					
					}
					else
					{
						// ce sont des donnees
						var ordreValeur:int = 0;
						var nombreValeurs:int = 0;

						premiereValeur = true;
						insertValeurs = "";
						for each (var valeur:String in champs)
						{
							if ( numerosChampsTrouves.indexOf(ordreValeur)>-1)
							{
								if (premiereValeur)
								{
									premiereValeur = false;								
								}
								else
								{
									insertValeurs += ",";	
								}
								insertValeurs += '"' + valeur + '"';	
								
								nombreValeurs++;
							}
							
							ordreValeur++;	
						}//for
						if ( nombreChamps == nombreValeurs )
						{
							
							var stmt:SQLStatement = new SQLStatement();
							//stmt.addEventListener( SQLEvent.RESULT, insere );
							stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
							stmt.sqlConnection = sqlAsyncConn;
							stmt.text =
									"INSERT INTO "+ nomTable + " (" + 
									insertChamps +
									") VALUES (" + 
									insertValeurs +
									")";
													
							//Util.log("insert1: "+stmt.text);
							//gerer erreur SQLError: 'Error #3115: SQL Error.', details:'near '101': syntax error', operation:'execute', detailID:'2003'
							stmt.execute();
						}//if
						else
						{							
							Util.log("ImportCsv, nombreChamps != nombreValeurs , c= " + nombreChamps + " v=" + nombreValeurs);	
						}
					}//if
				}//for each ligne				
			}
		}

		public function insert( nomTable:String, champ:String, valeur:String ):void
		{
			
			var stmt:SQLStatement = new SQLStatement();
			//stmt.addEventListener( SQLEvent.RESULT, insereProduits_Vehicule );
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = "INSERT INTO "+ nomTable + " (" + 
				champ +
				") VALUES ('" + 
				valeur +
				"')";						
			Util.log("insert: "+stmt.text);
			//gerer erreur SQLError: 'Error #3115: SQL Error.', details:'near '101': syntax error', operation:'execute', detailID:'2003'
			stmt.execute();
		}

		public function getCommunes():void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener( SQLEvent.RESULT, remplitCommunes );
			stmt.addEventListener( SQLErrorEvent.ERROR, errorHandler );
			stmt.sqlConnection = sqlAsyncConn;
			stmt.text = 'SELECT DISTINCT commune FROM communes ORDER BY commune';

			stmt.execute();
		}	
		private function remplitCommunes( event:SQLEvent ):void
		{
			var stmt:SQLStatement = SQLStatement(event.target);
			var result:SQLResult = stmt.getResult();
			acCommunes = new ArrayList();	
			if (result.data)
			{
				var numResults:int = result.data.length;
				Util.log('remplitCommunes, nb: ' + numResults.toString() );
				for (var i:int = 0; i < numResults; i++)
				{
					var row:Object = result.data[i];
					var commune:String = row.commune;
					if ( commune.length > 0 ) acCommunes.addItem({commune: row.commune});
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
		public function get acCommunes():ArrayList
		{
			return _acCommunes;
		}

		public function set acCommunes(value:ArrayList):void
		{
			_acCommunes = value;
		}


	}//class end
}//package end