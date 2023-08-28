Installation
############

At this moment only Linux platform is supported.(tested on KUbuntu 16.04).

Linux
*****
In this page it is explained how to compile and install from source in a Linux Platform

Requirements
============
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 3.11 or greater  <http://www.python.org/>`_
* `Poetry 1.5.1 or greater <https://python-poetry.org/>`_
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_


Download
========
Download source files from `PyCLP sources <https://sourceforge.net/projects/pyclp/files>`__

Compilation & Installation
==========================
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**LD_LIBRARY_PATH** enviromental variable shall contains the path of folder that contains 
the ECLiPSe sharable library. E.g. <eclipsedir>/lib/<platform>.



Install using usual method

.. code-block:: bash

   sudo python setup.py install

Regression test

.. code-block:: bash

   python test.py

Tested enviroment
=================

The present version of pyclp is tested on

* Ubuntu 20.04 (64bit) , Python 3.10

However it is expected working on other platform that fullfill the requirements.


   
Windows
*******


Binary installation
===================

Requirements
------------
Following packages shall be preinstalled before proceeding the installation of PyCLP
python3 setup.py register

* `Python 3.11 or greater  <http://www.python.org/>`_
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_


Enviroment variables
--------------------
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**PATH** add in the path the folder where is stored the *eclipse.dll* file


Download & Install
------------------
Download msi installer from `PyCLP binaries <https://github.com/pellico/pyclp/releases>`_




Installation from sources
=========================

Requirements
------------
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 3.11 or greater <http://www.python.org/>`_
* `Poetry 1.5.1 or greater <https://python-poetry.org/>`_
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_
*  Some compiler used to compile Python interpreter. (Note: Different version of python requires different microsoft compilers)

Download
--------
Download source files from `PyCLP sources <https://github.com/pellico/pyclp>`__

Compilation & Installation
--------------------------
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**PATH** add in the path the folder where is stored the *eclipse.dll* file

 

Create distribution
^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   poetry build
   
Wheel distribution will be available in ``dist`` folder

Regression test
^^^^^^^^^^^^^^^ 

.. code-block:: bash
   
   poetry install 
   poetry run python  .\test\test.py
   
Generate documentation
^^^^^^^^^^^^^^^^^^^^^^ 

.. code-block:: bash
   
   poetry install
   cd doc 
   poetry run make.bat html

Tested enviroment
=================

The present version of pyclp is tested on

* Windows 11 (64bit), Python 3.11

However it is expected working on other platform that fullfill the requirements.







