say("1..5")

# JWE OLD:
#sub ok(v)
#    say("ok ", v)
#end

# JWE NEW:
ok <- function(v) {
    print(c("ok", v))
}

ok(1+0)
ok(3-1)
ok(2*2-1)
ok(8/2)
ok(15%10)
