# vstyle-tools

**This project is under development and not ready for use.**

A formatter/linter for Coq source.

https://vstyle.readthedocs.io

# Building & running

```console
$ dune build
$ ./_build/default/src/coqformat.exe --help
```

# Example

```console
$ ./_build/default/src/coqformat.exe examples/Foo.v
```

# Formatting the source

```console
$ dune build @fmt --auto-promote
```
