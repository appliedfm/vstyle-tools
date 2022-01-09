val coqfmt_version : string

val coqfmt_man : Cmdliner.Manpage.block list

val coqfmt_doc : string

val debug : bool Cmdliner.Term.t

val input_file : string Cmdliner.Term.t

val disallow_sprop : bool Cmdliner.Term.t

val async : string option Cmdliner.Term.t

val async_workers : int Cmdliner.Term.t

val error_recovery : bool Cmdliner.Term.t

val prelude : string Cmdliner.Term.t

val ml_include_path : string list Cmdliner.Term.t

val load_path : Loadpath.vo_path list Cmdliner.Term.t

val rload_path : Loadpath.vo_path list Cmdliner.Term.t

val omit_loc : bool Cmdliner.Term.t

val omit_att : bool Cmdliner.Term.t

val omit_env : bool Cmdliner.Term.t

val exn_on_opaque : bool Cmdliner.Term.t
