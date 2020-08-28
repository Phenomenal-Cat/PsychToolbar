.. |Session| image:: _images/NTB_Icons/Calendar.png
  :width: 30
  :alt: Session

===================================
|Session| NTB Session Panel
===================================

.. _NTB_SessionPanel:

.. figure:: _images/NTB_GUIs/NTB_Main_SessionPanel.png
  :align: right
  :figwidth: 30%
  :width: 100%
  :alt: NIF Toolbar Session panel.

The Session panel of the NIF Toolbar GUI allows the user to quickly load variables associated with a specific computer, researcher, subject, experiment and session date. All variables controlled by the Session panel are saved to the :ref:`Session field <Params-Session>` of the **Params** structure.


.. |Settings| image:: _images/NTB_Icons/Settings.png
  :width: 30
  :alt: Load

|Settings| Parameters
=========================

The parameters file is a .mat file containing a 'Params' super-structure, which contains all of the experimental variables. By default, when the NIF Toolbar is launched is checks in the ``NTB_Params`` folder for a .mat file containing the name of the computer on which it is running. If a single match is found then the file is automatically loaded. If no match is found or multiple matches are found, the user will immediately be asked to select a params file to load.

The parameters dropdown menu shows all of the available parameters files located in the same folder as the currently selected parameters file. Selecting another filename from this menu will immediately load that file. Clicking on the 'parameters' gear icon will allow you to select a new parameters file from any directory.

.. |User| image:: _images/NTB_Icons/Users.png
  :width: 30
  :alt: Load

|User| User
=========================

The user name drop down menu is populated with the names of researchers associated with the currently loaded parameter file. If this is the first time running 

.. |Subject| image:: _images/NTB_Icons/Subject.png
  :width: 30
  :alt: Load

|Subject| Subject
=========================


.. |Experiment| image:: _images/NTB_Icons/Experiment.png
  :width: 30
  :alt: Load

|Experiment| Experiment
=========================


.. |Calendar| image:: _images/NTB_Icons/Calendar.png
  :width: 30
  :alt: Load

|Calendar| Session
=========================

.. _Params-Session:

Params.Session fields
=========================
