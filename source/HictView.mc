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
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE, Sensor.SENSOR_FOOTPOD]);
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

        // Draw the exercise count label
        view = View.findDrawableById(ExerciseLabel);
        drawExerciseLabel(view);

        // Draw the heart rate label
        view = View.findDrawableById(HeartrateLabel);
        drawHeartrateLabel(view);

        // Draw the temperature label
        view = View.findDrawableById(TemperatureLabel);
        drawTemperatureLabel(view);

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

    //! Returns true if the activity is running and it is a work period, false otherwise.
    function isWorking() {
        return running && !resting;
    }

    //! Returns true if the activity is running and it is a rest period, false otherwise.
    function isResting() {
        return running && resting;
    }

    //! Returns true if the workout is finished, false otherwise.
    function isDone() {
        return (!running) || (exerciseCount >= maxExerciseCount);
    }


    //! Start the activity
    function startActivity() {
        if (Log.isDebugEnabled()) {
            Log.debug("Starting activity");
        }

        // Load activity preference values
        loadPreferences();

        // Start activity recording
        if (Toybox has :ActivityRecording) {

            if (Log.isDebugEnabled()) {
                Log.debug("Activity recording is supported, starting session");
            }

            var sessionName = Ui.loadResource(Rez.Strings.SessionLabel);
            var type = Recording.SUB_SPORT_CARDIO_TRAINING;
            if (activityType == 1) {
                type = Recording.SUB_SPORT_STRENGTH_TRAINING;
                if (Log.isDebugEnabled()) {
                    Log.debug("Activity type: Strength");
                }
            } else {
                type = Recording.SUB_SPORT_CARDIO_TRAINING;
                if (Log.isDebugEnabled()) {
                    Log.debug("Activity type: Cardio");
                }
            }

            session = Recording.createSession({
                :sport=>Recording.SPORT_TRAINING,
                :subSport=>type,
                :name=>sessionName
            });
        }

        // Initialize counters
        running = true;
        resting = true;
        exerciseCount = 0;
        periodTime = 0;

        // Start timer
        timer = new Timer.Timer();
        timer.start(method(:timerAction), 1000, true);

        // Update view
        Ui.requestUpdate();
    }

    //! Stop the activity.
    //! If the session is running, then ask for confirmation.
    //! If confirmed, then closeActivity should be called by the handler.
    //! If not confirmed, then resumeActivity should be called by the handler.
    //! If the session is not running, then close the activity.
    function stopActivity() {

        if (Log.isDebugEnabled()) {
            Log.debug("Stopping activity");
        }

        // Stop timer
        timer.stop();

        // Pause activity recording
        if (session != null) {
            if (Log.isDebugEnabled()) {
                Log.debug("Stopping session recording");
            }
            session.stop();
        }

        if (running && !isDone()) {
            // Ask for confirmation
            var dialog = new Ui.Confirmation(Ui.loadResource(Rez.Strings.stop_session));
            var delegate = new StopConfirmationDelegate();
            delegate.setHictView(self);
            Ui.pushView(dialog, delegate, Ui.SLIDE_IMMEDIATE );
        } else {
            // Close activity
            closeActivity();
        }
    }

    //! Resume the activity
    function resumeActivity() {
        // Continue timer
        timer.start(method(:timerAction), 1000, true);
    }

    //! Close the activity and clean-up the session.
    function closeActivity() {

        if (Log.isDebugEnabled()) {
            Log.debug("Closing activity");
        }

        // Stop activity recording
        if (session != null) {
            if (exerciseCount < (maxExerciseCount / 2)) {
                // Ignore sessions < 6 exercises
                if (Log.isDebugEnabled()) {
                    Log.debug("Discarding workout session with only " + exerciseCount + " exercises");
                }
                session.discard();
            } else {
                if (Log.isDebugEnabled()) {
                    Log.debug("Saving workout session");
                }
                session.save();
            }

            // Clean session
            session = null;
        }

        // Reset counters
        running = false;
        resting = false;
        exerciseCount = 0;
        periodTime = 0;

        // Update view
        Ui.requestUpdate();
    }

    //! Action on timer event: switch to/from workout/rest
    function timerAction() {
        if (running) {
            // Increment time counter for the period
            periodTime++;

            if (resting) {
                if (periodTime >= restDelay) {
                    // Next exercise
                    switchToWorkout();
                }
            } else {
                if (periodTime >= exerciseDelay) {
                    // Switch to rest
                    switchToRest();
                } else {
                    if (periodTime % 10 == 0) {
                        // Short vibration
                        notifyShort();
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
            // if (Log.isDebugEnabled()) {
            //     Log.debug("Heartrate info: " + heartRate);
            // }

            // Temperature sensor info
            temperature = (info.temperature == null) ? -999 : info.temperature;
            // if (Log.isDebugEnabled()) {
            //     Log.debug("Temperature info: " + temperature);
            // }

            // Update view
            Ui.requestUpdate();
        }
    }

    hidden function switchToWorkout() {
        if (Log.isDebugEnabled()) {
            Log.debug("Switching to workout period");
        }

        exerciseCount++;
        periodTime = 0;
        resting = false;

        if (session != null) {
            if (!session.isRecording()) {
                if (Log.isDebugEnabled()) {
                    Log.debug("Starting session");
                }
                session.start();
            } else {
                // Add lap
                if (Log.isDebugEnabled()) {
                    Log.debug("Adding lap to session");
                }
                session.addLap();
            }
        }

        if (Log.isDebugEnabled()) {
            Log.debug("New exercise: " + EXERCISES[(exerciseCount - 1) % EXERCISES.size()]);
        }

        notifyEnd();
    }

    hidden function switchToRest() {
        if (Log.isDebugEnabled()) {
            Log.debug("Switching to rest period");
        }

        periodTime = 0;
        resting = true;

        if (session != null && session.isRecording()) {
            // Add lap
            if (Log.isDebugEnabled()) {
                Log.debug("Adding lap to session");
            }
            session.addLap();
        }

        if (Log.isDebugEnabled()) {
            Log.debug("Rest period");
        }

        notifyEnd();

        // Stop after maxExerciseCount exercises
        if (isDone()) {
            if (Log.isDebugEnabled()) {
                Log.debug("Reached max exercise count");
            }
            stopActivity();
        }
    }

    hidden function notifyEnd() {
        Attention.vibrate([
            new Attention.VibeProfile(100, 1000)
        ]);
    }

    hidden function notifyShort() {
        Attention.vibrate([
            new Attention.VibeProfile(100, 400)
        ]);
    }

    //! Load preferences for the view from the object store.
    //! This can be called from the app when the settings have changed.
    function loadPreferences() {
        exerciseDelay = Prefs.getExerciseDuration();
        restDelay = Prefs.getRestDuration();
        maxExerciseCount = Prefs.getExerciseCount();
        activityType = Prefs.getActivityType();
    }

    hidden function drawMainTextLabel(view) {
        if (running) {
            if (resting) {
                view.setText(exerciseCount < 1 ? Ui.loadResource(Rez.Strings.get_ready) : Ui.loadResource(Rez.Strings.rest));
            } else {
                view.setText(EXERCISES[(exerciseCount - 1) % EXERCISES.size()]);
            }
        } else {
            view.setText(Ui.loadResource(Rez.Strings.press_start));
        }
    }

    hidden function drawNextExerciseLabel(view) {
        if (running) {
            view.setText(exerciseCount < maxExerciseCount ? EXERCISES[exerciseCount % EXERCISES.size()] : "");
        } else {
            view.setText("");
        }
    }

    hidden function drawTimerLabel(view) {
        if (running) {
            var t = (resting ? restDelay : exerciseDelay) - periodTime - 1;
            view.setText(to2digitFormat(t));
        } else {
            view.setText(Ui.loadResource(Rez.Strings.no_value));
        }
    }

    hidden function drawExerciseLabel(view) {
        if (running && exerciseCount > 0) {
            view.setText(Lang.format("$1$ / $2$", [exerciseCount.format("%d"), maxExerciseCount.format("%d")]));
        } else {
            view.setText(Ui.loadResource(Rez.Strings.no_value));
        }
    }

    hidden function drawHeartrateLabel(view) {
        if (heartRate > 0) {
            view.setText(Lang.format("$1$", [heartRate.format("%d")]));
        } else {
            view.setText(Ui.loadResource(Rez.Strings.no_value));
        }
    }

    hidden function drawTemperatureLabel(view) {
        if (temperature > -999) {
            view.setText(Lang.format("$1$", [temperature.format("%1.1f")]));
        } else {
            view.setText(Ui.loadResource(Rez.Strings.no_value));
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
            string = Lang.format("0$1$", [number.format("%d")]);
        } else {
            string = Lang.format("$1$", [number.format("%d")]);
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
        Ui.loadResource(Rez.Strings.exercise12),
        Ui.loadResource(Rez.Strings.exercise13)
    ];

    // Running flag, true if activity is running
    hidden var running = false;
    // Resting flag, true if activity is in rest mode between exercises
    hidden var resting = false;

    // Activity recording session
    hidden var session = null;
    // Activity timer
    hidden var timer = null;

    // Time for current exercise/pause period
    hidden var periodTime = 0;
    // Exercise number now playing (1 to maxExerciseCount)
    hidden var exerciseCount = 0;

    // Heart rate value, if available
    hidden var heartRate = 0;
    // Temperature value, if available
    hidden var temperature = 0;

    // Activity type
    hidden var activityType = 0;
    // Max number of exercises
    hidden var maxExerciseCount = 13;
    // Exercise delay
    hidden var exerciseDelay = 30;
    // Pause delay
    hidden var restDelay = 10;

    hidden const TextLabel = "TextLabel";
    hidden const NextLabel = "NextLabel";
    hidden const TimerLabel = "TimerLabel";
    hidden const ExerciseLabel = "ExerciseLabel";
    hidden const HeartrateLabel = "HeartrateLabel";
    hidden const TemperatureLabel = "TemperatureLabel";
}
