# Installation docs

## General guide

1. dd the latest image onto the SD card

1. Copy updated files to the bootstrap partition.  Depending on your OS and
   name of the parition, the path `/Volumes/Untitled` may need to be changed.
   This is the default for macOS, however.

       cp wlansetup.sh snx_autorun.sh /Volumes/Untitled/
       cp -R bootstrap /Volumes/Untitled

1. Copy private WiFi configuration to the SD card:

       cp .private/.wifi* /Volumes/Untitled/
       cp .private/wpa_supplicant.conf /Volumes/Untitled/bootstrap/

1. Turn on the camera and wait a while til the light blinks blue, indicating
   the camera is on.

1. Place the microSD card into the camera and wait for the 'hammer' (tink-tink
   noise from the internal speaker)

1. Get access as root to the camera either via SSH or via telnet. The
   username is `root` and the default password is `ismart12`.

1. Change the root password to something else via `passwd`.

1. Download/replace the following files in the `data` partition:

       IP_ADDRESS=192.168.1.100
       scp data/usr/bin/{fang-ir-control.sh,trigger-alarm,check_rtsp} "root@$IP_ADDRESS:/media/mmcblk0p2/data/usr/bin/"
       scp data/etc/scripts/* "root@$IP_ADDRESS:/media/mmcblk0p2/data/etc/scripts/"
       scp data/usr/bin/{pcm_play-48k,snx_isp_ctl} "root@$IP_ADDRESS:/media/mmcblk0p2/data/usr/bin/"
       scp -r sounds "root@$IP_ADDRESS:/media/mmcblk0p2/"
       scp -r updates "root@$IP_ADDRESS:/media/mmcblk0p2/"

  This adds the requisite binaries for controlling the ISP (Image Signal
  Processor), alarm and adds/disables services according to preferences.
  This also introduces a new `wpa_supplicant` and associated libraries within
  the `updates/` folder (and uses these as part of the `01-network` script
  copied in these steps).


* Expand the SD card (requires reboot and fiddling)
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

Both methods end up writing to the same GPIO pin output for this Sonix chip.

Enable the speaker:

    # Old pin reference
    gpio_ms1 -n 7 -m 1 -v 1
    # New pin reference
    gpio_aud write 1 4 1

Disable the speaker:

    # Old pin reference
    gpio_ms1 -n 7 -m 1 -v 0
    # New pin reference
    gpio_aud write 1 4 0

## SDK

Firstly, obtain the Sonix SDK and setup an Ubuntu machine.
I've set up a machine using Docker and the SDK .tgz is located within the path
`/path/to/host/folder` on the host::

    docker run -v $PWD:/app -it ubuntu:16.04 bash
    dpkg --add-architecture i386 && apt update
    apt install -y sudo

If you're not keen on Docker, then you can run all of the following on a
bare metal machine or other form of VM host (like Virtualbox).

Install the dependencies::

    sudo apt install -y \
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

    sudo rm /bin/sh && sudo ln -s /bin/bash /bin/sh

Extract and configure the SDK:

    tar xf SN986_1.60_QR_Scan_019a_20160606_0951.tgz
    cd SN986_1.60_QR_Scan_019a_20160606_0951
    bash ./sdk.unpack
    # Minor patch for perl error
    sed -i 's/defined(@val)/@val/' snx_sdk/kernel/linux-2.6.35.12/src/kernel/timeconst.pl

    cd snx_sdk/buildscript
    make sn98660_402mhz_sf_defconfig

Compile various parts of the SDK, examples, and so on, and build the final
fil estructure:

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

## Updating wpa_supplicant

These instructions were adapted from
http://wiki.beyondlogic.org/index.php?title=Cross_Compiling_iw_wpa_supplicant_hostapd_rfkill_for_ARM#wpa_supplicant_2
and updated accordingly to use newer library versions and ensure that
`wpa_supplicant` is built from source to incorporate the KRACK patches which
are coming in the as-yet-unreleased v2.7.

Firstly, install and configure the SDK following the instructions above.  You
can stop just before the point of running `make` to compile the entire SDK;
you only need to have configured the SDK and have its toolchain available.
Specifically, you need the `crosstool` compilers and the kernel headers to build the
libraries and software.  This ensures that the same `uClibc` you have on the
camera is the one that you're building against for the new versions of the
libraries and `wpa-supplicant`.  Adjust your `SDK_PATH` below to correspond
to where you set up your SDK.

    export SDK_PATH=/opt/SN986_1.60_QR_Scan_019a_20160606_0951

Install depdenencies and configure environment:

    apt install -y wget
    mkdir -p /opt/build/updates
    cd /opt/build
    export PATH=$PATH:$SDK_PATH/snx_sdk/toolchain/crosstool-4.5.2/bin

Build `libnl`, a depednency of `wpa_supplicant`:

    apt install -y libbison-dev flex
    wget https://www.infradead.org/~tgr/libnl/files/libnl-3.2.25.tar.gz
    tar xf libnl-*.tar.gz
    pushd libnl-*
    ./configure --host=arm-linux --prefix=/opt/build/updates
    make && make install
    popd

Build `openssl` to get `libssl`, a depednency of `wpa_supplicant`:

    wget https://www.openssl.org/source/openssl-1.0.2r.tar.gz
    tar xf openssl-*.tar.gz
    pushd openssl-*
    export ARCH=arm
    export CROSS_COMPILE=arm-linux-
    ./Configure linux-generic32 --prefix=/opt/build/updates
    make && make install
    unset ARCH
    unset CROSS_COMPILE
    popd

Build the latest `wpa_supplicant`:

    apt install -y pkg-config
    wget https://w1.fi/releases/wpa_supplicant-2.7.tar.gz
    tar xf wpa_supplicant-*.tar.gz
    pushd wpa_supplicant-*/wpa_supplicant
    cp defconfig .config
    export PKG_CONFIG_PATH='/opt/build/updates/lib/pkgconfig'
    make CC=arm-linux-gcc EXTRA_CFLAGS='-I /opt/build/updates/include' LDFLAGS='-L /opt/build/updates/lib -ldl'
    make install DESTDIR=/opt/build/updates
    popd
    popd

