/////////////////////////////////////////////////////////////
// Auteur Bruce LANE
// Version du 28 janvier 2009
/////////////////////////////////////////////////////////////
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Mapping2D extends Sprite
	{
		private var _bmpOriginal:Bitmap; //le bitmap chargé original
		private var _bmpFond:Bitmap; //le bitmap affiché
		private var _bmpColorise:Bitmap; //le bitmap colorisé 
		private var _bmpMatFond:Bitmap3D; //le bitmap de matériau appliqué
		private var _bmpImage:Bitmap3D; //le bitmap de l'image ajoutée
		private var _bmpStylo:Bitmap3D; //le bitmap de l'image ajoutée
		private var _bmpTexte:Bitmap3D; //le bitmap conteneur du texte
		private var _bDataOriginal:BitmapData; // les pixels du bitmap chargé original
		private var _bDataCopie:BitmapData; //copie des pixels sans colorisation
		private var _bDataColor:BitmapData; //copie des pixels colorisés
		private var _bDataMatFond:BitmapData; // pixels du materiau
		private var _loader:Loader; //chargeur image bmp
	    private var _couleur:uint; //couleur de fond de colorisation du bitmap
	    private var _seuil:int; //seuil de bleu pour la colorisation du bitmap
	    private var _alpha:Number; //alpha de la colorisation du bitmap
	    private var _angle:int=-90; //angle du bitmap
	    private var _texte:Texte3D; //texte sur l'objet
	    private var _chemin:String; //chemin vers image bitmap sur laquelle on construit
		private	var _v:Array = new Array(); //variables du fichier XML
		private var _tlX:int;
		private var _tlY:int;
		private var _trX:int;
		private var _trY:int;
		private var _blX:int;
		private var _blY:int;
		private var _brX:int;
		private var _brY:int;

		private var _m1lxFull:int = 0;
		private var _m1lyFull:int = 0;
		private var _m1rxFull:int = 0;
		private var _m1ryFull:int = 0;
		private var _m2lxFull:int = 0;
		private var _m2lyFull:int = 0;
		private var _m2rxFull:int = 0;
		private var _m2ryFull:int = 0;
		private var _m1lxMedium:int = 0;
		private var _m1lyMedium:int = 0;
		private var _m1rxMedium:int = 0;
		private var _m1ryMedium:int = 0;
		private var _m2lxMedium:int = 0;
		private var _m2lyMedium:int = 0;
		private var _m2rxMedium:int = 0;
		private var _m2ryMedium:int = 0;
		private var _m1lx:int = 0;
		private var _m1ly:int = 0;
		private var _m1rx:int = 0;
		private var _m1ry:int = 0;
		private var _m2lx:int = 0;
		private var _m2ly:int = 0;
		private var _m2rx:int = 0;
		private var _m2ry:int = 0;

		private var _tlxFull:int;
		private var _tlyFull:int;
		private var _trxFull:int;
		private var _tryFull:int;
		private var _blxFull:int;
		private var _blyFull:int;
		private var _brxFull:int;
		private var _bryFull:int;
		private var _tlxMedium:int;
		private var _tlyMedium:int;
		private var _trxMedium:int;
		private var _tryMedium:int;
		private var _blxMedium:int;
		private var _blyMedium:int;
		private var _brxMedium:int;
		private var _bryMedium:int;
		private var _tlxSmall:int;
		private var _tlySmall:int;
		private var _trxSmall:int;
		private var _trySmall:int;
		private var _blxSmall:int;
		private var _blySmall:int;
		private var _brxSmall:int;
		private var _brySmall:int;
		private var _blurTexte:int = 0;
		private var _blurImage:int = 0;
		private	var _largTxt:int = 420;
		private	var _hautTxt:int = 63;
		private var _debug:Boolean;
		
		//Constructeur
		public function Mapping2D( xmlVars:String, debug:Boolean = false )
		{
			_debug = debug;
			trace( "Mapping2D, createVars:" + xmlVars );
			var ldrVar:URLLoader = new URLLoader(new URLRequest(xmlVars));
			ldrVar.addEventListener(Event.COMPLETE, createVars);
			super();
		}
		private function createVars(e:Event):void
		{
			//trace( "Mapping2D, createVars:"  );
			var xml:XML = new XML(e.target.data);
			var l:XMLList = xml.variable;
			
			for(var i:int=0; i<l.length(); i++)
			{
				_v[l[i].@nom] = l[i].@valeur;
				//trace(l[i].@nom + " = " + l[i].@valeur);
			}
			if (_v['largTxt']) _largTxt = _v['largTxt'];
			if (_v['hautTxt']) _hautTxt = _v['hautTxt'];
			if (_v['tlx']) _tlX = _v['tlx'];
			if (_v['tly']) _tlY = _v['tly'];
			if (_v['trx']) _trX = _v['trx'];
			if (_v['try']) _trY = _v['try'];
			if (_v['blx']) _blX = _v['blx'];
			if (_v['bly']) _blY = _v['bly'];
			if (_v['brx']) _brX = _v['brx'];
			if (_v['bry']) _brY = _v['bry'];
			if (_v['tlxFull']) _tlxFull = _v['tlxFull'];
			if (_v['tlyFull']) _tlyFull = _v['tlyFull'];
			if (_v['trxFull']) _trxFull = _v['trxFull'];
			if (_v['tryFull']) _tryFull = _v['tryFull'];
			if (_v['blxFull']) _blxFull = _v['blxFull'];
			if (_v['blyFull']) _blyFull = _v['blyFull'];
			if (_v['brxFull']) _brxFull = _v['brxFull'];
			if (_v['bryFull']) _bryFull = _v['bryFull'];
			if (_v['tlxMedium']) _tlxMedium = _v['tlxMedium'];
			if (_v['tlyMedium']) _tlyMedium = _v['tlyMedium'];
			if (_v['trxMedium']) _trxMedium = _v['trxMedium'];
			if (_v['tryMedium']) _tryMedium = _v['tryMedium'];
			if (_v['blxMedium']) _blxMedium = _v['blxMedium'];
			if (_v['blyMedium']) _blyMedium = _v['blyMedium'];
			if (_v['brxMedium']) _brxMedium = _v['brxMedium'];
			if (_v['bryMedium']) _bryMedium = _v['bryMedium'];
			if (_v['tlxSmall']) _tlxSmall = _v['tlxSmall'];
			if (_v['tlySmall']) _tlySmall = _v['tlySmall'];
			if (_v['trxSmall']) _trxSmall = _v['trxSmall'];
			if (_v['trySmall']) _trySmall = _v['trySmall'];
			if (_v['blxSmall']) _blxSmall = _v['blxSmall'];
			if (_v['blySmall']) _blySmall = _v['blySmall'];
			if (_v['brxSmall']) _brxSmall = _v['brxSmall'];
			if (_v['brySmall']) _brySmall = _v['brySmall'];
			if (_v['chemin']) _chemin = _v['chemin'];
			if (_v['alpha']) _alpha = _v['alpha'];
			if (_v['seuil']) _seuil = _v['seuil'];
			if (_v['angle']) _angle = _v['angle'];
			if (_v['blurTexte']) _blurTexte = _v['blurTexte'];
			if (_v['blurImage']) _blurImage = _v['blurImage'];
			if (_v['m1lxFull']) _m1lxFull = _v['m1lxFull'];
			if (_v['m1lyFull']) _m1lyFull = _v['m1lyFull'];
			if (_v['m1rxFull']) _m1rxFull = _v['m1rxFull'];
			if (_v['m1ryFull']) _m1ryFull = _v['m1ryFull'];
			if (_v['m2lxFull']) _m2lxFull = _v['m2lxFull'];
			if (_v['m2lyFull']) _m2lyFull = _v['m2lyFull'];
			if (_v['m2rxFull']) _m2rxFull = _v['m2rxFull'];
			if (_v['m2ryFull']) _m2ryFull = _v['m2ryFull'];
			if (_v['m1lxMedium']) _m1lxMedium = _v['m1lxMedium'];
			if (_v['m1lyMedium']) _m1lyMedium = _v['m1lyMedium'];
			if (_v['m1rxMedium']) _m1rxMedium = _v['m1rxMedium'];
			if (_v['m1ryMedium']) _m1ryMedium = _v['m1ryMedium'];
			if (_v['m2lxMedium']) _m2lxMedium = _v['m2lxMedium'];
			if (_v['m2lyMedium']) _m2lyMedium = _v['m2lyMedium'];
			if (_v['m2rxMedium']) _m2rxMedium = _v['m2rxMedium'];
			if (_v['m2ryMedium']) _m2ryMedium = _v['m2ryMedium'];
			init();
		}
		private function onImageLoaded( evt:Event ):void
		{
			trace("mapping2d onImageLoaded" );
			if (evt) 
			{
				_bmpOriginal = Bitmap ( evt.target.content );
				_bmpOriginal.smoothing = true;
				_bDataOriginal = new BitmapData(_bmpOriginal.bitmapData.width,_bmpOriginal.bitmapData.height);
				_bDataOriginal = _bmpOriginal.bitmapData;
				var tEvent:TextEvent = new TextEvent("imageLoaded");
				tEvent.text = _chemin;
				dispatchEvent(tEvent);
			}
		}
		public function changeFond(couleurFond:uint = 0xD6CEAA ):void
		{
			var nbChange:int = 0 ;
			_couleur = couleurFond;
			if ( ( _bmpOriginal ) &&  ( _bmpOriginal is Bitmap ) ) 
			{
				if ( _bmpFond ) this.removeChild( this.getChildByName( "bmpFond" ) );
				_bmpFond = null;
				if ( _bmpColorise ) this.removeChild( this.getChildByName( "bmpColor" ) );
				_bmpColorise = null;
	            if ( _bDataCopie ) _bDataCopie = null;
	            if ( !_bDataCopie ) _bDataCopie = _bDataOriginal.clone();
	            if ( _bDataColor ) _bDataColor = null;
	            if ( !_bDataColor ) _bDataColor = new BitmapData( _bDataOriginal.width, _bDataOriginal.height, true);
				_bmpFond = new Bitmap(_bDataCopie);
				_bmpColorise = new Bitmap(_bDataColor);
				
	            for ( var i:int=0; i < _bmpOriginal.width; i++ )
	            {
	            	for ( var j:int=0; j < _bmpOriginal.height; j++ )
	            	{
	            		if ( ( _bDataOriginal.getPixel32( i, j ) & 0xFF ) > _seuil )
	            		{
	            			nbChange++;
	            			_bDataColor.setPixel( i, j, _couleur);
	            		}
	            		else
	            		{
	            			_bDataColor.setPixel32( i, j, 0x00000000);
	            		}
	            		
	            	}
	            }
				//trace("changeFond_chg:" + nbChange);
	           	_bmpFond.name = "bmpFond";
	            _bmpColorise.alpha = _alpha;
	           	_bmpColorise.name = "bmpColor";
	            this.addChild( _bmpFond );
	            this.addChild( _bmpColorise );
			}
		}
		public function changeMateriau( materiau:BitmapData, paysage:Boolean = false ):void
		{
			//trace("changeMateriau:" );
			if ( _bmpMatFond ) this.removeChild( this.getChildByName( "bmpMat" ) );
			_bmpMatFond = new Bitmap3D( "bmpMat", materiau, _couleur, _tlxFull, _tlyFull, _trxFull, _tryFull, _blxFull, _blyFull, _brxFull, _bryFull, paysage, _debug, _blurImage );
			this.addChild( _bmpMatFond );
			_bmpMatFond.name = "bmpMat";
		}
		public function changeImage( nomBmpImage:String, image:BitmapData, typeObjet:String = "full", paysage:Boolean = false ):void
		{	
			initVars(typeObjet);
			if ( nomBmpImage == "bmpStylo" )
			{
				if ( _bmpStylo ) this.removeChild( this.getChildByName( nomBmpImage ) );
			
				_bmpStylo = new Bitmap3D( nomBmpImage, image, _couleur, _tlX, _tlY, _trX, _trY, _blX, _blY, _brX, _brY, paysage, _debug,_blurImage,0,0,0,0,0,0,0,0, _bDataColor, _angle );
				
				this.addChild( _bmpStylo );
				_bmpStylo.name = nomBmpImage;
			}
			else
			{
				if ( _bmpImage ) this.removeChild( this.getChildByName( nomBmpImage ) );
				if ( paysage )
				{
					_bmpImage = new Bitmap3D( nomBmpImage, image, _couleur, _blX, _blY, _tlX, _tlY, _brX, _brY, _trX, _trY, false, _debug,_blurImage,_m1lx,_m1ly,_m2lx,_m2ly,_m1rx,_m1ry,_m2rx,_m2ry );
				}
				else
				{
					_bmpImage = new Bitmap3D( nomBmpImage, image, _couleur, _tlX, _tlY, _trX, _trY, _blX, _blY, _brX, _brY, paysage, _debug,_blurImage,_m1lx,_m1ly,_m2lx,_m2ly,_m1rx,_m1ry,_m2rx,_m2ry );
				}
				this.addChild( _bmpImage );
				_bmpImage.name = nomBmpImage;
			}
		}
		public function changeTexte( texte:String, typeObjet:String, police:String, taillePolice:int, couleur:uint, horizontal:Boolean = true, angle:int = 270, stylo:Boolean = false ):void
		{
			initVars(typeObjet);
			//trace("changeTexte:" + texte);
			if ( texte.length > 0 )
			{
				var facteur:Number;
				var _tlyTxt:int = 0;
				if ( _largTxt > 300 ) 
				{
					facteur = (_trX - _tlX) / 250;
				} 
				else 
				{
					facteur = (_trX - _tlX) / 120;
					_tlyTxt = 36 - taillePolice;
				}
				if ( facteur == 0 ) facteur = 1; // TODO qd images pas chargées, trx et tlx = 0
				if ( horizontal )
				{
					_texte = new Texte3D( "texte", texte, police, taillePolice, 0,_tlyTxt,0,0,0,0,0,0, _largTxt * facteur, _hautTxt * facteur, couleur, _couleur,horizontal,90,_debug );
				}
				else
				{
					 _texte = new Texte3D( "texte", texte, police, taillePolice, 0,_tlyTxt,0,0,0,0,0,0, taillePolice/1.5, _largTxt * facteur + taillePolice +40, couleur, _couleur,horizontal,90,_debug );
				}

				_texte.name = "texte";   
//trace("_largTxt:" + _largTxt + "_hautTxt:" + _hautTxt + "w:" + _texte.width + "h:" + _texte.height );
				var tmpBD:BitmapData ;
				var tmpBitmap:Bitmap;
				
				tmpBD = new BitmapData( _texte.width, _texte.height, true, 0x00000000 );
				tmpBitmap = new Bitmap( tmpBD );
				tmpBD.draw( _texte );
				
				if ( _bmpTexte ) this.removeChild( this.getChildByName( "bmpTexte" ) );
				if ( ( _bmpImage ) && ( typeObjet != "full" ) )
				{
					if ( horizontal )
					{
						_bmpTexte = new Bitmap3D( "bmpTexte", tmpBD, _couleur, _blX, _blY, _brX, _brY, _blX+(_blX-_tlX),_blY+(_blY-_tlY),_brX+(_brX-_trX),_brY+(_brY-_trY),false,_debug,_blurTexte );
					}
					else
					{
						_bmpTexte = new Bitmap3D( "bmpTexte", tmpBD, _couleur, _blX+(_blX-_tlX),_blY+(_blY-_tlY), _blX, _blY, _brX+(_brX-_trX),_brY+(_brY-_trY), _brX, _brY,true,_debug,_blurTexte );
					}
				}
				else
				{// pas d image mode memo
					if ( horizontal )
					{
						var xDecal:Number = 0;
						var yDecal:Number = 0;
						if ( !stylo )
						{
							var hMax:int = 600;
							var xDemi:Number = ( _blX - _tlX ) / 2;
							var yDemi:Number = ( _blY - _tlY ) / 2;
							if ( xDemi < 0 )
							{
								xDecal = Math.min( xDemi + ( _texte.hauteur() * -xDemi / hMax ), 0);
							}
							else
							{
								xDecal = Math.max( xDemi + ( _texte.hauteur() * -xDemi / hMax ), 0);
							}
							if ( xDecal == 0 )
							{ 
								yDecal = 0;
							}
							else
							{
								yDecal = yDemi + ( _texte.hauteur() * -yDemi / hMax );	
							} 
						}
						_bmpTexte = new Bitmap3D( "bmpTexte", tmpBD, _couleur, _tlX+xDecal, _tlY+yDecal, _trX+xDecal, _trY+yDecal, _blX+xDecal, _blY+yDecal, _brX+xDecal, _brY+yDecal,false,_debug, _blurTexte );
					}
					else
					{
						_bmpTexte = new Bitmap3D( "bmpTexte", tmpBD, _couleur, _blX, _blY, _tlX, _tlY, _brX, _brY, _trX, _trY,true,_debug, _blurTexte );
					}
				}
				this.addChild( _bmpTexte );
				_bmpTexte.name = "bmpTexte"; 
			}  
			//trace( "hauteur texte: " + _texte.hauteur() );
		}
		public function supprimeImage():void
		{
			if ( _bmpImage ) this.removeChild( this.getChildByName( "bmpImage" ) );
			_bmpImage = null;
		}
		private function initVars(typeObjet:String = "full"):void 
		{
			switch (typeObjet)
 			{
 				case 'medium':
 					_tlX= _tlxMedium; _tlY= _tlyMedium; _trX= _trxMedium; _trY= _tryMedium;
					_blX= _blxMedium; _blY= _blyMedium; _brX= _brxMedium; _brY= _bryMedium;
 					_m1lx= _m1lxMedium; _m1ly= _m1lyMedium; _m1rx= _m1rxMedium; _m1ry= _m1ryMedium;
					_m2lx= _m2lxMedium; _m2ly= _m2lyMedium; _m2rx= _m2rxMedium; _m2ry= _m2ryMedium;
					break;
 				case 'small':
					_tlX= _tlxSmall; _tlY= _tlySmall; _trX= _trxSmall; _trY= _trySmall;
					_blX= _blxSmall; _blY= _blySmall; _brX= _brxSmall; _brY= _brySmall;
 					break;
 				default:
					_tlX= _tlxFull; _tlY= _tlyFull; _trX= _trxFull; _trY= _tryFull;
					_blX= _blxFull; _blY= _blyFull; _brX= _brxFull; _brY= _bryFull;
					_m1lx= _m1lxFull; _m1ly= _m1lyFull; _m1rx= _m1rxFull; _m1ry= _m1ryFull;
					_m2lx= _m2lxFull; _m2ly= _m2lyFull; _m2rx= _m2rxFull; _m2ry= _m2ryFull;
 					break;
 			}
 		}
		private function init():void
 		{
			_loader = new Loader() ;
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			if ( _chemin ) loadBmp( _chemin );

		}
		private function loadBmp( chemin:String ):void
 		{
 			_loader.load( new URLRequest( chemin ) );
		}
		private function ioErrorHandler( evt:IOErrorEvent ):void 
		{
            trace("Erreur chargement...");
        }

	}
}