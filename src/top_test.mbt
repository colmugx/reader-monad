///|
test "@reader.Reader::pure/basic" {
  let r = @reader.Reader::pure(42)
  inspect!(@reader.Reader::run(r, ()), content="42")
  let s = @reader.Reader::pure("hello")
  inspect!(@reader.Reader::run(s, 0), content="hello")
}

///|
test "@reader.Reader::bind/composition" {
  let r = @reader.Reader::pure(10)
  let f = fn(x : Int) { @reader.Reader::pure(x * 2) }
  let g = fn(x : Int) { @reader.Reader::pure(x + 1) }
  let r1 = @reader.Reader::bind(r, f)
  let r2 = @reader.Reader::bind(r1, g)
  inspect!(@reader.Reader::run(r2, ()), content="21")
}

///|
test "@reader.Reader::ask/environment_access" {
  let get_length = @reader.Reader::ask(fn(s : String) { s.length() })
  inspect!(@reader.Reader::run(get_length, "hello"), content="5")
  inspect!(@reader.Reader::run(get_length, ""), content="0")
}