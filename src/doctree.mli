class doc_node :
  Style_group.body_node ->
  object
    inherit Style.node

    val body : Style_group.body_node

    val css_margin : int
    val css_max_indent : int

    method get_style : style:Css.Types.Stylesheet.t -> ctx:Style.context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:Style.context -> unit
  end;;

class doctree :
  object
    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> unit
    method add_vernac : Vernacexpr.vernac_control_r CAst.t -> unit
  end;;
