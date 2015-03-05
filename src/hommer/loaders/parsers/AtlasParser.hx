package hommer.loaders.parsers;

import away3d.loaders.parsers.*;

import hommer.library.assets.AtlasAsset;

class AtlasParser extends ParserBase {
    private var _name : String;

    private var _asset : AtlasAsset;
    public var asset(get, null) : AtlasAsset;

    private function get_asset() : AtlasAsset {
        return _asset;
    }

    public function new(name : String) {
        _name = name;
        _asset = new AtlasAsset(_name);

        super(ParserDataFormat.PLAIN_TEXT);
    }

    private override function proceedParsing() : Bool {
        return ParserBase.MORE_TO_PARSE;
    }
}
