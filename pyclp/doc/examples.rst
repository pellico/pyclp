Examples
########

For a better understanding of interface to ECLiPSe system read description of C interface.

Simple Example
**************

A simple example of unification::

   from pyclp import *
   init()                        #Init ECLiPSe engine
   myVar=Var()                   #Create a prolog variable
   my_goal=Compound("=",myVar,1) #Create goal
   my_goal.post_goal()                 #Post goal
   result,dummy =resume()        #Resume execution 
                                 #of ECLiPSe engine
   if result != SUCCEED:
     raise
   print(myVar.value +1)               #myVar.value get the Var value back.
   print(myVar)                        #print value
   cleanup()                     #Shutdown ECLiPSe engine

Compound class is used to create compound term. First argument is a string representing the functor followed by the argument.


Search Solution
***************
A more complex example using ic library and search procedure::
    
    init()                                         # Init ECLiPSe engine
    Compound("lib",Atom("ic")).post_goal()         # Load ic library
    A_var=Var()                                    # Create variable A
    B_var=Var()                                    # Create variable B
    Compound("#::",PList([A_var,B_var]),\
             Compound("..",1,10)).post_goal()      # [A,B]#::1..10
    Compound("#<",A_var,B_var).post_goal()         # A#<B
    Compound("#=",A_var,5).post_goal()             # A#=5
    Compound("labeling",\
             PList([A_var,B_var])).post_goal()     # labeling([A,B])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):
        print(B_var)
        Atom("fail").post_goal()                   # Post fail for backtracking over solutions
         
    cleanup()                                      # Shutdown ECLiPSe engine
    
.. _cut-example:
    
Cut Example
***********

How to cut solutions::

    init() # Init ECLiPSe engine
    Compound("lib","lists").post_goal()                 # lib(lists)
    A_var=Var()                                         # Create variable A
    Compound("member",A_var,PList([1,2,3])).post_goal() # member(A_var,[1,2,3])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):                       
        if A_var.value()==2:                            # When value == 2 cut all other solutions.
            cut()
            break
        Atom("fail").post_goal()                        # Post fail for backtracking over solutions
    B_var=Var()                                         # Create variable B
    Compound("is",B_var,\
             Compound("+",A_var,1)).post_goal()         # B_Var is A_var + 1
    resume()
    print(A_var,B_var)
    cleanup()                                           #Shutdown ECLiPSe engine 
    
    
Input Example
*************

Receive data from stdout stream::

    init()                                          # Init ECLiPSe engine
    Compound("writeln","Hello world").post_goal()
    result,stream_num=resume()
    if result != FLUSHIO:                           # Check for output data
        raise
    else:
        outStream=Stream(stream_num)                # Open output stream
        data=outStream.readall()                    # Return data in a bytes object
        print(data) 
        outStream.close()                           # Not required but implemented to support RawIO protocol
    cleanup()                                       # Shutdown ECLiPSe engine
    
Input/Output Example
********************

Input to stdin stream and output from stdout stream::

    print ("I/O Example")
    init()                                # Init ECLiPSe engine
    stdin=Stream('stdin')                 # Open stdin stream
    stdout=Stream('stdout')               # Open stdout stream
    A_var=Var()                           # Variable where to store the input term.
    Compound ("read",A_var).post_goal()   # read(A)
    Compound("writeln",A_var).post_goal() # writeln(A)  

    while (1):                          
        result,stream=resume()
        if result==WAITIO:                # ECLiPSe is waiting for data
            stdin.write(b'Hello_World')
        elif result==FLUSHIO:
            print(stdout.readall())       # ECLiPSe send data to stdout stream
        else:
            break                     
    stdin.close()                         # Not required but implemented to support RawIO protocol
    stdout.close()                        # Not required but implemented to support RawIO protocol
    cleanup()                             # Shutdown ECLiPSe engine
