---
title: The Lesson of the Quine Programmer
date: 18 March 2026
---

<figure class="center">
  <img src="/images/last-one.png" style="width: 50%;" title="
    ALL THE PROGRAMS YOU'LL EVER NEED. FOR $600.
    Say goodbye to the costs and frustrations associated with writing software: The Last One(R) will be available very soon.
    More comprehensive and advanced than anything else in existence, The Last One(R) is a computer program that writes computer programs. Programs that work first time, every time.
    By asking you questions in *genuinely* plain English about what you want your program to do, The Last One(R) uses those answers to generate a totally bug-free program in BASIC, ready to put to immediate use.
    What's more, with The Last One(R), you can change or modify your programs as often as you wish. Without effort, fuss, or any additional cost. So as your requirements change, your programs can too.
    In fact, it's the end of programming as you know it.
    And if, because of the difficulties and costs of buying, writing and customising software, you've put off purchasing a computer system up to now, you need delay no longer.
    The Last One(R) will be available very soon from better computer outlets. To place your order, take this ad into your local dealer and ask him for further details. Or in case of difficulty, please write to us direct.
    THE LAST ONE
    YOU'LL NEVER NEED TO BUY ANOTHER PROGRAM.
    D.J. 'A.I.' Systems Ltd., Ilminster, Somerset, TA19 9BQ. England
    Telephone: 04605-4117. Telex: 46338 ANYTYR G.
  "/>
  <figcaption>A full-page ad for The Last One software system, post-processed with various effects by me. <br><a href="https://archive.org/details/byte-magazine-1981-08/page/n209/mode/2up" target=_blank>BYTE magazine Aug. 1981, pg. 196</a>
</figure>

