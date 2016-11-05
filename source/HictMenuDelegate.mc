using Toybox.Application as App;
using Toybox.WatchUi as Ui;

//! Application menu delegate
class HictMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        // Main
        if (item == :ExerciseDuration) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: ExerciseDuration");
            }
            Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME_MIN_SEC, new Time.Duration(Prefs.getExerciseDuration())),
                new ExerciseDurationPickerDelegate(), Ui.SLIDE_IMMEDIATE);
        }
        if (item == :RestDuration) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: RestDuration");
            }
            Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME_MIN_SEC, new Time.Duration(Prefs.getRestDuration())),
                new RestDurationPickerDelegate(), Ui.SLIDE_IMMEDIATE);
        }
        if (item == :ExerciseCount) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: ExerciseCount");
            }
            Ui.pushView(new SingleNumberPicker(Rez.Strings.ExerciseCountLabel, Prefs.getExerciseCount()),
                new ExerciseCountPickerDelegate(), Ui.SLIDE_IMMEDIATE);
        }
        if (item == :ActivityType) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: ActivityType");
            }
            Ui.pushView(new Rez.Menus.ActivityTypeMenu(), new HictMenuDelegate(), Ui.SLIDE_UP);
        }

        // Activity type
        if (item == :Cardio) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: Cardio");
            }
            Prefs.setActivityType(0);
        }
        if (item == :Strength) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: Strength");
            }
            Prefs.setActivityType(1);
        }
    }

}
