using Toybox.WatchUi as Ui;

class ExerciseDurationPickerDelegate extends Ui.NumberPickerDelegate {

    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(duration) {
        if (Log.isDebugEnabled()) {
            Log.debug("Exercise duration selected: " + duration.value().toNumber());
        }
        Prefs.setExerciseDuration(duration.value().toNumber());
    }
}
