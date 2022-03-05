![aura_banner.png](.img/aura_banner_bright.png)

*Aura* is a fast and lightweight 3D audio engine for [Kha](https://kha.tech/) to ease creating realistic sound atmospheres for your games and applications.

# Table of Content
- [Features](#features)
- [Setup](#setup)
- [Usage](#usage)
- [Platform Support](#platform-support)
- [License](#license)

# Features

- Multiple attenuation models for 3D sound
- Mix channels for modifying groups of sounds together
- Doppler effect
- Noise generator channels
- Built-in [DSP](https://en.wikipedia.org/wiki/Digital_signal_processing) filters:
  - High-/band-/lowpass filter
  - Haas effect
- Extendable DSP system – easily write your own filters
- *[Experimental]* Support for [HRTFs (head-related transfer functions)](https://en.wikipedia.org/wiki/Head-related_transfer_function)

# Setup

In your project directory, create a folder called `Subprojects`. Then, open a command line in that folder and execute the following command (Git must be installed on your machine):

```
git clone https://github.com/MoritzBrueckner/aura.git
```

Then, add the following line to your project's `khafile.js` (if you're using [Armory 3D](https://armory3d.org/), you can skip this step):

```js
await project.addProject("Subprojects/aura");
```

If you're using [Iron](https://github.com/armory3d/iron), but not Armory 3D, please also add the following to your Khafile to be able to use Iron's vector classes with Aura:

```js
project.addDefine("AURA_WITH_IRON");
```

# Usage

- Load sounds (and automatically uncompress them when needed):

  ```haxe
  import aura.Aura;

  ...

  Aura.init(); // <-- Don't forget this!

  var loadConfig: AuraLoadConfig = {
      uncompressed: [  // <-- List of sounds to uncompress
          "MySoundFile",
      ],
      compressed: [  // <-- List of sounds to remain compressed
          "AnotherSoundFile",
      ],
      hrtf: [  // <-- List of .mhr HRTF files for the HRTFPanner, if used
          "myHRTF_mhr",
      ],
      // Empty lists can be omitted!
  };

  Aura.loadSounds(loadConfig, () -> {
      // You can access the loaded sounds with `Aura.getSound()`
      var mySound: kha.Sound = Aura.getSound("MySoundFile");
  });
  ```

  > Alternative to referencing sounds by hard-coded names (like it's done in the above example), you can also rely on Kha's asset system and use the IDE's autocompletion for assistance:
  > ```haxe
  > kha.Assets.sounds.MySoundFileName; // Note the "Name" ending. This will give you the ID name for this sound
  > kha.Assets.blobs.myHRTF_mhrName; // The same works for blobs (and for other asset types as well)
  > ```
  > As a positive side effect you will get errors during compile time if an asset does not exist.

- Play a sound:

  ```haxe
  // Plays the sound `mySound` without repeat on the master channel
  Aura.play(mySound);

  // Plays the sound `mySound` with repeat on the master channel
  Aura.play(mySound, true);

  // Plays the sound `mySound` without repeat on the predefined fx channel
  Aura.play(mySound, false, Aura.mixChannels["fx"]);

  // You can also stream sounds directly from disk. Whether a sound can be
  // streamed highly depends on the target and whether the sound is compressed
  // or not. Please consult the Kha sources if in doubt.
  Aura.stream(mySound, false, Aura.mixChannels["music"]);
  ```

  `Aura.play()` and `Aura.stream()` both return a [`Handle`](https://github.com/MoritzBrueckner/aura/blob/master/Sources/aura/Handle.hx) object with which you can control the playback and relevant parameters.

- Create a `MixChannel` to control a group of sounds:

  ```haxe
  // Create a channel for all voices for example.
  // The channel can also be accessed with `Aura.mixChannels["voice"]`
  var voiceChannel = Aura.createMixChannel("voice");

  // Mix the output of `voiceChannel` into the master channel
  Aura.masterChannel.addInputChannel(voiceChannel);

  Aura.play(mySound, false, voiceChannel);
  ```

- Add a lowpass filter to the master channel:

  ```haxe
  import aura.dsp.Filter;

  ...

  Aura.play(mySound);

  var lowPass = new Filter(LowPass);
  lowPass.setCutoffFreq(1000); // Frequency in Hertz

  // Aura.masterChannel is short for Aura.mixChannels["master"]
  Aura.masterChannel.addInsert(lowPass);

  ```

- 2D sound:

  ```haxe
  var mySoundHandle = Aura.play(mySound);

  // Some utility constants
  mySoundHandle.setBalance(LEFT);
  mySoundHandle.setBalance(CENTER); // Default
  mySoundHandle.setBalance(RIGHT);

  // Set angle in degrees between -90 (left) and 90 (right)
  // You can also use Rad(value) for radians in [-pi/2, pi/2]
  mySoundHandle.setBalance(Deg(30));
  ```

- 3D sound:

  ```haxe
  import aura.dsp.panner.HRTFPanner;
  import aura.dsp.panner.StereoPanner;

  ...

  var cam = getCurrentCamera(); // <-- dummy function
  var mySoundHandle = Aura.play(mySound);

  // Create a panner for the sound handle (choose one)
  new StereoPanner(channel); // Simple left-right panner
  new HRTFPanner(channel, Aura.getHRTF("myHRTF_mhr"));  // More realistic panning using head-related transfer functions, but slower to calculate

  // Set the 3D location and view direction of the listener
  Aura.listener.set(cam.worldPosition, cam.look, cam.right);

  // Set the 3D location of the sound independent of the math API used
  mySoundHandle.panner.setLocation(new kha.math.FastVector3(-1.0, 1.0, 0.2));
  mySoundHandle.panner.setLocation(new iron.math.Vec3(-1.0, 1.0, 0.2));
  mySoundHandle.panner.setLocation(new aura.math.Vec3(-1.0, 1.0, 0.2));

  // Apply the changes to the sound to make them audible (!)
  mySoundHandle.panner.update3D();

  // Switch back to 2D sound. The sound's saved location will not be reset, but
  // you won't hear it at that location anymore. The panner however still exists
  // and can be re-enabled via update3D().
  mySoundHandle.panner.reset3D();
  ```

  Aura's own `Vec3` type can be implicitly converted from and to Kha or Iron vectors (3D and 4D)!

# Platform Support

Thanks to Haxe and Kha, Aura runs almost everywhere!

The following targets were tested so far:

| Target | Tested environments | Supported | Notes |
| --- | --- | :---: | --- |
| [Armorcore](https://github.com/armory3d/armorcore) (Krom) | Windows | ✔ | |
| HTML5 | | ✔ | - No dedicated audio thread for non-streaming playback<br>- If `kha.SystemImpl.mobileAudioPlaying` is true, streamed playback is not included in the Aura mix pipeline (no DSP etc.) |
| Hashlink/C | Windows | ✔ | |
| hxcpp | Windows | ✔ | |

# License

This work is licensed under multiple licences, which are specified at [`.reuse/dep5`](.reuse/dep5) (complying to the [REUSE recommendations](https://reuse.software/)). The license texts can be found in the [`LICENSES`](LICENSES) directory, or in case of submodules in their respective repositories.

**Short summary**:

- The entire source code in [`Sources/aura`](Sources/aura) is licensed under the Zlib license which is a very permissive license also used by Kha and Armory at the time of writing this. This is the important license for you if you include Aura code in your project.
- This readme file and other configuration files are licensed under CC0-1.0.
- All files in [`.img/`](.img) are licensed under CC-BY-4.0.
