package com.fsgdesarrollo.fsg_solutions;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import java.util.Locale;
import android.provider.Settings;
import java.util.TimeZone;

import java.text.SimpleDateFormat;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import org.apache.commons.io.FileUtils;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "app.channel.shared.data";


    MethodChannel _channel;
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        Context context = this;
        _channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
   
        _channel.setMethodCallHandler(
                        (call, result) -> {
                             if (call.method.equals("verifyNetworkTimeAndTimeZone")) {
                                result.success(verifyNetworkTimeAndTimeZone());
                            }
                            if (call.method.contentEquals("sendMap")) {
                                Uri gmmIntentUri = Uri.parse(call.argument("ubicacion"));
                                Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                                mapIntent.setPackage("com.google.android.apps.maps");
                                startActivity(mapIntent);
                            }else if (call.method.contentEquals("tomarFoto")) {
                                Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                                if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
                                    startActivityForResult(takePictureIntent, 3);
                                }
                            }else if (call.method.contentEquals("directorioTemporal")) {
                                result.success(context.getCacheDir().toPath().toString());
                            }else if (call.method.contentEquals("BorrarDirectorioTemporal")) {
                                FileUtils.deleteQuietly(context.getCacheDir());
                            }
                        }
                );
    }
    public void onActivityResult(int requestCode, int resultCode, Intent data){
         if(requestCode == 3){
            if (resultCode == RESULT_OK) {
                
                Bundle extras = data.getExtras();
                File fileName = new File(getCacheDir(),"temp");
                Bitmap imageBitmap = (Bitmap) extras.get("data");
                try {
                    FileOutputStream outputStream = new FileOutputStream(String.valueOf(fileName));
                    imageBitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
                    outputStream.close();
                    _channel.invokeMethod("cargarImagenDeCamara", fileName.toPath().toString());
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
     private boolean isUsingNetworkTime() {
        try {
            return Settings.Global.getInt(getContentResolver(), Settings.Global.AUTO_TIME) == 1;
        } catch (Settings.SettingNotFoundException e) {
            //Log.e("MainActivity", "Setting not found", e);
            return false;
        }
    }

    private boolean isTimeZoneGuayaquil() {
        return TimeZone.getDefault().getID().equals("America/Guayaquil");
    }

    private boolean verifyNetworkTimeAndTimeZone() {
        return isUsingNetworkTime() && isTimeZoneGuayaquil();
    }
}
