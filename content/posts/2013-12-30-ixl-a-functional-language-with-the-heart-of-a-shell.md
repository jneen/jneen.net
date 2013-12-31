---
title: 'ixl: a functional language with the heart of a shell'
date: 30 Dec 2013
---

[mcilroy]: http://www.leancrew.com/all-this/2011/12/more-shell-less-egg/
[to the left]: /posts/2012-02-13-shell-usability-what-tcl-is-missing

I have a confession to make: I secretly love bash.  Sure, it's impossible to use for large programs, takes tons of configuration to make work correctly, is filled with syntactic gotchas and has only one type (don't talk to me about bash arrays and assoc-arrays...).  It has a simplicity to it, and the left-to-right chaining makes it really easy to compose small programs into [sophisticated ones][mcilroy] that are easy to read, decent to reason about, and incredibly easy to type.  Barewords ease the typing burden of quoting.

I also love haskell.  The merits of functional programming have been talked into the ground already, but particularly important is the emphasis on creating a large common understanding between the programmer and the compiler.  But on the repl, it can be awkward to work with, since you have to [keep jumping to the left][to the left] to use each subsequent expression, and properly quote and balance parentheses.

So, without further ado, I'd like to introduce `ixl`, a language optimized for heavy repl usage, and also appropriate for writing large programs.  During my time off, I'll be working on a proof-of-concept implementation targetting Haskell Core.  **Your feedback would be super appreciated!**

Here's a little taste:

``` ixl
# familiar hash-style comments

# basic stuff
add 3 4

# chaining syntax
+ to-celsius %f = $f > sub 32 > mul 5 > div 9

# lambda syntax
$list > map [ %el => add 3 $el ]

# implicit arguments
$list > map [ add 3 $ ]

# enum types
@enum List 'a [
  .nil : List 'a
  .cons : 'a, List 'a -> List 'a
]

# lambda patterns
+ sum = [ .nil => 0; .cons %h %t => sum $t > add $h ]
# or better, using tuples and tail recursion
+ sum %list =
  + sum-iter %n = [ .nil => $n; => .cons (%h, %t) => $t > sum-iter (add $h $n) ]
  sum-iter $list 0

# currying
$list > map (add 3)

# laziness
+ fibs : List Int = $fibs > zip-with add (tail $fibs) > .cons 1 > .cons 1
+ fib %n = $fibs > at-index $n

# monad chaining and string syntax
+ main %argv = readline | %input => print "{Hello, $input}

# type-directed barewords (single ' is the empty string)
$input > replace awesome super-awesome
# since `awesome` is inferred to be of type Regex, this is equivalent to
$input > replace (Regex.parse 'awesome) [ %match => 'super-awesome ]

# /foo/bar is inferred to have type Filename, and is interpreted as such.
read /foo/bar | print
```

<!--fold-->

A few notes on the syntax, since it is very different from many other languages out there:

* For runtime expressions, the emphasis is on compactness and left-to-right writeability.  Imagine writing each of these lines on a shell.  On a shell, barewords are far more common than variables, which is why variables and patterns require sigils.
* For parts that you would normally put in a library, the emphasis is on consistency and readability.  This includes the type language and the `@enum` and `@struct` keywords.
* Tuples are intended to be recursive (one of my personal bugaboos with haskell...).  This means that `('a, ())` is equivalent to `'a`, and `('a, ('b, 'c))` is equivalent to `('a, 'b, 'c)`.  `(('a, 'b), 'c)` is semantically different, though.  This will allow making arbitrary tuples instances of typeclasses.
