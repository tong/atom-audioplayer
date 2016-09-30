
import js.Browser.document;
import js.html.AudioElement;
import js.html.audio.AudioContext;
import js.node.Fs;
import atom.CompositeDisposable;
import atom.Disposable;
import atom.File;

using Lambda;
using StringTools;
using haxe.io.Path;

@:keep
@:expose
class AudioPlayer {

    static inline function __init__() {

        untyped module.exports = AudioPlayer;

		disposables = new CompositeDisposable();
        disposables.add( Atom.views.addViewProvider( AudioPlayer, function(player:AudioPlayer) {
            return new AudioPlayerView( player ).element;
        }));
    }

    public static var context(default,null) : AudioContext;

    static var allowedFileTypes = ['aiff','flac','mp3','ogg','wav'];
    static var disposables : CompositeDisposable;
    //static var statusbar : Statusbar;

    static function activate( state : Dynamic ) {
        trace( 'Atom-audioplayer ' );
        context = new AudioContext();
		disposables.add( Atom.workspace.addOpener( openURI ) );
    }

    static function deactivate() {
        disposables.dispose();
        //statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            return new AudioPlayer( uri, Atom.config.get( 'audioplayer.autoplay' ) );
        }
        return null;
    }

    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }

	public var audio(default,null) : AudioElement;

	var file : atom.File;

	function new( path : String, play : Bool, time = 0.0 ) {

		this.file = new File( path );

		audio = document.createAudioElement();
        audio.autoplay = play; //Atom.config.get( 'audioplayer.autoplay' );
        audio.controls = true;
        audio.src = file.getPath();
        audio.currentTime = time;

        //if( play ) audio.play();
	}

	public function serialize() {
        return {
            deserializer: 'AudioPlayer',
            path: file.getPath(),
            play: !audio.paused,
            time: audio.currentTime
        }
    }

	public function dispose() {
		audio.pause();
        audio.remove();
        audio = null;
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
        //return "abc";// file.getPath().urlEncode();
        //return "file://" + encodeURI(file.getPath().replace(/\\/g, '/')).replace(/#/g, '%23').replace(/\?/g, '%3F')
        return "file://" + file.getPath().urlEncode();
    }

    public function isEqual( other ) {
        if( !Std.is( other, AudioPlayer ) )
            return false;
        return getURI() == cast( other, AudioPlayer ).getURI();
    }

	public static function deserialize( state : Dynamic ) {
        trace(state);
		return new AudioPlayer( state.path, state.play, state.time );
	}
}
