package com.example.fluttermusicplayer;

public interface PlayerInterface {

    void start(String src);

    void play();

    void pause();

    void stop();

    void seek(double position);

    void setCallback(Callback callback);

    int getState();

    interface State {
        int STOPPED = 1;
        int PLAYING = 2;
        int PAUSED = 3;
    }

    interface Callback {
        void onWaiting();

        void onCanPlay();

        void onPlay();

        void onPause();

        void onStop();

        void onEnded();

        void onTimeUpdate(double position, int bufferPercent, double duration);

        void onError(String msg);
    }

}
