using Toybox.Application as App;
using Toybox.WatchUi as Ui;

//! Application menu delegate
class HictMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :ActivityType) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: ActivityType");
            }
            Ui.pushView(new Rez.Menus.ActivityTypeMenu(), new HictMenuDelegate(), Ui.SLIDE_UP);
        }
        if (item == :Cardio) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: Cardio");
            }
            setActivityType(0);
        }
        if (item == :Strength) {
            if (Log.isDebugEnabled()) {
                Log.debug("Menu item: Strength");
            }
            setActivityType(1);
        }
    }

    function setActivityType(type) {
        activityType = type;
        var app = App.getApp();
        app.setProperty("activityType", type);
        //Ui.popView(Ui.SLIDE_DOWN);
    }
}
