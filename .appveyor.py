from subprocess import check_call

check_call('pip install -r requirements.txt')
check_call('python setup.py install')
check_call('python tests.py')
