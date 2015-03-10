package hommer.library.assets;

import haxe.xml.Fast;
import haxe.ds.StringMap;

import away3d.library.assets.*;
import away3d.core.base.*;
import away3d.textures.ATFTexture;

import openfl.Vector;

class AtlasAsset extends NamedAssetBase implements IAsset {

    public var isEmpty(get, null) : Bool;

    private function get_isEmpty() : Bool
    {
        return _doc == null;
    }

    private var _doc : Fast;

    private var _atf : ATFTexture;

    public var atf(get, null) : ATFTexture;
    private function get_atf() : ATFTexture {
        return _atf;
    }

    private var _map : StringMap<Vector<Float>> = new StringMap<Vector<Float>>();
    public function getRegion(name : String) : Vector<Float> {
        return _map.get(name);
    }

    public function setAtlas(doc:Fast, atf : ATFTexture) : Void {
        _doc = doc;
        _atf = atf;

        var st = _doc.nodes.SubTexture;
        for(reg in st) {
            var name = reg.att.name;
            var x = Std.parseInt(reg.att.x)/_atf.width;
            var y = Std.parseInt(reg.att.y)/_atf.height;
            var w = Std.parseInt(reg.att.width)/_atf.width;
            var h = Std.parseInt(reg.att.height)/_atf.height;
            var uv = new Vector<Float>();
            uv.push(x);
            uv.push(y);
            uv.push(x + w);
            uv.push(y);
            uv.push(x + w);
            uv.push(y + h);
            uv.push(x);
            uv.push(y + h);

            _map.set(name, uv);
        }
    }


    public function new(name : String) {
        super(name);
    }

    public var assetType(get_assetType, never):String;
    public function get_assetType():String {
        return Asset3DType.TEXTURE;
    }

    /**
     * TODO: Cleans up any resources used by the current object.
     */
    public function dispose():Void {
    }

}
