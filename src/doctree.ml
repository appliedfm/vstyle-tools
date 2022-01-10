open CAst
open Vernacexpr

class doc_node body_init =
  object
    inherit Style.node
      { ty = NodeTy_Doc; cls = []; id = None }
      as super

    val body : Style_group.body_node = body_init

    val css_margin : int = 120
    val css_max_indent : int = 20

    method! load_style ~style ~ctx =
      super#load_style ~style ~ctx;
      body#load_style ~style ~ctx:(el::ctx)

    method styled_pp ~ppf ~ctx =
      Format.pp_set_max_boxes ppf 0;
      Format.pp_set_geometry
        ppf
        ~max_indent:css_max_indent
        ~margin:css_margin;

      Format.pp_open_vbox ppf 0;
      body#styled_pp ~ppf ~ctx:(el::ctx);
      Format.pp_close_box ppf ();
  end;;

type grouping =
  | GBody of Style_group.body_node
  | GComponent of Style_group.component_node

exception WrongGrouping
  
let as_grouping g =
  match g with
  | GBody n -> (n :> Style.grouping_node)
  | GComponent n -> (n :> Style.grouping_node)

let as_body g =
  match g with
  | GBody n -> n
  | GComponent _ -> raise WrongGrouping
  
let as_component g =
  match g with
  | GBody _ -> raise WrongGrouping
  | GComponent n -> n

exception ExpectedBullet

class doctree =
  let doc_body_init = new Style_group.body_node ["root"] in
  let doc_init = new doc_node doc_body_init in
  let stack_init = Stack.create () in
  object(self)
    val doc : doc_node = doc_init
    val stack : grouping Stack.t = stack_init
    val bullet_stack : Proof_bullet.t list ref Stack.t = Stack.create ()
    val mutable suppress_proof = false
    initializer Stack.push (GBody doc_body_init) stack_init

    method get_stack_length : int = Stack.length stack

    method load_style ~style = doc#load_style ~style ~ctx:[]

    method styled_pp ~ppf = doc#styled_pp ~ppf ~ctx:[]

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

    method private is_bullet proof_state expr =
      match proof_state, expr with
      | _, VernacBullet _ -> true
      | _ -> false

    method private is_proof proof_state expr =
      if suppress_proof then false else begin
        match proof_state, expr with
        | Some _, _
        | _, VernacExtend (("Obligations", 5), _)
        | _, VernacSubproof _ -> true
        | _ -> false
      end

    method private is_end proof_state expr =
      match proof_state, expr with
      | _, VernacEndSegment _
      | _, VernacEndProof _ -> true
      | _, VernacEndSubproof -> true
      | _ -> false

    method add_vernac (proof_state : Proof.t option) ({v = {control = _; attrs = _; expr}; loc = _} as v) =
      if List.mem "definition" (as_grouping (Stack.top stack))#get_el.cls then begin
        let is_sticky = self#is_proof proof_state expr in
        if not is_sticky then ignore (Stack.pop stack)
      end;
      if self#is_definition proof_state expr then begin
        let top_g = as_grouping (Stack.top stack) in
        let def_b = new Style_group.body_node ["definition"] in
        def_b#add_child (new Style_vernac.vernac_node v);
        top_g#add_child ((def_b :> Style.node));
        Stack.push (GBody def_b) stack;
      end else if self#is_module proof_state expr then begin
        let top_g = as_grouping (Stack.top stack) in
        let new_g = new Style_group.component_node ["module"] in
        top_g#add_child (new_g :> Style.node);
        Stack.push (GComponent new_g) stack;
        new_g#set_header (new Style_vernac.vernac_node v)
      end else if self#is_proof proof_state expr then begin
        let top_g = as_grouping (Stack.top stack) in
        let new_g = new Style_group.component_node ["proof"] in
        top_g#add_child (new_g :> Style.node);
        Stack.push (GComponent new_g) stack;
        let _ =
          match expr with
          | VernacExtend (("Obligations", 5), _)
          | VernacProof _
          | VernacSubproof _ -> new_g#set_header (new Style_vernac.vernac_node v)
          | _ -> new_g#add_child (new Style_vernac.vernac_node v)
        in
        Stack.push (ref []) bullet_stack;
      end else if self#is_bullet proof_state expr then begin
        let bullets = Stack.pop bullet_stack in
        let bullet = match expr with | VernacBullet b -> b | _ -> raise ExpectedBullet in
        while List.mem bullet !bullets do begin
          bullets := List.tl !bullets;
          ignore (Stack.pop stack)
        end done;
        let top_g = as_grouping (Stack.top stack) in
        let new_g = new Style_group.component_node ["proof-bullet"] in
        top_g#add_child (new_g :> Style.node);
        Stack.push (GComponent new_g) stack;
        new_g#set_header (new Style_vernac.vernac_node v);
        bullets := bullet :: !bullets;
        Stack.push bullets bullet_stack
      end else if self#is_end proof_state expr then begin
        while List.mem "proof-bullet" (as_grouping (Stack.top stack))#get_el.cls do begin
          ignore (Stack.pop stack)
        end done;
        let top_g = as_component (Stack.pop stack) in
        top_g#set_footer (new Style_vernac.vernac_node v);
        if List.mem "proof" (top_g#get_el).cls then ignore (Stack.pop bullet_stack)
      end else begin
          let top_g = as_grouping (Stack.top stack) in
          top_g#add_child (new Style_vernac.vernac_node v)
      end;
      suppress_proof <-
        match expr with
        | VernacExtend (("Obligations", 5), _) -> true
        | _ -> false
  end;;
