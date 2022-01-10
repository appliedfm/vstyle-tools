open Style

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
