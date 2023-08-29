Installation
############

At this moment only Linux platform is supported.(tested on Ubuntu 20.04).

Linux
*****
In this page it is explained how to compile and install from source in a Linux Platform

Requirements
============
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 3.11 or greater  <http://www.python.org/>`_
* `Poetry 1.5.1 or greater <https://python-poetry.org/>`_
* gcc
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_


Download
========
Download source files from `PyCLP sources <https://github.com/pellico/pyclp>`__

Compilation & Installation
==========================
Setup Environmental variables for ECLiPSe:

**ECLIPSEDIR** environmental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**LD_LIBRARY_PATH** environmental variable shall contains the path of folder that contains 
the ECLiPSe sharable library. E.g. <eclipsedir>/lib/<platform>.



Generate wheel package
----------------------

.. code-block:: bash

   poetry build

Generated wheel packaged in folder ``dist`` can be installed using regular ``pip install``

Regression test
---------------

.. code-block:: bash

   poetry install 
   poetry run python  .\test\test.py

Generate documentation
^^^^^^^^^^^^^^^^^^^^^^ 

.. code-block:: bash
   
   poetry install
   cd doc 
   poetry run make.bat html

Tested environment
==================

The present version of pyclp is tested on

* Ubuntu 20.04 (64bit) , Python 3.10

However it is expected working on other platform that fullfil the requirements.


   
Windows (MSYS2 MINGW64)
***********************

EclipseCLP 7.0 is built using gcc and the headers files cannot be compiled with Microsoft C compiler. 

So it is assumed the following environment:

Environment Requirements
========================

* `Python 3.11 or greater  <http://www.python.org/>`_
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_

Environment variables
=====================
Setup Environmental variables for ECLiPSe:

**ECLIPSEDIR** environmental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

Binary installation
===================

Download & Install
------------------
Download wheel package from `PyCLP binaries <https://github.com/pellico/pyclp/releases>`_ and install using ``pip install``



Installation from sources
=========================

Extra requirements
------------------
Following packages shall be preinstalled using ``pacman``

*  mingw-w64-x86_64-toolchain
*  mingw-w64-x86_64-python-pkginfo
*  mingw-w64-x86_64-python-poetry
*  mingw-w64-x86_64-python-pip

The following environment variable shall be set due to limitation of setuptool see `Fails to install on MinGW x64 <https://github.com/pyproj4/pyproj/issues/1009>`_

.. code-block:: bash

   export SETUPTOOLS_USE_DISTUTILS=stdlib

Download
--------
Download source files from `PyCLP sources <https://github.com/pellico/pyclp>`__

Create wheel package
--------------------

.. code-block:: bash

   poetry build
   
Wheel distribution will be available in ``dist`` folder

Regression test
---------------

.. code-block:: bash
   
   poetry install 
   poetry run python  ./test/test.py
   
Generate documentation
----------------------

.. code-block:: bash
   
   poetry install
   cd doc 
   poetry run make html

Tested environment
==================

The present version of pyclp is tested on

* Windows 11 (64bit), Python 3.11

However it is expected working on other platform that fullfil the requirements.







