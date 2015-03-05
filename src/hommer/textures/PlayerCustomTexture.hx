package hommer.textures;

import away3d.textures.*;
import away3d.core.managers.*;

import openfl.Vector;
import openfl.display3D.*;
import openfl.display3D.textures.TextureBase;
import openfl.display3D._shaders.AGLSLShaderUtils;

class PlayerCustomTexture extends RenderTexture {

    private var vertexData:Vector<Float> = Vector.ofArray([ -1, 1, 0.0, 0.0,  0.0, 0.0, 0, 0,
                                                            1, 1, 1.0, 0.0,   0.0, 0.0, 0, 0,
                                                            1, -1, 1.0, 1.0,  0.0, 0.0, 0, 0,
                                                            -1, -1, 0.0, 1.0, 0.0, 0.0, 0, 0
                                                            ]);
    private var index:Vector<UInt> = Vector.ofArray([0, 1, 2, 0, 2, 3]);



    public function new(_width:Int, _height:Int) {
        super(_width, _height);
    }

    private function initProgram3D() : Void {

    }

    private var _sub : ATFTexture;
    public function assemble(sub : ATFTexture) : Void {
        _sub = sub;
        invalidateContent();
    }

    private function reset() : Void {

    }

    override public function getTextureForStage3D(stage3DProxy:Stage3DProxy):TextureBase {
        var contextIndex:Int = stage3DProxy._stage3DIndex;
        var tex:TextureBase = _textures[contextIndex];
        var context:Context3D = stage3DProxy._context3D;

        if (tex == null || _dirty[contextIndex] != context) {
            _textures[contextIndex] = tex = createTexture(context);
            _dirty[contextIndex] = context;

            uploadPlayerTexture(tex, stage3DProxy, context);
        }
        return tex;
    }

    private function uploadPlayerTexture(tex:TextureBase, proxy:Stage3DProxy, context:Context3D) : Void{
        if(_sub == null) return;

        trace("UPLOAD!");

        var indexBuffer = context.createIndexBuffer(6);
        var vertexBuffer = context.createVertexBuffer(4, 8);

        context.setDepthTest(false, Context3DCompareMode.ALWAYS);
        //set the texture of the player material
		proxy.setRenderTarget(tex, false);
		proxy.context3D.clear(0xFF, 0x99, 0, 0);

        var x : Float = 64/256;
        var y : Float = 64/256;
        var w : Float = 128/256;
        var h : Float = 32/256;

        //draw the sub texture to the player's texture
        vertexData[0] = x * 2 - 1;
        vertexData[1] = 1 - y * 2;

        vertexData[4] = x;
        vertexData[5] = y;

        vertexData[8] = vertexData[0] + w * 2;
        vertexData[9] = vertexData[1];

        vertexData[12] = x + w;
        vertexData[13] = y;

        vertexData[16] = vertexData[0] + w * 2;
        vertexData[17] = vertexData[1] - h * 2;

        vertexData[20] = x + w;
        vertexData[21] = y + h;

        vertexData[24] = vertexData[0];
        vertexData[25] = vertexData[1] - h * 2;

        vertexData[28] = x;
        vertexData[29] = y + h;

        vertexBuffer.uploadFromVector(vertexData, 0, 4);
		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
		context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);

        indexBuffer.uploadFromVector(index, 0, 6);

        context.setProgram(PlayerCustomTexture.getProgram(proxy));
        context.setTextureAt(0, _sub.getTextureForStage3D(proxy));

		context.drawTriangles(indexBuffer);

        indexBuffer.dispose();
        vertexBuffer.dispose();
    }

    private static inline var VERTEX_CODE:String = "mov op,va0\n mov v0,va1\n;";
    private static inline var FRAGMENT_CODE:String = "tex oc, v0, fs0 <2d,nearest>";
    private static inline var FRAGMENT_SHADER_DXT1:String = "tex oc, v0, fs0 <2d,nearest,dxt1>";
    private static inline var FRAGMENT_SHADER_DXT5:String = "tex ft0, v0, fs0 <2d,nearest,dxt5>\n mul ft0.xyz,ft0.xyz,ft0.w\n mov oc,ft0\n";

    /*public static var SHADER_VERTEX:Vector<String> = Vector.fromArray([
        "mov v0, va1;",         //Pass the uvs.
        "mov vt0, vc[va2.y];",  //Store temporarly the Start X&Y and Width & Height
        "mov v1, vc[va2.x];",   //Pass the uvOffset value to a variant.
        "mov v1.z, vt0.x;",     //Pass the X of Start (origin)
        "mov v1.w, vt0.y;",     //Pass the Y of Start (origin)
        "mov v2.xy, vt0.zw;",   //Pass the Width & Height
        "rcp v2.z, vt0.z;",     //Pass the reciprocals of Width
        "rcp v2.w, vt0.w;",     //Pass the reciprocals of Height
        "m44 op, va0, vc0;"     //Set the output of our vertex-shader (first and foremost!)
    ]);*/

    public static var SHADER_VERTEX:Vector<String> = Vector.fromArray([
        "mov op, va0\n",     //Set the output of our vertex-shader (first and foremost!)

        "mov v0, va1\n",        //Pass the uvs.
        "mov v1, va2\n"         //Pass the uvs.
    ]);

    public static var SHADER_FRAGMENT:Vector<String> = Vector.fromArray([
        "tex oc, v1, fs0 <2d,nearest,dxt5>\n"   //Sample it!
    ]);

    /*public static var SHADER_FRAGMENT:Vector<String> = Vector.fromArray([
        //v0 = uvs
        //v1 = uvOffset.x + .y AND Tile's start.x + .y
        //v2 = width & height AND 1/width & 1/height
        "alias ft0, temp;",
        "alias v0.xy, uvOriginal;",
        "alias v1.xy, uvOffset;",
        "alias v1.zw, uvStart;",
        "alias v2.xy, dimensionsWH;",
        "alias v2.zw, reciprocalsWH;",

        "mul temp, uvOriginal, dimensionsWH;",  //convert the 0-1 range to 0-[width of tile] range
        "add temp.xy, temp.xy, uvOffset;",  //add the offset x&y
        "mul temp.xy, temp.xy, reciprocalsWH;", //multiply to larger number
        "frc temp.xy, temp.xy;",        //only keep the fraction of the large number
        "mul temp.xy, temp.xy, dimensionsWH;",  //multiply to smaller number
        "add temp.xy, temp.xy, uvStart;",   //Add the Start X & Y of the tile

        "tex oc, temp, fs0 <2d,nearest,dxt5>;"   //Sample it!
    ]);*/


    private static var program : Program3D;
    private static function getProgram(proxy : Stage3DProxy) : Program3D {
        if(PlayerCustomTexture.program == null) {
            var vertexByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, SHADER_VERTEX.join(""));
            var fragmentByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, SHADER_FRAGMENT.join(""));
            //var vertexByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, VERTEX_CODE);
            //var fragmentByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, FRAGMENT_CODE);

            program = proxy.context3D.createProgram();
            program.upload(vertexByteCode, fragmentByteCode);
        }

        return program;
    }


}
