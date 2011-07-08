say("1..9")

a <- 1

foo <- function(a) {
    say("ok ", a)
    a <- 3 # No side-effects!
    b <- 2 # Will be like a <<- assignment
    return(a+b)
}

C = foo(a)
print(c("ok", b))
print(c("ok", a+2))

# New test of functions:
foo2 <- function(a) {
    return(a)
}

d <- foo2(4)
print(c("ok", d))
print(c("ok", foo2(5)))

e = []
e[1] = 6

print(c("ok", e[1]))

# The following should vanish or go someplace else, but I leave it for now.

classtest()
