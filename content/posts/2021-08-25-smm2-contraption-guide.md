---
title: "A Guide to building contraptions in Mario Maker 2"
description:
  The document I wish I had when I was getting started.
---

## introduction
Trolling in Mario Maker/Mario Maker 2 has evolved since its early days.
Contraptions that previously would have been considered "advanced" have
become commonplace - players even expect certain setups to be available,
and getting the effect you want can seem to take quite a deep knowledge
of the workings of the game.

Truth be told, the vast majority of contraptions in troll levels are
invented on-the-spot for the task at hand. Even after mastering the
techniques in this wiki, you will almost certainly still find yourself
having to invent new tech, or at least combine setups in creative ways.

Any attempt to document troll setups is by its nature out of date and
incomplete. Nintendo will patch setups, creators will find new jank,
and new things will become commonplace again. But Nintendo's rate of
patching glitches has slowed, and the basic principles behind most
of the tech here are here to stay, at least in Mario Maker 2.

Finally, remember that a good troll takes more than just a contraption.
[Defender1031, a prolific and experienced troll creator, has written
an entire guide on this already][troll-guide]. These setups should
be used to support the humour in the level, which comes from using
them in your own creative ways that play with the player's expectations.

## how this cursed game works

Let's begin with an overview of the basic principles of a Mario Maker 2 level.

### overworld and subworld

A level is divided into an overworld, containing the start platform
and the goal, and a subworld, accessible by pipes. Entering a pipe
always takes Mario across the border between these two. Warp doors,
on the other hand, never cross this boundary.

An overworld is always laid out horizontally, but a subworld can
optionally be *vertical* - narrow but very tall - which imparts a
number of special properties related to loading and scrolling.

### controlling the screen scroll

One very convenient way to hide setups and traps is to simply prevent
them from appearing on screen. While this can often be done by constraining
Mario's movement to a specific area (and in fact, this is often the most
effective way if possible), it's often much more effective to prevent the
screen from scrolling entirely.

The most basic way to prevent screen scroll is to use a **scroll stop**.
A scroll stop is a solid line contaning *only* ground tiles and hard-blocks
that spans an *entire* vertical column or horizontal row in the level.
(note: slope tiles, while they look like ground tiles, don't count for
this purpose. I don't know why either).
As long as this wall remains intact, the screen will scroll the wall into view,
but no further. If any one of the hard-blocks along the scroll-stop is
destroyed (see "destructible blocks"), the scroll-stop will open, allowing
the screen to scroll past it, even if mario is not able to move past it.
[image]

Another way to control the screen scroll is to use the **auto-scroll** feature.
With autoscroll, the screen will automatically scroll as far as it can
before it reaches a scroll-stop. With normal autoscroll, however, the screen
can still be scrolled *along* the scroll-stop, if not past it.

There is, however, one way to completely freeze the screen in place until
a scroll stop is broken, and it only requires a vertical scroll-stop on the
right of the screen. In an overworld, auto-scroll can be set to "Custom."
In this mode, the screen will only ever scroll along predetermined paths,
and will *completely stop* when encountering a scroll-stop, never moving
up nor down no matter where Mario moves on the screen. This can be used
to hide contraptions and secret off-screen areas.

### how to make sure mario dies

In order to prevent softlocks, it's very important to ensure a *permanent* path
to death is established. If a player can softlock by dodging a fish, killing an
enemy, or reloading a room, a backup strategy is necessary.

Receiving damage from an enemy is a simple way to provide a path to death, if the
player's powerup state is not a concern. However, there are many items that allow
a player to kill or avoid enemies and traps in surprising ways that can lead to
softlock. For example:

[images: killing a boo with spike-shellmet]

To avoid these, either use a different death strategy or ensure that the enemy
is spawned infinitely, as from a pipe or launcher.

Another way to kill Mario instantly is by **squishing**. A so-called "disrespect
block" on a track can provide an instant path to death by being squished between
the block and the ground. If you do this, make sure the player can't softlock by
destroying the block!

- how mario dies
  - damage
  - squish
  - pits and autoscroll death barriers
  - double-blocked doors and pipes
- the hard limits
  - there will never be enough doors and pipe entries (4 doors per area, 10 enterable pipes)
  - static entity limit (ELA)
    - see later chapter about hacks to work around this
  - dynamic entity limit (ELB)
    - see later chapter about how to use this to our advantage
  - static powerup limit
    - not usually encountered in troll levels
  - dynamic powerup limit
    - not usually encountered in troll levels
  - boss limit (doesn't count towards entity limit)
- spawning, despawning, reloading
  - spawn and despawn distance
  - spawning behind a scroll stop
  - spawning from blocks - never reloads (exception: vine blocks)
  - global ground: what it is and isn't

## destructible blocks and spawnblocking
- kinds of destructible / switchable blocks
  - using the switch: red/blue blocks
  - using a P-switch: P blocks, coins, brick/turnstile blocks
  - breakable: hard-blocks, question-mark blocks, filled brick/turnstile blocks
  - meltable (also breakable): frozen coins
- room-reload detection
  - clowncar-launcher trick for double-blocking
- switch-state or p-switch twice-twice

## enemies and how to use them
- stacks
  - entire stack takes on the movement of the bottom-most spawned enemy
  - can spawn-block things in stacks for offsetting or twice-twice
- spike and his magic balls
  - spikeballs can be spawnblocked
  - they hit and open blocks when they roll into them
  - when a spikeball hits a hidden block
  - hold in stasis with a conveyor belt
  - roll direction and checkpoint load detect
    - basic benevolent keydeath setup

## tracks, how do they work??
- float over blocks
- fixed timing. fast-ish switch-track setup. detectors using tracks are *slow*
- tracked items never despawn as long as they are on a track
- everything collides with mario, but only launchers and p-switches collide with other entities
  - lots of exceptions tho
- track transfer rules - why does it go that direction?

## detectors
- position detection
  - well-placed position detectors can often be used in place of
    much more complex detectors.
  - thwomp
  - icicle
  - buzzy beetle
  - monty mole
- offscreen noteblocks
- screen scroll detection
  - spawn/despawn detectors
  - seesaw detector for horizontal worlds
- hidden block detectors

## pink coins and the entity limit
- saving pink coins with a checkpoint
- what happens when you keydeath
- setup to spawn something from a block *unless* you have keydeathed

## basic entity saving tech
- reuse stuff
- the noteblock trick
- spikeball shenanigans

## yeets
- glitchless yeets
- jojalol launchers
- cannon hyperspeed
- thwomp+slope hyperspeed
- broken tracks
- you can find more probably

## 3d world is very different
- idk anything about 3d world lol pls expand
