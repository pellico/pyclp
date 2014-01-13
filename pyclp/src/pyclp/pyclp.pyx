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

#@PydevCodeAnalysisIgnore

"""
Pyclp is a Python library to interface ECLiPSe Constraint Programmig System.

.. note:: 
    Classes :py:class:`PList`, :py:class:`Atom`, :py:class:`Compound` can be compared each other as
    in `ec_compare <http://www.eclipseclp.org/doc/embedding/embroot078.html>`_
 

"""
from __future__ import print_function
cimport pyclp
cimport cpython
cimport libc.stdlib
import io,sys
import weakref
import string
import types
from cpython.version cimport PY_MAJOR_VERSION

#Store a global reference used to return data from eclipse engine.
cdef Var toPython=None
python_pred2func={}
last_resume_result=None 
# Store a weak reference in order to support cleanup function
# All reference need to be destroyed before cleanup of eclipse engine
all_active_refs=weakref.WeakSet()
# Flag to signal when eclipse engine is initialized.
cdef int eclipse_initialized=0
#Store exceptions raised by predicates implemented in Python
pyPredicatesException=None 


SUCCEED=True
FLUSHIO=pyclp.PFLUSHIO
WAITIO=pyclp.PWAITIO
FAIL=False
YIELD=pyclp.PYIELD
THROW=pyclp.PTHROW
OPTION_IO=pyclp.EC_OPTION_IO
OPTION_MAPFILE=pyclp.EC_OPTION_MAPFILE
OPTION_PARALLEL_WORKER=pyclp.EC_OPTION_PARALLEL_WORKER
OPTION_ARGC=pyclp.EC_OPTION_ARGC
OPTION_ARGV=pyclp.EC_OPTION_ARGV
OPTION_LOCALSIZE=pyclp.EC_OPTION_LOCALSIZE
OPTION_GLOBALSIZE=pyclp.EC_OPTION_GLOBALSIZE
OPTION_PRIVATESIZE=pyclp.EC_OPTION_PRIVATESIZE
OPTION_SHAREDSIZE=pyclp.EC_OPTION_SHAREDSIZE
OPTION_PANIC=pyclp.EC_OPTION_PANIC
OPTION_ALLOCATION=pyclp.EC_OPTION_ALLOCATION
OPTION_DEFAULT_MODULE=pyclp.EC_OPTION_DEFAULT_MODULE
OPTION_ECLIPSEDIR=pyclp.EC_OPTION_ECLIPSEDIR
OPTION_INIT=pyclp.EC_OPTION_INIT
OPTION_DEBUG_LEVEL=pyclp.EC_OPTION_DEBUG_LEVEL

class pyclpEx(Exception):
    def __init__(self,arg):
        self.msg=arg
    def __str__(self):
        return self.msg

cdef object tounicode(char* s):
    cdef bytes py_string_bytes
    if (PY_MAJOR_VERSION < 3):
        py_string_bytes=s
        return py_string_bytes
    else:
        return s.decode('ascii', 'strict')

cdef object tounicode_with_length(
        char* s, size_t length):
    if (PY_MAJOR_VERSION < 3):
        return s[:length]
    else:
        return s[:length].decode('ascii', 'strict')
    
#===============================================================================
# cdef unicode tounicode_with_length_and_free(
#        char* s, size_t length):
#    try:
#        return s[:length].decode('ascii', 'strict')
#    finally:
#        libc.stdlib.free(s)
#===============================================================================

cdef bytes tobytes(object string):
    if isinstance(string,unicode):
        return string.encode('ascii')
    elif isinstance(string,str):
        return string
    else:
        raise ValueError("requires text input, got %s" % type(string))


    
#Execute a predicate defined in python 
cdef public int call_python() with gil :
    """
    This is called from ECLiPSe
    """
    global pyPredicatesException
    cdef int err_stream_number
    cdef char * error_string
    cdef pyclp.pword  python_error_pword
    cdef int post_event_result
    pyPredicatesException=None
    try:
        predicate=pword2object(ec_arg(1))
        arguments=pword2object(ec_arg(2))
        pred_string=predicate.__str__()      
        python_function=python_pred2func[pred_string]
        #Execute python function
        result=python_function(arguments)
    # Python exception send a specific event 'python_error' that can be 
    # handled and eventually masked in eclipse. If not catched the event trigger a
    # raise of same exception (it is stored in global pyPredicatesException) 
    except Exception as pyPredicatesException:
        python_error_pword=pyclp.ec_atom(pyclp.ec_did("python_error_event",0))
        post_event_result=ec_post_event(python_error_pword)
        # if posting event is failing I raise regular external error event.
        if post_event_result != pyclp.PSUCCEED:
            # Error codes are negative numbers in C code.
            # Note that in Prolog the positive counterparts are used!
            # In -213 "error in external predicate"
            return pyclp.EC_EXTERNAL_ERROR
        else:
            return FAIL
    if result==SUCCEED:
        return pyclp.PSUCCEED
    else:
        return pyclp.PFAIL
    
    
