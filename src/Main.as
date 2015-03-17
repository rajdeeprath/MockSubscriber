package
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import flash.media.Video;
	import flash.text.TextField;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.Event;
	import flash.events.NetStatusEvent;

	
	/**
	 * ...
	 * @author Krishna
	 */
	public class Main extends Sprite 
	{
		private const SERVER:String = "rtmp://192.168.1.109/live";
		private const STREAM:String = "PxNnc64DQdCzYAvSlW";
		private var vid:Video;
		private  var txtStats:TextField;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var playing:Boolean;
		

		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			initialize();
		}
		
		private function initialize():void
		{
			this.addEventListener(Event.ENTER_FRAME, onFrame);	
			
			var bg:Shape = new Shape();
			bg.graphics.lineStyle(0, 0, 1);
			bg.graphics.beginFill(0, 1);
			bg.graphics.drawRect(0, 0, 320, 240);
			bg.graphics.endFill();
			addChild(bg);
			
			vid = new Video();
			vid.width = 320;
			vid.height = 240;
			addChild(vid);
			
			
			txtStats = new TextField();
			addChild(txtStats);
			txtStats.width = 320;
			txtStats.height = 200;
			txtStats.border = true;
			txtStats.type = TextFieldType.DYNAMIC;
			txtStats.multiline = true;			
			txtStats.x = vid.x;
			txtStats.y = vid.y + vid.height;
			txtStats.setTextFormat(new TextFormat("_sans", 16, 0, true, null, null, null, null, "left"));
			
			startConnection();
		}

		private function startConnection():void
		{
			nc = new NetConnection();
			nc.client = this;
			nc.addEventListener(NetStatusEvent.NET_STATUS, onConnStatus);
			nc.connect(SERVER);
		}


		private function startStream():void
		{
			ns = new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
			ns.client = this;
			ns.bufferTime = 0.1;
			ns.bufferTimeMax = 0.3;
			ns.useHardwareDecoder = true;
			
			ns.play(STREAM);
		}

		private function onStreamStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);
			
			switch(e.info.code)
			{
				case "NetStream.Play.Start":
				vid.attachNetStream(ns);
				playing = true;
				break;
			}
		}

		private function onConnStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);

			switch(e.info.code)
			{
				case "NetConnection.Connect.Success":
				startStream();
				break;
			}
		}

		private function onFrame(e:Event):void
		{
			var msg:String = "";

			if (ns && playing) {
			msg += "\n";
			msg += "BufferLength " + ns.bufferLength + " ms";
			msg += "\n";
			msg += "bufferTimeMax " + ns.bufferTimeMax  + " ms";
			msg += "\n";
			msg += "bufferTime " + ns.bufferTime + " ms";
			msg += "\n";
			msg += "currentFPS " + Math.round(ns.currentFPS);
			msg += "\n";
			msg += "decodedFrames " + ns.decodedFrames;
			msg += "\n";
			msg += "droppedFrames " + ns.info.droppedFrames;
			msg += "\n";
			msg += "currentBytesPerSecond " + Math.round(ns.info.currentBytesPerSecond / 125) + " kbps";
			msg += "\n";
			msg += "liveDelay " + ns.liveDelay + " ms";
			msg += "\n";
			msg += "byteCount " + ns.info.byteCount + " bytes";
			msg += "\n";
			
			//if (ns.bufferLength > ns.bufferTimeMax)
			//ns.bufferTime = .01;
			}

			txtStats.text = msg;
			
			
		}
		
		public function onBWDone(...rest):void
		{
			return;
		}
		
		
		public function onMetaData (...rest):void
		{
			return;
		}
	}
	
}