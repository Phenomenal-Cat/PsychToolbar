====================
NIF Toolbar
====================

.. _NIF_Toolbar_Home:

.. figure:: _images/NTB_Images/DisplayMockUp.png
  :align: right
  :figwidth: 100%
  :width: 100%
  :alt: NTB Display Example

.. figure:: _images/NTB_GUIs/NIF_Toolbar.png
  :align: right
  :figwidth: 100%
  :width: 100%
  :alt: NIF Toolbar GUI

The NIF Toolbar is a suite of graphical user interfaces (GUIs) and functions, intended to simplify the management of experimental control parameters for running behavioral neuroscience experiments involving non-human primates (NHPs). NIF Toolbar is written in Matlab and designed to interface with commonly used Matlab extensions for behavioral neuroscience.

As the name suggests, the NIF Toolbar has been developed specifically for use in the `NIF (Neurophysiology Imaging Facility) <nif.nimh.nih.gov>`_ and `SCNI (Section on Cognitive Neurophysiology and Imaging) <ttps://www.nimh.nih.gov/research/research-conducted-at-nimh/research-areas/clinics-and-labs/ln/scni/index.shtml>`_ at the National Institutes of Health. It is provided to NIF users as a more open-ended alternative to the excellent `NIMH Monkey Logic <https://monkeylogic.nimh.nih.gov/>`_ extension for Matlab, which is also available for use in the NIF and is worth considering for your research needs.

Basic Overview
================

The NIF Toolbar is flexibly designed to be of benefit to both novice and experienced researchers. For the novice with little programming experience, the NIF Toolbar's graphic environment offers an intuitive way of getting simple visual experiments up and running quickly. For this purpose, a series of commonly used experimental templates are provided, including:

* Eye-tracker calibration
* Presentation of static images (e.g. fMRI 'face patch localizer')
* Presentation of movie clips (e.g. fMRI block design)
* Presentation of abstract graphics (e.g. dot motion, gratings, retinotopic mapping stimuli)

For the advanced user, NIF Toolbar provides a fast and user-friendly means of editing and organizing the many variables involved (via GUIs), which can then be optionally accessed in your own experimental code through the :link-badge:`NTB_ParamsObject,Params,ref,cls=badge-warning text-dark` `object class <https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html>`_. NTB sub-functions allow common tasks that may occur throughout an experiment (e.g. reward delivery) to be executed with a single line of code, thus minimizing the amount of code required to write new experiments.


Panels and Tabs
===================

.. |Session| image:: _images/NTB_Icons/W_Calendar.png
  :width: 40
  :alt: Session
  :target: NTB_SessionPanel.html

.. |Actions| image:: _images/NTB_Icons/W_Play.png
  :width: 40
  :alt: Actions
  :target: NTB_ActionsTab.html

.. |Settings| image:: _images/NTB_Icons/W_Settings.png
  :width: 40
  :alt: Settings
  :target: NTB_SettingsTab.html

.. |Experiments| image:: _images/NTB_Icons/W_Experiment.png
  :width: 40
  :alt: Experiments
  :target: NTB_ExperimentsTab.html

.. |fMRI| image:: _images/NTB_Icons/W_EPI.png
  :width: 40
  :alt: fMRI
  :target: NTB_fMRITab.html

.. |Ephys| image:: _images/NTB_Icons/W_Ephys2.png
  :width: 40
  :alt: Ephys
  :target: NTB_EphysTab.html

.. |Calib| image:: _images/NTB_Icons/W_Calibrate.png
  :width: 40
  :alt: Calibrations
  :target: NTB_CalibrationsTab.html

.. csv-table::
  :file: _static/CSVs/NIF_ToolbarTabs.csv
  :header-rows: 1
  :widths: 10 20 60
  :align: left


Requirements
==============

All systems running the NIF Toolbar comprise of the following:

**Hardware:**

* PC with 32GB RAM, 1TB SSD
* `NVidia Geforce GTX 1080 <https://www.nvidia.com/en-us/geforce/10-series/>`_ (8GB)
* `VPixx DataPixx 2 <https://vpixx.com/products/datapixx2/>`_ interface
* Video-based eye tracking PC with analog output and ethernet communication
* :ref:`DataPixx Interface rack-mount box <InterfaceBox>`_ (optional)
* Neurophysiology recording system (optional)

**Software:**

* `Ubuntu <https://ubuntu.com/download/desktop>`_ 20.04 LTS
* `NVidia drivers  <https://www.nvidia.com/Download/index.aspx>`_ 450.66.
* `Matlab <https://www.mathworks.com/products/matlab.html>`_ R2020a
* `PsychToolbox <http://psychtoolbox.org/>`_ Version 3.0.16
* `DataPixx Toolbox <http://www.vpixx.com/manuals/psychtoolbox/html/install.html>`_ (optional)
* `PLDAPS <https://github.com/HukLab/PLDAPS>`_ Version 4.3.0 (optional)

Installation
===================

The NIF Toolbar can be downloaded or cloned from the `GitHub repository <https://github.com/Phenomenal-Cat/NIF-Toolbar>`_. The computer system should already be configured as outlined in :ref:`SystemInstall`.


Contents
===============================

.. toctree::
   :maxdepth: 2

   NTB Session Panel <NTB_SessionPanel>
   NTB Actions Tab <NTB_ActionsTab>
   NTB Settings Tab <NTB_SettingsTab>
   NTB Experiments Tab <NTB_ExperimentsTab>
   NTB fMRI Tab <NTB_fMRITab>
   NTB Ephys Tab <NTB_EphysTab>
   NTB Calibrations Tab <NTB_CalibrationsTab>
   NTB Review Panel <NTB_ReviewPanel>
   NTB Hardware <NTB_Hardware>
   
   



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`



