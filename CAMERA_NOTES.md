## Hardware

* Sonix SN98660(AFG)
* USB Devices:
  * Bus 001 Device 001: ID 1d6b:0002 (Linux Foundation USB 2.0 Root Hubjj)
  * Bus 001 Device 002: ID 0bda:0179 (RTL8188ETV Wireless LAN 802.11n Network Adapter)

### Hacks

* 360-degree rotation: remove the base of the camera (two screws at base plus
there are 4 plastic clips) and look at how the rotation occurs.  You'll notice
a plastic tab that prevents 360-degree rotation.  I used a pair of scissors to
slightly trim this tab so then rotation occurs unhindered.
* Improved base stability: the camera's base (the "leg") tended to be quite
flimsy and not want to stay up if extended.  To fix this, there are two screws
to tighten -- one is exposed near the rotating base, closest to the camera and
the other is inside the grey base.  To get to this, remove the 4 rubber pads
on the bottom, remove the screws under each, and the base will open.  Tighten
both "leg" screws as far as possible and re-piece the camera back together.

## Terminology

* ISP: Image Signal Processing
* OSD: On Screen Display
* MD: Motion Detection
* PM: Private Mask (ability to hide part of the image)
* AE: Auto Exposure
* AWB: Auto White Balance
* M2M: Memory to Memory middleware pathway
* DRC: Dynamic Range Control (?)
* IQ: ?? (Image Quality?)
  * NRA: ?
  * NRN: ?

## Image Signal Processing (ISP) interface

Most configuration can be carried out by the `snx_isp_ctl` application.
Otherwise, it is possible to use the file descriptor interface for most
common aspects of the configuration.

### Adjust output image

Some of these aspects such as gamma severely affect the visible content and if
tweaked correctly can greatly improve the image. The values shown are the
defaults noted on my camera with my specific version.

    echo 0x40 > /proc/isp/filter/brightness
    echo 0x20 > /proc/isp/filter/contrast
    echo 0x64 > /proc/isp/filter/gamma
    echo 0x0 > /proc/isp/filter/hue
    echo 0x40 > /proc/isp/filter/saturation

The `sharpness` filter doesn't seem to have any effect if changed directly.

    echo 0x3 > /proc/isp/filter/sharpness

### Mirror horizontally

    echo 0x1 > /proc/isp/sensor/mirror
    echo 0x0 > /proc/isp/sensor/mirror

### Flip vertically

    echo 0x1 > /proc/isp/sensor/flip
    echo 0x0 > /proc/isp/sensor/flip

### Frame control

ISP Dropping frames

    echo 0 > /proc/isp/ae/fps_ctrl

Use Automatic Exposure (AE) exposure time to output average fps

    echo 1 > /proc/isp/ae/fps_ctrl

Enable DRC (unknown what this does at this stage; dynamic range control?)

    echo 0x1 > /proc/isp/drc/enable
    echo 0x0 > /proc/isp/drc/enable
