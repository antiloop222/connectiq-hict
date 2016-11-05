using Toybox.WatchUi as Ui;

class RestDurationPickerDelegate extends Ui.NumberPickerDelegate {

    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(duration) {
        if (Log.isDebugEnabled()) {
            Log.debug("Rest duration selected: " + duration.value().toNumber());
        }
        Prefs.setRestDuration(duration.value().toNumber());
    }
}
