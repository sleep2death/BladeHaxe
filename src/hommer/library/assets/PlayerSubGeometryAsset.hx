package hommer.library.assets;

import away3d.library.assets.*;
import away3d.core.base.*;

import openfl.Vector;

class PlayerSubGeometryAsset extends NamedAssetBase implements IAsset {
    public var assetType(get_assetType, never):String;

    public var isEmpty(get, never):Bool;

    public var vertices : Vector<Float>;
    public var uvs : Vector<Float>;
    public var boneWeights : Vector<Float>;
    public var boneIndices : Vector<UInt>;
    public var indices : Vector<UInt>;

    public function new(name : String) {
        super(name);
    }

    public function get_assetType():String {
        return Asset3DType.GEOMETRY;
    }

    public function get_isEmpty():Bool {
        return vertices == null;
    }

    /**
	 * Cleans up any resources used by the current object.
	 */
    public function dispose():Void {
        vertices = null;
        uvs = null;
        boneWeights = null;
        boneIndices = null;
        indices = null;
    }

}
