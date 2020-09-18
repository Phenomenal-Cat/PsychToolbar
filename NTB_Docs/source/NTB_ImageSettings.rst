.. |Images| image:: _images/NTB_Icons/Slideshow.png
  :align: bottom
  :height: 30
  :alt: NTB Image Settings

.. _NTB_ImageSettings:

=============================================
|Images| NTB Image Experiment Settings
=============================================

.. figure:: _images/NTB_GUIs/NTB_ImageSettings/NTB_ImageSettings.png
  :align: right
  :figwidth: 50%
  :width: 100%
  :alt: NTB Image Experiments Settings GUI.

The Image Experiments settings GUI allows the user to quickly set parameters for experiments involving the visual presentation of static images. All variables controlled by the Image settings GUI are saved to the :ref:`Image field <Params-Image>` of the Params object.

Settings Panel
=================


Selection Tab
------------------

* **Image directory**: full path of the folder to load image stimuli from.

* **Background directory**: full path of the folder to load background images from. If selected, background images will be presented behind the stimulus images and hence will only be visible where the stimulus image contains transparent pixels.

* **Image format**: File format of the images to load. Images in other formats from the selected image directory will be ignored.

* **Subdirectories**: Select how to treat subdirectories found inside the image directory:

  - **Ignore**: only load images found in the top level of the image directory.
  - **Load all**: search the image directory recursively and load all images from any subdirectories.
  - **Use as conditions**: treat each subdirectory found in the image directory as a separate experimental condition and load the images from each.

* **Conditions**: If the **Subdirectories** field above is set to **Use as conditions** then this dropdown menu will be populated with the subdirectory names. Selecting a name in this dropdown menu will make the image preview jump to the first image belonging to that condition.

* **Backgrounds**: Select how to use background images found in the **Background directory**. If there is a specific background image for each stimulus then background images should be named with a similar convention to the images so that they retain the same order. If there are fewer background images than stimulus images then the background can either be randomized per trial or randomized per block.

* **SDS 3D format?**: Select this checkbox if the stimuli are in side-by-side (SBS) stereoscopic 3D format. For stereoscopic presentation, settings must also be updated in :ref:`NTB Display Settings GUI <NTB_DisplaySettings>`.


Transforms Tab
------------------

* **Present fullscreen**: 

* **Stimulus width (units)**:

* **Stimulus width**:

* **Use alpha channel?**:

* **Color**: 

* **Apply mask**:

* **Image rotation ()**:

* **Image contrast**:

* **Normalize luminance**: 


Presentation Tab
------------------

* **Stimulus order**:

* **Trials per run**:

* **Stim. per trial**:

* **Stim. duration (ms)**:

* **Inter-stim interval (ms)**:

* **Inter-trial interval (ms)**:

* **Temporal jitter (mean ms)**:



fMRI Tab
------------------

* **Add fixation blocks**: 

* **Blocks per run**: 

* **Stim. Per block**: 

* **Stim. Duration (ms)**: 

* **Inter-stim interval (ms)**: 

* **Sync stim to TTL?**: 


Stimulus Panel
==================

* **No. images**:

* **Image res (px)**:

* **Preview image**:




Options Panel
==================

.. |GUIname| replace:: Image

The Options panel is standardized across NTB Settings GUIs and contains buttons with icons indicating their function as listed below. You can also hover the cursor over the GUI buttons to see the tooltips description of each button's function.

.. |Save| image:: _images/NTB_Icons/W_Save.png
  :width: 30
  :alt: Save

.. |SaveDesc| replace:: Saves the current |GUIname| parameter values to the currently loaded Parameters file.

.. |Load| image:: _images/NTB_Icons/W_Transfer.png
  :width: 30
  :alt: Load

.. |LoadDesc| replace:: Allows the user to select a different Parameters file from the current one, and load only the |GUIname| parameters from that file.

.. |Help| image:: _images/NTB_Icons/W_ReadTheDocs.png
  :width: 30
  :alt: Documentation

.. |HelpDesc| replace:: Opens the NTB |GUIname| Settings GUI documentation page (this page) in a web browser.

.. |Close| image:: _images/NTB_Icons/W_Exit.png
  :width: 30
  :alt: Close GUI

.. |CloseDesc| replace:: Closes the NTB |GUIname| Settings GUI and returns the updated variables to the Params structure of the main NIF Toolbar.

.. |Textures| image:: _images/NTB_Icons/W_SlideShow.png
  :width: 30
  :alt: Load Textures

.. |TexDesc| replace:: Loads the selected images into PTB textures on the GPU ready for the experiment to run. Only enabled when a PTB window has already been opened.

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
  | |Textures| | **Load im** | |TexDesc|      |
  +------------+-------------+----------------+



Params.Image fields
======================

.. _Params-Image:

.. csv-table:: 
  :file: _static/ParamsCsv/Image.csv
  :header: Subfield, Full field, Description
  :align: left
  :widths: 20 40 40


