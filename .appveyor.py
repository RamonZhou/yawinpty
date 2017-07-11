from subprocess import check_call, STDOUT

check_call('pip install -r requirements.txt', stderr = STDOUT)
check_call('python setup.py bdist_egg', stderr = STDOUT)
check_call('python setup.py install', stderr = STDOUT)
check_call('python tests.py', stderr = STDOUT)
