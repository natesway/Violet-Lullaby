Fork of Hypno's Lullaby for violet-funk (package atom funkin-mods/lullaby::violet-funk)

# Pre-requisites

If you want to build the mod for yourself:

- Merge `dev-lang/neko` or, if you're not using Gentoo, install `neko` via your distro's package manager. (Not all distros package neko.) If neko is not available for your distro (i.e. Void Linux), install both `cmake` and `make`, then grab the tarball for Neko 2.3.0's source code. Compile and install it to your system.
- If you **are not using Gentoo,** try installing `haxe` through your distro's package manager. If `haxelib` does not show as the Haxe Library Manager, try checking `/usr/local/bin/haxelib`. If that offers no dice, fetch the tarball for Haxe 4.2.5's source code instead. (Gentoo's `dev-lang/haxe` will not suffice! We need the ACTUAL Haxe library manager.) Install `ocaml` and then attempt to compile Haxe. Any missing libraries should easily be disclosed to the user during build time. Once Haxe has been compiled, install it to the system.
- Set the Haxe library directory using `haxelib setup /usr/share/haxe/lib` (as both the regular user ***and*** sudo/root). Then, install the following libraries (you must use the version number given if it's next to the library):
  - newgrounds [1.1.5]
  - flixel [4.11.0]
  - lime [8.0.0]
    - Run `haxelib run lime setup` and accept lime's offer of creating a binary in `/usr/bin`. This gives you a neat shorthand to use.
  - flixel-ui
  - flixel-addons [git; use https://github.com/HaxeFlixel/flixel-addons]
  - flixel-tools
    - Run `haxelib run flixel-tools setup`.
  - openfl [9.1.0] (ignore lime's eventual warning when compiling)
  - flxanimate [1.2.0]
  - hxCodec [2.5.1]
  - actuate
  - faxe
  - hscript [2.5.0]
  - discord_rpc [git; use https://github.com/Aidan63/linc_discord-rpc]
  - polymod [git; use https://github.com/larsiusprime/polymod]
  - tentools [git; use https://github.com/TentaRJ/tentools]
  - systools [git; use https://github.com/waneck/systools]
    - Run `lime rebuild systools linux`.
    
# Compilation

If you are using Gentoo, merge `net-libs/libidn11::violet-funk` AND `media-video/vlc`. Then, run these commands in order:

- `sudo rm /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.9`
- `sudo rm /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.9.0.0`
- `sudo cp /usr/lib64/libvlccore.so.9.0.0 /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/`
- `sudo ln -s /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.9.0.0 /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.9`
- `sudo ln -s /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.9.0.0 /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/libvlccore.so.7`
- `sudo cp /usr/lib64/libidn.so.11 /usr/share/haxe/lib/hxCodec/2,5,1/lib/vlc/lib/Linux/`

Once you've done all this, clone `https://github.com/MagelessMayhem/Violet-Lullaby`, cd into `Violet-Lullaby/` and run `lime build linux -v`. If all goes well, you will have a built game in `~/Violet-Lullaby/export/release/linux/bin`.

**Known issues (list is subject to growth):**

- The shop menu's shaders do not show correctly. They appear as 3 abnormally colored quadrilaterals, covering 3 of the 4 quadrants of the rendering window (NOT the full application window). This effect disappears when exiting freeplay.
- During Lost Cause, after Hypno appears and GF stands up, GF's animations cancel out and she ends up becoming an FlxSprite statue.
