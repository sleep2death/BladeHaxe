package hommer.core.geometries;

import away3d.core.base.*;
import away3d.events.*;

import openfl.Vector;
import openfl.events.Event;

import hommer.library.PlayerLibrary;
import hommer.library.assets.PlayerSubMeshAsset;
import hommer.events.PlayerEvent;

class PlayerGeometry extends Geometry {

    //Always use four joints per vertex.
    private var unitedGeometry:SkinnedSubGeometry = new SkinnedSubGeometry(4);

    public function new() {
        super();
        addSubGeometry(unitedGeometry);
    }


    private var _countSubGeo : UInt;
    private var _numSubGeo : UInt;
    private var _indicesOffset : UInt;

    private var preparingAssets : Vector<PlayerSubMeshAsset> = new Vector<PlayerSubMeshAsset>();

    public var isPreparing(get, null) : Bool;

    public function get_isPreparing() : Bool {
        return preparingAssets.length > 0;
    }

    public function init() : Void {
        _countSubGeo = 0;
        _indicesOffset = 0;

        _unitedVertices = new Vector<Float>();
        _unitedUvs = new Vector<Float>();
        _unitedIndices = new Vector<UInt>();
        _unitedBoneWeights = new Vector<Float>();
        _unitedBoneIndices = new Vector<UInt>();

        while(preparingAssets.length > 0){
            preparingAssets.pop().removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onSubMeshLoaded);
        }
    }

    public function getSubMeshGroup(subNames : Vector<String>) : Void {
        init();

        _numSubGeo = subNames.length;

        for(name in subNames) {
            var pma : PlayerSubMeshAsset = PlayerLibrary.getInstance().getSubMesh(name);
            //if sub mesh need to be loaded:
            if(pma.isEmpty) {
                pma.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onSubMeshLoaded);
                preparingAssets.push(pma);
            }else{
                //already got this:
                onSubMeshReady(pma);
            }
        }
    }

    private function onSubMeshLoaded(evt : LoaderEvent) : Void
    {
        evt.target.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onSubMeshLoaded);
        var pma : PlayerSubMeshAsset = cast(evt.target, PlayerSubMeshAsset);
        onSubMeshReady(pma);
    }
    //TODO: PARSE ERROR HANDLER NEEDED!

    private var _unitedVertices : Vector<Float>;
    private var _unitedUvs : Vector<Float>;
    private var _unitedIndices : Vector<UInt>;
    private var _unitedBoneWeights : Vector<Float>;
    private var _unitedBoneIndices : Vector<UInt>;

    private function onSubMeshReady(pma : PlayerSubMeshAsset) : Void
    {
        _unitedVertices = _unitedVertices.concat(pma.vertices);
        _unitedUvs = _unitedUvs.concat(pma.uvs);
        _unitedBoneWeights = _unitedBoneWeights.concat(pma.boneWeights);
        _unitedBoneIndices = _unitedBoneIndices.concat(pma.boneIndices);

        var len:UInt = pma.indices.length;
        for(i in 0...len){
            //Add Offset to the indicies of the sub mesh
            _unitedIndices.push(pma.indices[i] + _indicesOffset);
        }

        _indicesOffset += cast(pma.vertices.length/3, UInt);
        _countSubGeo++;

        if(_countSubGeo == _numSubGeo) {
            assemble();
        }
    }

    private function assemble() : Void {
        unitedGeometry.fromVectors(_unitedVertices, _unitedUvs, null, null);
        unitedGeometry.updateIndexData(_unitedIndices);

        unitedGeometry.updateJointWeightsData(_unitedBoneWeights);
        unitedGeometry.updateJointIndexData(_unitedBoneIndices);

        dispatchEvent(new PlayerEvent(PlayerEvent.GEO_ASSEMBLE_COMPLETE));
    }

}
