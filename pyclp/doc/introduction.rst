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

   * Extend functionality of set_option function
   * Add functions for event handling
  






