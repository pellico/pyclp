Introduction
############

`PyCLP <http://developer.berlios.de/projects/pyclp/>`_ 
is a Python library to interface ECLiPSe Constraint Programmig System.

This module try to implement a pythonic interface to `ECLiPSe <http://www.eclipseclp.org/>`_ 
(alias easy to use) by compromising on a little bit on performance.


Major differences from ECLiPSe standard interface libraries
***********************************************************

The main difference compared to embedded interface provided  by ECLiPSe system is 
the persistence of constructed terms after calling the :py:func:`pyclp.resume` (check 
`3.1.2  Building ECLiPSe terms <http://www.eclipseclp.org/doc/embedding/embroot008.html#toc11>`_ ) function.
In ECLiPSe standard interfaces compound terms are destroyed after resume while in PyCLP are
stored in a reference that survive after resuming. PyCLP will destroy the refence only when python
destroys the corrisponded python object (garbage collection). This consumes more memory but the now
the python object and teh corrispondent ECLiPSe object have the same *lifetime*.

Moreover, in the definition of the API I tried to take advantage of a common propety of python and 
ECLiPSe: both are weak typed languages.


Next steps
**********

   * Release installers for Windows platform
   * Add functions for event handling
   
   
Installation
############


At this moment only Linux platform is supported.(tested on Ubuntu 12.04).

Linux
*****
In this page it is explained how to compile and install from source in a Linux Platform

Requirments
===========
Following packages shall be preinstalled before proceeding the installation of PyCLP

* `Python 3.x <http://www.python.org/>`_
* `Cython <http://www.cython.org/>`_
* `ECLiPSe Constraint Programming System <http://www.eclipseclp.org/>`_

Download
========
Download source files from `PyCLP sources <http://developer.berlios.de/project/showfiles.php?group_id=12904>`_

Compilation & Installation
==========================
Setup Enviromental variables for ECLiPSe:

**ECLIPSEDIR** enviromental variable shall be set to the folder where is located ECLiPSe system. 
This is required for compiling and using PyCLP.

**LD_LIBRARY_PATH** enviromental variable shall contains the path of folder that contains 
the ECLiPSe sharable library. E.g. <eclipsedir>/lib/i386_linux.



Install using usual method

.. code-block:: bash

   sudo python setup.py install

Regression test

.. code-block:: bash

   python test.py
   
   
Windows
*******

TODO

LICENSE


#Simplified BSD License
#Copyright (c) 2012, Oreste Bernardi
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
#BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
#IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
#OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
#OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
#THE POSSIBILITY OF SUCH DAMAGE.
   
   
   