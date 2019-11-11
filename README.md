# ![Installation Guide For Solaris 8 x86 In VirtualBox](./svgs/mainTitle.svg)

This (hobby) project list the steps that I've used to build a Solaris 8 x86 virtual machine in VirtualBox.
These steps were built from a number of sources that I used to guide me through the process.

I've spent many years developing software in the Sun SPARC architecture,
first on the [SPARCstation 1](https://en.wikipedia.org/wiki/SPARCstation_1) (Sun 4/60)
up through the [Sun Ultra](https://en.wikipedia.org/wiki/Sun_Ultra_series) 1 and 2.
Those Sun systems were my first real taste of Unix and 32-bit computing.
I remember that a [SPARCstation IPX](https://en.wikipedia.org/wiki/SPARCstation_IPX) was
not fast enough to decode mp3 files and 1152x900 8-bit color was state-of-the-art graphics
(yes there were 24-bit cards available, but they were expensive and very slow and not
all of the software supported the 24 bit visuals).


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
* <strong>Graphic beyond SVGA</strong> (800×600 4-bit color depth)<br>
Looks like it may be possible (and may be non-trivial).<br>
I just haven't looked into it yet; probably ties in with Guest Additions.
<!-- https://docs.oracle.com/cd/E97728_01/F12469/html/adv-config-linux-guest.html -->
* <strong>Guest Additions:</strong><br>
Shared clipboard, drag and drop, seamless mode, shared folders from host system, and theoretically better graphics<br>
I haven't looked into it at all.

#### Acknowledgements and Attribution
I searched many dozens of sites for answers, the major sites are listed in
these steps, TODO

## Disclaimer
![Software is provided "as is" and "with all faults."](./svgs/disclaimer.svg)
THE AUTHOR makes no representations or warranties of any kind concerning the safety, suitability,
lack of viruses, inaccuracies, typographical errors, or other harmful components of SOFTWARE in this guide.
There are inherent risks and dangers in the use of any software, and you are solely responsible for determining
whether this SOFTWARE in this guide is compatible with your equipment and other software installed on your equipment.
You are also solely responsible for the protection of your equipment and the backup of your data,
and THE AUTHOR will not be liable for any damages you may suffer in connection with using,
modifying, or distributing this SOFTWARE in this guide.<br>

:boom: There are likely <i>many</i> bugs, errors, incomplete and missing features and documentation.

# System Requirements

### VirtualBox

* The VirtualBox version is <code>4.3.32-1</code> (rpmfusion-free on <code>Fedora 21 x86_64, 4.1.13-100.fc21.x86_64</code>).
<br>I've had later versions of VirtualBox crash and burn with some VMs I've built in the past.
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


# Getting Started
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

#### 5. Building the "tools" CD
I decided, after a few install iterations, the easiest thing to do was to 
create a CD ISO image containing all of the packages and scripts used to build the system.
I emphasize a CD volume because I'm not sure if Solaris 8 "knows" about DVD file systems;
if it can, then use whatever format you want (although most burners will select the
format automatically based on the size of the image to create).<br>
Note, <i>you don't actually need to burn a CD</i>, just use whatever software to create a CD image file
that can be mounted in VirtualBox.  I used <strong>K3b</strong>.
Solaris 8 will automatically detect when the ISO image is mounted through VirtualBox.


# VirtualBox
[top](#top)
<a href="#top">Back to top</a>
It's easier to show all of the screenshots of the VirtualBox setting that were used
with notes as needed to clarify the process.
Items that are not show are setting that don't affect the outcome (e.g., whether the <strong>Shared Clipboard</strong> is enabled, etc.)
#### General
* ![General setting](./images/VirtualBox-0001.png)<br>

#### System
* ![System settings](./images/VirtualBox-0002.png)<br>
2 gigabytes is pretty generous for these old architectures...
<br>
* ![Systen settings](./images/VirtualBox-0003.png)<br><br>
* ![Systen settings](./images/VirtualBox-0004.png)<br>

#### Display
* ![Display settings](./images/VirtualBox-0005.png)<br>
I don't know if <strong>Enable 3D Acceleration</strong> actually helps (doesn't hurt, though).

#### Storage
* ![Storage settings](./images/VirtualBox-0006.png)<br>

#### Audio
* ![Audio settings](./images/VirtualBox-0007.png)<br>

#### Network
* ![Network settings](./images/VirtualBox-0008.png)<br>

#### Serial Ports
* No serial ports were configured.

#### USB
* Enabled -- don't know if this has any effect in Solaris 8.

#### Shared Folders
* No folders are configured.

