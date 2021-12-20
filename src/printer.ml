open Sexplib

exception Unrecognized

let pp_v _fmt v_kind v _loc =
  match (v_kind, v) with
  | ( "NUMBER",
      Sexp.List
        [
          Sexp.List [ Sexp.Atom "int"; Sexp.Atom i ];
          Sexp.List [ Sexp.Atom "frac"; Sexp.Atom f ];
          Sexp.List [ Sexp.Atom "exp"; Sexp.Atom e ];
        ] ) ->
      print_string i;
      if f <> "" then print_string ("." ^ f);
      if e <> "" then print_string e
  | "IDENT", Sexp.Atom x -> print_string x
  | "KEYWORD", Sexp.Atom x -> print_string x
  | "FIELD", Sexp.Atom x -> print_string x
  | _ -> raise Unrecognized

let rec pp_sentence fmt sen =
  match sen with
  | Sexp.List [ Sexp.List [ Sexp.Atom "v"; Sexp.List [ Sexp.Atom v_kind; v ] ]; Sexp.List (Sexp.Atom "loc" :: loc) ]
    :: tail ->
      pp_v fmt v_kind v loc;
      print_string " ";
      pp_sentence fmt tail
  | [] -> ()
  | _ -> raise Unrecognized

let pp fmt s =
  let _ =
    try
      match s with
      | Sexp.List [ Sexp.Atom "Sentence"; Sexp.List sen ] ->
          print_string "(* sentence *) ";
          pp_sentence fmt sen;
          print_string "(* end sentence *)"
      | _ -> raise Unrecognized
    with Unrecognized -> Sexp.pp_hum fmt s
  in
  ()
