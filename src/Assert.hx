import sdl.GL;

class Assert {
    public static inline function glDebug(call:() -> Void) {
        #if (assert == "1")
        while (GL.getError() != GL.NO_ERROR) {}
        #end

        call();

        #if (assert == "1")
        var error = GL.getError();
        var errors = [];
        while (error != 0) {
            var outError = switch (error) {
                case GL.INVALID_ENUM: "INVALID_ENUM";
                case GL.INVALID_VALUE: "INVALID_VALUE";
                case GL.INVALID_OPERATION: "INVALID_OPERATION";
                case GL.INVALID_FRAMEBUFFER_OPERATION: "INVALID_FRAMEBUFFER_OPERATION";
                default: "UNKNOWN";
            };

            errors.push(outError + " (" + error + ")");
            error = GL.getError();
        }
        if (errors.length > 0) {
            throw(errors.join("\n"));

            
        }
        #end
    }
  }