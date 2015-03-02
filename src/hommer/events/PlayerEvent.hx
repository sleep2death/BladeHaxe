package hommer.events;

import openfl.events.Event;

class PlayerEvent extends Event {

    public static inline var GEO_ASSEMBLE_COMPLETE : String = "player_geo_assemble_complete";

    private var _message : String;
    public var message(get, null) : String;
    public function get_message() : String
    {
        return _message;
    }


    public function new(type:String, msg:String = null) {
        super(type);
        _message = msg;
    }
}
