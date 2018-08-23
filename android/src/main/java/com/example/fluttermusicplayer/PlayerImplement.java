package com.example.fluttermusicplayer;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Handler;
import android.os.Looper;

import java.io.IOException;


public class PlayerImplement implements PlayerInterface {

    private MediaPlayer mMediaPlayer;
    private AudioManager mAudioManager;
    private AudioManager.OnAudioFocusChangeListener mOnAudioFocusChangeListener;
    private Handler mHandler;
    private Runnable mRunnable;
    private Context mContext;
    private String mSource;
    private Callback mCallback;
    private int mState = State.STOPPED;

    public PlayerImplement(Context context) {
        mContext = context;
    }

    private void init() {
        mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
        mOnAudioFocusChangeListener = new AudioManager.OnAudioFocusChangeListener() {
            @Override
            public void onAudioFocusChange(int i) {
                switch (i) {
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        if (mState == State.PLAYING) pause();
                        break;
                    case AudioManager.AUDIOFOCUS_GAIN:
                        if (mState == State.PAUSED) play();
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        stop();
                        break;
                }
            }
        };
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mediaPlayer) {
                mAudioManager.requestAudioFocus(mOnAudioFocusChangeListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);
                mCallback.onCanPlay();
                play();
            }
        });
        mMediaPlayer.setOnBufferingUpdateListener(new MediaPlayer.OnBufferingUpdateListener() {
            @Override
            public void onBufferingUpdate(MediaPlayer mediaPlayer, int i) {
                mCallback.onBufferUpdate(i);
            }
        });
        mMediaPlayer.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {
            @Override
            public void onSeekComplete(MediaPlayer mediaPlayer) {
                mCallback.onCanPlay();
                play();
            }
        });
        mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mediaPlayer) {
                mState = State.STOPPED;
                mCallback.onEnded();
            }
        });
        mMediaPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mediaPlayer, int i, int i1) {
                mCallback.onError(String.valueOf(i));
                return true;
            }
        });
    }

    private void handleTimeUpdate() {
        if (mState == State.PLAYING && mMediaPlayer != null) {
            mCallback.onTimeUpdate(mMediaPlayer.getCurrentPosition() / 1000d, mMediaPlayer.getDuration() / 1000d);
            mHandler.postDelayed(mRunnable, 1000);
        } else {
            mHandler.removeCallbacks(mRunnable);
        }
    }

    @Override
    public void start(String src) {
        boolean isOld = src == null || src.equals(mSource);
        mSource = src;
        if (mMediaPlayer == null) {
            init();
        }
        if (isOld) {
            play();
            return;
        }
        try {
            mMediaPlayer.reset();
            mMediaPlayer.setDataSource(mSource);
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mMediaPlayer.prepareAsync();
            mCallback.onWaiting();
        } catch (IOException e) {
            e.printStackTrace();
            mCallback.onError(e.getMessage());
        }
    }

    @Override
    public void play() {
        if (mMediaPlayer != null) {
            mMediaPlayer.start();
            mState = State.PLAYING;
            mCallback.onPlay();
            if (mHandler == null) {
                mHandler = new Handler(Looper.getMainLooper());
            }
            if (mRunnable == null) {
                mRunnable = new Runnable() {
                    @Override
                    public void run() {
                        handleTimeUpdate();
                    }
                };
            }
            handleTimeUpdate();
        }
    }

    @Override
    public void pause() {
        if (mState == State.PLAYING && mMediaPlayer != null) {
            mState = State.PAUSED;
            mMediaPlayer.pause();
            mCallback.onPause();
        }
    }

    @Override
    public void stop() {
        mState = State.STOPPED;
        mAudioManager.abandonAudioFocus(mOnAudioFocusChangeListener);
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
        mCallback.onStop();
    }

    @Override
    public void seek(double position) {
        if (mState != State.STOPPED && mMediaPlayer != null) {
            mCallback.onWaiting();
            mMediaPlayer.seekTo((int) (position * 1000));
        }
    }

    @Override
    public void setCallback(Callback callback) {
        mCallback = callback;
    }

    @Override
    public int getState() {
        return mState;
    }
}
