import sys.io.FileInput;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

class ShaderLoader {
   public static macro  function buildShader():Array<Field>{
    var fields:Array<Field> = Context.getBuildFields();

    var posInfos = Context.getPosInfos(Context.currentPos());
    var directory = Path.directory(posInfos.file);
    
    // get the current class information. 
    var ref:ClassType = Context.getLocalClass().get();
    // path to the template. syntax: "MyClassName.template"
    var filePath:String = Path.join([directory, ref.name + ".shader"]);

    if (FileSystem.exists(filePath)) {
      // get the file content of the template 
      var fileInput:FileInput = File.read(filePath);

      var code:Map<String,String> = [];
      
      var currentType:String= "";
      while (!fileInput.eof()) {
        var line = fileInput.readLine();
        if (line.indexOf("#shader ") != -1) {
          currentType = line.substring(8);
        } else {
          if (code[currentType] == null) {
            code[currentType] = line + "\n";
          } else {
            code[currentType] += line + "\n";
          }
        }
      }

      for (key in code.keys()) {
        fields.push({
          name: key.toUpperCase(),
          access:  [Access.AStatic, Access.APublic],
          kind: FieldType.FVar(macro:String, macro $v{code[key]}), 
          pos: Context.currentPos(),
          doc: "auto-generated from " + filePath,
        });
      }

    } else {
      throw("File not found " + filePath);
    }

    return fields;

  }


  public static macro function loadShaderSource(path:String) {
    return try {
      var code:Dynamic = {};
      if (FileSystem.exists(path)) {
        // get the file content of the template 
        var fileInput:FileInput = File.read(path);
  
        
        
        var currentType:String= "";

        var reading = true;
        while (reading) {
          try {
            var line = fileInput.readLine();
            if (line.indexOf("#shader ") != -1) {
              currentType = line.substring(8).toLowerCase();
            } else {
              switch (currentType) {
                case "vertex":
                  if (code.VERTEX == null) {
                    code.VERTEX = line + "\n";
                  } else {
                    code.VERTEX += line + "\n";
                  }
                case "fragment":
                  if (code.FRAGMENT == null) {
                    code.FRAGMENT = line + "\n";
                  } else {
                    code.FRAGMENT += line + "\n";
                  }
              }
            }
          } catch (e:haxe.io.Eof) {
            reading = false;
          }
        }
  
      } else {
        throw("File not found " + path);
      }
      macro $v{code};
    } catch (e) {
        haxe.macro.Context.error('Failed to load shader: $e', haxe.macro.Context.currentPos());
    }

  }
  
}