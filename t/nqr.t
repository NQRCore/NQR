say("1..3")

a <- 1

foo <- function(a) {
    print(paste("ok", a))
    a <- 3 # No side-effects!
    b <- 2 # Will be like a <<- assignment
    return(a+b)
}

C = foo(a)
print(paste("ok", b))
print(paste("ok", a+2))



