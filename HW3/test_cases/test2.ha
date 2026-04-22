device Temp : sensor;
device Temp : light;

rule "Test" {
    when Foo > 24;
    then Temp = on;
}