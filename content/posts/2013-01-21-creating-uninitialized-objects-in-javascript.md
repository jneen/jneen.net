---
title: Creating Uninitialized Objects in Javascript
description:
  "How javascript's instanceof operator works, and how to make instances of classes without running the constructor"
date: 21 Jan 2013
---

When I first started writing larger applications in Javascript, I was stumped about how to set up a prototype chain correctly.  The idiomatic way runs code that isn't strictly necessary:

``` js
function BaseClass(thing) { this.thing = thing; }
function SubClass() { BaseClass.apply(this, arguments); }
SubClass.prototype = new BaseClass;
```

The problem here is that the third line runs the constructor function with no arguments.  In this case it's fine, because it sets `SubClass.prototype.thing` to `undefined`.  But what if the constructor has to do some kind of computation, or has required arguments, or (gasp) does I/O?  Not the best coding practices in the world, sure, but I've worked with this kind of code.

In modern JS environments, the right thing to do is use `Object.create`:

``` js
SubClass.prototype = Object.create(BaseClass.prototype);
```

But if you want to support older browsers, a different strategy is called for.

It turns out, the Javascript runtime has no way of telling which constructor was used to create an object.  Its `instanceof` operator only looks at the prototype chain.  In environments supporting the [`__proto__` accessor][__proto__], we could implement `instanceof` ourselves:

``` js
function isInstanceOf(obj, constructor) {
  if (typeof constructor !== 'function') throw new TypeError;
  if (typeof obj !== 'object') throw new TypeError;

  if (constructor === Object) return true;

  // recursively look up the prototype chain for a match
  return (function checkPrototype(obj) {
    if (obj.__proto__ === constructor.prototype) return true;
    if (obj === Object.prototype) return false;

    return checkPrototype(obj.__proto__)
  })(obj);
}
```

So in particular, we can use a completely different constructor to make instances of the same function!

``` js
function f() {}
function g() {}
f.prototype = g.prototype = {a: 1}
(new f) instanceof g; // => true
(new g) instanceof f; // => true
```

So in order to make a new "instance" for subclassing, we can just initialize an empty constructor that has the right prototype, and the runtime *can't tell the difference*.

``` js
function create(_super) {
  function noop() {}
  noop.prototype = _super;
  return new noop;
}

SubClass.prototype = create(BaseClass.prototype);
```

[Coffeescript uses this approach][coffeescript varargs] when it needs to construct objects with varargs.  We've used a variation of this approach in the [latest version of pjs][pjs v3.0.0].  Pjs classes carry around [ready-made noop constructors][pjs bare] with the correct prototypes already set.  For a pjs class, if you want an empty instance of `MyClass`, just type `new MyClass.Bare`.

Happy coding!

--Jay

[__proto__]: https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Object/proto "The __proto__ accessor"
[coffeescript varargs]: http://coffeescript.org/documentation/docs/nodes.html#section-55 "Coffeescript vararg constructors"
[pjs bare]: https://github.com/jayferd/pjs/blob/v3.0.0/src/p.js#L28 "Pjs Bare class"
[pjs v3.0.0]: https://github.com/jayferd/pjs/tree/v3.0.0 "Pjs v3.0.0"
