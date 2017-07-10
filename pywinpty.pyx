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

cdef class _ErrorObject:
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
    """create _ErrorObject with `winpty_error_ptr_t errobj`"""
    self = _ErrorObject()
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
    @staticmethod
    def _from_code(code):
        """get Error type from code"""
        mp = {
            winpty.WINPTY_ERROR_OUT_OF_MEMORY: OutOfMemory,
            winpty.WINPTY_ERROR_SPAWN_CREATE_PROCESS_FAILED: SpawnCreateProcessFailed,
            winpty.WINPTY_ERROR_LOST_CONNECTION: LoseConnection,
            winpty.WINPTY_ERROR_AGENT_EXE_MISSING: AgentExeMissing,
            winpty.WINPTY_ERROR_UNSPECIFIED: Unspecified,
            winpty.WINPTY_ERROR_AGENT_DIED: AgentDied,
            winpty.WINPTY_ERROR_AGENT_TIMEOUT: AgentTimeout,
            winpty.WINPTY_ERROR_AGENT_CREATION_FAILED: AgentCreationFailed}
        return mp.get(code, UnknownUnknownError)
    @staticmethod
    def _from_errobj(errobj):
        """get Error type from errobj"""
        return WinptyError._from_code(errobj.get_code())
    @staticmethod
    def _raise_errobj(errobj):
        """raise a Error instance from errobj"""
        err_type = WinptyError._from_errobj(errobj)
        if err_type is UnknownUnknownError:
            raise UnknownError(errobj.get_code(), errobj.get_msg())
        else:
            raise err_type(errobj.get_msg())
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
class OutOfMemory(WinptyError, MemoryError):
    """class OutOfMemory for WINPTY_ERROR_OUT_OF_MEMORY"""
    def __init__(self, err_msg):
        """init OutOfMemory with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_OUT_OF_MEMORY, err_msg)
class SpawnCreateProcessFailed(WinptyError):
    """class SpawnCreateProcessFailed for WINPTY_ERROR_SPAWN_CREATE_PROCESS_FAILED"""
    def __init__(self, err_msg):
        """init SpawnCreateProcessFailed with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_SPAWN_CREATE_PROCESS_FAILED, err_msg)
class LoseConnection(WinptyError):
    """class LoseConnection for WINPTY_ERROR_LOST_CONNECTION"""
    def __init__(self, err_msg):
        """init LoseConnection with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_LOST_CONNECTION, err_msg)
class AgentExeMissing(WinptyError):
    """class AgentExeMissing for WINPTY_ERROR_AGENT_EXE_MISSING"""
    def __init__(self, err_msg):
        """init AgentExeMissing with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_AGENT_EXE_MISSING, err_msg)
class Unspecified(WinptyError):
    """class Unspecified for WINPTY_ERROR_UNSPECIFIED"""
    def __init__(self, err_msg):
        """init Unspecified with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_UNSPECIFIED, err_msg)
class AgentDied(WinptyError):
    """class AgentDied for WINPTY_ERROR_AGENT_DIED"""
    def __init__(self, err_msg):
        """init AgentDied with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_AGENT_DIED, err_msg)
class AgentTimeout(WinptyError):
    """class AgentTimeout for WINPTY_ERROR_AGENT_TIMEOUT"""
    def __init__(self, err_msg):
        """init AgentTimeout with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_AGENT_TIMEOUT, err_msg)
class AgentCreationFailed(WinptyError):
    """class AgentCreationFailed for WINPTY_ERROR_AGENT_CREATION_FAILED"""
    def __init__(self, err_msg):
        """init AgentCreationFailed with `err_msg`"""
        super().__init__(winpty.WINPTY_ERROR_AGENT_CREATION_FAILED, err_msg)
