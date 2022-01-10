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

class virtual node el_init =
  object
    val el : element = el_init

    method get_el : element = el

    method load_style ~style ~ctx =
      let _ : Css.Types.Stylesheet.t = style in
      let _ : node list = ctx in
      ()

    method virtual styled_pp : ppf:formatter -> ctx:node list -> unit
  end;;

class virtual grouping_node el_init =
  object
    inherit node el_init as super

    method virtual add_child : node -> unit

    method! load_style ~style ~ctx = super#load_style ~style ~ctx

    method virtual styled_pp : ppf:formatter -> ctx:node list -> unit
  end;;

let basic =
{|
  doc {
    margin: 120;
    max-indent: 20;
  }

  body {
    betweenlines: 1;
  }

  body#definition {
    betweenlines: 0;
  }

  body#proof {
    betweenlines: 0;
  }

  body#proof-bullet {
    betweenlines: 0;
  }

  component {
    body-indent-hf: 2;
    body-indent-h: 0;
    body-indent-f: 0;
    body-indent: 0;
  }
|}
