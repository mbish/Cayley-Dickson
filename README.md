Cayley-Dickson Shell
============================

This is pretty much just a perl eval loop so: if you can perl-it you can do it.


Usage
-----
****
**Controls**

If you have readline installed you should get most of the tools for looking through your command history other wise hit return to end a command.

Variable declerations are done with:

  our $x = 2

and are always refered to with a sigil ($) in front of their name:

  $a = $b 

and things like this are perfectly valid.

*********
**Element**
   * Elements can be specified as real numbers or pairs of the form [a,b] where a and b are elements of the same dimension
   * Note: In a pair, you must pair an element with another element of the same dimension
   * Examples: 1 = 1, [1,2] = 1 + 2i, [[1,2],[1,2]] = 1 + 2i + 1j + 2k 

****
**Functions**

<pre>
   * mult(a,b) - multiplies two elements
   * conj(a)   - conjugates an element
   * neg(a)    - returns negation of an element
   * add(a,b)  - adds two elements
</pre>
****
**Notation**

ei is used as the basis of the i'th dimension in a vector space with e0 being the real part
****
**Examples**


    Basics:
        >> our $a = mult(2,2)
        4e0
        >> mult([1,2],[3,$a])
        -5e0 + 10e1

    Observing loss of commutitivty in quaternions:
        >> our $a = [[1,2],[3,4]]
        1e0 + 2e1 + 3e2 + 4e3

        >> our $b = [[5,6],[7,8]]
        5e0 + 6e1 + 7e2 + 8e3

        >> mult($a, $b)
        9e0 + 12e1 + 13e2 + 24e3 

        >> mult($b, $a)
        9e0 + 20e1 + 29e2 + 32e3
        
Dependencies
------------
A readline package for perl is very helpful for editing and keeping track of history.
