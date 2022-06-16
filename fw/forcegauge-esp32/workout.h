#pragma once

#include "tabata.h"

class Workout
{
public:
    enum WorkoutSound
    {
        soundCountdownPip,
        soundStartRep,
        soundStartRest,
        soundStartBreak,
        soundStartSet,
        soundEndWorkout,
        soundWarningBeforeBreakEnds,
        soundTargetReached
    };

    enum WorkoutState
    {
        stateInitial,
        stateStarting,
        stateExercising,
        stateResting,
        stateBreaking,
        stateFinished
    };
    static String stepName(WorkoutState step)
    {
        switch (step)
        {
        case stateExercising:
            return "Exercise";
        case stateResting:
            return "Rest";
        case stateBreaking:
            return "Break";
        case stateFinished:
            return "Finished";
        case stateStarting:
            return "Starting";
        default:
            return "";
        }
    }

    Tabata _config;
    WorkoutState _step = stateInitial;
    int _set = 0; // Current set
    int _rep = 0; // Current rep
    int _totalTime = 0;
    float _targetForce = 0;
    float _lastForceValue = 0;
    int _timeLeft = 0;
    bool _targetForceReached = false;
    void (*_onSound)(WorkoutSound) = nullptr;
    bool timerRunning = false;

    void _playSound(WorkoutSound sound)
    {
        if (_onSound != nullptr)
        {
            _onSound(sound);
        }
    }

    Workout(Tabata &tabata, float targetForce = 0) : _config(tabata), _targetForce(targetForce){};

    void registerOnSounds(void (*onSound)(WorkoutSound))
    {
        _onSound = onSound;
    }

    // void printState()
    // {
    //     std::string buff = "";
    //     buff += stepName(_step) + "\n";
    //     int min = _timeLeft / 60;
    //     int sec = _timeLeft % 60;
    //     buff += std::to_string(min) + ":" + std::to_string(sec) + "\n";
    //     buff += "Set: " + std::to_string(_set) + " rep: " + std::to_string(_rep) + "\n";

    //     // In seconds
    //     // buff += "Tabata time: " + std::to_string(_config.getTotalTime()) + "\n";
    //     // buff += "Tabata time: " + std::to_string(_totalTime) + "\n";
    //     // buff += "Time left: " + std::to_string(getTimeRemaining()) + "\n";

    //     // min = _config.getTotalTime() / 60;
    //     // sec = _config.getTotalTime() % 60;
    //     // buff += "Tabata time: " + std::to_string(min) + ":" + std::to_string(sec) + "\n";

    //     min = _totalTime / 60;
    //     sec = _totalTime % 60;
    //     buff += "Total time: " + std::to_string(min) + ":" + std::to_string(sec) + "\n";

    //     int timeRemaining = getTimeRemaining();
    //     min = timeRemaining / 60;
    //     sec = timeRemaining % 60;
    //     buff += "Time left: " + std::to_string(min) + ":" + std::to_string(sec) + "\n";

    //     std::cout << buff << std::endl;
    // }

    // New force value has arrived
    void newForceValue(float force)
    {
        _lastForceValue = force;
        bool playSoundFlag = false;
        if (fabsf(force) > _targetForce && _targetForceReached == false)
        {
            _targetForceReached = true;
            playSoundFlag = true;
        }

        // record only in workout
        if (_step == stateExercising && _targetForceReached)
        {
            //   _workoutReport.addValue(_set, _rep, force);
            if (playSoundFlag)
                _playSound(soundTargetReached);
        }
    }

    void stop()
    {
        _finish();
    }

    // Starts or resumes the workout
    void start()
    {
        if (timerRunning)
            return;

        if (_step == stateFinished)
            return;

        timerRunning = true;

        if (_step == stateInitial)
        {
            _step = stateStarting;
            if (_config.startDelay == 0)
            {
                _nextStep();
            }
            else
            {
                _timeLeft = _config.startDelay;
            }
        }
        //_onStateChange();
    }

    bool isStarted()
    {
        return timerRunning;
    }

    bool isFinished()
    {
        return _step == stateFinished;
    }

    void next()
    {
        //_waitAfterUserAction = Duration(seconds : 0);
        _nextStep();
    }

    void previous()
    {
        //_waitAfterUserAction = Duration(seconds : 0);
        _prevStep();
    }

    void finished()
    {
        pause();
        _step = stateFinished;
        //_onStateChange();
    }

    //   /// Pauses the workout
    void pause()
    {
        timerRunning = false;
        //_timer.cancel();
        //_onStateChange();
    }

    //   /// Stops the timer without triggering the state change callback.
    //   dispose() { _timer.cancel(); }

    void tick()
    {
        if (timerRunning == false)
            return;
        // if (_waitAfterUserAction > 0) {
        //   _waitAfterUserAction -= Duration(seconds : 1);
        //   return;
        // }

        if (_step != stateStarting)
        {
            _totalTime += 1;
        }

        bool targetForceReached = true;
        if (_step == stateExercising)
        {
            if (_targetForceReached == false)
            {
                targetForceReached = false;
            }
        }
        if (targetForceReached)
        {
            if (_timeLeft == 1)
            {

                _nextStep();
            }
            else
            {
                _timeLeft -= 1;

                if (_timeLeft <= 3 && _timeLeft >= 1)
                {
                    _playSound(soundCountdownPip);
                }
                else if (_targetForce != 0.0f && _step == stateExercising)
                {
                    // if (_targetForce > 0.001)
                    //     _playSound(soundCountdownPip);
                }
                if (_timeLeft == _config.warningBeforeBreakEndsTime &&
                    _config.warningBeforeBreakEndsTime > 0 && _step != stateExercising)
                {
                    _playSound(soundWarningBeforeBreakEnds);
                }
            }
        }
        //_onStateChange();
    }

