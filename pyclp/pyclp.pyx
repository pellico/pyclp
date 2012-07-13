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

cimport pyclp
cimport cpython
cimport libc.stdlib
import io
import weakref
import string

#Store a global reference used to return data from eclipse engine.
cdef Var toPython=None
last_resume_result=None 
# Store a weak reference in order to support cleanup function
# All reference need to be destroyed before cleanup of eclipse engine
all_active_refs=weakref.WeakSet() 

SUCCEED=True
FLUSHIO=pyclp.PFLUSHIO
WAITIO=pyclp.PWAITIO
FAIL=False
YIELD=pyclp.PYIELD

class pyclpEx(Exception):
    def __init__(self,arg):
        self.msg=arg
    def __str__(self):
        return self.msg

cdef unicode tounicode(char* s):
    return s.decode('ascii', 'strict')

cdef unicode tounicode_with_length(
        char* s, size_t length):
    return s[:length].decode('ascii', 'strict')

#===============================================================================
# cdef unicode tounicode_with_length_and_free(
#        char* s, size_t length):
#    try:
#        return s[:length].decode('ascii', 'strict')
#    finally:
#        libc.stdlib.free(s)
#===============================================================================
        
cdef bytes tobytes(unicode string):
    py_byte_string = string.encode('ascii')
    return py_byte_string

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
        #cdef char* buffer
        cdef int lenght
        cdef int num_bytes_read
        lenght=ec_queue_avail(<int>self.stream_num)
        if n==0:
            return bytes(0)
        elif n > 0:
            # Don't read more buffer than available.
            if lenght > n:
                lenght=n
        #buffer=<char*>libc.stdlib.calloc(lenght,1)
        buffer=bytes(lenght)
        num_bytes_read=pyclp.ec_queue_read(<int> self.stream_num,<char*>buffer,lenght)
        if num_bytes_read < 0 :
            raise IOError(n)
        #r=buffer[0:lenght]
        #libc.stdlib.free(buffer)
        return buffer
    def write(self,buffer):
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
    """
    global toPython
    last_resume_result=None #It shall be None at init.Defensive programming
    pyclp.ec_set_option_long(pyclp.EC_OPTION_IO, pyclp.MEMORY_IO)
    if (pyclp.ec_init()):
        return False
    else:
        recreate_all_refs()
        if toPython is None:
            toPython=Var()
        return True

def cleanup():
    """This shutdown the Eclipse engine.
    Any operation on pyclp object or class could crash the program.
    If after a cleanup it is called again init() all terms created before the cleanup are not valid and they need 
    to be rebuilt.
    """
    destroy_all_refs()
    last_resume_result=None
    if (pyclp.ec_cleanup()):
        return False
    else:
        return True

def cut():
    """
    Cut all choice point of succeeded goal.
    Equivalent to void ec_cut_to_chp(ec_ref)
    It can be called only if previous resume call SUCCEED.
    """
    if last_resume_result==pyclp.PSUCCEED:
        pyclp.ec_cut_to_chp((<Var>toPython).ref.ref)
    else:
        raise pyclpEx("Cut it is possible only after a resume that returns SUCCEED.")
    

def resume(in_term=None):
    """Resume eclipse engine.
    Include the functionality of ec_resume,ec_resume1,ec_resume2. 
    For more details please refer to "Embedding and Interfacing Manual"  
    It accepts optional argument in_term. Used to return a value to the prolog predicate yield/2
    Return:
        (pyclp.SUCCEED,None): if execution succeed (equivalent to True). 
                       In this case it is possible to call pyclp.cut()
        (pyclp.FAIL,None): if the goal fails.
        (pyclp.FLUSHIO,int stream_number): if some data is present in stream 
                                            identified by <stream_number>
        (pyclp.WAITIO,int stream_number): if eclipse engine try to read data 
                                          from stream identified by stream_number
        (pyclp.PYIELD, yield_returned_value): in case of predicate call YIELD/2.
    Important: After receiving FLUSHIO or WAITIO a new resume shall be issued
               before creating variable or calling post_goal to avoid undefined
                /unpredictable behavior 
    """
    cdef int result
    cdef pyclp.pword in_pword
    cdef pyclp.ec_ref in_ref #Reference to store the value to be used for cut or yield
    global last_resume_result
    in_ref=toPython.ref.ref
    if in_term is None:
        result=pyclp.ec_resume1(in_ref)
    else:
        result=pyclp.ec_resume2( (<Term?>in_term).get_pword(),(<Ref>toPython).ref)
    last_resume_result=result
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
    else:
        assert False,"Unrecognized result from ec_resume"
        
cdef class Term:
    """Class for prolog Term.
    Compound, Atom,PList and Var are derived from this class.
    User doesn't need to use directly it.
    """
    cdef Ref ref
    cdef pyclp.pword cached_pword
    def __init__(self,init_arg=None):
        cdef char* c_string
        cdef int index
        cdef pyclp.pword* array_pword 
        cdef pyclp.pword temp
        self.ref=Ref()
        if init_arg:
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
        pyclp.ec_post_goal(self.ref.get())
        

cdef extern object pword2object(pyclp.pword in_pword)    
            
cdef class Atom(Term):
    """Class to create Atom.
    This is required to distinguish strings from atoms.
    In normal use case the user shall provide a string when creating the object 
    """
    cdef pyclp.dident ec_dict_ptr
    def __init__(self,string=None):
        cdef char* c_string
        Term.__init__(self)
        if string is not None:
            if not isinstance(string,str):
                raise TypeError("Atom constructor accept only string")
            py_byte_string = tobytes(string)
            c_string = py_byte_string
            self.ec_dict_ptr=pyclp.ec_did(c_string,0)
            self.set_pword(pyclp.ec_atom(self.ec_dict_ptr))
    cdef int set_pword(self,pyclp.pword in_pword) except -1:
        Term.set_pword(self,in_pword)
        if ec_get_atom(self.get_pword(),&(self.ec_dict_ptr)) != pyclp.PSUCCEED:
            raise pyclpEx("Failed retrieving of Atom dictionary item")
            
    def __str__(self):
        cdef char* Name
        Name=DidName(self.ec_dict_ptr)
        string=tounicode(Name)
        return string

cdef class PList(Term):
    """Class to create and read Prolog lists.
    When creating a new instance a list or tuple shall be provided.
    string,float and integer are automatically transformed in term as in
    Compound class.
    As for Compound objects, at
    Supported operation:
        all comparison as for compare/3 (see Eclipse documentation)
        iterator over items in the list e.g. for x in PList([1,2,3,4]).
        iterheadtail() return a iterator over tuple (head,tail)
        p[index] indexed access of items in the list 
    """
    def __init__(self,in_list=None):
        cdef int list_lenght
        cdef int index
        cdef pyclp.pword tail
        Term.__init__(self)
        if in_list is not None:
            if not( isinstance(in_list,list) or isinstance(in_list,tuple)):
                raise TypeError("PList constructor accept only list or tuple")
            list_lenght=len(in_list)
            tail=pyclp.ec_nil()
            #Convert not Term arguments
            for index in range(list_lenght-1,-1,-1):
                item=in_list[index]
                if isinstance(in_list[index],Term):
                    term_item= in_list[index]
                else:
                    term_item=Term(in_list[index])
                tail=pyclp.ec_list((<Term>term_item).get_pword(),tail)
            self.ref.set(tail)

    def head_generator(self):
        cdef pyclp.pword tail
        cdef pyclp.pword head
        cdef pyclp.pword new_tail
        tail=self.get_pword()
        while(1):
            if pyclp.ec_get_nil(tail)== pyclp.PSUCCEED: #End of the list
                return 
            if pyclp.ec_get_list(tail,&head,&tail) != pyclp.PSUCCEED:
                raise pyclpEx("Unexpected error during prolog list recovering")
            yield pword2object(head)
    def head_tail_generator(self):
        cdef pyclp.pword tail
        cdef pyclp.pword head
        cdef pyclp.pword new_tail
        tail=self.get_pword()
        while(1):
            if pyclp.ec_get_nil(tail)== pyclp.PSUCCEED: #End of the list
                return 
            if pyclp.ec_get_list(tail,&head,&tail) != pyclp.PSUCCEED:
                raise pyclpEx("Unexpected error during prolog list recovering")
            yield (pword2object(head),pword2object(tail))
    def __iter__(self):
        return self.head_generator()
    def __len__(self):
        cdef int index=0
        for x in self:
            index +=1
        return index
    def iterheadtail(self):
        return self.head_tail_generator()
    
    cdef int get_head_tail(self,pyclp.pword *head_ptr,pyclp.pword *tail_ptr) except -1:
        if pyclp.ec_get_nil(tail_ptr[0])== pyclp.PSUCCEED: #End of the list
            raise IndexError("Argument index out of range")
        if pyclp.ec_get_list(tail_ptr[0],head_ptr,tail_ptr) != pyclp.PSUCCEED:
            raise pyclpEx("Unexpected error during prolog list recovering")
        return 1
            
    def __getitem__(self,index):
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
    def __str__(self):
        list_element=list(self)
        list_string=list(map(formatTermStr,list_element))
        return "[{0}]".format(",".join(list_string))
        


    
cdef class Compound(Term):
    cdef pyclp.dident ec_dict_ptr
    def __init__(self,functor_string=None,*args):
        cdef int arity
        cdef int index
        cdef pyclp.pword * array_pword
        cdef char* c_string
        Term.__init__(self)
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
            #Create c array fro eclipse function
            array_pword=<pyclp.pword *>(libc.stdlib.calloc(arity,sizeof(pyclp.pword)))
            for index in range(arity):
                array_pword[index]=(<Term>(args[index])).get_pword()
            py_byte_string = tobytes(functor_string)
            c_string = py_byte_string # type casting
            #Function dictionarry element
            self.ec_dict_ptr=pyclp.ec_did(c_string,arity)
            #Generte pword of compound term
            self.ref.set(pyclp.ec_term_array(self.ec_dict_ptr,array_pword))
            libc.stdlib.free(array_pword)
    cdef int arity(self):
        return pyclp.DidArity(self.ec_dict_ptr)
    property arity:
        def __get__(self):
            return self.arity()
    cdef int set_pword(self,pyclp.pword in_pword) except -1:
        Term.set_pword(self,in_pword)
        if ec_get_functor(self.get_pword(),&(self.ec_dict_ptr)) != pyclp.PSUCCEED:
            raise pyclpEx("Failed retrieving of Functor dictionary item")
    cdef object get_functor_string(self):
        cdef char* Name
        Name=DidName(self.ec_dict_ptr)
        string=tounicode(Name)
        return string
    property functor:
        def __get__(self):
            return self.get_functor_string()
    def arguments(self):
        """Return an iterator over compound term arguments
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
        if abs(c_index) >=  arity:
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


            



