package classes
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class BigPhoto extends Sprite
	{
		// Containers
		private var _imageLoader:Loader;								// Loads in the thumbnail
		private var _imageContainer:Sprite;								// Container for the thumbnail
		
		// Constructor
		public function BigPhoto ()
		{
			super();
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
		
		// Clean up method
		public function destroy ():void
		{
			_imageContainer.removeChild (_imageLoader);
			_imageLoader.unload ();
			_imageLoader = null;
			
			this.removeChild (_imageContainer);
			_imageContainer = null;	
		}
		
		///////////////////////////////////////////////////////////////////////////////////
		//
		// Private Methods
		//
		///////////////////////////////////////////////////////////////////////////////////	
		private function imageComplete (e:Event):void
		{
			// Instantiate the container
			_imageContainer = new Sprite ();
			this.addChild (_imageContainer);
			
			// Add the loader
			_imageContainer.addChild (_imageLoader);
			
			// Clean up
			_imageLoader.contentLoaderInfo.removeEventListener (Event.COMPLETE, imageComplete);
		}
	}
}