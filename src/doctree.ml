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

      Format.pp_set_margin ppf css_margin;
      Format.pp_set_max_indent ppf css_max_indent;
      Format.pp_open_vbox ppf 0;
      body#fmt ~ppf ~style ~ctx:(el::ctx);
      Format.pp_close_box ppf ();
  end;;

class doctree =
  let doc_body_init = new Style_group.body_node ["root"] in
  let doc_init = new doc_node doc_body_init in
  let stack_init = Stack.create () in
  object
    val doc : doc_node = doc_init
    val stack : Style_group.body_node Stack.t = stack_init
    initializer Stack.push doc_body_init stack_init

    method fmt ~ppf ~style = doc#fmt ~ppf ~style ~ctx:[]

    method add_vernac ({v = {control = _; attrs = _; expr}; loc = _} as v) =
      match expr with
      | VernacDefineModule _
      | VernacDeclareModule _ 
      | VernacDeclareModuleType _ ->
          let b = new Style_group.body_node ["component"] in
          (Stack.top stack)#add_child (b :> Style.node);
          Stack.push b stack;
          b#set_header (new Style_vernac.vernac_node v)
      | VernacEndSegment _ ->
          (Stack.top stack)#set_footer (new Style_vernac.vernac_node v);
          let _ = Stack.pop stack in ()
      | _ ->
          (Stack.top stack)#add_child (new Style_vernac.vernac_node v)
  end;;
