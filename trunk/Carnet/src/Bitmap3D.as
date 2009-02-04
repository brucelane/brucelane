package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.filters.BlurFilter;
	
	import mx.core.Application;

	public class Bitmap3D extends Sprite
	{
		private var handle_TL:Sprite;
		private var handle_TR:Sprite;
		private var handle_BL:Sprite;
		private var handle_BR:Sprite;
		private var handle_M1L:Sprite;
		private var handle_M1R:Sprite;
		private var handle_M2L:Sprite;
		private var handle_M2R:Sprite;
		private var _tlX:int;
		private var _tlY:int;
		private var _trX:int;
		private var _trY:int;
		private var _blX:int;
		private var _blY:int;
		private var _brX:int;
		private var _brY:int;
		private var _m1lX:int=0;
		private var _m1lY:int=0;
		private var _m2lX:int=0;
		private var _m2lY:int=0;
		private var _m1rX:int=0;
		private var _m1rY:int=0;
		private var _m2rX:int=0;
		private var _m2rY:int=0;  
		private var _angle:int=0;  
		private var _blur:int;  
		private var container:Sprite;
		private var triangleLines:Sprite;
		private var bmd:BitmapData;
		private var bmdH:BitmapData;
		private var bmdM:BitmapData;
		private var bmdB:BitmapData; 
		private var _bmdMask:BitmapData;
		private var _nom:String;
		
		private var vertices:Vector.<Number>;
		private var verticesM:Vector.<Number>;
		private var verticesB:Vector.<Number>;
		private var uvt:Vector.<Number>;
		
		private var _debug:Boolean = false;

		//Constructeur
		public function Bitmap3D( nom:String, bd:BitmapData, couleur:uint, 
								  tlX:int, tlY:int, trX:int, trY:int, blX:int, blY:int, brX:int, brY:int, 
								  paysage:Boolean = false, debug:Boolean = false, blur:int = 0, 
								  m1lX:int=0, m1lY:int=0, m2lX:int=0, m2lY:int=0, m1rX:int=0, m1rY:int=0, m2rX:int=0, m2rY:int=0, 
								  bdMask:BitmapData = null, angle:int = -50 )
		{
			/* var tmpBD:BitmapData ;
			var tmpBitmap:Bitmap; */
			
			_nom = nom;
			_tlX = tlX;
			_tlY = tlY;
			_trX = trX;
			_trY = trY;
			_blX = blX;
			_blY = blY;
			_brX = brX;
			_brY = brY;
			_m1lX = m1lX;
			_m1lY = m1lY;
			_m2lX = m2lX;
			_m2lY = m2lY;
			_m1rX = m1rX;
			_m1rY = m1rY;
			_m2rX = m2rX;
			_m2rY = m2rY;  
			_debug = debug;
			_angle =  angle;
			_blur = blur;  
			/* tmpBitmap = new Bitmap( bd );
			tmpBitmap.smoothing = true;

			trace( "Bitmap3D, creation:" + _nom + " w:" + tmpBitmap.width+ " h:" + tmpBitmap.height); */
			bmd = bd;
			_bmdMask = bdMask;
			
			uvt = new Vector.<Number>();
			// Triangle 1
			uvt.push(0, 0); uvt.push(1, 0);	uvt.push(0, 1);
			// Triangle 2
			uvt.push(1, 0);	uvt.push(1, 1);	uvt.push(0, 1);
			initImage();
			generateHandles();
			drawTrigs();
			super();
		}
		private function initImage():void {
			//trace( "Bitmap3D, initImage" + _nom );
			container = new Sprite();
			container.x = 0;
			container.y = 0;
			this.addChild(container);
			/* container.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingContainer);
			container.addEventListener(MouseEvent.MOUSE_UP, stopDraggingContainer); */
			if ( _debug ) 
			{
				container.addEventListener(MouseEvent.MOUSE_OVER, showHandles);
				container.addEventListener(MouseEvent.MOUSE_OUT, hideHandles);
				triangleLines = new Sprite();
				container.addChild(triangleLines);
			}
		}
		private function showHandles(e:MouseEvent = null):void 
		{
			handle_TL.visible = true;
			handle_TR.visible = true;
			handle_BL.visible = true;
			handle_BR.visible = true;
			if ( _m1lX != 0 )
			{
				handle_M1L.visible = true;
				handle_M1R.visible = true;
				handle_M2L.visible = true;
				handle_M2R.visible = true;
			}
		}
		private function hideHandles(e:MouseEvent = null):void 
		{
			handle_TL.visible = false;
			handle_TR.visible = false;
			handle_BL.visible = false;
			handle_BR.visible = false;
			if ( _m1lX != 0 )
			{
				handle_M1L.visible = false;
				handle_M1R.visible = false;
				handle_M2L.visible = false;
				handle_M2R.visible = false;
			}
		}
		private function startDraggingContainer(e:MouseEvent):void 
		{
			e.currentTarget.startDrag();
			Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE, drawTrigs);
		}
		private function stopDraggingContainer(e:MouseEvent):void 
		{
			stopDrag();
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawTrigs);
		}
		private function drawTrigs(e:Event = null):void 
		{
			/* trace( "Bitmap3D, drawTrigs________________________________" );
			trace( "Bitmap3D, drawTrigs" + container.width + " " + bmd.width );
			trace( "Bitmap3D, drawTrigs" + handle_TL.x + " tl " +  handle_TL.y);
			trace( "Bitmap3D, drawTrigs" + handle_TR.x + " tr " +  handle_TR.y);
			trace( "Bitmap3D, drawTrigs" + handle_BL.x + " bl " +  handle_BL.y);
			trace( "Bitmap3D, drawTrigs" + handle_BR.x + " br " +  handle_BR.y); */
			if (handle_TL.getChildByName( "tf" )) ( (handle_TL.getChildByName( "tf" )) as TextField).text = handle_TL.x + " tl " +  handle_TL.y;
			if (handle_TR.getChildByName( "tf" )) ( (handle_TR.getChildByName( "tf" )) as TextField).text = handle_TR.x + " tr " +  handle_TR.y;
			if (handle_BL.getChildByName( "tf" )) ( (handle_BL.getChildByName( "tf" )) as TextField).text = handle_BL.x + " bl " +  handle_BL.y;
			if (handle_BR.getChildByName( "tf" )) ( (handle_BR.getChildByName( "tf" )) as TextField).text = handle_BR.x + " br " +  handle_BR.y;
			//trace( "Bitmap3D, drawTrigs" + _trX + " tl " +  _trY);
			// Create a new Vector for our vertices. We use the position of the handles to find our triangles.
			vertices = new Vector.<Number>();
			// Triangle 1
			vertices.push(handle_TL.x, handle_TL.y);
			vertices.push(handle_TR.x, handle_TR.y);
			vertices.push(handle_BL.x, handle_BL.y);
			// Triangle 2
			vertices.push(handle_TR.x, handle_TR.y);
			vertices.push(handle_BR.x, handle_BR.y);
			vertices.push(handle_BL.x, handle_BL.y);
			if ( _m1lX != 0 )
			{
				var tmpBmdOrigine:BitmapData = bmd.clone();
				var bmpOrigine:Bitmap = new Bitmap(tmpBmdOrigine,PixelSnapping.ALWAYS,true);
				var larg:int = bmpOrigine.width;
				var haut:int = larg/30;
				var oyH:int = bmpOrigine.height / 2;
				var oyM:int = oyH + haut;
				var oyB:int = oyM + haut;
				var rectDecoupeH:Rectangle = new Rectangle( 0, oyH, larg, haut );
				var rectDecoupeM:Rectangle = new Rectangle( 0, oyM, larg, haut );
				var rectDecoupeB:Rectangle = new Rectangle( 0, oyB, larg, haut );
				bmpOrigine.smoothing = true;
				bmdH = new BitmapData( larg, haut );
				bmdH.copyPixels( tmpBmdOrigine,rectDecoupeH,new Point(0,0) );
				bmdM = new BitmapData( larg, haut );
				bmdM.copyPixels( tmpBmdOrigine,rectDecoupeM,new Point(0,0) );
				bmdB = new BitmapData( larg, haut );
				bmdB.copyPixels( tmpBmdOrigine,rectDecoupeB,new Point(0,0) );
				container.graphics.clear();
				container.graphics.beginBitmapFill(bmdH);
				container.graphics.drawTriangles(vertices, null, uvt, TriangleCulling.NONE);
				verticesM = new Vector.<Number>();
				// Triangle 3
				verticesM.push(handle_BL.x, handle_BL.y);
				verticesM.push(handle_BR.x, handle_BR.y);
				verticesM.push(handle_M1L.x, handle_M1L.y);
				// Triangle 4
				verticesM.push(handle_BR.x, handle_BR.y);
				verticesM.push(handle_M1R.x, handle_M1R.y);
				verticesM.push(handle_M1L.x, handle_M1L.y);
				container.graphics.beginBitmapFill(bmdM);
				container.graphics.drawTriangles(verticesM, null, uvt, TriangleCulling.NONE); 
				// Triangle 5
				verticesB = new Vector.<Number>();
				verticesB.push(handle_M1L.x, handle_M1L.y);
				verticesB.push(handle_M1R.x, handle_M1R.y);
				verticesB.push(handle_M2L.x, handle_M2L.y);
				// Triangle 6
				verticesB.push(handle_M1R.x, handle_M1R.y);
				verticesB.push(handle_M2R.x, handle_M2R.y);
				verticesB.push(handle_M2L.x, handle_M2L.y);
				container.graphics.beginBitmapFill(bmdB);
				container.graphics.drawTriangles(verticesB, null, uvt, TriangleCulling.NONE); 
				if (handle_M1L.getChildByName( "tf" )) ( (handle_M1L.getChildByName( "tf" )) as TextField).text = handle_M1L.x + " m1l " +  handle_M1L.y;
				if (handle_M1R.getChildByName( "tf" )) ( (handle_M1R.getChildByName( "tf" )) as TextField).text = handle_M1R.x + " m1r " +  handle_M1R.y;
				if (handle_M2L.getChildByName( "tf" )) ( (handle_M2L.getChildByName( "tf" )) as TextField).text = handle_M2L.x + " m2l " +  handle_M2L.y;
				if (handle_M2R.getChildByName( "tf" )) ( (handle_M2R.getChildByName( "tf" )) as TextField).text = handle_M2R.x + " m2r " +  handle_M2R.y;
				/* trace( "Bitmap3D, drawTrigs" + handle_M1L.x + " m1l " +  handle_M1L.y);
				trace( "Bitmap3D, drawTrigs" + handle_M1R.x + " m1r " +  handle_M1R.y);
				trace( "Bitmap3D, drawTrigs" + handle_M2L.x + " m2l " +  handle_M2L.y);
				trace( "Bitmap3D, drawTrigs" + handle_M2R.x + " m2r " +  handle_M2R.y); */ 
			}
			else
			{
				if ( _bmdMask )	
				{
					var largeur:int = 382; 
					var hauteur:int = 177;
					var nbChange:int = 0 ;
					var tmpBmdOrig:BitmapData = bmd.clone();
					var bmpOrig:Bitmap = new Bitmap(tmpBmdOrig,PixelSnapping.ALWAYS,true);
					//trace(largeur + " l h " + hauteur);
					//retaille Bitmap
					//var bmdRetaille:BitmapData = retailleBD( tmpBmdOrig );
					//bitmapData qui a subi la rotation
					//var bmdR:BitmapData = rotationBD( bmdRetaille, _angle );
					var bmdR:BitmapData = rotationBD( tmpBmdOrig, _angle );
					var bitmapR:Bitmap = new Bitmap(bmdR);//,PixelSnapping.ALWAYS,true
					var hBmdR:int = bitmapR.bitmapData.height;
					var wBmdR:int = bitmapR.bitmapData.width;
					var scaleBmdR:Number;
					if ( hBmdR == 0 ) scaleBmdR = 0.8 else scaleBmdR = hauteur/hBmdR*1.7;
					//trace(hBmdR + " bitmapR " + wBmdR + " scaleBmdR " + scaleBmdR);
					bmpOrig.smoothing = true;
					//bitmapData à mapper
					bmd = new BitmapData( largeur, hauteur, true,0xFFFFFFFF );
					var _bmpZ:Bitmap = new Bitmap(bmdR);
					_bmpZ.scaleX = _bmpZ.scaleY = scaleBmdR;
					//if ( _debug ){container.addChild( _bmpZ );_bmpZ.x= -100;_bmpZ.y= 200;}

					for(var ypos:uint = 0; ypos < hauteur; ypos++)
					{
						for(var xpos:uint = 0; xpos < largeur; xpos++)
						{	// si alpha different de 0 on peint le pixel
							if ( _bmdMask.getPixel32(xpos, ypos) == 0 )
							{
								bmd.setPixel32( xpos, ypos, 0x00000000);
							}
							else
							{
	            				nbChange++;
								bmd.setPixel(xpos, ypos, _bmpZ.bitmapData.getPixel( xpos/scaleBmdR , ypos/scaleBmdR+40 ) );//noir
							}  
						}
					}		
				}
				var _bmpB:Bitmap = new Bitmap(bmd);
	            var bmdBWidth:int = _bmpB.width;
	           	var bmdBHeight:int = _bmpB.height;
				var filtre:BlurFilter = new BlurFilter(_blur,_blur,1);//2,2,1);
				var rect:Rectangle=new Rectangle(0,0,bmdBWidth,bmdBHeight);
				bmd.applyFilter(bmd,rect,rect.topLeft,filtre);
	
				container.graphics.clear();
				container.graphics.beginBitmapFill(bmd);
				container.graphics.drawTriangles(vertices, null, uvt, TriangleCulling.NONE);
			}
			if (_debug) 
			{
				triangleLines.graphics.clear();
				triangleLines.graphics.lineStyle(1, 0xFF0000);
				triangleLines.graphics.moveTo(vertices[0], vertices[1]);
				for (var i:int = 0; i < vertices.length-1; i+=2) 
				{
					triangleLines.graphics.lineTo(vertices[i], vertices[i + 1]);
				}
				triangleLines.graphics.lineTo(vertices[0], vertices[1]);
			}  
		}
		private function retailleBD(bmdIn:BitmapData ):BitmapData
		{
			var bmdOut:BitmapData;
			var _bmpB:Bitmap = new Bitmap(bmdIn);
           	var bmdBHeight:int = _bmpB.height;
            var bmdBWidth:int = bmdBHeight/10;
			if ( ( bmdBWidth == 0 ) || ( bmdBHeight == 0 ) ) bmdBWidth = bmdBHeight = 1;
			bmdOut = new BitmapData( bmdBWidth, bmdBHeight );;
            for ( var q:int=0; q < bmdBWidth ; q++ )
            {
            	for ( var r:int=0; r < bmdBHeight ; r++ )
            	{
            		if ( _bmpB.bitmapData.getPixel32( q, r ) != 0 )
            		{
             			bmdOut.setPixel( q, r, _bmpB.bitmapData.getPixel32( q, r ) );
            		}
            		else
            		{
            			bmdOut.setPixel32( q, r, 0x00000000);
            		} 
            	}
            }			
			return bmdOut;
		}
		private function rotationBD(bmdIn:BitmapData, angle:int ):BitmapData
		{
			var bmdOut:BitmapData;
			var tmpBitmap:Bitmap = new Bitmap( bmdIn );
			var maxPixels:int = Math.min( Math.max( tmpBitmap.width, tmpBitmap.height ) * 2, 2000 );
			//trace("maxPixels " + maxPixels );
			//on place bmdIn dans un bmp de taille superieure pour rien perdre dans la rotation
			var bmdElargi:BitmapData;
			var moveMatrix:Matrix = new Matrix();
			//on centre les pixels
			moveMatrix.translate( maxPixels/2 - ( tmpBitmap.width/2 ), maxPixels/2 - ( tmpBitmap.height/2 )  );
			
			bmdElargi= new BitmapData( maxPixels, maxPixels );
            for ( var o:int=0; o< maxPixels; o++ )
            {
            	for ( var p:int=0; p < maxPixels; p++ )
            	{
            		bmdElargi.setPixel32( o, p, 0x00000000);//ROUGE 0x00000000
            	}
            }
			bmdElargi.draw( tmpBitmap.bitmapData, moveMatrix );
			
			//on arrondit le haut
			var _bmpB:Bitmap = new Bitmap(bmdElargi);
			var tmpBmdIn:BitmapData;
            //var bmdRotated:BitmapData;
            var bmdBWidth:int = _bmpB.width;
            var bmdBHeight:int = _bmpB.height;
			if ( ( bmdBWidth == 0 ) || ( bmdBHeight == 0 ) ) bmdBWidth = bmdBHeight = 1;
			tmpBmdIn = new BitmapData( bmdBWidth, bmdBHeight );;
            for ( var q:int=0; q < bmdBWidth ; q++ )
            {
            	for ( var r:int=0; r < bmdBHeight ; r++ )
            	{
            		if ( _bmpB.bitmapData.getPixel32( q, r ) != 0 )
            		{
            			//nbChange++;
            			//bmdOut.setPixel( m, n, bmdRotated.getPixel32( m + minI, n + minJ ));
            			//tmpBmdIn.setPixel( q, r, _bmpB.bitmapData.getPixel32( q + ( Math.cos(q)*1.3), r  ) );
            			tmpBmdIn.setPixel( q, r, _bmpB.bitmapData.getPixel32( q, -10 + r + ( 20 * Math.sin(q*.02))  ) );
            		}
            		else
            		{
            			tmpBmdIn.setPixel32( q, r, 0x00000000);
            		} 
            	}
            }			
			
			
			var _bmpA:Bitmap = new Bitmap(tmpBmdIn);
			/*   if (_debug)
			{
				_bmpA.scaleX = _bmpA.scaleY = .53;
				container.addChild( _bmpA );
				_bmpA.x= +250;
				_bmpA.y= -50; 	
			}  */
			//on effectue une rotation
			var angle_in_radians:Number = Math.PI * 2 * ( angle / 360 );
			var rotationMatrix:Matrix = new Matrix();
			rotationMatrix.translate( -_bmpA.width/2, -_bmpA.height/2  );
			rotationMatrix.rotate( angle_in_radians );
			rotationMatrix.translate( _bmpA.width/2, _bmpA.height/2 );
			var bmdRotated:BitmapData;
			bmdRotated = new BitmapData( _bmpA.width, _bmpA.height );
            for ( var k:int=0; k < maxPixels; k++ )
            {
            	for ( var l:int=0; l < maxPixels; l++ )
            	{
            		bmdRotated.setPixel32( k, l, 0x00000000);//BLEU0x00000000
            	}
            }
			bmdRotated.draw( _bmpA.bitmapData, rotationMatrix );
			var _bmpZ:Bitmap = new Bitmap(bmdRotated);
			/*  if ( _debug )
			{//OK
				_bmpZ.scaleX = _bmpZ.scaleY = .2;
				container.addChild( _bmpZ );
				_bmpZ.x= 0;
				_bmpZ.y= 120;	
			}  */

			var minI:int=0;
			var minJ:int=0;
			var maxI:int=0;
			var maxJ:int=0;
            //for ( var i:int=0; i < tmpBitmap.width+2; i++ )
            //trace("_bmpZ.width" + _bmpZ.width + "bmpZ.height" + _bmpZ.height);
            for ( var j:int=0; j < _bmpZ.height; j++ )
            {
            	//for ( var j:int=0; j < tmpBitmap.height+2; j++ )
	            for ( var i:int=0; i < _bmpZ.width; i++ )
            	{
            		if ( bmdRotated.getPixel32( i, j ) != 0 )
            		{    			
            			if ( minI == 0 ) minI = i else if ( minI > i ) minI = i;
            			if ( minJ == 0 ) minJ = j else if ( minJ > j ) minJ = j;
            			if ( i > maxI ) maxI = i;
            			if ( j > maxJ ) maxJ = j;       			
//trace( "bmdRotated i " + i + " j " + j + " w " + tmpBitmap.width  + " h " + tmpBitmap.height + " g " + bmdRotated.getPixel32( i, j ).toString(16) );
					}
            	}
            }
            var bmdOutWidth:int = maxI - minI;
            var bmdOutHeight:int = maxJ - minJ;
			//trace( "bmdRotated maxI " + maxI + " maxJ " + maxJ + "minI " + minI + " minJ " + minJ);
			//trace( "bmdRotated bmdOutWidth " + bmdOutWidth + " bmdOutHeight " + bmdOutHeight );
			//ne copier que les pixels interessants
			if ( ( bmdOutWidth == 0 ) || ( bmdOutHeight == 0 ) ) bmdOutWidth = bmdOutHeight = 1;
			
			bmdOut = new BitmapData( bmdOutWidth, bmdOutHeight );
            for ( var m:int=0; m < bmdOutWidth + minI; m++ )
            {
            	for ( var n:int=0; n < bmdOutHeight + minJ; n++ )
            	{
            		if ( bmdRotated.getPixel32( m + minI, n + minJ ) != 0 )
            		{
            			//nbChange++;
            			//bmdOut.setPixel( m, n, bmdRotated.getPixel32( m + minI, n + minJ ));
            			bmdOut.setPixel( m, n, bmdRotated.getPixel32( m + minI, n + minJ ) );
            		}
            		else
            		{
            			bmdOut.setPixel32( m, n, 0x00000000);
            		} 
            	}
            }

			/* var _bmpO:Bitmap = new Bitmap(bmdOut);
			if ( _debug )
			{//OK
				  //_bmpO.scaleX = _bmpO.scaleY = .2;
				container.addChild( _bmpO );
				_bmpO.x= 0;
				_bmpO.y= 120;  	
			} */

			return bmdOut;
		}

		private function generateHandles():void 
		{
			/* trace( "Bitmap3D, generateHandles" + _nom );
			trace( "Bitmap3D, generateHandles " + _trX + " tr " +  _trY); */
			//trace( "Bitmap3D, generateHandles " + _v['trx'] + " _v['trx'] " +  _v['try']);
			handle_TL = createHandle("TL");
			container.addChild(handle_TL);
			handle_TL.x = _tlX;
			handle_TL.y = _tlY;
			handle_TR = createHandle("TR");
			handle_TR.x = _trX;
			handle_TR.y = _trY;
			container.addChild(handle_TR);
			handle_BL = createHandle("BL");
			handle_BL.x = _blX;
			handle_BL.y = _blY;
			container.addChild(handle_BL);
			handle_BR = createHandle("BR");
			handle_BR.x = _brX;
			handle_BR.y = _brY;
			container.addChild(handle_BR);
			
			if ( _m1lX != 0 )
			{
				handle_M1L = createHandle("M1L");
				handle_M1L.x = _m1lX;
				handle_M1L.y = _m1lY;
				container.addChild(handle_M1L);
				handle_M1R = createHandle("M1R");
				handle_M1R.x = _m1rX;
				handle_M1R.y = _m1rY;
				container.addChild(handle_M1R);
				handle_M2L = createHandle("M2L");
				handle_M2L.x = _m2lX;
				handle_M2L.y = _m2lY;
				container.addChild(handle_M2L);
				handle_M2R = createHandle("M2R");
				handle_M2R.x = _m2rX;
				handle_M2R.y = _m2rY;
				container.addChild(handle_M2R);
				handle_M1L.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
				handle_M1R.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
				handle_M2L.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
				handle_M2R.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
			}
			handle_TL.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
			handle_TR.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
			handle_BL.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
			handle_BR.addEventListener(MouseEvent.MOUSE_DOWN, startDraggingHandle);
			if ( _debug ) showHandles() else hideHandles();
			if ( Application.application.stage ) Application.application.stage.addEventListener(MouseEvent.MOUSE_UP, stopDraggingHandle);
		}
		private function createHandle(nom:String):Sprite 
		{
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x00FF00);
			sprite.graphics.drawRect( -10, -10, 20, 20);
			sprite.graphics.endFill();
			sprite.buttonMode = true;
			sprite.name = nom;
	    	var _tfDbg:TextField; //controle texte
			_tfDbg = new TextField(); 
			_tfDbg.wordWrap = true;
			_tfDbg.multiline = true;
			_tfDbg.border = _debug;
			_tfDbg.width = 70;
			_tfDbg.height = 20;
			_tfDbg.htmlText = sprite.name; 
			_tfDbg.name = "tf";
			sprite.addChild(_tfDbg);
			//sprite.visible = false;
			return sprite;
		}
		private function startDraggingHandle(e:MouseEvent):void 
		{
			trace(e.currentTarget.name);
			e.currentTarget.startDrag();
			Application.application.stage.addEventListener(MouseEvent.MOUSE_MOVE, drawTrigs);
		}
		private function stopDraggingHandle(e:MouseEvent):void 
		{
			stopDrag();
			Application.application.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drawTrigs);
		}
		
		
	}
}