let create_document ~in_file ~stm_flags ~quick ~ml_load_path ~vo_load_path ~debug ~allow_sprop =
  let open Sertop.Sertop_init in
  (* coq initialization *)
  coq_init
    {
      fb_handler = (fun _ _ -> ()) (* XXXX *);
      ml_load = None;
      debug;
      allow_sprop;
      indices_matter = false;
      ml_path = ml_load_path;
      vo_path = vo_load_path;
    }
    Format.std_formatter;

  (* document initialization *)
  let stm_options = process_stm_flags stm_flags in

  (* Disable due to https://github.com/ejgallego/coq-serapi/pull/94 *)
  let stm_options =
    { stm_options with async_proofs_tac_error_resilience = `None; async_proofs_cmd_error_resilience = false }
  in

  let stm_options = if quick then { stm_options with async_proofs_mode = APonLazy } else stm_options in

  let injections = [ Coqargs.RequireInjection ("Coq.Init.Prelude", None, Some false) ] in

  let ndoc = { Stm.doc_type = Stm.VoDoc in_file; injections; stm_options } in

  (* Workaround, see
     https://github.com/ejgallego/coq-serapi/pull/101 *)
  if quick || stm_flags.enable_async <> None then Safe_typing.allow_delayed_constants := true;

  Stm.new_doc ndoc

let check_pending_proofs ~pstate =
  Option.iter
    (fun _pstate ->
      (* let pfs = Vernacstate.get_all_proof_names pstate in *)
      let pfs = [] in
      if not CList.(is_empty pfs) then
        let msg =
          let open Pp in
          seq [ str "There are pending proofs: "; pfs |> List.rev |> prlist_with_sep pr_comma Names.Id.print; str "." ]
        in
        CErrors.user_err msg)
    pstate

let close_document ~doc ~pstate =
  let _doc = Stm.join ~doc in
  check_pending_proofs ~pstate

let driver debug disallow_sprop async async_workers error_recovery quick coq_path ml_path load_path rload_path in_file
    omit_loc omit_att omit_env exn_on_opaque =
  (* initialization *)
  let options = Serlib.Serlib_init.{ omit_loc; omit_att; exn_on_opaque; omit_env } in
  Serlib.Serlib_init.init ~options;

  let dft_ml_path, vo_path = Serapi.Serapi_paths.coq_loadpath_default ~implicit:true ~coq_path in
  let ml_load_path = dft_ml_path @ ml_path in
  let vo_load_path = vo_path @ load_path @ rload_path in

  let allow_sprop = not disallow_sprop in
  let stm_flags = { Sertop.Sertop_init.enable_async = async; deep_edits = false; async_workers; error_recovery } in

  let doc, sid = create_document ~in_file ~stm_flags ~quick ~ml_load_path ~vo_load_path ~debug ~allow_sprop in

  (* main loop *)
  let in_chan = open_in in_file in
  let doc, _sid = Formatter.format_doc ~in_file ~in_chan ~doc ~sid in
  let pstate = match Stm.state_of_id ~doc sid with `Valid (Some { Vernacstate.lemmas; _ }) -> lemmas | _ -> None in
  let () = close_document ~doc ~pstate in
  ()

let fatal_exn exn info =
  let loc = Loc.get_loc info in
  let msg = Pp.(pr_opt_no_spc Topfmt.pr_loc loc ++ fnl () ++ CErrors.iprint (exn, info)) in
  Format.eprintf "Error: @[%a@]@\n%!" Pp.pp_with msg;
  exit 1

let main () =
  let coqfmt_cmd =
    let open Arg in
    ( Cmdliner.Term.(
        const driver $ debug $ disallow_sprop $ async $ async_workers $ error_recovery $ quick $ prelude
        $ ml_include_path $ load_path $ rload_path $ input_file $ omit_loc $ omit_att $ omit_env $ exn_on_opaque),
      Cmdliner.Term.info "coqfmt" ~version:coqfmt_version ~doc:coqfmt_doc ~man:coqfmt_man )
  in

  try match Cmdliner.Term.eval ~catch:false coqfmt_cmd with `Error _ -> exit 1 | `Version | `Help | `Ok () -> exit 0
  with exn ->
    let e, info = Exninfo.capture exn in
    fatal_exn e info

let _ = main ()
