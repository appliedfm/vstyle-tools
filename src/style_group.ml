open Format
open Style

class body_node cls =
  object(self)
    inherit grouping_node
      { ty = NodeTy_Body; cls = cls; id = None }
      as super

    val children : node Queue.t = Queue.create ()

    method add_child n = Queue.push n children
    method has_children = not (Queue.is_empty children)

    val mutable css_betweenlines : int = 1

    method! load_style ~style ~ctx =
      super#load_style ~style ~ctx;
      let _ = if List.mem "definition" el.cls then css_betweenlines <- 0 in
      let _ = if List.mem "proof" el.cls then css_betweenlines <- 0 in
      let _ = if List.mem "proof-bullet" el.cls then css_betweenlines <- 0 in
      Queue.iter (fun n -> n#load_style ~style ~ctx:((self :> node)::ctx)) children

    method styled_pp ~ppf ~ctx =
      pp_open_vbox ppf 0;
      let sep = fun ppf u -> for _ = 0 to css_betweenlines do pp_print_cut ppf u done in
      let nodes = List.rev (Queue.fold (Fun.flip List.cons) [] children) in
      pp_print_list ?pp_sep:(Some sep) (fun ppf n -> n#styled_pp ~ppf ~ctx:((self :> node)::ctx)) ppf nodes;
      pp_close_box ppf ()
    end;;

class component_node cls =
  object(self)
    inherit grouping_node
      { ty = NodeTy_Component; cls = cls; id = None }
      as super

    val mutable css_body_indent_hf : int = 2
    val mutable css_body_indent_h : int = 0
    val mutable css_body_indent_f : int = 0
    val mutable css_body_indent : int = 0

    val mutable header : node option = None
    val body : body_node = new body_node (["component"] @ cls)
    val mutable footer : node option = None

    method set_header n = header <- Some n
    method add_child n = body#add_child n
    method set_footer n = footer <- Some n

    method! load_style ~style ~ctx =
      super#load_style ~style ~ctx;
      Option.iter (fun n -> n#load_style ~style ~ctx:((self :> node)::ctx)) header;
      body#load_style ~style ~ctx:((self :> node)::ctx);
      Option.iter (fun n -> n#load_style ~style ~ctx:((self :> node)::ctx)) footer;

    method styled_pp ~ppf ~ctx =
      let pp_gen n ppf' = n#styled_pp ~ppf:ppf' ~ctx:((self :> node)::ctx) in
      let pp_b indent =
        if body#has_children then
          [
          fun ppf' ->
            begin
              pp_open_hbox ppf' ();
              pp_print_string ppf' (String.make indent ' ');
              pp_gen body ppf';
              pp_close_box ppf' ();
            end
          ]
        else []
      in
      match header, footer with
      | Some h, Some f ->
        let pp_h = pp_gen h in
        let pp_f = pp_gen f in
        pp_open_vbox ppf 0;
        pp_print_list (fun x f -> f x) ppf ([pp_h] @ pp_b css_body_indent_hf @ [pp_f]);
        pp_close_box ppf ();
      | Some h, None ->
        let pp_h = pp_gen h in
        pp_open_hbox ppf ();
        pp_print_list ?pp_sep:(Some pp_print_space) (fun x f -> f x) ppf ([pp_h] @ pp_b css_body_indent_h);
        pp_close_box ppf ();
      | None, Some f ->
        let pp_f = pp_gen f in
        pp_open_vbox ppf 0;
        pp_print_list (fun ppf f -> f ppf) ppf (pp_b css_body_indent_f @ [pp_f]);
        pp_close_box ppf ();
      | None, None ->
        pp_print_list (fun x f -> f x) ppf (pp_b css_body_indent);
    end;;
