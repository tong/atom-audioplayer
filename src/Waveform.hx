
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.CSSStyleDeclaration;
import js.html.audio.AudioContext;
import js.Browser.document;
import js.Browser.window;
import om.audio.AudioBufferLoader;
import om.audio.PeakMeter;

class Waveform {

    public var canvas(default,null) : CanvasElement;
    public var color : String;
    public var backgroundColor(get,set) : String;

    //var audio : AudioContext;
    var context : CanvasRenderingContext2D;
    var peaks : Array<Float>;

    public function new( color : String, backgroundColor : String ) {

        canvas = document.createCanvasElement();
        canvas.classList.add( 'waveform' );
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        this.color = color;
        this.backgroundColor = backgroundColor;

        context = canvas.getContext2d();
        context.fillStyle = color;
    }

    inline function get_backgroundColor() : String return canvas.style.backgroundColor;
    inline function set_backgroundColor(v:String) : String return canvas.style.backgroundColor = v;

    public function generate( path : String, ?subRanges : Int, ?onComplete : Void->Void ) {

        if( subRanges == null ) subRanges = window.innerWidth;

        AudioBufferLoader.load( AudioPlayer.context, path, function(e,buf){

            if( e != null ) {
                Atom.notifications.addError( 'Failed to analyze sound data' );
                return;
            }

            peaks = PeakMeter.getMergedPeaks( buf, subRanges );
            //TODO determine max volume

            draw( peaks );

            if( onComplete != null ) onComplete();
        });
    }

    public function resize() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        draw( peaks );
    }

    function draw( peaks : Array<Float> ) {

        context.clearRect( 0, 0, canvas.width, canvas.height );
        context.fillStyle = color;

        var stepSizeX = canvas.width / peaks.length;
        var i = 0;
        var halfHeight = canvas.height/2;

        for( peak in peaks ) {
            //var peakL = peak[0];
            //var peakR = peak[1];
            context.fillRect( i * stepSizeX, halfHeight, stepSizeX, (peak*halfHeight/2) );
            i++;
        }
        //context.stroke();
    }

}
