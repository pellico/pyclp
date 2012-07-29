PyCLP Module Reference
######################



.. automodule:: pyclp
    :members: init,cleanup,cut
    
.. autofunction:: resume(in_term=None)


.. autoclass:: Atom (atom_id)
    
    :inherited-members:

    .. automethod:: __str__

.. autoclass:: Compound (functor_string,*args)
    :members: functor, arity
   
    :inherited-members:
    
     .. automethod:: __str__

    
.. autoclass:: Var()
   :members: value
   
   :inherited-members:
   
      .. automethod:: __str__


.. autoclass:: PList
    :inherited-members:
    
    .. automethod:: __str__
    
.. autoclass:: Stream(name)
   :members: readall 
   
   .. automethod:: read(n=-1)
   .. automethod:: write(buffer)
      
   
    

    
.. autoexception:: pyclpEx




