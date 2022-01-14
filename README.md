# vstyle-tools

**This project is under development and not ready for use.**

A formatter/linter for Coq source.

https://vstyle.readthedocs.io

# Installing

```console
$ opam install src/coq-vstyle.opam
$ coqformat --help
```

# Building & running

```console
$ cd src
/src$ dune build
/src$ dune exec ./coqformat.exe -- --help
```

# Example

```console
$ cd src
/src$ dune exec ./coqformat.exe -- ../examples/Foo.v
```

# Formatting the source

```console
$ cd src
/src$ dune build @fmt --auto-promote
```
