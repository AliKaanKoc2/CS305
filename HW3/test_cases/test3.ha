device Temp : sensor;
device Temp : light;
device Light1 : light;
device Switch1 : switch;
rule "Test" {
    when Foo > 24;
    then Temp = on;
}
rule "Morning" {
    when Light1 > 50;
    then Switch1 = ambient;
}
rule "Morning" {
    when time in 06:00..10:00;
    then Switch1 = on;
}