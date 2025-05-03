///|
pub struct Reader[Env, A] {
  priv _run : (Env) -> A
}

///|
pub fn Reader::new[Env, A](f : (Env) -> A) -> Reader[Env, A] {
  { _run: f }
}

///|
pub fn Reader::pure[Env, A](x : A) -> Reader[Env, A] {
  { _run: fn { _ => x } }
}

///|
pub fn Reader::run[Env, A](reader : Reader[Env, A], config : Env) -> A {
  (reader._run)(config)
}

///|
pub fn Reader::bind[Env, A, B](
  reader : Reader[Env, A],
  f : (A) -> Reader[Env, B]
) -> Reader[Env, B] {
  Reader::new(fn { cfg => reader.run(cfg) |> f |> Reader::run(cfg) })
}

///|
pub fn Reader::map[Env, A, B](
  reader : Reader[Env, A],
  f : (A) -> B
) -> Reader[Env, B] {
  reader.bind(fn { a => f(a) |> Reader::pure })
}

///|
pub fn Reader::ask[Env, A](f : (Env) -> A) -> Reader[Env, A] {
  { _run: f }
}