cdef int register_call_python_pred():
    """
    Register call_python_function to eclipse engine.
    """
    cdef dident module_name_dict
    cdef int result
    module_name_dict=ec_did('pyclp',0)
    # Register predicate to call external function implemented in python.
    #event_handler_compile_string="compile_term([python_error_event_handler(_):- exit_block(python_error)),:-  set_event_handler(python_error,python_error_event_handler) ]"
    event_handler_compile_string=tobytes("create_module(pyclp,[call_python_function/2],[eclipse_language]),compile_term([python_error_event_handler(_):- exit_block(python_error),:-  set_event_handler(python_error_event,python_error_event_handler/1) ])@pyclp,use_module(pyclp)")
    ec_post_string(event_handler_compile_string)
    result=pyclp.ec_resume()
    if pyclp.PSUCCEED != result:
        return result
    else:
        return pyclp.ec_external(pyclp.ec_did("call_python_function",2), call_python, module_name_dict)
 


cpdef formatTermStr(element):
    """Just used to generate the string if terms.
    string terms shall be enclosed in double quotes as in ECLiPSe
    """
    if isinstance(element,str):
        return "".join(['"',element,'"'])
    else:
        return element.__str__()


cdef class Ref:
    cdef pyclp.ec_ref ref
    cdef object __weakref__
    def __cinit__(self):
        self.ref=pyclp.ec_ref_create_newvar()
    def cinit(self):
        self.ref=pyclp.ec_ref_create_newvar()
    def __init__(self):
        all_active_refs.add(self)
    def __dealloc__(self):
        if self.ref != NULL:
            pyclp.ec_ref_destroy(self.ref)
            self.ref=NULL
    def dealloc(self):
        if self.ref != NULL:
            pyclp.ec_ref_destroy(self.ref)
            self.ref=NULL
    cdef pyclp.pword get(self):
        return pyclp.ec_ref_get(self.ref)
    cdef void set(self,pyclp.pword pr_word):
        pyclp.ec_ref_set(self.ref,pr_word)             
        
class Stream(io.RawIOBase):
    """Class to support streams to and from ECLiPSe.
    This is class is derived from io.RawIOBase.
    
    :param name: string containing stream name of a previously opened stream by ECLiPSe program. \
    See: `Embedded C stream api <http://www.eclipseclp.org/doc/embedding/embroot082.html>`_ \
    and `get_stream/2 <http://www.eclipseclp.org/doc/bips/kernel/iostream/get_stream-2.html>`_
    
    .. note:: 
        The following stream are already opened: \
        'input', 'output', 'error', 'warning_output', 'log_output', 'stdin', 'stdout', 'stderr', 'null'.
    
    :raise IOError: if name is not matching a previously open stream by \
    `open/3 <http://www.eclipseclp.org/doc/bips/kernel/iostream/open-3.html>`_ and \
    `open/4 <http://www.eclipseclp.org/doc/bips/kernel/iostream/open-4.html>`_
    

    
      
    """
    def __init__(self,name):
        if isinstance(name,str):
            self.name=name
            encoded_name=tobytes(name)
            self.stream_num=(pyclp.ec_stream_nr (<char *>encoded_name))
            if self.stream_num < 0:
                raise IOError
        elif isinstance(name,int):
            self.stream_num=name
        else:
            raise TypeError("name shall be a string or a integer") 
    def seekable(self):
        return False
    def readable(self):
        return True
    def writeable(self):
        return True
    def fileno(self):
        return self.stream_num
    def isatty(self):
        return False
    def truncate(self,size=None):
        raise IOError
    def flush(self):
        """The semantic is different from usual Stream.
        In this case it does nothing
        """
        pass
    def read(self,int n=-1):
        """
        
        Read all bytes from stream
        
        :param n: Number of bytes to be read if omitted or equal to -1 it will return all avaiable bytes.
        :returns: bytes object
        """
        cdef char* buffer
        cdef int lenght
        cdef int num_bytes_read
        cdef bytes python_buffer
        lenght=ec_queue_avail(<int>self.stream_num)
        if n==0:
            return bytes(0)
        elif n > 0:
            # Don't read more buffer than available.
            if lenght > n:
                lenght=n
        buffer=<char*>libc.stdlib.calloc(lenght,1)
        num_bytes_read=pyclp.ec_queue_read(<int> self.stream_num,buffer,lenght)
        if num_bytes_read < 0 :
            raise IOError(n)
        
        python_buffer=buffer[0:lenght]
        libc.stdlib.free(buffer)
        return python_buffer
    def write(self,buffer):
        """
        Write a bytes object to stream.
        :type buffer: bytes object.
        :return: number of bytes written 
        """
        #cdef char* buffer
        cdef int lenght
        cdef int returned_value
        cdef int num_bytes_read
        lenght=len(buffer)
        returned_value=pyclp.ec_queue_write(<int> self.stream_num,<char*>buffer,lenght)
        if returned_value < 0:
            raise IOError(returned_value)
        else:
            return returned_value
    def readall(self):
        """
        Read all available bytes equivalent to :py:func:`pyclp.read`
        
        """
        return self.read(-1)
    def readinto(self,b):
        raise NotImplemented()
        
