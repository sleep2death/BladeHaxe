package hommer.materials;

import hommer.library.PlayerLibrary;
import hommer.library.assets.AtlasAsset;
import hommer.events.PlayerEvent;
import hommer.utils.FileExtension;
import hommer.textures.*;

import openfl.Vector;
import openfl.events.Event;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.display.BlendMode;
import openfl.errors.Error;
import openfl.display3D.Context3D;

import away3d.materials.*;
import away3d.events.*;
import away3d.textures.*;
import away3d.utils.ArrayUtils;

class PlayerBodyMaterial extends TextureMaterial
{
    //TODO: For test only.
    public static inline var ATLAS : String = "atlas";
    private static inline var ASSETS_URL : String = "../../../assets/fashi/output/";

    private static function prefixURL(id : String) : String {
        return  ASSETS_URL + id + FileExtension.XML;
    }

    //The Atlas which is storing the AllInOne ATF and the description XML.
    private var atlas : AtlasAsset;

    private var needAssemble : Bool = false;

    public function new() {
        super();

        //get the atlas from the player library
        var url : String = PlayerBodyMaterial.prefixURL(PlayerBodyMaterial.ATLAS);
        atlas = PlayerLibrary.getInstance().getAtlas(url);
        //get the render texture
        texture = new PlayerRenderTexture(atlas, BODY_TEXTURE_WIDTH, BODY_TEXTURE_HEIGHT);
        //need to render the default texture, if equipments are not provided
        needAssemble = true;

    }

    public override function updateMaterial(context : Context3D) : Void {
        if(needAssemble && !atlas.isEmpty){
            assemble(context);
        }
        super.updateMaterial(context);
    }

    private function assemble(context : Context3D) : Void {
        trace("UPDATE PLAYER BODY MATERIAL.");

        texture.invalidateContent();
        needAssemble = false;
    }


    private static inline var BODY_TEXTURE_WIDTH : UInt = 256;
    private static inline var BODY_TEXTURE_HEIGHT : UInt = 256;

}
