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
        if self._errobj == NULL:
            raise TypeError('NULL is not a valid errobj')
        return winpty.winpty_error_code(self._errobj)
    def get_msg(self):
        """get error msg from errobj"""
        if self._errobj == NULL:
            raise TypeError('NULL is not a valid errobj')
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

class _Flag:
    """class _Flag contains flags

    conerr
    ======
     Create a new screen buffer (connected to the "conerr" terminal pipe) and
     pass it to child processes as the STDERR handle.  This flag also prevents
     the agent from reopening CONOUT$ when it polls -- regardless of whether the
     active screen buffer changes, winpty continues to monitor the original
     primary screen buffer.

    plain_output
    ============
     Don't output escape sequences.

    color_escapes
    =============
     Do output color escape sequences.  These escapes are output by default, but
     are suppressed with WINPTY_FLAG_PLAIN_OUTPUT.  Use this flag to reenable
     them.

    allow_curproc_desktop_creation
    ==============================
     On XP and Vista, winpty needs to put the hidden console on a desktop in a
     service window station so that its polling does not interfere with other
     (visible) console windows.  To create this desktop, it must change the
     process' window station (i.e. SetProcessWindowStation) for the duration of
     the winpty_open call.  In theory, this change could interfere with the
     winpty client (e.g. other threads, spawning children), so winpty by default
     spawns a special agent process to create the hidden desktop.  Spawning
     processes on Windows is slow, though, so if
     WINPTY_FLAG_ALLOW_CURPROC_DESKTOP_CREATION is set, winpty changes this
     process' window station instead.
     See https://github.com/rprichard/winpty/issues/58.

    mask
    ====
     mask of flags"""

    conerr=             0x1
    plain_output=       0x2
    color_escapes=      0x4
    allow_curproc_desktop_creation=0x8
    mask = (0 \
        | conerr \
        | plain_output \
        | color_escapes \
        | allow_curproc_desktop_creation \
    )
class _MouseMode:
    """class _MouseMode contains mouse modes

    none
    ====
     QuickEdit mode is initially disabled, and the agent does not send mouse
     mode sequences to the terminal.  If it receives mouse input, though, it
     still writes MOUSE_EVENT_RECORD values into CONIN.

    auto
    ====
     QuickEdit mode is initially enabled.  As CONIN enters or leaves mouse
     input mode (i.e. where ENABLE_MOUSE_INPUT is on and ENABLE_QUICK_EDIT_MODE
     is off), the agent enables or disables mouse input on the terminal.

     This is the default mode.

    force
    =====
     QuickEdit mode is initially disabled, and the agent enables the terminal's
     mouse input mode.  It does not disable terminal mouse mode (until exit)."""

    none=         0
    auto=         1
    force=        2

cdef class Config:
    """class Config to handle a winpty config object"""
    cdef winpty.winpty_config_t* _cfg
    def __init__(self, *flags):
        """init Config with `flags`
        `flags` is combine of `Config.flag.*`"""
        cdef winpty.UINT64 rf = 0
        for flag in flags:
            rf |= flag
        cdef winpty.winpty_error_ptr_t err
        self._cfg = winpty.winpty_config_new(rf, &err)
        if err != NULL:
            WinptyError._raise_errobj(create_ErrorObject(err))
    def __dealloc__(self):
        winpty.winpty_config_free(self._cfg)
    def set_initial_size(self, cols, rows):
        """set initial size"""
        winpty.winpty_config_set_initial_size(self._cfg, cols, rows)
    def set_mouse_mode(self, mouse_mode):
        """set mouse mode to `mouse_mode` which is one of `Config.mouse_mode`"""
        winpty.winpty_config_set_mouse_mode(self._cfg, mouse_mode)
    def set_agent_timeout(self, timeout):
        """Amount of time (in ms) to wait for the agent to startup and to wait for any given
        agent RPC request.  Must be greater than 0.  Can be INFINITE."""
        winpty.winpty_config_set_agent_timeout(self._cfg, timeout)
    flag = _Flag()
    mouse_mode = _MouseMode()
    def __getattribute__(self, attr):
        if attr in ('flag', 'mouse_mode'):
            raise AttributeError("'{}' object has no attribute '{}'".format(type(self).__name__, attr))
        else:
            return object.__getattribute__(self, attr)