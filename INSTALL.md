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

---

1. dd the latest image onto the SD card

2. Copy updated files to the bootstrap partition:

       cp wlansetup.sh snx_autorun.sh .wifi* /Volumes/Untitled/
       cp -R bootstrap /Volumes/Untitled
       cp wpa_supplicant.conf /Volumes/Untitled/bootstrap/

3. Turn on the camera and wait a while til the light blinks blue, indicating
   the camera is on.

3. Place the microSD card into the camera and wait for the 'hammer' (tink-tink
   noise from the internal speaker)

4. Get access as root to the camera either via SSH or via telnet.

5. Change the root password to something else via `passwd`.

6. Download/replace the following files in the `data` partition:

   wget http://0.0.0.0:8000/data/usr/bin/fang-ir-control.sh -O data/usr/bin/fang-ir-control.sh
   wget http://0.0.0.0:8000/data/etc/scripts/01-network -O data/etc/scripts/01-network
   wget http://0.0.0.0:8000/data/etc/scripts/30-status-led -O data/etc/scripts/30-status-led
   chmod 755 data/etc/scripts/30-status-led

* Expand the SD card (requires reboot and fiddling)
* Ensure ftpd and telnetd are both disabled entirely. All other services to be
enabled.
* Change the network mode to Client (requires reboot and potentially lots of
fiddling with the wpa_supplicant.conf file)
* Set the TZ to `EST-10` and hostname to `XiaoFang-Cam-X`
* Disable Cloud Applications once boot has been assured several times
(including after hard power down)

---


    killall wpa_supplicant && wpa_supplicant -B -i wlan0 -c /tmp/wpa_supplicant.conf

    killall wpa_supplicant && ps | grep wpa && wpa_supplicant -Dwext -B -i wlan0 -c /media/mmcblk0p2/data/etc/wpa_supplicant.conf

    cd /media/mmcblk0p2/data/etc/

    rtsp://192.168.1.111/unicast

killall wpa_supplicant && wpa_supplicant -d -i wlan0 -c test-no-quotes.conf > wpa.log
killall wpa_supplicant && wpa_supplicant -d -i wlan0 -c test-quotes.conf > wpa-quotes.log
---

## Restoring a copy of an SD card on Mac

From http://hints.macworld.com/article.php?story=2009041216314856:

    hdid -nomount "fang-sd-card.dmg"
    diskutil list
    sudo dd if=/dev/disk4 of=/dev/disk2 bs=1M


## Speaker

Enable the speaker:

    gpio_ms1 -n 7 -m 1 -v 1

Disable the speaker:

    gpio_ms1 -n 7 -m 1 -v 0


## SDK

    sudo dpkg --add-architecture i386
    sudo apt-get install -y gcc libencode-detect-perl lzop ncurses-dev:i386 gcc-arm-linux-gnueabi:i386 libz-dev:i386
    tar xf SDK.tgz

