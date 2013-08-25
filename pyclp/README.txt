Introduction
############

`PyCLP <http://developer.berlios.de/projects/pyclp/>`_ 
is a Python library to interface ECLiPSe Constraint Programmig System.

This module try to implement a pythonic interface to `ECLiPSe <http://www.eclipseclp.org/>`_ 
(alias easy to use) by compromising on a little bit on performance.


Major differences from ECLiPSe standard interface libraries
***********************************************************

The main difference compared to embedded interface provided  by ECLiPSe system is 
the persistence of constructed terms after calling the pyclp.resume (check 
`3.1.2  Building ECLiPSe terms <http://www.eclipseclp.org/doc/embedding/embroot008.html#toc11>`_ ) function.
In ECLiPSe standard interfaces compound terms are destroyed after resume while in PyCLP are
stored in a reference that survives after resuming. PyCLP will destroy the reference only when python
destroys the linked python object (garbage collection). This consumes more memory but now
the python object and the related ECLiPSe object have the same *lifetime*.

Moreover, in the definition of the API I tried to take advantage of a common propety of python and 
ECLiPSe: both are weak typed languages.


Next steps
**********

   * Extend functionality of set_option function
   
  
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
Download source files from `PyCLP sources <http://developer.berlios.de/project/showfiles.php?group_id=12904>`_

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
Download msi installer from `PyCLP sources <http://developer.berlios.de/project/showfiles.php?group_id=12904>`_




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
Download source files from `PyCLP sources <http://developer.berlios.de/project/showfiles.php?group_id=12904>`_

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








