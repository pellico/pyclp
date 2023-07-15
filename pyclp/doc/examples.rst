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
    
    from pyclp import *
    init()                                         # Init ECLiPSe engine
    Compound("lib",Atom("ic")).post_goal()   # Load ic library
    A_var=Var()                                    # Create variable A
    B_var=Var()                                    # Create variable B
    Compound("#::",PList([A_var,B_var]),Compound("..",1,10)).post_goal() # [A,B]#::1..10
    Compound("#<",A_var,B_var).post_goal()         # A#<B
    Compound("#=",A_var,5).post_goal()             # A#=5
    Compound("labeling",PList([A_var,B_var])).post_goal()  # labeling([A,B])
    # Loop on all solution and print them.
    while (resume()[0]==SUCCEED):
        print(B_var)
        Atom("fail").post_goal()                   # Post fail for backtracking over solutions
         
    cleanup()                                      #Shutdown ECLiPSe engine
    
.. _cut-example:
    
Cut Example
***********

How to cut solutions::

    print("Cut Example")
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