cdef destroy_all_refs():
    for prolog_ref in all_active_refs:
        if prolog_ref is not None:
            (<Ref?>prolog_ref).dealloc()
            
cdef recreate_all_refs():
    """Recreate all eclipse refs.
    """
    for prolog_ref in all_active_refs:
        if prolog_ref is not None and (<Ref?>prolog_ref).ref==NULL:
            prolog_ref.cinit()                     
def init():
    """This shall be called before calling any other function.
    This initialize Eclipse engine.
    
    :raise:
        pyclpEx in case of failure or if eclipse engine is already initialized

    """
    global toPython,last_resume_result,python_pred2func
    global eclipse_initialized,pyPredicatesException
    pyPredicatesException=None
    python_pred2func={} #It shall be a empty dictionary at init. Defensive programming
    if eclipse_initialized != 0:
        raise pyclpEx("Tried to initialize an already initialized eclipse engine")
    last_resume_result=None #It shall be None at init. Defensive programming
    pyclp.ec_set_option_long(pyclp.EC_OPTION_IO, pyclp.MEMORY_IO)
    if (pyclp.ec_init()):
        raise pyclpEx("Failed initialization")
    else:
        #If the registering of call_python_func fails raise an exception
        if register_call_python_pred() != pyclp.PSUCCEED:
            cleanup()
            raise pyclpEx("init() failed registering of eclipse:call_python_func")
        eclipse_initialized=1
        recreate_all_refs()
        if toPython is None:
            toPython=Var()


def cleanup():
    """This shutdown the Eclipse engine.
    After calling this function any operation on pyclp object or class could crash the program.
    
    :raise:
        pyclpEx in case of failure or if eclipse engine is already shutdown
        
    .. warning::
    
        If after a cleanup it is called again :py:func:`pyclp.init` all terms created before the cleanup are not valid and they need 
        to be rebuilt.
    """
    global last_resume_result,python_pred2func
    global eclipse_initialized,pyPredicatesException
    pyPredicatesException=None
    if eclipse_initialized == 0:
        raise pyclpEx("Tried to cleanup an already shutdown engine")
    destroy_all_refs()
    python_pred2func={}
    eclipse_initialized=0
    last_resume_result=None
    if (pyclp.ec_cleanup()):
        raise pyclpEx("Failed cleanup operation")


def cut():
    """
    Cut all choice point of succeeded goal.
    Equivalent to void `ec_cut_to_chp(ec_ref) <http://www.eclipseclp.org/doc/embedding/embroot081.html>`_
    It can be called only if previous resume call SUCCEED.
    
    .. seealso::
    
        `ec_cut_to_chp <http://www.eclipseclp.org/doc/embedding/embroot081.html>`_
            cut function in ECLiPSe in C interface library
            
    For an example see :ref:`Cut Example <cut-example>` 
    
    """
    if last_resume_result==pyclp.PSUCCEED:
        pyclp.ec_cut_to_chp(toPython.ref.ref)
    else:
        raise pyclpEx("Cut it is possible only after a resume that returns SUCCEED.")
    

