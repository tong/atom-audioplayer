
import js.Browser.document;

using StringTools;

@:keep
class AudioPlayer {

    var file : atom.File;

    public function new( filePath : String ) {
        file = new atom.File( filePath );
    }

    public function getViewClass() {
        trace("getViewClass");
        return AudioPlayerView;
    }


    public function destroy() {
        var view = Atom.views.getView( this );
        view.remove();
    }

    public function getPath() {
        return file.getPath();
    }

    /*
    public function getIconName() {
        return 'git-branch';
    }
    */

    public function getTitle() {
        return file.getBaseName();
    }

    public function getURI() {
        //getURI: -> encodeURI(@getPath()).replace(/#/g, '%23').replace(/\?/g, '%3F')
        return getPath().urlEncode();
    }

    public function isEqual( other ) {
        if( !Std.is( other, AudioPlayer ) )
            return false;
        return getURI() == cast( other, AudioPlayer ).getURI();
    }

}
