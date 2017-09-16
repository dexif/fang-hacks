# Installation docs

## General guide

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


## Restoring a copy of an SD card on Mac

From http://hints.macworld.com/article.php?story=2009041216314856:

    hdid -nomount "fang-sd-card.dmg"
    diskutil list
    sudo dd if=/dev/disk4 of=/dev/disk2 bs=1M


## Accessing the RTSP stream

Use the URL:

    rtsp://device-ip/unicast


## Enabling cron

Create the crontabs directories:

    mkdir -p /var/spool/cron/crontabs
    crontab -e
    # Now make your changes...

Now on boot, start `crond` to run the daemon.


## Speaker

Enable the speaker:

    gpio_ms1 -n 7 -m 1 -v 1

Disable the speaker:

    gpio_ms1 -n 7 -m 1 -v 0


## SDK

Firstly, obtain the Sonix SDK and setup an Ubuntu 17.04 machine.
I've set up a machine using Docker::

    docker run -it ubuntu:17.04 bash
    apt-get install -y sudo

If you're not keen on Docker, then you can run all of the following on a
bare metal machine or other form of VM host (like Virtualbox).

Install the dependencies::

    sudo dpkg --add-architecture i386
    sudo apt-get install -y \
      bash \
      gcc \
      make \
      patch \
      libencode-detect-perl \
      libdigest-crc-perl \
      libncurses-dev \
      libz-dev:i386 \
      cpio \
      lzma \
      lzop

Reconfigure your default `/bin/sh` if required.  The scripts have shebangs
that actually require `bash` but declare `/bin/sh`::

    rm /bin/sh && ln -s /bin/bash /bin/sh

Extract and compile the SDK:

    tar xf SN986_1.60_QR_Scan_019a_20160606_0951.tgz
    cd SN986_1.60_QR_Scan_019a_20160606_0951
    bash ./sdk.unpack
    # Minor patch for perl error
    sed -i 's/defined(@val)/@val/' snx_sdk/kernel/linux-2.6.35.12/src/kernel/timeconst.pl

    cd snx_sdk/buildscript
    make sn98660_402mhz_sf_defconfig

    make
    make ez-setup

At this point, executable objects have been compiled and can be extracted
to copy to your device.  For example, to play sounds you can use
`snx_sdk/app/ez-setup/rootfs/usr/bin/pcm_play`. There are many more similar
examples and utilities available elsewhere in the directory tree.

To list all modules (eg in case you want to recompile just part of the setup):

    make showmodules
    make [module name from previous output]

To optionally build the firmware and fileystem images, you can run::

    make install