def resume(in_term=None):
    """
    Resume Eclipse engine.
    Implements the functionality of 
    `ec_resume,ec_resume1,ec_resume2 <http://www.eclipseclp.org/doc/embedding/embroot081.html>`_.  
    It accepts optional argument *in_term*. Used to return a value to the prolog predicate 
    `yield/2 <http://www.eclipseclp.org/doc/bips/kernel/externals/yield-2.html>`_
    
    :param in_term: Optional argument *in_term*. Used to return a value to the prolog predicate \
    `yield/2 <http://www.eclipseclp.org/doc/bips/kernel/externals/yield-2.html>`_
    :type in_term: :py:class:`PList`, :py:class:`Atom`, :py:class:`Compound`
    
    :rtype: tuple
    :returns: 
        (pyclp.SUCCEED,None) if execution succeed (equivalent to True). \
        In this case it is possible to call pyclp.cut()
        
        (pyclp.FAIL,None) if the goal fails.
        
        (pyclp.FLUSHIO,\ *stream_number*\ ) if some data is present in stream identified by *stream_number*
        
        (pyclp.WAITIO,\ *stream_number*\ )  if eclipse engine try to read data \
        from stream identified by *stream_number*
        
        (pyclp.YIELD, *yield_returned_value*) in case of predicate call \
        `yield/2 <http://www.eclipseclp.org/doc/bips/kernel/externals/yield-2.html>`_.

        (pyclp.THROW, *Term TagExit*) an event have been thrown and no one have catched it \
        `exit_block/1 <http://www.eclipseclp.org/doc/bips/kernel/control/exit_block-1.html>`_.
        
            
      
    .. warning::
    
        After receiving FLUSHIO or WAITIO a new resume shall be issued 
        before creating variable or calling post_goal to complete the 
        goal execution and avoid unpredictable behavior.
    
    .. note::
    
        PyCLP have a different behavior compared to C/C++/Java default libraries provided by ECLiPsE.
        Standard resume execution destroys all the terms built before the execution of resume function while PyCLP is 
        preserving them creating a reference and storing the created term in this.
    
    .. seealso::
    
        `ec_resume,ec_resume1,ec_resume2 <http://www.eclipseclp.org/doc/embedding/embroot081.html>`_
            Resume functions in ECLiPSe in C interface library.
        
    
    """
    cdef int result
    cdef pyclp.pword in_pword
    cdef pyclp.ec_ref in_ref #Reference to store the value to be used for cut or yield
    global last_resume_result
    
    in_ref=toPython.ref.ref
    # Eclipse resume can be executed with GIL released
    if in_term is None:
        result=pyclp.ec_resume1(in_ref)
    else:
        result=pyclp.ec_resume2( (<Term?>in_term).get_pword(),in_ref)
    last_resume_result=result # Save last result in a global to be used in cut and init.
    if pyclp.PSUCCEED == result:
        return (SUCCEED, None)
    elif pyclp.PFAIL == result:
        return (FAIL,None)
    elif pyclp.PFLUSHIO== result:
        return (FLUSHIO,toPython.value())
    elif pyclp.PWAITIO ==result:
        return (WAITIO,toPython.value())
    elif pyclp.PYIELD ==result:
        return (YIELD,toPython.value())
    elif pyclp.PTHROW == result:
        returned_value=toPython.value()
        # if exception was raised in external predicate 
        # re-raise the exception otherwise return value
        if returned_value == Atom("python_error"):
            raise pyPredicatesException
        else:
            return (THROW,returned_value)
    else:
        assert False,"Unrecognized result from ec_resume"
        
        
def set_option(option,value):
    """
    Set options of eclipse engine. Equivalent to 
    `ec_set_option_long(int, long) <http://www.eclipseclp.org/doc/embedding/embroot079.html>`_
    and `int ec_set_option_ptr(int, char *) <http://www.eclipseclp.org/doc/embedding/embroot079.html>`_.
    
    This function must be used before initializing the ECLiPSe engine using :py:func:`pyclp.init`
    
    :param option: option supported:
        pyclp.OPTION_LOCALSIZE (value shall be int)
        pyclp.OPTION_GLOBALSIZE (value shall be int)
        pyclp.EC_OPTION_ECLIPSEDIR (value shall be a string)
        
    :param value: int or string depends on which option used.
    
    """
    if option == pyclp.EC_OPTION_ECLIPSEDIR:
        if isinstance(value,str):
            py_byte_string = tobytes(value)
            c_string = py_byte_string
            if pyclp.ec_set_option_ptr(option,c_string) != pyclp.PSUCCEED:
                raise pyclpEx("Invalid option in set_option")
        else:
            raise TypeError("value shall be a string")
    elif option == pyclp.EC_OPTION_LOCALSIZE or option == pyclp.EC_OPTION_GLOBALSIZE:
        if isinstance(value,int):
            ec_set_option_long(option,value)
        else:
            raise TypeError("value shall be a int")       
    else:
        raise pyclpEx("Unsupported option")
        
