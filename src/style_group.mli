open Style

class virtual grouping_node :
  element ->
  object
    inherit node

    val children : node Queue.t

    method add_child : node -> unit

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method virtual fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end

class body_node :
  string list ->
  object
    inherit grouping_node

    val css_indent : int

    val mutable header : node option
    val mutable footer : node option

    method set_header : Style.node -> unit
    method set_footer : Style.node -> unit

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end
