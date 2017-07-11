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
    def test_errors(self):
        """test Error classes inherit"""
        for code in range(1, 9):
            err_type = WinptyError._from_code(code)
            err_inst = err_type('awd')
            self.assertTrue(issubclass(err_type, WinptyError))
            self.assertIsInstance(err_inst, WinptyError)
            self.assertIsInstance(err_inst, err_type)
            self.assertEqual(err_inst.code, code)
            self.assertEqual(err_inst.args[0], 'awd')

if __name__ == '__main__':
    unittest.main()
