(* This is an example
 * of a Coq file
 *)

Definition five:
    nat
 := 5
.

Lemma five__eq__five:
    five = 5.
Proof.
    easy.
Qed.

Definition add_em (x y: nat):
    nat
 := x + y
.

Arguments add_em [_].

From Coq Require Import Lists.List.
Import ListNotations.

Definition listy_five:
    list nat
 := [ five ]
.

Fail Require Import SomethingThatDoesNotExist.

Lemma this_is_not_true:
    0 = 1.
Proof.
    Fail reflexivity.
Admitted.
