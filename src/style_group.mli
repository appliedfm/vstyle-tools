open Style

class virtual grouping_node :
  element ->
  object
    inherit node

    method virtual add_child : node -> unit

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method virtual fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end

class body_node :
  string list ->
  object
    inherit grouping_node

    method add_child : node -> unit
    method has_children : bool

    method set_css_indent : int -> unit

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end

class component_node :
  string list ->
  object
    inherit grouping_node

    method set_header : node -> unit
    method add_child : node -> unit
    method set_footer : node -> unit

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end
