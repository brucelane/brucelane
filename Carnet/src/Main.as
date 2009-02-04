/////////////////////////////////////////////////////////////
// Auteur Bruce LANE
// Version du 28 janvier 2009
/////////////////////////////////////////////////////////////
		import flash.display.Bitmap;
		import flash.display.BitmapData;
		import flash.display.Loader;
		import flash.events.Event;
		import flash.events.EventDispatcher;
		import flash.events.IEventDispatcher;
		import flash.events.MouseEvent;
		import flash.events.TimerEvent;
		import flash.net.FileFilter;
		import flash.net.FileReference;
		import flash.net.URLLoader;
		import flash.net.URLRequest;
		import flash.net.navigateToURL;
		import flash.utils.Timer;
		
		import flashcomps.Carousel;
		
		import mx.managers.CursorManager;

        private var capuchon:Mapping2D;
        private var corpsStylo:Mapping2D;
        private var carnetCouv:Mapping2D;
        private var carnetDos:Mapping2D;
		private var fileRefCouv:FileReference;
		private var fileRefQuat:FileReference;
		private var fileRefStylo:FileReference;
		private var fileFilter:FileFilter;
		private var loader:Loader;
		private var loaderCouv:Loader;
		private var loaderQuat:Loader;
		private var loaderStylo:Loader;
		public var pixelsImageCouv:BitmapData;
		public var pixelsImageQuat: BitmapData;
		public var pixelsImageStylo:BitmapData;
		private var originalCouvertureFull:Bitmap;
		private var vignCouvertureFull:Bitmap;
		private var vignCouvertureMedium:Bitmap;
		private var vignCouvertureSmall:Bitmap;
		private var originalQuatFull:Bitmap;
		private var originalStyloFull:Bitmap;
		private var vignQuatFull:Bitmap;
		private var vignQuatMedium:Bitmap;
		private var vignQuatSmall:Bitmap;
		private var vignStyloFull:Bitmap;
		private var vignStyloMedium:Bitmap; 
 		private var debug:Boolean = false;
		private var policeTexteCouv:String = "Arial";
		private var policeTexteQuat:String = "Arial";
		private var policeTexteStylo:String = "Arial";
		private var taillePoliceTexteCouv:int = 36;
		private var taillePoliceTexteQuat: int = 36;
		private var taillePoliceTexteStylo: int = 36;
		private var bmpMateriauCouv:String; 
		private var bmpMateriauQuat:String; 
		private var typePapierCouv:String; 
		private var typePapierQuat:String; 
		private var typePapierStylo:String; 
		private var typePapierCapuchon:String; 
		private var typeCouverture:String = 'full';
		private var typeQuatre:String = 'full';
		private var typeStylo:String = 'full';
		private	var v:Array = new Array();
		private	var urlImageCouv:String;
		private	var urlImageQuat:String;
		private	var urlImageStylo:String;
		private	var urlimage:String;
		private	var urlmemo:String;
		private	var urlcommande:String;
		private	var uploaddir:String;
		private	var carnetScale:Number = .34;
		private var vignette_small_max_width:int = 30;
		private var vignette_small_max_height:int = 42;
		private var vignette_medium_max_width:int = 50;
		private var vignette_medium_max_height:int = 71;
		[Bindable]
		private var vignette_full_max_width:int = 60;
		[Bindable]
		private var vignette_full_max_height:int = 90;
		private var cr:flashcomps.Carousel;
		private var etape:int = 1;
 		private var wCouv:int; 
 		private var wQuat:int; 
 		private var wStylo:int; 
 		private var wCap:int; 
		private var paysageCouv:Boolean = false;		
		private var paysageQuat:Boolean = false;		
		private var horizontalStyloTexte:Boolean = true;		
		private var matCouvFond:BitmapData;		
		private var matCouvQuat:BitmapData;	
		private var matCouvStylo:BitmapData;	
		private var matCouvCapuchon:BitmapData;	
		private var carousels:XML;
		private var taillepolices:XML;
		private var polices:XML;
		private var materiauxPapier:XML;
		private var formatscarnet:XML; 
		private var idCB:String = "0";
		private var session:String = null;
		private var variables:URLVariables;
		private var xmlDispatcher:XmlDispatcher;
		private var myTimer:Timer;
		
		private function preInit():IEventDispatcher
		{
            trace("1>> preInit");
  			loader = new Loader ( ) ;
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoaded ) ;
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
 			loaderCouv = new Loader ( ) ;
			loaderCouv.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoadedEtape1 ) ;
			loaderCouv.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
 			loaderQuat = new Loader ( ) ;
			loaderQuat.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoadedEtape2 ) ;
			loaderQuat.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
 			loaderStylo = new Loader ( ) ;
			loaderStylo.contentLoaderInfo.addEventListener ( Event.COMPLETE, onImageLoadedEtape3 ) ;
			loaderStylo.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
            init();
            xmlDispatcher = new XmlDispatcher();
            xmlDispatcher.addEventListener("xmlCharges", xmlLoaded);
			return new EventDispatcher(this);  
		}
		private function init():void
		{
            trace("2>> init");
			loadVar("variables.xml");
		}
		private function loadVar(urlXml:String):void
		{
            trace("3>> loadVar " + urlXml);
			var ldrVar:URLLoader = new URLLoader(new URLRequest(urlXml + "?t=" + new Date().getMilliseconds()));
			ldrVar.addEventListener(Event.COMPLETE, createVars);
		}
		private function createVars(e:Event):void
		{
            trace("4>> createVars");
			var xml:XML = new XML(e.target.data);
			var l:XMLList = xml.variable;
			for(var i:int=0; i<l.length(); i++)
			{
				v[l[i].@nom] = l[i].@valeur;
				//trace(l[i].@nom + " = " + l[i].@valeur);
			}
			if (v['vignette_small_max_width']) vignette_small_max_width = v['vignette_small_max_width'];
 			if (v['vignette_small_max_height']) vignette_small_max_height = v['vignette_small_max_height'];
			if (v['vignette_medium_max_width']) vignette_medium_max_width = v['vignette_medium_max_width'];
 			if (v['vignette_medium_max_height']) vignette_medium_max_height = v['vignette_medium_max_height'];
			if (v['vignette_full_max_width']) vignette_full_max_width = v['vignette_full_max_width'];
 			if (v['vignette_full_max_height']) vignette_full_max_height = v['vignette_full_max_height'];
			if (v['urlmemo']) urlmemo = v['urlmemo'];
			if (v['urlcommande']) urlcommande = v['urlcommande'];
			if (v['urlimage']) urlimage = v['urlimage'];
			if (v['uploaddir']) uploaddir = v['uploaddir'];
			if (v['debug']) debug = (v['debug']=="true");
			var ldrTPXML:URLLoader = new URLLoader(new URLRequest("taillepolice.xml?t=" + new Date().getMilliseconds()));
			ldrTPXML.addEventListener(Event.COMPLETE, tpXML);
			ldrTPXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			var ldrPXML:URLLoader = new URLLoader(new URLRequest("polices.xml?t=" + new Date().getMilliseconds()));
			ldrPXML.addEventListener(Event.COMPLETE, pXML);
			ldrPXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			var ldrMPXML:URLLoader = new URLLoader(new URLRequest("materiauxpapier.xml?t=" + new Date().getMilliseconds()));
			ldrMPXML.addEventListener(Event.COMPLETE, mpXML);
			ldrMPXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			/* var ldrFCXML:URLLoader = new URLLoader(new URLRequest("formatscarnet.xml?t=" + new Date().getMilliseconds()));
			ldrFCXML.addEventListener(Event.COMPLETE, fcXML);
			XML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );  */
			if ( Application.application.parameters.xmlfile ) 
			{
				var ldrInitXML:URLLoader = new URLLoader(new URLRequest("inits/" + Application.application.parameters.xmlfile + "?t=" + new Date().getMilliseconds()));
				ldrInitXML.addEventListener(Event.COMPLETE, initXML);
				ldrInitXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			}
			else
			{
				if ( debug )
				{
					var ldrIntXML:URLLoader = new URLLoader(new URLRequest("inits/init3.xml"));
					ldrIntXML.addEventListener(Event.COMPLETE, initXML); 
					ldrIntXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
				}
				else loadCSS(idCB);
			}
			var urlCar:String;
			if ( Application.application.parameters.carousel ) 
			{
				urlCar = "carousels/" + Application.application.parameters.carousel + "?t=" + new Date().getMilliseconds();
			}
			else
			{
				if ( debug )
				{
					urlCar = "carousels/carousel.xml?t=" + new Date().getMilliseconds();
				}
				else urlCar = "carousels/carousel.xml?t=" + new Date().getMilliseconds();
			}
			var ldrCaroXML:URLLoader = new URLLoader( new URLRequest(urlCar) );
			ldrCaroXML.addEventListener(Event.COMPLETE, carXML);
			ldrCaroXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
			var urlFC:String;
			if ( Application.application.parameters.fc ) 
			{
				urlFC = "fc/" + Application.application.parameters.fc + "?t=" + new Date().getMilliseconds();
			}
			else
			{
				if ( debug )
				{
					urlFC = "fc/formatscarnet3.xml?t=" + new Date().getMilliseconds();
				}
				else urlFC = "fc/formatscarnet.xml?t=" + new Date().getMilliseconds();
			}
			var ldrFcXML:URLLoader = new URLLoader( new URLRequest(urlFC) );
			ldrFcXML.addEventListener(Event.COMPLETE, fcXML);
			ldrFcXML.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
		}
		private function loadCSS(id:String):void
		{
            trace("6>> loadCSS");
			var ldrCssXML:URLLoader = new URLLoader(new URLRequest("css" + id + ".xml?t=" + new Date().getMilliseconds()));
			ldrCssXML.addEventListener(Event.COMPLETE, cssXML);
		}
		

		private function tpXML(e:Event):void
		{
            trace("7>> tpXML");
			taillepolices = new XML(e.target.data);
			taillePoliceCouv.dataProvider = taillepolices.taillepolice;
			taillePoliceQuat.dataProvider = taillepolices.taillepolice;
			taillePoliceStylo.dataProvider = taillepolices.taillepolice;
		}
		private function pXML(e:Event):void
		{
            trace("8>> pXml");
			polices = new XML(e.target.data);
			policeCouv.dataProvider = polices.police;
			policeQuat.dataProvider = polices.police;
			policeStylo.dataProvider = polices.police;
		}
		private function mpXML(e:Event):void
		{
            trace("9>> mpXML");
			materiauxPapier = new XML(e.target.data);
			papier.dataProvider = materiauxPapier.materielpapier;
			papierQuat.dataProvider = materiauxPapier.materielpapier;
		}
		private function cssXML(e:Event):void
		{
            trace("12>> cssXML");
			var css:XML = new XML(e.target.data);
			l1.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l2.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l3.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l5.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l6.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l7.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l8.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l10.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l11.setStyle("color",css.couleurPoliceBandeau.@valeur);
			l12.setStyle("color",css.couleurPoliceBandeau.@valeur);
			labelMaxchars.setStyle("color",css.couleurPoliceBandeau.@valeur);
			labelMaxcharsQuat.setStyle("color",css.couleurPoliceBandeau.@valeur);
			labelMaxcharsStylo.setStyle("color",css.couleurPoliceBandeau.@valeur);
			canvas1.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas2.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas3.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas4.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas5.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas6.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas7.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas8.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas9.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas10.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas11.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas12.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			canvas13.setStyle("backgroundColor",css.couleurBandeau.@valeur);
			btnSave.setStyle( "color", css.degradeBoutonTexte.@valeur ); 
			btnVoir.setStyle("color",css.degradeBoutonTexte.@valeur); 
			btnCommander.setStyle( "color", css.degradeBoutonTexteAutre.@valeur ); 
			if ( css.degradeBoutonFillHaut.@valeur )
			{
				var fillBtn:Array = new Array();
				fillBtn.push( css.degradeBoutonFillHaut.@valeur, css.degradeBoutonFillBas.@valeur);
				fillBtn.push( css.degradeBoutonRollHaut.@valeur, css.degradeBoutonRollBas.@valeur);
				btnSave.setStyle( "fillColors", fillBtn ); 
				btnVoir.setStyle("fillColors",fillBtn); 
			}
			if ( css.degradeBoutonFillHautAutre.@valeur )
			{
				var fillBtnAutre:Array = new Array();
				fillBtnAutre.push( css.degradeBoutonFillHautAutre.@valeur, css.degradeBoutonFillBasAutre.@valeur);
				fillBtnAutre.push( css.degradeBoutonRollHautAutre.@valeur, css.degradeBoutonRollBasAutre.@valeur);
				btnCommander.setStyle( "fillColors", fillBtnAutre ); 
			}
			// a lieu en dernier apres chargement CSS
			xmlDispatcher.dispatchEvent(new Event("xmlCharges"));
		}
		private function carXML(e:Event):void
		{
            trace("11>> carXML");
			carousels = new XML(e.target.data);
			catalogue.dataProvider = carousels.rubrique;
			catalogQuat.dataProvider = carousels.rubrique;
			catalogStylo.dataProvider = carousels.rubrique;
		}
		private function fcXML(e:Event):void
		{
            trace("13>> fcXML");
			formatscarnet = new XML(e.target.data);
			formatPrix.dataProvider = formatscarnet.formatcarnet;
		}
		private function initXML(e:Event):void
		{
            trace("5>> initXML" );
 			var xml:XML = new XML(e.target.data);
			idCB = xml.id.@valeur;
			var sess:String = xml.session.@valeur;
			if ( sess.length > 0 ) session = xml.session.@valeur;
			//couverture
			typeCouverture = xml.ct.@valeur;
			couleurTexte.selectedColor = xml.ctc.@valeur;
			formatPrix.selectedIndex = xml.ga.@valeur;
			var cmis:String = xml.cmi.@valeur;
			if ( cmis.length > 0 )
			{
				var cmi:int = (int)(cmis);
				if ( cmi > -1 )
				{ 
					papier.selectedIndex = cmi;
				    typePapierCouv = 'image';
					bmpMateriauCouv = xml.cm.@valeur;
					if ( ( bmpMateriauCouv ) && ( bmpMateriauCouv != "null" ) )
					{
		        		//bmpMateriauCouv = cm;
		 				var ldrC:Loader = new Loader();
						ldrC.contentLoaderInfo.addEventListener( Event.COMPLETE, changeMatCouvFond );
						ldrC.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
						ldrC.load( new URLRequest( bmpMateriauCouv ) );
					}
					else bmpMateriauCouv="";
				}
			}
			urlImageCouv = xml.ci.@valeur;
			if ( ( urlImageCouv ) && ( urlImageCouv != "null" ) ) loaderCouv.load( new URLRequest(urlImageCouv) ) ;
			paysageCouv = ( xml.cp.@valeur == 'true' );
			radioGroup.selectedValue = paysageCouv ? "Paysage" : "Portrait";
			couleurFond.selectedColor = xml.cf.@valeur;
			texteCouv.text = xml.ctx.@valeur;
			couleurTexte.selectedColor = xml.ctc.@valeur;
			var ctpi:int = (int)(xml.ctpi.@valeur);
			if ( ctpi > -1 )
			{ 
				policeCouv.selectedIndex = ctpi;
				var ctp:String = xml.ctp.@valeur;
				if ( ( ctp ) && ( ctp != "null" ) ) policeTexteCouv = ctp;
			}
			var ctti:int = (int)(xml.ctti.@valeur);
			if ( ctti > -1 )
			{ 
				taillePoliceCouv.selectedIndex = ctti;
				var ctt:int = (int)(xml.ctt.@valeur);
				if ( ctt > 0 ) taillePoliceTexteCouv = ctt;
			}
			//Dos carnet	
			typeQuatre = xml.qt.@valeur;
			couleurTexteQuat.selectedColor = xml.qtc.@valeur;
			var qmis:String = xml.qmi.@valeur;
			if ( qmis.length > 0 )
			{
				var qmi:int = (int)(qmis);
				if ( qmi > -1 )
				{ 
					papierQuat.selectedIndex = qmi;
				    typePapierQuat = 'image';
					bmpMateriauQuat = xml.qm.@valeur;
					if ( ( bmpMateriauQuat ) && ( bmpMateriauQuat != "null" ) )
					{
		        		//bmpMateriauQuat = qm;
		 				var ldrQ:Loader = new Loader();
						ldrQ.contentLoaderInfo.addEventListener( Event.COMPLETE, changeMatQuatFond );
						ldrQ.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
						ldrQ.load( new URLRequest( bmpMateriauQuat ) );
					}
					else bmpMateriauQuat="";
				}
			}
			urlImageQuat = xml.qi.@valeur;
			if ( ( urlImageQuat ) && ( urlImageQuat != "null" ) ) loaderQuat.load( new URLRequest(urlImageQuat) ) ;
			paysageQuat = ( xml.qp.@valeur == 'true' );
			radioGroupQuat.selectedValue = paysageQuat ? "Paysage" : "Portrait";
			couleurFondQuat.selectedColor = xml.qf.@valeur;
			texteQuat.text = xml.qtx.@valeur;
			couleurTexteQuat.selectedColor = xml.qtc.@valeur;
			var qtpi:int = (int)(xml.qtpi.@valeur);
			if ( qtpi > -1 )
			{ 
				policeQuat.selectedIndex = qtpi;
				var qtp:String = xml.qtp.@valeur;
				if ( ( qtp ) && ( qtp != "null" ) ) policeTexteQuat = qtp;
			}
			var qtti:int = (int)(xml.qtti.@valeur);
			if ( qtti > -1 )
			{ 
				taillePoliceQuat.selectedIndex = qtti;
				var qtt:int = (int)(xml.qtt.@valeur);
				if ( qtt > 0 ) taillePoliceTexteQuat = qtt;
			}		
			//capuchon et stylo	
			typeStylo = xml.st.@valeur;
			couleurTexteStylo.selectedColor = xml.htc.@valeur;
			urlImageStylo = xml.si.@valeur;
			if ( ( urlImageStylo ) && ( urlImageStylo != "null" ) ) loaderStylo.load( new URLRequest(urlImageStylo) ) ;
			horizontalStyloTexte = ( xml.hp.@valeur == 'true' );
			radiogroupStylo.selectedValue = horizontalStyloTexte ? "horizontal" : "vertical";
			couleurCapuchon.selectedColor = xml.hf.@valeur;
			couleurCorps.selectedColor = xml.sf.@valeur;
			texteStylo.text = xml.htx.@valeur;
			couleurTexteStylo.selectedColor = xml.htc.@valeur;
			var htpi:int = (int)(xml.htpi.@valeur);
			if ( htpi > -1 )
			{ 
				policeStylo.selectedIndex = htpi;
				var htp:String = xml.htp.@valeur;
				if ( ( htp ) && ( htp != "null" ) ) policeTexteStylo = htp;
			}
			var htti:int = (int)(xml.htti.@valeur);
			if ( htti > -1 )
			{ 
				taillePoliceStylo.selectedIndex = htti;
				var htt:int = (int)(xml.htt.@valeur);
				if ( htt > 0 ) taillePoliceTexteStylo = htt;
			}		
			loadCSS(idCB);
		}
        public function xmlLoaded(evt:Event):void {
            trace("13>> xmlLoaded");

            super.initialized = true;
        }
        
		public function created():void
		{
            trace("14>> created");
            myTimer = new Timer(1000, 1);
            myTimer.addEventListener("timer", calledLater);
            myTimer.start();
        }
		public function calledLater(event:TimerEvent):void
		{
            trace("15>> verifier calledLater APRES xmlLoaded  ");
			trace("mesImages:" + mesImages);
			//myTimer.stop();
			mesImages.addEventListener ( MouseEvent.CLICK, handleCouvMouseEvent ) ;
			mesImagesQuat.addEventListener ( MouseEvent.CLICK, handleQuatMouseEvent ) ;
			mesImagesStylo.addEventListener ( MouseEvent.CLICK, handleStyloMouseEvent ) ;
			fileFilter = new FileFilter ( "Image", "*.jpg;*.gif;*.png;" ) ;		
			taillePoliceCouv.text = taillePoliceTexteCouv.toString();										
			taillePoliceQuat.text = taillePoliceTexteQuat.toString();
			taillePoliceStylo.text = taillePoliceTexteStylo.toString();

			matCouvFond = new BitmapData(1,1,false,couleurFond.selectedColor); 
			matCouvQuat = new BitmapData(1,1,false,couleurFond.selectedColor); 
			matCouvStylo = new BitmapData(1,1,false,couleurFond.selectedColor); 

			resizeVignetteCouv(false); 
 			resizeVignetteQuat(false);
 			resizeVignetteStylo(false);
 			capuchon = new Mapping2D("capuchon.xml",debug);
			cap.addChild( capuchon );
			capuchon.addEventListener( "imageLoaded", capLoaded);
			corpsStylo = new Mapping2D("stylo.xml",debug);
			stylo.addChild( corpsStylo );
			corpsStylo.addEventListener( "imageLoaded", corpsLoaded);
			carnetCouv = new Mapping2D("couv.xml",debug);
			couv.addChild( carnetCouv );
			carnetCouv.addEventListener( "imageLoaded", couvLoaded);
			carnetDos = new Mapping2D("dos.xml",debug);
			quat.addChild( carnetDos );
			carnetDos.addEventListener( "imageLoaded", dosLoaded);
		}
        private function couvLoaded(event:TextEvent):void
        {
        	//trace("couv image chargee");
			switch (typeCouverture)
 			{
 				case 'medium':
 					selTypeCouv('medium',vignetteCouvMedium);
					break;
 				case 'small':
					selTypeCouv('small',vignetteCouvSmall);
 					break;
 				default:
					selTypeCouv('full',vignetteCouvFull);
 					break;
 			}
		} 
        private function dosLoaded(event:TextEvent):void
        {
        	//trace("dos image chargee");
			switch (typeQuatre)
 			{
 				case 'medium':
 					selTypeQuat('medium',vignetteQuatMedium);
					break;
 				case 'small':
					selTypeQuat('small',vignetteQuatSmall);
 					break;
 				default:
					selTypeQuat('full',vignetteQuatFull);
 					break;
 			}
		} 
        private function capLoaded(event:TextEvent):void
        {
        	//trace("capuchon image chargee");
			switch (typeStylo)
 			{
 				case 'medium':
 					selTypeStylo('medium',vignetteStyloMedium);
					break;
 				default:
					selTypeStylo('full',vignetteStyloFull);
 					break;
 			}
		} 
        private function corpsLoaded(event:TextEvent):void
        {
        	//trace("corps image chargee");
        	changeStylo();
		} 
		
   		private function showToolTip( event:Event ):void
		{
			event.target.toolTip = "Si vous souhaitez utiliser une de vos photos, choisissez de préférence le format suivant : largeur (width): 520 pixels - hauteur (height): 780 pixels à 300 dpi (format standard d'un appareil photo numérique)";
		}
		private function hideToolTip( event:Event ):void
		{
			event.target.toolTip = null;
		}
		private function changeEtape( etp:int ):void
		{
			etape = etp;
			etape1.selected = false;
			etape2.selected = false;
			etape3.selected = false;
			switch ( etape )
			{
				case 1:
					etape1.selected = true;
					titreEtape.text = "La couverture du carnet";
					currentState = "stateEtape1";
				break;
				case 2:
					etape2.selected = true;
					titreEtape.text = "Le dos du carnet";
					currentState = "stateEtape2";
				break;
				case 3:
					etape3.selected = true;
					titreEtape.text = "Le stylo";
					currentState = "stateEtape3";
				break;
			}
		}
		
		private function resizeVignetteCouv(paysage:Boolean):void
		{
 			resizeVignette( vignCouvertureSmall,vignetteCouvSmall,vignette_small_max_height,vignette_small_max_width,paysage);
			resizeVignette( vignCouvertureMedium,vignetteCouvMedium,vignette_medium_max_height,vignette_medium_max_width,paysage); 
			resizeVignette( vignCouvertureFull,vignetteCouvFull,vignette_full_max_height,vignette_full_max_width,paysage);
		}
		private function resizeVignetteQuat(paysage:Boolean):void
		{
 			resizeVignette( vignQuatSmall,vignetteQuatSmall,vignette_small_max_height,vignette_small_max_width,paysage);
			resizeVignette( vignQuatMedium,vignetteQuatMedium,vignette_medium_max_height,vignette_medium_max_width,paysage); 
			resizeVignette( vignQuatFull,vignetteQuatFull,vignette_full_max_height,vignette_full_max_width,paysage);
		}
		private function resizeVignetteStylo(paysage:Boolean):void
		{
			resizeVignette( vignStyloMedium,vignetteStyloMedium,vignette_medium_max_height,vignette_medium_max_width,paysage); 
			resizeVignette( vignStyloFull,vignetteStyloFull,vignette_full_max_height,vignette_full_max_width,paysage);
		}
		private function changeCouverture():void
		{
            carnetCouv.changeFond(couleurFond.selectedColor);
			resizeVignetteCouv(false);//paysage
			if ( matCouvFond ) carnetCouv.changeMateriau( matCouvFond );
			if ( pixelsImageCouv )
			{
				carnetCouv.changeImage( "bmpImage", pixelsImageCouv, typeCouverture, paysageCouv );
				texteCouv.maxChars = 50;
				texteCouv.text = texteCouv.text.substr(0, 50);
				labelMaxchars.text="Saisissez votre texte (50 caractères)";
			}
			else
			{ 
				texteCouv.maxChars = 64000;
				labelMaxchars.text="Saisissez votre texte (64000 caractères)";
			}
			if ( texteCouv.text.length > 0 )
			{
				carnetCouv.changeTexte(texteCouv.text,typeCouverture,policeTexteCouv,taillePoliceTexteCouv,couleurTexte.selectedColor);
			}
		}
		private function changeQuat():void
		{
            carnetDos.changeFond(couleurFondQuat.selectedColor);
			resizeVignetteQuat(false);//paysage
			if ( matCouvQuat ) carnetDos.changeMateriau( matCouvQuat );
			if ( pixelsImageQuat )
			{
				carnetDos.changeImage( "bmpImage", pixelsImageQuat, typeQuatre, paysageQuat );
				texteQuat.maxChars = 50;
				texteQuat.text = texteQuat.text.substr(0, 50);
				labelMaxcharsQuat.text="Saisissez votre texte (50 caractères)";
			}
			else
			{ //mode memo
				texteQuat.maxChars = 64000;
				labelMaxcharsQuat.text="Saisissez votre texte (64000 caractères)";
			}
			if ( texteQuat.text.length > 0 )
			{
				carnetDos.changeTexte(texteQuat.text,typeQuatre,policeTexteQuat,taillePoliceTexteQuat,couleurTexteQuat.selectedColor);
			}
		}
		private function changeStylo():void
		{
			matCouvStylo = null;
			matCouvStylo = new BitmapData(1,1,false,couleurCorps.selectedColor); 
            corpsStylo.changeFond(couleurCorps.selectedColor);
 			resizeVignetteStylo(false);//paysage
			if ( pixelsImageStylo )
			{
				corpsStylo.changeImage( "bmpStylo", pixelsImageStylo, typeStylo, false );
			} 
			matCouvCapuchon = null;
			matCouvCapuchon = new BitmapData(1,1,false,couleurCapuchon.selectedColor); 
			capuchon.changeFond(couleurCapuchon.selectedColor);
			if ( texteStylo.text.length > 0 )
			{ 
				capuchon.changeTexte(texteStylo.text,typeStylo,policeTexteStylo,taillePoliceTexteStylo,couleurTexteStylo.selectedColor,horizontalStyloTexte,0,true);
			}
		}
		private function resizeVignette( target : Bitmap, vignette:Image, maxH:int, maxW:int, paysage:Boolean = false ):void
		{
			var square:Sprite = new Sprite();
			if ( etape == 1 ) 
			{
				square.graphics.beginFill(couleurFond.selectedColor)
			} 
			else 
			{
				if ( etape == 2 )
				{
					square.graphics.beginFill(couleurFondQuat.selectedColor)
				}
				else 
				{
					square.graphics.beginFill(couleurCorps.selectedColor)
					
				}
			}
			changeEtape( etape );
			square.graphics.drawRect(0, 0, vignette_full_max_width, vignette_full_max_height);
			square.useHandCursor = true;
			square.graphics.endFill();
			if (vignette.numChildren > 0) vignette.removeChildAt(0);
			if (target)
			{
				var tmpBD:BitmapData ;
				var tmpBitmap:Bitmap;
				if (paysage==true)
				{
					tmpBD = new BitmapData(target.height, target.width );
					tmpBD.fillRect( new Rectangle(0, 0, target.height, target.width), 0x0000FF );

					var angle_in_radians:Number = Math.PI * 2 * ( 270 / 360 );
					var rotationMatrix:Matrix = new Matrix();
					rotationMatrix.translate( -target.width/2, -target.height/2 );
					rotationMatrix.rotate( angle_in_radians );
					rotationMatrix.translate( target.width/2, target.height/2 );
					tmpBD.draw( target.bitmapData, rotationMatrix );
				} 
				else
				{
					tmpBD = new BitmapData( target.width, target.height );
					tmpBD.draw( target.bitmapData );
				}
				tmpBitmap = new Bitmap( tmpBD );
				
				if (paysage==true)
				{
					if ( tmpBitmap.width >= maxW ) {
						tmpBitmap.width = maxW;
						if (maxH != vignette_full_max_height) tmpBitmap.scaleY = tmpBitmap.scaleX;
					} 
					if ( tmpBitmap.height > maxH) {
						tmpBitmap.height = maxH;
						if (maxH != vignette_full_max_height) tmpBitmap.scaleX = tmpBitmap.scaleY;
					} 
				} else {
					if ( tmpBitmap.height > maxH) {
						tmpBitmap.height = maxH;
						if (maxH != vignette_full_max_height) tmpBitmap.scaleX = tmpBitmap.scaleY;
					} 
					if ( tmpBitmap.width >= maxW ) {
						tmpBitmap.width = maxW;
						if (maxH != vignette_full_max_height) tmpBitmap.scaleY = tmpBitmap.scaleX;
					} 
				} 
				tmpBitmap.x = (vignette_full_max_width - tmpBitmap.width) /2;
				tmpBitmap.y = (vignette_full_max_height - tmpBitmap.height) /2; 

				square.addChild(tmpBitmap);
			}
			vignette.addChild(square);
		}
		private function commander():void 
		{
			sauver( urlcommande );
		}
		private function memo():void 
		{
			sauver( urlmemo );
		}
		private function sauver( urlredir:String ):void
		{
			sauveCarnet( urlredir );
			sauveImages();
		}
		private function sauveCarnet( urlredir:String ):void
		{
			if ( !variables ) variables = new URLVariables();
            variables.gd = new Date().toString();
            variables.id = idCB; //id cobranding
			if ( session ) variables.session = session;
			variables.ga = formatPrix.selectedIndex;//General format=#ca#<BR> 
			variables.ct = typeCouverture;//Couverture type=#ct#<BR>
			variables.ci = urlImageCouv;//Couverture image=#ci#<BR>
			variables.cp = paysageCouv;//Couverture paysage=#cp#<BR>
			variables.cf = "0x" + couleurFond.selectedColor.toString(16);//Couverture couleur fond=#cf#<BR>
			if ( bmpMateriauCouv ) variables.cmi = papier.selectedIndex else variables.cmi = -1;
			variables.cm = bmpMateriauCouv;//Couverture materiau=#cm#<BR>
			variables.ctx = texteCouv.text;//Couverture texte=#ctx#<BR>
			variables.ctc = "0x" + couleurTexte.selectedColor.toString(16);//Couverture couleur texte=#ctc#<BR>
			variables.ctpi = policeCouv.selectedIndex;//Couverture police index
			variables.ctp = policeTexteCouv;//Couverture police texte=#ctp#<BR>
			variables.ctti = taillePoliceCouv.selectedIndex;//Couverture taille index
			variables.ctt = taillePoliceTexteCouv;//Couverture taille texte=#ctt#<BR>
			variables.qt = typeQuatre;//Quatre type=#qt#<BR>
			variables.qi = urlImageQuat;//Quatre image=#qi#<BR>
			variables.qp = paysageQuat;//Quatre paysage=#qp#<BR>
			variables.qf = "0x" + couleurFondQuat.selectedColor.toString(16);//Quatre couleur fond=#qf#<BR>
			if ( bmpMateriauQuat ) variables.qmi = papierQuat.selectedIndex else variables.qmi = -1;
			variables.qm = bmpMateriauQuat;//Quatre materiau=#qm#<BR>
			variables.qtx = texteQuat.text;//Quatre texte=#qtx#<BR>
			variables.qtc = "0x" + couleurTexteQuat.selectedColor.toString(16);//Quatre couleur texte=#qtc#<BR>
			variables.qtpi = policeQuat.selectedIndex;//Quatre police index
			variables.qtp = policeTexteQuat;//Quatre police texte=#qtp#<BR>
			variables.qtti = taillePoliceQuat.selectedIndex;//Quatre taille index
			variables.qtt = taillePoliceTexteQuat;//Quatre taille texte=#qtt#<BR>
			variables.st = typeStylo;//Stylo type=#st#<BR>
			variables.si = urlImageStylo;//Stylo image=#si#<BR>
			variables.sf = "0x" + couleurCorps.selectedColor.toString(16);//Stylo couleur fond=#sf#<BR>
			variables.hp = horizontalStyloTexte;//Capuchon paysage=#hp#<BR>
			variables.hf = "0x" + couleurCapuchon.selectedColor.toString(16);//Capuchon couleur fond=#hf#<BR>
			variables.htx = texteStylo.text;//Capuchon texte=#htx#<BR>
			variables.htc = "0x" + couleurTexteStylo.selectedColor.toString(16);//Capuchon couleur texte=#htc#<BR>
			variables.htpi = policeStylo.selectedIndex;//Capuchon police index
			variables.htp = policeTexteStylo;//Capuchon police texte=#htp#<BR>
			variables.htti = taillePoliceStylo.selectedIndex;//Capuchon taille index
			variables.htt = taillePoliceTexteStylo;//Capuchon taille texte=#htt#<BR>

			var request:URLRequest = new URLRequest(urlredir);
            request.data = variables;
            try {            
                navigateToURL(request,"_self" );//"_blank nouvel onglet"
            }
            catch (e:Error) {
                trace(e.message.toString());
            }
		}
		private function sauveImages():void
		{
			var request:URLRequest = new URLRequest(urlimage);
		    try
		    {
		        if ( fileRefCouv ) fileRefCouv.upload(request,"thefile");
		        if ( fileRefQuat ) fileRefQuat.upload(request,"thefile");
		        if ( fileRefStylo ) fileRefStylo.upload(request,"thefile");
		    }
		    catch (error:Error)
		    {
		        trace(error.message.toString());
		    }

		}
		private function supprimePhoto():void
		{
			vignCouvertureSmall = null;
			vignCouvertureMedium = null;
			vignCouvertureFull = null;
			pixelsImageCouv = null;
			urlImageCouv = "";
			carnetCouv.supprimeImage();
			changeCouverture();
		}
		private function supprimePhotoQuat():void
		{
			vignQuatSmall = null;
			vignQuatMedium = null;
			vignQuatFull = null;
			pixelsImageQuat = null;
			urlImageQuat = "";
			carnetDos.supprimeImage();
			changeQuat();
		}
		private function supprimePhotoStylo():void
		{
			vignStyloMedium = null;
			vignStyloFull = null;
			pixelsImageStylo = null;
			urlImageStylo = "";
			corpsStylo.supprimeImage();
			changeStylo();
		}
		private function handleCouvMouseEvent( evt:MouseEvent ):void
		{
			fileRefCouv = new FileReference();
			fileRefCouv.browse ( [fileFilter] );
			fileRefCouv.addEventListener( Event.SELECT, onImageSelectCouv );
		}
		private function handleQuatMouseEvent( evt:MouseEvent ):void
		{
			fileRefQuat = new FileReference();
			fileRefQuat.browse ( [fileFilter] );
			fileRefQuat.addEventListener( Event.SELECT, onImageSelectQuat );
		}
		private function handleStyloMouseEvent( evt:MouseEvent ):void
		{
			fileRefStylo = new FileReference() ;
			fileRefStylo.browse ( [fileFilter] ) ;
			fileRefStylo.addEventListener( Event.SELECT, onImageSelectStylo );
		}
		private function onImageSelectCouv( evt:Event ):void
		{
			urlImageCouv = uploaddir + fileRefCouv.name;
			fileRefCouv.load();
			fileRefCouv.addEventListener ( Event.COMPLETE, onDataLoaded ) ;
		}
		private function onImageSelectQuat( evt:Event ):void
		{
			urlImageQuat = uploaddir + fileRefQuat.name;
			fileRefQuat.load();
			fileRefQuat.addEventListener ( Event.COMPLETE, onDataLoaded ) ;
		}
		private function onImageSelectStylo( evt:Event ):void
		{
			urlImageStylo = uploaddir + fileRefStylo.name;
			fileRefStylo.load();
			fileRefStylo.addEventListener ( Event.COMPLETE, onDataLoaded ) ;
		}
 
		private function onDataLoaded ( evt:Event ) : void
		{
			var tempFileRef:FileReference = FileReference ( evt.target ) ;
			loader.loadBytes ( tempFileRef.data ) ;
		}
		private function onImageLoadedEtape1( evt:Event ):void
		{
			if (evt) 
			{
				originalCouvertureFull = Bitmap ( evt.target.content );
				originalCouvertureFull.smoothing = true;
				pixelsImageCouv = new BitmapData(originalCouvertureFull.bitmapData.width,originalCouvertureFull.bitmapData.height);
				pixelsImageCouv = originalCouvertureFull.bitmapData;
				
				vignCouvertureFull = new Bitmap( pixelsImageCouv );
				vignCouvertureMedium = new Bitmap( pixelsImageCouv );
				vignCouvertureSmall = new Bitmap( pixelsImageCouv );
				
				vignCouvertureFull.smoothing = true;
				vignCouvertureMedium.smoothing = true; 
				vignCouvertureSmall.smoothing = true; 
				changeCouverture();
			}
		}			
		private function onImageLoadedEtape2( evt:Event ):void
		{
			if (evt) 
			{
				originalQuatFull = Bitmap ( evt.target.content );
				originalQuatFull.smoothing = true;
				pixelsImageQuat = new BitmapData(originalQuatFull.bitmapData.width,originalQuatFull.bitmapData.height);
				pixelsImageQuat = originalQuatFull.bitmapData;
				
				vignQuatFull = new Bitmap( pixelsImageQuat );
				vignQuatMedium = new Bitmap( pixelsImageQuat );
				vignQuatSmall = new Bitmap( pixelsImageQuat );
				
				vignQuatFull.smoothing = true;
				vignQuatMedium.smoothing = true; 
				vignQuatSmall.smoothing = true; 
				changeQuat();
			}
		}
		private function onImageLoadedEtape3( evt:Event ):void
		{
			if (evt) 
			{
				originalStyloFull = Bitmap ( evt.target.content );
				originalStyloFull.smoothing = true;
				pixelsImageStylo = new BitmapData(originalStyloFull.bitmapData.width,originalStyloFull.bitmapData.height);
				pixelsImageStylo = originalStyloFull.bitmapData;
				
				vignStyloFull = new Bitmap( pixelsImageStylo );
				vignStyloMedium = new Bitmap( pixelsImageStylo );
				
				vignStyloFull.smoothing = true;
				vignStyloMedium.smoothing = true; 
				changeStylo();
			}
		}
		private function onImageLoaded( evt:Event ):void
		{
			if (evt) 
			{
				if ( etape == 1 ) 
				{
					originalCouvertureFull = Bitmap ( evt.target.content );
					originalCouvertureFull.smoothing = true;
					pixelsImageCouv = new BitmapData(originalCouvertureFull.bitmapData.width,originalCouvertureFull.bitmapData.height);
					pixelsImageCouv = originalCouvertureFull.bitmapData;
					
					vignCouvertureFull = new Bitmap( pixelsImageCouv );
					vignCouvertureMedium = new Bitmap( pixelsImageCouv );
					vignCouvertureSmall = new Bitmap( pixelsImageCouv );
					
					vignCouvertureFull.smoothing = true;
					vignCouvertureMedium.smoothing = true; 
					vignCouvertureSmall.smoothing = true; 
					changeCouverture();
				}
				if ( etape == 2 ) 
				{
					originalQuatFull = Bitmap ( evt.target.content );
					originalQuatFull.smoothing = true;
					pixelsImageQuat = new BitmapData(originalQuatFull.bitmapData.width,originalQuatFull.bitmapData.height);
					pixelsImageQuat = originalQuatFull.bitmapData;
					
					vignQuatFull = new Bitmap( pixelsImageQuat );
					vignQuatMedium = new Bitmap( pixelsImageQuat );
					vignQuatSmall = new Bitmap( pixelsImageQuat );
					
					vignQuatFull.smoothing = true;
					vignQuatMedium.smoothing = true; 
					vignQuatSmall.smoothing = true; 
					changeQuat();
				}
				if ( etape == 3 ) 
				{
					originalStyloFull = Bitmap ( evt.target.content );
					originalStyloFull.smoothing = true;
					pixelsImageStylo = new BitmapData(originalStyloFull.bitmapData.width,originalStyloFull.bitmapData.height);
					pixelsImageStylo = originalStyloFull.bitmapData;
					
					vignStyloFull = new Bitmap( pixelsImageStylo );
					vignStyloMedium = new Bitmap( pixelsImageStylo );
					
					vignStyloFull.smoothing = true;
					vignStyloMedium.smoothing = true; 
					changeStylo();
				}
				changeEtape( etape );
			}
		}
		private function ioErrorHandler( evt:IOErrorEvent ):void 
		{
            trace("Erreur chargement..." + evt.text);
        }
        private function selectionImage(event:TextEvent):void
        {
			if ( etape == 1 ) 
			{
        		urlImageCouv = event.text;
				currentState = "stateEtape1";
			} 
			else 
			{
				if ( etape == 2 ) 
				{
					urlImageQuat = event.text;
					currentState = "stateEtape2";
				}
				else 
				{
					urlImageStylo = event.text;
					currentState = "stateEtape3";
				}
			}
			changeEtape( etape );
			loader.load( new URLRequest(event.text) ) ;
            panelCarousel.removeAllChildren();
			cr = null;
		}
		private function carouselCloseHandler(event:Event):void 
		{ 
            if (ComboBox(event.target).selectedIndex > 0)
            {
            	panelCarousel.removeAllChildren();
            	cr = null;
            	cr = new flashcomps.Carousel(); 
            	panelCarousel.addChild(cr);
            	cr.addEventListener( "imageSelect", selectionImage);
				cr.loadXML(ComboBox(event.target).selectedItem.@fichier);
				if ( etape == 1 ) 
				{
					currentState = "stateCarousel";
				} 
				else 
				{
					if ( etape == 2 ) currentState = "stateCarouselQuat" else currentState = "stateCarouselStylo";
				}
            }
            else
            {
				if ( etape == 1 ) 
				{
					currentState = "stateEtape1";
				} 
				else 
				{
					if ( etape == 2 ) currentState = "stateEtape2" else currentState = "stateEtape3";
				}
            } 
        }   
		private function voir():void
		{
			titreEtape.text = "Le carnet-stylo";
			currentState = "stateVoir";
		}
		private function materiauCloseHandler(event:Event = null):void 
		{
			if ( event )
			{
			    typePapierCouv = ComboBox(event.target).selectedItem.@type;
	            couleurFond.selectedColor =  ComboBox(event.target).selectedItem.@valeur;
	            switch ( typePapierCouv )
	            {
	            	case 'base':
	            		bmpMateriauCouv = "";
						matCouvFond = null;
						matCouvFond = new BitmapData(1,1,false,couleurFond.selectedColor); 
			            changeCouverture();
	            		break;
	            	case 'image':
	            		bmpMateriauCouv = ComboBox(event.target).selectedItem.@chemin;
	 					var ldr:Loader = new Loader();
						ldr.contentLoaderInfo.addEventListener( Event.COMPLETE, changeMatCouvFond );
						ldr.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ); 
						ldr.load( new URLRequest( bmpMateriauCouv ) );
						CursorManager.setBusyCursor();
	            		break;
	            }
			}
			else
			{
        		bmpMateriauCouv = "";
				matCouvFond = null;
				matCouvFond = new BitmapData(1,1,false,couleurFond.selectedColor); 
	            changeCouverture();
			}
        }   
		private function materiauQuatCloseHandler(event:Event = null):void 
		{ 
 			if ( event )
			{
			    typePapierQuat = ComboBox(event.target).selectedItem.@type ;
	            couleurFondQuat.selectedColor =  ComboBox(event.target).selectedItem.@valeur ;
	            switch ( typePapierQuat )
	            {
	            	case 'base':
	            		bmpMateriauQuat = "";
						matCouvQuat = null;
						matCouvQuat = new BitmapData(1,1,false,couleurFondQuat.selectedColor); 
			            changeQuat();
	            		break;
	            	case 'image':
	            		bmpMateriauQuat = ComboBox(event.target).selectedItem.@chemin;
	 					var ldr:Loader = new Loader();
						ldr.contentLoaderInfo.addEventListener( Event.COMPLETE, changeMatQuatFond );
						ldr.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler ) ; 
						ldr.load( new URLRequest(ComboBox(event.target).selectedItem.@chemin) ) ;
						CursorManager.setBusyCursor();
	            		break;
	            }
			}
			else
			{
        		bmpMateriauQuat = "";
				matCouvQuat = null;
				matCouvQuat = new BitmapData(1,1,false,couleurFondQuat.selectedColor); 
	            changeQuat();
			}
       	}   
		private function materiauStyloCloseHandler(event:Event = null):void 
		{ 
            changeStylo();
       	}   
		private function materiauCapuchonCloseHandler(event:Event = null):void 
		{ 
            changeStylo();
       } 
 		private function changeMatCouvFond( evt : Event ) : void
		{
            CursorManager.removeBusyCursor();
			if (evt) 
			{
				var bmpCouvFond:Bitmap = Bitmap ( evt.target.content );
				bmpCouvFond.smoothing = true;
				matCouvFond = new BitmapData(bmpCouvFond.bitmapData.width,bmpCouvFond.bitmapData.height);
				matCouvFond = bmpCouvFond.bitmapData;
	            changeCouverture();
			}
		}
		private function changeMatQuatFond( evt : Event ) : void
		{
            CursorManager.removeBusyCursor();
			if (evt) 
			{
				var bmpCouvQuat:Bitmap = Bitmap ( evt.target.content );
				bmpCouvQuat.smoothing = true;
				matCouvQuat = new BitmapData(bmpCouvQuat.bitmapData.width,bmpCouvQuat.bitmapData.height);
				matCouvQuat = bmpCouvQuat.bitmapData;
	            changeQuat();
			}
		}
		private function changeMatStyloFond( evt : Event ) : void
		{
            CursorManager.removeBusyCursor();
			if (evt) 
			{
				var bmpCouvStylo:Bitmap = Bitmap ( evt.target.content );
				bmpCouvStylo.smoothing = true;
				matCouvStylo = new BitmapData(bmpCouvStylo.bitmapData.width,bmpCouvStylo.bitmapData.height);
				matCouvStylo = bmpCouvStylo.bitmapData;
	            changeStylo();
			}
		}

		private function policeCloseHandler(event:Event):void 
		{ 
            policeTexteCouv =  ComboBox(event.target).selectedItem.@valeur ;
            changeCouverture();
        }   
		private function policeQuatCloseHandler(event:Event):void 
		{ 
            policeTexteQuat =  ComboBox(event.target).selectedItem.@valeur;
            changeQuat();
        }   
		private function policeStyloCloseHandler(event:Event):void 
		{ 
            policeTexteStylo =  ComboBox(event.target).selectedItem.@valeur;
            changeStylo();
        }   
		private function taillePoliceCloseHandler(event:Event):void 
		{ 
            taillePoliceTexteCouv =  ComboBox(event.target).selectedItem.@valeur;
            changeCouverture();
        }   
		private function taillePoliceQuatCloseHandler(event:Event):void 
		{ 
            taillePoliceTexteQuat =  ComboBox(event.target).selectedItem.@valeur;
            changeQuat();
        }   
		private function taillePoliceStyloCloseHandler(event:Event):void 
		{ 
            taillePoliceTexteStylo =  ComboBox(event.target).selectedItem.@valeur;
            changeStylo();
        }   
		private function selTypeCouv(t:String, img:Image):void
		{
			typeCouverture = t;
			vignetteCouvFull.alpha = .3;
			vignetteCouvMedium.alpha = .3;
			vignetteCouvSmall.alpha = .3;
			img.alpha = 1;
 			changeCouverture();
		}
		private function selTypeQuat(t:String, img:Image):void
		{
			typeQuatre = t;
			vignetteQuatFull.alpha = .3;
			vignetteQuatMedium.alpha = .3;
			vignetteQuatSmall.alpha = .3;
			img.alpha = 1;
 			changeQuat();
		}
		private function selTypeStylo(t:String, img:Image):void
		{
			typeStylo = t;
			vignetteStyloFull.alpha = .3;
			vignetteStyloMedium.alpha = .3;
			img.alpha = 1;
 			changeStylo();
		}
