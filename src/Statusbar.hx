
import js.Browser.document;
import js.html.Element;
import js.html.DivElement;
import js.html.SpanElement;
import js.html.AudioElement;

class Statusbar {

    public var element(default,null) : SpanElement;

    var disposables : atom.CompositeDisposable;
    var player : AudioPlayer;

    public function new() {

        element = document.createSpanElement();
        element.setAttribute( 'is', 'status-bar-audioplayer' );
        element.classList.add( 'audioplayer-status', 'inline-block',  'icon', 'icon-unmute' );

        disposables = new atom.CompositeDisposable();
        disposables.add( Atom.workspace.onDidChangeActivePaneItem( function(e) {
            changePlayer();
        } ) );
    
        changePlayer();
    }

    public function attach() {
        trace("attach");
    }

    public function attached() {
        trace("attached");
    }

    public function dispose() {
        trace("dispose");
        disposables.dispose();
    }

    public function update() {
        trace("update");
    }

    public function setText( text : String ) {
        element.textContent = text;
    }

    function changePlayer() {
        var item = Atom.workspace.getActivePaneItem();
        if( Std.is( item, AudioPlayer ) ) {
            player = cast( item, AudioPlayer );
            var view = Atom.views.getView( player );
            var audio : AudioElement = null;
            for( child in view.children ) {
                if( child.nodeName == 'AUDIO' ) {
                    audio = cast child;
                    break;
                }
            }
            audio.addEventListener( 'canplaythrough', function(e){
                //trace(audio);
                element.textContent = ''+audio.duration;
            });
            element.style.display = 'inline-block';
        } else {
            element.textContent = '';
            element.style.display = 'none';
        }
    }
}
