import os
from subprocess import check_call, STDOUT

os.chdir('tests')
for test in os.listdir('.'):
    if not os.path.isdir(test):
        continue
    os.chdir(test)
    print('Testing {}'.format(test))
    check_call(['python', 'server.py'], stderr = STDOUT)
    os.chdir('..')
