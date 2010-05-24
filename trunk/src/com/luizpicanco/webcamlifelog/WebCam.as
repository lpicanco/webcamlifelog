package com.luizpicanco.webcamlifelog
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import mx.controls.VideoDisplay;
	import mx.formatters.DateFormatter;
	import mx.graphics.codec.JPEGEncoder;

	public class WebCam
	{
		private var camera: Camera;
		private var cameraView: Video;
		private var dir: String;
		
		public function WebCam(dir: String)
		{
			this.dir = dir;
		}
		
		public function shoot(): void {
			camera = Camera.getCamera();
			camera.addEventListener(ActivityEvent.ACTIVITY, onActivity);
			camera.setMode(640, 480, 30);
			cameraView = new Video(camera.width, camera.height);
			cameraView.attachCamera(camera);
		}
		
		private function onActivity(event:ActivityEvent):void {
			if (camera.currentFPS > 0) {
				var snapshot: BitmapData = new BitmapData(cameraView.width, cameraView.height);
				snapshot.draw(cameraView);		
				cameraView.attachCamera(null);
				camera = null;							
				
				var imgByteArray: ByteArray = new JPEGEncoder(80).encode(snapshot);
				savePhoto(imgByteArray);
			}
		}
		
		private function savePhoto(imageData: ByteArray): void {
			var fl:File = generateFileName();
			var fs:FileStream = new FileStream();
			
			try{
				fs.open(fl,FileMode.WRITE);
				fs.writeBytes(imageData);
				fs.close();
			}catch(e:Error){
				trace(e.message);
			}
		}
		
		private function generateFileName(): File {
			var df: DateFormatter = new DateFormatter();
			df.formatString = "YYYYMMDD_HHNN";

			var name: String = df.format(new Date()) + "_snapshot.jpg";
			var fl: File = File.desktopDirectory.resolvePath(dir + "/" + name);
			return fl;
		}
	}
}