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

    public static function prefixURL(id : String) : String {
        return  ASSETS_URL + id + FileExtension.XML;
    }

    public function new() {
        super();

        //get the atlas from the player library
        //var url : String = PlayerBodyMaterial.prefixURL(PlayerBodyMaterial.ATLAS);
        //atlas = PlayerLibrary.getInstance().getAtlas(url);
        //set the render texture
        texture = new PlayerRenderTexture(BODY_TEXTURE_WIDTH, BODY_TEXTURE_HEIGHT);
    }

    public function setSubTextures(atlas : AtlasAsset, names : Vector<String>) : Void {
        var vb : Vector<Float> = getVertexData(getParts());
        var ib : Vector<UInt>  = getIndexData(getParts());

        cast(texture, PlayerRenderTexture).assemble(atlas, names, vb, ib);
    }

    private static inline var BODY_TEXTURE_WIDTH : UInt = 256;
    private static inline var BODY_TEXTURE_HEIGHT : UInt = 256;

    private static var _parts : Vector<Rectangle>;
    private static var numParts : UInt;

    private static function getParts() : Vector<Rectangle> {
        if(_parts == null) {
            //TODO: store the rects to atlas file?
            _parts = new Vector<Rectangle>();
            _parts.push(new Rectangle(   0,   0, 256, 256)); //prime rect always draw first
            _parts.push(new Rectangle(   0,   0,  64,  32)); //head
            _parts.push(new Rectangle(   0,  32,  64,  64)); //face
            _parts.push(new Rectangle(   0,  96,  64,  64)); //shoulder
            _parts.push(new Rectangle(   0, 160,  64,  64)); //arm
            _parts.push(new Rectangle(   0, 224,  64,  32)); //hand

            numParts = _parts.length;
        }

        return _parts;
    }

    private static var _vertexData : Vector<Float>;

    private static function getVertexData(parts : Vector<Rectangle>) : Vector<Float> {
        if(_vertexData == null) {
            _vertexData = new Vector<Float>(parts.length*4*4);    //x,y,u,v per point, 4 points per rect
            ArrayUtils.Prefill(_vertexData, _vertexData.length, 0);

            var vIndex : UInt = 0;
            for(rect in parts){
                if(rect != null){
                    var x : Float = (rect.x/BODY_TEXTURE_WIDTH) * 2 - 1;
                    var y : Float = 1 - (rect.y/BODY_TEXTURE_HEIGHT) * 2;
                    var w : Float = rect.width/BODY_TEXTURE_WIDTH;
                    var h : Float = rect.height/BODY_TEXTURE_HEIGHT;

                    //TOP LEFT
                    _vertexData[vIndex]      = x;
                    _vertexData[vIndex + 1]  = y;

                    //TOP RIGHT
                    _vertexData[vIndex + 4]  = x + w * 2;
                    _vertexData[vIndex + 5]  = y;

                    //BOTTOM RIGHT
                    _vertexData[vIndex + 8]  = x + w * 2;
                    _vertexData[vIndex + 9]  = y - h * 2;

                    //BOTTOM LEFT
                    _vertexData[vIndex +12]  = x;
                    _vertexData[vIndex +13]  = y - h * 2;

                    vIndex += 16;
                }
            }
        }

        return _vertexData.copy();
    }

    private static var _indexData : Vector<UInt>;

    public static function getIndexData(parts : Vector<Rectangle>) : Vector<UInt>
    {
        if(_indexData == null){
            _indexData = new Vector<UInt>(parts.length*6);
            ArrayUtils.Prefill(_indexData, _indexData.length, 0);

            var vOff : UInt = 0;
            var iIndex : UInt = 0;
            for(rect in parts){
                if(rect != null){
                    _indexData[iIndex    ] = 0 + vOff;
                    _indexData[iIndex + 1] = 1 + vOff;
                    _indexData[iIndex + 2] = 2 + vOff;
                    _indexData[iIndex + 3] = 0 + vOff;
                    _indexData[iIndex + 4] = 2 + vOff;
                    _indexData[iIndex + 5] = 3 + vOff;

                    vOff += 4;
                    iIndex += 6;
                }
            }
        }
        trace(_indexData);
        return _indexData.copy();
    }
}