    void _prevStep()
    {
        //_workoutReport.clearValues(_set, _rep);
        if (_rep == 0 && _set == 0)
        {
            _step = stateStarting;
            _timeLeft = _config.startDelay;
            return;
        }
        if (_step == stateExercising)
        {
            if (_rep == 1)
            {
                if (_set == 1)
                {
                    _set = 0;
                    _rep = 0;
                    _step = stateStarting;
                    _timeLeft = _config.startDelay;
                }
                else
                {
                    _set--;
                    _rep = _config.reps;
                    _startBreak();
                }
            }
            else
            {
                _rep--;
                _startRest();
            }
        }
        else if (_step == stateResting)
        {
            _rep--;
            _startRep();
            //_workoutReport.clearValues(_set, _rep);
        }
        else if (_step == stateStarting || _step == stateBreaking)
        {
            _set--;
            _startSet();
            _rep = _config.reps;
            //_workoutReport.clearValues(_set, _rep);
        }
    }

    //   /// Moves the workout to the next step and sets up state for it.
    void _nextStep()
    {

        // print("Rep: $rep, Set: $set");
        if (_targetForce < 0.001)
            _targetForceReached = true;
        else
            _targetForceReached = false;

        if (_step == stateExercising)
        {

            if (_rep == _config.reps)
            {
                if (_set == _config.sets)
                {
                    _finish();
                }
                else
                {
                    _startBreak();
                }
            }
            else
            {
                _startRest();
            }
        }
        else if (_step == stateResting)
        {
            _startRep();
        }
        else if (_step == stateStarting || _step == stateBreaking)
        {

            _startSet();
        }
    }

    //   Future _playSound(String sound) {
    //     // silent mode
    //     if (sound == null || sound.length == 0) {
    //       return Future.value();
    //     }
    //     // audioCache.duckAudio = true;
    //     // return audioCache.play("sounds/" + sound);
    //     AssetsAudioPlayer.newPlayer().open(Audio("assets/sounds/" + sound), showNotification : false, autoStart : true,
    //     );

    //     return Future.value();
    //   }

    void _startRest()
    {
        _step = stateResting;
        if (_config.restTime == 0)
        {
            _nextStep();
            return;
        }
        _timeLeft = _config.restTime;
        _playSound(soundStartRest);
    }

    void _startRep()
    {
        _rep++;
        _step = stateExercising;
        _timeLeft = _config.exerciseTime;
        // print("Start rep: $_targetForce");
        if (_targetForce < 0.001)
        {
            _playSound(soundStartRep);
        }
    }

    void _startBreak()
    {
        _step = stateBreaking;
        if (_config.breakTime == 0)
        {
            _nextStep();
            return;
        }
        _timeLeft = _config.breakTime;
        _playSound(soundStartBreak);
    }

    void _startSet()
    {
        _set++;
        _rep = 1;
        _step = stateExercising;
        _timeLeft = _config.exerciseTime;

        if (_targetForce < 0.001)
        {

            _playSound(soundStartSet);
        }
    }

    void _finish()
    {
        timerRunning = false;
        _step = stateFinished;
        _timeLeft = 0;
        _playSound(soundEndWorkout);
        //_playSound(_sounds.endWorkout).then((p) {
        //   if (p == null)
        //   {
        //     return;
        //   }
        //   p.onPlayerCompletion.first.then((_) { _playSound(_sounds.endWorkout); });
        // });
    }

    int getTimeRemaining()
    {
        int sets, reps, time = 0;
        if (_step == stateStarting)
        {
            time = _config.getTotalTime() - _config.startDelay + _timeLeft;
        }

        else if (_step == stateExercising)
        {
            sets = _config.sets - (_set - 1);
            time = (_config.exerciseTime * sets * _config.reps) + (_config.restTime * sets * (_config.reps - 1)) + (_config.breakTime * (sets - 1));
            time -= (_config.restTime + _config.exerciseTime) * (_rep - 1);
            time -= (_config.exerciseTime - _timeLeft);
        }
        else if (_step == stateResting)
        {
            sets = _config.sets - (_set - 1);
            time = (_config.exerciseTime * sets * _config.reps) + (_config.restTime * sets * (_config.reps - 1)) + (_config.breakTime * (sets - 1));
            time -= (_config.restTime + _config.exerciseTime) * (_rep - 1);
            time -= _config.exerciseTime;
            time -= (_config.restTime - _timeLeft);
        }
        else if (_step == stateBreaking)
        {
            sets = _config.sets - _set;
            time = (_config.exerciseTime * sets * _config.reps) + (_config.restTime * sets * (_config.reps - 1)) + (_config.breakTime * (sets - 1));
            time += _timeLeft;
        }
        return time;
    }
};
