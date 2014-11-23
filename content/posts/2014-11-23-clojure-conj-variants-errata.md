---
title: 'clojure/conj variants errata'
date: "23 Nov 2014"
---

[video]: https://www.youtube.com/watch?v=ZQkIWWTygio "the talk on youtube"
[slides]: https://github.com/jneen/variants-slides "the slides"
[jneen-gist]: https://gist.github.com/jneen/f9f6ca49bdf8efc39ec2
[ambrose-gist]: https://gist.github.com/frenchy64/c7e1a318c67baf7576c5

[@ambrosebs]: https://twitter.com/ambrosebs
[@swannodette]: https://twitter.com/swannodette
[@bobpoekert]: https://twitter.com/bobpoekert

I [gave a talk][video] at clojure/conj about variants in clojure! ([slides][])

I want to follow up on a few pieces I think got left out - whether by my own lacking or by lack of time.

<!--fold-->

## variants and multimethods

I got two questions I wish I could have expanded on way more.  At 33:25 I was asked about how to handle extensibility with open variants, and at 35:10 I was asked how multimethods fit into the picture.  The good news is this: multimethods are a fantastic way to allow others to extend open variants!  After a few [very fruitful][jneen-gist] [conversations][ambrose-gist] with [@bobpoekert][], [@ambrosebs][], and [@swannodette][], there seems to be a pretty straightforward strategy that will work with core.typed:

``` clojure
; the dispatch function is `first`, to grab the tag out of the variant
(defmulti perform-command first)

; each method has to destructure the variant, and will almost certainly
; ignore the tag, since it's already been matched as the dispatch value
(defmethod perform-command :print [[_ val]] (println val))
(defmethod perform-command :read [[_ fname]] (slurp fname))

(perform-command [:print "hello world"]) ; prints "hello world"
(perform-command [:read "./project.clj"]) ; returns the contents of project.clj
```

It's got a few warts, but nothing that can't be papered over with a few really simple macros:

``` clojure
(defmacro defvariant [name & args]
  `(defmulti ~name first ~@args))

(defmacro defcase [name [tag & binders] body]
  `(defmethod ~name ~tag [[_# ~@binders]] body))

(defvariant perform-command)
(defcase perform-command [:print val] (println val))
(defcase perform-command [:read fname] (slurp fname))
```

This makes it a little more obvious we're working with variant values.  Further conveniences might include making sure to change the default value to something other than `:default`, since that's likely to be a variant tag itself.

If someone wants to wrap this all up in a package people can start using that'd be super awesome!

## match / recur

At about 20:10 I mentioned that match and recur indicate a tree traversal.  What I meant to say was that match and regular non-tail recursion usually indicates a tree traversal, since traversals are almost never tail recursive.

## mix and match structs and variants, part 1

A question I expected to get asked but didn't was about what to do when your variant has too many data points in it, or when the variants all share one or more pieces of data.  If your variant has a lot of data points, you run the risk of making something like this:

``` clj
[:tag val1 val2 val3 val4 val5 val6 val7] ; l(-_-.) -just no
```

which is really hard to scan - and the positional anchoring of each value is going to be pretty hard to keep straight.  Instead, I'd recommend that if you have more than, say, 3 data points, that you put a map in your variant, like so:

``` clj
[:tag {:val1 1, :val2 2, :val3 3, :val4 4, ...}]
```

The `match` macro can even destructure these, and pick selective keys:

``` clj
(match thing
  [:tag {:val2 val2, :val4 val4}] (do-something-with val2 val4)
  ...)
```

## mix and match structs and variants, part 2

[ashton-talk-moment]: https://www.youtube.com/watch?v=HXGpBrmR70U#t=1169

There was [a moment in Ashton Kemerling's talk][ashton-talk-moment] where I was sitting in the audience waving my arms around and definitely not blurting out "that should totally be a variant!!".  He's modeling user actions in a generative test like this:

``` clj
{ :story 2198
  :type ::drag-drop
  :via ::selenium
  :args 2192 }
```

As he explains, `:type` is sort of which type the action is and `:args` is an arbitrary piece of data that gets attached. So let's use a variant!

``` clj
[::drag-drop 2198 ::selenium 2192]
[::comment 2198 ::phantomjs 123 ".(u_u,) -variants tho"]

(match action
  [::drag-drop story-id platform target] ...
  [::comment story-id platform user-id text] ...)
                      ; -(o_e,) wait but this looks worse
```

...not really the clarity win we were expecting.  That's because there are two pieces of shared data that in Ashton's case are going to be on *every* action variant value.  In this case, what I'd generally do is factor out those two into a wrapping struct:

``` clj
{ :story 2198
  :via ::selenium
  :action [::drag-drop 2192] }

{ :story 1234
  :via ::phantomjs
  :action [::comment 56 "(~._.)~ `(._.-) (s._.)s ~(._.~)"] }
```

This way we have the struct parts and the variant parts doing what they're each good at - aggregating data and varying data.

By the way, this action variant is a really good example of an open variant, and a perfect use case for destructuring with an extensible set of multimethods.

## naming

After the conj, an attendee confessed to being "confused about the difference between variants and types".  I *think* what they meant was that we have a bit of a name clash between the values and the form they take.  In fact, I actually see three distinct concepts which seem to be overloaded with the word "variant":

* Variant values.  These are simply the vectors with the keywords.
* Variant types or specs.  These include the available tags, and some notion of what data goes with them.
* Multimethods to destructure open variants, of which there may be many per spec.  These were defined with `defvariant` above.

It's possible we need better terminology around this (which would influence the naming of `defvariant` and `defcase`).

## in languages that aren't clojure

[polymorphism-pattern]: http://refactoring.com/catalog/replaceConditionalWithPolymorphism.html

A common question after the talk was "I'm in $LANGUAGE, how do I do variants there?"  Unfortunately, sometimes the sad truth is there's really no good way (rubyyyyyyyyy).  There are, however, two other techniques for dealing with this kind of situation in OO and dynamic OO languages.  [Martin Fowler described a pattern][polymorphism-pattern] in OO languages to eliminate type tags.  In this case the original antipattern is similar to the non-solution with a map from my talk - remember objects are glorified structs with inheritance.  While this approach has some known issues - serializability loss, no ability to do ad-hoc destructuring, and literally the expression problem, it gets the job done for a lot of people.

However in more dynamic languages that have lightweight lambdas, we can do a bit better.  I mentioned to a few people that I maintain a compiler written in coffeescript at work (`.(o_o.)`), and this is the approach I use there:

``` coffeescript
class MyVariant extends Variant
  # this call generates subclasses and static methods on MyVariant
  @variants
    tag1: ['val1', 'val2']
    tag2: ['val3']

# multiple constructors
MyVariant.tag1(val1, val2)
MyVariant.tag2(val3)

# single destructor
variant.cases
  tag1: (val1, val2) -> ...
  tag2: (val3) -> ...
```

The `cases` method simply calls into the correct function depending on the tag.  And even better, I can define methods for my variants on the base class.  It's worked well enough for me and is in production - if people are interested I'd be happy to extract this out into an npm or bower package.

Thanks for reading and watching and pushing this further!  I think there's a lot of work to be done, but I hope variants help you rethink some painful code and avoid bugs in the future!

## ``<3 -(n_n`)``

jneen

P.S. Comments seem to be broken - I'll look into that soon, but until then feel free to ping me [on twitter](https://twitter.com/jneen_).
