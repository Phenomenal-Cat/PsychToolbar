.. |DS_icon| image:: _images/NTB_Icons/Display.png
  :align: bottom
  :height: 30
  :alt: NTB Display Settings

.. _NTB_DisplaySettings:

===================================
|DS_icon| NTB Display Settings
===================================

.. figure:: _images/NTB_GUIs/NTB_DisplaySettings.png
  :align: right
  :figwidth: 60%
  :width: 100%
  :alt: NIF Toolbar Display Settings GUI.

The NTB Display Settings GUI allows the user to quickly make changes to parameters that will affect aspects of the visual display for both the subject and the experimenter. All variables controlled by the Display Settings GUI are saved to the :ref:`Display field <Params-Display>` of the Params structure.

.. contents::  :local:


Profile Panel
======================

The `System Profile` panel doesn't contain any editable fields, but displays information about the current environment in which the GUI is running. This can be useful for confirming that the NIF Toolbar is being run on a computer with the correct software and hardware for the experimental demands.

Viewing Geometry Panel
=========================
The `Viewing Geometry` panel contains editable fields related to the physical geometry of the display screen relative to the subject. These settings are particularly important if you choose to specify the dimensions of experimental visual stimuli in 'degrees of visual angle' (DVA). 

* **Viewing distance (cm)**: the distance from the subject's eye to the subject's display screen. 

* **Inter-pupillary distance (cm)**: the distance between the pupils of the subject's eyes. This value is used to calculate the appropriate binocular disparities when displaying stereoscopic 3D content that is generated online (it will not affect offline 3D renderings). The default value of 3.5cm is the average IPD for an adult Rhesus macaque, whereas the average adult human IPD is 6.5cm.

* **Screen dimensions (cm)**: the physical dimensions (width x height) of the subject's display. For setups using monitors or TVs, these dimensions should reflect the active portion of the display (i.e. excluding the bezel), while for setups using projectors these dimensions should reflect the dimensions of the projected image.

* **Screen resolution (pixels)**: the resolution of the subject's display. This is automatically calculated using PsychToolbox's Screen('Rect') function to find the resolution of the second X-Screen, and dividing the width by 2 (since the subject and experimenter displays should be of equal resolution and combined to form a single wide X-Screen - see :ref:`SetupNvidiaXscreens` for details).

* **Pixels/degree (X,Y)**: this field is not editable but shows the number of pixels per degree of visual angle (DVA) based on the information provided in the previous fields. These values are used to calculate the size of visual stimuli and other displayed components when their size is specified in DVA.

* **PTB stereoscopic mode**: select the PsychToolbox stereo-mode appropriate for your presentation format. `Monocular` is suitable for all non-stereoscopic presentation, as well as when stereoscopic stimuli have been rendered offline (e.g. in side-by-side format).

Preview Panel
=========================
The `Preview` panel provides a preview of how various components of the visual display will appear to both the subject and the experimenter. The visual appearance of these components is controlled via a series of tabs in the panel below the preview display.

Grid Tab
------------

This tab controls the appearance of the grid (fields belonging to `Params.Display.Grid`) that can optionally be displayed on the experimenter's display, overlaid on the visual stimulus. This can be helpful for assessing the subject's eye position relative to central fixation, or in terms of overall gaze distribution.

Fixation Tab
--------------

This tab controls the appearance of the central fixation marker (via fields belonging to `Params.Display.Fix`), that is typically displayed on both the subject's and experimenter's displays. 

Gaze Window Tab
-----------------


Photodiode Tab
----------------


Eye Trace Tab
---------------



Options Panel
==================

.. |GUIname| replace:: Display

The Options panel is standardized across NTB Settings GUIs and contains buttons with icons indicating what function they perform. You can also hover over GUI buttons to read tooltips.

.. image:: _images/NTB_Icons/W_Save.png
  :align: left
  :width: 30
  :alt: Save

Saves the current |GUIname| parameter values to the currently loaded Parameters file.

.. image:: _images/NTB_Icons/W_Transfer.png
  :align: left
  :width: 30
  :alt: Load

Allows the user to select a different Parameters file from the current one, and load only the |GUIname| parameters from that file.

.. image:: _images/NTB_Icons/W_ReadTheDocs.png
  :align: left
  :width: 30
  :alt: Documentation

Opens the NTB |GUIname| Settings GUI documentation page in a web browser.

.. image:: _images/NTB_Icons/W_Exit.png
  :align: left
  :width: 30
  :alt: Close GUI

Closes the NTB |GUIname| Settings GUI and returns the updated variables to the Params structure of the main NIF Toolbar.



Params.Display fields
========================

.. _Params-Display:

.. table:: 
  :align: left
  :widths: 20 40 40

  +------------+--------------------------------------+---------------------------+
  | Subfield   | Full field name                      | Description               |
  +============+======================================+===========================+
  | Basic      | Params.Display.Basic.ViewingDist     | X                         |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.Settings.UseAudio         |  X                        |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.Settings.Installed        |  X                        |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.Settings.Connected        |  X                        |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.Settings.TDTconnected     |  X                        |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.Settings.EyeLinkInterface |  X                        |
  +------------+--------------------------------------+---------------------------+
  | Screen     | Params.DPx.AnalogIn.Rate             |  X                        |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.AnalogIn.Channels         | X                         |
  +            +--------------------------------------+---------------------------+
  |            | Params.DPx.AnalogIn.Options          | X                         |
  +------------+--------------------------------------+---------------------------+
