val load_file : string -> bytes

val stream_tok : int -> Tok.t CAst.t list -> Tok.t LStream.t -> Loc.source -> int -> int -> Tok.t CAst.t list

val format_doc : in_file:string -> in_chan:in_channel -> doc:Stm.doc -> sid:Stateid.t -> Stm.doc * Stateid.t
