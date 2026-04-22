device Temp : sensor;
device Light1 : light;

rule "Morning" {
    when Temp > 20;
    then Light1 = ambient;
}