
import js.Browser.document;
import js.Browser.window;
import js.html.AudioElement;
import js.html.Element;
import js.html.DivElement;
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
    }

    public static var context(default,null) : AudioContext;

    static var allowedFileTypes = ['flac','mp3','ogg','opus','wav','weba'];
    static var disposables : CompositeDisposable;
    //static var statusbar : Statusbar;

    static function activate( state : Dynamic ) {

        trace( 'Atom-audioplayer ' );

        context = new AudioContext();

		disposables = new CompositeDisposable();
		disposables.add( Atom.workspace.addOpener( openURI ) );
    }

    static function deactivate() {
        disposables.dispose();
        //statusbar.dispose();
    }

    static function openURI( uri : String ) {
        var ext = uri.extension().toLowerCase();
        if( allowedFileTypes.has( ext ) ) {
            //return new AudioPlayer( uri, Atom.config.get( 'audioplayer.autoplay' ) );
            return new AudioPlayer( { path : uri, play: Atom.config.get( 'audioplayer.autoplay' ), time: null } );
        }
        return null;
    }

    static function consumeStatusBar( pane ) {
        //pane.addRightTile( { item: new Statusbar().element, priority:0 } );
    }

	public static function deserialize( state : Dynamic ) {
		trace(state);
		//return new AudioPlayer( state.path, state.play, state.time );
		return new AudioPlayer( state );
	}

	////////////////////////////////////////////////////////////////////////////


	var file : atom.File;
	var element : Element;
	var audio : AudioElement;
	var waveform : Waveform;
    var marker : DivElement;
    var isPlaying : Bool;
	var seekSpeed : Float;
	var wheelSpeed : Float;
    var animationFrameId : Int;
    var commands : CompositeDisposable;

	function new( state ) {

		this.file = new File( state.path );

        isPlaying = false;
        seekSpeed = 1;
		wheelSpeed = 1; //config.get( 'audioplayer.wheel_speed' );

		var workspaceStyle = window.getComputedStyle( Atom.views.getView( Atom.workspace ) );

		element = document.createDivElement();
        element.classList.add( 'audioplayer' );
        element.setAttribute( 'tabindex', '-1' );

		waveform = new Waveform( workspaceStyle.color, workspaceStyle.backgroundColor );
        element.appendChild( waveform.canvas );

		marker = document.createDivElement();
        marker.classList.add( 'marker' );
        element.appendChild( marker );

		audio = document.createAudioElement();
        //audio.autoplay = state.play; //Atom.config.get( 'audioplayer.autoplay' );
        audio.controls = true;
        audio.src = file.getPath();
        audio.currentTime = state.time;
		element.appendChild( audio );

        audio.addEventListener( 'playing', handleAudioPlaying, false );
        audio.addEventListener( 'ended', handleAudioEnded, false );
        audio.addEventListener( 'error', handleAudioError, false );
        audio.addEventListener( 'canplaythrough', function(e) {

            waveform.color = workspaceStyle.color;
            waveform.backgroundColor = workspaceStyle.backgroundColor;
            waveform.generate( file.getPath(), function(){
                updateMarker();
            });

            //element.addEventListener( 'click', handleMouseDown, false );
            //element.addEventListener( 'mousewheel', handleMouseWheel, false );
            //element.addEventListener( 'focus', function(e) trace(e) , false );
            //element.addEventListener( 'blur', function(e) handleClickVideo(e) , false );

        }, false );

        commands = new CompositeDisposable();
        commands.add( Atom.commands.add( element, 'audioplayer:toggle-playback', function(e) togglePlayback() ) );
        commands.add( Atom.commands.add( element, 'audioplayer:toggle-mute', function(e) toggleMute() ) );
        commands.add( Atom.commands.add( element, 'audioplayer:seek-backward', function(e) seek( -(audio.duration / 10 * seekSpeed) ) ) );
        commands.add( Atom.commands.add( element, 'audioplayer:seek-forward', function(e) seek( (audio.duration / 10 * seekSpeed) ) ) );
        //commands.add( Atom.commands.add( element, 'audioplayer:goto-start', function(e) video.currentTime = 0 ) );
        //commands.add( Atom.commands.add( element, 'audioplayer:goto-end', function(e) video.currentTime = video.duration ) );

        element.addEventListener( 'click', handleMouseDown, false );
        element.addEventListener( 'mousewheel', handleMouseWheel, false );

        if( state.play != null ) play();
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
        commands.dispose();
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

	function update( time : Float ) {

        animationFrameId = window.requestAnimationFrame( update );
        updateMarker();

        /*
        ctx.fillStyle = '#fff';
    	for( i in 0...frequencyData.length ) {
			ctx.fillRect( i, 0, 1, frequencyData[i] / 256 * h );
		}
        */
    }

    function play() {
        if( !isPlaying ) {
            isPlaying = true;
            audio.play();
        }
    }

    function pause() {
        if( isPlaying ) {
            isPlaying = false;
            audio.pause();
        }
    }


    function seek( time : Float ) : Float {
        if( audio.currentTime != null ) audio.currentTime += time;
        return audio.currentTime;
    }

    function setAudioPositionFromPanePosition( x : Int ) {
        audio.currentTime = audio.duration * (x / element.offsetWidth);
    }

    function updateMarker() {
        var percentPlayed = audio.currentTime / audio.duration;
        marker.style.left = (percentPlayed * element.offsetWidth )+'px';
    }

    /*
	function handleCanPlayThrough(e) {
    }
    */

    inline function togglePlayback() {
        isPlaying ? pause() : play();
    }

    inline function toggleMute() {
        audio.muted = !audio.muted;
    }

	function handleAudioPlaying(e) {
        //trace(e);
        animationFrameId = window.requestAnimationFrame( update );
    }

    function handleAudioEnded(e) {
    }

    function handleAudioError(e) {
    }

    function handleMouseDown(e) {
        setAudioPositionFromPanePosition( e.layerX  );
        //element.addEventListener( 'mouseup', handleMouseUp, false );
        //element.addEventListener( 'mousemove', handleMouseMove, false );
        //element.addEventListener( 'mouseout', handleMouseOut, false );
    }

    function handleMouseUp(e) {
        //stopMouseSeek();
    }

    function handleMouseOut(e) {
        //stopMouseSeek();
    }

    function handleMouseWheel(e) {
        var v = e.wheelDelta / 100 * wheelSpeed;
        if( e.ctrlKey ) {
            v *= 10;
            if( e.shiftKey ) v *= 10;
        }
        seek( v );
    }

    function handleResize(e) {
        waveform.resize();
    }
}
