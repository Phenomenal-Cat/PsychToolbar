.. |Experiments| image:: _images/NTB_Icons/Experiment.png
  :width: 30
  :alt: Experiments

.. _NTB_ExperimentsTab:

===================================
|Experiments| NTB Experiments Tab
===================================

.. toctree::
   :maxdepth: 2
   :hidden:

   NTB Image Settings <NTB_ImageSettings>
   NTB Movie Settings <NTB_MovieSettings>
   NTB Visuotopy Settings <NTB_VisuotopySettings>
   NTB Saccade Map Settings <NTB_SaccadeMapSettings>


The :badge:`Experiments,badge-primary` tab of the NIF Toolbar GUI allows the user to launch apps to quickly load, edit and save variables related to specific pre-programmed experiments. The variables controlled by each app in the Settings tab are saved to a unique field of the :link-badge:`NTB_ParamsObject,Params,ref,cls=badge-warning text-dark` object, as listed in the table below. Click on the icon or name of each experiment GUI to view its documentation, or click on the output structure to see the list of fields within each experiment's output structure.

.. panels::
  :column: col-lg-12 p-0 border-1
  :header: bg-primary text-bold p-1 pl-2
  :body: bg-secondary border-0 p-2

  :opticon:`info,mr-1` **Note**
  ^^^^^^^^^^^^^^^^^^^^^^^^
  If you are programming your own experiment and want to utilize NIF Toolbar controls or features, see the :ref:`guide to adding custom experiments <CustomExperiments>` for further information. 


.. |Image| image:: _images/NTB_Icons/W_Slideshow.png
  :height: 40
  :alt: Image
  :target: NTB_ImageSettings.html

.. |Movie| image:: _images/NTB_Icons/W_Movie.png
  :height: 40
  :alt: Movie
  :target: NTB_MovieSettings.html

.. |Visuotopy| image:: _images/NTB_Icons/Checkerboard_w.png
  :height: 40
  :alt: Visuotopy
  :target: NTB_VisuotopySettings.html

.. |Saccade| image:: _images/NTB_Icons/W_Eye.png
  :height: 40
  :alt: EyeTracking
  :target: NTB_SaccadeSettings.html

.. |Audio| image:: _images/NTB_Icons/W_SpeakerOn.png
  :height: 40
  :alt: Auditory
  :target: NTB_AudioSettings.html


.. csv-table:: 
  :file: _static/CSVs/NTB_ExperimentsTab.csv
  :header-rows: 1
  :widths: 8 15 15 60
  :align: left
  :class: special
  
