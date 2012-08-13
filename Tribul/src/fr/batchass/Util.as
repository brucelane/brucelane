package fr.batchass
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.formatters.DateFormatter;
	
	public class Util
	{
		private static var dateFormatter:DateFormatter;
		private static var millisDateFormatter:DateFormatter;
		private static var millisTimeFormatter:DateFormatter;
		private static var _nowDate:String;
		private static var _sessionDate:String;
		
		public static function trim(s:String):String 
		{
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
		public static function log( text:String, clear:Boolean=false ):void
		{
			
			var file:File = File.applicationStorageDirectory.resolvePath( sessionDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( nowTime + "\t" + text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );
			
		} 
		public static function errorLog( text:String, clear:Boolean=false ):void
		{
			
			var file:File = File.applicationStorageDirectory.resolvePath( "error-" + sessionDate + ".log" );
			var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, fileMode );
			
			fileStream.writeMultiByte( nowTime + "\t" + text + "\n", File.systemCharset );
			fileStream.close();
			trace( text );
			
		} 

		public static function get nowDate():String
		{
			if ( !millisDateFormatter )
			{
				millisDateFormatter = new DateFormatter();
				millisDateFormatter.formatString = "YYYYMMDD-HHhNNmnSSsQQQ";
			}
			_nowDate = millisDateFormatter.format(new Date());	
			return _nowDate;
		}
		public static function get nowTime():String
		{
			if ( !millisTimeFormatter )
			{
				millisTimeFormatter = new DateFormatter();
				millisTimeFormatter.formatString = "HHhNNmnSSsQQQ";
			}
			return millisTimeFormatter.format(new Date());
		}
		
		public static function get sessionDate():String
		{
			if ( !_sessionDate )
			{
				if ( !dateFormatter )
				{
					dateFormatter = new DateFormatter();
					dateFormatter.formatString = "HH";
				}
				_sessionDate = dateFormatter.format(new Date());	
			}
			return _sessionDate;
		}
		
		public static function getFileNameFromFormerSlash( url:String ):String
		{
			var fileName:String = "";
			var lastSlash:int = url.lastIndexOf( '/' );
			var formerSlash:int = url.substr( 0, lastSlash - 1).lastIndexOf( '/' );
			if ( formerSlash > -1 )
			{
				fileName = url.substr( formerSlash + 1 );
			}
			return fileName;
		}
		
		public static function getPathNameFromFormerSlash( url:String ):String
		{
			var pathName:String = "";
			var lastSlash:int = url.lastIndexOf( '/' );
			var formerSlash:int = url.substr( 0, lastSlash - 1).lastIndexOf( '/' );
			if ( formerSlash > -1 )
			{
				pathName = url.substr( formerSlash + 1, lastSlash - formerSlash - 1);
			}
			return pathName;
		}
		
		public static function getFileName( url:String ):String
		{
			var fileName:String = url;
			var lastSlash:int = url.lastIndexOf( '/' );
			var lastBackSlash:int = url.lastIndexOf( '\\' );
			var lastChar:int = Math.max( lastSlash, lastBackSlash );
			if ( lastChar > -1 )
			{
				fileName = url.substr( lastChar + 1 );
			}
			return fileName;
		}
		public static function getLastSeparatorIndex( url:String ):int
		{
			var fileName:String = url;
			var lastSlash:int = url.lastIndexOf( '/' );
			var lastBackSlash:int = url.lastIndexOf( '\\' );
			
			return Math.max( lastSlash, lastBackSlash );
		}
		
		public static function getFileNameWithoutTrailingNumbersAndExtension( url:String ):String
		{
			var lastDot:int;
			var fileName:String = getFileName( url );
			
			var patternNumber:RegExp = /\d*\./g;  
			fileName = fileName.replace(patternNumber,".");
			
			var patternRemoveSpecial:RegExp = /[-_().]\./g;  
			fileName = fileName.replace(patternRemoveSpecial,".");
			
			
			lastDot = fileName.lastIndexOf( '.' );
			if ( lastDot > -1 ) fileName = fileName.substr( 0, lastDot );
			
			if ( fileName.length < 1 )
			{
				//all characters removed 
				fileName = getFileName( url );
				lastDot = fileName.lastIndexOf( '.' );
				if ( lastDot > -1 ) fileName = fileName.substr( 0, lastDot );
			}
			
			return fileName;
		}
		
		public static function getFileNameWithoutExtensionWithDate( url:String ):String
		{
			var fileName:String = getFileName( url );
			var lastDot:int = fileName.lastIndexOf( '.' );
			if ( lastDot > -1 ) fileName = fileName.substr( 0, lastDot );
			
			var millisecs:DateFormatter = new DateFormatter();
			millisecs.formatString = "YYYYMMDD-HHNNSSQQQ-";
			
			fileName = millisecs.format(new Date()) + fileName;
			
			return fileName;
		}
		public static function getFileNameWithSafePath( url:String ):String
		{
			var patternBackslash:RegExp = /\\/g;  
			var patternForwardslash:RegExp = /\//g;  
			var patternColon:RegExp = /:/g;  
			var fileName:String = url.replace(patternBackslash,"§");
			
			fileName = fileName.replace(patternForwardslash,"§");
			fileName = fileName.replace(patternColon,"");
			
			return fileName;
		}
	}
}
