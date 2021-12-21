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

Definition add_em_2 x := add_em x.

Arguments add_em [_].

From Coq Require Import Lists.List.
Import ListNotations.

Definition listy_five:
    list nat
 := [ five ; five ]
.

Fail Require Import SomethingThatDoesNotExist.

Lemma this_is_not_true:
    0 = 1.
Proof.
    Fail reflexivity.
Admitted.

Unset Printing Notations.

Definition appy := Lists.List.app listy_five listy_five.

Definition sixteen := 0x10.

Require Import Coq.ZArith.ZArith.

Definition negative_sixteen: Z := -0X1_0.

Require Import Coq.Floats.Floats.

Definition fiftytwo: float := 5.2e1.

Definition fiftytwo_2: float := 5.2E1.

Definition fifty: float := 5E1.

From Coq Require Import Strings.String.

Definition a_string: string := ("foo")%string.
