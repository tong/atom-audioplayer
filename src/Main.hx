
import js.node.Fs;
import atom.Disposable;

using Lambda;
using haxe.io.Path;

@:keep
class Main {

    static inline function __init__() untyped module.exports = Main;

    static var allowedFileTypes = ['ogg','wav','mp3'];

    static var config = {
        autoplay: {
            "title": "Autoplay",
            "description": "Autoplay video when opened",
            "type": "boolean",
            "default": true
        },
        loop: {
            "title": "Loop Video",
            "type": "boolean",
            "default": false
        },
        volume: {
            "title": "Default Volume",
            "type": "number",
            "default": 0.7,
            "minimum": 0.0,
            "maximum": 1.0
        }
    }

    static var disposables : atom.CompositeDisposable;
    static var statusbar : Statusbar;

    static function activate( state ) {

        trace( 'Atom-audioplayer ' );

        statusbar = new Statusbar();

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.workspace.addOpener( openURI ) );
        disposables.add( Atom.views.addViewProvider( AudioPlayer, function(player:AudioPlayer) {
            return new AudioPlayerView( player ).element;
        }));
    }

    static function deactivate() {
        disposables.dispose();
        statusbar.destroy();
    }

    static function consumeStatusBar( pane ) {
        pane.addRightTile( { item: statusbar.element, priority:0 } );
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) )
            return new AudioPlayer( uri );
        return null;
    }
}
