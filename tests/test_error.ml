open Core_kernel.Std
open Async.Std

let phrases = [
    "1 +";
    "1 +. 1.";
    "type t = 'a";
  ]


let eval_phrases t =
  Deferred.Or_error.List.iter
    phrases
    ~f:(fun phrase ->
        Format.printf "# [32m%s[0m;;@\n%!" phrase;
        Oloop.eval t phrase >>| function
        | Result.Ok(out_phrase, _) ->
           !Oprint.out_phrase Format.std_formatter out_phrase;
           Format.printf "@?";
           Ok()
        | Result.Error(e, msg) ->
           Format.printf "[36m%s[0m" msg;
           Oloop.report_error Format.std_formatter e;
           Ok()
       )

let () =
  ignore(Oloop.with_toploop Oloop.Output.separate ~f:eval_phrases
         >>| function
         | Ok _ -> shutdown 0
         | Error e -> eprintf "%s\n%!" (Error.to_string_hum e);
                     shutdown 1);
  never_returns(Scheduler.go())