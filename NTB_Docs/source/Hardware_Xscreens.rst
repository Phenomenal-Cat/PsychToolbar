.. _Xwindows:

=========================
X Windows Configuration
=========================

All NIF and `SCNI <https://nif.nimh.nih.gov/doc/scni-guide/>`_ experimental control PCs used with DataPixx run on Ubuntu operating systems and are installed with Nvidia graphics cards with (at least) 3 video outputs, intended to display the following content:

  1. Experimenter's Matlab console window (and NIF Toolbar GUI)
  2. Experimenter's stimulus copy with data overlay
  3. Subject's visual stimulus

Management of multiple video outputs under Unix operating systems is handled via the `X Window system (X11) <https://www.x.org/wiki/>`_. This page describes various methods for configuration of suitable X Window settings for use with NIF Toolbar.

.. panels::
  :column: col-lg-12 p-0 border-1
  :header: bg-warning text-bold text-dark p-1
  :body: bg-warning text-dark border-0 p-2 

  :fa:`exclamation-triangle` **Note**
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  In all cases, X window configuration settings are saved and loaded to the system default directory: :code:`/etc/X11/`. Ensure that the user you are logged into Ubuntu as has read and write permissions for this folder in order to make and save changes.

.. panels::
  :column: col-lg-12 p-0 border-1
  :header: bg-primary text-bold p-1 pl-2
  :body: bg-secondary border-0 p-2

  :opticon:`info,mr-1` **Note**
  ^^^^^^^^^^^^^^^^^^^^^^^^
  There is no reason why PsychToolbox and NIF Toolbar shouldn't work with AMD Radeon or other GPUs. However, since Nvidia cards were preferred by several software developers (such as PsychToolbox and Blender) for a while, this is the only GPU manufacturer that NIF Toolbar has been tested with.


NVidia X Server Settings
=========================

.. figure:: _images/NTB_Images/NVidia_settings1.png
  :figwidth: 40%
  :width: 100%
  :align: right

All NIF and SCNI experimental control PCs used with DataPixx run on Ubuntu operating systems with Nvidia graphics cards. The :badge:`Nvidia X Server Settings,badge-primary` UI should have been installed and pinned to the desktop dock. 


-  Connect displays (or matrix switch inputs) to 3 of the display port
   outputs on the NVIDIA graphics card

-  In Ubuntu, open the :badge:`Nvidia X Server Settings,badge-primary` manager and select
   **XServer display configuration**

-  Click and drag to arrange your displays from left to right: 1) Matlab
   command line 2) Experimenter display 3) Subject display

-  Select display 2, click the :badge:`Configuration,badge-secondary` drop down menu and select ``Add new Xscreen``

.. figure:: _images/NTB_Images/NVidia_settings2.png
  :figwidth: 40%
  :width: 100%
  :align: right


-  Set display 1 to use Xscreen 0 and displays 2 and 3 to use Xscreen 1

-  Click the :badge:`Save to X Configuration File,badge-primary` button

-  You will be prompted to overwrite the existing file. Accept.

-  After reboot, the new settings will take effect. The experimenter display and subject display will now remain black after logon, while the experimenter console display will show the Ubuntu desktop. Content will only appear on these screens when we tell Matlab to open a PsychToolbox window on Xscreen 1. Both the experimenter and subject displays are treated as a single extended window (7680 x 2160 pixels).


PsychToolbox Control 
========================

PsychToolbox provides several functions that allow users to create, select and change xorg.conf settings for X11 management on Linux OSs: 

- `PsychLinuxConfiguration <http://psychtoolbox.org/docs/PsychLinuxConfiguration>`_ 
- `XOrgConfCreator <http://psychtoolbox.org/docs/XOrgConfCreator>`_
- `XOrgConfSelector <http://psychtoolbox.org/docs/XOrgConfSelector>`_ 

The former script creates a :code:`/etc/X11/xorg.conf.d/` directory for xorg.conf configuration files which are writable by members of the ‘psychtoolbox’ group to allow easy reconfiguration of the X11 display system for running experiment sessions.



Troubleshooting X-screen configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In a worst case scenarios where the desktop is not visually accessible (e.g. appears on the subject's display), the Ubuntu DataPixx PC can be accessed remotely and the xorg.conf file modified.

.. code-block::

  ssh lab@156.40.249.70
  sudo cp xorg.conf /etc/X11/xorg.conf
  sudo reboot

