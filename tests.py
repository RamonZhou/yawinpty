import unittest
from yawinpty import *

class YawinptyTest(unittest.TestCase):
    """tests for yawinpty"""
    def test_helloworld(self):
        """test simple use"""
        pty = Pty(Config(Config.flag.plain_output))
        cfg = SpawnConfig(SpawnConfig.flag.auto_shutdown, cmdline = r'python tests\helloworld.py')
        with open(pty.conout_name(), 'r') as fout:
            pty.spawn(cfg)
            out = fout.read()
        self.assertEqual(out, 'helloworld\n')

if __name__ == '__main__':
    unittest.main()
