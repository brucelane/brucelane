// Code Behind for FlexFileUpload.mxml


            import com.newmediateam.fileIO.MultiFileUpload;
            import com.razuna.AuthenticationService;
            import com.razuna.LoginhostResultEvent;
            
            import flash.net.FileFilter;

            public var multiFileUpload:MultiFileUpload;
            
             // Set the File Filters you wish to impose on the applicaton
            public var imageTypes:FileFilter = new FileFilter("Images (*.jpg; *.jpeg; *.gif; *.png)" ,"*.jpg; *.jpeg; *.gif; *.png");
        	public var videoTypes:FileFilter = new FileFilter("Flash Video Files (*.flv)","*.flv");
        	public var documentTypes:FileFilter = new FileFilter("Documents (*.pdf), (*.doc), (*.rtf), (*.txt)",("*.pdf; *.doc; *.rtf, *.txt"));
            
            // Place File Filters into the Array that is passed to the MultiFileUpload instance
            public var filesToFilter:Array = new Array(imageTypes,videoTypes,documentTypes);
            
            //public var uploadDestination:String = "http://api.razuna.com/index.cfm";  // Modify this variable to match the  URL of your site
            public var uploadDestination:String;  
            //public var uploadDestination:String = "http://sonata.local:8080/global/host/dam/index.cfm";  // Modify this variable to match the  URL of your site
			private var sessiontoken:String;
		[Bindable]
		private var xData:XML;
            
            public function initApp():void{
            	logon();
          
           }
		private function logon():void
		{
			var loginService:AuthenticationService = new AuthenticationService();
			loginService.addloginhostEventListener(loginListener);
			loginService.loginhost( 'batchass.razuna.com', 'batchass', '');	
		}

		private function loginListener(event:LoginhostResultEvent):void
		{
			var result:String =	event.result;
			xData = XML(result);
			sessiontoken = xData..sessiontoken;
			trace(sessiontoken + "(loginListener)");
			if ( sessiontoken.length < 30 ) 
			{
				trace( "Access denied" );
			}
			else
			{
				trace( "Connected " );

				uploadDestination = "http://batchass.razuna.com/index.cfm?fa=c.apiupload&sessiontoken=" + sessiontoken + "&destfolderid=1"; 
	            
	            var postVariables:URLVariables = new URLVariables;
	            postVariables.name = "up";
	            postVariables.fa = "c.apiupload";
	            postVariables.sessiontoken = sessiontoken;
	            postVariables.destfolderid = 1;
	                
	            multiFileUpload = new MultiFileUpload(
	                filesDG,
	                browseBTN,
	                clearButton,
	                delButton,
	                upload_btn,
	                progressbar,
	                uploadDestination,
	                postVariables,
	                350000,
	                filesToFilter
	                );
	            
	           multiFileUpload.addEventListener(Event.COMPLETE,uploadsfinished);

			}
 		}           
           public function uploadsfinished(event:Event):void{
 				trace( "uploadsfinished " );          
           		
           }