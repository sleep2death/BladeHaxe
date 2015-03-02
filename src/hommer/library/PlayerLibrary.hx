package hommer.library;

import away3d.library.*;
import away3d.library.assets.*;
import away3d.loaders.misc.*;
import away3d.events.*;

import openfl.net.URLRequest;
import openfl.Vector;

import hommer.loaders.parsers.*;
import hommer.library.assets.*;
import hommer.utils.FileExtension;

class PlayerLibrary {

    private var meshBundle : Asset3DLibraryBundle;
    private var animBundle : Asset3DLibraryBundle;

    private function new() {
        meshBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_MESH);
        animBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_ANIM);
    }

    public function getSubMesh(id : String, autoLoad:Bool = true) : PlayerSubMeshAsset {
        var pma : PlayerSubMeshAsset = cast(meshBundle.getAsset(id), PlayerSubMeshAsset);

        if(pma == null && autoLoad) {
            var parser : PlayerSubMeshParser = new PlayerSubMeshParser(id);
            var token : AssetLoaderToken = meshBundle.load(new URLRequest(prefixMeshURL(id)), null, parser);
            pma = parser.asset;
            //TODO: add load & parse error handlers here!
        }

        return pma;
    }

    //TODO: For test only.
    private static inline var PLAYER_MESH_URL : String = "../../../assets/fashi/";

    private static function prefixMeshURL(id : String) : String {
        return  PLAYER_MESH_URL + id + FileExtension.MESH;
    }

    private static var _lib : PlayerLibrary;

    public static function getInstance() : PlayerLibrary {
        if(_lib == null){
            _lib = new PlayerLibrary();
        }

        return _lib;
    }
}
