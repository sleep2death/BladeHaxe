package;

import openfl.display.Sprite;
import openfl.net.URLRequest;
import openfl.events.Event;
import openfl.geom.Vector3D;
import openfl.Vector;

import away3d.library.Asset3DLibrary;
import away3d.library.Asset3DLibraryBundle;
import away3d.loaders.parsers.ImageParser;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.events.Asset3DEvent;
import away3d.core.base.*;
import away3d.entities.*;
import away3d.materials.*;
import away3d.primitives.*;
import away3d.materials.methods.*;

import hommer.library.*;
import hommer.core.geometries.*;
import hommer.entities.*;
import hommer.materials.*;

class CharacterView extends ViewerBase {
    public function new()
    {
        super();
        loadCharacterMesh();
        //loadCharacterMaterial();
    }

    private var geo : PlayerGeometry;
    private var mat : PlayerBodyMaterial;

    public function loadCharacterMesh() : Void
    {
        geo = new PlayerGeometry();
        geo.getSubGeometryGroup(["arm_0", "body_0", "belt_0","boot_0", "hair_0", "hand_0", "head_0", "leg_0", "thigh_0"]);

        mat = new PlayerBodyMaterial();
        mat.setSubTextures(PlayerLibrary.getInstance().getAtlas(PlayerBodyMaterial.prefixURL(PlayerBodyMaterial.ATLAS)), Vector.fromArray(["male_avatar", "head_t1_toufa", "face_t1_toufa"]));
        //mat.addMethod(new RimLightMethod(0xFFFFFF, 2, 2));

        var mesh : PlayerBase = new PlayerBase(geo, mat);
        _view.scene.addChild(mesh);
    }

    private var mesh : Mesh;
    private function loadCharacterMaterial() : Void
    {
        var plane : PlaneGeometry = new PlaneGeometry(256, 256, 4, 4);
        var m : PlayerBodyMaterial = new PlayerBodyMaterial();

        mesh = new Mesh(plane, m);
        _view.scene.addChild(mesh);

        //m.getSubTextureGroup(["ATFTest"]);

        _view.camera.y = 400;
        _view.camera.z = 0;
        _view.camera.lookAt(new Vector3D());

    }

    private var _count : UInt = 0;
    private override function _onEnterFrame(e:Event):Void
    {
        _view.render();
        if(_count == 150) {
            //player.getSubGeometryGroup(["arm_0", "body_0", "belt_0","boot_0", "hair_0", "hand_0", "head_0", "leg_0", "skirt_1"]);
        }
        _count++;
    }

}
