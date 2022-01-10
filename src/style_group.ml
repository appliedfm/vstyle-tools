open Format
open Style

class virtual grouping_node el_init =
  object
    inherit node el_init as super

    method virtual add_child : node -> unit

    method! get_style ~style ~ctx = super#get_style ~style ~ctx

    method virtual fmt : ppf:formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end;;

class body_node cls =
  object
    inherit grouping_node
      { ty = NodeTy_Body; cls = cls; id = None }
      as super

    val children : node Queue.t = Queue.create ()

    method add_child n = Queue.push n children
    method has_children = not (Queue.is_empty children)

    val mutable css_indent : int = 0
    val mutable css_betweenlines : int = 1

    method! get_style ~style ~ctx =
      super#get_style ~style ~ctx;
      let _ = if List.mem "component" el.cls then css_indent <- 2 in
      let _ = if List.mem "definition" el.cls then css_betweenlines <- 0 in
      let _ = if List.mem "proof" el.cls then css_betweenlines <- 0 in
      let _ = if List.mem "proof-bullet" el.cls then css_betweenlines <- 0 in
      let _ = if List.mem "proof-bullet" el.cls then css_indent <- 0 in
      Queue.iter (fun n -> n#get_style ~style ~ctx:(el::ctx)) children

    method fmt ~ppf ~style ~ctx =
      pp_open_hbox ppf ();
      pp_print_string ppf (String.make css_indent ' ');
      pp_open_vbox ppf 0;
      let sep = fun ppf u -> for _ = 0 to css_betweenlines do pp_print_cut ppf u done in
      let nodes = List.rev (Queue.fold (Fun.flip List.cons) [] children) in
      pp_print_list ?pp_sep:(Some sep) (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf nodes;
      pp_close_box ppf ();
      pp_close_box ppf ()
    end;;

class component_node cls =
  object
    inherit grouping_node
      { ty = NodeTy_Component; cls = cls; id = None }
      as super

    val mutable header : node option = None
    val body : body_node = new body_node (["component"] @ cls)
    val mutable footer : node option = None

    method set_header n = header <- Some n
    method add_child n = body#add_child n
    method set_footer n = footer <- Some n

    method! get_style ~style ~ctx =
      super#get_style ~style ~ctx;
      Option.iter (fun n -> n#get_style ~style ~ctx:(el::ctx)) header;
      body#get_style ~style ~ctx:(el::ctx);
      Option.iter (fun n -> n#get_style ~style ~ctx:(el::ctx)) footer;

    method fmt ~ppf ~style ~ctx =
      match header, footer with
      | Some h, Some f ->
        let b : Style.node list = if body#has_children then [(body :> Style.node)] else [] in
        pp_open_vbox ppf 0;
        pp_print_list (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf ([h] @ b @ [f]);
        pp_close_box ppf ();
      | Some h, None ->
        pp_open_hbox ppf ();
        h#fmt ~ppf ~style ~ctx:(el::ctx);
        pp_print_space ppf ();
        body#fmt ~ppf ~style ~ctx:(el::ctx);
        pp_close_box ppf ();
      | None, Some f ->
        let b : Style.node list = if body#has_children then [(body :> Style.node)] else [] in
        pp_open_vbox ppf 0;
        pp_print_list (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf (b @ [f]);
        pp_close_box ppf ();
      | None, None -> body#fmt ~ppf ~style ~ctx:(el::ctx)
    end;;
