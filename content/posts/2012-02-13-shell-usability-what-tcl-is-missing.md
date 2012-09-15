---
title: "Shell usability: What TCL is missing"
date: Feb 13, 2012

---

I ran into TCL a few months ago, and spent the better part of a weekend playing and experimenting with it.  I really enjoyed its flexibility, simplicity, and emphasis on command-line usability.  I even went through a phase where I tried using it as my default shell in place of `bash`!

I very quickly ran into some problems, though, and it took me a while to figure out what was happening.

<!--fold-->

Here's an example: say I've got an open file handle `$fh`, and I want to get an array of its lines.  First I've got to read the file:

``` tcl
read $fh
```

this will return a string, which I'd like to split on newlines:

``` tcl
split [read $fh] "\n"
```

and this is my only chance to catch the return value of this command, so let's store it in a variable:

``` tcl
set lines [split [read $fh] "\n"]
```

The problem here is that I imagined this code in the reverse of how I've written it.  We start with the raw data on the right, and each subsequent action appears to the left.  But I read *and* write code left-to-right.  Especially in a `readline`-style interface, my cursor would have had to be jumping around constantly from left to right, surrounding expressions with square brackets and adding new commands to the left.

Now imagine if I could do something like this (read `$_` as "it", as in Perl):

``` tcl
read $fh | split $_ "\n" | set lines $_
```

Type that a couple of times.  See how much more natural that is?  You type it as you think it: "read the file, split it on newlines, store it in a variable."

In the language I'm designing (more on that soon), I've optimized the flow to make it a bit easier on the keyboard.  So far I'm thinking something like this:

```
# line breaks are optional, for readability
read .fh
  | split . \n
  | set lines .
```

What do you think?  What other considerations are there in optimizing a language for interactive use?

--Jay

[Discuss on HN][hn]

[hn]: http://news.ycombinator.com/item?id=3586335
