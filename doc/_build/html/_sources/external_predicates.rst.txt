Calling Python from ECLiPSe
###########################

It is possible to call python function from ECLiPSe.

How to define a python function call it from ECLiPSe
****************************************************

The steps to achieve this are quite simple.

* Define a python function.
* Register it using function :py:meth:`pyclp.addPythonFunction`
* Call from ECLiPSe with ``call_python_function`` predicate.

Python function definition
==========================

Python function tha implement the predicate shall have one argument. This argument will be used to pass
a list of the term used in the invocation.
Python function shall return the following values :py:const:`pyclp.SUCCEED` or :py:const:`pyclp.FAIL` any other values are equivalent to :py:const:`pyclp.FAIL`
It can be called in this function a :py:meth:`pyclp.unify` to unify to term and interact with ECLiPSe term.

Example::

   def py_unify(args):
      return pyclp.unify(args[0],args[1])
   

Register python function for calling
====================================

In order to be able to excute a python function from ECLiPSe it is required to register the function by calling 
:py:meth:`pyclp.addPythonFunction` after having executed :py:meth:`pyclp.init`

Example::
   
   init()
   pyclp.addPythonFunction("my_unify",py_unify)
   


Call python function from ECLiPSe
=================================

To excecute the python function from ECLiPSe use ``call_python_function`` predicate.
This predicate is declared in ``pyclp`` module. This shall be imported in the user module.
``pyclp`` is created when :py:meth:`pyclp.init` is executed and it is automatically imported in the ``eclipse`` module (the default one)

Example:
   
   ``use_module pyclp``
   ``call_python_function("my_unify",[A,B])``


Modify ECLiPSe variables
************************

In the python function it is possible to use all class to represent ECLiPSe object like: :py:meth:`pyclp.Atom`,
:py:meth:`Compound` etc.. but not :py:meth:`pyclp.resume`,:py:meth:`pyclp.init`,
:py:meth:`pyclp.cut` and :py:meth:`pyclp.cleanup`


Handling python exceptions
**************************

Exception raised in the python function it is stored and reraised inside the 
:py:meth:`pyclp.resume` function if a ECLiPSe signal ``python_error`` is not masked by ECLiPSe.


Internal sequence of operations::

   python script          ECLiPSe                  user python function
   
   resume()       ---->
                          call_python_function ---> 
                                                    raise exception
                                                    (exception stored)                
                                                    signal event "python_error"
                                               <--  
                          if not masked 
                          send THROW to resume
                  <----
    if the event 
    is "python_error"
    restore exception
    and raise it.        
                                              
Complete Example
****************

Example::

   from pyclp import *
   
   def external_predicate(arguments):
      #arguments store all arguments passed with call_python_function
      #Note unify usage
      return unify(arguments[0],arguments[1])
   
   init()   #Init ECLiPSe engine   
   #Register function with 'my_name' atom
   add_python_function('my_name',external_predicate)
   my_var=Var()
   # call_python_function,'my_name',[1,My_var])
   Compound('call_python_function',Atom('my_name'),[1,my_var]).post_goal()
   resume()
   if my_var.value() != 1:
      print("Failed resume ")
        

If an exception is raised during the python function execution ``abort`` event will be raised by
ECLiPSe with the following message.
If this event will be handled by the user in ECLiPSe program, ECLiPSe engine will send a message to python (FLUSHIO) and then THROW value.
See the below example.







 

