open Cmdliner

let coqfmt_version = "0.0.1"

let coqfmt_man =
  [
    `S "DESCRIPTION";
    `P "Coq source formatter.";
    `S "USAGE";
    `P "To format the file `fs/fun.v` with logical path `Funs`:";
    `Pre "coqfmt -Q fs,Funs fs/fun.v > fs/fun.sexp";
    `P "See https://vstyle.readthedocs.io for more information.";
  ]

let coqfmt_doc = "coqfmt Coq source formatter"

let debug =
  let doc = "Enable debug mode for Coq." in
  Arg.(value & flag & info [ "debug" ] ~doc)

let input_file =
  let doc = "Input file." in
  Arg.(required & pos 0 (some string) None & info [] ~docv:"FILE" ~doc)

let disallow_sprop =
  let doc = "Forbid using the proof irrelevant SProp sort (allowed by default)" in
  Arg.(value & flag & info [ "disallow-sprop" ] ~doc)

let async =
  let doc = "Enable async support using Coq binary $(docv) (experimental)." in
  Arg.(value & opt (some string) None & info [ "async" ] ~doc ~docv:"COQTOP")

let async_workers =
  let doc = "Maximum number of async workers." in
  Arg.(value & opt int 3 & info [ "async-workers" ] ~doc)

let error_recovery =
  let doc = "Enable Coq's error recovery inside tactics and commands." in
  Arg.(value & flag & info [ "error-recovery" ] ~doc)

let quick =
  let doc = "Skip checking opaque proofs (very experimental)." in
  Arg.(value & flag & info [ "quick" ] ~doc)

let prelude =
  let doc = "Load Coq.Init.Prelude from $(docv); plugins/ and theories/ should live there." in
  Arg.(value & opt string Coq_config.coqlib & info [ "coqlib" ] ~docv:"COQPATH" ~doc)

let ml_include_path : string list Term.t =
  let doc = "Include DIR in default loadpath, for locating ML files" in
  Arg.(value & opt_all dir [] & info [ "I"; "ml-include-path" ] ~docv:"DIR" ~doc)

let coq_lp_conv ~implicit (unix_path, lp) =
  Loadpath.{ coq_path = Libnames.dirpath_of_string lp; unix_path; has_ml = true; recursive = true; implicit }

let load_path : Loadpath.vo_path list Term.t =
  let doc = "Bind a logical loadpath LP to a directory DIR" in
  Term.(
    const List.(map (coq_lp_conv ~implicit:false))
    $ Arg.(value & opt_all (pair dir string) [] & info [ "Q"; "load-path" ] ~docv:"DIR,LP" ~doc))

let rload_path : Loadpath.vo_path list Term.t =
  let doc = "Bind a logical loadpath LP to a directory DIR and implicitly open its namespace." in
  Term.(
    const List.(map (coq_lp_conv ~implicit:true))
    $ Arg.(value & opt_all (pair dir string) [] & info [ "R"; "rec-load-path" ] ~docv:"DIR,LP" ~doc))

let omit_loc : bool Term.t =
  let doc = "[debug option] shorten location printing" in
  Arg.(value & flag & info [ "omit_loc" ] ~doc)

let omit_att : bool Term.t =
  let doc = "[debug option] omit attribute nodes" in
  Arg.(value & flag & info [ "omit_att" ] ~doc)

let omit_env : bool Term.t =
  let doc = "[debug option] turn enviroments into abstract objects" in
  Arg.(value & flag & info [ "omit_env" ] ~doc)

let exn_on_opaque : bool Term.t =
  let doc = "[debug option] raise an exception on non-serializeble terms" in
  Arg.(value & flag & info [ "exn_on_opaque" ] ~doc)
