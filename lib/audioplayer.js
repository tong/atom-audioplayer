// Generated by Haxe 4.0.0-preview.4
(function ($hx_exports) { "use strict";
var $hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}var AudioPlayer = function(state) {
	var _gthis = this;
	this.file = new atom_File(state.path,false);
	this.isPlaying = false;
	this.seekSpeed = 1;
	this.wheelSpeed = 1;
	var workspaceStyle = window.getComputedStyle(window.document.body);
	this.element = window.document.createElement("div");
	this.element.classList.add("audioplayer");
	this.element.setAttribute("tabindex","-1");
	this.spectrum = new SoundSpectrum(workspaceStyle.color,workspaceStyle.backgroundColor);
	this.element.appendChild(this.spectrum.element);
	this.marker = window.document.createElement("div");
	this.marker.classList.add("marker");
	this.element.appendChild(this.marker);
	this.audio = window.document.createElement("audio");
	this.audio.controls = true;
	this.audio.src = this.file.getPath();
	this.audio.currentTime = state.time;
	this.element.appendChild(this.audio);
	this.audio.addEventListener("playing",$bind(this,this.handleAudioPlaying),false);
	this.audio.addEventListener("ended",$bind(this,this.handleAudioEnded),false);
	this.audio.addEventListener("error",$bind(this,this.handleAudioError),false);
	this.audio.addEventListener("canplaythrough",$bind(this,this.handleCanPlayThrough),false);
	this.frequencyAnalyser = AudioPlayer.context.createAnalyser();
	this.frequencyAnalyser.fftSize = 128;
	this.timedomainAnalyser = AudioPlayer.context.createAnalyser();
	this.timedomainAnalyser.fftSize = 2048;
	this.timedomainAnalyser.connect(this.frequencyAnalyser);
	this.frequencyData = new Uint8Array(this.frequencyAnalyser.frequencyBinCount);
	this.timedomainData = new Float32Array(this.timedomainAnalyser.frequencyBinCount);
	this.commands = new atom_CompositeDisposable();
	this.commands.add(atom.commands.add(this.element,"audioplayer:toggle-playback",function(e) {
		if(_gthis.isPlaying) {
			_gthis.pause();
		} else {
			_gthis.play();
		}
	}));
	this.commands.add(atom.commands.add(this.element,"audioplayer:toggle-mute",function(e1) {
		_gthis.audio.muted = !_gthis.audio.muted;
	}));
	this.commands.add(atom.commands.add(this.element,"audioplayer:seek-backward",function(e2) {
		_gthis.seek(-(_gthis.audio.duration / 10 * _gthis.seekSpeed));
	}));
	this.commands.add(atom.commands.add(this.element,"audioplayer:seek-forward",function(e3) {
		_gthis.seek(_gthis.audio.duration / 10 * _gthis.seekSpeed);
	}));
	this.element.addEventListener("click",$bind(this,this.handleMouseDown),false);
	this.element.addEventListener("mousewheel",$bind(this,this.handleMouseWheel),false);
	if(state.play != null) {
		this.play();
	}
};
AudioPlayer.__name__ = true;
AudioPlayer.activate = $hx_exports["activate"] = function(state) {
	AudioPlayer.disposables = new atom_CompositeDisposable();
	AudioPlayer.disposables.add(atom.workspace.addOpener(AudioPlayer.openURI));
};
AudioPlayer.deactivate = $hx_exports["deactivate"] = function() {
	AudioPlayer.disposables.dispose();
	if(AudioPlayer.context != null) {
		AudioPlayer.context.close();
	}
};
AudioPlayer.deserialize = $hx_exports["deserialize"] = function(state) {
	if(AudioPlayer.context == null) {
		AudioPlayer.context = new AudioContext();
	}
	return new AudioPlayer(state);
};
AudioPlayer.openURI = function(uri) {
	var ext = haxe_io_Path.extension(uri).toLowerCase();
	if(Lambda.has(AudioPlayer.allowedFileTypes,ext)) {
		if(AudioPlayer.context == null) {
			AudioPlayer.context = new AudioContext();
		}
		return new AudioPlayer({ path : uri, play : atom.config.get("audioplayer.autoplay"), time : null});
	}
	return null;
};
AudioPlayer.consumeStatusBar = function(pane) {
};
AudioPlayer.prototype = {
	serialize: function() {
		return { deserializer : "AudioPlayer", path : this.file.getPath(), play : !this.audio.paused, time : this.audio.currentTime};
	}
	,dispose: function() {
		this.commands.dispose();
		this.element.removeEventListener("click",$bind(this,this.handleMouseDown));
		this.element.removeEventListener("mousewheel",$bind(this,this.handleMouseWheel));
		this.audio.removeEventListener("playing",$bind(this,this.handleAudioPlaying));
		this.audio.removeEventListener("ended",$bind(this,this.handleAudioEnded));
		this.audio.removeEventListener("error",$bind(this,this.handleAudioError));
		this.audio.pause();
		this.audio.remove();
		this.audio = null;
	}
	,getPath: function() {
		return this.file.getPath();
	}
	,getTitle: function() {
		return this.file.getBaseName();
	}
	,getURI: function() {
		var s = this.file.getPath();
		return "file://" + encodeURIComponent(s);
	}
	,play: function() {
		if(!this.isPlaying) {
			this.isPlaying = true;
			this.audio.play();
		}
	}
	,pause: function() {
		if(this.isPlaying) {
			this.isPlaying = false;
			this.audio.pause();
		}
	}
	,seek: function(time) {
		if(this.audio.currentTime != null) {
			this.audio.currentTime += time;
		}
		return this.audio.currentTime;
	}
	,setAudioPositionFromPanePosition: function(x) {
		this.audio.currentTime = this.audio.duration * (x / this.element.offsetWidth);
	}
	,updateMarker: function() {
		var percentPlayed = this.audio.currentTime / this.audio.duration;
		this.marker.style.left = (percentPlayed * this.element.offsetWidth | 0) + "px";
	}
	,update: function(time) {
		this.animationFrameId = window.requestAnimationFrame($bind(this,this.update));
		this.updateMarker();
	}
	,togglePlayback: function() {
		if(this.isPlaying) {
			this.pause();
		} else {
			this.play();
		}
	}
	,toggleMute: function() {
		this.audio.muted = !this.audio.muted;
	}
	,handleCanPlayThrough: function(e) {
		this.audio.removeEventListener("canplaythrough",$bind(this,this.handleCanPlayThrough));
		this.spectrum.generateWaveForm(this.file.getPath());
	}
	,handleAudioPlaying: function(e) {
		this.animationFrameId = window.requestAnimationFrame($bind(this,this.update));
	}
	,handleAudioEnded: function(e) {
		window.cancelAnimationFrame(this.animationFrameId);
		this.animationFrameId = null;
	}
	,handleAudioError: function(e) {
	}
	,handleMouseDown: function(e) {
		this.setAudioPositionFromPanePosition(e.layerX);
	}
	,handleMouseUp: function(e) {
	}
	,handleMouseOut: function(e) {
	}
	,handleMouseWheel: function(e) {
		var v = e.wheelDelta / 100 * this.wheelSpeed;
		if(e.ctrlKey) {
			v *= 10;
			if(e.shiftKey) {
				v *= 10;
			}
		}
		this.seek(v);
	}
	,handleResize: function(e) {
	}
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = true;
Lambda.has = function(it,elt) {
	var x = $getIterator(it);
	while(x.hasNext()) {
		var x1 = x.next();
		if(x1 == elt) {
			return true;
		}
	}
	return false;
};
Math.__name__ = true;
var SoundSpectrum = function(color,backgroundColor) {
	this.element = window.document.createElement("div");
	this.element.classList.add("spectrum");
	this.canvasWaveform = window.document.createElement("canvas");
	this.canvasWaveform.classList.add("waveform");
	this.canvasWaveform.width = window.innerWidth;
	this.canvasWaveform.height = window.innerHeight;
	this.element.appendChild(this.canvasWaveform);
	this.canvasFrequency = window.document.createElement("canvas");
	this.canvasFrequency.classList.add("frequency");
	this.canvasFrequency.width = window.innerWidth;
	this.canvasFrequency.height = window.innerHeight;
	this.element.appendChild(this.canvasFrequency);
	this.color = color;
	this.element.style.backgroundColor = backgroundColor;
};
SoundSpectrum.__name__ = true;
SoundSpectrum.prototype = {
	generateWaveForm: function(path,subRanges) {
		var _gthis = this;
		if(subRanges == null) {
			subRanges = window.innerWidth;
		}
		om_audio_AudioBufferLoader.loadAudioBuffer(AudioPlayer.context,path).then(function(buf) {
			_gthis.waveform = om_audio_PeakMeter.getMergedPeaks(buf,subRanges);
			_gthis.drawWaveform();
		});
	}
	,drawWaveform: function() {
		var ctx = this.canvasWaveform.getContext("2d",null);
		ctx.clearRect(0,0,this.canvasWaveform.width,this.canvasWaveform.height);
		ctx.fillStyle = this.color;
		var stepSizeX = this.canvasWaveform.width / this.waveform.length;
		var i = 0;
		var halfHeight = this.canvasWaveform.height / 2;
		var _g = 0;
		var _g1 = this.waveform;
		while(_g < _g1.length) {
			var peak = _g1[_g];
			++_g;
			ctx.fillRect(i * stepSizeX,halfHeight,stepSizeX,peak * halfHeight / 2);
			++i;
		}
	}
};
var atom_CompositeDisposable = require("atom").CompositeDisposable;
var atom_File = require("atom").File;
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe_io_Bytes.__name__ = true;
haxe_io_Bytes.alloc = function(length) {
	return new haxe_io_Bytes(new ArrayBuffer(length));
};
haxe_io_Bytes.ofString = function(s,encoding) {
	if(encoding == haxe_io_Encoding.RawNative) {
		var buf = new Uint8Array(s.length << 1);
		var _g = 0;
		var _g1 = s.length;
		while(_g < _g1) {
			var i = _g++;
			var c = s.charCodeAt(i);
			buf[i << 1] = c & 255;
			buf[i << 1 | 1] = c >> 8;
		}
		return new haxe_io_Bytes(buf.buffer);
	}
	var a = [];
	var i1 = 0;
	while(i1 < s.length) {
		var c1 = s.charCodeAt(i1++);
		if(55296 <= c1 && c1 <= 56319) {
			c1 = c1 - 55232 << 10 | s.charCodeAt(i1++) & 1023;
		}
		if(c1 <= 127) {
			a.push(c1);
		} else if(c1 <= 2047) {
			a.push(192 | c1 >> 6);
			a.push(128 | c1 & 63);
		} else if(c1 <= 65535) {
			a.push(224 | c1 >> 12);
			a.push(128 | c1 >> 6 & 63);
			a.push(128 | c1 & 63);
		} else {
			a.push(240 | c1 >> 18);
			a.push(128 | c1 >> 12 & 63);
			a.push(128 | c1 >> 6 & 63);
			a.push(128 | c1 & 63);
		}
	}
	return new haxe_io_Bytes(new Uint8Array(a).buffer);
};
haxe_io_Bytes.ofData = function(b) {
	var hb = b.hxBytes;
	if(hb != null) {
		return hb;
	}
	return new haxe_io_Bytes(b);
};
haxe_io_Bytes.ofHex = function(s) {
	if((s.length & 1) != 0) {
		throw new js__$Boot_HaxeError("Not a hex string (odd number of digits)");
	}
	var a = [];
	var i = 0;
	var len = s.length >> 1;
	while(i < len) {
		var high = s.charCodeAt(i * 2);
		var low = s.charCodeAt(i * 2 + 1);
		high = (high & 15) + ((high & 64) >> 6) * 9;
		low = (low & 15) + ((low & 64) >> 6) * 9;
		a.push((high << 4 | low) & 255);
		++i;
	}
	return new haxe_io_Bytes(new Uint8Array(a).buffer);
};
haxe_io_Bytes.fastGet = function(b,pos) {
	return b.bytes[pos];
};
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__ : true, __constructs__ : ["UTF8","RawNative"]
	,UTF8: {_hx_index:0,__enum__:"haxe.io.Encoding"}
	,RawNative: {_hx_index:1,__enum__:"haxe.io.Encoding"}
};
var haxe_io_Path = function(path) {
	switch(path) {
	case ".":case "..":
		this.dir = path;
		this.file = "";
		return;
	}
	var c1 = path.lastIndexOf("/");
	var c2 = path.lastIndexOf("\\");
	if(c1 < c2) {
		this.dir = HxOverrides.substr(path,0,c2);
		path = HxOverrides.substr(path,c2 + 1,null);
		this.backslash = true;
	} else if(c2 < c1) {
		this.dir = HxOverrides.substr(path,0,c1);
		path = HxOverrides.substr(path,c1 + 1,null);
	} else {
		this.dir = null;
	}
	var cp = path.lastIndexOf(".");
	if(cp != -1) {
		this.ext = HxOverrides.substr(path,cp + 1,null);
		this.file = HxOverrides.substr(path,0,cp);
	} else {
		this.ext = null;
		this.file = path;
	}
};
haxe_io_Path.__name__ = true;
haxe_io_Path.extension = function(path) {
	var s = new haxe_io_Path(path);
	if(s.ext == null) {
		return "";
	}
	return s.ext;
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o.__enum__) {
			var e = $hxEnums[o.__enum__];
			var n = e.__constructs__[o._hx_index];
			var con = e[n];
			if(con.__params__) {
				s += "\t";
				var tmp = n + "(";
				var _g = [];
				var _g1 = 0;
				var _g2 = con.__params__;
				while(_g1 < _g2.length) {
					var p = _g2[_g1];
					++_g1;
					_g.push(js_Boot.__string_rec(o[p],s));
				}
				return tmp + _g.join(",") + ")";
			} else {
				return n;
			}
		}
		if((o instanceof Array)) {
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g3 = 0;
			var _g11 = l;
			while(_g3 < _g11) {
				var i1 = _g3++;
				str += (i1 > 0 ? "," : "") + js_Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e1 ) {
			var e2 = (e1 instanceof js__$Boot_HaxeError) ? e1.val : e1;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var k = null;
		var str1 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str1.length != 2) {
			str1 += ", \n";
		}
		str1 += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str1 += "\n" + s + "}";
		return str1;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var js_node_Fs = require("fs");
var om_ArrayBufferTools = function() { };
om_ArrayBufferTools.__name__ = true;
om_ArrayBufferTools.buf2ab = function(buf) {
	var a = new ArrayBuffer(buf.length);
	var v = new Uint8Array(a);
	var _g = 0;
	var _g1 = buf.length;
	while(_g < _g1) {
		var i = _g++;
		v[i] = buf[i];
	}
	return a;
};
var om_audio_AudioBufferLoader = function() { };
om_audio_AudioBufferLoader.__name__ = true;
om_audio_AudioBufferLoader.loadArrayBuffer = function(url) {
	return new Promise(function(resolve,reject) {
		js_node_Fs.readFile(url,function(e,buf) {
			if(e != null) {
				reject(e);
			} else {
				var tmp = om_ArrayBufferTools.buf2ab(buf);
				resolve(tmp);
			}
		});
	});
};
om_audio_AudioBufferLoader.loadAudioBuffer = function(ctx,url) {
	return om_audio_AudioBufferLoader.loadArrayBuffer(url).then(function(buf) {
		return ctx.decodeAudioData(buf).then(function(abuf) {
			return abuf;
		});
	});
};
var om_audio_PeakMeter = function() { };
om_audio_PeakMeter.__name__ = true;
om_audio_PeakMeter.getMergedPeaks = function(buf,length) {
	var sampleSize = buf.length / length | 0;
	var sampleStep = ~(~(sampleSize / 10 | 0)) | 0;
	var channels = buf.numberOfChannels;
	var mergedPeaks = [];
	var _g = 0;
	var _g1 = channels;
	while(_g < _g1) {
		var c = _g++;
		var peaks = [];
		var chan = buf.getChannelData(c);
		var _g2 = 0;
		var _g11 = length;
		while(_g2 < _g11) {
			var i = _g2++;
			var start = ~(~(i * sampleSize)) | 0;
			var end = ~(~(start + sampleSize));
			var min = chan[0];
			var max = chan[0];
			var j = start;
			while(j < end) {
				var value = chan[j];
				if(value > max) {
					max = value;
				}
				if(value < min) {
					min = value;
				}
				j += sampleStep;
			}
			peaks[2 * i] = max;
			peaks[2 * i + 1] = min;
			if(c == 0 || max > mergedPeaks[2 * i]) {
				mergedPeaks[2 * i] = max;
			}
			if(c == 0 || min < mergedPeaks[2 * i + 1]) {
				mergedPeaks[2 * i + 1] = min;
			}
		}
	}
	return mergedPeaks;
};
function $getIterator(o) { if( o instanceof Array ) return HxOverrides.iter(o); else return o.iterator(); }
var $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = m.bind(o); o.hx__closures__[m.__id__] = f; } return f; }
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.__name__ = true;
Array.__name__ = true;
Object.defineProperty(js__$Boot_HaxeError.prototype,"message",{ get : function() {
	return String(this.val);
}});
AudioPlayer.allowedFileTypes = ["flac","mp3","ogg","opus","weba","wav"];
})(typeof exports != "undefined" ? exports : typeof window != "undefined" ? window : typeof self != "undefined" ? self : this);
