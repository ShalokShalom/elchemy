
<p align="center">
<img src="https://github.com/wende/elchemy/blob/master/logo.png?raw=true" width="250" height="250">
</p>
<p align="center">
  <a href="https://join.slack.com/t/elchemy-lang/shared_invite/enQtNjMzMDI0NzM3MzQ3LWVmZDZkMzY3OWZkMzJlOGIzZjMzMjcwMDgzNDFlZDYzY2NiYzE0ZjdhOTRmMmMyMjRiOTUzNjhhNWQ1M2VlMGY">
    <img src="https://img.shields.io/badge/chat-on%20slack-blueviolet.svg">
  </a>
  <a href="http://elchemy.neontree.pl">
    <img src="https://img.shields.io/badge/try%20now-online-yellow.svg">
  </a>
  <a href="https://wende.gitbooks.io/elchemy/content/">
    <img src="https://img.shields.io/badge/read-docs-informational.svg">
  </a>
  <a href="https://medium.com/@krzysztof.wende/elmchemy-write-type-safe-elixir-code-with-elms-syntax-part-1-introduction-8968b76d721d">
    <img src="https://img.shields.io/badge/getting-started-green.svg">
  </a>
  <a href="https://travis-ci.org/wende/elchemy">
    <img src="https://travis-ci.org/wende/elchemy.svg?branch=master">
  </a>
 
</p>

#### Quick install

```shell
npm install -g elchemy
```


# What is it?

Elchemy lets you write simple, fast and quality type safe code while leveraging both the Elm's safety and Elixir's ecosystem


### In case of any questions about the project feel free to submit them in Issues with Q&A label


# Features

- **Type inference:** Powerful type inference means you rarely have to annotate types. Everything gets checked for you by the compiler
- **Easy and type-safe interop**: You can call Elixir/Erlang without any extra boiler-plate. All the calls you make are checked in terms of type-safety as thoroughly as possible based on Elixir's typespecs.
- **All the best of Elm and Elixir**: Elchemy inherits what's best in Elm - type safety, inference and extreme expressiveness, but also what's best in Elixir - Doc-tests, tooling and obviously the entire BEAM platform.
- **Nearly no runtime errors** - Elchemy's type system **eliminates almost all runtime errors**. With a shrinking set of edge cases, your entire Elchemy codebase is safe. Elixir parts of the codebase are the only ones to be a suspect in cases of runtime errors happening.
- **Beautiful and fully readable output** - The produced code is idiomatic, performant and can be easily read and analyzed without taking a single look at the original source.


# Maturity of the project

