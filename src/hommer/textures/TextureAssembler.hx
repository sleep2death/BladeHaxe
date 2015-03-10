package hommer.textures;

import openfl.Vector;
import openfl.display3D.*;
import openfl.display3D.textures.TextureBase;
import openfl.display3D._shaders.AGLSLShaderUtils;

import away3d.textures.*;

import hommer.library.assets.AtlasAsset;

class TextureAssembler extends RenderTexture{
    /*
    target : render target to draw the regions on it
    atlas  : the atlas asset contains the regions and the big atlas map
    vertexData:
    indexData:
    context : passed from the material when rendering
    */
    public static function assemble(target : RenderTexture, atlas : AtlasAsset, vertexData:Vector<Float>, indexData:Vector<UInt>, context : Context3D) : Void {
        createProgram(context);

        context.setDepthTest(false, Context3DCompareMode.ALWAYS);
        context.setRenderToTexture(cast(target, TextureBase), false, 0, 0);//DepthAndStencil, AntiAlias, surfaceSelector
        context.clear(0xFF, 0x99, 0, 0);

        var len : UInt = cast(vertexData.length/16, UInt);
        var indexBuffer = context.createIndexBuffer(6*len);
        var vertexBuffer = context.createVertexBuffer(4*len, 4);

        vertexBuffer.uploadFromVector(vertexData, 0, len*4);
        indexBuffer.uploadFromVector(indexData, 0, len*6);

        context.setProgram(program);
        context.drawTriangles(indexBuffer);

        indexBuffer.dispose();
        vertexBuffer.dispose();
    }

    private static inline var VERTEX_CODE :   String = "mov op, va0\n mov v0, va1\n";
    private static inline var FRAGMENT_CODE : String = "tex ft0, v0, fs0 <2d, nearest, dxt5>\n mul ft0.xyz, ft0.xyz, ft0.w\n mov oc, ft0\n";

    private static var program : Program3D;

    private static function createProgram(context: Context3D) : Void {
        //TODO: Assume there is only one stage3D, maybe?
        if(program == null){
            program = context.createProgram();
            var vertexByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, VERTEX_CODE);
            var fragmentByteCode = AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, FRAGMENT_CODE);

            program.upload(vertexByteCode, fragmentByteCode);
        }
    }
}
