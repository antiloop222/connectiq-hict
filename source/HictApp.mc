using Toybox.Application as App;
using Toybox.WatchUi as Ui;

//! Application
class HictApp extends App.AppBase {

	//! Initialize the app
    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
		view = new HictView();
		behaviorDelegate = new HictBehaviorDelegate();
		behaviorDelegate.setHictView(view);

        return [ view, behaviorDelegate ];
    }


	hidden var view;
	hidden var behaviorDelegate;
}
