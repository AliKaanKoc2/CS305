// Test file 1: Basic tokens
// Tests device declarations

device Temp : sensor;
device Light : light;
device Plug : switch;

rule "WarmEvening" {
    when Temp > 24 and time in 18:00..23:00;
    then Light = accent and Plug = off;
}