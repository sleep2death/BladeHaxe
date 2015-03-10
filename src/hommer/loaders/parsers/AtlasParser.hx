package hommer.loaders.parsers;

import haxe.xml.Fast;

import away3d.loaders.parsers.*;
import away3d.textures.ATFTexture;
import away3d.loaders.misc.ResourceDependency;
import away3d.library.assets.IAsset;
import away3d.events.LoaderEvent;

import openfl.net.URLRequest;
import openfl.errors.Error;

import hommer.library.assets.AtlasAsset;


class AtlasParser extends ParserBase {
    private var _name : String;

    private var _asset : AtlasAsset;
    public var asset(get, null) : AtlasAsset;

    private var _doc:Xml;
    private var _fastDoc:Fast;
    private var _atf:ATFTexture;

    private function get_asset() : AtlasAsset {
        return _asset;
    }

    public function new(name : String) {
        _name = name;
        _asset = new AtlasAsset(_name);

        super(ParserDataFormat.PLAIN_TEXT);
    }

    private override function finalizeAsset(a:IAsset, name:String = null):Void {
        _asset.setAtlas(_fastDoc, _atf);
        _asset.dispatchEvent(new LoaderEvent(LoaderEvent.RESOURCE_COMPLETE));

        //don't finalize this asset, because it is already added to the bundle
        //super.finalizeAsset(_asset);
    }

    private static inline var LOADING_XML : String = "loading_xml";
    private static inline var LOADING_ATF : String = "loading_atf";
    private static inline var COMPLETE : String = "complete";

    private var _parsingState : String = LOADING_XML;

    private override function proceedParsing() : Bool {
        switch(_parsingState){
            case LOADING_XML:
                _doc = Xml.parse(getTextData());
                _fastDoc = new Fast(_doc.firstElement());
                _parsingState = LOADING_ATF;
            case LOADING_ATF:
                //NOTICE: Away3d do the ugly things here: it changes the url based on the parent url automatically...
                var atf_url : String = _fastDoc.att.imagePath;
                addDependency(atf_url, new URLRequest(atf_url));

                pauseAndRetrieveDependencies();
            case COMPLETE:
                //some XML parsing here?
                finalizeAsset(_asset);
                return ParserBase.PARSING_DONE;

        }
        return ParserBase.MORE_TO_PARSE;
    }

    override public function resolveDependency(resourceDependency:ResourceDependency):Void {
        //TODO: handle multiple atfs?
        _atf = cast(resourceDependency.assets[0], ATFTexture);
        _parsingState = COMPLETE;
    }

    override public function resolveDependencyFailure(resourceDependency:ResourceDependency):Void
    {
        throw "DEPENDENCY RESOLVE ERROR";
    }
}
