open Format


type node_ty =
  | NodeTy_Doc
  | NodeTy_Body
  | NodeTy_Component
  | NodeTy_Vernac

let pp_node_ty ppf =
  function
  | NodeTy_Doc -> pp_print_string ppf "doc"
  | NodeTy_Body -> pp_print_string ppf "body"
  | NodeTy_Component -> pp_print_string ppf "component"
  | NodeTy_Vernac -> pp_print_string ppf "vernac"

type element = {
  ty: node_ty;
  cls: string list;
  id: string option;
}

type context = element list


class virtual node el_init =
  object
    val el : element = el_init

    val mutable css_tab_spaces : int = 2

    method get_style ~style ~ctx =
      let _ : Css.Types.Stylesheet.t = style in
      let _ : context = ctx in
      ()

    method virtual fmt : ppf:formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end;;

let basic =
{|
  doc {
    margin: 120;
    tab-spaces: 2;
  }

  body {
    indent: 0
  }

  body#component {
    indent: 1;
  }

  vernac {
    dot: sameline;
  }
|}
