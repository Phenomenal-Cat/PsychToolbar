.. _NIF_PLDAPS:

===================================
NIF PLDAPS
===================================

.. panels::
  :column: col-lg-12 p-0 border-1
  :header: bg-primary text-bold p-1 pl-2
  :body: bg-secondary border-0 p-2

  :opticon:`info,mr-1` **Note**
  ^^^^^^^^^^^^^^^^^^^^^^^^
  NIF Toolbar is the recommended replacement for the Krauzlis lab's PLDAPS GUI when running fMRI experiments in the NIF. PLDAPS itself has also been updated substantially since this GUI was written. This page documents how to use the Krauzlis PLDAPS GUI code for reference.


A brief history
-----------------

The NIF began using Datapixx interface with a single Ubuntu PC running Matlab and PsychToolbox in 2017. This replaced the previous experimental control system, which was a client-server system involving a realtime QNX operating system that handled analog and digital IO and timing and send messages via TCP/IP to a second PC running Matlab and PsychToolbox that handled stimulus presentation. DataPixx was recommended to the NIF by Richard Krauzlis in NEI, whose lab used VPixx hardware in conjucntion with the `PLDAPS <https://github.com/HukLab/PLDAPS>`_ Matlab code developed by `Alex Huk's group <https://motion.cps.utexas.edu/people/alex-huk/>`_, and had developed their own graphical user interface (GUI) for handling experiments. This page documents the structure of experimental code written to work with Rich's PLDAPS GUI.



pldaps_gui2_ms
-----------------

The main GUI was written by `Richard Krauzlis <https://www.nei.nih.gov/research/research-labs-and-branches/we-are-nei-intramural/richard-krauzlis>`_ using Matlab's `GUIDE <https://www.mathworks.com/help/matlab/creating_guis/about-the-simple-guide-gui-example.html>`_ feature for GUI creation. Development began in 2012 and the last update of the version generously shared with the NIF was made in April 2017. Due to the nature of Matlab's GUIDE, the GUI is difficult to edit and it is not recommended to attempt to do so (indeed GUIDE is due to be removed from Matlab since being replaced by the `App Designer <https://www.mathworks.com/help/matlab/app-designer.html>`_). 

The GUI is composed of two files: pldaps_gui2_ms.fig and pldaps_gui2_ms.m. It can be run by changing directory to where the GUI files are located and typing :code:`pldaps_gui2_ms` in the Matlab command line. 

.. image:: _images/NTB_GUIs/pldaps_gui_ms.png
  :align: right
  :width: 50%




Settings file
----------------

When you click the :badge:`Browse,badge-primary` button on the GUI, it will open a file browser window that by default will be in the :code:`Settings` subdirectory of the current directory (i.e. where pldaps_gui2_ms.m is executed from). The window allows you to select a Matlab script (.m file) that should have the necessary experiment parameters hard-coded inside it. Parameters specified in this file will be loaded into the GUI and can be modified there. 

Parameters should be stored in 3 structures, organized as follows:

- :badge:`m,badge-primary`: m-file references
- :badge:`c,badge-primary`: most variables
- :badge:`s,badge-primary`: status values


Experiment files
------------------

After loading the settings file, an :badge:`Initialize,badge-primary` button will appear on the GUI. Pressing this button will run the corresponding initialization function for the selected experiment, which should be named in the format :code:`*_init.m` (where * is replaced with a unique string indicating the experiment). The GUI expects each experiment to be composed of four separate .m files with a specific naming convention as follows:

1. **ExpName_init.m** - this function should initialize all aspects of the experiment, including opening the DataPixx connection, opening a PsychToolbox window, calculating on-screen rectangles for drawing textures to, and optionally even pre-loading images into offscreen textures.

2. **ExpName_run.m** - this function is executed when the :badge:`Run,badge-primary` button on the GUI is pressed. It should contain all code for running the actual experiment, including checking for experimenter keyboard input, the subject's current eye position, drawing image textures to screen, and saving any data to file.

3. **ExpName_next.m** - this function is executed when the previous *_run.m function ends. It is typically left blank.

4. **ExpName_finish.m** - this function is executed after the *_run.m function has executed the number of times specified in the status (:badge:`badge-primary`) structure.


Block Design Example
----------------------







