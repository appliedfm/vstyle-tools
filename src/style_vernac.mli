open Style

type vernac_dot =
  | VernacDot_Sameline
  | VernacDot_Newline

class vernac_node :
  Vernacexpr.vernac_control_r CAst.t ->
  object
    inherit node

    val v : Vernacexpr.vernac_control_r CAst.t

    val css_dot_placement : vernac_dot

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end