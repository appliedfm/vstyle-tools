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
  object(self)
    inherit grouping_node
      { ty = NodeTy_Body; cls = cls; id = None }
      as super

    val children : node Queue.t = Queue.create ()

    method add_child n = Queue.push n children
    method has_children = not (Queue.is_empty children)

    val mutable css_indent : int = 2

    method! get_style ~style ~ctx =
      super#get_style ~style ~ctx;
      if List.mem "component" el.cls
        then css_indent <- 2
        else css_indent <- 0

    method fmt ~ppf ~style ~ctx =
      self#get_style ~style ~ctx;

      pp_open_hbox ppf ();
      pp_print_string ppf (String.make css_indent ' ');
      pp_open_vbox ppf 0;
      let nodes = List.rev (Queue.fold (Fun.flip List.cons) [] children) in
      pp_print_list (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf nodes;
      pp_close_box ppf ();
      pp_close_box ppf ()
    end;;

class component_node cls =
  object(self)
    inherit grouping_node
      { ty = NodeTy_Component; cls = cls; id = None }
      as super

    val mutable header : node option = None
    val body : body_node = new body_node ["component"]
    val mutable footer : node option = None

    method set_header n = header <- Some n
    method add_child n = body#add_child n
    method set_footer n = footer <- Some n

    method! get_style ~style ~ctx =
      super#get_style ~style ~ctx;

    method fmt ~ppf ~style ~ctx =
      self#get_style ~style ~ctx;

      pp_open_vbox ppf 0;

      let to_list =
        function
        | None -> []
        | Some x -> [(x :> Style.node)]
      in
      let h : Style.node list = to_list header in
      let b : Style.node list = if body#has_children then [(body :> Style.node)] else [] in
      let f : Style.node list = to_list footer in

      pp_print_list (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf (h @ b @ f);

      pp_close_box ppf ()
    end;;
