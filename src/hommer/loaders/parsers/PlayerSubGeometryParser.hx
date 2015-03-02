package hommer.loaders.parsers;

import away3d.loaders.parsers.*;
import away3d.core.base.*;
import away3d.events.*;
import away3d.library.assets.*;

import openfl.utils.ByteArray;
import openfl.utils.Endian;
import openfl.Vector;

import hommer.library.assets.*;

class PlayerSubGeometryParser extends ParserBase {
    private static inline var BLM_VERTEX:Int = 0x0800;
    private static inline var BLM_INDEX:Int = 0x0900;

    private var _byteData : ByteArray;
    private var _startedParsing:Bool;
    private var _tmpChunk : ChunkBlm = new ChunkBlm();

    private var _vertices : Vector<Float>;
    private var _uvs : Vector<Float>;
    private var _boneWeights : Vector<Float>;
    private var _boneIndices : Vector<UInt>;
    private var _indices : Vector<UInt>;

    private var _name : String;

    public var asset(get, null) : PlayerSubGeometryAsset;
    private var _asset : PlayerSubGeometryAsset;

    public function get_asset() : PlayerSubGeometryAsset
    {
        return _asset;
    }

    public function new(name : String) {
        if(name != null) {
            _name = name;
        }

        _asset = new PlayerSubGeometryAsset(_name);

        super(ParserDataFormat.BINARY);
    }

    private override function finalizeAsset(a:IAsset, name:String = null):Void {
        _asset.vertices = _vertices;
        _asset.uvs = _uvs;
        _asset.boneWeights = _boneWeights;
        _asset.boneIndices = _boneIndices;
        _asset.indices = _indices;
        _byteData.clear();

        //dispatch complete event so that the playerbase should know;
        _asset.dispatchEvent(new LoaderEvent(LoaderEvent.RESOURCE_COMPLETE));

        super.finalizeAsset(_asset);
    }

    private override function proceedParsing() : Bool {
		if(!_startedParsing)
		{
			_byteData = getByteData();
			_byteData.position = 0;
			_byteData.endian = Endian.LITTLE_ENDIAN;

			var version:UInt = _byteData.readUnsignedInt();
			var vertexNum:UInt = _byteData.readUnsignedInt();
			var faceCount:UInt = _byteData.readUnsignedInt();
			var indexCount:UInt = _byteData.readUnsignedInt();


			_vertices = new Vector<Float>(vertexNum*3, true);
			_uvs = new Vector<Float>(vertexNum*2, true);
			_boneIndices = new Vector<UInt>(vertexNum * 4, true);
			_boneWeights = new Vector<Float>(vertexNum * 4, true);

			_indices = new Vector<UInt>(indexCount, true);

			_startedParsing = true;
		}

		while (hasTime())
		{
			readChunk(_byteData);

			var chunkId : UInt = _tmpChunk.id;
			var count : UInt = _tmpChunk.count;

			switch(chunkId)
			{
				case BLM_VERTEX:
					readChunk_BLM_VERTEX(count);
				case BLM_INDEX:
					readChunk_BLM_INDEX(count);
			}


			if (_byteData.position == _byteData.length) {
                finalizeAsset(null, _name);
    			return ParserBase.PARSING_DONE;
            }

		}
		return ParserBase.MORE_TO_PARSE;
	}

    private function readChunk(ba:ByteArray) : ChunkBlm
    {
        _tmpChunk.id = ba.readUnsignedShort();
        _tmpChunk.count = ba.readUnsignedInt();
        return _tmpChunk;
    }

    private function readChunk_BLM_VERTEX(count:UInt) : Void {
        for(vertexIndex in 0...count)
        {
            _vertices[vertexIndex*3] = _byteData.readFloat();
            _vertices[vertexIndex*3+1] = _byteData.readFloat();
            _vertices[vertexIndex*3+2] = _byteData.readFloat();

            _uvs[vertexIndex*2] = _byteData.readFloat();
            _uvs[vertexIndex*2+1] = _byteData.readFloat();

            var i:UInt;
            var boneCount:UInt = _byteData.readUnsignedByte();

            for(i in 0...boneCount)
            {
                var boneIndex:Int = _byteData.readShort();
                _boneIndices[vertexIndex*4+i] = boneIndex*3;
                var boneWeight:Float = _byteData.readFloat();
                _boneWeights[vertexIndex*4+i] = boneWeight;
            }

        }
    }

    private function readChunk_BLM_INDEX(count:UInt) : Void {
        for(indexI in 0...count)
        {
            _indices[indexI*3] = _byteData.readUnsignedInt();
            _indices[indexI*3+1] = _byteData.readUnsignedInt();
            _indices[indexI*3+2] = _byteData.readUnsignedInt();
        }
    }

    public static function supportsData(data:Dynamic) : Bool {
        //always parse the data;
        return true;
    }

    public static function supportsType(ext : String) : Bool {
        trace("ext is:" + ext);
        //always parse the data;
        return ext=="blm";
    }
}

class ChunkBlm
{
	public var id:UInt;
	public var count:UInt;

    public function new () : Void
    {

    }
}
