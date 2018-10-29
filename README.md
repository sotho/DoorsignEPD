# Walldisplay

Based on a c't project, see https://github.com/jamct/DoorsignEPD and https://ct.de/yrzv

We use it for our family calendars (first display) and a TODO list (second
display). The calendars and the TODO list are hosted at google and can be edited
with our smartphones or the web frontend.

The wall display just shows the rendered version of our calendars / TODO list,
no editing possible. The rendering is done on a local NAS.

# Hardware

Here is what I used (for one display):

* Ikea picture frame, RIBBA, 13cmx18cm, https://www.ikea.com/de/de/catalog/products/70378414/#/50378410,
  ~2 €
* Display: 7.5inch E-Ink display HAT 640x384 E-paper Module Black White Two-color SPI No Backlight for Raspberry Pi 2B/3B/3B+/Zero/Zero W
  from: https://www.aliexpress.com/item/7-5inch-E-Ink-display-HAT-640x384-E-paper-Module-Black-White-Two-color-SPI-No/32831829309.html?spm=a2g0s.9042311.0.0.6a264c4dz7ARx8
  ~50 €
* Arduino: Mini D1 ESP32 ESP-32 ESP-32S ESP32S Module Wifi Bluetooth Wireless Board Based Dual Core Mode CPU Micro USB Interface
  from: https://www.aliexpress.com/item/10Pin-Convert-To-Standard-6-Pin-Adapter-Board-For-ATMEL-STK500-AVRISP-USBASP/1859124621.html?spm=a2g0s.9042311.0.0.6a264c4dz7ARx8
  ~7 €
* Battery Case, e.g New Plastic 18650 Battery Case Holder Storage Box with Wire Leads for 18650 Batteries 3.7V Black
  from: https://www.aliexpress.com/item/New-Plastic-18650-Battery-Case-Holder-Storage-Box-with-Wire-Leads-for-18650-Batteries-3-7V/32658520557.html?spm=a2g0s.9042311.0.0.6a264c4dz7ARx8
  <1 €
* Batteries (at least one), e.g. Advanced 2018 New Consumer Electronics Battery 1PCS 3.7V 3500mAH Li-ion Rechargeable 18650 Battery For Flashlight Torch
  from: https://www.aliexpress.com/item/Advanced-2018-New-Consumer-Electronics-Battery-1PCS-3-7V-3500mAH-Li-ion-Rechargeable-18650-Battery-For/32832001193.html?spm=a2g0s.9042311.0.0.27424c4dpTtWHO
  ~2 €

When battery is empty:

* A charger, e.g. Smart LCD Battery Charger Smart USB Charger for 26650 18650 18500 18350 17670 14500 10440 lithium battery
  from: https://www.aliexpress.com/item/Smart-LCD-Battery-Charger-Smart-USB-Charger-for-26650-18650-18500-18350-17670-16340-14500-10440/32741436953.html?spm=a2g0s.9042311.0.0.6a264c4dz7ARx8
  ~10 €

To assemble:

* Soldering station, e.g. https://www.amazon.de/gp/product/B071HTXYR8/ref=oh_aui_search_detailpage?ie=UTF8&psc=1
  to solder the battery case cables on the arduino
* knife / cutter: to cut the cardboard of the picture frame to make it the proper size for the display
* two-sided adhesive tape: to glue the display onto the cardboard (from behind)

# Software

## Arduino

The arduino software is in esp32/doorsignEPD/doorsignEPD.ino, you need the
arduino IDE and a few libraries to compile it and flash it on the arduino.

What I changed (compared with the original c't project):

* I added an ID (first byte) to the raw picture served by the NAS. The ID is
  never 0. When the arduino first starts it initializes its ID with 0. When the
  ID doesn't match (on first boot it never matches), then the e-ink display is
  updated. The ID from the raw picture is stored and the arduino goes into deep
  sleep. On next wake-up the raw picture is downloaded and the ID is compared
  with the stored ID. Only if it has changed the display is updated. This should
  safe a bit of power and avoids this annoying flickering for several seconds
  whenever possible.
* Align wake-up from deep sleep to full or half hour (xx:00 or xx:30).
* Deep sleep is at most 30 minutes. I tried 60 minutes, but then my arduino
  never wakes up; no idea why.

## Server

apache with python module is serving the pre-rendered raw picture. The picture
is created by a systemd-service triggered by a systemd-timer.

These files/directories are needed:

* /var/www/html/board: here the raw images are stored. Owned by www-data:www-data.
* /etc/apache2/sites-available/000-default.conf: contains definition for board directory
* /var/www/html/board/index.py: serves the raw image depending on source IP of
  the display (less configuration on arduino)
* /usr/local/bin/board: The script the creates raw images.
* /usr/local/share/board/client_secret.json: The API IDs the client software
  needs; you can create your own as a developer. The tutorials of the google
  API for calendar describes how to do that.
* /var/www/.config/myBoard/credentials-myboard.json: The credentials for the
  google account that shall be used for calendar and TODO list. To create this
  file call /usr/local/bin/board as a normal user; then it opens an URL in your
  browser and you can confirm the permissions (read-only calendar and TODO-list)
  for your google account. Copy that file from ~/.config/myBoard/credentials-myboard.json
* /etc/systemd/system/board.service: The systemd service to run /usr/local/bin/board
* /etc/systemd/system/board.timer: The systemd timer to run the board.service
  every 30 minutes.
* init.sls: A salt state file how to deploy these files and install dependencies, etc.

Dependencies:

* apache2
* libapache2-mod-python
* python-pip
* python3-pip
* python3-pil
* fonts-liberation
* python3-tz
* ttf-mscorefonts-installer

(some might no longer be needed)

For the google API we don't have a debian package, use: pip3 install google-api-python-client

* Adapt /var/www/html/board/index.py to map your local arduino IP to an raw image
* Adapt /usr/local/bin/board
 * calendarIdMap: mapping of calendar IDs to a short symbol (not rendered, because we didn't like it).
 * BLACKLIST_CAL_ID: never use calendars with these short symbols. We didn't
   want birthdays from contacts and the calendar week.

