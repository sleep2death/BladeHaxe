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
    private var animBundle : Asset3DLibraryBundle;

    private function new() {
        geometryBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_GEOMETRY);
        animBundle = Asset3DLibrary.getBundle(LibNames.PLAYER_ANIM);
    }

    //get submesh from bundle or net
    public function getSubGeometry(url : String, autoLoad:Bool = true) : PlayerSubGeometryAsset {
        var pma : PlayerSubGeometryAsset = cast(geometryBundle.getAsset(url), PlayerSubGeometryAsset);

        if(pma == null && autoLoad) {
            var parser : PlayerSubGeometryParser = new PlayerSubGeometryParser(url);
            var token : AssetLoaderToken = geometryBundle.load(new URLRequest(url), null, parser);
            pma = parser.asset;
            //TODO: add load & parse error handlers here!
        }

        return pma;
    }

    //get material from pool or net


    private static var _lib : PlayerLibrary;

    public static function getInstance() : PlayerLibrary {
        if(_lib == null){
            _lib = new PlayerLibrary();
        }

        return _lib;
    }
}
