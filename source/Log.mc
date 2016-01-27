using Toybox.System as Sys;

//! Logging utility
module Log {

	//! Writes a debug message on system console
	function debug(text) {
		if (DEBUG) {
			Sys.println(text);
		}
	}

	hidden var DEBUG = true;
}