cdef object pword2object(pyclp.pword in_pword):
    cdef pyclp.dident dummy_dident
    cdef char* c_string = NULL
    cdef long int length = 0
    cdef long int c_int
    cdef double c_double
    cdef pyclp.pword tail
    cdef pyclp.pword head
    #Check if it is a Compound term
    if pyclp.ec_get_list(in_pword,&head,&tail)== pyclp.PSUCCEED:
        result=PList()
        (<PList>result).set_pword(in_pword)
    elif pyclp.ec_get_functor(in_pword,&dummy_dident)== pyclp.PSUCCEED:
        result=Compound()
        (<Compound>result).set_pword(in_pword)
    elif pyclp.ec_get_long(in_pword,&c_int)== pyclp.PSUCCEED:
        result=c_int
    elif pyclp.ec_get_nil(in_pword) == pyclp.PSUCCEED:
        result=() 
    # Check for Atom
    elif pyclp.ec_get_atom(in_pword,&dummy_dident)== pyclp.PSUCCEED:
        result=Atom()
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
                
        
cdef class Var(Term):
    """Class to create Prolog variable.
    It has only one property value to retrieve the value unified with the variable
    None is returned in case the variable is uninstantiated.
    E.g.
    p=Var()
    p.value
    None
    """
    def __init__(self):
        Term.__init__(self)
    cdef value(self):
        cdef pyclp.pword pword_value
        pword_value=self.ref.get()
        if pyclp.ec_is_var(pword_value)== pyclp.PSUCCEED:
            result=None
        else:
            result=pword2object(pword_value)
        return result    
        
    property value:
        def __get__(self):
            return self.value()
    def __str__(self):
        var_value=self.value()
        if var_value is None:
            return "_"
        else:
            return str(self.value())               
