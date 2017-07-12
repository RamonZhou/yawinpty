========
yawinpty
========
yet another winpty binding for python

.. image:: https://ci.appveyor.com/api/projects/status/vaa9vkgs8ihivyg9?svg=true
  :target: https://ci.appveyor.com/project/TitanSnow/yawinpty
  :alt: Build status
.. image:: https://img.shields.io/github/license/PSoWin/yawinpty.svg
  :target: LICENSE
  :alt: LICENSE

build & install
===============

There are two ways to build & install yawinpty

install from an egg/wheel
  it's easiest way. just use ``pip`` is ok. you can use ``pip install`` to install from PyPI as well
build from source
  if none of pre-built eggs is suitable of your python, then you need to build from source
  
  make sure you have installed Visual Studio and also make sure the version of it is new enough otherwise building winpty might fail
  
  *important:* python 3.4 and versions below always try to use MSVC9.0. it might be a issue of ``distutils`` so some hack work is needed to do on ``distutils``. python 3.5+ have no problem
  
  open "Native Tools Command Prompt for VS" then use ``python setup.py build`` to build and ``python setup.py install`` to install. also you could install from a source tarball

basic example
=============

.. code-block:: python

  from yawinpty import *
  
  pty = Pty(Config(Config.flag.plain_output))
  cfg = SpawnConfig(SpawnConfig.flag.auto_shutdown, cmdline='python -c "print(\'helloworld\')"')
  with open(pty.conout_name(), 'r') as fout:
      pty.spawn(cfg)
      out = fout.read()


using ``yawinpty``
==================

the common goal to use ``yawinpty`` is to open a pseudo terminal then spawn a process in it and send input to it's stdin and get output from it's stdout. yawinpty.Pty wrapper a pseudo-terminal and do the jobs

*class* yawinpty.\ *Pty*\ (*config=yawinpty.Config()*)
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

yawinpty.Pty accept a instance of yawinpty.Config as its config

*class* yawinpty.\ *Config*\ (:emphasis:`\*flags`)
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

for the flags to init a "config class" is commonly a set of Class.flag.\*. example\:

.. code-block:: python

  cfg = yawinpty.Config(yawinpty.Config.flag.plain_output)

``help(yawinpty.Config.flag)`` for more supported flags

for ``yawinpty.SpawnConfig`` it's similar

``help(yawinpty.Config)`` for more methods

instances of the ``Pty`` class have the following methods\:

Pty.\ *conin_name*\ ()
>>>>>>>>>>>>>>>>>>>>>>

Pty.\ *conout_name*\ ()
>>>>>>>>>>>>>>>>>>>>>>>

Pty.\ *conerr_name*\ ()
>>>>>>>>>>>>>>>>>>>>>>>

get the name of console in/out/err pipe. the name could be passed to builtin ``open`` to open the pipe

Pty.\ *agent_process_id*\ ()
>>>>>>>>>>>>>>>>>>>>>>>>>>>>

get the process id of the agent process

Pty.\ *set_size*\ ()
>>>>>>>>>>>>>>>>>>>>

set window size of the terminal

Pty.\ *spawn*\ (\ *spawn_config*\ )
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

spawn a process in the pty. spawn_config is a instance of ``yawinpty.SpawnConfig``. note that one Pty instance could only spawn once otherwise ``yawinpty.RespawnError`` would be raised

returns a tuple of *process id, thread id* of spawned process

*class* yawinpty.\ *SpawnConfig*\ (:emphasis:`\*spawnFlags, appname=None, cmdline=None, cwd=None, env=None`)
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

``spawnFlags``
  the flags from ``yawinpty.SpawnConfig.flag``
``appname``
  full path to executable file. can be ``None`` if ``cmdline`` is specified
``cmdline``
  command line passed to the spawned process
``cwd``
  working directory for the spawned process
``env``
  the environ for the spawned process, a dict like ``{'VAR1': 'VAL1', 'VAR2': 'VAL2'}``

note that init a ``SpawnConfig`` *does not* spawn a process. a process is spawned only when calling ``Pty.spawn()``. one SpawnConfig instance could be used multitimes

exceptions
>>>>>>>>>>

all winpty related exceptions are subclasses of ``yawinpty.WinptyError``. ``help(yawinpty)`` for more information
