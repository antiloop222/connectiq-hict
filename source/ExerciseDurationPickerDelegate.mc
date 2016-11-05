using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class ExerciseDurationPickerDelegate extends Ui.NumberPickerDelegate {

    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(duration) {
        if (Log.isDebugEnabled()) {
            Log.debug("Exercise duration selected: " + duration.value().toNumber());
        }
        exerciseDuration = duration.value().toNumber();

        // Save to pref store
        App.getApp().setProperty("exerTime", exerciseDuration);
    }
}
