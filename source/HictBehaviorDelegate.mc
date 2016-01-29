using Toybox.WatchUi as Ui;

//! Application behavior delegate
class HictBehaviorDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	//! Back button pressed
	function onBack() {
		// Do not quit if activity is running
		return (view != null) && view.isRunning();
	}

	//! Key pressed
	function onKey(key) {
		if (key.getKey() == Ui.KEY_ENTER) {
			if (Log.isDebugEnabled()) {
				Log.debug("Key pressed: ENTER");
			}

			if (view.isRunning()) {
				// Stop activity
				view.stopActivity();
			} else {
				// Start activity
				view.startActivity();
			}
		}
	}

	function setHictView(v) {
		view = v;
	}

	hidden var view = null;
}
