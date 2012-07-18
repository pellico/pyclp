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

