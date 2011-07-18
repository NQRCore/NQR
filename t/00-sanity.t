
say("1..20")

# Basic assignment
a <- 1
print(paste("ok", a))

# Array indexing and length (note: indexing starts at 0)
a <- 0:2
print(paste("ok", a[2]))
print(paste("ok", length(a)))

# A function
foo <- function(a) {
    print(paste("ok", a))
    return(a+1)
}
a <- foo(4)
print(paste("ok", a))

# Basic logicals and if..then..else

a <- 1
b <- 1
C <- 0
d <- 0

if (a) { print("ok 6") }
if (!C) { print("ok 7") }
if (a & b) { print("ok 8") }
if (a | C) { print("ok 9") }
if (!C & a) { print("ok 10") }
if (C) { print("nok 11")
} else { print("ok 11") }

# test mathy operators
a <- 1 + 11
b <- 4 * 3 + 1
C <- 15 - 1
d <- 15.0
e <- (3 + 1) * (3 + 1)

if (a==12) { print(paste("ok", a)) }
if (b==13) { print(paste("ok", b)) }
if (C==14) { print(paste("ok", C)) }
if (d==15) { print(paste("ok", d)) }
if (e==16) { print(paste("ok", e)) }

j <- 0
g <- 17
while (j < 2) {
    print(paste("ok", j + g))
    j = j + 1
}

# seq()
a <- seq(1, 19, 1)
print(paste("ok", a[18]))

# c()
x <- c("A", c(1,2,20))
print(paste("ok", x[3]))



