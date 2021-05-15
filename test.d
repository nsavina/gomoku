import std.stdio;
import std;
import std.regex;

int main()
{
  string s = "sss.s";
  string b = s.replace('s', 'X');
  writeln(b);

  char[4] arr = ['a', 'b', 'c', 'd'];
  string st = arr.idup();
  writeln(st);
  arr = new char[4];
  writeln(arr);
  string stt = "aaa";
  string t = "aaa";
  writeln(t == stt);

  for (int i = 0; i <= 0; i++) {
    writeln("hi");
  }
  s = "bbb";
  writeln(s);

  string ss = "aaaa";
  writeln(ss.findSplit("aaaa"));
  writeln(ss.findSplit("aaaaa"));

  writeln(5 / 2);

  auto rnd = Random(unpredictableSeed);

// Generate an integer in [0, 1023]
  auto a = uniform(0, 2, rnd);

  writeln(a);

  writeln("regexp");

  auto r = r"71111|17111|11711|11171|11117";
  writeln(r);
  writeln(bmatch("000071111", r));
  if (bmatch("54", r)) {
    writeln("true");
  }
  else {
    writeln("false");
  }

  return 0;
}