# Steps For Installing Solaris 8 x86 on VirtualBox

This (hobby) project list the steps that I've used to build a Solaris 8 x86 virtual machine in VirtualBox.
These steps were built from a number of sources that I used to guide me through the process.

I've spent many years working in the Sun architecture, from the
[SPARCstation 1](https://en.wikipedia.org/wiki/SPARCstation_1)
through the [Sun Ultras](https://en.wikipedia.org/wiki/Sun_Ultra_series)
they were my first real taste of Unix and 32-bit computing.


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
Graphic support beyond CGA.  Looks like it's possible (and may be non-trivial),
just haven't looked into it yet.

#### Acknowledgements and Attribution
I searched many dozens of sites for answers, the major sites are listed in
these steps, TODO

## Disclaimer
![Software is provided "as is" and "with all faults."](./svgs/disclaimer.svg)
THE PROVIDER makes no representations or warranties of any kind concerning the safety, suitability,
lack of viruses, inaccuracies, typographical errors, or other harmful components of this SOFTWARE.
There are inherent risks and dangers in the use of any software, and you are solely responsible for determining
whether this SOFTWARE is compatible with your equipment and other software installed on your equipment.
You are also solely responsible for the protection of your equipment and the backup of your data,
and THE PROVIDER will not be liable for any damages you may suffer in connection with using,
modifying, or distributing this SOFTWARE.<br>

:boom: There are likely <i>many</i> bugs, errors, incomplete and missing features and documentation.

# System Requirements

### VirtualBox

* The VirtualBox version is <code>4.3.32-1</code> (rpmfusion-free on <code>Fedora 21 x86_64, 4.1.13-100.fc21.x86_64</code>).
<br>I've had later versions of VirtualBox crash and burn with some VMs I've built in the past.
It's a problem because as far as I know, it's not possible to <strong>easily</strong> have multiple versions of VirtualBox
installed on the same machine (like you can do with the gcc compiler collection, e.g.).
There might be a way, but I haven't tried it and my version runs all of my VMs fine
(although the creature comforts added in later versions are nice, but the VMs
don't work).

### Solaris 8 x86
* The Solaris 8 x86 ISOs are available on [archive.org](https://archive.org/download/sol-8-u7-ia).<br><br>
![sample](./images/Solaris_8-availability.png)<br>
You should download all of the Solaris 8 x86 ISO images:<br>

| :cd: Filename    | Image md5sum | :notebook: Notes |
| :----            | :----:       | ---- |
| <code>sol-8-u7-ia-v1.iso</code>      | <code>c243aa080e4c503f60cca48a8fd54e47</code> | Boot with this image |
| <code>sol-8-u7-ia-v2.iso</code>      | <code>6c63bcbbf9e92ed946f1435f6bb89e5f</code> | 2nd install image |
| <code>sol-8-u7-lang-ia.iso</code>    | <code>6164e7e2d24f2291689f2b1f82fccc0b</code> | Optional languages image |
| <code>sol-8-u7-install-ia.iso</code> | <code>91029b86d9eb130a73d83e7a67a817df</code> | This ISO image is<br>not used in these steps. |

* These ISOs will build a Solaris installation with the following characteristics
after all of the steps have been performed in this guide (from <code>/etc/release</code>):<br><br>
![Solaris 8 2/02 s28x_u7wos_08a INTEL](./images/Solaris-8-x86-Desktop.png)<br>

### Solaris 8 x86 Recommended Patch Cluster
Everything up to this point (and following these steps) will allow you to build a working
Solaris 8 x86 virtual machine.  Networking should be fine (manual steps are necessary to
configure the network).  If you've selected <strong>SoundBlaster 16</strong> as the Audio Controller
in VirtualBox, you can listen to that nostalgic Sun [cowbell](/usr/demo/SOUNDS/sounds/cowbell.au) sound once again.
But you'll be missing many tools that are taken for granted in a modern Linux system, for example:
* a C compiler (Solaris 8 does <strong>not</strong> ship with a C compiler),
* the ssh suite (the pseudo-devices <code>/dev/random</code> and <code>/dev/urandom</code> do not exist), and of course
* the lack of any of the <i>modern</i> tools, e.g. <strong>openssl</strong>, <strong>openssh</strong>,
and <strong>gnu</strong> tools are a notable examples.

Sadly http://sunsolve.sun.com [sic] no longer exists, and finding patches can be difficult.
While it's nicest to apply all of the recommended patches, the most important patch is <strong>112439-02</strong>
which provides the pseudo-devices <code>/dev/random</code> and <code>/dev/urandom</code>.
It's best if you're able to find the
[Solaris 8 recommended patch cluster](http://ftp.lanet.lv/ftp/unix/sun-info/sun-patches/8_Recommended.zip) (which includes 112439-02)
and install the cluster for best results.

### Pre-compiled Solaris 8_x86 Binaries
This is really a deal breaker for a usable system if you're unable to find any prebuilt packages.<br>
Fortunately, [tgcware](http://jupiterrise.com/tgcware/)
is there to the [rescue](http://jupiterrise.com/tgcware/sunos5.8_x86/stable/)!
I can't stress enough what a tremendous help and time-saver this was.
There's a good selection of tools assembled (with various versions of some of the tools) and
each package that was built is listed with its name, brief description, and its <code>md5sum</code> checksum.

Some Markdown text with <span style="color:blue">some *blue* text</span>.
testing ...

