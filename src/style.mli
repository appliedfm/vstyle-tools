type node_ty =
  | NodeTy_Doc
  | NodeTy_Body
  | NodeTy_Vernac

val pp_node_ty : Format.formatter -> node_ty -> unit

type element = {
  ty: node_ty;
  cls: string list;
  id: string option;
}

type context = element list


class virtual node :
  element ->
  object
    val el : element

    val css_tab_spaces : int

    method get_style : style:Css.Types.Stylesheet.t -> ctx:context -> unit

    method virtual fmt : ppf:Format.formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end

val basic : string
