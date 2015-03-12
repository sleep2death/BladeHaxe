package hommer.textures;

import away3d.textures.*;
import away3d.core.managers.*;
import away3d.utils.ArrayUtils;

import openfl.Vector;
import openfl.display3D.*;
import openfl.display3D.textures.TextureBase;
import openfl.display3D._shaders.AGLSLShaderUtils;
import openfl.geom.Rectangle;

import hommer.library.assets.AtlasAsset;
import hommer.library.PlayerLibrary;

class PlayerRenderTexture extends RenderTexture {

    public function new(width:Int, height:Int) {
        super(width, height);
    }

    private var _vertexData:Vector<Float>;
    private var _indexData:Vector<UInt>;
    private var _atlas : AtlasAsset;
    private var _names : Vector<String>;

    public function assemble(atlas : AtlasAsset, names : Vector<String>, vertexData:Vector<Float>, indexData:Vector<UInt>) : Void {
        _atlas = atlas;
        _names = names;
        _vertexData = vertexData;
        _indexData  = indexData;
        //invalide this, so it will keep asking for redrawing per frame...
        invalidateContent();
    }

    override public function getTextureForStage3D(stage3DProxy:Stage3DProxy):TextureBase {
        var contextIndex:Int = stage3DProxy._stage3DIndex;
        var tex:TextureBase = _textures[contextIndex];
        var context:Context3D = stage3DProxy._context3D;

        if (tex == null || _dirty[contextIndex] != context) {
            //if atlas is ready for this...
            if(!_atlas.isEmpty){
                //TODO:  INDEX need to be passed in, or stored in the atlas
                var i : UInt = 0;
                for(n in _names){
                    var region = _atlas.getRegion(n);
                    fillUV(region, _vertexData, i);
                    i++;
                }
                //dispose the texture if already got one
                if(tex != null) tex.dispose();
                _textures[contextIndex] = tex = createTexture(context);
                _dirty[contextIndex] = context;

                uploadPlayerTexture(tex, stage3DProxy, context);
            }
        }

        return tex;
    }

    private function uploadPlayerTexture(tex:TextureBase, proxy:Stage3DProxy, context:Context3D) : Void {

        var len : UInt = cast(_vertexData.length/16, UInt);
        var vLen : UInt = len*4;
        var iLen : UInt = len*6;

        var vertexBuffer = proxy.createVertexBuffer(vLen, 4);
        vertexBuffer.uploadFromVector(_vertexData, 0, vLen);

        var indexBuffer = proxy.createIndexBuffer(iLen);
        indexBuffer.uploadFromVector(_indexData, 0, iLen);

        //context.setDepthTest(false, Context3DCompareMode.ALWAYS);
        //set the texture of the player material
		proxy.setRenderTarget(tex);
		proxy.context3D.clear(0, 0, 0, 0);

        context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);

		context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);


        context.setProgram(getProgram(proxy));
        context.setTextureAt(0, _atlas.atf.getTextureForStage3D(proxy));

		context.drawTriangles(indexBuffer);

        Stage3DProxy.disposeIndexBuffer(indexBuffer);
        Stage3DProxy.disposeVertexBuffer(vertexBuffer);
    }

    public static var SHADER_VERTEX:Vector<String> = Vector.fromArray([
        "mov op, va0\n",     //Set the output of our vertex-shader (first and foremost!)
        "mov v0, va1\n",        //Pass the uvs.
    ]);

    public static var SHADER_FRAGMENT:Vector<String> = Vector.fromArray([
        "tex ft0, v0, fs0 <2d,nearest,dxt5>\n mul ft0.xyz, ft0.xyz, ft0.w\n mov oc, ft0\n"   //Sample it!
    ]);

    private static var program : Program3D;
    private static function getProgram(proxy : Stage3DProxy) : Program3D {
        if(program == null) {
            var vertexByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, SHADER_VERTEX.join(""));
            var fragmentByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, SHADER_FRAGMENT.join(""));

            program = proxy.context3D.createProgram();
            program.upload(vertexByteCode, fragmentByteCode);
        }

        return program;
    }

    private static function fillUV(region : Vector<Float>, vertexData : Vector<Float>, index:UInt) : Void {
        var vIndex : UInt = index*16;
        if(region.length > 0 && region.length == 8){
            //set the 4 points uv of the rects
            vertexData[vIndex + 2] = region[0];
            vertexData[vIndex + 3] = region[1];

            vertexData[vIndex + 6] = region[2];
            vertexData[vIndex + 7] = region[3];

            vertexData[vIndex + 10] = region[4];
            vertexData[vIndex + 11] = region[5];

            vertexData[vIndex + 14] = region[6];
            vertexData[vIndex + 15] = region[7];
        }
    }
}
