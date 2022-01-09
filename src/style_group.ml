open Format
open Style

class virtual grouping_node el_init =
  object
    inherit node el_init as super

    val children : node Queue.t = Queue.create ()

    method add_child n = Queue.push n children

    method! get_style ~style ~ctx = super#get_style ~style ~ctx

    method virtual fmt : ppf:formatter -> style:Css.Types.Stylesheet.t -> ctx:context -> unit
  end;;

class body_node cls =
  object(self)
    inherit grouping_node
      { ty = NodeTy_Body; cls = cls; id = None }
      as super

    val mutable css_indent : int = 2

    val mutable header : node option = None
    val mutable footer : node option = None

    method set_header n = header <- Some n
    method set_footer n = footer <- Some n

    method! get_style ~style ~ctx =
      super#get_style ~style ~ctx;
      (* TODO: actually read from the CSS ... *)
      if List.mem "root" el.cls
        then css_indent <- 0
        else css_indent <- 2

    method fmt ~ppf ~style ~ctx =
      self#get_style ~style ~ctx;

      pp_open_vbox ppf 0;

      pp_open_vbox ppf css_indent;
      let header_list =
        match header with
        | None -> []
        | Some n -> [n]
      in

      let nodes = header_list @ List.rev (Queue.fold (Fun.flip List.cons) [] children) in
      pp_print_list (fun ppf n -> n#fmt ~ppf ~style ~ctx:(el::ctx)) ppf nodes;
      pp_close_box ppf ();

      pp_print_cut ppf ();

      pp_open_vbox ppf 0;
      let _ =
        match footer with
        | None -> ()
        | Some n ->
            n#fmt ~ppf ~style ~ctx:(el::ctx)
      in
      pp_close_box ppf ();

      pp_close_box ppf ()
    end;;
