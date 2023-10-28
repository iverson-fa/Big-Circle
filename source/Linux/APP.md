# Ubuntu20.04最简APP列表

## 1 说明

由于过认证要求安装最少的APP，所以需要将大多数的APP卸载。

但是存在这样的问题：APP显示的名字和package的名字不匹配，通过安装`synaptic`来找到APP对应的package，路径：`edit` ->`search`。

以下记录JP5.1.2/Ubuntu20.04的APP卸载过程

## 2 卸载过程

### 2.1 Klondike

package: aisleriot

This is a collection of over eighty different solitaire card games, including
popular variants such as spider, freecell, klondike, thirteen (pyramid),
yukon, canfield and many more.

### 2.2 Cheese

package: cheese

A webcam application that supports image and video capture. Makes
it easy to take photos and videos of you, your friends, pets or whatever
you want. Allows you to apply fancy visual effects, fine-control image
settings and has features such as Multi-Burst mode, Countdown timer
for photos.

### 2.3 Mines

package: gnome-mines

Mines is a puzzle game where you locate mines floating in an ocean
using only your brain and a little bit of luck.

### 2.4 Mahjongg

package: gnome-mahjongg

This is a solitaire (one player) version of the classic Eastern tile
game, Mahjongg.
You start with five levels of tiles which are stacked so some are
covered up by the tiles on top. The object of Mahjongg is to remove all
the tiles from the game, by finding matching pairs which look alike.

### 2.5 Sudoku

package: gnome-sudoku

This is an application for playing the popular sudoku logic puzzle
game, in which one must fill a 9 by 9 square with the correct digits.
It features automatic puzzle generation, saving and restoring games,
annotations, trackers, and much more.

### 2.5 Onboard

package: onboard

On-screen Keyboard with macros, easy layout creation and word suggestion.
This on-screen keyboard can be useful for tablet PC users, as well as
for mobility impaired users.

### 2.6 firefox

package: firefox

Firefox delivers safe, easy web browsing. A familiar user interface,
enhanced security features including protection from online identity theft,
and integrated search let you get the most out of the web.

### 2.7 libreoffice

```shell
libreoffice-base-core                    (office productivity suite -- shared library)
libreoffice-calc                            (office productivity suite -- spreadsheet)
libreoffice-common               (office productivity suite -- arch-independent files)
libreoffice-core                   (office productivity suite -- arch-dependent files)
libreoffice-draw                                (office productivity suite -- drawing)
libreoffice-gnome                     (office productivity suite -- GNOME integration)
libreoffice-gtk3                     (office productivity suite -- GTK+ 3 integration)
libreoffice-impress                        (office productivity suite -- presentation)
libreoffice-math                        (office productivity suite -- equation editor)
libreoffice-pdfimport  (transitional package for PDF Import component for LibreOffice)
libreoffice-style-breeze            (office productivity suite -- Breeze symbol style)
libreoffice-style-colibre          (office productivity suite -- colibre symbol style)
libreoffice-style-elementary    (office productivity suite -- Elementary symbol style)
libreoffice-style-tango                  (transitional package for Tango symbol style)
libreoffice-writer                       (office productivity suite -- word processor)
```

### 2.8 Remmina

package: remmina

Remmina is a remote desktop client written in GTK+, aiming to be
useful for system administrators and travellers, who need to work
with lots of remote computers in front of either large monitors or
tiny netbooks.
Remmina supports multiple network protocols in an integrated and
consistent user interface.

### 2.9 Rhythmbox

package: rhythmbox

Rhythmbox is a very easy to use music playing and management program
which supports a wide range of audio formats (including mp3 and ogg).
Originally inspired by Apple's iTunes, the current version also supports
Internet Radio, iPod integration and generic portable audio player
support, Audio CD burning, Audio CD playback, music sharing, and
Podcasts.

### 2.10 Totem

Totem is a simple yet featureful media player for GNOME which can read
a large number of file formats.

### 2.11 Thunderbird

package: thunderbird

Thunderbird is a full-featured email, RSS and newsgroup client that makes
emailing safer, faster and easier than ever before. It supports different mail
accounts (POP, IMAP, Gmail), has a simple mail account setup wizard, one-
click address book, tabbed interface, an integrated learning spam filter,
advanced search and indexing capabilities, and offers easy organization
of mails with tagging and virtual folders. It also features unrivalled
extensibility.

### 2.12 Transmission

