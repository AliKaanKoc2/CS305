device A : sensor;
  device L : light;
  rule "R" {
    when A > 2147483648;
    then L = task;
  }