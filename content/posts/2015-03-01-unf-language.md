---
title: UNF, an Untyped Functional Language Which is Going to Be Pretty Cool
date: "23 Nov 2014"
---

[adam-baker]: https://github.com/adambaker
[unf]: https://gitlab.com/jneen/unf

This language is gonna rock, I'm really excited about it.  I've talked to a number of people about unf, but this is the first I've sat down and written out what it's going to look like.  In particular, I owe [Adam Baker][adam-baker] a huge thanks for talking through the first version of this with me in January.

So here's [unf][]!

<!--fold-->

## Design goals

Unf is designed to sit in the intersection of repl tools (bash, zsh, ex, etc) and scripting languages.  It's intended to scale both *down* to small things typed at a repl, and *up* to large-ish programs, to the extent you'd want to build with ruby, python, clojure, etc.

It's an interpreted, pure, dynamic functional language, but for the most part it enables the user to behave as if they were in a language with a Hindley-Milner type-checker.  Open variants (called "tagwords"), paired with patterns and open methods, are the central strategy to manage polymorphism.

Importantly, unf aims to be obvious and easy to explain.  You should not need to study PLT to understand the core concepts of unf.  To that end, we try to avoid jargon and unclear language.

## Basic syntax

Variables are `kebab-case` identifiers, comments are from `#` to the end of the line, and values are assigned to variables with `+ my-variable = my-value`.  Indentation is not semantic (as that's not a repl-friendly feature), and newlines and semicolons (`;`) are syntactically equivalent.  All user functions are identifiers, and all symbols are reserved for the language.  There are no identifier keywords - all special directives will be prefixed with `@` (see `@method` and `@impl` below, for example).

## Chaining and Auto-Curry

For ergonomic purposes on a repl, it is critical to support typing small but powerful programs *linearly* - from left to right.  Prefix function calls usually require seeking left every time you want to use the result of an expression.  This gets very tedious very quickly.  Unf has two features that combine to make this easy.

The first is auto-currying.  Users of Haskell or ML will find this familiar.  If a function is called with fewer than its expected number of arguments, it returns a function expecting the rest of the arguments.  For example,

``` unf
(add 5) 3
```

calls the function `(add 5)` on the value 3, and returns 8.  Luckily the precedence works out such that you can just type `add 5 3` in this case and get on with your day.

The second is one of two infix operators in the language: `>`, pronounced "into", "reverse-apply", or simply "then".  This operator expects a value on the left and a function on the right, and simply applies the function to the value.  So the example above could be rewritten as:

``` unf
3 > add 5
```

Proper standard library design here is critical.  Functions to be used on the repl must be written to take their chained argument last, or else typing becomes much more difficult.  In the case that you are using a function in a way the author didn't expect, there's a sibling symbol to `>`, which is the special variable `-`.  If a segment in a `>`-chain contains `-`, the chained argument is placed there instead.  For example,

``` unf
foo > bar - baz
```

is equivalent to `bar foo baz`.  Alternately, you can bind a variable to a name for later within a chain:

``` unf
foo > x => bar > baz > add x
```

## Tagwords

Tagwords are the basic building block of all unf's user-space data structures.  Syntactically, a tagword is simply an identifier sigiled with a `.`, as in `.foo`.  When a tagword is called as a function, it creates a **tagged value**.  When a tagged value is called as a function, it appends the data to its internal list.  Let's look at an example:

``` unf
.foo # => .foo
.foo 1 # => .foo 1
.foo 1 2 # => .foo 1 2
```

In simple terms, they construct values.  Some examples of tagwords that will be commonly used in the standard library are:

``` unf
# booleans
.t
.f

# lists
.cons 1 (.cons 2 (.cons 3 .nil))

# result
.ok value
.err message

# option
.some value
.none
```

## Blocks and patterns

It's expected that lambda ("blocks"), will be a common thing to type on the repl, so it's been kept very lightweight.  A basic block looks like this:

``` unf
[ foo => some-expr-in foo ]
```

where the variable `foo` is bound inside the block.  Nested blocks have the usual properties of closures.

Things get a little more interesting with destructuring.  Rather than being a simple variable binder (`foo` above), the binder can also match and destructure tagged values over multiple clauses:

``` unf
+ map f = [ .nil => .nil; .cons x xs => .cons (f x) (map f xs) ]
```

Patterns can also include named pattern or type checks (sigiled with `%`):

``` unf
+ add = [ (x : %uint) (y : %uint) => add-uint x y ]
+ map (f:%callable) = ...
+ foo (bar : .bar _ _) = ...
```

All the native types will have `%`-sigiled type names, and there will be a way to implement your own named checks, which is still in design.

Patterns also have predicates on any part of the match that can use bound names from sub-matches:

``` unf
[ .foo (x ? gt 4 -) => ...; .foo x ? is-even x => ... ]
```

Blocks can be used with `>` to destructure arguments.  For example, here is unf's equivalent of an `if` expression:

``` unf
condition > [ .t => true-value; .f => false-value ]
```

The special pattern `_` acts as usual - it matches any value and binds no results.  A simple guard pattern can be implemented as

``` unf
[ _? cond-1 => val-1; _? cond-2 => val-2 ]
```

Naming all the variables and typing `=>` every time can be a pain on the repl, so for simple blocks unf provides a feature called **autoblocks** and the **autovar**.  Autoblocks are also delimited by square brackets, but contain no pattern and only a single clause.  The autovar, denoted `$`, is the argument to the closest-nested autoblock:

``` unf
list > map [ some-fn $ arg ]
```

Future plans may also include support for `$1`, `$2`, etc.

## Literals, macros, parsing macros

I strongly dislike macros that can hide in code.  I get really frustrated when I open a source file and see `(foo ...)` and can't tell whether it's a function or a macro until I read documentation.  For these reasons, extensible literals and macros in unf are all sigiled with `/`.  Here is a basic macro: the list constructor:

``` unf
/list[1 2 3]
```

The implementation syntax for these is still in design phase, but they will take after rust in that they will pattern-match against syntax, and result in new syntax.  I expect `list` to be so common that for that special case it is permitted to leave off the macro name: `/[1 2 3]` is equivalent.

Parsing macros use `{}` in place of normal macros' `[]`.  Definition syntax for these is also in design phase.  Rather than matching against syntax, parsing are responsible for parsing a raw string into a data structure representation.  When encountering one of these, the unf parser simply scans forward for the matching close brace (respecting `\{` and `\}`), and passes that string directly through to the implementation.  So for example, `/regex{\s+}` is a regular expression literal, `/string{foo}` is a string literal, etc.

Strings are common enough that they are the default.  Simply `{...}` is enough to quote a string literal.  But since many string literals are much simpler, parsing macros also support `'` as a one-sided delimiter that scans to whitespace or one of the delimiters `]` or `)`.  Here are some examples:

``` unf
/string{foo} # => the string {foo}
'foo # => the string {foo}
/r{\w+} # a regex that matches identifiers
/r'\w+ # equivalent
```

An alternate syntax using `"` will also be provided, which will support backslash escapes as well as interpolation syntax which is still in design.

## Let, recursion, laziness

Unf is not a lazy language (mostly).  If you want a lazy expression, simply prefix it with `~`.  Evaluation of lazy expressions is deferred until a pattern-match needs the value.  A non-pattern-matching function called with a lazy value results in a further lazy value.

A **let-expression** looks like `+ name = value; expr`.  You can bind multiple names this way in an expression:

``` unf
+ foo =
  + bar = 1
  + baz = 2
  zot bar baz

+ foo bar = baz
```

Let-bound function arguments can pattern match in the same way as lambda arguments.  Multiple definitions of the same function in a sequence of let bindings behaves the same as multiple clauses in a lambda.

Unf supports **let-recursion**: a variable bound in a let-expression (`+ name = value`) can use itself in its definition.  A sequence of let-expressions can also refer to each other recursively.  This generally works fine when the values defined are all functions, but it can break down when the values use recursive references strictly:

``` unf
# the lazy y-combinator (.o_o).
+ fix f = + x = f x; x
```

In this case, unf will detect the recursion, and the second `x` will be treated as a lazy reference.  Any reference loop in a sequence of lets will be closed by converting the last link to a lazy reference.  This makes it simple to create graph-like structures.

Tail call optimization is supported and encouraged.

Definitions that begin with `>` are desugared as follows:

``` unf
+ foo = > bar > baz

# equivalent to
+ foo x = x > bar > baz
```

## Flags, Optional Arguments, Maps

Flags are identifiers that begin with `-`.  A flag-pair is a sequence of a flag and an expression.  When a flag-pair is called with another flag-pair argument, it merges that pair into its internal record.  For example,

``` unf
-foo 1 # => (-foo 1)
-foo 1 -bar 2 # => (-foo 1 -bar 2)
```

Flags are used for keyword arguments.  Given a function defined as:

``` unf
+ foo -bar x -baz y = ...
```

it can be called as:

``` unf
foo -baz 3 -bar 2
```

Since function calls are not resolved until all arguments are given, the expression `foo -baz 3` will return a lambda that expects a `-bar ...` keyword argument.

Splats for keyword arguments are still in design phase, as are optional arguments and boolean flags. The latter will automatically be converted to `.some`/`.none` or `.t`/`.f`.

I should be note here that flags - in particular optional arguments - are **complex**, especially when paired with auto-currying.  But they are a critical tool for implementing repl interfaces.  So they are supported, but are generally discouraged unless you are exporting a function to be used on a repl.

## Methods, Protocols, Implementations

A common problem in general-purpose languages is to define an interface that can be implemented by users later.  This is the purpose of, for example, `defprotocol` and multimethods in clojure, most good uses of interfaces in java, and typeclasses in Haskell.  A method declaration in unf looks like this:

``` unf
@method map _ %
```

This is read as: `map` is a method that takes two arguments, and dispatches on the second argument.  Some implementations of this method might look like:

``` unf
@impl map f (.cons x xs) = .cons (f x) (map f xs)
@impl map f .nil = .nil
@impl map f (.some x) = .some (f x)
@impl map .none = .none
@impl map f (.ok x) = .ok (f x)
@impl map f (.err e) = .err e
```

In implementation definitions, only the dispatched argument can be pattern-matched, and only simple tag destructures, native type checks, and default (`_`) are allowed.  Open recursion, hower is both allowed and encouraged.  Multiple dispatch is also planned, but not yet designed.

Methods contain a global registry of implementations, so implementations can only be specified at the top-level of a module.  This restriction might be lifted in the future, but that could cause other complications.

## Pipes, Lifting, I/O

Unf has two infix operators - one is reverse-apply, which was discussed earlier, and the other is the overloadable pipe operator.  The following desugars apply:

``` unf
foo | bar
foo | x => bar x

# equivalent to
pipe bar foo
pipe-fn [ x => bar x ] foo
```

You can define `pipe` and `pipe-fn` on a particular data structure to support piping - `pipe-fn` gets called if the first argument is a function, using method dispatch as described above.  This is useful for abstracting over computation models - you might pipe together parsers, streams, stateful actions, etc.  This can yield something similar to Haskell's `do`-syntax:

``` unf
foo | foo-val =>
bar | bar-val =>
baz foo-val bar-val
```

But this is kind of a pain to write all the time.  That's why I stole bang notation from idris.  Bang notation is a syntactic sugar that automatically lifts expressions into piped expressions.  So the previous example could be written:

``` unf
baz !foo !bar
```

Bang expressions are lifted to the nearest pipe, lambda, or let-definition.

Unf is a *pure* langauge - that is, every function called with the same arguments always returns the same results.  This can make side-effecting actions complicated.  Unf's I/O model uses pipes to chain together actions.  For example, to move some files from a directory to another, you would write

``` unf
ls '/tmp/files | each (mv './some-dir)
```

The function `each` takes a list of functions that return actions and performs them one-by-one, and sends a list of the results into its pipe.

## Concurrency

This part is pending a lot of design work, but unf is intended to ship with erlang-style actors.  Most of the decisions already made lend themselves rather easily to this approach.

## Modules, Scripts, Importing, Private Definitions

A module is a collection of definitions, usually living in a file.  A file can either be a script or export multiple modules.

A module is declared as follows:

``` unf
@module my-module-name arg-1 arg-2 [
  + foo = 1
  + bar = 2
  @method ...
  @impl ...
]
```

For the root module of a file, the square brackets can be omitted.  A module is imported into another module with the `@import` directive:

``` unf
@module my-module arg-1
@import another-module arg-1
@import yet-another-module [ name other-name ]
@import last-one @all # imports everything that's exported
```

Module arguments must be statically resolvable, and can only depend on top-level definitions and other module arguments (but they can be functions, which allows for all sorts of interesting designs).  Conflicting names in later imports shadow ones from earlier ones.  Names can either be imported into the namespace or accessed by `module-name/member-name`.

Definitions in a module can be made private by using `-` instead of `+` in the definition syntax.  Tagwords whose names start with `-` (as in `.-foo`) are also private to the module - pattern matches in other modules against those tagwords will not match.

A *script* is a different kind of unf file.  A script has a `@script` declaration at the top, and consists of a list of expressions which are all evaluated.  If those expressions evaluate to actions, those actions are performed one at a time.  Eventually the `@script` declaration will also be able to specify command-line arguments and environment imports, but that is also in design.

## Putting it all together

Unf is not a small language.  My goal was to include enough features to be useful, add extensibility in the right places, but also guarantee a consistent look with predictable behaviors.  Unf is still in active development, and I could use a whole lot of help, both filling in the design gaps here and actually churning out the implementation.  Please ping me on twitter (`@jneen_`) with any feedback or if you want to get involved!
