using Toybox.ActivityRecording as Recording;
using Toybox.Sensor as Sensor;
using Toybox.WatchUi as Ui;

//! Main view for application
class HictView extends Ui.View {

	function initialize() {
		View.initialize();
	}

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.MainLayout(dc));
	}

	//! Called when this View is brought to the foreground. Restore
	//! the state of this View and prepare it to be shown. This includes
	//! loading resources into memory.
	function onShow() {
		Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
		Sensor.setEnabledSensors([Sensor.SENSOR_TEMPERATURE]);
		Sensor.enableSensorEvents(method(:sensorAction));
	}

	//! Update the view
	function onUpdate(dc) {
		var view;

		// Draw the main text
		view = View.findDrawableById(TextLabel);
		drawMainTextLabel(view);

		// Draw the timer
		view = View.findDrawableById(TimerLabel);
		drawTimerLabel(view);

		// Draw the next label
		view = View.findDrawableById(NextLabel);
		drawNextExerciseLabel(view);

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	//! Called when this View is removed from the screen. Save the
	//! state of this View here. This includes freeing resources from
	//! memory.
	function onHide() {
	}

	//! Returns true if the activity is running, false otherwise.
	function isRunning() {
		return running;
	}

	//! Start the activity
	function startActivity() {

		Log.debug("Starting activity");

		// Start activity recording
		if (Toybox has :ActivityRecording) {
			var sessionName = Ui.loadResource(Rez.Strings.AppName);
			session = Recording.createSession({
				:name => sessionName,
				:sport => Recording.SPORT_TRAINING,
				:subSport => Recording.SUB_SPORT_EXERCISE
			});
			session.start();
		}

		// Initialize counters
		running = true;
		resting = true;
		activityTime = 0;
		exerciseCount = 0;

		// Start timer
		timer = new Timer.Timer();
		timer.start(method(:timerAction), 1000, true);

		// Update view
		Ui.requestUpdate();
	}

	//! Stop the activity
	function stopActivity() {

		Log.debug("Stopping activity");

		// Stop timer
		timer.stop();

		// Stop activity recording
		if (session != null && session.isRecording()) {
			session.stop();
			if (activityTime < 180) {
				// Ignore sessions < 3 minutes
				session.discard();
			} else {
				session.save();
			}
		}

		// Reset counters
		running = false;
		resting = true;
		activityTime = 0;
		exerciseCount = 0;

		// Update view
		Ui.requestUpdate();
	}

	function timerAction() {
		if (running) {
			activityTime++;
			periodTime++;

			if (resting) {
				if (periodTime > restDelay) {
					// Next exercise
					exerciseCount++;
					periodTime = 0;
					resting = false;
					if (session != null && session.isRecording()) {
						session.addLap();
					}
					notify();
				}
			} else {
				if (periodTime > exerciseDelay) {
					// Switch to rest
					periodTime = 0;
					resting = true;
					notify();

					// Stop after 12 exercises
					if (exerciseCount >= maxExerciseCount) {
						stopActivity();
					}
				}
			}
		}

		// Update view
		Ui.requestUpdate();
	}

	//! Action on sensor event: save heart rate and temperature for display
	function sensorAction(info) {
		if (info != null) {
			// Heart rate sensor info
			heartRate = (info.heartRate == null) ? 0 : info.heartRate;

			// Temperature sensor info
			temperature = (info.temperature == null) ? 0 : info.temperature;

			// Update view
			Ui.requestUpdate();
		}
	}

	hidden function notify() {
		Attention.vibrate([
			new Attention.VibeProfile(100, 1000)
		]);
	}

	hidden function drawMainTextLabel(view) {
		if (running) {
			view.setText(resting ? Ui.loadResource(Rez.Strings.rest) : EXERCISES[exerciseCount-1]);
		} else {
			view.setText(Ui.loadResource(Rez.Strings.press_start));
		}
	}

	hidden function drawNextExerciseLabel(view) {
		if (running) {
			if (resting) {
				view.setText(exerciseCount < 12 ? (Ui.loadResource(Rez.Strings.next) + ": " + EXERCISES[exerciseCount]) : "");
			} else {
				view.setText(Ui.loadResource(Rez.Strings.next) + ": " + Ui.loadResource(Rez.Strings.rest));
			}
		} else {
			view.setText("");
		}
	}

	hidden function drawTimerLabel(view) {
		if (running) {
			var t = (resting ? restDelay : exerciseDelay) - periodTime;
			view.setText(to2digitFormat(t));
		} else {
			view.setText("00");
		}
	}

	//! Format number with 2 digits
	//! Bug: 2-digit format does not work on productive watch (1.2.1)
	//! @param number the number to format
	hidden function to2digitFormat(number) {
		var string;
		if (number == 0) {
			string = "00";
		} else if (number < 10) {
			string = Lang.format("0$1$", [number.format("%.d")]);
		} else {
			string = Lang.format("$1$", [number.format("%.d")]);
		}
		return string;
	}

	//! List of exercises.
	hidden var EXERCISES = [
		Ui.loadResource(Rez.Strings.exercise1),
		Ui.loadResource(Rez.Strings.exercise2),
		Ui.loadResource(Rez.Strings.exercise3),
		Ui.loadResource(Rez.Strings.exercise4),
		Ui.loadResource(Rez.Strings.exercise5),
		Ui.loadResource(Rez.Strings.exercise6),
		Ui.loadResource(Rez.Strings.exercise7),
		Ui.loadResource(Rez.Strings.exercise8),
		Ui.loadResource(Rez.Strings.exercise9),
		Ui.loadResource(Rez.Strings.exercise10),
		Ui.loadResource(Rez.Strings.exercise11),
		Ui.loadResource(Rez.Strings.exercise12)
	];

	// Running flag, true if activity is running
	hidden var running = false;
	// Resting flag, true if activity is in rest mode between exercises
	hidden var resting = false;

	// Activity recording session
	hidden var session = null;
	// Activity timer
	hidden var timer = null;

	// Total time for activity
	hidden var activityTime = 0;
	// Time for current exercise/pause preriod
	hidden var periodTime = 0;
	// Exercise number now playing (1 to 12)
	hidden var exerciseCount = 0;
	// Max number of exercises
	hidden var maxExerciseCount = 12;

	// Heart rate value, if available
	hidden var heartRate = 0;
	// Temperature value, if available
	hidden var temperature = 0;

	// Exercise delay (30s)
	// TODO: should be configurable
	hidden var exerciseDelay = 30;
	// Pause delay (10s)
	// TODO: should be configurable
	hidden var restDelay = 10;

	hidden const TextLabel = "TextLabel";
	hidden const NextLabel = "NextLabel";
	hidden const TimerLabel = "TimerLabel";
}
