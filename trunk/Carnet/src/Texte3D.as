package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.Application;

	public class Texte3D extends Sprite
	{
		private var handle_TL:Sprite;
		private var handle_TR:Sprite;
		private var handle_BL:Sprite;
		private var handle_BR:Sprite;
		private var _w:int;
		private var _h:int;
		private var container:Sprite;
		private var triangleLines:Sprite;
		private var _bmd:BitmapData;
		private var _bmp:Bitmap;
		private var _nom:String;
		private	var _v:Array = new Array();
		private var _tlxTxt:int;
		private var _tlyTxt:int;
		private	var _rotXS:int = 41;
		private	var _rotYS:int = 331;
		private	var _rotZS:int = 164;
		private	var _rotVXS:int = 330;
		private	var _rotVYS:int = 70;
		private	var _rotVZS:int = 264;
		private	var _largTxt:int = 230;
		private	var _hautTxt:int = 63;
		private	var _horizontal:Boolean;
	    private var _tf:TextField; //controle texte
		private var _texte:String;
		private var _police:String;
		private var _taillePolice:int;
		private var _couleur:uint;
		private var _couleurFond:uint;
		private var _angle:int = 270;
		private var _debug:Boolean;
		//Constructeur
		public function Texte3D( nom:String, texte:String, police:String, taillePolice:int, tlxTxt:int, tlyTxt:int, rotXS:int, rotYS:int, rotZS:int, rotVXS:int, rotVYS:int, rotVZS:int, largTxt:int, hautTxt:int, couleur:uint, couleurFond:uint, horizontal:Boolean = true, angle:int = 270, debug:Boolean = false )
		{
			_debug = debug;
			_nom = nom;
			_horizontal = horizontal;
			_texte = texte;
			_police = police;
			_taillePolice = taillePolice;
			_couleur = couleur;
			_couleurFond = couleurFond;
			_angle = angle;
			_tlxTxt = tlxTxt;
			_tlyTxt = tlyTxt;
			_rotXS = rotXS;
			_rotYS = rotYS;
			_rotZS = rotZS;
			_rotVXS = rotVXS;
			_rotVYS = rotVYS;
			_rotVZS = rotVZS;
			_largTxt = largTxt;
			_hautTxt = hautTxt;
 			initImage();
			drawText();
			super();
		}

		private function initImage():void {
			// Create the container Sprite to draw to and center on the stage.
			container = new Sprite();
			container.x = _tlxTxt;
			container.y = _tlyTxt;
			//container.alpha=0;
			this.addChild(container);
			if (_debug)
			{	//ATTENTION Erreur InvalidBitmapData si _largTxt ou _hautTxt = 0
				_bmd = new BitmapData( _largTxt, _hautTxt, false, 0xAA);
			}
			else
			{
				_bmd = new BitmapData( _largTxt, _hautTxt, true, 0x00FF0000); 
			}
			_bmd.draw( createTexte( _texte, createFormat(_police, _taillePolice, _couleur), _largTxt ) );
		 	container.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingContainer);
			container.addEventListener(MouseEvent.MOUSE_UP, stopDraggingContainer); 
		}
		private function createTexte( texte:String, format:TextFormat, width:int ):TextField
		{
			if (_tf) _tf = null;
			_tf = new TextField(); 
			_tf.htmlText = texte; 
			_tf.wordWrap = true;
			_tf.multiline = true;
			_tf.border = _debug;
			//PO_tf.embedFonts = true;
			//_tf.antiAliasType = AntiAliasType.ADVANCED;//SERT A RIEN
			_tf.autoSize = TextFieldAutoSize.CENTER;
			_tf.width = width; 
			_tf.setTextFormat(format); 
			_tf.background = false;
			//_tf.backgroundColor = 0xFF0000;
			return _tf;			
		}	
		public function hauteur():int
		{
			return _tf.height;
		}
		private function createFormat( police:String, taillePolice:int, couleur:uint ):TextFormat
		{
			var format:TextFormat;
			format = new TextFormat( police, taillePolice, couleur );
			format.align = TextFormatAlign.CENTER;
			return format;
		}	
		private function startDraggingContainer(e:MouseEvent):void 
		{
			e.currentTarget.startDrag();
			Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE, drawText);
		}
		private function stopDraggingContainer(e:MouseEvent):void 
		{
			stopDrag();
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawText);
		}
		private function drawText(e:Event = null):void 
		{
			//trace("drawText " +  _texte + _nom + container.x +"TL"+ container.y + " ");	
			/* if ( _bmp ) _bmp = null; 3/1 */
			if ( !_bmp ) _bmp = new Bitmap( _bmd ) ; 
			
			if ( _bmp ) container.addChild( _bmp );
			/*if ( !_horizontal ) 
			{
				_bmp.rotationX = 0;
				_bmp.rotationY = 40;
				_bmp.rotationZ = 0;
			} 
			else
			{
				_bmp.rotationX = _rotVXS;// + mouseX;
				_bmp.rotationY = _rotVYS;// + mouseY;
				_bmp.rotationZ = _rotVZS;
			} */
			//trace(_bmp.rotationX + " rot " + _bmp.rotationY);
			//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA_bmp.z = 700;
			//_bmp.transform.perspectiveProjection.
		}
		private function startDraggingHandle(e:MouseEvent):void 
		{
			e.currentTarget.startDrag();
			Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE, drawText);
		}
		private function stopDraggingHandle(e:MouseEvent):void 
		{
			stopDrag();
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawText);
		}
		
		
	}
}