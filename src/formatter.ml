let formatter_pp_sentence ast = Ppvernac.pr_vernac ast
let formatter_pp_to_string pp = Pp.string_of_ppcmds pp
let formatter_pp_to_debug_string pp = formatter_pp_to_string pp ^ "\n" ^ Pp.db_string_of_pp pp

exception End_of_input

let format_doc ~style ~in_file ~in_chan ~doc ~sid =
  let stt = ref (doc, sid) in
  let in_pa =
    let in_strm = Stream.of_channel in_chan in
    let source = Loc.InFile in_file in
    Pcoq.Parsable.make ~loc:(Loc.initial source) in_strm
  in
  let out_doc = new Doctree.doctree in
  try
    while true do
      let doc, sid = !stt in
      let ast =
        match Stm.parse_sentence ~doc ~entry:Pvernac.main_entry sid in_pa with
        | Some ast -> ast
        | None -> raise End_of_input
      in
      (* Format.printf "%s\n" (formatter_pp_to_debug_string (formatter_pp_sentence ast)); *)
      out_doc#add_vernac ast;
      try
        let doc, n_st, tip = Stm.add ~doc ~ontop:sid false ast in
        if tip <> `NewTip then CErrors.user_err ?loc:ast.loc Pp.(str "fatal, got no `NewTip`");
        stt := (doc, n_st)
      with exn -> raise exn
    done;
    !stt;
  with
  (* | Stack.Empty -> *)
  | End_of_input ->
      let ppf = Format.std_formatter in
      out_doc#fmt ~ppf ~style;
      Format.pp_print_newline ppf ();
      !stt
