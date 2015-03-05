package hommer.library.assets;

import away3d.library.assets.*;
import away3d.core.base.*;
import away3d.textures.ATFTexture;

import openfl.Vector;

class AtlasAsset extends NamedAssetBase implements IAsset {

    public var isEmpty(get, null) : Bool;

    private function get_isEmpty() : Bool
    {
        return true;
    }


    public function new(name : String) {
        super(name);
    }

    public var assetType(get_assetType, never):String;
    public function get_assetType():String {
        return Asset3DType.TEXTURE;
    }

    /**
     * Cleans up any resources used by the current object.
     */
    public function dispose():Void {
    }

}
