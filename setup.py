from distutils.core import setup
from distutils.extension import Extension
from distutils.command.build_ext import build_ext
from Cython.Build import cythonize
from subprocess import check_output
from os import environ

cmd = environ.get('comspec', 'cmd')

class WinptyExtension(Extension):
    pass

class build_winpty(build_ext):
    def build_extensions(self):
        winpty_exts = [ext for ext in self.extensions if isinstance(ext, WinptyExtension)]
        if winpty_exts:
            winpty_commit_hash = check_output([cmd, '/c', r'cd winpty\src\shared && GetCommitHash.bat']).decode()
            winpty_gen_include = check_output([cmd, '/c', r'cd winpty\src\shared && UpdateGenVersion.bat {}'.format(winpty_commit_hash)]).decode()
            if winpty_gen_include[-2:] == '\r\n':
                winpty_gen_include = winpty_gen_include[:-2]
        for ext in winpty_exts:
            ext.include_dirs += ['winpty/src/{}'.format(winpty_gen_include)]

        super().build_extensions()


setup(
    name = 'pywinpty',
    cmdclass = {
        'build_ext': build_winpty},
    ext_modules = cythonize(
        WinptyExtension('pywinpty',
            define_macros = [
                ('UNICODE', None),
                ('_UNICODE', None),
                ('NOMINMAX', None),
                ('COMPILING_WINPTY_DLL', None)],
            include_dirs = [
                'winpty/src/include'],
            libraries = [
                'advapi32',
                'user32'],
            sources = [
                'winpty/src/libwinpty/AgentLocation.cc',
                'winpty/src/libwinpty/winpty.cc',
                'winpty/src/shared/BackgroundDesktop.cc',
                'winpty/src/shared/Buffer.cc',
                'winpty/src/shared/DebugClient.cc',
                'winpty/src/shared/GenRandom.cc',
                'winpty/src/shared/OwnedHandle.cc',
                'winpty/src/shared/StringUtil.cc',
                'winpty/src/shared/WindowsSecurity.cc',
                'winpty/src/shared/WindowsVersion.cc',
                'winpty/src/shared/WinptyAssert.cc',
                'winpty/src/shared/WinptyException.cc',
                'winpty/src/shared/WinptyVersion.cc',
                'pywinpty.pyx'],
            language='c++'),
        compiler_directives = {
            'embedsignature': True,
            'language_level': 3}))
