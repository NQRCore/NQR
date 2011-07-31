
print("1..35")

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

# Vector operations
a <- rep(3,10) * 1:10
print(paste("ok", a[6]))

a <- rep(c(0,1), 5)
a <- (!a + 1:10) * 2 + 2
print(paste("ok", a[9]))

a <- (-5:5) * -4 + 3
print(paste("ok", a[0]))

a <- seq(0,24,1)
print(paste("ok", a[24]))

a[10] <- 25
print(paste("ok", a[10]))

j <- 0
a <- rep(0,27)
while (j <= 26) {
    a[j] <- j
    j = j + 1
}
print(paste("ok", a[length(a)-1]))

a <- seq(1.0, 27, 1)
print(paste("ok", max(a)))

a <- c(0, a, 1234.567)
print(paste("ok", which.max(a)))

set.seed(1,2)
a <- rexp(30, 1.0)
print(paste("ok", which.max(sort(a))))

print(paste("ok", 29 + is.array(a)))
print(paste("ok", 30 + var(c(0.0, 1, 2))))
print(paste("ok", exp(log(32.0))))
print(paste("ok", 32 + cor(seq(0.5,10,1), seq(5.5,15,1))))

print(c("ok", 34))

a <- seq(0.5,22,1)
b <- seq(0.5,14,1)
print(c("ok", a[length(a)-1] + b[length(b)-1]))


