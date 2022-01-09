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
  object(self)
    val doc : doc_node = doc_init
    val stack : grouping Stack.t = stack_init
    val mutable last_definition : Style_group.body_node option = None
    initializer Stack.push (GBody doc_body_init) stack_init

    method fmt ~ppf ~style = doc#fmt ~ppf ~style ~ctx:[]

    method private is_definition proof_state expr =
      match proof_state, expr with
      | _, VernacDefinition _
      | _, VernacStartTheoremProof _ -> true
      | _ -> false

    method private is_module proof_state expr =
      match proof_state, expr with
      | _, VernacDefineModule _
      | _, VernacDeclareModule _ 
      | _, VernacDeclareModuleType _ -> true
      | _ -> false
  
    method private is_proof proof_state expr =
      match proof_state, expr with
      | Some _, _ -> true
      | _ -> false

    method private is_end proof_state expr =
      match proof_state, expr with
      | _, VernacEndSegment _
      | _, VernacEndProof _ -> true
      | _ -> false


    method add_vernac proof_state ({v = {control = _; attrs = _; expr}; loc = _} as v) =
      let _ : Proof.t option = proof_state in
      if self#is_definition proof_state expr then begin
        let top_g = as_grouping (Stack.top stack) in
        let def_b = new Style_group.body_node ["definition"] in
        last_definition <- Some def_b;
        def_b#add_child (new Style_vernac.vernac_node v);
        top_g#add_child ((def_b :> Style.node))
      end else if self#is_module proof_state expr then begin
        let top_g = as_grouping (Stack.top stack) in
        let new_g = new Style_group.component_node [] in
        top_g#add_child (new_g :> Style.node);
        Stack.push (GComponent new_g) stack;
        new_g#set_header (new Style_vernac.vernac_node v)
      end else if self#is_proof proof_state expr then begin
        let last_g =
          match last_definition with
          | None -> as_grouping (Stack.top stack)
          | Some g -> (g :> Style_group.grouping_node)
        in
        let new_g = new Style_group.component_node [] in
        last_g#add_child (new_g :> Style.node);
        Stack.push (GComponent new_g) stack;
        let _ =
          match expr with
          | VernacProof _ -> new_g#set_header (new Style_vernac.vernac_node v)
          | _ -> new_g#add_child (new Style_vernac.vernac_node v)
        in ()
      end else if self#is_end proof_state expr then begin
        let top_g = as_component (Stack.pop stack) in
        top_g#set_footer (new Style_vernac.vernac_node v);
      end else begin
          let top_g = as_grouping (Stack.top stack) in
          top_g#add_child (new Style_vernac.vernac_node v)
      end;
      if not (self#is_definition proof_state expr) then last_definition <- None
  end;;