cdef class Term:
    """Class for prolog Term.
    Compound, Atom,PList and Var are derived from this class.
    User doesn't need to use directly it.
    """
    cdef Ref ref
    cdef pyclp.pword cached_pword
    def __init__(self,init_arg):
        cdef char* c_string
        cdef int index
        cdef pyclp.pword* array_pword 
        cdef pyclp.pword temp
        self.ref=Ref()
        if init_arg!=None:
            #String
            if isinstance(init_arg,str):
                py_byte_string = tobytes(init_arg)
                c_string = py_byte_string
                self.ref.set(pyclp.ec_string(c_string))
            #ints
            elif isinstance(init_arg,int):
                temp=pyclp.ec_long(init_arg)
                self.ref.set(temp)
            #Float
            elif isinstance(init_arg,float):
                self.ref.set(pyclp.ec_double(init_arg))
            else:
                raise TypeError("init argument shall be a string, integer or float")
    cdef pyclp.pword get_pword(self):
        return self.ref.get()
    cdef int set_pword(self,pyclp.pword in_pword) except -1:
        self.ref.set(in_pword)
    
    cdef int compare_pword(self,other) except? -12345 :
        if  isinstance(self,Term) and isinstance(other,Term):
            return pyclp.ec_compare((<Term>self).get_pword(),(<Term>other).get_pword())
        else:
            raise TypeError("Comparison between incompatible types")    
        
    def __cmp__(self,other):
        cdef Term self_casted
        if other is None:
            return 1
        else:
            self_casted=<Term?>self
            return self_casted.compare(other)
        
    def __richcmp__(self,other,op):
        """Rich comparison special function.
        If the other object is not a Term or derived from Term a TypeError will be raised.
        """
        cdef Term self_casted
        if other is None:
            if op==2:
                return False
            elif op==3:
                return True
            else:
                raise TypeError("This comparison operation is not supported with None. Only supported comparison == !=")
            
        self_casted=<Term?>self
        if op==2: # ==
            if self_casted.compare_pword(other)==0:
                return True
            else:
                return False  
        elif op==3: # !=
            if self_casted.compare_pword(other)==0:
                return False
            else:
                return True
        elif op==0: # <
            if self_casted.compare_pword(other) < 0:
                return True
            else:
                return False
        elif op==4: # >
            if self_casted.compare_pword(other) < 0:
                return False
            else:
                return True
        elif op==1: # <=
            if self_casted.compare_pword(other) <= 0:
                return True
            else:
                return False
        elif op==5: # >=
            if self_casted.compare_pword(other) >= 0:
                return True
            else:
                return False
                           
    def post_goal(self):
        """Post goal
        """
        pyclp.ec_post_goal(self.ref.get())
        

cdef object pword2object(pyclp.pword in_pword):
    cdef pyclp.dident dummy_dident
    cdef char* c_string = NULL
    cdef long int length = 0
    cdef long int c_int
    cdef double c_double
    cdef pyclp.pword tail
    cdef pyclp.pword head
    #Check if it is a list. 
    # List is before because a list is also a Compound term.
    if pyclp.ec_get_list(in_pword,&head,&tail)== pyclp.PSUCCEED or pyclp.ec_get_nil(in_pword) == pyclp.PSUCCEED:
        result=PList(None)
        (<PList>result).set_pword(in_pword)
    elif pyclp.ec_get_functor(in_pword,&dummy_dident)== pyclp.PSUCCEED:
        result=Compound(None)
        (<Compound>result).set_pword(in_pword)
    elif pyclp.ec_get_long(in_pword,&c_int)== pyclp.PSUCCEED:
        result=c_int
    # Check for Atom
    elif pyclp.ec_get_atom(in_pword,&dummy_dident)== pyclp.PSUCCEED:
        result=Atom(None)
        (<Atom>result).set_pword(in_pword)
    elif ec_get_string_length(in_pword,&c_string,&length)==pyclp.PSUCCEED:
        result=tounicode_with_length(c_string,length)
    elif pyclp.ec_get_double(in_pword,&c_double)== pyclp.PSUCCEED:
        result=c_double
    elif pyclp.ec_is_var(in_pword)== pyclp.PSUCCEED:
        result=Var()
        (<Var>result).set_pword(in_pword)   
    else:
        raise pyclpEx("Unknown type returned by eclipse") 
    return result        
  
            
cdef class Atom(Term):
    """
    Class to create Atom.
    
    :param atom_id: atom name
    :type atom_id: string
    
    """
    cdef pyclp.dident ec_dict_ptr
    def __init__(self,string):
        cdef char* c_string
        Term.__init__(self,None)
        if string is not None:
            if not isinstance(string,str):
                raise TypeError("Atom constructor accept only string")
            #Convert to byte array
            py_byte_string = tobytes(string)
            c_string = py_byte_string
            # Create dictionary entry
            self.ec_dict_ptr=pyclp.ec_did(c_string,0)
            # Convert to atom pword and store in Term
            self.set_pword(pyclp.ec_atom(self.ec_dict_ptr))
            
    cdef int set_pword(self,pyclp.pword in_pword) except -1:
        """Override Term.set_pword to get  
        """
        Term.set_pword(self,in_pword)
        # Get dictionary entry and store. This required when 
        # retrieving the result of a query.
        if ec_get_atom(self.get_pword(),&(self.ec_dict_ptr)) != pyclp.PSUCCEED:
            raise pyclpEx("Failed retrieving of Atom dictionary item")
            
    def __str__(self):
        """
        Convert to string for pretty printing
        """
        cdef char* Name
        Name=DidName(self.ec_dict_ptr)
        string=tounicode(Name)
        return string

