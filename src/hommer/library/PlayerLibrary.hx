package hommer.library;

import away3d.library.*;
import away3d.library.assets.*;
import away3d.loaders.misc.*;
import away3d.events.*;

import openfl.net.URLRequest;
import openfl.Vector;

import hommer.loaders.parsers.*;
import hommer.library.assets.*;


class PlayerLibrary {

    private var geometryBundle : Asset3DLibraryBundle;
    private var materialBundle : Asset3DLibraryBundle;

    private function new() {
        geometryBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_GEOMETRY);
        materialBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_MATERIAL);
    }

    //get submesh from bundle or net
    public function getSubGeometry(url : String, autoLoad:Bool = true) : SubGeometryAsset {
        var pma : SubGeometryAsset = cast(geometryBundle.getAsset(url), SubGeometryAsset);

        if(pma == null && autoLoad) {
            var parser : PlayerSubGeometryParser = new PlayerSubGeometryParser(url);
            var token : AssetLoaderToken = geometryBundle.load(new URLRequest(url), null, parser);
            pma = parser.asset;
            //TODO: add load & parse error handlers here!
        }

        return pma;
    }

    //get material from pool or net
    //TODO: When loaded from one united atf, it should be a new bundle class to handle that.
    public function getAtlas(url : String, autoLoad:Bool = true) : AtlasAsset
    {
        var aa : AtlasAsset = cast(materialBundle.getAsset(url), AtlasAsset);

        if(aa == null && autoLoad) {
            var parser : AtlasParser= new AtlasParser(url);
            var token : AssetLoaderToken = materialBundle.load(new URLRequest(url), null, parser);
            aa = parser.asset;
            //TODO: add load & parse error handlers here!
        }

        return aa;
    }


    private static var _lib : PlayerLibrary;

    public static function getInstance() : PlayerLibrary {
        if(_lib == null){
            _lib = new PlayerLibrary();
        }

        return _lib;
    }
}
