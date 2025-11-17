# Curated Builder – Unsigned macOS Build Instructions

This build is **not signed or notarized**. macOS Gatekeeper will block it after download. Follow these steps to launch it anyway.

## macOS install steps
1) Open the DMG and drag `Curated Builder.app` into `/Applications`.
2) Try to open it once. macOS will show “Curated Builder is damaged and can’t be opened.”
3) Open **System Settings → Privacy & Security**. You should see “Curated Builder was blocked from use” with an **Open Anyway** button. Click it, then confirm in the next dialog. The app will launch.

### If “Open Anyway” does not appear
Use Terminal to remove the quarantine flag manually:

```bash
sudo xattr -dr com.apple.quarantine "/Applications/Curated Builder.app"
open "/Applications/Curated Builder.app"
```

You must repeat the quarantine removal for each new download.

## Why this happens
Gatekeeper trusts apps signed with an Apple Developer ID certificate. Because this build is unsigned/un-notarized, macOS labels it as “damaged” and blocks it until you explicitly allow it.

## Windows install steps
1) Run the installer: `Curated Builder Setup.exe`.
2) If Windows SmartScreen warns, click **More info** and then **Run anyway**.
3) Follow the installer prompts to finish.

SmartScreen flags unsigned apps. Because this build is not code-signed, you must approve it manually the first time





OR PAY ME AND WE CAN REMOVE THIS!!!!