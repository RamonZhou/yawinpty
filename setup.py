from sys import version_info
from runpy import run_path

if version_info >= (3, 5):
    run_path('setup3.py')
else:
    run_path('setup2.py')
