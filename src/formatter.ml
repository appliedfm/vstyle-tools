exception End_of_input

let format_doc ~in_file ~in_chan ~doc ~sid =
  let open Format in
  let stt = ref (doc, sid) in
  let in_strm = Stream.of_channel in_chan in
  let source = Loc.InFile in_file in
  let in_pa = Pcoq.Parsable.make ~loc:(Loc.initial source) in_strm in
  try
    while true do
      let doc, sid = !stt in
      let ast =
        match Stm.parse_sentence ~doc ~entry:Pvernac.main_entry sid in_pa with
        | Some ast -> ast
        | None -> raise End_of_input
      in
      (* let ast_pp = Ppvernac.pr_vernac_expr ast.v.expr in *)
      let ast_pp = Ppvernac.pr_vernac ast in
      printf "%s\n" (Pp.string_of_ppcmds ast_pp);
      try
        let doc, n_st, tip = Stm.add ~doc ~ontop:sid false ast in
        if tip <> `NewTip then CErrors.user_err ?loc:ast.loc Pp.(str "fatal, got no `NewTip`");
        stt := (doc, n_st)
      with exn ->
        raise exn
    done;
    !stt
  with End_of_input -> !stt
