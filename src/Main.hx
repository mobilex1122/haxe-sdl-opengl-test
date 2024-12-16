
import haxe.io.UInt32Array;
import haxe.io.Int32Array;
import haxe.io.Float32Array;
import sdl.Event;
import sdl.Window;
import sdl.Sdl;
import sdl.GL;
class Main {

    static function compileShaders(vertexShader:String,fragmentShader:String) {
        var program = GL.createProgram();
        
        var vs = compileShader(GL.VERTEX_SHADER, vertexShader);
        var fs = compileShader(GL.FRAGMENT_SHADER, fragmentShader);
    
    
        GL.attachShader(program,vs);
        GL.attachShader(program,fs);
    
        GL.linkProgram(program);
        GL.deleteShader(vs);
        GL.deleteShader(fs);
    
        final log = GL.getProgramInfoLog(program);
    
        if (log.length > 0)
            throw log;
    
        return program;
    }
    
    static function compileShader(type:Int, code:String) {
        var id = GL.createShader(type);
        GL.shaderSource(id,code);
        GL.compileShader(id);
    
        final log = GL.getShaderInfoLog(id);
    
        if (log.length > 0)
            throw log;
    
        return id;
    }


    static function GLDebug(call:()->Void, ?pos:haxe.PosInfos) {
        while (GL.getError() != GL.NO_ERROR) {}

        call();

        var error = GL.getError();
        var errors = [];
        while (error != 0) {
            errors.push(error);
            error = GL.getError();
        }
        if (errors.length > 0) {
            throw(errors.toString());
        }
    }

    static final WINDOW_WIDTH:Int = 800;
    static final WINDOW_HEIGHT:Int = 800;
    static function main() {
        Sdl.init();
    
        
        var window:Window = new Window("Thing", WINDOW_WIDTH,WINDOW_HEIGHT);
        GL.init();
        

        var data = Float32Array.fromArray([
            -0.5,-0.5,
             0.5,-0.5,
             0.5, 0.5,
            -0.5,0.5,
        ]).getData();

        var indecies = UInt32Array.fromArray([
            0,1,2,
            2,3,0
        ]).getData();

        
        var myshader = ShaderLoader.loadShaderSource("src/shaders/MyShader.shader");

        trace(myshader.VERTEX);
        
        var program = compileShaders(myshader.VERTEX,myshader.FRAGMENT);

        GL.useProgram(program);

        var uniID = GL.getUniformLocation(program, 'u_Color');

        var ubuffer:Buffer = GL.createBuffer();
        GL.bindBuffer(GL.UNIFORM_BUFFER, ubuffer);
        var udata = Float32Array.fromArray([0.2,0.3,0.8,1]).getData();
        GL.bufferData(GL.UNIFORM_BUFFER,udata.byteLength, udata.bytes,GL.STATIC_DRAW);

        
        Assert.glDebug(() -> GL.uniform4fv(uniID,udata.bytes,0,1));
              
        final posAttrib = GL.getAttribLocation(program, 'position');


        var buffer:Buffer = GL.createBuffer();
        GL.bindBuffer(GL.ARRAY_BUFFER, buffer);

        GL.bufferData(GL.ARRAY_BUFFER,data.byteLength, data.bytes,GL.STATIC_DRAW);

        final vao = GL.createVertexArray();
        GL.bindVertexArray(vao);

        GL.enableVertexAttribArray(0);
        GL.vertexAttribPointer(0,2,GL.FLOAT,false,8,0);


        var indeciesB = GL.createBuffer();
        GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indeciesB);
        GL.bufferData(GL.ELEMENT_ARRAY_BUFFER,indecies.byteLength, indecies.bytes,GL.STATIC_DRAW);


        var isRunning = true;

        while (isRunning) {
            Sdl.processEvents((event) -> {
             
                if (event.state == WindowStateChange.Close) {
                    isRunning = false;
                }
                

                return true;
            });
            GL.clearColor(0,0,0,1);

            
            Assert.glDebug(() -> GL.drawElements(GL.TRIANGLES,6,GL.UNSIGNED_INT,0));


            window.present();
        }

        
        Sdl.quit();


    }
}