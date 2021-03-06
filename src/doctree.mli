class doc_node :
  Style_group.body_node ->
  object
    inherit Style.node

    val body : Style_group.body_node

    val css_margin : int
    val css_max_indent : int

    method load_style : style:Css.Types.Stylesheet.t -> ctx:Style.node list -> unit

    method styled_pp : ppf:Format.formatter -> ctx:Style.node list -> unit
  end;;

type grouping =
  | GBody of Style_group.body_node
  | GComponent of Style_group.component_node

exception WrongGrouping
val as_grouping : grouping -> Style.grouping_node
val as_body : grouping -> Style_group.body_node
val as_component : grouping -> Style_group.component_node

class doctree :
  object
    method get_stack_length : int
    method load_style : style:Css.Types.Stylesheet.t -> unit
    method styled_pp : ppf:Format.formatter -> unit
    method add_vernac : Proof.t option -> Vernacexpr.vernac_control_r CAst.t -> unit
  end;;
