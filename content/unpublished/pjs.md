---
# vim: ft=markdown
title: >
  Class instantiation in Pjs
date: 2/8/2012
---

I love javascript.  I also love prototypes.  But the particular implementation of classes in javascript is pretty lacking.  Here's a typical heirarchy ([stolen with appreciation from J.R.][jr-inheritance]):

``` javascript
function Person(isDancing) {
  this.dancing = isDancing;
}

Person.prototype.dance = function() { return this.isDancing };

function Ninja() {
  Person.call(this, false);
}

Ninja.prototype = new Person;
Ninja.prototype.swingSword = function() {
  return 'swinging sword!';
}
```

This code works great.  We can play around with it:

``` javascript
var person = new Person(true)
  , ninja = new Ninja;
;

person.dance() // => true
ninja.dance() // => false

person instanceof Person // => true
ninja instanceof Person // => true
person instanceof Ninja // => false
ninja instanceof Ninja // => true

ninja.swingSword() // 'swinging sword!'
person.swingSword() // TypeError: Person person has no method 'swingSword'
```

Now let's add some data validation.  For example, let's require that you pass an argument to `Person`'s constructor.  (this is a little contrived, but bear with me):

``` javascript
function Person(isDancing) {
  if (arguments.length === 0) {
    throw new Error("the Person constructor requires an argument.");
  }

  this.dancing = isDancing;
}
```

Great!  Let's fire this up, and... well crap.  Something's throwing our error.

```
Error: the Person constructor requires an argument.
    at new Person (example.js:14)
    // ..etc..
```

The problem is when we set up the prototype chain like so:

``` javascript
Ninja.prototype = new Person;
```

the initializer for Person is run with no arguments.  This is important: **there is no browser-compatible way to clone prototypes without calling the constructor function.** (Astute readers will be quick to point out that `Object.create` exists, but it's not supported in IE8 or earlier, nor FF 3.6 or earlier, so for browser development it's not really an option.)

Javascript has a weird inconsistency.  It uses prototypes to manage inheritance, and yet depends on the "class" -- which is really the constructor -- to clone objects.

So our first order of business in making this better will have to be offloading the initialization to a different method.

``` javascript
function Person(isDancing) {
  if (typeof this.init === 'function') this.init.call(this, isDancing);
}
```

The problem is that we still have the same problem: every time we create a `new Person`, the initializer is run.  Here's a clever hack:

``` javascript
function Person(isDancing) {
  if (arguments.length > 0 && typeof this.init === 'function') {
    this.init.call(this, isDancing);
  }
}
```

<!--
You may recognize the `if (!(this instanceof Person))` trap from [John Resig][jr-instantiation].  This allows us to behave slightly differently when `Person()` is called than when `new Person` is called.  In the first case, javascript will always set `this` to the global object - in the second, `this` is the new instance. 
-->

In this implementation, if you call `new Person` with no arguments, this implementation will not run `this.init`.  This way it's easy to clone for inheritance, as above.

There's a glaring problems with this, though.  Many constructors actually take zero arguments.  Let's try something crazy:

``` javascript
function Person(args) {
  if (args && typeof this.init === 'function') this.init.apply(this, args);
}
```

It's a little clunky, but this implemetation makes `new Person` take an *array* of arguments when instantiating, and zero arguments when cloning.

``` javascript
new Person; // init is not called
new Person([true]) // this.init(true) is called
new Person([]) // this.init() is called
```

Now, to make this a bit easier to deal with, we might make a special `create` function:

``` javascript
Person.create = function() {
  return new Person(arguments);
}
```

This is still a bit cumbersome.  Luckily we're not stuck.  We can take a [trick][jr-instantiation] from the toolkit of John Resig, and detect whether `Person` was called with the `new` operator:

```
function Person(args) {
  if (!(this instanceof Person)) return new Person(arguments);
  if (args && typeof this.init === 'function') this.init.apply(this, args);
}
```

This way, when you call `Person(true)`, it springs the first trap, returning (roughly) `new Person([true])`, and in the second time through will call `init.apply(this, [true])`, which is exactly what we wanted.  This is how this behaves:

``` javascript
new Person // clones Person's prototype
new Person([true]) // clones the prototype, runs init(true)
Person(true) // creates a new Person object, runs init(true)
```

This is the core of the [pjs][pjs-src] framework.  It's simple, readable, and usable.

............. Finish this post!

-- Jeanine

[jr-inheritance]: http://ejohn.org/blog/simple-javascript-inheritance/
[jr-instantiation]: http://ejohn.org/blog/simple-class-instantiation/
[pjs-src]: https://github.com/jneen/pjs/blob/master/src/p.js#L40
