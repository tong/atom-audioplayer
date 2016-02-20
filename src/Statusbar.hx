
import js.Browser.document;
import js.html.Element;
import js.html.DivElement;
import js.html.SpanElement;
import js.html.AudioElement;

class Statusbar {

    public var element(default,null) : SpanElement;

    var disposables : atom.CompositeDisposable;

    public function new() {

        element = document.createSpanElement();
        element.setAttribute( 'is', 'status-bar-audioplayer' );
        element.classList.add( 'audioplayer-status', 'inline-block',  'icon', 'icon-unmute' );

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.workspace.onDidChangeActivePaneItem( function(e) {
            var item = Atom.workspace.getActivePaneItem();
            if( Std.is( item, AudioPlayer ) ) {
                var player = cast( item, AudioPlayer );
                var view = Atom.views.getView( player );
                var audio : AudioElement = null;
                for( child in view.children ) {
                    if( child.nodeName == 'AUDIO' ) {
                        audio = cast child;
                        break;
                    }
                }
                audio.addEventListener( 'canplaythrough', function(e){
                    trace(audio);
                    element.textContent = ''+audio.duration;
                });

            }
            /*
            var item = Atom.workspace.getActivePaneItem();
            if( Std.is( item, AudioPlayer ) ) {
                var player = cast( item, VideoPlayer );
                var view = Atom.views.getView( player );
                var video : VideoElement = cast view.children[0];
                video.addEventListener( 'canplaythrough', function(e){
                    var info = video.videoWidth+"x"+video.videoHeight;
                    //trace(untyped video.webkitAudioDecodedByteCount);
                    //trace(untyped video.webkitDroppedFrameCount);
                    //var q = video.getVideoPlaybackQuality();
                    element.textContent = info;
                    element.style.display = 'inline-block';

                    /*
                    Atom.tooltips.add( element, { title:
                        '<div>AudioDecodedByteCount: '+untyped video.webkitAudioDecodedByteCount+'</div>'
                    } );
                    * /

                }, false );
            } else {
                element.textContent = '';
                element.style.display = 'none';
            }
            */
        } ) );
    }

    public function attach() {
        trace("attach");
    }

    public function attached() {
        trace("attached");
    }

    public function destroy() {
        trace("destroy");
        disposables.dispose();
    }

    public function update() {
        trace("update");
    }

    public function setText( text : String ) {
        element.textContent = text;
    }
}
