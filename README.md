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
* finding recommended patches, and
* "fixing" things that seemed to have been broken in the original OS and patches.

The process took longer than I expected
but after getting things to actually work was pretty satisfing and fun.

There will probably be errors and omissions, but I hope these steps will be useful.

:boom: There are likely <i>many</i> bugs, incomplete and missing features and documentation,
but I hope these steps will be useful.

# Requirements

First, versions of the software used:

The VirtualBox version is 4.3.32-1.  I've had later versions of VirtualBox
crash and burn with some VMs I've built in the past.  It's a problem because
as far as I know, it's not possible to have multiple versions of VirtualBox
installed on the same machine (like you can do with the gcc compiler collection, e.g.).


