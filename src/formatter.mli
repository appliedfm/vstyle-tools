val formatter_pp_sentence : Vernacexpr.vernac_control_r CAst.t -> Pp.t

val formatter_pp_to_string : Pp.t -> string

val formatter_pp_to_debug_string : Pp.t -> string

val format_doc : style:Css.Types.Stylesheet.t -> in_file:string -> in_chan:in_channel -> doc:Stm.doc -> sid:Stateid.t -> Stm.doc * Stateid.t
