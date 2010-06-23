package {
	// Imports
	import caurina.transitions.Tweener;
	
	import classes.BigPhoto;
	import classes.ThumbNail;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	[SWF(width="466", height="355", backgroundColor="#000000", frameRate="30")]
	public class PhotoGallery extends Sprite
	{
		// Containers
		private var _thumbContainer:Sprite;							// Stores the thumbnails
		private var _nextButton:Sprite;								// Stores the next arrow	
		private var _backButton:Sprite;								// Stores the back arrow
		private var _bigPhoto:BigPhoto;								// The container for the big image
		
		// XML
		private var _xmlLoader:URLLoader;							// Loads the XML file
		private var _xml:XML;										// Stores the XML data
		
		// Image Assets
		[Embed(source="assets/next-arrow.png")]
		private var _nextArrow:Class;								// Embedded asset for the next arrow
		
		[Embed(source="assets/back-arrow.png")]
		private var _backArrow:Class;								// Embedded asset for the back arrow
		
		// Constructor
		public function PhotoGallery()
		{
			init ();
		}
		
		// Initializing method
		private function init ():void
		{	
			_xmlLoader = new URLLoader ();
			_xmlLoader.addEventListener (Event.COMPLETE, xmlComplete, false, 0, true);
			_xmlLoader.load (new URLRequest ("gallery.xml"));
			/*var swfStage:Stage = this.stage;
			swfStage.stage.width = 30;*/

		}
		
		// XML Complete
		private function xmlComplete (e:Event):void
		{
			// Store the XML data
			_xml = new XML (e.target.data);
			
			loadImages ();
			
			// Clean up
			_xmlLoader.removeEventListener (Event.COMPLETE, xmlComplete);
			_xmlLoader = null;
		}
		
		// Load in the thumbs
		private function loadImages ():void
		{
			// Temporary variables
			var imageHeight:uint = _xml.@thumbHeight;
			var imageWidth:uint = _xml.@thumbWidth;
			var imageGap:uint = _xml.@image_gap;
			var rows:uint = _xml.@rows;
			var rowCounter:uint = 0;
			var columnCounter:uint = 0;	
			
			// Instantiate the container and position it on screen
			_thumbContainer = new Sprite ();
			_thumbContainer.x = imageWidth/2 + imageGap;
			_thumbContainer.y = imageHeight/2 + imageGap;
			_thumbContainer.buttonMode = true;
			_thumbContainer.addEventListener (MouseEvent.CLICK, thumbClick, false, 0, true);
			this.addChild (_thumbContainer);
			
			// Loop through the images and create the visual grid	
			for (var i:uint = 0; i < _xml.asset.length(); i++)
			{
				var path:String = _xml.asset[i].thumbnail;
				var description:String = _xml.asset[i].description;
				
				// Create the thumbnail
				var p:ThumbNail = new ThumbNail();
				p.newID = i;
				p.loadImage (path);
				p.description = description;
				p.x = ( imageWidth + imageGap ) * columnCounter;
				p.y = ( imageHeight + imageGap ) * rowCounter; 				
				_thumbContainer.addChild(p);
				
				// Create the grid
				if ((rowCounter + 1) < rows)
				{
					rowCounter++;
				}
				else
				{
					rowCounter = 0;
					columnCounter++;
				}
			}	
			
			// Setup the navigation
			createNavigation ();
		}
		
		// This method handles the click event for the next arrow
		private function nextClick (e:MouseEvent):void
		{
			// 155 is the width + spacing
			if (-_thumbContainer.x < (_thumbContainer.width - stage.stageWidth - 155))
			{
				disableNavigation ();
				Tweener.addTween (_thumbContainer, {x:_thumbContainer.x - 155, time:0.75, transition:"easeOutExpo", onComplete:enableNavigation});	
			} 
		}
		
		// This method handles the click event for the back arrow
		private function previousClick (e:MouseEvent):void
		{
			if (-_thumbContainer.x > 0)
			{
				disableNavigation ();
				Tweener.addTween (_thumbContainer, {x:_thumbContainer.x + 155, time:0.75, transition:"easeOutExpo", onComplete:enableNavigation});	
			} 
		}
		
		// This method handles the click event for the thumbnails
		private function thumbClick (e:MouseEvent):void
		{			
			disableNavigation ();
			
			// Disable the container that stores the thumbnails
			/*_thumbContainer.buttonMode = false;
			_thumbContainer.mouseChildren = false;
			_thumbContainer.removeEventListener (MouseEvent.CLICK, thumbClick);*/
			
			// Get the full image path
			var imagePath:String = _xml.asset[e.target.newID].url;
			
			// Instantiate the big photo
			if ( _bigPhoto )
			{
				Tweener.addTween (_bigPhoto, {alpha:0, time:1, onComplete:deletePhoto});
			}
			
			
			_bigPhoto = new BigPhoto ();
			_bigPhoto.buttonMode = true;
			_bigPhoto.x = 10;
			_bigPhoto.y = 10;
			_bigPhoto.alpha = 0;
			_bigPhoto.loadImage (imagePath);
			_bigPhoto.addEventListener (MouseEvent.CLICK, closePhoto, false, 0, true);
			this.addChild (_bigPhoto);
			
			// Fade up the photo
			Tweener.addTween (_bigPhoto, {alpha:1, time:1});
		}
		
		// Fade out the photo
		// When the image finishes fading, delete the photo, and enable the navigation items
		private function closePhoto (e:MouseEvent):void
		{
			Tweener.addTween (_bigPhoto, {alpha:0, time:1, onComplete:deletePhoto});
		}
		
		private function deletePhoto ():void
		{
			if ( _bigPhoto )
			{
				_bigPhoto.buttonMode = false;
				_bigPhoto.removeEventListener( MouseEvent.CLICK, closePhoto );
				_bigPhoto.destroy();
				
				this.removeChild ( _bigPhoto );
				_bigPhoto = null;
			}
			
			/*_thumbContainer.buttonMode = true;
			_thumbContainer.mouseChildren = true;
			_thumbContainer.addEventListener (MouseEvent.CLICK, thumbClick, false, 0, true);*/
			
			enableNavigation ();
		}
		
		private function createNavigation ():void
		{
			// Instantiate the next arrow
			var n:Bitmap = new _nextArrow ();
			
			// Instantiate the nextButton container
			// Add the next button as a child of the nextButton container
			_nextButton = new Sprite ();
			this.addChild (_nextButton);
			_nextButton.addChild (n);
			_nextButton.x = stage.stageWidth - _nextButton.width;
			_nextButton.y = stage.stageHeight - 70;
			
			// Instantiate the back arrow
			var b:Bitmap = new _backArrow ();
			
			// Instantiate the backButton container
			// Add the next button as a child of the backButton container
			_backButton = new Sprite ();
			this.addChild (_backButton);
			_backButton.addChild (b);	
			_backButton.x = _nextButton.x - _nextButton.width - 5;		
			_backButton.y = stage.stageHeight - 70;
			
			enableNavigation ();
		}
		
		private function enableNavigation ():void
		{
			_nextButton.buttonMode = true;
			_nextButton.addEventListener (MouseEvent.CLICK, nextClick, false, 0, true);
			
			_backButton.buttonMode = true;
			_backButton.addEventListener (MouseEvent.CLICK, previousClick, false, 0, true);
		}
		
		private function disableNavigation ():void
		{
			_nextButton.buttonMode = false;
			_nextButton.removeEventListener (MouseEvent.CLICK, nextClick);
			
			_backButton.buttonMode = false;
			_backButton.removeEventListener (MouseEvent.CLICK, previousClick);
		}
	}
}