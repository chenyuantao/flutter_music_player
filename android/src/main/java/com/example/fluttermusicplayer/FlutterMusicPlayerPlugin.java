package com.example.fluttermusicplayer;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterMusicPlayerPlugin
 */
public class FlutterMusicPlayerPlugin implements MethodCallHandler {

    private static PlayerInterface mPlayer;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_music_player");
        mPlayer = new PlayerImplement(registrar.context());
        mPlayer.setCallback(new PlayerInterface.Callback() {
            @Override
            public void onWaiting() {
                channel.invokeMethod("onWaiting", null);
            }

            @Override
            public void onCanPlay() {
                channel.invokeMethod("onCanPlay", null);
            }

            @Override
            public void onPlay() {
                channel.invokeMethod("onPlay", null);

            }

            @Override
            public void onPause() {
                channel.invokeMethod("onPause", null);

            }

            @Override
            public void onStop() {
                channel.invokeMethod("onStop", null);

            }

            @Override
            public void onEnded() {
                channel.invokeMethod("onEnded", null);

            }

            @Override
            public void onBufferUpdate(int bufferPercent) {
                channel.invokeMethod("onBufferUpdate", bufferPercent);
            }

            @Override
            public void onTimeUpdate(double position, double duration) {
                channel.invokeMethod("onTimeUpdate", String.format("{\"position\":%f,\"duration\":%f}", position, duration));

            }

            @Override
            public void onError(String msg) {
                channel.invokeMethod("onError", msg);

            }
        });
        channel.setMethodCallHandler(new FlutterMusicPlayerPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "start":
                mPlayer.start((String) call.arguments());
                break;
            case "play":
                mPlayer.play();
                break;
            case "pause":
                mPlayer.pause();
                break;
            case "stop":
                mPlayer.stop();
                break;
            case "seek":
                if (call.arguments() != null) {
                    mPlayer.seek((Double) call.arguments());
                } else {
                    result.error("400", "invalid params", null);
                }
                break;
            case "getState":
                result.success(mPlayer.getState());
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
