package hommer.entities;

import away3d.entities.*;
import away3d.core.base.*;
import away3d.materials.*;

class PlayerBase extends Mesh {
    public function new(geometry : Geometry, material : MaterialBase = null) : Void
    {
        super(geometry, material);
    }
}
