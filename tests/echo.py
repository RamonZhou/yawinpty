try:
    input = raw_input
except NameError:
    pass
try:
    while True:
        print(input())
except EOFError:
    pass
