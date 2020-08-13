package com.newgrounds 
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author Mike Welsh
	 */
	public class SmartURLLoader extends EventDispatcher
	{
		private static var _loaders:Dictionary	= new Dictionary();
		private static const CRLF:String		= "\r\n";
		
		
		private var _variables:Dictionary;
		private var _files:Dictionary;
		private var _hasVariables:Boolean;

		private var _method:String				= URLRequestMethod.GET;

		private var _urlRequest:URLRequest;
		private var _urlLoader:URLLoader;
		private var _dataFormat:String 			= URLLoaderDataFormat.TEXT;

		private var _openBrowser:Boolean		= false;
		private var _preventCache:Boolean		= false;
		
		public var owner:*;	// TODO!!!
		
		public function SmartURLLoader() 
		{
			_urlRequest = new URLRequest();
			_variables = new Dictionary();
		}
		
		public function get responseFormat():String			{ return _dataFormat; }
		public function set responseFormat(s:String):void	{ _dataFormat = s; }
		public function get response():*					{ return _urlLoader.data; }
		public function get hasFiles():Boolean				{ return Boolean(_files); }
		public function get method():String					{ return _method; }
		public function set method(m:String):void
		{
			if (hasFiles && m == URLRequestMethod.GET)
				throw new IllegalOperationError("GET cannot be used to upload files.");
			_method = m;
		}
		public function get openBrowser():Boolean			{ return _openBrowser; }
		public function set openBrowser(b:Boolean):void		{ _openBrowser = b; }
		public function get preventCache():Boolean			{ return _preventCache; }
		public function set preventCache(b:Boolean):void	{ _preventCache = b; }
		
		public function addVariable(name:String, value:* = ""):void
		{
			_variables[name] = value;
			if (value)
				_hasVariables = true;
		}
		
		public function addFile(fileName:String, data:ByteArray, dataField:String, contentType:String = "application/octect-stream"):void
		{
			method = URLRequestMethod.POST;
			
			if (!_files)
				_files = new Dictionary();

			_files[fileName] = new File(fileName, data, dataField, contentType);
		}
		
		public function clearVariables():void
		{
			_variables = new Dictionary();
		}
		
		public function clearFiles():void
		{
			_files = null;
		}
		
		
		public function load(url:String):void
		{
			_urlRequest.url = url;
			if (_preventCache)
			{

				url += "?seed=" + Math.random();	// TODO: do I need seed for POST?
				if (_hasVariables) url += "&";
			}
				
			_urlRequest.method = _method;

			if (_urlRequest.method == URLRequestMethod.GET || !hasFiles)
			{
				_urlRequest.contentType = "application/x-www-form-urlencoded";
				if (_hasVariables)
				{
					var urlVariables:URLVariables = new URLVariables();
					for (var key:String in _variables)
						urlVariables[key] = _variables[key];
					_urlRequest.data = urlVariables;
				}
			}
			else
			{
				var boundary:String = "";
				for (var i:uint = 0; i < 0x20;  i++)
					boundary += String.fromCharCode( uint(97 + Math.random() * 25) );
				_urlRequest.contentType = 'multipart/form-data; boundary="' + boundary + '"';
				_urlRequest.data = buildMultipartData(boundary);
			}
			
			if (openBrowser)
			{
				navigateToURL(_urlRequest, "_blank");	// always _blank?
			}
			else
			{
				_urlLoader = new URLLoader();
				_urlLoader.dataFormat = _dataFormat;					
				
				_urlLoader.addEventListener(Event.COMPLETE, onComplete);
				_urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
				_loaders[_urlLoader] = this;

				try
				{
					_urlLoader.load(_urlRequest);
				}
				catch (error:Error)
				{
					var event:SecurityErrorEvent = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message);
					onSecurityError(event);
				}
			}
		}
		
		public function close():void
		{
			try {
				_urlLoader.close();
			}
			catch(e:Error) { }
		}
		
		public function dispose():void
		{
			_files = null;
			_variables = null;
			
			if (_urlLoader)
			{
				_urlLoader.removeEventListener(Event.COMPLETE, onComplete);
				_urlLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_urlLoader = null;
			}
			_urlRequest = null;
			
			_loaders[this] = null;
			// TODO
		}
		
		private function buildMultipartData(boundary:String):ByteArray
		{
			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;
			
			boundary = "--" + boundary;
			
			for (var key:String in _variables)
			{
				postData.writeUTFBytes(boundary + CRLF);
				postData.writeUTFBytes('Content-Disposition: form-data; name="' + key + '"' + CRLF);
				postData.writeUTFBytes(CRLF);
				postData.writeUTFBytes(_variables[key] + CRLF);
			}
			
			if (hasFiles)
			{
				for each(var file:File in _files)
				{
					postData.writeUTFBytes(boundary + CRLF);
					postData.writeUTFBytes('Content-Disposition: form-data; name="Filename"' + CRLF);
					postData.writeUTFBytes(CRLF);
					postData.writeUTFBytes(file.fileName + CRLF);
					
					postData.writeUTFBytes(boundary + CRLF);
					postData.writeUTFBytes('Content-Disposition: form-data; name="' + file.dataField + '"; filename="' + file.fileName + '"' + CRLF);
					postData.writeUTFBytes('Content-Type: ' + file.contentType + CRLF);
					postData.writeUTFBytes(CRLF);
					
					postData.writeBytes(file.data);
					postData.writeUTFBytes(CRLF);
				}
				
				postData.writeUTFBytes(boundary + CRLF);
				postData.writeUTFBytes('Content-Disposition: form-data; name="Upload"' + CRLF);
				postData.writeUTFBytes(CRLF);
				postData.writeUTFBytes('Submit Query' + CRLF);
			}
			
			postData.writeUTFBytes(boundary + "--");

			postData.position = 0;
			trace(postData.readUTFBytes(postData.length));
			postData.position = 0;
			return postData;
		}
		
		private function onComplete(e:Event):void
		{
			dispatchEvent(e);
			dispose();
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e);
		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			dispatchEvent(e);
			dispose();
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void
		{
			dispatchEvent(e);
			dispose();
		}
		
		private function onHTTPStatus(e:HTTPStatusEvent):void
		{
			dispatchEvent(e);
		}
	}
	
}

internal class File
{
	internal var fileName:String;
	internal var data:flash.utils.ByteArray;
	internal var dataField:String;
	internal var contentType:String;
	
	public function File(fileName:String, data:flash.utils.ByteArray, dataField:String = "Filedata", contentType:String = "application/octet-stream")
	{
		this.fileName = fileName;
		this.data = data;
		this.dataField = dataField;
		this.contentType = contentType;
	}
}