# Retain the installation entry point for signed on-device release verification.
-keepclassmembers class com.zekitazegul.kuranapp.MainActivity {
    public void installUpdate(java.io.File);
}
