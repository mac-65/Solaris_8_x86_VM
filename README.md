<a name="top00"></a>![Guide](./svgs/mainTitle.svg)<br>

This (hobby) project list the steps that I've used to build a Solaris 8 x86 virtual machine in VirtualBox.
This guide was built from a number of sources that provided pieces of the puzzle, but not the complete picture
of installing Solaris 8 x86 in VirtualBox.

# Contents
* [Introduction](#introduction)
* [Disclaimer](#disclaimer)
* [System Requirements](#system-requirements)
* [Getting Started](#getting-started)
* [VirtualBox](#virtualbox-configuration)
* [Installing: First Boot](#installing-first-boot)
 * [Video Device Selection](#video-device-selection)
 * [Solaris Install Console](#solaris-install-console)
 * [Select Name Serice](#select-name-service)
 * [Setting the Time Zone](#select-time-zone)
* [Solaris Interactive Install](#interactive-install)
 * [Select Software](#select-software)

## Introduction
I've spent many years developing software in the Sun SPARC architecture,
first on the [SPARCstation 1](https://en.wikipedia.org/wiki/SPARCstation_1) (Sun 4/60)
up through the [Sun Ultra](https://en.wikipedia.org/wiki/Sun_Ultra_series) 1 and 2.
Those Sun systems were my first real taste of Unix and 32-bit computing.
I remember that a [SPARCstation IPX](https://en.wikipedia.org/wiki/SPARCstation_IPX) was
not fast enough to decode mp3 files and 1152x900 8-bit color was state-of-the-art graphics
(yes there were 24-bit cards available, e.g. <code>cgtwelve</code>, but they were expensive
and very slow and not all of the software supported the 24 bit visuals).<br>
There's some interesting reading about framebuffers [here](http://www.sunhelp.org/faq/FrameBuffer.html).


Once in a while, I need to do something in this olde OS, and
using a virtual machine makes it easy.
But, building the virtual machine had its challenges from:
* finding installable ISO images,
* finding recommended patches,
* finding pre-built packages, and
* "fixing" things that seemed to have been broken in the original OS and the patches.

The process took longer than I expected
but after getting things to actually work was pretty satisfying and fun.

#### Not Covered In This Guide
* <strong>Graphics beyond VGA/SVGA</strong> (640x480 or 800×600 4-bit color depth)<br>
Looks like it may be possible (and may be non-trivial).<br>
I just haven't looked into it yet; probably ties in with Guest Additions.
<!-- https://docs.oracle.com/cd/E97728_01/F12469/html/adv-config-linux-guest.html -->
* <strong>Guest Additions:</strong><br>
Shared clipboard, drag and drop, seamless mode, shared folders from host system, and theoretically better graphics<br>
I haven't looked into it at all.

#### Acknowledgements and Attribution
I searched many dozens of sites for answers, the major sites are listed in
these steps, TODO

<a name="disclaimer"></a>
## <span style="text-align:left;">Disclaimer<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
![Software is provided "as is" and "with all faults."](./svgs/disclaimer.svg)
THE AUTHOR makes no representations or warranties of any kind concerning the safety, suitability,
lack of viruses, inaccuracies, typographical errors, or other harmful components of SOFTWARE in this guide.
There are inherent risks and dangers in the use of any software, and you are solely responsible for determining
whether this SOFTWARE in this guide is compatible with your equipment and other software installed on your equipment.
You are also solely responsible for the protection of your equipment and the backup of your data,
and THE AUTHOR will not be liable for any damages you may suffer in connection with using,
modifying, or distributing this SOFTWARE in this guide.<br>

:boom: There are likely <i>many</i> bugs, errors, incomplete and missing features and documentation.

<a name="system-requirements"></a>
# <span style="text-align:left;">System Requirements<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>

### RPMFusion VirtualBox

* The VirtualBox version is <code>4.3.32-1</code> (rpmfusion-free on <code>Fedora 21 x86_64, 4.1.13-100.fc21.x86_64</code>).<br>
I've had later versions of VirtualBox crash and burn with some VMs I've built in the past.
It's a problem because as far as I know, it's not possible to <strong>easily</strong> have multiple versions of VirtualBox
installed on the same machine (like you can do with the gcc compiler collection, e.g.).
There might be a way, but I haven't tried it and this version runs all of my VMs fine
(although the creature comforts added in later versions are nice, but the VMs
don't work).


### Solaris 8 x86
* The Solaris 8 x86 ISOs are available on [archive.org](https://archive.org/download/sol-8-u7-ia).<br><br>
![sample](./images/Solaris_8-availability.png)<br>
You should download all of the Solaris 8 x86 ISO images:<br>

| :cd: Filename    | md5sum | :notebook: Notes |
| :----            | :----:       | ---- |
| <code>sol-8-u7-ia-v1.iso</code>      | <code>c243aa080e4c503f60cca48a8fd54e47</code> | Boot with this image |
| <code>sol-8-u7-ia-v2.iso</code>      | <code>6c63bcbbf9e92ed946f1435f6bb89e5f</code> | 2nd install image |
| <code>sol-8-u7-lang-ia.iso</code>    | <code>6164e7e2d24f2291689f2b1f82fccc0b</code> | Optional languages image |
| <code>sol-8-u7-install-ia.iso</code> | <code>91029b86d9eb130a73d83e7a67a817df</code> | This ISO image is<br>not used in these steps. |

* These ISOs can build a Solaris installation with the following characteristics
after all of the steps have been performed in this guide (from <code>/etc/release</code>):<br><br>
![Solaris 8 2/02 s28x_u7wos_08a INTEL](./images/Solaris-8-x86-Desktop.png)<br>

Everything up to this point (and following these steps) will allow you to build a working
Solaris 8 x86 virtual machine.
Networking should be fine (manual steps are necessary to configure the network).
If you've selected <strong>SoundBlaster 16</strong> as the Audio Controller in VirtualBox,
you can listen to that nostalgic Sun cowbell sound
(<code>cat /usr/demo/SOUNDS/sounds/cowbell.au > /dev/audio</code>) once again.
But you'll be missing many tools that are taken for granted in a modern Linux system, for example:
* a C compiler (Solaris 8 did <strong>not</strong> even ship with the K&R C compiler),
* the ssh suite (the pseudo-devices <code>/dev/random</code> and <code>/dev/urandom</code> do not exist), and of course
* the lack of any of the <i>modern</i> tools, e.g. <strong>openssl</strong>, <strong>openssh</strong>,
and <strong>gnu</strong> tools are a notable examples.


### Solaris 8 x86 Recommended Patch Cluster(s) & 112439-02
Sadly http://sunsolve.sun.com [sic] no longer exists, and finding patches can be difficult.
While it's nicest to apply all of the recommended patches, the most important patch is <strong>112439-02</strong>
which provides the pseudo-devices <code>/dev/random</code> and <code>/dev/urandom</code>.

It's best if you're able to find the
[Solaris 8 x86 recommended patch cluster](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/8_x86_Recommended.zip)
and install the cluster for best results.

Next, either find and install the patch
[112439-02](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/112439-02.zip).
That patch is also included in the
[J2SE Solaris 8 x86 recommended patch cluster](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/J2SE_Solaris_8_x86_Recommended.zip)
if you want to install that cluster in addition to the regular recommended patch cluster.


### Pre-compiled Solaris 8_x86 Binaries
This is really a deal breaker for a usable system if you're unable to find any prebuilt packages.<br>
Fortunately, [tgcware](http://jupiterrise.com/tgcware/)
is there to the [rescue](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/)!
I can't stress enough what a tremendous help and time-saver this was.
There's a good selection of tools assembled (with various versions of some of the tools) and
each package that was prebuilt is listed with its name, brief description, and its <code>md5sum</code> checksum.
<br>
This guide includes a simple script for getting the prebuilt binaries from [tgcware](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/).


<a name="getting-started">
# </a><span style="text-align:left;">Getting Started<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
This guide includes some package install scripts to help smooth the process
and perform some task that are minor enhancements or missing in the original.
It is recommended that you review each script and make any changes suited to
your particular environment or needs.  The scripts are named as <code>001-gzip.sh</code>, etc.,
so that <code>ls 0\*.sh</code> will list all of the scripts.


#### 1. Download the ISOs
Use your browser or use <code>wget</code> to get the ISOs, e.g.<br>
* <code>wget -c https://archive.org/download/sol-8-u7-ia/sol-8-u7-ia-v1.iso</code>

#### 2. Download the Solaris 8 x86 Recommended Patch Cluster(s)
After you have downloaded the necessary
[cluster patch](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/8_x86_Recommended.zip)
and [112439-02](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/112439-02.zip),
make a copy of the files and uncompress all of the files.
It will make the process easier and the install scripts provided assume that the packages are uncompressed.

#### 3. Download the <code>tgcware</code> Packages
This guide provides a simple installation script for acquiring the pre-built packages
from [tgcware](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/).
* Run the script <code>get_tgcware.sh -h</code> for usage instructions.

The packages selected are meant as a starting point to build the
Solaris 8 x86 box with a sane configuration: e.g. bash, vim, gcc, and openssl/openssh suite
are installed with some other basic tools.
<br>But, please feel free to change anything to your specific requirements/tastes.

All of the packages from [tgcware](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/) are <code>.gz</code> files
<i>except</i> for the [gzip](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/gzip-1.6-1.tgc-sunos5.8-i386-tgcware) package
(for obvious reasons).
<br>Like with the patch files, copy and uncompress all of the pre-built software files.

#### 4. Review the <code>bashrc</code> and <code>vimrc</code> . File Templates and <code>0\*.sh</code> Scripts
I've include some of my simple shell and vim hacks to get things started.
<br>Put a copy of those files in the same location as all of the other files and
the <code>0\*.sh</code> scripts as well.

#### 5. Building the "tools" :cd:
I decided, after a few install iterations, the easiest thing to do was to 
create a CD ISO image containing all of the packages and scripts used to build the system.
I emphasize a CD volume because I'm not sure if Solaris 8 "knows" about DVD file systems;
if it can, then use whatever format you want (although most burners will select the
format automatically based on the size of the image to create).<br>
Note, <i>you don't actually need to burn a CD</i>, just use whatever software to create a CD image file
that can be mounted in VirtualBox.  I used <strong>K3b</strong>.
Solaris 8 will automatically detect when the ISO image is mounted through VirtualBox.


<!-- It's a shame that github strips the style tags,
     have to make due with a few SPACEs before the button -->
<a name="virtualbox-configuration"></a>
# <span style="text-align:left;">VirtualBox Configuration<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
It's easier to show all of the screenshots of the VirtualBox setting that were used
with notes as needed to clarify the process.<br>
After building the new machine (setting its name, memory, and hard drive), use these
screen shots to perform the final setting that are needed.<br>
Items that are not show are settings that don't affect the outcome
(e.g., whether the <strong>Shared Clipboard</strong> is enabled, etc.)

#### General
* ![General setting](./images/VirtualBox-0001.png)<br>
Ensure the 32-bit version is selected.

#### System
* ![System settings](./images/VirtualBox-0002.png)<br>
2 gigabytes is pretty generous for these old architectures... <br>

* ![Systen settings](./images/VirtualBox-0003.png)<br>
I configured a 2 CPU system.  I'm not sure how many CPU Solaris 8 x86 supports.<br>
Based on [What's New in Solaris 8 Operating Environment](http://www.ing.iac.es/~cfg/pub_notes/solaris/solaris%208%20whatsnew.pdf),
PAE is available<br>
if you want to go above a 4 gigabyte memory configuration.

* ![Systen settings](./images/VirtualBox-0004.png)<br>


#### Display
* ![Display settings](./images/VirtualBox-0005.png)<br>
I don't know if <strong>Enable 3D Acceleration</strong> actually helps (doesn't hurt, though).

#### Storage
* ![Storage settings](./images/VirtualBox-0006.png)<br>
Install the Solaris 8 media <strong>sol-8-u7-ia-v1.iso</strong>, this is the boot media.

#### Audio
* ![Audio settings](./images/VirtualBox-0007.png)<br>

#### Network
* ![Network settings](./images/VirtualBox-0008.png)<br>
Ensure that the adapter type is set <strong>PCnet-PCI II (Am79C970A)</strong> (others may work, I haven't tried).<br>
Multiple adaapters should work, but the network will require a different configuration
(I believe)
<br>and this guide does not cover those steps.

#### Serial Ports
* No serial ports were configured.

#### USB
* Enabled -- USB is supported according to the documentation.

#### Shared Folders
* No folders are configured.

<a name="installing-first-boot"></a>
# <span style="text-align:left;">Installing: First Boot<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>

<strong>It's suggested that you read through these steps before booting the VM for the first time.</strong><br>
This is where a few non-obvious steps are taken to ensure a good build.
* Start the virtual machine.
You should see a brief booting screen followed by the following screen --<br>
![First Boot 01](./images/firstBoot-001.png)<br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%">
to continue the booting process.<br>
The <strong>Scanning Devices</strong> screen with a text-based progress bar will be displayed.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="./images/firstBoot-001-scan.png" alt="incomplete device list" width="540" height="auto"><br>

:exclamation::exclamation: <strong>Review the Identified Devices screen.</strong><br>
* <img src="./images/firstBoot-002.png" alt="firstBoot-002" width="720px" height="auto"><br>
Ensure that it looks as close to this as possible and that none of the expected devices are missing or<br>
"generically" identified (notice the missing <strong>ADS Sound Blaster</strong> and <strong>PCI: Ethernet controller</strong> entry). :arrow_lower_left:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="./images/firstBoot-001-no_audio_device.png" alt="incomplete device list" width="540" height="auto"><br>
If the Identified Devices screen looks like the above, then the most likely cause is that there's an incorrect setting in the VM.<br>
Power off the VM and review the above settings screens [:up:](#virtualbox-configuration).
Then boot the VM again and ensure it's correct.<br>

* If everything looks okay, then press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%">
to the next steps of the booting process.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="./images/firstBoot-003-loading_ata.png" alt="incomplete device list" width="540" height="auto"><br>

* After the driver is loaded the <strong>Boot Solaris</strong> screen appears.<br>
Navigate using the arrow keys, then press SPACE to selct the CD device to boot Solaris 8.<br>
<img src="./images/firstBoot-004-boot_from_device.png" alt="firstBoot-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to boot Solaris 8 and start the installation.

* After the driver is loaded the <strong>Boot Solaris</strong> screen appears.<br>
<img src="./images/firstBoot-005-interactive.png" alt="select-interactive" width="720px" height="auto"><br>
<br>Select <strong>1. Solaris Interactive</strong> and press <strong>ENTER</strong> to boot the kernel.<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="./images/firstBoot-006-boot_kernel.png" alt="incomplete device list" width="540" height="auto"><br>

* Perform the installation - select the language, etc. (only the interesting screens will be shown).<br>
<img src="./images/firstBoot-007-start_install.png" alt="firstBoot-002" width="720px" height="auto"><br><br>
<img src="./images/install-001.png" alt="install-001" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue the installation.<br>

* You'll need to tell the installer about the video device.<br>
A lot of steps are necessary to get a usable video configuration.<br>
<img src="./images/install-002-kdmconfig.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue the installation.<br><br>
<img src="./images/install-002-kdmconfig-2.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue the installation.<br>

<a name="video-device-selection"></a>
# <span style="text-align:left;">Window System Configuraton<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
#### :camera: It's recommended that you take a snapshot of the VM here...<br>
* <strong>Video Device Selection</strong>
There are *a lot* of video devices listed, unfortunately only the first two are available.<br>
I selected the second option just to get a little more useable screen (even with the panning).<br>
<img src="./images/install-002-kdmconfig-3.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue.<br>

* <strong>Monitor Type Selection</strong><br>
I _think_ any *MultiFrequency* monitor will work, just pick the first.<br>
<img src="./images/install-002-kdmconfig-4.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue.<br>

* <strong>Screen Size Selection</strong><br>
Any size should work, I selected a 17-inch.<br>
<img src="./images/install-002-kdmconfig-5.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue.<br>

* <strong>Virtual Screen Resolution Selection</strong><br>
Because panning was selected, select the panning size.<br>
<img src="./images/install-002-kdmconfig-6.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue.<br>

<a name="#view-and-edit"></a>
* <strong><code>kdmconfig</code>:: View and Edit Window System Configuration</strong><br>
The installer will allow you to continue.<br>
<img src="./images/install-002-kdmconfig-final.png" alt="install-002" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to continue.<br>

* <strong><code>kdmconfig</code>:: Window System Configuration Test</strong><br>
Make sure everything works.<br>
<img src="./images/install-002-kdmconfig-test.png" alt="test-001" width="720px" height="auto"><br>
Press <img src="./images/f2_key.png" alt="F2" width="3%" height="3%"> to perform the display test.<br><br>
<img src="./images/install-002-kdmconfig-test-1.png" alt="test-002" width="720px" height="auto"><br>
* If you see the above image, then the Window System Configuration was successful.<br>
Note, not all of the colors _work_ (agree with their label), but this is how it looks.<br>
If the display doesn't work, appears to hang, or is incorrect you can wait about 20 seconds
and the screen will revert to the [View and Edit Window System Configuration](#view-and-edit) screen.<br>
If everything looks fine, click in the VM's window and scroll to the big rounded <strong>Yes</strong> button
to start the <strong>Solaris Install Console</strong>.

<a name="#solaris-install-console"></a>
# <span style="text-align:left;">Solaris Install Console<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
#### :camera: It's recommended that you take a snapshot of the VM here...<br>
* The installation from this point requires the use of the mouse and follow the images.
<img src="./images/install-colsole-001.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-002.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-003.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
* Enter the VM's hostname.<br>
<img src="./images/install-colsole-004.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
* Enter the VM's IP address for the network device.<br>
Note that the address must agree with the network configuration
that the <strong>bridged adapter</strong> is connected to on the host.<br>
<img src="./images/install-colsole-ip_address.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-subnet.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
* Enter the appropriate <strong>Netmask</strong>.<br>
<img src="./images/install-colsole-netmask.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-noipv6.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>

### <span style="text-align:left;">Confirm the Network Settings<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
* Confirm the setting and click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-confirm.png" alt="confirm" width="640px" height="auto"><br><br>
Kerberos Security Settings (not used)<br>
<img src="./images/install-colsole-kerberos.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>
<img src="./images/install-colsole-kerberos-1.png" alt="no changes" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>

<a name="#select-name-service"></a>
### <span style="text-align:left;">Select the Name Service<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
* Select <strong>None</strong> and press <strong>RETURN</strong>.<br>
<img src="./images/install-colsole-noname.png" alt="confirm" width="640px" height="auto"><br><br>
<img src="./images/install-colsole-noname-1.png" alt="confirm" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>

<a name="#select-time-zone"></a>
### <span style="text-align:left;">Select the Time Zone<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
* Nothing special in this section, just follow the prompts...

<a name="#interactive-install"></a>
### <span style="text-align:left;">Solaris Interactive Install<span style="float:right;">&nbsp;&nbsp;&nbsp;&nbsp;[:top:](#top00)</span></span>
* Click <strong>Continue</strong>.<br>
<img src="./images/interactive-001.png" alt="confirm" width="640px" height="auto"><br><br>

* <strong>Select Geographic Regions</strong><br>
I selected everything, but choose to suit you tastes...
<img src="./images/interactive-002.png" alt="confirm" width="640px" height="auto"><br>
Click <strong>Continue</strong>.<br>

<a name="#select-software"></a>
* <strong>Select Software</strong><br>
Select <strong>Entire Distribution plus OEM support</strong>
<img src="./images/interactive-software.png" alt="confirm" width="640px" height="auto"><br>
* Click <strong>Continue</strong>.<br>



<style
  type="text/css">
  h1 {font-family: "Comic Sans MS", Arial, Helvetica, sans-serif; color: #0000F0;}
  h2 {font-family: "Comic Sans MS", Arial, Helvetica, sans-serif; color: #0000D0;}
  h3 {font-family: "Comic Sans MS", Arial, Helvetica, sans-serif; color: #0000D0;}
</style>
okay



#### :camera: It's recommended that you take a snaphot of the VM here...<br>

