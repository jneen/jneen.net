---
title: "Bash adventures: read a single character, even if it's a newline"
description:
  How to read just one character from a stream without clobbering newlines in bash
date: 12/01/2011
---

## tl;dr

``` bash
getc() {
  IFS= read -r -n1 -d '' "$@"
}

getc ch
echo "$ch" # don't forget to quote it!
```

<!--fold-->

## the explanation

So it turns out that it's pretty difficult to read exactly one character from a stream.
From the manual for `read` (usually in `man builtins`):

```
-n nchars
       read returns after reading nchars characters rather  than
       waiting  for a complete line of input, but honor a delim‐
       iter if fewer than nchars characters are read before  the
       delimiter.
```


The naive solution, then would be:

``` bash
getc() {
  read -n1 "$@"
}

while getc ch; do
  echo "[$ch]";
done <<EOF
one
two
three
four
EOF
```

The output from this is:

```
[o]
[n]
[e]
[]
[t]
[w]
[o]
[]
[t]
[h]
[r]
[e]
[e]
[]
[f]
[o]
[u]
[r]
[]
```

Wait, what happened to the newlines -- why are they returning empty characters?  Well, it turns out there are two things going on here.  Again from the manual:

```
The characters in the value of the IFS variable are used to split the
line into words.
```

...and the newline is in the IFS.  So let's zero out `IFS`:

``` bash
getc() {
  IFS= read -n1 "$@"
}
```

unfortunately, this outputs the same thing, but for a different reason.
Remember: `read -n nchars` will still "honor a delimiter if fewer than `nchars` characters are read before the delimiter".
And the default delimiter (specified with `-d delim`) is the newline.
So the next solution is to use an empty delimiter.

Now our `getc` looks like:

``` bash
getc() {
  IFS= read -n1 -d '' "$@"
}
```

(NOTE: the space between the `-d` and the `''` is not optional.  This confused me the first time I was solving the problem, and I had suggested using the EOF character.  Not only that, I suggested obtaining an EOF with `"$(echo -e '\004')"`.  The empty delimiter is a better way to solve this particular problem, and `$'\004'` is a better way to get an EOF character.)

Now we get a very different output:

```
[o]
[n]
[e]
[
]
[t]
[w]
[o]
[
]
[t]
[h]
[r]
[e]
[e]
[
]
[f]
[o]
[u]
[r]
[
]
```

Our newlines are back!  Yay!

There is, however, one more wrinkle, as helpfully pointed out by an anonymous commenter.  `read` also likes to let you use backslashes to escape things.  For example, with the current implementation of `getc`:

``` bash
while getc ch; do
  echo "[$ch]"
done <<EOF
one\
two
EOF
```

Yields the following output:

```
[o]
[n]
[e]
[t]
[w]
[o]
[
]
```

Note how the backslash after `one` was interpreted as an escape for the newline that follows.  Luckily, `read` comes with an `-r` option:

```
-r     Backslash does not act as an escape character.  The back‐
       slash is considered to be part of the line.  In  particu‐
       lar,  a  backslash-newline pair may not be used as a line
       continuation.
```

So the final solution is:

``` bash
getc() {
  IFS= read -r -n1 -d '' "$@"
}
```

EDIT 7/19/2011:  Fixes and nuances to the original solution, as provided by `:)`.
