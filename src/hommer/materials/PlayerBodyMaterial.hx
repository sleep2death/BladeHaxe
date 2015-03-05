package hommer.materials;

import hommer.library.PlayerLibrary;
import hommer.library.assets.AtlasAsset;
import hommer.events.PlayerEvent;
import hommer.utils.FileExtension;

import openfl.Vector;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import openfl.display.BlendMode;
import openfl.errors.Error;

import away3d.materials.*;
import away3d.events.*;
import away3d.textures.*;

class PlayerBodyMaterial extends TextureMaterial
{
    public static inline var BODY : String = "player_body";

    private static inline var PLAYER_TEXTURE_WIDTH : UInt = 256;
    private static inline var PLAYER_TEXTURE_HEIGHT : UInt = 256;

    //TODO: For test only.
    private static inline var ASSETS_URL : String = "../../../assets/";

    private static function prefixURL(id : String) : String {
        return  ASSETS_URL + id + FileExtension.XML;
    }

    //The Atlas which is storing the AllInOne ATF and the description XML.
    private var _atlas : AtlasAsset;

    public function new() {
        var url : String = PlayerBodyMaterial.prefixURL(PlayerBodyMaterial.BODY);
        _atlas = PlayerLibrary.getInstance().getAtlas(url);
        super();
    }


    private static inline var BODY_TEXTURE_WIDTH : UInt = 256;
    private static inline var BODY_TEXTURE_HEIGHT : UInt = 256;

    //The texture IDs which will be drawn to the player's textre.
    private var _textureSet : Vector<UInt>;
    public var textureSet(get, set) : Vector<UInt>;

    public function set_textureSet(IDs : Vector<UInt>) : Vector<UInt> {
        if(IDs.length != _textureSet.length) throw new Error("THE IDs Length Must Be 14!");
        _textureSet = IDs;

        return _textureSet;
    }

    public function get_textureSet() : Vector<UInt> {
        return _textureSet;
    }

    public function setTextureAt(index : UInt, id : UInt) : Void {
        _textureSet[index] = id;
    }

}
