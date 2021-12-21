# vstyle-tools

**This project is under development and not ready for use.**

A formatter/linter for Coq source.

https://vstyle.readthedocs.io

# Building & running

```console
$ cd src
/src$ dune build
/src$ ./_build/default/coqformat.exe --help
```

# Example

```console
$ cd src
/src$ ./_build/default/coqformat.exe ../examples/Foo.v
```

# Formatting the source

```console
$ cd src
/src$ dune build @fmt --auto-promote
```
