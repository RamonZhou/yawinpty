from subprocess import check_call, STDOUT

check_call('pip install -r requirements.txt', stderr = STDOUT)
check_call('pip install wheel', stderr = STDOUT)
check_call('python setup.py bdist_wheel', stderr = STDOUT)
check_call('python setup.py install', stderr = STDOUT)
check_call('python tests.py', stderr = STDOUT)
