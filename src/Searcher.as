package
{
	import com.codezen.helper.WebWorker;
	import com.codezen.helper.Worker;
	import com.codezen.mse.playr.PlayrTrack;
	import com.codezen.mse.search.ISearchProvider;
	import com.codezen.util.MD5;
	import com.codezen.vkontakte.api.VkAPIService;
	
	import flash.events.Event;
	
	import mx.utils.StringUtil;
	
	public class Searcher extends Worker implements ISearchProvider
	{
		// results array
		private var _result:Vector.<PlayrTrack>;
		
		// limit of duration
		private var _finddur:int;
		//artist|track
		private var _query:String;
		
		private var vkMusic:VkAPIService;
		
		public function Searcher()
		{
			super();
			setAuthDetails("2011434", "4J9C9AnuPjLLa8erkWLI");
		}
		
		public function get PLUGIN_NAME():String{
			return "Vkontakte API MP3 Search";
		}
		
		public function get AUTHOR_NAME():String{
			return "yamalight";
		}
		
		public function get result():Vector.<PlayrTrack>{
			return _result;
		}
		
		public function get requiresAuth():Boolean{ return true; }
		public function setAuthDetails(appID:String, appKey:String):void{
			vkMusic = new VkAPIService(appID, appKey, false);
			vkMusic.addEventListener(Event.COMPLETE, onInit);
		}
		
		private function onInit(e:Event):void{
			vkMusic.removeEventListener(Event.COMPLETE, onInit);
			trace('vk plugin inited');
			
			this.dispatchEvent(new Event(Event.INIT));
		}
		
		public function search(query:String, durationMs:int = 0):void{
			this._query = query;
			this._finddur = durationMs;
			
			vkMusic.addEventListener(Event.COMPLETE, onResults);
			vkMusic.findSongs(query);
		}
		
		/**
		 * 
		 * @param evt
		 * Result parser on recieve
		 */
		private function onResults(evt:Event):void{
			vkMusic.removeEventListener(Event.COMPLETE, onResults);
			
			trace('done');
			_result = new Vector.<PlayrTrack>();
			var audio:Array = vkMusic.audio;
			var track:PlayrTrack;
			
			for each(track in audio){
				if(_finddur != 0){
					if( Math.floor(_finddur - (track.totalSeconds*1000)) < 1000 ){
						_result.push(track);
					}
				}else{
					_result.push(track);
				}
			}
			
			endLoad();
		}
		
	}
}