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






