.. _SystemInstall:

=======================
System Installation
=======================

.. warning::
  NIF users **should not make changes to any computer system** in the NIF without the permission and direct supervision of a member of the NIF support team! The NIF is a shared resource and any changes made to these systems will affect all NIF users research.

.. note::
  If you encounter issues that you believe to be related to system updates or changes, please contact NIF support so that we can help to resolve the problem for all users.


The following instructions describe the process for setting up the standard configuration used in the NIF and SCNI for DataPixx stimulus presentation PCs. The specific hardware and software selections have been driven primarily by the recommendations of
VPixx and Mario Kleiner at PsychToolbox. NIF Toolbar's default settings expect this type of setup, but can be configured to operate in alternative environments (e.g. other OSs, and with more or fewer displays).

For this purpose, we typically order high-specification custom workstation PCs in rack mount chassis, from companies like ADEK. It is recommended to request at the time of order that the system should be a Windows - Ubuntu dual boot, and that we will be running power-hungry GPUs (so that the supplier can provide an appropriately rated power supply).

.. contents:: :local:


Ubuntu Installation
=====================

-  **Download Ubuntu 16.04 DVD ISO from http://ubuntu.com** and burn a
   copy, or borrow a burned DVD from NIF.

-  **Power on ADEK PC**, open drive, insert Ubuntu 16.04 DVD.

-  **Boot Ubuntu Installer**. If you don't see the Ubuntu Installer on
   PC boot:

Install aptitude and update all packages
----------------------------------------

Aptitude is a friendlier apt-get, use either based on your preference.

::

    sudo apt-get install aptitude
    sudo aptitude update
    sudo aptitude upgrade -y
    sudo aptitude install build-essential
    sudo reboot


Install NVIDIA drivers for GTX 1080
=======================================

-  Logged in as `nifsupport`, download the appropriate `NVidia drivers <http://.www.nvidia.com/Download/index.aspx>`_ and save to the nifsupport `downloads` directory.

-  Restart the PC and at the GRUB screen, select 'Ubuntu Advanced'

-  From the log in screen, hit 'Ctrl + Alt + F2' to get to a command
   line

-  Log in as Root ('Root' plus nifsupport password)

:: 

   service lightdm stop
   cd /nif-admin/downloads
   ./NVIDIA-XXX...

-  Accept the various terms and conditions of the NVidia driver
   installation process

-  When the installer is finished type::

   service lightdm start

-  Login as lab, use the Ubuntu search function to open the NVidia X
   Server Settings (and pin to dock)

-  The following instructions are adapted from this blog post:
   http://abhay.harpale.net/blog/linux/nvidia-gtx-1080-installation-on-ubuntu-16-04-lts/

-  With graphics card model number in hand, head over to
   `Nvidia <http://www.nvidia.com/Download/index.aspx>`_ and download & install the
   appropriate driver.

-  The NIF's primary DATAPixx PC was setup by VPixx to run dual boot
   Ubuntu 16.04 and Windows 7 and has the NVIDIA drivers correctly
   installed for the NVIDIA GTX 1060 card. The specific drivers
   installed on that machine are shown in the screenshot below.

.. figure:: _images/NTB_Images/NVidia_Drivers.png
  :figwidth: 40%
  :width: 100%
  :align: right

Install NeuroDebian
-------------------


:: 

    wget -O- http://neuro.debian.net/lists/xenial.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
    sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9
    sudo apt-get update

Install Blender
---------------

:: 

     sudo add-apt-repository ppa:thomas-schiex/blender
     sudo apt-get update
     sudo apt-get install blender


Install GNU Octave & PsychToolbox
==========================================

:: 

    sudo add-apt-repository ppa:octave/stable
    sudo apt-get update
    sudo apt-get install octave
    sudo apt-get install octave-psychtoolbox-3

Install Matlab & PsychToolbox
-----------------------------

-  Login to the Mathworks account linked to your NIH e-mail address:
   https://www.mathworks.com/login

-  Download, install and activate MATLAB using your account.


:: 

    sudo apt-get install matlab-psychtoolbox-3

Install DataPixx Tools
----------------------

-  Copy the Datapixx mex file for 64-bit Linux, (e.g. 
   ``/projects/SCNI/Software/VPixx_Software_Tools/DatapixxToolbox_trunk/mexdev/build/matlab/linux64/Datapixx.mexa64``)
     to the PsychBasic folder of your matlab installation (e.g.:
     ``/usr/share/psychtoolbox-3/PsychBasic``)

:: 

    sudo mv /home/lab/Documents/Datapixx.mexa64 /usr/share/psychtoolbox-3/PsychBasic

-  In order to run Datapixx functions without running Matlab or Octave
   as root user (i.e., without need for root login or the sudo command):


:: 

    sudo cp Psychtoolbox/PsychHardware/DatapixxToolbox/60-vpixx-permissions.rules /etc/udev/rules.d/

-  Connect to NIF storage again and copy
   ``/Volumes/LIBRARY/software/VPixx_Software_Tools.zip`` to
   ``~lab/Downloads``.

-  Unzip VPixx\ *Software*\ Tools.zip

-  Add
   `/home/lab/Downloads/VPixx_Software_Tools/DatapixxToolbox_trunk/`
   to MATLAB's path.


.. _SetupNvidiaXscreens:

Setup NVIDIA X-Screens
========================

.. figure:: _images/NTB_Images/NVidia_settings1.png
  :figwidth: 40%
  :width: 100%
  :align: right

-  Connect displays (or matrix switch inputs) to 3 of the display port
   outputs on the NVIDIA GTX 1080 card

-  In Ubuntu, open the **NVIDIA XServer Settings** manager and select
   **XServer display configuration**

-  Click and drag to arrange your displays from left to right: 1) Matlab
   command line 2) Experimenter display 3) Monkey display

-  Select display 2, click the drop down menu next to ``Configuration``
   and select ``Add new Xscreen``

.. figure:: _images/NTB_Images/NVidia_settings2.png
  :figwidth: 40%
  :width: 100%
  :align: right


-  Set display 1 to use Xscreen 0 and displays 2 and 3 to use Xscreen 1

-  Click the **Save to X Configuration File** button

-  You will be propted to overwrite the existing file. Accept.

-  After reboot, the new settings will take effect. The experimenter
   display and monkey display will now remain black after logon. Content
   will only appear on these screens when we tell Matlab to open a
   PsychToolbox window on Xscreen 1. Both the experimenter and monkey
   displays are treated as a single extended window (7680 x 2160 pixels)