cdef class PList(Term):
    """
    Class to create and read Prolog lists.
    
    When creating a new instance a list or tuple shall be provided.
    string,float and integer are automatically transformed in term as in
    Compound class.
    This class support iterator protocol this means that you can loop on the list as for python list
    
    **Example**::
        
        init()
        my_list=PList([1,2,3])
        for x in my_list:
            print(x)
            
    This class support retrieving values by indexing.
    
    **Example**::
        
        init()
        my_list=PList([1,2,3])
        print(my_list[3])
    
    .. warning::
        As for all other terms it is not possible to change their values.
        
    **Special cases**
    
    Empty prolog list can be created with PList([])
    To check that a returned PList is the empty list it avaiable the method :py:func:`pyclp.PList.isNil`
    
    **Head Tail**
    
    In prolog it is possible to define a list using the operator |
    
    **Example of prolog list and head tail decomposition**::
        
        %Prolog list example
        [1,2,3|myAtom]
        [1|A]
        %Also regular list have a tail: []
        [1,2,3]=[1,2,3|[]]
        %All list can be decomposed recursively as head tail couple
        [1,2,3]
        [1|[2,3]]
        [1|[2|[3]]]
        [1|[2|[3|[]]]]
        
    

        
    """
    def __init__(self,in_list,tail=[]):
        cdef int list_lenght
        cdef int index
        cdef pyclp.pword tail_pword
        cdef Term term_item
        Term.__init__(self,None)
        if in_list is not None:
            if not( isinstance(in_list,list) or isinstance(in_list,tuple)):
                raise TypeError("PList constructor accept only list or tuple")
            if not(isinstance(tail,list) or isinstance(tail,Term)):
                raise TypeError("PList tail shall be a list or a Term")
            list_lenght=len(in_list)
            # If lenght is 0 means an empty list --> []
            if (list_lenght == 0):
                tail_pword=pyclp.ec_nil()
            else:
                #Generate the starting tail for building the list
                if isinstance(tail,list) or isinstance(tail,tuple):
                    if len(tail) == 0:
                        tail_pword=pyclp.ec_nil()
                    else:
                        tail_pword=PList(tail)
                elif isinstance(tail,Term):
                        tail_pword=(<Term>tail).get_pword()
                else:
                    raise TypeError("PList tail shall be a list, tuple or  Term")
                #Convert not Term arguments
                for index in range(list_lenght-1,-1,-1):
                    item=in_list[index]
                    if isinstance(in_list[index],Term):
                        term_item= in_list[index]
                    #This to allow the coversion of nested lists.
                    elif isinstance(in_list[index],list) or isinstance(in_list[index],tuple):
                        term_item=PList(in_list[index])
                    else:
                        term_item=Term(in_list[index])
                    tail_pword=pyclp.ec_list(term_item.get_pword(),tail_pword)
            self.ref.set(tail_pword)

    def head_generator(self):
        cdef pyclp.pword tail
        cdef pyclp.pword head
        tail=self.get_pword()
        while(1):
            res=pyclp.ec_get_list(tail,&head,&tail)
            if res == pyclp.PSUCCEED:
                yield pword2object(head)
            else:
                return
    def head_tail_generator(self):
        cdef pyclp.pword tail
        cdef pyclp.pword head
        tail=self.get_pword()
        while(1):
            if pyclp.ec_get_list(tail,&head,&tail) != pyclp.PSUCCEED:
                return
            yield (pword2object(head),pword2object(tail))
    def __iter__(self):
        return self.head_generator()
    def __len__(self):
        cdef int index=0
        for x in self:
            index +=1
        return index
    def iterheadtail(self):
        """
        .. deprecated:: 1.5
        
        Replaced by :py:func:`PList.iterHeadTail`
        """
        return self.iterHeadTail()
    def iterHeadTail(self):
        """
        :returns: Iterator that returns a tuple (head,tail) where head is a element of the list and \
            tail is the remaining list
            
        """
        return self.head_tail_generator()
    
    cdef int get_head_tail(self,pyclp.pword *head_ptr,pyclp.pword *tail_ptr) except -1:
        if pyclp.ec_get_list(tail_ptr[0],head_ptr,tail_ptr) != pyclp.PSUCCEED:
            raise IndexError("Argument index out of range")
        return 1
            
    def __getitem__(self,index):
        """Implement python list protocol
        """
        cdef pyclp.pword tail
        cdef pyclp.pword head
        cdef pyclp.pword *array_pword
        cdef int c_index
        cdef int c_k=0
        
        c_index=<int?>index
        tail=self.get_pword()
        if c_index < 0:
            c_index=abs(c_index)
            # Create fifo 
            array_pword=<pyclp.pword *>(libc.stdlib.calloc(c_index,sizeof(pyclp.pword)))
            for c_k in range(c_index):
                self.get_head_tail(&head,&tail)
                array_pword[c_k]=head
            try:
                while(1):
                    self.get_head_tail(&head,&tail)
                    c_k+=1
                    c_k=c_k % c_index
                    array_pword[c_k]=head
            except IndexError:
                result=pword2object(array_pword[(c_k - c_index +1)%c_index])
            finally:
                libc.stdlib.free(array_pword)
            return result
            
        else:
            for c_k in range(c_index+1):
                self.get_head_tail(&head,&tail)
            return pword2object(head)
        
    def getListTail(self):
        """
        Convert a PList in a python list and the tail.
        
        **Examples**::
        
            prolog              python
            [1,2,3,f(1,2)]  --> ([1,2,3,Compound('f',1,2)],PList([]))
            [1,2,3|A]       --> ([1,2,3],Var())
            [1,2,3|dummy]   --> ([1,2,3],Atom('dummy'))
        
        :returns: a tuple (list,tail). First element is a python list containing each element of prolog list converted to a pyclp object \
            second element is a pyclp object representing the tail of prolog list.
        
        """
        returned_list=[]
        for head,tail in self.iterHeadTail():
            returned_list.append(head)
        return (returned_list,tail)
    cpdef bint isNil(self):
        """
        Check if the PList is the nil list --> []
        
        :returns: True if it is the empty list
        
        """
        if pyclp.ec_get_nil(self.get_pword()) == pyclp.PSUCCEED:
            return True
        else:
            return False
        
    def __str__(self):
        """
        Pretty printing of the list 
        """
        list_element,tail=self.getListTail()
        list_string=list(map(formatTermStr,list_element))
        #Convert all pyclp object to a string
        list_string=list(map(str,list_string))
        if isinstance(tail,PList):
            return "[{0}]".format(",".join(list_string))
        else: # Just in case the tail is not a nil list
            return "[{0}|{1}]".format(",".join(list_string),str(tail))    



    
