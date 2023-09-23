package meta.state;

import meta.MusicBeat.MusicBeatState;
import sys.FileSystem;
#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as MP4Handler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import MP4Handler;
#else import vlc.MP4Handler as MP4Handler; #end
#end

class VideoState extends MusicBeatState
{
	public static var videoName:String;

	override public function create()
	{
		super.create();

		#if VIDEOS_ALLOWED
		var filepath:String = SUtil.getPath() + Paths.video(videoName);
		if (!FileSystem.exists(filepath))
		{
			close();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.video(filepath);
		video.onEndReached.add(function()
		{
			close();
			return;
		})
		#else
		close();
		return;
		#end
	}

	public function close()
		Main.switchState(this, new PlayState());
}