Now, you have the relevant libraries in `/opt/build/updates/lib` and the
executables in `/opt/build/updates/usr`.  Copy these to your camera:

    IP_ADDRESS=192.168.1.100
    scp -r /opt/build/updates/{lib,usr} "root@$IP_ADDRESS:/media/mmcblk0p2/updates/wpa_supplicant"

And now, on your camera, you will need to run `wpa_supplicant` from this
specific path and by specifying the correct `LD_LIBRARY_PATH` so it can find
the relevant libraries it was built with like so:

    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/media/mmcblk0p2/updates/lib \
        /media/mmcblk0p2/updates/usr/local/sbin/wpa_supplicant

Assuming everything is good to go, you'll see the help text for
`wpa_supplicant` and not an error about missing libraries.  Now, apply the
adjusted `01-network` script into your `data/etc/scripts/` directory (or
adjust your file yourself) and you're good to go.

## Updating RTSP server

A customised RTSP server is available from
https://github.com/davidjb/snx_rtsp_server which adds some additional features
over the built-in version - particularly authentication for RTSP.

Firstly, install and configure the SDK following the instructions above.  You
can stop just before the point of running `make` to compile the entire SDK;
you only need to have configured the SDK and have its toolchain available.
Specifically, you need the `crosstool` compilers and the kernel headers to build the
libraries and software.  This ensures that the same `uClibc` you have on the
camera is the one that you're building against for the new versions of the
libraries and `wpa-supplicant`.  Adjust your `SDK_PATH` below to correspond
to where you set up your SDK.

    export SDK_PATH=/opt/SN986_1.60_QR_Scan_019a_20160606_0951


Build the dependencies and configure build environment:

    cd "$SDK_PATH"
    pushd snx_sdk/buildscript
    make distribute-pre
    make middleware_video middleware_rate_ctl middleware_audio middleware_gpio middleware_common middleware_zbar-0.10 middleware_sdrecord
    popd

Build a customised version of `snx_rtsp_server`:

    apt install -y git
    pushd snx_sdk/app/example/src/ipc_func/
    rm -rf rtsp_server
    git clone https://github.com/davidjb/snx_rtsp_server.git rtsp_server
    pushd rtsp_server
    make && make install

Copy to the camera (create the remote directories if necessary):

    IP_ADDRESS=192.168.1.100
    ssh root@$IP_ADDRESS 'mkdir -p /media/mmcblk0p2/updates/rtsp_server/usr/bin'
    scp -r ../../../../../middleware/_install/lib root@$IP_ADDRESS:/media/mmcblk0p2/updates/rtsp_server
    scp ./snx_rtsp_server root@$IP_ADDRESS:/media/mmcblk0p2/updates/rtsp_server/usr/bin

    popd && popd

On the camera, create a file for authentication credentials on the camera:

    echo 'username:password' > /etc/config/.rtsp_auth

Ensure that the new `20-rtsp-server` script is installed on the SD card and
now you can restart the service.  You should be prompted for auth!

