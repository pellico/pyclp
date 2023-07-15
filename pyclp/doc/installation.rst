Installation
############


At this moment only Linux platform is supported.(tested on Ubuntu 12.04).

Linux
*****
In this page it is explained how to compile and install from source in a Linux Platform

Requirments
===========
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 2.x or 3.x  <http://www.python.org/>`_
* `Cython <http://www.cython.org/>`_
* `ECLiPSe Constraint Programming System 6.1 <http://www.eclipseclp.org/>`_


Download
========
Download source files from `PyCLP sources <https://sourceforge.net/projects/pyclp/files>`_

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

* Ubuntu 12.04 LTS (32bit), Python 2.7 and 3.3
* Ubuntu 13.04 (64bit) , Python 2.7 and 3.3

However it is expected working on other platform that fullfill the requirements.


   
Windows
*******


Binary installation
===================

Requirments
-----------
Following packages shall be preinstalled before proceeding the installation of PyCLP
python3 setup.py register

* `Python 2.x or 3.x  <http://www.python.org/>`_
* `ECLiPSe Constraint Programming System 6.1 <http://www.eclipseclp.org/>`_


Enviroment variables
--------------------
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**PATH** add in the path the folder where is stored the *eclipse.dll* file


Download & Install
------------------
Download msi installer from `PyCLP sources <https://sourceforge.net/projects/pyclp/files>`_




Installation from sources
=========================

Requirments
-----------
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 2.x 3.x <http://www.python.org/>`_
* `Cython <http://www.cython.org/>`_
* `ECLiPSe Constraint Programming System 6.1 <http://www.eclipseclp.org/>`_
*  Some compiler used to compile Python interpreter. (Note: Different version of python requires different microsoft compilers)

Download
--------
Download source files from `PyCLP sources <https://sourceforge.net/projects/pyclp/files>`_

Compilation & Installation
--------------------------
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**PATH** add in the path the folder where is stored the *eclipse.dll* file

 

Install using usual method

.. code-block:: bash

   python setup.py install

Regression test

.. code-block:: bash

   python test.py

Tested enviroment
=================

The present version of pyclp is tested on

* Windows 7 (64bit), Python 2.7, 3.3
* Windows 7 (32bit), Python 2.7, 3.3

However it is expected working on other platform that fullfill the requirements.







