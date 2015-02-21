package;

import openfl.display.Sprite;
import openfl.net.URLRequest;

import away3d.library.Asset3DLibrary;
import away3d.library.Asset3DLibraryBundle;
import away3d.loaders.parsers.ImageParser;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.events.Asset3DEvent;

class CharacterView extends Sprite {
    public function new()
    {
        super();
        trace("Hello World");

        var libBundle = Asset3DLibrary.getBundle("MyBundle");
        libBundle.load(new URLRequest("../../../assets/image.jpg"), null, null, new ImageParser());
        libBundle.addEventListener(Asset3DEvent.ASSET_COMPLETE, onComplete);
    }

    private function onComplete(evt : Asset3DEvent) : Void
    {
        trace("Loaded:" + evt.asset.name + " in " + evt.asset.assetNamespace + " -> " + evt.asset.assetType);
        var libBundle = Asset3DLibrary.getBundle("MyBundle");
    }

}
