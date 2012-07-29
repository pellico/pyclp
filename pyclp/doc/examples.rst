Examples
########

For a better understanding of interface to ECLiPSe system read description of C interface.

Simple Example
**************

A simple example of unification::

   pyclp.init()                        #Init ECLiPSe engine
   myVar=pyclp.Var()                   #Create a prolog variable
   my_goal=pyclp.Compound("=",myVar,1) #Create goal
   my_goal.post_goal()                 #Post goal
   result,dummy =pyclp.resume()        #Resume execution 
                                       #of ECLiPSe engine
   if result != pyclp.SUCCEED:
     raise
   print(myVar.value +1)               #myVar.value get the Var value back.
   print(myVar)                        #print value
   pyclp.cleanup()                     #Shutdown ECLiPSe engine

Compound class is used to create compound term. First argument is a string representing the functor followed by the argument.


Search Solution
***************
A more complex example using ic library and search procedure::

    pyclp.init()                                         # Init ECLiPSe engine
    pyclp.Compound("lib",pyclp.Atom("ic")).post_goal()   # Load ic library
    A_var=pyclp.Var()                                    # Create variable A
    B_var=pyclp.Var()                                    # Create variable B
    pyclp.Compound("#::",pyclp.PList([A_var,B_var]),pyclp.Compound("..",1,10)).post_goal() # [A,B]#::1..10
    pyclp.Compound("#<",A_var,B_var).post_goal()         # A#<B
    pyclp.Compound("#=",A_var,5).post_goal()             # A#=5
    pyclp.Compound("labeling",pyclp.PList([A_var,B_var])).post_goal()  # labeling([A,B])
    # Loop on all solution and print them.
    while (pyclp.resume()[0]==pyclp.SUCCEED):
        print(B_var)
        pyclp.Atom("fail").post_goal()                   # Post fail for backtracking over solutions
         
    pyclp.cleanup()                                      #Shutdown ECLiPSe engine
    
    

