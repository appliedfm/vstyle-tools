open Style

class vernac_node :
  Vernacexpr.vernac_control_r CAst.t ->
  object
    inherit node

    val v : Vernacexpr.vernac_control_r CAst.t

    method load_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method styled_pp : ppf:Format.formatter -> ctx:context -> unit
  end