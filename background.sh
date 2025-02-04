#!/bin/bash
cp background.svg /usr/share/desktop-base/emerald-theme/wallpaper/contents/images/
cp /usr/share/images/desktop-base/desktop-background.xml /usr/share/images/desktop-base/desktop-background.xml.bak
echo "
<background>
  <static>
    <duration>8640000.0</duration>
    <file>
      <size width="1280" height="800">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size>
      <size width="1280" height="1024">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size>
      <size width="1600" height="1200">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="1920" height="1080">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="1920" height="1200">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="2560" height="1440">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="2560" height="1600">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="3200" height="1800">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="3200" height="2000">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="3840" height="2160">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
      <size width="5120" height="2880">/usr/share/desktop-base/emerald-theme/wallpaper/contents/images/background.svg</size></size>
    </file>
  </static>
</background>" > /usr/share/images/desktop-base/desktop-background.xml