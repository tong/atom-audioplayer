
import js.Browser.document;
import js.Browser.window;
import js.html.DivElement;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.CSSStyleDeclaration;
import js.html.Float32Array;
import js.html.Uint8Array;
import js.html.audio.AudioContext;
import om.audio.AudioBufferLoader;
import om.audio.PeakMeter;

class SoundSpectrum {

    public var element(default,null) : DivElement;

    public var color : String;

    public var backgroundColor(get,set) : String;
    inline function get_backgroundColor() : String return element.style.backgroundColor;
    inline function set_backgroundColor(v:String) : String return element.style.backgroundColor = v;

    var canvasWaveform : CanvasElement;
    var canvasFrequency : CanvasElement;
    var waveform : Array<Float>;

    public function new( color : String, backgroundColor : String ) {

        element = document.createDivElement();
        element.classList.add( 'spectrum' );

        canvasWaveform = document.createCanvasElement();
        canvasWaveform.classList.add( 'waveform' );
        canvasWaveform.width = window.innerWidth;
        canvasWaveform.height = window.innerHeight;
        element.appendChild( canvasWaveform );

        canvasFrequency = document.createCanvasElement();
        canvasFrequency.classList.add( 'frequency' );
        canvasFrequency.width = window.innerWidth;
        canvasFrequency.height = window.innerHeight;
        element.appendChild( canvasFrequency );

        this.color = color;
        this.backgroundColor = backgroundColor;
    }

    public function generateWaveForm( path : String, ?subRanges : Int ) {
        if( subRanges == null ) subRanges = window.innerWidth;
        AudioBufferLoader.loadAudioBuffer( AudioPlayer.context, path ).then( function(buf) {
            waveform = PeakMeter.getMergedPeaks( buf, subRanges );
            drawWaveform();
        });
    }

    /*
    public function draw( frequency : Uint8Array, timedomain : Float32Array ) {

        ///// Draw timedomain

        ctx.strokeStyle = 'rgb(90,90,90)';
        ctx.beginPath();

        for( i in 0...timedomain.length ) {
            var py = timedomain[i] * height / 2 + (height/2);
            if( i == 0) {
                ctx.moveTo( px, py );
            } else {
                ctx.lineTo( px, py );
            }
            px += bw;
        }

        ctx.lineTo( width, height/2 );
        ctx.stroke();
    }
    */

    public function resize() {
        canvasWaveform.width = canvasFrequency.width = window.innerWidth;
        canvasWaveform.height = canvasFrequency.height = window.innerHeight;
        drawWaveform();
    }

    function drawWaveform() {
        var ctx = canvasWaveform.getContext2d();
        ctx.clearRect( 0, 0, canvasWaveform.width, canvasWaveform.height );
        ctx.fillStyle = color;
        var stepSizeX = canvasWaveform.width / waveform.length;
        var i = 0;
        var halfHeight = canvasWaveform.height/2;
        for( peak in waveform ) {
            //var peakL = peak[0];
            //var peakR = peak[1];
            ctx.fillRect( i * stepSizeX, halfHeight, stepSizeX, (peak*halfHeight/2) );
            i++;
        }
        //ctx.stroke();
    }

    /*
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
    */
}

/*
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
*/
