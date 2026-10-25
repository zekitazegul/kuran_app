package com.zekitazegul.kuranapp;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

/** System-only test runner, with no dependencies on classes removed from a release APK. */
public final class UpdateTestInstrumentation extends Instrumentation {
    @Override public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        start();
    }
    @Override public void onStart() {
        final MainActivity activity = (MainActivity) startActivitySync(
            new Intent(getTargetContext(), MainActivity.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
        File directory = new File(activity.getCacheDir(), "updates"); directory.mkdirs();
        final File apk = new File(directory, "verified-update-test.apk");
        try {
            android.content.SharedPreferences oldSession = activity.getSharedPreferences("update-install-session", 0);
            int oldId = oldSession.getInt("id", -1);
            if (oldId >= 0) {
                try { activity.getPackageManager().getPackageInstaller().abandonSession(oldId); }
                catch (Exception ignored) { }
                oldSession.edit().clear().commit();
            }
            InputStream input = getContext().getAssets().open("upgrade.apk");
            FileOutputStream output = new FileOutputStream(apk);
            byte[] buffer = new byte[65536];
            int count;
            while ((count = input.read(buffer)) >= 0) output.write(buffer, 0, count);
            output.close(); input.close();
            runOnMainSync(() -> activity.installUpdate(apk));
            Bundle result = new Bundle();
            result.putString("result", "Android installer opened");
            finish(Activity.RESULT_OK, result);
        } catch (Exception error) {
            Bundle result = new Bundle(); result.putString("error", error.toString());
            finish(Activity.RESULT_CANCELED, result);
        }
    }
}
