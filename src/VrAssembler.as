


package  {

	import flash.utils.Endian;
	import avmplus.FileSystem;
	import avmplus.System;

	import flash.utils.ByteArray;

	public class assemble {
			
		private var cl : CommandLine;

		public function assemble(args : Array) {
			
			cl = new CommandLine( args );
			
			if( cl.isEmpty() ) {
				printHelp();
				System.exit( 0 );
			}
			
			_run();
			
			System.exit( 0 );
			
		}

		public function filterJxr(element:*, index:int, arr:Array) : Boolean {
			return ( element.AS3::substr(-4) == '.jxr');
		}


		private function _run() : void {
			
			const sep  : String = FileSystem.separators[0];
			
			var res : ByteArray = new ByteArray();
			res.endian = Endian.LITTLE_ENDIAN;
			
			var jxrs : Array = FileSystem.listFilesWithFilter( cl.dir, filterJxr, false );

			// MAGIC
			res.writeUTFBytes('VRA');

			// MAP TABLE
			var map : ByteArray = FileSystem.readByteArray( cl.dir+sep+'areas.bin');
			
			res.writeUnsignedInt( map.length );
			res.writeBytes( map );
			
			for (var i : int = 0, l : int = jxrs.length; i < l; i++) {
				var jxr : ByteArray = FileSystem.readByteArray( cl.dir+sep+jxrs[i] );
				var nsplit : Array = jxrs[i].substr(0, -4).split('_');
				var face : uint = parseInt(nsplit[0] );
				var index : uint = parseInt(nsplit[1] );
				
				res.writeUnsignedInt( face );
				res.writeUnsignedInt( index );
				res.writeUnsignedInt( jxr.length );
				res.writeBytes( jxr );
			}
			
			trace( "output "+cl.output+" ["+uint(res.length/1024)+"Ko]")
			FileSystem.writeByteArray( cl.output, res );
			
		}
		
		private function printHelp() : void {
			
			var nl : String = "\n";
			
			var help : String = "";
			
			help += "clean_materials"+nl;
			help += "Remove duplicated materials (mat with the same name)"+nl;
			help += "author Pierre Lepers (pierre[dot]lepers[at]gmail[dot]com)"+nl;
			help += "powered by RedTamarin"+nl;
			help += "version 1.0"+nl;
			help += "usage : clean_materials "+nl;
//			
			help += " -i <awdfile> input awd file"+nl;
			help += " -o <filename> : output little endian file"+nl;
			
			trace( help );
		}
	}
	
}



import avmplus.System;
import avmplus.FileSystem;

import flash.utils.Dictionary;

class CommandLine {


	public function isEmpty() : Boolean {
		return _empty;
	}

	
	public function CommandLine( arguments : Array ) {
		_init();
		_build(arguments);
	}

	private var _dir : String;
	private var _output : String;
	private var _help : Boolean;
	
	private function _build(arguments : Array) : void {
		
		
		_empty = arguments.length == 0;
		var arg : String;
		while( arguments.length > 0 ) {
			arg = arguments.shift();
			var handler : Function = _argHandlers[ arg ];
			if( handler == undefined )
				throw new Error(arg + " is not a valid argument." + HELP);
				
			handler(arguments);
		}
	}
	

	
	private function handleDir( args : Array ) : void {
		_dir = FileSystem.normalizePath( args.shift() );
	}
	
	private function handleOutput( args : Array ) : void {
		if( _output != null )
			throw new Error("-o / -output argument cannot be define twice." + HELP);
		_output = args.shift();
	}

	private function handleHelp( args : Array ) : void {
		_help = true;
	}

	

	private function _init() : void {
		_argHandlers = new Dictionary();
		
		_argHandlers[ "-dir" ] = handleDir;
		_argHandlers[ "-o" ] = handleOutput;
		_argHandlers[ "-help" ] = handleHelp;
	}
	
	
	private var _empty : Boolean = true;

	private var _argHandlers : Dictionary;


	private static const HELP : String = " -help for more infos.";
	

	public function get output() : String {
		return _output;
	}
	
	public function get dir() : String {
		return _dir;
	}
	
	public function get help() : Boolean {
		return _help;
	}

	

	
}






var main : assemble = new assemble( System.argv );
