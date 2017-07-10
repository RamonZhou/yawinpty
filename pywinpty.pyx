cimport winpty

cdef ws2str(winpty.LPCWSTR wmsg):
    """convert wchar_t* to str"""
    if wmsg == NULL:
        return None
    if wmsg[0] == 0:
        return ''
    cdef int sz = winpty.WideCharToMultiByte(winpty.CP_UTF8, winpty.WC_ERR_INVALID_CHARS, wmsg, -1, NULL, 0, NULL, NULL)
    if sz == 0:
        raise OSError(None, None, None, winpty.GetLastError())
    cdef char* amsg = <char*>winpty.malloc(sz + 1)
    if amsg == NULL:
        raise MemoryError('malloc failed')
    cdef int rc = winpty.WideCharToMultiByte(winpty.CP_UTF8, winpty.WC_ERR_INVALID_CHARS, wmsg, -1, amsg, sz, NULL, NULL)
    if rc == 0:
        winpty.free(amsg)
        raise OSError(None, None, None, winpty.GetLastError())
    amsg[sz] = <char>0
    msg = <bytes>amsg
    winpty.free(amsg)
    return msg.decode('utf8')

cdef class ErrorObject:
    """errobj handle class for internal use"""
    cdef winpty.winpty_error_ptr_t _errobj
    def __init__(self):
        """should not use this
        use `create_ErrorObject` instead"""
        self._errobj = NULL
    def __dealloc__(self):
        """free the errobj"""
        winpty.winpty_error_free(self._errobj)
    def get_code(self):
        """get error code from errobj"""
        return winpty.winpty_error_code(self._errobj)
    def get_msg(self):
        """get error msg from errobj"""
        return ws2str(winpty.winpty_error_msg(self._errobj))
cdef create_ErrorObject(winpty.winpty_error_ptr_t errobj):
    """create ErrorObject with `winpty_error_ptr_t errobj`"""
    self = ErrorObject()
    self._errobj = errobj
    return self

class WinptyError(RuntimeError):
    """base error class for winpty

    there are 'error codes' for winpty to specify errors

    each error class maps a error code

    `self.code` is the original code for internal use

    `self.args[0]` is the textual representation of the error
    """

    def __init__(self, code, err_msg):
        """init WinptyError with `code` and `err_msg`"""
        super().__init__(err_msg)
        self.code = code
class UnknownError(WinptyError):
    """class UnknownError for unknown error code"""
    def __init__(self, code, err_msg):
        """init UnknownError with `code` and `err_msg`"""
        super().__init__(code, err_msg)
class UnknownUnknownError(UnknownError):
    """class UnknownUnknownError for unspecified error code"""
    def __init__(self, err_msg):
        """init UnknownUnknownError with `err_msg`"""
        super().__init__(None, err_msg)
