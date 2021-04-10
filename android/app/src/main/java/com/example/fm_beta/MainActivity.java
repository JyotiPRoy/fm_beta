package com.example.fm_beta;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Environment;
import android.os.StatFs;
import android.provider.MediaStore;
import android.provider.MediaStore.Images.Thumbnails;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.content.FileProvider;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.fm_beta";
    Context context = this;

    @RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if(call.method.equals("getSDFreeSpace")){
                                result.success(getSDFreeSpace());
                            }else if(call.method.equals("getSDTotalSpace")){
                                result.success(getSDTotalSpace());
                            }else if(call.method.equals("getExternalSDTotalSpace")){
                                if (VERSION.SDK_INT >= VERSION_CODES.KITKAT) {
                                    result.success(getExternalSDTotalSpace());
                                }
                            }else if(call.method.equals("getExternalSDFreeSpace")){
                                if (VERSION.SDK_INT >= VERSION_CODES.KITKAT) {
                                    result.success(getExternalSDFreeSpace());
                                }
                            }else if(call.method.equals("openFile")){
                                result.success(openFile(call.argument("data"), call.argument("mimeType")));
                            }else if(call.method.equals("share")){
                                result.success(share(call.argument("data"), call.argument("dataList"), call.argument("mimeType")));
                            }else if(call.method.equals("getThumbnail")){
                                result.success(getThumbnail(call.argument("path"), call.argument("thumbnailPath")));
                            }
                        }
                );
    }

    @RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
    private Long getSDFreeSpace(){
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getAbsolutePath());
        return stat.getAvailableBytes();
    }

    @RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
    private Long getSDTotalSpace(){
        File path = Environment.getDataDirectory();
        StatFs stat = new StatFs(path.getAbsolutePath());
        return stat.getTotalBytes();
    }

    @RequiresApi(api = VERSION_CODES.KITKAT)
    private Long getExternalSDFreeSpace(){
        File[] dirs = getExternalFilesDirs(null);
        StatFs stat = new StatFs(dirs[1].getAbsolutePath().split("Android")[0]);
        return stat.getAvailableBytes();
    }

    @RequiresApi(api = VERSION_CODES.KITKAT)
    private Long getExternalSDTotalSpace(){
        File[] dirs = getExternalFilesDirs(null);
        StatFs stat = new StatFs(dirs[1].getAbsolutePath().split("Android")[0]);
        return stat.getTotalBytes();
    }

    private boolean openFile(String uri, String mimeT){
        File file =  new File(uri);
        Uri fileUri = FileProvider.getUriForFile(context, context.getPackageName() + ".provider", file);
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(fileUri, mimeT);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
        context.startActivity(intent);
        return true;
    }

    @RequiresApi(api = VERSION_CODES.JELLY_BEAN_MR2)
    private boolean share(String path, ArrayList<String> pathList, String mimeT){
        Log.v("INFO", "PATH: " + path);
        Log.println(Log.INFO, "INFO", "PATH: " + path);
        if(path != null){
            File shareFile = new File(path);
            Uri shareFileUri = FileProvider.getUriForFile(context, context.getPackageName() + ".provider", shareFile);
            Intent share = new Intent(Intent.ACTION_SEND);
            share.setType(mimeT);
            share.putExtra(Intent.EXTRA_STREAM, shareFileUri);
            context.startActivity(share);
        }else if(pathList != null && !pathList.isEmpty()){
            ArrayList<Uri> shareUris = new ArrayList<>();
            for(String filePath : pathList){
                File file = new File(filePath);
                Uri uri = FileProvider.getUriForFile(context, context.getPackageName() + ".provider", file);
                shareUris.add(uri);
            }
            Intent shareMultiple = new Intent(Intent.ACTION_SEND_MULTIPLE);
            shareMultiple.setType("*/*");
            shareMultiple.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
            shareMultiple.putExtra(Intent.EXTRA_STREAM, shareUris);
            shareMultiple.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            context.startActivity(shareMultiple);
        }
        return true;
    }

    private int getScaledWidth(int height, int width, int reqHeight){
        return (int) (width * (reqHeight/height));
    }

    // From Android Developers site
    public static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;
        if (height > reqHeight || width > reqWidth) {
            final int halfHeight = height / 2;
            final int halfWidth = width / 2;
            while ((halfHeight / inSampleSize) >= reqHeight
                    && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }
        return inSampleSize;
    }

    private String getThumbnail(String path, String thumbnailPath){
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, options);
        options.inSampleSize = calculateInSampleSize(options, getScaledWidth(options.outHeight, options.outWidth, 64), 64);
        options.inJustDecodeBounds = false;
        Bitmap rawThumbnail =  BitmapFactory.decodeFile(path, options);
        File thumbnail = new File(thumbnailPath);
        try{
            FileOutputStream fos = new FileOutputStream(thumbnail);
            rawThumbnail.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.close();
        }catch(FileNotFoundException fexcp){
            Log.d("ERROR", fexcp.toString());
        }catch(IOException ioexcp){
            Log.d("ERROR", ioexcp.toString());
        }
        return thumbnailPath; // It's silly but can't use a void function here
    }
}
