(* -*- coq-prog-name: "~/research/coq/trunk/bin/coqtop.byte"; coq-prog-args: ("-emacs-U" "-top" "Coq.Classes.Morphisms"); compile-command: "make -C ../.. TIME='time -p'" -*- *)
(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(* Typeclass-based morphism definition and standard, minimal instances.
 
   Author: Matthieu Sozeau
   Institution: LRI, CNRS UMR 8623 - UniversitÃcopyright Paris Sud
   91405 Orsay, France *)

(* $Id$ *)

Set Manual Implicit Arguments.

Require Import Coq.Program.Basics.
Require Import Coq.Program.Tactics.
Require Import Coq.Relations.Relation_Definitions.
Require Export Coq.Classes.RelationClasses.

(** * Morphisms.

   We now turn to the definition of [Proper] and declare standard instances. 
   These will be used by the [setoid_rewrite] tactic later. *)

(** A morphism for a relation [R] is a proper element of the relation.
   The relation [R] will be instantiated by [respectful] and [A] by an arrow type 
   for usual morphisms. *)

Class Proper {A} (R : relation A) (m : A) : Prop :=
  proper : R m m.

(** Respectful morphisms. *)

(** The fully dependent version, not used yet. *)

Definition respectful_hetero 
  (A B : Type) 
  (C : A -> Type) (D : B -> Type) 
  (R : A -> B -> Prop) 
  (R' : forall (x : A) (y : B), C x -> D y -> Prop) : 
    (forall x : A, C x) -> (forall x : B, D x) -> Prop := 
    fun f g => forall x y, R x y -> R' x y (f x) (g y).

(** The non-dependent version is an instance where we forget dependencies. *)

Definition respectful {A B : Type}
  (R : relation A) (R' : relation B) : relation (A -> B) :=
  Eval compute in @respectful_hetero A A (fun _ => B) (fun _ => B) R (fun _ _ => R').

(** Notations reminiscent of the old syntax for declaring morphisms. *)

Delimit Scope signature_scope with signature.

Arguments Scope Proper [type_scope signature_scope].
Arguments Scope respectful [type_scope type_scope signature_scope signature_scope].

Module ProperNotations.

  Notation " R ++> R' " := (@respectful _ _ (R%signature) (R'%signature)) 
    (right associativity, at level 55) : signature_scope.
  
  Notation " R ==> R' " := (@respectful _ _ (R%signature) (R'%signature))
    (right associativity, at level 55) : signature_scope.
  
  Notation " R --> R' " := (@respectful _ _ (inverse (R%signature)) (R'%signature))
    (right associativity, at level 55) : signature_scope.

End ProperNotations.

Export ProperNotations.

Open Local Scope signature_scope.

(** Dependent pointwise lifting of a relation on the range. *) 

Definition forall_relation {A : Type} {B : A -> Type} (sig : Π a : A, relation (B a)) : relation (Π x : A, B x) :=
  λ f g, Π a : A, sig a (f a) (g a).

Arguments Scope forall_relation [type_scope type_scope signature_scope].

(** Non-dependent pointwise lifting *)

Definition pointwise_relation (A : Type) {B : Type} (R : relation B) : relation (A -> B) := 
  Eval compute in forall_relation (B:=λ _, B) (λ _, R).

Lemma pointwise_pointwise A B (R : relation B) : 
  relation_equivalence (pointwise_relation A R) (@eq A ==> R).
Proof. intros. split. simpl_relation. firstorder. Qed.

(** We can build a PER on the Coq function space if we have PERs on the domain and
   codomain. *)

Hint Unfold Reflexive : core.
Hint Unfold Symmetric : core.
Hint Unfold Transitive : core.

Typeclasses Opaque respectful pointwise_relation forall_relation.

Program Instance respectful_per `(PER A (R : relation A), PER B (R' : relation B)) : 
  PER (R ==> R').

  Next Obligation.
  Proof with auto.
    assert(R x0 x0).
    transitivity y0... symmetry...
    transitivity (y x0)...
  Qed.

(** Subrelations induce a morphism on the identity. *)

Instance subrelation_id_proper `(subrelation A R₁ R₂) : Proper (R₁ ==> R₂) id.
Proof. firstorder. Qed.

(** The subrelation property goes through products as usual. *)

Instance subrelation_respectful `(subl : subrelation A R₂ R₁, subr : subrelation B S₁ S₂) :
  subrelation (R₁ ==> S₁) (R₂ ==> S₂).
Proof. simpl_relation. apply subr. apply H. apply subl. apply H0. Qed.

(** And of course it is reflexive. *)

Instance subrelation_refl : ! subrelation A R R.
Proof. simpl_relation. Qed.

(** [Proper] is itself a covariant morphism for [subrelation]. *)

Lemma subrelation_proper `(mor : Proper A R₁ m, unc : Unconvertible (relation A) R₁ R₂,
  sub : subrelation A R₁ R₂) : Proper R₂ m.
Proof.
  intros. apply sub. apply mor.
Qed.

CoInductive apply_subrelation : Prop := do_subrelation.

Ltac proper_subrelation :=
  match goal with 
    [ H : apply_subrelation |- _ ] => clear H ; eapply @subrelation_proper
  end.

Hint Extern 4 (@Proper _ ?H _) => proper_subrelation : typeclass_instances.

Instance proper_subrelation_proper : 
  Proper (subrelation ++> @eq _ ==> impl) (@Proper A).
Proof. reduce. subst. firstorder. Qed.

(** Essential subrelation instances for [iff], [impl] and [pointwise_relation]. *)

Instance iff_impl_subrelation : subrelation iff impl | 2.
Proof. firstorder. Qed.

Instance iff_inverse_impl_subrelation : subrelation iff (inverse impl) | 2.
Proof. firstorder. Qed.

Instance pointwise_subrelation {A} `(sub : subrelation B R R') :
  subrelation (pointwise_relation A R) (pointwise_relation A R') | 4.
Proof. reduce. unfold pointwise_relation in *. apply sub. apply H. Qed.

(** The complement of a relation conserves its proper elements. *)

Program Instance complement_proper
  `(mR : Proper (A -> A -> Prop) (RA ==> RA ==> iff) R) :
  Proper (RA ==> RA ==> iff) (complement R).

  Next Obligation.
  Proof.
    unfold complement.
    pose (mR x y H x0 y0 H0).
    intuition.
  Qed.

(** The [inverse] too, actually the [flip] instance is a bit more general. *) 

Program Instance flip_proper
  `(mor : Proper (A -> B -> C) (RA ==> RB ==> RC) f) :
  Proper (RB ==> RA ==> RC) (flip f).

  Next Obligation.
  Proof.
    apply mor ; auto.
  Qed.

(** Every Transitive relation gives rise to a binary morphism on [impl], 
   contravariant in the first argument, covariant in the second. *)

Program Instance trans_contra_co_morphism
  `(Transitive A R) : Proper (R --> R ++> impl) R | 6.

  Next Obligation.
  Proof with auto.
    transitivity x...
    transitivity x0...
  Qed.

(** Proper declarations for partial applications. *)

Program Instance trans_contra_inv_impl_morphism
  `(Transitive A R) : Proper (R --> inverse impl) (R x) | 3.

  Next Obligation.
  Proof with auto.
    transitivity y...
  Qed.

Program Instance trans_co_impl_morphism
  `(Transitive A R) : Proper (R ++> impl) (R x) | 3.

  Next Obligation.
  Proof with auto.
    transitivity x0...
  Qed.

Program Instance trans_sym_co_inv_impl_morphism
  `(PER A R) : Proper (R ++> inverse impl) (R x) | 3.

  Next Obligation.
  Proof with auto.
    transitivity y... symmetry...
  Qed.

Program Instance trans_sym_contra_impl_morphism
  `(PER A R) : Proper (R --> impl) (R x) | 3.

  Next Obligation.
  Proof with auto.
    transitivity x0... symmetry...
  Qed.

Program Instance per_partial_app_morphism
  `(PER A R) : Proper (R ==> iff) (R x) | 2.

  Next Obligation.
  Proof with auto.
    split. intros ; transitivity x0...
    intros.
    transitivity y...
    symmetry...
  Qed.

(** Every Transitive relation induces a morphism by "pushing" an [R x y] on the left of an [R x z] proof
   to get an [R y z] goal. *)

Program Instance trans_co_eq_inv_impl_morphism
  `(Transitive A R) : Proper (R ==> (@eq A) ==> inverse impl) R | 3.

  Next Obligation.
  Proof with auto.
    transitivity y...
  Qed.

(** Every Symmetric and Transitive relation gives rise to an equivariant morphism. *)

Program Instance PER_morphism `(PER A R) : Proper (R ==> R ==> iff) R | 2.

  Next Obligation.
  Proof with auto.
    split ; intros.
    transitivity x0... transitivity x... symmetry...
  
    transitivity y... transitivity y0... symmetry...
  Qed.

Lemma symmetric_equiv_inverse `(Symmetric A R) : relation_equivalence R (flip R).
Proof. firstorder. Qed.
  
Program Instance compose_proper A B C R₀ R₁ R₂ :
  Proper ((R₁ ==> R₂) ==> (R₀ ==> R₁) ==> (R₀ ==> R₂)) (@compose A B C).

  Next Obligation.
  Proof.
    simpl_relation.
    unfold compose. apply H. apply H0. apply H1.
  Qed.

(** Coq functions are morphisms for leibniz equality, 
   applied only if really needed. *)

Instance reflexive_eq_dom_reflexive (A : Type) `(Reflexive B R') :
  Reflexive (@Logic.eq A ==> R').
Proof. simpl_relation. Qed.

(** [respectful] is a morphism for relation equivalence. *)

Instance respectful_morphism : 
  Proper (relation_equivalence ++> relation_equivalence ++> relation_equivalence) (@respectful A B).
Proof.
  reduce.
  unfold respectful, relation_equivalence, predicate_equivalence in * ; simpl in *.
  split ; intros.
  
    rewrite <- H0.
    apply H1.
    rewrite H.
    assumption.

    rewrite H0.
    apply H1.
    rewrite <- H.
    assumption.
Qed.

(** Every element in the carrier of a reflexive relation is a morphism for this relation.
   We use a proxy class for this case which is used internally to discharge reflexivity constraints.
   The [Reflexive] instance will almost always be used, but it won't apply in general to any kind of 
   [Proper (A -> B) _ _] goal, making proof-search much slower. A cleaner solution would be to be able
   to set different priorities in different hint bases and select a particular hint database for
   resolution of a type class constraint.*) 

Class ProperProxy {A} (R : relation A) (m : A) : Prop :=
  proper_proxy : R m m.

Lemma eq_proper_proxy A (x : A) : ProperProxy (@eq A) x.
Proof. firstorder. Qed.

Lemma reflexive_proper_proxy `(Reflexive A R) (x : A) : ProperProxy R x.
Proof. firstorder. Qed.

Lemma proper_proper_proxy `(Proper A R x) : ProperProxy R x.
Proof. firstorder. Qed.

Hint Extern 1 (ProperProxy _ _) => apply eq_proper_proxy || eapply @reflexive_proper_proxy : typeclass_instances.
(* Hint Extern 2 (ProperProxy ?R _) => not_evar R ; eapply @proper_proper_proxy : typeclass_instances. *)

(** [R] is Reflexive, hence we can build the needed proof. *)

Lemma Reflexive_partial_app_morphism `(Proper (A -> B) (R ==> R') m, ProperProxy A R x) :
   Proper R' (m x).
Proof. simpl_relation. Qed.

Class Params {A : Type} (of : A) (arity : nat).

Class PartialApplication.

CoInductive normalization_done : Prop := did_normalization.

Ltac partial_application_tactic := 
  let rec do_partial_apps H m :=
    match m with
      | ?m' ?x => eapply @Reflexive_partial_app_morphism ; [do_partial_apps H m'|clear H]
      | _ => idtac
    end
  in
  let rec do_partial H ar m :=
    match ar with
      | 0 => do_partial_apps H m
      | S ?n' => 
        match m with
          ?m' ?x => do_partial H n' m'
        end
    end
  in
  let on_morphism m :=
    let m' := fresh in head_of_constr m' m ;
    let n := fresh in evar (n:nat) ;
    let v := eval compute in n in clear n ;
    let H := fresh in
      assert(H:Params m' v) by typeclasses eauto ;
      let v' := eval compute in v in 
      do_partial H v' m
 in
  match goal with
    | [ _ : normalization_done |- _ ] => fail 1
    | [ _ : @Params _ _ _ |- _ ] => fail 1
    | [ |- @Proper ?T _ (?m ?x) ] => 
      match goal with 
        | [ _ : PartialApplication |- _ ] => 
          eapply @Reflexive_partial_app_morphism
        | _ => 
          on_morphism (m x) || 
            (eapply @Reflexive_partial_app_morphism ;
              [ pose Build_PartialApplication | idtac ])
      end
  end.

Hint Extern 4 (@Proper _ _ _) => partial_application_tactic : typeclass_instances.

Lemma inverse_respectful : forall (A : Type) (R : relation A) (B : Type) (R' : relation B),
  relation_equivalence (inverse (R ==> R')) (inverse R ==> inverse R').
Proof.
  intros.
  unfold flip, respectful.
  split ; intros ; intuition.
Qed.

(** Special-purpose class to do normalization of signatures w.r.t. inverse. *)

Class Normalizes (A : Type) (m : relation A) (m' : relation A) : Prop := 
  normalizes : relation_equivalence m m'.

(** Current strategy: add [inverse] everywhere and reduce using [subrelation]
   afterwards. *)

Lemma inverse_atom A R : Normalizes A R (inverse (inverse R)).
Proof.
  firstorder.
Qed.

Lemma inverse_arrow `(NA : Normalizes A R (inverse R'''), NB : Normalizes B R' (inverse R'')) :
  Normalizes (A -> B) (R ==> R') (inverse (R''' ==> R'')%signature).
Proof. unfold Normalizes. intros.
  rewrite NA, NB. firstorder.
Qed.

Ltac inverse :=   
  match goal with
    | [ |- Normalizes _ (respectful _ _) _ ] => eapply @inverse_arrow
    | _ => eapply @inverse_atom
  end.

Hint Extern 1 (Normalizes _ _ _) => inverse : typeclass_instances.

(** Treating inverse: can't make them direct instances as we 
   need at least a [flip] present in the goal. *)

Lemma inverse1 `(subrelation A R' R) : subrelation (inverse (inverse R')) R.
Proof. firstorder. Qed.

Lemma inverse2 `(subrelation A R R') : subrelation R (inverse (inverse R')).
Proof. firstorder. Qed.

Hint Extern 1 (subrelation (flip (flip _)) _) => eapply @inverse1 : typeclass_instances.
Hint Extern 1 (subrelation _ (flip (flip _))) => eapply @inverse2 : typeclass_instances.

(** That's if and only if *)
Instance eq_subrelation `(Reflexive A R) : subrelation (@eq A) R.
Proof. simpl_relation. Qed.

(** Once we have normalized, we will apply this instance to simplify the problem. *)

Definition proper_inverse_proper `(mor : Proper A R m) : Proper (inverse R) m := mor.

Hint Extern 2 (@Proper _ (flip _) _) => eapply @proper_inverse_proper : typeclass_instances.

(** Bootstrap !!! *)

Instance proper_proper : Proper (relation_equivalence ==> @eq _ ==> iff) (@Proper A).
Proof.
  simpl_relation.
  reduce in H.
  split ; red ; intros.
  setoid_rewrite <- H.
  apply H0.
  setoid_rewrite H.
  apply H0.
Qed.

Lemma proper_normalizes_proper `(Proper A R0 m, Normalizes A R0 R1) : Proper R1 m.
Proof.
  intros A R0 m H R' H'.
  red in H, H'. setoid_rewrite <- H'.
  assumption.
Qed.

Ltac proper_normalization :=
  match goal with
    | [ _ : normalization_done |- _ ] => fail 1
    | [ _ : apply_subrelation |- _ ] => fail 1
    | [ |- @Proper _ ?R _ ] => let H := fresh "H" in
      set(H:=did_normalization) ; eapply @proper_normalizes_proper
  end.

Hint Extern 6 (@Proper _ _ _) => proper_normalization : typeclass_instances.

(** Every reflexive relation gives rise to a morphism, only for immediately solving goals without variables. *)

Lemma reflexive_proper `{Reflexive A R} (x : A)
   : Proper R x.
Proof. firstorder. Qed.

Lemma proper_eq A (x : A) : Proper (@eq A) x. 
Proof. intros. apply reflexive_proper. Qed.

Ltac proper_reflexive :=
  match goal with
    | [ _ : normalization_done |- _ ] => fail 1
    | [ |- @Proper _ _ _ ] => apply proper_eq || eapply @reflexive_proper
  end.

Hint Extern 7 (@Proper _ _ _) => proper_reflexive : typeclass_instances.
