.. |DPx_icon| image:: _images/PTB_Icons/DataPixx.png
  :align: bottom
  :height: 30
  :alt: PTB Datapixx Settings

.. _PTB_DatapixxSettings:

===================================
|DPx_icon| PTB Datapixx Settings
===================================

.. figure:: _images/PTB_GUIs/PTB_DatapixxSettings.png
  :align: right
  :figwidth: 50%
  :width: 100%
  :alt: Psych Toolbar Datapixx Settings GUI.

The :badge:`Datapixx Settings,badge-success` GUI allows the user to quickly make changes to parameters related to the analog and digital I/O capabilities of the `VPixx DataPixx interface box <https://vpixx.com/products/datapixx2/>`_. All variables controlled by the Datapixx Settings GUI are saved to the :ref:`DPx field <Params-DPx>` of the **Params** object.


Top Panel
======================

The top panel:

* :badge:`Video,badge-primary` enable button: this button is green when pressed, and indicates that the video signal from the PC's graphics card is being routed through the DataPixx box via the DVI connectors. If the video signal is not being based through the DataPixx box then this button should not be pressed.
* :badge:`Audio,badge-primary` enable button: this button is green when pressed, and indicates that the audio signal is being routed via the DataPixx box via the 1/8" mini stereo jacks. If the audio signal is not being passed through the PataPixx box then this button should not be pressed.
* :badge:`VPixx Technologies,badge-primary`: clicking the VPixx logo will open VPixx' DataPixx Toolbox documentation web page in a browser.

.. figure:: _images/PTB_Images/DataPixx_2.png
  :figwidth: 50%
  :width: 100%
  :align: right

  Rear panel connections of the DataPixx 2 interface box used in the Psych and SCNI for analog and digital I/O.

To the right of the top panel, four check boxes induce the following:

* :badge:`DataPixx tools installed?,badge-primary`: this non-editable checkbox indicates whether the `DataPixx Toolbox <http://www.vpixx.com/manuals/psychtoolbox/html/>`_ was found on the Matlab path. This must be installed in order for Matlab to communicate with the DataPixx box. Note also that an earlier version of the DataPixx Toolbox is installed when `PsychToolbox <http://psychtoolbox.org/>`_ is installed, but that it is `recommended to update the DataPixx Toolbox <http://www.vpixx.com/manuals/psychtoolbox/html/install.html>`_ after PsychToolbox installation.

* :badge:`DataPixx box connected?,badge-primary`: if the DataPixx toolbox is installed (as indicated above) then this non-editable checkbox indicates whether the DataPixx interface box is currently powered on and connected to the PC via USB.

* :badge:`TDT Connected via DB25?,badge-primary`: this user editable checkbox tells the GUI whether the `Digital Out` DB25 connector of the DataPixx 2 interface box is connected directly to the 'Digital In' DB25 connector of the TDT RZ2 Bioamp for neurophysiology recording. If so, the appropriate channels of the DataPixx's digital out are automatically assigned to the TDT and cannot be edited.

* :badge:`Use EyeLink interface box?,badge-primary`: this user editable checkbox tells the GUI whether the `Analog I/O`, `Digital In` and `Digital Out` DB25 connectors of the DataPixx 2 interface are connected to the `Interface box <>`_. The interface box partially constrains which signals will appear of which channels, and the GUI will update to reflect these fixed mappings.


Main Panel
======================

.. tabbed:: DAQ Tab

  This panel controls channel assignments for the data acquisition (DAQ) analog and digital I/O functions of the DataPixx.


  .. tab:: Analog In

    * :badge:`ADC rate (Hz),badge-primary`: Set sampling rate of the DataPixx buffer for analog input channels. Note that digital signals converted to analog (e.g. eye position) will have their own sample rate, so there is rarely a need to set the sample rate higher than 1kHz.
    * Dropdown boxes:

  .. tab:: Analog Out

    * :badge:`DAC rate (Hz),badge-primary`: Set sampling rate of the DataPixx buffer for writing to analog output channels. 


.. tabbed:: PsychDPx Tab

  .. image:: _images/PTB_GUIs/PTB_Datapixx_PsychDPx.png
    :width: 40%
    :align: right

  This panel controls the settings of the DataPixx Toolbox functions that integrate with PsychToolbox, related to video display and timing.

  * :badge:`PsychDPx Verbosity,badge-primary`:

  * :badge:`Dummy mode?,badge-primary`: 

  * :badge:`Log onset timestamps,badge-primary`:

  * :badge:`Datapixx video mode,badge-primary`:

  * :badge:`Video horizontal split,badge-primary`:

  * :badge:`Video vertical stereo,badge-primary`:

  * :badge:`Video stereo blueline,badge-primary`:

  * :badge:`Video scanning backlight,badge-primary`:


.. tabbed:: Test Tab

  This tab allows rudimentary testing of the connected DataPixx by reading and plotting incoming signals or setting output signals to selected values. This can be useful for verifying connections and basic debugging.

  * :badge:`Connect,badge-primary`:

  * :badge:`Reset,badge-primary`:

  * :badge:`Log onset timestamps,badge-primary`:


  .. tab:: Analog

    * :badge:`Voltage range (V),badge-primary`:

    * :badge:`Waverform,badge-primary`:

    * :badge:`Frequency (Hz),badge-primary`:

  .. tab:: Digital

    * :badge:`Digital IN channel,badge-primary`:

    * :badge:`Time period (s),badge-primary`:

    * :badge:`Reset,badge-primary`:



Options Panel
==================

.. |GUIname| replace:: Datapixx

The Options panel is standardized across PTB Settings GUIs and contains buttons with icons indicating their function as listed below. You can also hover the cursor over the GUI buttons to see the tooltips description of each button's function.

.. |Save| image:: _images/PTB_Icons/W_Save.png
  :width: 30
  :alt: Save

.. |SaveDesc| replace:: Saves the current |GUIname| parameter values to the currently loaded Parameters file.

.. |Load| image:: _images/PTB_Icons/W_Transfer.png
  :width: 30
  :alt: Load

.. |LoadDesc| replace:: Allows the user to select a different Parameters file from the current one, and load only the |GUIname| parameters from that file.

.. |Help| image:: _images/PTB_Icons/W_ReadTheDocs.png
  :width: 30
  :alt: Documentation

.. |HelpDesc| replace:: Opens the PTB |GUIname| Settings GUI documentation page (this page) in a web browser.

.. |Close| image:: _images/PTB_Icons/W_Exit.png
  :width: 30
  :alt: Close GUI

.. |CloseDesc| replace:: Closes the PTB |GUIname| Settings GUI and returns the updated variables to the Params structure of the main Psych Toolbar.


.. table::
  :align: left
  :widths: 10 10 80

  +------------+-------------+----------------+
  | Icon       | Function    | Description    |
  +============+=============+================+
  | |Save|     | **Save**    | |SaveDesc|     |
  +------------+-------------+----------------+
  | |Load|     | **Load**    | |LoadDesc|     |
  +------------+-------------+----------------+
  | |Help|     | **Help**    | |HelpDesc|     |
  +------------+-------------+----------------+
  | |Close|    | **Close**   | |CloseDesc|    |
  +------------+-------------+----------------+


.. _Params-DPx:

Params.DPx Fields
===================

.. csv-table:: 
  :file: _static/ParamsCsv/DPx.csv
  :header: Subfield, Full field, Description
  :align: left
  :widths: 20 40 40

