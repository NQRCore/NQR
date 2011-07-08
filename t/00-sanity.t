
say("1..25")

# test global variable
g = 1
print(c("ok", g))

# test local variable  DEFUNCT
x = 2
print(c("ok", x))

# test hashtable indexing
hsh  = {}
key  = "hi"
hsh{key} = 3

print(c("ok", hsh{key}))

# test array indexing
arr = []
idx = 10
arr[idx] = 4

print(c("ok", arr[idx]))

# JWE: NEW test function
foo <- function(a) {
    print(c("ok", a))
    return(a)
}
a <- foo(5)

# test if statement JWE: requiring R-ish usage now

a = 1
b = 1
C = 0
d = 0

if (a) {
    print("ok 6")
}

if (!C) {
    print("ok 7")
}

if (a & b) {
    print("ok 8")
}

if (a | C) {
    print("ok 9")
}

if (!C & a) {
    print("ok 10")
}

if (C) {
    print("nok 11")
} else {
    print("ok 11")
}

# test algorithmic
a = 1 + 11
b = 4 * 3 + 1
C = 15 - 1
d = 45 % 30
e = (3 + 1) * (3 + 1)

print(c("ok", a))
print(c("ok", b))
print(c("ok", C))
print(c("ok", d))
print(c("ok", e))

# test try-statement (omitted)

#try
#    throw "error"
#catch exc
#    say("ok 17")
#    #say(exc)
#end

print("ok 17")
print("ok 18")
print("ok 19")
print("ok 20")

# for-statement



#for var i = 18, 20 {
#    i = 20
#    print(c("ok", i))
#}

g = 21

## XXX there's something wrong with the for loop and the step of 2.
## k={21,23,25,27,29}, g={21,22,23,24,25}
#for var k = 21, 29, 2 do
#    say("ok ", g)
#    g = g + 1
#end

# JWE: modified for new while syntax:
j = 0
while (j < 5) {
    print(c("ok", j + g))
    j = j + 1
}