package: transmission-common

Transmission is a set of lightweight BitTorrent clients (in GUI, CLI
and daemon form). All its incarnations feature a very simple, intuitive
interface on top on an efficient, cross-platform back-end.

### 2.13 Simple-scan

pakcage: simple-scan

Simple Scan is an easy-to-use application, designed to let users
connect their scanner and quickly have the image/document in an
appropriate format.
Simple Scan is basically a frontend for SANE - which is the same
backend as XSANE uses. This means that all existing scanners will
work and the interface is well tested.

### 2.14 xterm

package: xterm

### 2.15 todo

package: gnome-todo

GNOME To Do is a simplistic personal task manager designed to perfectly fit
the GNOME desktop. Designed from ground up to seamlessly integrate with
the GNOME desktop environment, To Do enables you to be as productive as
you want.

### 2.16 shotwell

package: shotwell

Shotwell is a digital photo organizer designed for the GNOME desktop
environment. It allows you to import photos, pictures, images and videos
from disk or camera. Shotwell can organize them in collections and in other
various ways. The viewer shows them in full-window or fullscreen mode and
presents them as galleries or slideshows. The integrated editor can rotate,
flip, crop and tag the photos, adjust the colors und remove red eyes. Export
is possible to facebook, Flickr or Youtube to share with others. It is able
to manage a lot of image formats such as JPEG, PNG, BMP, TIFF and Raw CR2.

## 3 最终APP列表

```shell
sudo apt remove --purge aisleriot gnome-mines gnome-sudoku cheese onboard firefox libreoffice-base-core libreoffice-draw remmina rhythmbox thunderbird transmission-common simple-scan xterm gnome-todo shotwell gnome-mahjongg python3-software-properties python3-update-manager
```

```shell
# /usr/share/applications
mv org.gnome.PowerStats.desktop org.gnome.PowerStats.desktop.bak
mv xfce4-dict.desktop xfce4-dict.desktop.bak
mv thunar-bulk-rename.desktop thunar-bulk-rename.desktop.bak
mv org.gnome.Characters.desktop org.gnome.Characters.desktop.bak
mv light-locker-settings.desktop light-locker-settings.desktop.bak
mv org.gnome.DejaDup.desktop org.gnome.DejaDup.desktop.bak
mv pavucontrol.desktop pavucontrol.desktop.bak
mv thunar.desktop thunar.desktop.bak
mv thunar-settings.desktop thunar-settings.desktop.bak
mv thunar-volman-settings.desktop thunar-volman-settings.desktop.bak
mv xfce4-appfinder.desktop xfce4-appfinder.desktop.bak
mv org.gnome.FileRoller.desktop org.gnome.FileRoller.desktop.bak
mv org.gnome.Calculator.desktop org.gnome.Calculator.desktop.bak
mv xfce4-clipman.desktop xfce4-clipman.desktop.bak
mv org.gnome.font-viewer.desktop org.gnome.font-viewer.desktop.bak
mv org.gnome.Logs.desktop org.gnome.Logs.desktop.bak
mv org.gnome.Evince.desktop org.gnome.Evince.desktop.bak
mv org.gnome.eog.desktop org.gnome.eog.desktop.bak
mv xfce4-sensors.desktop xfce4-sensors.desktop.bak
mv xfburn.desktop  xfburn.desktop.bak
mv org.gnome.Totem.desktop org.gnome.Totem.desktop.bak
mv ristretto.desktop ristretto.desktop.bak
mv vim.desktop vim.desktop.bak
mv xfce4-terminal.desktop xfce4-terminal.desktop.bak
mv org.gnome.Calendar.desktop org.gnome.Calendar.desktop.bak
mv gnome-language-selector.desktop gnome-language-selector.desktop.bak
mv mousepad.desktop mousepad.desktop.bak
mv org.gnome.Screenshot.desktop org.gnome.Screenshot.desktop.bak
mv xfce4-screenshooter.desktop xfce4-screenshooter.desktop.bak
mv oem-config-prepare-gtk.desktop oem-config-prepare-gtk.desktop.bak
mv gnome-session-properties.desktop gnome-session-properties.desktop.bak
mv org.gnome.seahorse.Application.desktop org.gnome.seahorse.Application.desktop.bak
```
最终的列表：
- Disks
- Disk Usage Analyzer
- Files
- Help
- Settings
- System Monitor
- Task Manager
- Terminal
- Text Editor