- Parser - **99%** of Elm's syntax (see [elm-ast](https://github.com/Bogdanp/elm-ast/issues))
- Compiler - **90%** (Sophisticated incremental compilation. 
  No support for Windows yet though ([#287](https://github.com/wende/elchemy/issues/287)) and also big reliance on unix tools ([#288](https://github.com/wende/elchemy/issues/288))
- Elchemy-core - **95%** ( Everything covered except side effects and JSON Decoders) 
- Interop with Elixir - **90%** - Purity tests ([#162](https://github.com/wende/elchemy/issues/162)) and handling of macro-heavy libraries ([#276](https://github.com/wende/elchemy/issues/276)) to go 
- Ideology - **70%** - We've got a pretty solid idea of where Elchemy is going 
- Documentation - **80%** - There are two tutorials and a complete Gitbook documentation. Few entrance level tutorials though, this project tries to change it. 
- Elchemy-effects - **20%** - You can't and shouldn't write anything with side-effects in Elchemy yet. We're working on finding the best solution for effects that would fit both Elm's and Elixir's community (see [#297](https://github.com/wende/elchemy/issues/297) for more info)
- Elchemy-core for Erlang VM - **5%** - Everything for os related tasks like filesystem, OTP goodies etc are yet to be done
- Elchemy type checker - **20%** - Self-hosted elchemy type inference algorithm, written by @wende and inspired by @Bogdanp.

# Usage

### Prerequisites

- [elixir@1.4.0-1.6.x](https://elixir-lang.org/install.html)
- [node@5+](https://nodejs.org/en/)
- [elm-lang@0.18.0](https://guide.elm-lang.org/install.html) (`npm install -g elm@0.18.0`)
- [elm-github-install@0.1.2](https://github.com/gdotdesign/elm-github-install) - Compiler will install it automatically for you, if you don't have it yet.


### Installation in an existing Elixir project


Install `elchemy` globally with:

```shell
npm install -g elchemy
```


Then, in the root directory of your project do:

```shell
elchemy init
```

And follow the instructions.

`elchemy` will find all `*.elm` files specified in `elchemy_path` and compile it into corresponding `*.ex` files in `lib` directory.

You can override output directory specifying `elixirc_paths`.


### Installation as a standalone

```shell
npm install -g elchemy
```

Usage

```
elchemy compile source_dir output_dir
```

### Recommended editors setup

- [Atom](https://atom.io/) with [elixir-language](https://atom.io/packages/language-elixir) and [atom-elixir](https://github.com/msaraiva/atom-elixir) or [elixir-ide](https://atom.io/packages/ide-elixir) for Elixir; and [language-elm](https://atom.io/packages/language-elm) + [elmjutsu](https://atom.io/packages/elmjutsu) for Elchemy.
- [Visual Studio Code](https://code.visualstudio.com/) with [vscode-elixir](https://marketplace.visualstudio.com/items?itemName=mjmcloug.vscode-elixir), [vscode-elixir-ls](https://github.com/JakeBecker/vscode-elixir-ls) and [vscode-elm](https://github.com/elm-tooling/elm-language-client-vscode)


### Build from source

```
git clone https://github.com/wende/elchemy.git
cd elchemy
make compile
./elchemy compile source_dir output_dir
```

and

```
make dev
```

In order to launch and test the web demo.


## Troubleshooting

If something doesn't work, try 


```
npm install -g elchemy
elchemy clean
elchemy init
mix test
```

first


# FAQ

## Why *would* I want to use that?

- You like types
- But even more you prefer compile-time errors over run-time error
- You prefer `add b c = b + c` over `defp add(a, b), do: b + c`
- You like curry
- You think failing fast is cool, but not as cool as not failing at all


## Why *wouldn't* I want to use that?

- Your project relies on die-hard battle tested libraries, and you despise any versions starting with 0
- You're afraid that when you learn what Monad is your mustache will grow, and eyesight weaken


## Can I use it in already existing Elixir project?

You can, but nice and dandy compile tools are still on their way


## Will my employer notice I'm having an affair with Elchemy?

The output files of Elchemy treat the code readability as a first class citizen. The code is meant to be properly indented, the comments aren't omitted, and the code is optimized as hard as it can ( f.i case clauses reduce to function overloads)


## When will Elchemy become 1.0.0?

Once it's done, so as it is supposed to be in the so called semantic versioning. :innocent:


## Can I contribute?

Definitely. Yes. Please do. :two_hearts:


## How are types represented?

You're a nosy one, aren't you? :smile: Elchemy represents all type constructors as snake cased atoms, and all type applications as tuples. Which means that `MyType 42 "Forty two" Error` in Elchemy equals to `{:my_type, 42, "Forty Two", :error}` in Elixir.


## Can I use already existing Elm libraries with Elchemy?

As long as they don't use any Native modules, Ports or Elm runtime they can be safely imported and used


## Can I use already existing Elixir libraries with Elchemy?

Yes. You can do an `ffi` call to any function in any module. Whether it's Elixir module, Erlang module, or even a macro you can include it in your code. Ffi calls are a treated specially in Elchemy, and they get generated test to analyze the types based on @specs, so that you don't compromise type safety for using Elixir code. 
In order to increase readability it's advised not to use `ffi` calls if not necessary and always document and doctest them.


## But what about out of function macros? Like tests and `use Module`?

Unfortunately you can't write any macros with `do..end` blocks yet. You can write any out of function code using an elixir inline code with:


```elm
{- ex
  *code_here*
-}
```

But it is a last resort solution and shouldn't ever be abused.


## Can I define an Elixir macro in Elchemy?

So you want to write an Elm-like code, that will manipulate Elixir code, which generates an Elixir code that manipulates Elixir code? How about no?


## Do I need to have Elm installed to compile my `.elm` files with Elchemy?

Elchemy uses Elm to typecheck your program. It is possible to use it without Elm on your machine, while it's not advised.


# Contributor credits:

- Tomasz Cichociński - [@baransu](https://github.com/baransu)
- Colin Bankier - [@colinbankier](https://github.com/colinbankier)
- Nathaniel Knight - [@neganp](https://github.com/neganp)

# Inspiration:

- [Elm](https://github.com/elm/compiler) by Evan Czaplicki - [@evancz](https://github.com/evancz)
- [Elixir](https://github.com/elixir-lang/elixir) by José Valim - [@josevalim](https://github.com/josevalim)
- [Elm-in-Elm](https://github.com/bogdanp/elm-in-elm) by Bogdan Popa - [@bogdanp](https://github.com/bogdanp) 


# Contributing Guide

- Everyone is welcome to contribute :hugs:
- Refer to https://bogdanp.github.io/elm-ast/example/ to have better understanding of parsed tokens.
- Refer to https://wende.github.io/elchemy/stable/ to know the latest development version of the parser
- For project management we use ZenHub. You can see the Kanban board, card estimates and all the reports by installing a browser extension here: [Opera/Chrome](https://chrome.google.com/webstore/detail/zenhub-for-github/ogcgkffhplmphkaahpmffcafajaocjbd), [Firefox](zenhub.com)


## Targeted values:

- Fully readable and indented elixir code generated from compilation
- Seamless and stress less interop with existing Elixir code, preferably with magically working type safety
- Full integration with entire elm syntax for editors and compilers magic


