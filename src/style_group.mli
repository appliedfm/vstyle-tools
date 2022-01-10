open Style

class body_node :
  string list ->
  object
    inherit grouping_node

    method add_child : node -> unit
    method has_children : bool

    method load_style : style:Css.Types.Stylesheet.t -> ctx:node list -> unit

    method styled_pp : ppf:Format.formatter -> ctx:node list -> unit
  end

class component_node :
  string list ->
  object
    inherit grouping_node

    method set_header : node -> unit
    method add_child : node -> unit
    method set_footer : node -> unit

    method load_style : style:Css.Types.Stylesheet.t -> ctx:node list -> unit

    method styled_pp : ppf:Format.formatter -> ctx:node list -> unit
  end
