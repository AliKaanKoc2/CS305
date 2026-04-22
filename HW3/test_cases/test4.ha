device Humidity : sensor;
device Thermostat : sensor;
device Fan : switch;
device Lamp : light;

rule "ComplexCondition" {
    when (Humidity >= 80 or Thermostat <= 15) and not time in 00:00..06:00;
    then Fan = on; Lamp = ambient;
}

rule "Morning" {
    when Thermostat < 20 and time in 06:00..09:00;
    then Lamp = task;
}

rule "Evening" {
    when time in 18:00..22:00 and Humidity != 50;
    then Fan = off;
}