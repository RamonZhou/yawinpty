from subprocess import check_call, call, STDOUT
from glob import glob
from shutil import move
from os import remove

check_call('pip install -r requirements.txt', stderr = STDOUT)
check_call('pip install wheel', stderr = STDOUT)
check_call('python setup.py bdist_wheel', stderr = STDOUT)
whl = glob('dist/*.whl')
assert(len(whl) == 1)
whl = whl[0]
call('pip uninstall -y yawinpty', stderr = STDOUT)
check_call(['pip', 'install', whl], stderr = STDOUT)
move(whl, 'finaldist')
try:
    remove('env')
except OSError:
    pass
check_call('python tests.py', stderr = STDOUT)
