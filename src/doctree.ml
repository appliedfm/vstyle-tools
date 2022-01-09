open CAst
open Vernacexpr

class doc_node body_init =
  object(self)
    inherit Style.node
      { ty = NodeTy_Doc; cls = []; id = None }
      as super

    val body : Style_group.body_node = body_init

    val css_margin : int = 120
    val css_max_indent : int = 20

    method! get_style ~style ~ctx = super#get_style ~style ~ctx

    method fmt ~ppf ~style ~ctx =
      self#get_style ~style ~ctx;

      Format.pp_set_max_boxes ppf 0;
      Format.pp_set_geometry
        ppf
        ~max_indent:css_max_indent
        ~margin:css_margin;

      Format.pp_open_vbox ppf 0;
      body#fmt ~ppf ~style ~ctx:(el::ctx);
      Format.pp_close_box ppf ();
  end;;

type grouping =
  | GBody of Style_group.body_node
  | GComponent of Style_group.component_node

exception WrongGrouping
  
let as_grouping g =
  match g with
  | GBody n -> (n :> Style_group.grouping_node)
  | GComponent n -> (n :> Style_group.grouping_node)

let as_body g =
  match g with
  | GBody n -> n
  | GComponent _ -> raise WrongGrouping
  
let as_component g =
  match g with
  | GBody _ -> raise WrongGrouping
  | GComponent n -> n
  
class doctree =
  let doc_body_init = new Style_group.body_node ["root"] in
  let doc_init = new doc_node doc_body_init in
  let stack_init = Stack.create () in
  object
    val doc : doc_node = doc_init
    val stack : grouping Stack.t = stack_init
    initializer Stack.push (GBody doc_body_init) stack_init

    method fmt ~ppf ~style = doc#fmt ~ppf ~style ~ctx:[]

    method add_vernac ({v = {control = _; attrs = _; expr}; loc = _} as v) =
      match expr with
      | VernacDefineModule _
      | VernacDeclareModule _ 
      | VernacDeclareModuleType _ ->
          let top_g = as_grouping (Stack.top stack) in
          let new_g = new Style_group.component_node [] in
          top_g#add_child (new_g :> Style.node);
          Stack.push (GComponent new_g) stack;
          new_g#set_header (new Style_vernac.vernac_node v)
      | VernacEndSegment _ ->
          let top_g = as_component (Stack.pop stack) in
          top_g#set_footer (new Style_vernac.vernac_node v);
      | _ ->
          let top_g = as_grouping (Stack.top stack) in
          top_g#add_child (new Style_vernac.vernac_node v)
  end;;
