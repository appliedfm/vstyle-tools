# vstyle-tools

A formatter/linter for Coq source.

https://vstyle.readthedocs.io

# Building & running

```console
$ dune build
$ ./_build/default/src/coqfmt.exe --help
```

# Example

```console
$ ./_build/default/src/coqfmt.exe examples/Foo.v
```

# Formatting the source

```console
$ dune build @fmt --auto-promote
```
