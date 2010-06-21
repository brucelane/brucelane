package classes
{
	import caurina.transitions.Tweener;
	
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class ThumbNail extends Sprite
	{
		// Containers
		private var _imageLoader:Loader;								// Loads in the thumbnail
		private var _imageContainer:Sprite;								// Container for the thumbnail
		private var _mask:Shape;										// Container for the mask
		private var _descriptionContainer:Sprite;						// Container for the description
		
		// TextFields
		private var _description:TextField;								// TextField for the container
		
		// Logic
		private var _newID:uint;										// The ID of the object
		
		[Embed(systemFont="Arial", fontName="arial", embedAsCFF='false', fontWeight="bold", mimeType='application/x-font-truetype')]
		private var _arial:Class;										// Embedded asset for the font
		
		// Constructor
		public function ThumbNail ()
		{
			super ();
			
			init ();
		}
		
		// Initializing method
		private function init ():void
		{
			// Instantiate the container
			_imageContainer = new Sprite ();
			_imageContainer.alpha = 0;
			this.addChild (_imageContainer);
			
			createDescription ();
			
			this.mouseChildren = false;
			this.addEventListener (MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			this.addEventListener (MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		///////////////////////////////////////////////////////////////////////////////////				
		public function loadImage (path:String):void
		{
			_imageLoader = new Loader ();
			_imageLoader.contentLoaderInfo.addEventListener (Event.COMPLETE, imageComplete, false, 0, true);
			_imageLoader.load (new URLRequest (path));
		}				
		
		// Getter/Setter Methods
		public function get newID ():uint
		{
			return this._newID;
		}
		
		public function set newID (value:uint):void
		{
			this._newID = value;
		}
		
		public function get description ():String
		{
			return this._description.text;
		}
		
		public function set description (value:String):void
		{
			this._description.text = value;
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		//
		// Private Methods
		//
		///////////////////////////////////////////////////////////////////////////////////
		private function onMouseOver (e:MouseEvent):void
		{
			Tweener.addTween (_descriptionContainer, {y:75, time:0.5, transition:"easeOutExpo"});
		}
		
		private function onMouseOut (e:MouseEvent):void
		{
			Tweener.addTween (_descriptionContainer, {y:150, time:0.5, transition:"easeOutExpo"});
		}		
		
		private function imageComplete (e:Event):void
		{
			// Reposition the loaded content to the center
			_imageLoader.x = -(_imageLoader.width / 2);
			_imageLoader.y = -(_imageLoader.height / 2);
			_imageContainer.addChildAt (_imageLoader, 0);
			
			// Apply background after the image has completely loaded
			drawBackground ();
			
			// Draw the mask around the description
			drawMask ();
			
			// Fade in the container
			Tweener.addTween (_imageContainer, {alpha:1, time:0.5});
			
			// Clean up
			_imageLoader.contentLoaderInfo.removeEventListener (Event.COMPLETE, imageComplete);
		}
		
		// Draws a background behind _imageContainer
		private function drawBackground ():void
		{
			_imageContainer.graphics.beginFill (0xFFFFFF);
			_imageContainer.graphics.drawRect (_imageLoader.x - 1, _imageLoader.y - 1, _imageLoader.width + 2, _imageLoader.height + 2);
			_imageContainer.graphics.endFill ();
		}
		
		// Creates everything for the description
		private function createDescription ():void
		{
			// Instantiate the container
			_descriptionContainer = new Sprite ();
			_descriptionContainer.y = 150;
			_descriptionContainer.graphics.beginFill (0x000000, 0.75);
			_descriptionContainer.graphics.drawRect (-75, -75, 150, 75);
			_descriptionContainer.graphics.endFill ();
			_imageContainer.addChild (_descriptionContainer);
			
			// Specify text formatting for the description Text Field
			var tf:TextFormat = new TextFormat ();
			tf.color = "0xFFFFFF";
			tf.align = "center";
			tf.font = "arial";
			tf.bold = true;
			tf.size = 12;
			
			// Instantiate the TextF ield
			_description = new TextField ();
			_description.x = -75;
			_description.y = -70;
			_description.width = 150;
			_description.wordWrap = true;
			_description.embedFonts = true;
			_description.defaultTextFormat = tf;
			_description.autoSize = TextFieldAutoSize.LEFT;
			_descriptionContainer.addChild (_description);
		}
		
		// Draws a mask our _descriptionContainer
		private function drawMask ():void
		{
			// Draw the mask shape
			_mask = new Shape ();
			_mask.graphics.beginFill (0xFF0000);
			_mask.graphics.drawRect (_imageLoader.x, _imageLoader.y, _imageLoader.width, _imageLoader.height);
			_mask.graphics.endFill ();
			addChild (_mask);
			
			// Apply the mask to the container
			_descriptionContainer.mask = _mask;
		}
	}
}