cdef class Compound(Term):
    """
    Class to create compound terms.
    
    :param functor_string: A string with functor name.
    :param args: Any number of arguments of type integer, float,string and :py:class:`PList`, :py:class:`Atom`, :py:class:`Compound`
    
    len(arg) function called with a Compound object return the arity of compound term.
    
    This class support iterator protocol this means that you can iterate over term arguments 
    or get the arguments by index protocol:
    
    Example::
        
        init()
        my_compound=Compound("test",1,"dummy")
        for x in my_compound:
            print(x)
        print(my_compound[0])  # Print first argument.
    
    .. warning::
        As for all other terms it is not possible to change their values.
    
    """
    cdef pyclp.dident ec_dict_ptr
    def __init__(self,functor_string,*args):
        cdef int arity
        cdef int index
        cdef pyclp.pword * array_pword
        cdef char* c_string
        Term.__init__(self,None)
        args=list(args)
        if functor_string is not None:
            arity=len(args)
            if arity ==0: 
                raise pyclpEx("Arity of compound item shall be >0")
            #Convert not Term arguments
            for index in range(len(args)):
                if isinstance(args[index],list) or isinstance(args[index],tuple):
                    args[index]=PList(args[index])
                if not isinstance(args[index],Term):
                    args[index]=Term(args[index])
            #Create c array for eclipse function
            array_pword=<pyclp.pword *>(libc.stdlib.calloc(arity,sizeof(pyclp.pword)))
            for index in range(arity):
                array_pword[index]=(<Term>(args[index])).get_pword()
            py_byte_string = tobytes(functor_string)
            c_string = py_byte_string # type casting
            #Function dictionary element
            self.ec_dict_ptr=pyclp.ec_did(c_string,arity)
            #Generate pword of compound term
            self.ref.set(pyclp.ec_term_array(self.ec_dict_ptr,array_pword))
            libc.stdlib.free(array_pword)
    cpdef int arity(self):
        """
        :return: arity of Compound object.
        """
        return pyclp.DidArity(self.ec_dict_ptr)
    cdef int set_pword(self,pyclp.pword in_pword) except -1:
        Term.set_pword(self,in_pword)
        if ec_get_functor(self.get_pword(),&(self.ec_dict_ptr)) != pyclp.PSUCCEED:
            raise pyclpEx("Failed retrieving of Functor dictionary item")
    cdef object get_functor_string(self):
        cdef char* Name
        Name=DidName(self.ec_dict_ptr)
        string=tounicode(Name)
        return string
    def functor(self):
        """        
        :return: string storing name of functor
        """
        return self.get_functor_string()
    def arguments(self):
        """
        Return an iterator over compound term arguments
        """
        cdef int index
        cdef pyclp.pword arg_pword
        cdef int result
        for index in range(self.arity()):
            result=pyclp.ec_get_arg(index+1,self.get_pword(),&arg_pword)
            if result == pyclp.PSUCCEED:
                yield pword2object(arg_pword)
            elif result == pyclp.RANGE_ERROR:
                raise pyclpEx("Functor arity bigger than available args")
            else:
                raise pyclpEx("Unknow error during args getting")
    def __iter__(self):
        return self.arguments()
    def __len__(self):
        return self.arity()
    def __getitem__(self,index):
        cdef int arity
        cdef int result
        cdef pyclp.pword arg_pword
        cdef int c_index
        arity=self.arity()
        if not isinstance(index,int):
            raise TypeError("Index shall be a integer")
        else:
            c_index=<int>index
        if c_index < 0:
            c_index=arity+c_index
        if (<int>abs(c_index)) >=  arity:
            raise IndexError("Argument index out of range {0} arity {1}".format(index,arity))

        result=pyclp.ec_get_arg(c_index+1,self.get_pword(),&arg_pword)
        if result == pyclp.PSUCCEED:
            item_returned=pword2object(arg_pword)
        elif result == pyclp.RANGE_ERROR:
            raise pyclpEx("Range error while getting args probably data corruption")
        else:
            raise pyclpEx("Unknow error during args getting")
        
        return item_returned
            
    def __str__(self):
        cdef int arity
        cdef list list_args_text
        list_args_text=[]
        functor_string=self.get_functor_string()
        list_args_text=list(map(formatTermStr,self.arguments()))
        result=str.join(",",list_args_text)
        result="{0!s}({1})".format(functor_string,result)
        return result


            



                
        
