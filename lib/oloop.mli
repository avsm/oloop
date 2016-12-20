open Core_kernel.Std
open Async_kernel.Std

module Script : module type of Oloop_script

module Raw_script : module type of Oloop_raw_script

module Outcome : module type of Oloop_outcome
  with type separate = Oloop_outcome.separate
  with type merged = Oloop_outcome.merged
  with type 'a kind = 'a Oloop_outcome.kind
  with type 'a eval = 'a Oloop_outcome.eval

type 'a t
(** A handle to a toploop. *)

type 'a ocaml_args =
  ?include_dirs: string list ->
  ?no_app_functors: unit ->
  ?principal: unit ->
  ?rectypes: unit ->
  ?short_paths: unit ->
  ?strict_sequence: unit ->
  ?thread: unit ->
  'a

type 'a args = (
  ?prog: string ->
  ?working_dir: string ->
  ?msg_with_location: unit ->
  ?silent_directives: unit ->
  ?determine_deferred: unit ->
  ?determine_lwt: unit ->
  'a
) ocaml_args

val create : ('a Outcome.kind -> 'a t Or_error.t Deferred.t) args
(** Create a new toploop.

    The optional arguments [include_dirs] (-I), [init],
    [no_app_functors], [principal], [rectypes], [short_paths] and
    [strict_sequence] correspond activate toploop flags.  By default,
    they are not provided.

    @param msg_with_location if provided, make error messages returned
    by {!eval} contain the location of the error.  The
    location is always accessible using {!location_of_error} which can
    be used to highlight the problematic part of the phrase.

    @param silent_directives if set, the toplevel directives (existing
    ones or new ones), unless they raise an exception, will return an
    empty structure — thus [Oprint.out_phrase] will print nothing —
    and their output will be discarded.

    @param determine_deferred Automatically determine anonymous
    [Deferred.t] values as Utop does.

    @param determine_lwt Automatically determine anonymous [Lwt.t]
    values as Utop does.

    @param prog is full path to the specially customized toploop that
    you want to run (if for example it is at an unusual location). *)

val close : _ t -> unit Deferred.t
(** Terminates the toplevel. *)

val with_toploop : (
  'a Outcome.kind ->
  f:('a t -> 'b Deferred.Or_error.t) ->
  'b Deferred.Or_error.t
) args
(** [with_toploop kind f] will run [f], closing the toploop and
    freeing its resources whether [f] returns a result or an error.
    This is convenient in order use to the bind operator [>>=?] to
    chain computations in [f]. *)

val eval : 'a t -> string -> 'a Outcome.t Deferred.t
(** [eval t phrase] evaluates [phrase] in the toploop [t]. *)

val eval_or_error :
  'a t -> string -> 'a Outcome.eval Deferred.Or_error.t
(** Same as {!eval} except that the [`Uneval] result is transformed
   into an [Error.t] using the function {!Outcome.uneval_to_error}. *)

val init : ?file: string -> _ t -> unit Deferred.Or_error.t
(** [init t] seek the ".ocamlinit" file and evaluate it.  It first
    checks whether ".ocamlinit" exists in the current directory and,
    if not, it tries to find one in your $HOME directory.

    @param init_file the name (and path, absolute or relative to the
    current directory) of the file to evaluate. *)

val eval_script :
  (?init: string -> ?noinit: unit ->
   Script.t -> Script.Evaluated.t Or_error.t Deferred.t) args
(** [eval_script sc] evaluate the script [sc] and return the outcome
    of each phrase.

    @param init load that file at startup.
    @param noinit do not load any file at startup, not even
    "$HOME/.ocamlinit". *)


(** {2 Miscellaneous} *)

val phrase_remove_underscore_names :
  Outcometree.out_phrase -> Outcometree.out_phrase

val signatures_remove_underscore_names :
  Outcometree.out_sig_item list -> Outcometree.out_sig_item list

(** Copy of the compiler [Location] module, enriched with conversions
    from and to sexp. *)
module Location : sig
    include module type of Location with type t = Location.t

    val sexp_of_t : t -> Sexp.t
  end
