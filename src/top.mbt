///|
pub struct Reader[Env, A] {
  priv _run : (Env) -> A
}

///|
/// Creates a new `Reader` from a function that transforms an environment into a
/// value.
///
/// Parameters:
///
/// * `f`: A function that takes an environment of type `Env` and produces a
/// value of type `A`. This function represents the computation that will be
/// performed in the context of the environment.
///
/// Returns a new `Reader` that encapsulates the given computation.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::new" {
///   let reader : Reader[String, Int] = Reader::new(fn { env => env.length() })
///   inspect!(reader.run("hello"), content="5")
/// }
/// ```
fn Reader::new[Env, A](f : (Env) -> A) -> Reader[Env, A] {
  { _run: f }
}

///|
/// Creates a new `Reader` that ignores the environment and always returns a
/// constant value.
///
/// Parameters:
///
/// * `x` : The value to be returned by the reader.
///
/// Generic Parameters:
///
/// * `Env` : The type of environment (which will be ignored).
/// * `A` : The type of the value to be returned.
///
/// Returns a new `Reader` that always produces the given value regardless of the
/// environment.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::pure" {
///   let reader = Reader::pure("constant")
///   inspect!(reader.run(42), content="\"constant\"")
/// }
/// ```
pub fn Reader::pure[Env, A](x : A) -> Reader[Env, A] {
  { _run: fn { _ => x } }
}

///|
/// Executes a reader computation with the given environment.
///
/// Parameters:
///
/// * `reader` : A `Reader` that contains the computation to be executed.
/// * `environment` : The environment value to be provided to the computation.
///
/// Returns the result of running the reader computation with the given
/// environment.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::run" {
///   let reader = Reader::new(fn { env => env + 1 })
///   inspect!(reader.run(41), content="42")
/// }
/// ```
pub fn Reader::run[Env, A](reader : Reader[Env, A], config : Env) -> A {
  (reader._run)(config)
}

///|
/// Chains two reader computations by applying a function to the result of the
/// first reader to produce a second reader computation.
///
/// Parameters:
///
/// * `reader` : The first reader computation that produces a value of type `A`.
/// * `f` : A function that takes the result of the first reader and returns a
/// new reader computation of type `B`.
///
/// Returns a new reader that represents the sequential composition of the two
/// computations.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::bind" {
///   let reader1 = Reader::pure(5)
///   let reader2 = reader1.bind(fn { x => Reader::pure(x * 2) })
///   inspect!(reader2.run(0), content="10")
/// }
/// ```
pub fn Reader::bind[Env, A, B](
  reader : Reader[Env, A],
  f : (A) -> Reader[Env, B]
) -> Reader[Env, B] {
  Reader::new(fn { env => reader.run(env) |> f |> Reader::run(env) })
}

///|
/// Maps a function over the value produced by a reader computation, transforming
/// it from type `A` to type `B` while preserving the reader context.
///
/// Parameters:
///
/// * `reader` : A reader computation that produces a value of type `A`.
/// * `f` : A transformation function that converts a value of type `A` to type
/// `B`.
///
/// Returns a new reader that will run the original computation and then apply
/// the transformation function to its result.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::map" {
///   let reader = Reader::pure(5)
///   let mapped = reader.map(fn { x => x * 2 })
///   inspect!(mapped.run(0), content="10")
/// }
/// ```
pub fn Reader::map[Env, A, B](
  reader : Reader[Env, A],
  f : (A) -> B
) -> Reader[Env, B] {
  reader.bind(fn { a => f(a) |> Reader::pure })
}

///|
/// Executes a reader computation with a modified environment.
///
/// Parameters:
///
/// * `reader` : A `Reader` computation that produces a value of type `A`.
/// * `modifier` : A function that transforms the environment before it's passed
/// to the reader computation.
///
/// Returns a new reader that will run the original computation with the modified
/// environment.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "Reader::local_" {
///   let reader = Reader::new(fn { env => env * 2 })
///   let modified = reader.local_(fn { env => env + 1 })
///   inspect!(modified.run(5), content="12")
/// }
/// ```
pub fn Reader::local_[Env, A](
  reader : Reader[Env, A],
  modifier : (Env) -> Env
) -> Reader[Env, A] {
  Reader::new(fn { env => reader.run(modifier(env)) })
}

///|
/// Creates a Reader that simply returns the environment itself.
///
/// Generic Parameters:
///
/// * `Env`: The type of the environment.
///
/// Returns a reader computation that produces the environment when run.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "ask" {
///   let reader = ask()
///   inspect!(reader.run("hello"), content="\"hello\"")
/// }
/// ```
pub fn ask[Env]() -> Reader[Env, Env] {
  Reader::new(fn { env => env })
}

///|
/// Creates a Reader that transforms the environment using a given function.
///
/// Parameters:
///
/// * `f` : A function that takes an environment of type `Env` and produces a
/// value of type `A`. This function will be applied to the environment when the
/// reader is run.
///
/// Returns a new `Reader` that will apply the given function to the environment.
///
/// Example:
///
/// ```moonbit
/// ///|
/// test "asks" {
///   let reader = asks(fn { env => env + 1 })
///   inspect!(reader.run(41), content="42")
/// }
/// ```
pub fn asks[Env, A](f : (Env) -> A) -> Reader[Env, A] {
  Reader::new(f)
}