cdef class Var(Term):
    """
    Class to create Prolog variable.
    """
    def __init__(self):
        Term.__init__(self,None)
    cpdef value(self):
        """
        :rtype: integer, float, string, :py:class:`PList`, :py:class:`Atom`, :py:class:`Compound`, None (if var is uninstantiated)
        
        """
        cdef pyclp.pword pword_value
        pword_value=self.ref.get()
        if pyclp.ec_is_var(pword_value)== pyclp.PSUCCEED:
            result=None
        else:
            result=pword2object(pword_value)
        return result    
    def __str__(self):
        """
        :return: Return pretty print string of object unified to this variable.\
        If variable is uninstantiated it returns '_'
        """
        var_value=self.value()
        if var_value is None:
            return "_"
        else:
            return str(var_value)
           


def unify(term1,term2):
    """
    Implements unify as described in 
    `ec_unify <http://www.eclipseclp.org/doc/embedding/embroot013.html>`_
    This function shall be used only inside python function tha are called
    from ECLiPSe
    
    :type term1: pyclp.Var, pyclp.Compound, pyclp.PList    
    :type term2: pyclp.Var, pyclp.Compound, pyclp.PList
    
    :returns: pyclp.SUCCEED or pyclp.FAIL  
    
    """
    cdef Term term1_term
    cdef Term term2_term
    
    if not isinstance(term1,Term):
        term1_term=Term(term1)
    else:
        term1_term=term1
        
    if not isinstance(term2,Term):
        term2_term=Term(term2)
    else:
        term2_term=term2
        
    if pyclp.PSUCCEED==pyclp.ec_unify(term1_term.get_pword(),term2_term.get_pword()):
        return SUCCEED
    else:
        return FAIL   
    
def addPythonFunction(eclipse_name,func):
    """
    Register a python function to be called from Eclipse using the predicate call_python.
    It shall be called after :py:func:`init`
    
    E.g. call_python(<eclipse_name>,<list of terms.>).
    
    The registered python function will be called as:
    
    <func>(<list of terms>)
    
    The registered function shall return pyclp.SUCCEED or any other value for reporting FAIL. 
    
    :param eclipse_name: str or byte string. Name to be used to with predicate call_python_function
    :param func: It shall be the function to be called. 
    
    """
    if not isinstance(func,types.FunctionType):
        raise TypeError("func shall be a function")
    
    if isinstance(eclipse_name,unicode) or isinstance(eclipse_name,str):
        python_pred2func[eclipse_name]=func
    else:
        raise ValueError("eclipse_name shall be a text, got %s" % type(string)) 
    
    
         
