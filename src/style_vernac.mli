open Style

class vernac_node :
  Vernacexpr.vernac_control_r CAst.t ->
  object
    inherit node

    val v : Vernacexpr.vernac_control_r CAst.t

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end