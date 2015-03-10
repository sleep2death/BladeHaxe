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

    private var _atlas : AtlasAsset;
    public function new(atlas : AtlasAsset, width:Int, height:Int) {
        super(width, height);
        _atlas = atlas;
    }

    public function assemble() : Void {

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

    private function uploadPlayerTexture(tex:TextureBase, proxy:Stage3DProxy, context:Context3D) : Void {
        if(!_atlas.isEmpty) {
            //Fill the default vertex and index data, if they are not filled
            fillData();
            //Clean the UV of the vertex data for the next draw, always call fillData first
            clearUV();
            //Pass the vertex and index data to assembler
            fillUV(_atlas, Vector.fromArray(["female_avatar", "head_t1_toufa", "face_t1_toufa", "shoulder_t10_a_yifu"]));

            var vLen : UInt = numParts*4;
            var iLen : UInt = numParts*6;

            var vertexBuffer = context.createVertexBuffer(vLen, 4);
            vertexBuffer.uploadFromVector(vertexData, 0, vLen);

            var indexBuffer = context.createIndexBuffer(iLen);
            indexBuffer.uploadFromVector(indexData, 0, iLen);

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

            indexBuffer.dispose();
            vertexBuffer.dispose();
        }
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

    private static inline var BODY_TEXTURE_WIDTH : UInt = 256;
    private static inline var BODY_TEXTURE_HEIGHT : UInt = 256;

    private static var vertexData : Vector<Float>;
    private static var indexData : Vector<UInt>;

    private static var numParts : UInt = 0;
    private static var parts : Vector<Rectangle>;

    private static function fillData() : Void {
        if(vertexData == null) {
            parts = new Vector<Rectangle>();
            parts.push(new Rectangle(   0,   0, 256, 256)); //prime rect always draw first
            parts.push(new Rectangle(   0,   0,  64,  32)); //head
            parts.push(new Rectangle(   0,  32,  64,  64)); //face
            parts.push(new Rectangle(   0,  96,  64,  64)); //shoulder
            parts.push(new Rectangle(   0, 160,  64,  64)); //arm
            parts.push(new Rectangle(   0, 224,  64,  32)); //hand

            numParts = parts.length;

            vertexData = new Vector<Float>(parts.length*4*4);    //x,y,u,v per point, 4 points per rect
            indexData = new Vector<UInt>(parts.length*6);
            ArrayUtils.Prefill(vertexData, vertexData.length, 0);
            ArrayUtils.Prefill(indexData, indexData.length, 0);

            var vIndex : UInt = 0;
            var iIndex : UInt = 0;
            for(rect in parts){
                if(rect != null){
                    var x : Float = (rect.x/BODY_TEXTURE_WIDTH) * 2 - 1;
                    var y : Float = 1 - (rect.y/BODY_TEXTURE_HEIGHT) * 2;
                    var w : Float = rect.width/BODY_TEXTURE_WIDTH;
                    var h : Float = rect.height/BODY_TEXTURE_HEIGHT;

                    //TOP LEFT
                    vertexData[vIndex]      = x;
                    vertexData[vIndex + 1]  = y;

                    //TOP RIGHT
                    vertexData[vIndex + 4]  = x + w * 2;
                    vertexData[vIndex + 5]  = y;

                    //BOTTOM RIGHT
                    vertexData[vIndex + 8]  = x + w * 2;
                    vertexData[vIndex + 9]  = y - h * 2;

                    //BOTTOM LEFT
                    vertexData[vIndex +12]  = x;
                    vertexData[vIndex +13]  = y - h * 2;


                    var vOff : UInt = cast(vIndex/4, UInt);
                    indexData[iIndex    ] = cast(0 + vOff, UInt);
                    indexData[iIndex + 1] = cast(1 + vOff, UInt);
                    indexData[iIndex + 2] = cast(2 + vOff, UInt);
                    indexData[iIndex + 3] = cast(0 + vOff, UInt);
                    indexData[iIndex + 4] = cast(2 + vOff, UInt);
                    indexData[iIndex + 5] = cast(3 + vOff, UInt);

                    vIndex += 16;
                    iIndex += 6;
                }
            }
        }
    }


    private static function fillUV(atlas : AtlasAsset, names:Vector<String>) : Void {
        var vIndex : UInt = 0;
        for(name in names){
            var region = atlas.getRegion(name);
            vertexData[vIndex + 2] = region[0];
            vertexData[vIndex + 3] = region[1];
            vertexData[vIndex + 6] = region[2];
            vertexData[vIndex + 7] = region[3];
            vertexData[vIndex + 10] = region[4];
            vertexData[vIndex + 11] = region[5];
            vertexData[vIndex + 14] = region[6];
            vertexData[vIndex + 15] = region[7];

            vIndex += 16;
        }
    }

    private static function clearUV() : Void {
        for(i in 0...numParts){
            var vIndex : UInt = i * 16;
            vertexData[vIndex + 2] = vertexData[vIndex + 3] = vertexData[vIndex + 6] = vertexData[vIndex + 7] = vertexData[vIndex + 10] = vertexData[vIndex + 11] = vertexData[vIndex + 14] = vertexData[vIndex + 15] = 0;
        }
    }


}
