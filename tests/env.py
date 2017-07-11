import pickle
from os import environ

pickle.dump({**environ}, open('env', 'wb'))