I was recently shocked to learn that [The Daily WTF](https://thedailywtf.com) is still running after all these years. It seems like such a time capsule now, programmers making fun of the absolute nonsense they encounter in the field - marvel at the [24 nested stringReplace calls](https://thedailywtf.com/articles/A-Spacy-Problem)! Watch [The PHP God](https://thedailywtf.com/articles/Divine-by-Zero) non-deterministically divide by zero! To me it evokes an era of IRC channels, PHP, subversion, and logging into the production server to update the code. Simpler times. These days it's a lot of very obtuse React.

There is one snippet from that time that really stuck in my brain though. It reached above the nonsense layer and into the philosophical. And that is the story of [The Quine Programmer](https://thedailywtf.com/articles/the-quine-programmer). It's a very short read, go take a look, I'll wait.

See, unlike the typical inanity and wacky code snippets of the site, the Quine Programmer, and the Quine System they create, get at a very fundamental question:

> **What is the difference between a System that Can Do Anything and, say, Python?**

At what point can the user of a system be considered programming? Is Excel a programming language? What about [The Last One][the-last-one]? If scratch is a programming language, does clicking around Unreal Engine count? `nginx.conf`? What about the command-line flags of `find`?[^turing-complete]

And what makes Python better than The Quine Programmer's monster?

<!--fold-->

I think most folks I know who work on and write about programming languages would say that broadly speaking these systems all represent a type of programming[^turing-complete-2]. There are some design considerations all these systems have in common, and it is a design space I enjoy thinking about.

So, how do we do better than the Quine Programmer? How can we connect the dots between human user and computer in a way that respects the strengths of both?

## Computer Language Design

For this broader question, I prefer the following extremely general definition of a "computer language":

> A **computer language** is a computer program whose meaningful inputs are unbounded in complexity.

This is pretty close to the definition from [my clojure/west talk 10 years ago][clojure-west], and though there's many things I'd change about that talk a decade later, I think it's fairly workable for our purposes. It clearly includes configuration, markup, and styling languages, as well as non-text-based languages quite nicely. It also, crucially, includes the Quine Programmer's system.[^definition-grey-area]

[clojure-west]: https://jneen.ca/talks/clojure-west-2015 "My talk at clojure/west 2015: &ldquo;How to tell if you've accidentally implemented a programming language, and what to do about it&rdquo;"

And for those versed in certain languages, evaluating a tool by the possible shapes of its inputs should feel fairly familiar - the shape of the input determines the utility of the output. Just as an if/else inside a loop might be a parser, the moment you are handling arbitrarily complex input is perhaps the moment you should ask "Am I the Quine Programmer?"[^reddit]

What I think more strongly stands the test of time[^test-of-time], though, are the **general design goals of a computer language** that I presented:

> 1. *Interpretation*. The computer must be able to interpret valid input and reject invalid input.
> 2. *Predictability*. The user must be able to understand the *way* in which the computer will interpret their input.
> 3. *Discoverability*. The user must be able to express new goals within the constraints of the system.

The Quine programmer is quite satisfied with their performance on **Interpretation**. Give it a valid input, and the system will work just fine! Perhaps they haven't thought through the feedback loop for invalid input particularly well, and perhaps there are some corners the users would be surprised to know about, but to the Quine Programmer's mind these are simply part of the spec. Every bug a feature.

As for **Predictability**, the Quine Programmer has not even considered it. In their mind the implementation *is* the mental model. But their users, who almost as a rule are *not* familiar with the implementation, will absolutely struggle to use the system if they cannot reasonably predict its behaviour. Any bozo can write `display: flex` in a CSS file, but there is no meaning to this action unless you have a mental model of *what it will do*. Systems with low predictability leave users with a complicated guess-and-check workflow that relies mostly on [superstition][].

[superstition]: https://utcc.utoronto.ca/~cks/space/blog/programming/ProgrammingViaSuperstition "Chris Siebenmann - A significant amount of programming is done by superstition"

<figure class="center">
  <img style="max-width: 480px" src="/images/family-guy-css.gif" title="Classic GIF of Peter Griffin struggling with Venetian blinds, captioned 'CSS'" />
  <figcaption>A dated meme, but one that encapsulates the &ldquo;try it and see if it works&rdquo; feeling I remember from trying to make a site look right in IE6.</figcaption>

</figure>

Similary, **Discoverability** may have been overlooked by the Quine Programmer, who typically is not known to write extensive documentation. Just read the code! Languages that fail on this point tend to be plagued with copy-paste and programming by superstition.

The Quine Programmer has also likely overlooked another important discovery feature: *error messages*. It is vitally important that the system respond in a helpful way when given invalid input. Users rely on these messages (among other things) to correct mistakes and develop a clear mental model of the language.

So that's a fun little philosophical exercise from 10 years ago, based on a satirical blog post from 15 years ago. But this is 2026, so I think we all know where this is going.

## Evaluating AI as a computer language

This beef isn't new for me. I was getting into embarrassing online arguments with AI people on exactly these points as far back as 2014. Perhaps I should have written about them more.

See, the design goals we've talked about aren't just applicable to quine systems or computer languages, but more generally to how I feel it is appropriate to design a tool facilitating communication between a human user and a computer. Any AI system that communicates with a user in natural language *certainly* meets our computer language definition above, and so I feel fairly justified in judging it by the same criteria.

==From my perspective, AI is an incredibly poorly designed computer language.==

Actually that may not quite be fair, as AI systems excel at discoverability. By design, it is certainly very easy to use an AI system. Those who believe in the existence of "prompting skill" may have one or two tips and tricks for saving tokens and preventing certain classes of errors, but ultimately communicating with a machine in natural language takes an extremely minimal amount of knowledge or training. It's all right there, willing to explain anything you ask. The issue is that the designers seem to have forgotten the rest of it - what discoverability is *for*.

Whether an AI system can interpret valid input is a topic of contentious debate (and I don't think we should accept "sometimes" as an answer here), but it is *very* clear to me that AI systems are not capable of rejecting invalid input, at least not consistently.[^latest] One could even ask whether there *is* a distinction between valid and invalid input for an AI system.

Natural language is slippery, full of weird regionalisms and self-negatives and overlapping meanings and context dependence that make the process of interpretation extremely error-prone, even for a theoretically perfect system. As [Dijkstra famously argued][dijkstra], the use of formal symbols for logical and technical tasks historically represented a major breakthrough, and is one we should not let slip lightly.

But the complete abject failure of AI systems lies mainly in predictability. The scale of the data set means that there is simply no way for users to develop a mental model of its operation - to even guess as to the nature of the interpretation of a given input. **We have automated the Peter Griffin Struggles With Venetian Blinds workflow on our codebases and our users.**

To be fair to the users though, they do in fact end up constructing a mental model of their interactions with an AI. The problem is it's dangerously wrong.

## The AI User's Actual Mental Model

Most computer science folks these days are familiar with [ELIZA][], the 1960s chatbot that famously convinced users they were talking to a real person, passing the Turing Test with flying colours by mere social engineering. Fewer, I think, have read ELIZA author Joseph Weizenbaum's excellent book [Computer Power and Human Reason][cphr] on the topic. I managed to find a hard-copy - it has one of those old cardboard-ey bindings and smells like my grandmother's bookshelf.

The language in it is admittedly a bit dated and certainly dense, but it is surprisingly prescient for today's world. Here's how Weizenbaum describes a user developing a mental model of a natural language system:

[ELIZA]: https://en.wikipedia.org/wiki/ELIZA_effect "Wikipedia: ELIZA effect"

> So, unless they are capable of very great skepticism (the kind we bring to bear while watching a stage magician), they can explain the computer's intellectual feats only by bringing to bear the single analogy available to them, that is, their model of their own capacity to think. [pg. 15]

This is not, as is the impression I fear so many walk away with, some problem limited to some gullible secretary complaining to a computer program about her boyfriend.[^boyfriend] We are not as different from her as maybe we would like to imagine. In fact, Weizenbaum cites professional psychiatrists declaring the program to be the future of their field, and even Carl Sagan himself chimed in to offer a rosy vision of a future where therapy was administered coldly through arrays of computer terminals. **You are not immune to the ELIZA effect!**

And today, AI's tendency towards being anthropomorphized is not neutral. It's directly led to some of its more unsavoury effects on its users. In fact, they are arguably an [active cognitohazard][baldur]. Even presumed subject-matter experts are prone to this - just a few weeks ago a Meta AI specialist [posted herself admonishing OpenClaw for deleting her email][summer-yue], an act that assumes a computer can feel shame and correct its behaviour to avoid it.

Instead, consider this a natural result, a kind of optical illusion created by having no other reference point to fall back on. Like most optical illusions, being aware of the problem doesn't mean your perception is suddenly "fixed" - you and I are equipped with human senses that have a lot of strange flaws and corner cases, and we eventually learn to question what we see to some extent. So we can somewhat move about in a world full of [stage magic pretending to be real][llmentalist].

[llmentalist]: https://softwarecrisis.dev/letters/llmentalist/ "Baldur Bjarnason: The LLMentalist Effect"

## Tuned Noise

"but what about getting it 95% right" -- need to finish this section

talk about shaders / perlin noise

actually a legitimate application in some ways, used responsibly

[summer-yue]: https://nitter.net/summeryue0/status/2025774069124399363 "Summer Yue's texts with her OpenClaw instance"


[baldur]: https://softwarecrisis.dev/letters/llmentalist/ "LLMentalist by Baldur Bjarnason"

## Conclusion

(write something a bit more substantial here but i think this is a good ending paragraph)

When a tool is unreliable, completely resists modeling, is incapbable of consistently rejecting invalid input, and acts as [an active cognitohazard][baldur], I think it's reasonable to say it's not fit for purpose. Maybe the next time I want an indeterminate answer that I can't tell is right I'll ask The PHP God.[^god]


[the-last-one]: https://en.wikipedia.org/wiki/The_Last_One_(software) "The Last One"
[cphr]: https://archive.org/details/computerpowerhum0000weiz_v0i3 "Computer Power and Human Reason by Joseph Weizenbaum"
[dijkstra]: https://www.cs.utexas.edu/~EWD/transcriptions/EWD06xx/EWD667.html

[^turing-complete]: Those with just enough CS knowledge to be dangerous will probably be excitedly ready to explain [Turing Completeness](https://en.wikipedia.org/wiki/Turing_completeness) at this moment, a mathematical categorization of programming languages based on their capability, given some infinite amount of resources (classically, a tape). But I'm more interested in the *design* of languages than their specific application or capabilities, so let's perhaps say that turing-completeness is an *attribute* that a language can have, rather than a *definition* of what one is. It's an important consideration to be sure! But there are other design considerations that I think apply a bit more generally.

[^turing-complete-2]: ...with the caveat that sometimes "programming" is implied to be in a *Turing complete* system, or even more specifically an *imperative* one, and this ambiguity is also part of why I prefer "computer language". I'm including things like HTML and CSS here, as they also have these kinds of design considerations.

[^test-of-time]: with some modifications, which may be a bit unfair of me

[^definition-grey-area]: There's some grey area around creative tools like Photoshop or your average DAW (which these days tend to have programming-like systems built in anyways).

[^reddit]: AITQP subreddit when

[^god]: Holy heck it just occurred to me that the code from TDWTF snippets is almost certainly in your favourite model's training set. Terrifying, have a great day.

[^latest]: I swear to god if somebody comes at me with "you just haven't used the latest model yet". We've heard this before. Non-determinism is inherent to the design.

[^boyfriend]: Honestly the fact that the "All men are the same" prompt is the chosen snippet *every time* ELIZA is brought up says something about our perception and treatment of women, and allows us to be somewhat dismissive of the ELIZA effect in ways that are super uncomfortable to think about!
