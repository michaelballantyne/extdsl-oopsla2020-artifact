# Getting started

Our artifact is packaged as sources together with a Dockerfile that
creates an appropriate execution environment. The following commands
will unzip the artifact, build a docker image with needed dependencies,
and launch a container. Note that depending on your Docker configuration
you may need to run the docker commands as root.

```
tar -xvjf 625.tar.bz2
cd 625
docker build -t artifact625 ./
docker create -ti --name artifact625 --network none --mount "type=bind,src=${PWD}/code,dst=/root/code" artifact625
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

We tested these instructions with Docker Desktop 2.3.0.3 on Mac OS
10.14. The only dependencies beyond those included in the artifact
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
  has a DEVELOPING.md file that describes its code.

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

Note that the code in the paper often differs slightly from the
corresponding running code in order to simplify the presentation. These
differences are explained with each example. The excerpts in the
submitted version of the paper also have several typos we have since
corrected.

### Section 1

The examples in section 1 show uses of Racket's existing `match`
feature and a hypothetical `css` extension that could be defined using
Racket's existing `define-match-expander` (and ad-hoc DSL extensibility
feature). Because these examples are merely suggestive, we do not
provide an implementation in the artifact.

### Section 2

#### 2.1

The code in figure 2 (lines 99-120) is in
`code/examples/2.1/figure-2/match-list.rkt` and
`code/examples/2.1/figure-2/example.rkt`

The example at lines 157-165 in the unnumbered "Reliable macros" is in
`code/examples/2.1/hygiene.rkt`, along with tests demonstrating that
hygiene ensures the macro behaves as intended.

#### 2.2

The annotated syntax in figure 157-165 conveys the intuition behind the
scope sets algorithm. The program `code/examples/2.2/scopes.rkt` expands
the example from lines 157-165 to show the real scopes annotated by the
expander. The scopes that correspond to the figure are as follows:

| scope from scopes.rkt output | scope in figure |
| ---------------------------- | ----------------|
| 0 | example.rkt |
| 2 | let1 |
| 3 | match-list.rkt |
| 6 | macro |
| 7 | let2 |
| 12 | let3 |

The full scope sets algorithm contains a number of optimizations and
edge cases that make the real scope annotations somewhat different:

* The scope sets model calls for use-site scopes, but the Racket
expander does not apply them in cases where their effect is subsumed
by other scopes. In this case the `match-list` macro is defined in a
different context than its use, so the expander does not apply a
use-site scope to the use.
* After resolving a reference to a local variable, the Racket expander
removes all scopes from the reference that are not needed in order for
it to refer to the binder. Thus in the final expansion, references to
the local `v` and `match-list-error` variables do not include scopes for
nested `let`s they are contained in.
* The example in the paper doesn't show scopes due to the expansion of
`cond`. Each `cond` clause body expands to a `let`, so identifiers
within these clauses have extra scopes (7, 9, and 12).
* The expander also applies "inside-edge" scopes, which are irrelevant
to this example. These are scopes 1, 4, 5, 7, 19, and 13 in the
program output.

These details are unimportant to the example and muddy the intuitive
understanding of scope sets, so we present a simplified view in the figure.
The full details are covered in the scope sets paper.

#### 2.3

Figure 4 (218-231) provides a very simplified sketch of the architecture
of Racket's `match` macro. The implementation of match can be found in
the artifact Docker container at
/usr/share/racket/collects/racket/match, or online at
https://github.com/racket/racket/tree/v7.8/racket/collects/racket/match

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
  `code/dsls/racket-peg-ee/private/forms.rkt`. The implementation is
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

#### 7.2

### Section 8

#### 8.1

#### 8.2

## Adding your own macro

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
