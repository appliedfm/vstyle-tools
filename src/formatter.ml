let load_file f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = Bytes.create n in
  really_input ic s 0 n;
  close_in ic;
  s

let rec stream_tok n_tok acc str source begin_line begin_char =
  let e = LStream.next str in
  let pre_loc : Loc.t = LStream.get_loc n_tok str in
  let loc =
    {
      pre_loc with
      fname = source;
      line_nb = begin_line;
      line_nb_last = begin_line + pre_loc.line_nb_last - 1;
      bp = begin_char + pre_loc.bp;
      ep = begin_char + pre_loc.ep;
    }
  in
  let l_tok = CAst.make ~loc e in
  if Tok.(equal e EOI) then List.rev acc else stream_tok (n_tok + 1) (l_tok :: acc) str source begin_line begin_char

exception End_of_input

let format_doc ~in_file ~in_chan ~doc ~sid =
  let open Format in
  let stt = ref (doc, sid) in
  let in_strm = Stream.of_channel in_chan in
  let source = Loc.InFile in_file in
  let in_pa = Pcoq.Parsable.make ~loc:(Loc.initial source) in_strm in
  let in_bytes = load_file in_file in
  try
    while true do
      let l_pre_st = CLexer.Lexer.State.get () in
      let doc, sid = !stt in
      let ast =
        match Stm.parse_sentence ~doc ~entry:Pvernac.main_entry sid in_pa with
        | Some ast -> ast
        | None -> raise End_of_input
      in
      let begin_line, begin_char, end_char =
        match ast.loc with Some lc -> (lc.line_nb, lc.bp, lc.ep) | None -> raise End_of_input
      in
      let istr = Bytes.sub_string in_bytes begin_char (end_char - begin_char) in
      let l_post_st = CLexer.Lexer.State.get () in
      let sstr = Stream.of_string istr in
      try
        CLexer.Lexer.State.set l_pre_st;
        let lex = CLexer.Lexer.tok_func sstr in
        let sen = Sertop.Sertop_ser.Sentence (stream_tok 0 [] lex source begin_line begin_char) in
        CLexer.Lexer.State.set l_post_st;
        printf "@[%a@]@\n%!" Printer.pp (Sertop.Sertop_ser.sexp_of_sentence sen);
        let doc, n_st, tip = Stm.add ~doc ~ontop:sid false ast in
        if tip <> `NewTip then CErrors.user_err ?loc:ast.loc Pp.(str "fatal, got no `NewTip`");
        stt := (doc, n_st)
      with exn ->
        CLexer.Lexer.State.set l_post_st;
        raise exn
    done;
    !stt
  with End_of_input -> !stt
