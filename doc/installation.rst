Installation
############

At this moment only Linux and MINGW64 platforms are supported.

Linux
*****
Tested platform Ubuntu 24.04

Requirements
============
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 3.11 or greater  <http://www.python.org/>`_
* `Poetry 2.0.0 or greater <https://python-poetry.org/>`_
* gcc
* `ECLiPSe Constraint Programming System 7.0 <http://www.eclipseclp.org/>`_



Compilation & Installation
==========================
Setup Environmental variables for ECLiPSe:

**ECLIPSEDIR** environmental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**LD_LIBRARY_PATH** environmental variable shall contains the path of folder that contains 
the ECLiPSe sharable library. E.g. <eclipsedir>/lib/<platform>.

Installation from PyPi
----------------------

.. code-block:: bash

   pip install pyclp



Compilation and installation from sources
-----------------------------------------

Download source files from `PyCLP sources <https://github.com/pellico/pyclp>`__

Generate wheel and source package
---------------------------------

.. code-block:: bash

   poetry build

Generated wheel packaged in folder ``dist`` can be installed using regular ``pip install``


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

* Ubuntu 20.04 (64bit) , Python 3.11

However it is expected working on other platform that fullfil previous requirements.


   
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

Build distribution packages from sources
========================================

Extra requirements
------------------
Following packages shall be preinstalled using ``pacman``

*  mingw-w64-x86_64-toolchain
*  mingw-w64-x86_64-python-pkginfo
*  mingw-w64-x86_64-python-poetry
*  mingw-w64-x86_64-python-pip


Download
--------
Download source files from `PyCLP sources <https://github.com/pellico/pyclp>`__

Create wheel and source package
-------------------------------

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

* Windows 11 (64bit) / (MSYS2 MINGW64), Python 3.12

However it is expected working on other platform that fullfil the requirements.







