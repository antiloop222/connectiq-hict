using Toybox.WatchUi as Ui;

//! Main menu for CIQ3 devices
//! Replaces old resource menus/main.xml
class MainMenu extends Ui.Menu {

    function initialize() {
        Menu.initialize();
        // setTitle("Options");

        var itemName;
        var label;
        var value;

        // Activity type
        itemName = Rez.Strings.ActivityTypeLabel;
        self.addItem(itemName, :ActivityType);

        // Exercise count
        label = Ui.loadResource(Rez.Strings.ExerciseCountLabel);
        value = Prefs.getExerciseCount();
        itemName = Lang.format("$1$: $2$", [ label, value ]);
        self.addItem(itemName, :ExerciseCount);

        // Exercise duration
        label = Ui.loadResource(Rez.Strings.ExerciseTimeLabel);
        value = Prefs.getExerciseDuration();
        itemName = Lang.format("$1$: $2$", [ label, value ]);
        self.addItem(itemName, :ExerciseDuration);

        // Rest duration
        label = Ui.loadResource(Rez.Strings.RestTimeLabel);
        value = Prefs.getRestDuration();
        itemName = Lang.format("$1$: $2$", [ label, value ]);
        self.addItem(itemName, :RestDuration);

        // Notification policy
        itemName = Rez.Strings.NotifPolicyLabel;
        self.addItem(itemName, :NotifPolicy);
    }

}