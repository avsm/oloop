open Core.Std
open Async.Std
open Format

let f (x:int) : unit Or_error.t Deferred.t =
  printf "run %d\n%!" (x+1);
  let f t =
    Oloop.eval t "2+3" >>| fun _ ->
    Ok () in
  Oloop.(with_toploop Outcome.merged ~f)

let main () =
  Deferred.Or_error.List.iter ~f (List.init 1100 ~f:Fn.id)

let () =
  ignore(main() >>|? fun _ -> shutdown 0);
  never_returns(Scheduler.go())
