package;

/*
	Aw hell yeah! something I can actually work on!
 */
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import meta.CoolUtil;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets;

using StringTools;

class Paths
{
	// Here we set up the paths class. This will be used to
	// Return the paths of assets and call on those assets as well.
	public static var SOUND_EXT = "ogg";

	// level we're loading
	static var currentLevel:String = 'assets';
	static var previousLevel:String = 'assets';

	// set the current level top the condition of this function if called
	static public function setCurrentLevel(name:String):Void
	{
		if (currentLevel != name)
		{
			previousLevel = currentLevel;
			currentLevel = name.toLowerCase();
		}
	}

	static public function revertCurrentLevel():Void
	{
		var tempCurLevel = currentLevel;
		currentLevel = previousLevel;
		previousLevel = tempCurLevel;
	}

	// stealing my own code from psych engine
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function excludeAsset(key:String):Void
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [];

	public static function clearUnusedMemory():Void
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					obj.bitmap.lock();

					if (currentTrackedTextures.exists(key))
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}

					@:privateAccess
					if (Assets.cache.hasBitmapData(key))
					{
						Assets.cache.removeBitmapData(key);
						Assets.cache.clearBitmapData(key);
						Assets.cache.clear(key);
						if (FlxG.bitmap._cache.exists(key))
							FlxG.bitmap._cache.remove(key);
					}

					obj.bitmap.dispose();
					obj.bitmap.disposeImage();
					obj.destroy();
					obj = null;
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				if (currentTrackedSounds.exists(key))
				{
					if (Assets.cache.hasSound(key))
					{
						Assets.cache.removeSound(key);
						Assets.cache.clearSounds(key);
						Assets.cache.clear(key);
						currentTrackedSounds.remove(key);
					}
				}
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory():Void
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				obj.bitmap.lock();

				if (Assets.cache.hasBitmapData(key))
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					if (FlxG.bitmap._cache.exists(key))
						FlxG.bitmap._cache.remove(key);
				}

				obj.bitmap.dispose();
				obj.bitmap.disposeImage();
				obj.destroy();
				obj = null;
			}
		}

		for (key in Assets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				if (Assets.cache.hasSound(key))
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	public static function returnGraphic(key:String, ?library:String, ?compression:Bool = false):FlxGraphic
	{
		var path:String = getPath('images/$key.png', IMAGE, library);
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var bitmap:BitmapData = Assets.getBitmapData(path);
				var graphic:FlxGraphic;

				if (compression)
				{
					var texture:Texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(path, texture);

					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;

					trace('new texture $key, bitmap is $bitmap');
					graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path, true);
				}
				else
				{
					graphic = FlxGraphic.fromBitmapData(bitmap, false, path, true);
					trace('new bitmap $path, not textured');
				}

				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('$path its null');
		return null;
	}

	public static function returnSound(path:String, key:String, ?library:String):Sound
	{
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		if (Assets.exists(path, SOUND))
		{
			if (!currentTrackedSounds.exists(gottenPath))
				currentTrackedSounds.set(gottenPath, Assets.getSound(gottenPath));

			localTrackedAssets.push(gottenPath);
			return currentTrackedSounds.get(gottenPath);
		}

		trace('$gottenPath its null');
		return null;
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String>):String
	{
		if (library != null)
			return getLibraryPath(file, type, library);
		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, type:AssetType, library:String = "preload"):String
	{
		return if (library == "preload" || library == "default" || library.contains('assets')) getPreloadPath(file); else getLibraryPathForce(file, type,
			library);
	}

	static function getLibraryPathForce(file:String, type:AssetType, library:String = 'assets'):String
	{
		var returnPath:String = '$library:$library/$file';
		if (!Assets.exists(returnPath, type))
			returnPath = CoolUtil.swapSpaceDash(returnPath);
		return returnPath;
	}

	static public function shader(name:String):String
	{
		return Assets.getText('assets/shaders/$name.frag');
	}

	static function getPreloadPath(file:String):String
	{
		var returnPath:String = '$currentLevel/$file';
		if (!Assets.exists(returnPath))
			returnPath = CoolUtil.swapSpaceDash(returnPath);
		return returnPath;
	}

	static public function file(file:String, type:AssetType = TEXT, ?library:String):String
	{
		return getPath(file, type, library);
	}

	static public function txt(key:String, ?library:String):String
	{
		return getPath('$key.txt', TEXT, library);
	}

	static public function video(key:String):String
	{
		return 'assets/cutscenes/$key.mp4';
	}

	static public function xml(key:String, ?library:String):String
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	static public function json(key:String, ?library:String):String
	{
		return getPath('songs/$key.json', TEXT, library);
	}

	static public function module(key:String, ?library:String):String
	{
		return getPath('$key.hxs', TEXT, library);
	}

	static public function songJson(song:String, secondSong:String, old:Bool, ?library:String)
		return getPath('songs/${song.toLowerCase()}/${secondSong.toLowerCase() + (old ? '_old' : '')}.json', TEXT, library);

	static public function sound(key:String, ?library:String):Dynamic
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		var sound:Sound = returnSound('sounds', key + FlxG.random.int(min, max), library);
		return sound;
	}

	static public function music(key:String, ?library:String):Dynamic
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	static public function voices(song:String, old:Bool, ?library:String):Sound
		return returnSound('songs', '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Voices' + (old ? '_old' : ''), library);

	static public function inst(song:String, old:Bool, ?library:String):Sound
		return returnSound('songs', '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Inst' + (old ? '_old' : ''), library);

	static public function image(key:String, ?library:String, ?compression:Bool = false)
		return returnGraphic(key, library, compression);

	static public function font(key:String):String
		return 'assets/fonts/$key';

	static public function getSparrowAtlas(key:String, ?compression:Bool = false, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key, library, compression), Assets.getText(file('images/$key.xml', library)));
}
