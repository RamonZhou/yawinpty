import pickle
from os import environ

pickle.dump(dict(**environ), open('env', 'wb'))
