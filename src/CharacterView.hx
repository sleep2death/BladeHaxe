package;

import openfl.display.Sprite;
import openfl.net.URLRequest;
import openfl.events.Event;

import away3d.library.Asset3DLibrary;
import away3d.library.Asset3DLibraryBundle;
import away3d.loaders.parsers.ImageParser;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.events.Asset3DEvent;
import away3d.core.base.*;
import away3d.entities.*;
import away3d.materials.*;

import hommer.library.*;
import hommer.core.geometries.*;

class CharacterView extends ViewerBase {
    public function new()
    {
        super();
        loadCharacterMesh();
    }

    private var player : PlayerGeometry;
    public function loadCharacterMesh() : Void
    {
        player = new PlayerGeometry();
        player.getSubMeshGroup(["arm_0", "body_0", "belt_0","boot_0", "hair_0", "hand_0", "head_0", "leg_0", "thigh_0"]);

        var mesh : Mesh = new Mesh(player, new ColorMaterial(0xFF9900));
        _view.scene.addChild(mesh);
        //var libPlayer : PlayerLibrary = PlayerLibrary.getInstance();
        //var pma : PlayerSubMeshAsset = libPlayer.getSubMesh("arm_0");
        //libPlayer.getMesh("arm_0");
        //libPlayer.getMesh("body_0");
        //libPlayer.getMesh("belt_0");
        //libPlayer.getMesh("boot_0");
        //libPlayer.getMesh("hair_0");
        //libPlayer.getMesh("hand_0");
        //libPlayer.getMesh("head_0");
        //libPlayer.getMesh("leg_0");
        //libPlayer.getMesh("thigh_0");
        //libBundle.addEventListener(Asset3DEvent.Asset_COMPLETE, onMeshComplete)
        //libBundle.load(new URLRequest(PLAYER_MESH_URL), );
    }

    private var _count : UInt = 0;
    private override function _onEnterFrame(e:Event):Void
    {
        _view.render();
        if(_count == 300) {
            player.getSubMeshGroup(["arm_0", "body_0", "belt_0","boot_0", "hair_0", "hand_0", "head_0", "leg_0", "skirt_1"]);
        }
        _count++;
    }

}
