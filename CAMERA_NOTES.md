## Hardware specs

* Sonix SN98660(AFG)

## Image Signal Processing (ISP) interface

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
