
1. Format SDCard like in wiki (vfat + ext2)

2. Download this source code + i dont want to use Mi Home app, so i will
   download this too and copy it to rest of the source code #132, edit both
   dot files (wifi password and ESSID)

3. Copy bootstrap folder, snx_autorun.sh, wlansetup.sh, .wifipasswd, .wifissid
   to vfat partition

4. Copy data folder to ext2 partition

5. Put SDCard in camera, power on camera. Camera will start blink blue after
   few seconds (if wifi connection is ok)

6. Power off camera and REMOVE sdcard

7. Power on camera without sdcard, wait to wifi connection (now its
   configured) till blue light blinks

8. After blue that, put sdcard inside camera, wait till sound "klink klink".
   Go to the http://ip/cgi-bin/status and click Apply.

