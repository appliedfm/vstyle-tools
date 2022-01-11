open Format


type node_ty =
  | NodeTy_Doc
  | NodeTy_Body
  | NodeTy_Component
  | NodeTy_Vernac

let node_ty_to_string =
  function
  | NodeTy_Doc -> "doc"
  | NodeTy_Body -> "body"
  | NodeTy_Component -> "component"
  | NodeTy_Vernac -> "vernac"

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

let rec css_components_match (ctx:node list) (n:node) (cc:Css.Types.Component_value.t list) =
  match cc, ctx with
  | [], _ ->
    (* Printf.printf "match\n"; *)
    true
  | (Css.Types.Component_value.Ident i::cc'), _ ->
    let j = node_ty_to_string n#get_el.ty in
    (* Printf.printf "ident '%s' vs '%s'\n" i j; *)
    String.equal i j && css_components_match ctx n cc'
  | (Css.Types.Component_value.Hash i::cc'), _ ->
    let jj = n#get_el.cls in
    (* Printf.printf "searching for class '%s' among " i; List.iter (Printf.printf "'%s' ") jj; Printf.printf "\n"; *)
    List.exists (String.equal i) jj && css_components_match ctx n cc'
  | _ ->
    (* Printf.printf "no match\n"; *)
    false

let css_rule_matches (ctx:node list) (n:node) rule =
  match rule with
  | Css.Types.Rule.At_rule _ -> false
  | Css.Types.Rule.Style_rule {prelude=(prelude, _);_} ->
    css_components_match ctx n (List.map (function | (c, _) -> c) prelude)

let css_rule_get_property prop rule =
  match rule with
  | Css.Types.Rule.At_rule _ -> None
  | Css.Types.Rule.Style_rule {block=(decls,_);_} ->
    let f =
      function
      | Css.Types.Declaration_list.At_rule _ -> None
      | Css.Types.Declaration_list.Declaration d ->
        let i, _ = d.name in
        if String.equal prop i
          then Some d.value
          else None
    in List.find_map f decls

let css_get_property ~style ~ctx n prop =
  let rules = List.filter (css_rule_matches ctx n) (let css, _ = style in css) in
  List.filter_map (css_rule_get_property prop) rules

let css_get_last (props:Css.Types.Component_value.t Css.Types.with_loc list Css.Types.with_loc list) =
  match List.rev props with
  | [] -> None
  | (xx::_) ->
    match xx with
    | [], _ -> None
    | ((x, _)::_), _ -> Some x

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
