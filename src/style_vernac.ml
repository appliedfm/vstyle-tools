open Format
open Style

(* open CAst *)
(* open Vernacexpr *)

class vernac_node v_init =
  object
    inherit node
      { ty = NodeTy_Vernac; cls = []; id = None }
      as super

    val v : Vernacexpr.vernac_control_r CAst.t = v_init

    method! get_style ~style ~ctx = super#get_style ~style ~ctx

    method fmt ~ppf ~style:_ ~ctx:_ =
      pp_open_hvbox ppf 1;
      Pp.pp_with ppf (Ppvernac.pr_vernac v);
      pp_close_box ppf ()
  end;;