type node_ty =
  | NodeTy_Doc
  | NodeTy_Body
  | NodeTy_Component
  | NodeTy_Vernac

val pp_node_ty : Format.formatter -> node_ty -> unit

type element = {
  ty: node_ty;
  cls: string list;
  id: string option;
}

class virtual node :
  element ->
  object
    val el : element

    method get_el : element

    method load_style : style:Css.Types.Stylesheet.t -> ctx:node list -> unit

    method virtual styled_pp : ppf:Format.formatter -> ctx:node list -> unit
  end

class virtual grouping_node :
  element ->
  object
    inherit node

    method virtual add_child : node -> unit

    method load_style : style:Css.Types.Stylesheet.t -> ctx:node list -> unit

    method virtual styled_pp : ppf:Format.formatter -> ctx:node list -> unit
  end

val basic : string
