# Getting started

Our artifact is packaged as sources together with a Dockerfile that
creates an appropriate execution environment.

First, ensure you have a recent Docker installation. We tested these
instructions with [Docker Desktop](https://www.docker.com/products/docker-desktop) 2.3.0.3 on Mac OS 10.14,
and with version
`19.03.6-0ubuntu1~18.04.1` of the `docker.io` package on Ubuntu 18.04.4.
Docker may be installed on Ubuntu with the command:

```
sudo apt install docker.io -y
```

Then, the following commands will unzip the artifact, build a docker
image with needed dependencies, and launch a container. Note that
some Docker configurations require Docker commands to be run as root
(see <https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface>).
If you get an error like "ERRO[0000] failed to dial gRPC: cannot connect to the Docker daemon...",
you probably need to run as root.

```
tar -xvjf 625.tar.bz2
cd 625
docker build -t artifact625 ./
docker create -ti --name artifact625 --network none \
  --mount "type=bind,src=${PWD}/code,dst=/root/code" artifact625
docker start artifact625
```

Once the container is running, this command builds our library,
case studies, and examples:

```
docker exec artifact625 /root/code/build.sh
```

Finally, this command runs all tests and examples:

```
docker exec artifact625 /root/code/test.sh
```

The output should include "274 tests passed" and "38 tests passed".

The only dependencies beyond those included in the artifact
archive are Docker and the `ubuntu:20.04` base Docker image that is
downloaded when building our artifact's image.

# Step by step

Our paper makes no experimental claims. Therefore, our artifact simply
demonstrates that our new syntax system API and DSL expander case
studies work in the way illustrated by the examples in the paper.
The remainder of this overview shows how the code excerpts in the paper
correspond to our implementations and complete examples. It also shows
how to extend the PEG DSL with a new element of syntactic sugar.

## Guide to the code

The `dependencies` directory includes a linux Racket installer and
snapshots of the Racket packages that our case studies depend on. The
`Dockerfile` uses these files to build an image.

The `code` directory contains all the code developed along with our
paper:

* `ee-lib` is the library that implements our new syntax system API.
* `dsls` contains the implementations of our case study DSLs. Each DSL
  folder has an ARTIFACT.md file directly inside that describes its code.

   | Example 	      |	   Directory |
   | ---------------- | ------------ |
   | Parsing Expression Grammars | `racket-peg-ee` |
   | Command-line argument parsing | `cmdline-ee` |
   | miniKanren logic programming language | `minikanren-ee` |
   | Rash shell language | `racket-rash` |
   |  Typed Racket's language of types | `type-expander` |


* `examples` contains code for each example in the paper.

The `code` directory is shared between your machine and the Docker
container, where it is mounted at `/root/code`.  Thus you can edit the
examples or DSL implementations on your host machine and run the code in
the container. To get a shell in the container, run:

```
docker exec -ti artifact625 /bin/bash
```

In general, you can run a `.rkt` file with the command:

```
racket <filename>
```

and run any tests embedded in the file with:

```
raco test <filename>
```

If you modify a dependency of a file, you may need to re-build the compiled
version of the file for the changes to take effect. Use the command:

```
raco make <filename>
```

## Code excerpts

Most code snippets in the paper correspond either to an example in
`code/examples`, or to part of the PEG DSL implementation in
`code/dsls/racket-peg-ee`.

The example code in the paper differs slightly from the running code in
the artifact in order to simplify the presentation. Each example comes
with an explanation of the relevant differences. The excerpts in the
submitted version of the paper also have several typos we have since
corrected.

### Section 1

The examples in section 1 show uses of Racket's existing `match` feature
and a hypothetical `css` extension that could be defined using `match`'s
existing ad-hoc DSL extensibility feature, [`define-match-expander`]
(https://docs.racket-lang.org/reference/match.html?q=define-match-expander#%28form._%28%28lib._racket%2Fmatch..rkt%29._define-match-expander%29%29).
Because these examples are merely suggestive, we do not provide an
implementation in the artifact.

### Section 2

#### 2.1

The code in figure 2 (lines 99-120) is in
`code/examples/2.1/figure-2/match-list.rkt` and
`code/examples/2.1/figure-2/example.rkt`

The example at lines 157-165 in the unnumbered "Reliable macros" is in
`code/examples/2.1/hygiene.rkt`, along with tests demonstrating that
hygiene ensures the macro behaves as intended.

#### 2.2

The annotated syntax in figure 3 (lines 197-203) conveys the intuition
behind the scope sets algorithm. The program
`code/examples/2.2/scopes.rkt` expands the example from lines 157-165 to
show the real scopes annotated by the expander. The scopes that
correspond to the figure are as follows:

| scope from scopes.rkt output | scope in figure |
| ---------------------------- | ----------------|
| 0 | example.rkt |
| 2 | let1 |
| 3 | match-list.rkt |
| 6 | macro |
| 7 | let2 |
| 12 | let3 |

The full scope sets algorithm contains a number of optimizations and
edge cases that make the real scope annotations differ:

* In this case, the effect of the use-site scope is subsumed by others,
so the expander does not apply it.
* After resolving a references to local variables such as `v` and
  `match-list-binder`, the expander removes all scopes from the
reference that are not needed in order for it to refer to the binder.
* The example in the paper doesn't show scopes due to the expansion of
`cond`.
* The expander also applies "inside-edge" scopes, which are irrelevant
to this example.

These details are unimportant to the example and muddy the intuitive
understanding of scope sets, so we present a simplified view in the figure.
The full details are covered in the scope sets paper.

#### 2.3

Figure 4 (218-231) provides a very simplified sketch of the architecture
of Racket's `match` macro. The implementation of match can be found in
the artifact Docker container at
`/usr/share/racket/collects/racket/match`, or online at
<https://github.com/racket/racket/tree/v7.8/racket/collects/racket/match>

### Section 3

#### 3.2

The API described here is implemented in `code/ee-lib/main.rkt`.

### Section 4

#### 4.1

The code in figure 7 (419-435) is in `code/examples/4.1/figure-7.rkt`.
Our implementation of the PEG DSL uses the library name `racket-peg-ee`
rather than `peg`, which is reflected in the import. We stub out the
`term` production to match any number via the `predicate-token` PEG
syntax.  In our artifact we declare `struct`s with the `#:transparent`
option to make writing tests easier, but omit the `#:transparent`
declaration in the paper examples for simplicity.

Our PEG DSL can implement a lexer or scannerless parser matching text,
or a traditional parser matching lists of tokens. The submitted version
of the paper was not careful to distinguish which mode each example
used. In this example we match a list of tokens represented as string
and number values. To indicate that string literals as PEG expressions
should parse string values, the artifact's version includes the
declaration `(use-literal-token-interpretation string-token)`.
Internally this works via the `#%peg-datum` interposition point
discussed in section 7.2.


#### 4.2

The left-recursive example of lines 451-455 corresponds to the test in
`code/examples/4.2/leftrec.rkt`, which ensures that the implementation
recognizes the left-recursion and raises a compile-time error. The
left-recursion check is implemented in
`code/dsls/racket-peg-ee/private/leftrec-check.rkt`, driven by the
interface macros in `code/dsls/racket-peg-ee/core.rkt`.

#### 4.3

Lines 468-470 are in `code/examples/4.3/optimization.rkt`. The submitted
version of the paper contains a mistake in this section: it should say
that the PEG DSL implements these optimizations for text matching, not
for token matching. Because of the design of the DSL's extensible token
matching (discussed in section 7.2), there is not enough compile-time
information about the token matchers to implement the binary search
optimization for tokens.  While adding an error check to the
optimization after our submission, we also discovered that the "<" and
">" alternatives must appear after the "<=" and ">=" alternatives due to
PEG's ordered choice semantics.

Running the example both tests the code and outputs the Racket code to
which the `comp-op` production compiles, which includes the unrolled
binary search. The optimization is implemented in
`code/dsls/racket-peg-ee/private/compile-alt-str.rkt`.

#### 4.4

The `many-until` macro of lines 483-490 is implemented in
`code/examples/4.4/many-until.rkt` along with a fragment of a lexer
demonstrating its use.

### Section 5

Figure 8 (paper lines 491-518) is composed of elements defined in several
places in the full PEG DSL implementation:

* Figure lines 1-2 correspond to the literals definition in
  `code/dsls/racket-peg-ee/private/forms.rkt`
* Lines 5-6 are implemented in
  `code/dsls/racket-peg-ee/private/env-reps.rkt`. The implementation is
somewhat more complex because it also defines interfaces using
`racket/generic` to allow other DSLs to create bindings that act as PEG
non-terminals or PEG macros while also having other behaviors in the other
DSLs. The structure types implement those interfaces.
* `expand-peg` (lines 9-27) is implemented in
  `code/dsls/racket-peg-ee/private/expand.rkt`.

#### 5.1

As mentioned on line 618, figure 9 (lines 622-634) is a simplified
sketch of the full interface macro implementation. The full
implementation consists of the macros `define-peg`, `define-peg-pass2`,
and `define-peg-rhs` in `code/dsls/racket-peg-ee/core.rkt`. The complete
implementation enables mutually recursive PEG non-terminals.

The exports at lines 646-647 of the paper are at the top of
`code/dsls/racket-peg-ee/core.rkt`.

### Section 7

#### 7.1

The code on lines 725-730 is in `code/examples/7.1/raise-1.rkt`, lines
12-16. The example uses tokens represented as Racket syntax objects in
order to retain source location information. The
`(use-literal-token-interpretation syntax-token)` declaration makes
string literals in PEG expressions parse syntax objects containing
symbols with the same string value.

The implementation of the `define-peg-ast` form from figure 10 (lines
758-767) is in `code/examples/7.1/define-peg-ast.rkt`.

Finally, the concise definition of the `raise` production using
`define-peg-ast` from lines 739-740 is in
`code/examples/7.1/raise-2.rkt`

#### 7.2

All code from this section is in
`code/examples/7.2/return-example.rkt`. The implementation's token
interface is richer than that presented in the paper. Rather than simply
returning a boolean indicating whether the token matched, token
specification functions return two values:

1. either `#f` indicating failure, or a value to be used as the semantic
   value of the `token` PEG expression
2. a source location structure, or `#f` indicating no source location
   information is available.

The version of `keyword` in the artifact thus returns the
`expected-name` when the token matches, along with `#f` to indicate no
source location information is available.

The `lexer-tokens` submodule provides the list of Python keywords that
the paper example imports from a `python-lexer` module.

### Section 8

#### 8.1

##### miniKanren
See `code/examples/8.1/minikanren.rkt`.

Our miniKanren implementation returns the results of the query in a
different order from that shown in the paper. The order is not
semantically significant.

##### Rash
See `code/examples/8.1/rash.rkt`.

The artifact version imports `csv->list` from `csv-reading` and `fourth`
from `racket/list`. In order to work with decimals as exact numbers, it
configures the reader with `(read-decimal-as-inexact #f)`, and formats
the final result with `exact->inexact`.

It is also possible to test the example in the interactive shell. After
running the build step from "Getting started", run
`/root/.racket/7.8/bin/rash-repl` in the Docker container to start the
shell. Change to the `/root/code/examples/8.1` directory and input all
but the `#lang rash` line.

##### Command-line argument parsing
See `code/examples/8.1/cmdline.rkt`.

The syntax in the artifact is slightly more verbose because the DSL
includes more features than demonstrated in the paper. The `#:options`
keyword specifies that the following clauses concern command-line
options; additional features such as positional arguments are supported
by other keywords. The full implementation also uses a naming convention
where option syntax names end in `/o` and flag syntaxes end in `/f`.

##### Typed Racket
See `code/examples/8.1/typed-racket.rkt`.

#### 8.2

##### miniKanren

Lines 914-916: see `code/examples/8.2/minikanren-macro.rkt`. The
`defrel/match` syntax is defined in `code/dsls/minikanren-ee/main.rkt`.
The presentation in the paper uses a pattern syntax similar to that
supported by Racket's `match` form, which we expect to be most familiar
to readers. The real DSL in the artifact uses a different syntax
inspired by a pattern matcher written for Chez Scheme.

The compile-time error behavior mentioned on lines 929-930 is tested in
`code/examples/8.2/minikanren-compile-time-errors.rkt`.

`code/examples/8.2/minikanren-program-transformation.rkt` demonstrates
the program transformation discussed in the paper at lines 912-950.
Running the program expands the version of `append` with the recursive
call in the middle of the two unifications and prints the core language
syntax after program transformation. In the core syntax, the two
unifications come before the recursive call. The test also verifies that
the query from line 945 terminates.

##### Rash

See `code/examples/8.2/rash.rkt`.

The example can be run in the interactive shell just as the example
from 8.1 using `/root/.racket/7.8/bin/rash-repl`.

##### Command-line argument parsing

See `code/examples/8.2/cmdline.rkt`.

The `numbered-flags/f` and `list/o` macros are defined in
`code/dsls/cmdline-ee/main.rkt`.

##### Typed Racket

See `code/examples/8.2/typed-racket.rkt`.

## Adding a piece of syntactic sugar

This section provides instructions for adding an element of syntactic
sugar to the PEG DSL to suggest how you might explore the artifact
further.

It is common to parse an optional sequence of elements, as in the `raise`
production in `code/examples/7.1/raise-2.rkt`. Currently `?` takes only
one subexpression, so an optional sequence within an overall sequence
needs to be written:

```
(seq "a" (? (seq "b" "c")) "d")
```

We can change `?` to accept multiple elements in its body in an
implicit sequence. Then we can write:

```
(seq "a" (? "b" "c") "d")
```

To make this change, add a new, sugary definition of `?` at the bottom
of `code/dsls/racket-peg-ee/main.rkt`:

```
(define-peg-syntax-parser new-?
  [(_ p:peg ...+) #'(? (seq p ...))])
```

Then, change the `?` part of the provide at the top of the file (line
15) to:

```
(rename-out [new-? ?])
```

Try out the change by editing `code/examples/7.1/raise-2.rkt`, replacing
the existing expression:

```
(seq "raise" (? (seq (: exn test) (? (seq "from" (: from test))))))
```

with:

```
(seq "raise" (? (: exn test) (? "from" (: from test))))
```

To see if it worked, rebuild and test `raise-2.rkt` by running these commands in the container:

```
raco make /root/code/examples/7.1/raise-2.rkt
raco test /root/code/examples/7.1/raise-2.rkt
```

## Tear down


The following commands delete the docker container and image:

```
docker container stop artifact625
docker container rm artifact625
docker image rm artifact625
```

If you would like to remove the base Ubuntu 20.04 image as well, run:

```
docker image rm ubuntu:20.04
```
