(* Command-line arguments *)

let usage_msg = "coqfmt [-verbose] <file1> [<file2>] ..."

let verbose = ref false

let input_files = ref []

let anon_fun filename =
  input_files := filename :: !input_files

let speclist =
  [("-verbose", Arg.Set verbose, "Output debug information")]


(* Coq init *)

module SP = Serapi.Serapi_protocol

let _ppd = Caml.Format.eprintf "===> %s@\n%!"

let exec_cmd =
  let st_ref = ref (SP.State.make ()) in
  fun cmd ->
    try
      let ans, st = SP.exec_cmd !st_ref cmd in
      st_ref := st;
      ans
    with exn ->
      let msg = Caml.Printexc.to_string exn in
      [SP.ObjList [ SP.CoqString ("Exception raised in Coq: " ^ msg) ]]


(* driver *)

let driver debug coq_path ml_path load_path rload_path disallow_sprop omit_loc omit_att omit_env exn_on_opaque =
  let () = Coq_init.init debug coq_path ml_path load_path rload_path disallow_sprop omit_loc omit_att omit_env exn_on_opaque in
  Caml.Format.eprintf "🐓🐓 Coq's initialization complete 🐓🐓@\n%!"


open Cmdliner


let coqfmt_version = "0.0.1"

let coqfmt_doc = "Coq formatter"

let coqfmt_man =
  [
    `S "DESCRIPTION";
    `P "Coq formatter.";
    `S "USAGE";
    `P "See the documentation on the project's website for more information."
  ]

let fatal_exn exn info =
  let loc = Loc.get_loc info in
  let msg = Pp.(pr_opt_no_spc Topfmt.pr_loc loc ++ fnl ()
                ++ CErrors.iprint (exn, info)) in
  Format.eprintf "Error: @[%a@]@\n%!" Pp.pp_with msg;
  exit 1

let () =
  Caml.Arg.parse speclist anon_fun usage_msg;

  let coqfmt_cmd =
    let open Sertop.Sertop_arg in
      Term.(const driver
        $ debug
        $ prelude
        $ ml_include_path
        $ load_path
        $ rload_path
        $ disallow_sprop
        $ omit_loc
        $ omit_att
        $ omit_env
        $ exn_on_opaque
        ),
      Term.info "coq-fmt" ~version:coqfmt_version ~doc:coqfmt_doc ~man:coqfmt_man in

  try match Term.eval ~catch:false coqfmt_cmd with
    | `Error _ -> exit 1
    | `Version
    | `Help
    | `Ok ()   -> exit 0
  with exn ->
    let (e, info) = Exninfo.capture exn in
    fatal_exn e info
