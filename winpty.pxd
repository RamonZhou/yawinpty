from libc.stddef cimport wchar_t
from libc.stdlib cimport malloc, free

cdef extern from 'windows.h':
    ctypedef wchar_t WCHAR
    ctypedef char CHAR
    ctypedef int BOOL
    ctypedef const WCHAR* LPCWSTR
    ctypedef CHAR* LPSTR
    ctypedef const CHAR* LPCSTR
    ctypedef BOOL* LPBOOL
    ctypedef unsigned long DWORD
    ctypedef unsigned int UINT
    cdef int CP_UTF8
    cdef int WC_ERR_INVALID_CHARS
    cdef int WideCharToMultiByte(UINT, DWORD, LPCWSTR, int, LPSTR, int, LPCSTR, LPBOOL)
    cdef DWORD GetLastError()

cdef extern from 'winpty.h':
    cdef int WINPTY_ERROR_SUCCESS
    cdef int WINPTY_ERROR_OUT_OF_MEMORY
    cdef int WINPTY_ERROR_SPAWN_CREATE_PROCESS_FAILED
    cdef int WINPTY_ERROR_LOST_CONNECTION
    cdef int WINPTY_ERROR_AGENT_EXE_MISSING
    cdef int WINPTY_ERROR_UNSPECIFIED
    cdef int WINPTY_ERROR_AGENT_DIED
    cdef int WINPTY_ERROR_AGENT_TIMEOUT
    cdef int WINPTY_ERROR_AGENT_CREATION_FAILED
    ctypedef DWORD winpty_result_t
    cdef struct winpty_error_t:
        pass
    ctypedef winpty_error_t* winpty_error_ptr_t
    cdef winpty_result_t winpty_error_code(winpty_error_ptr_t err)
    cdef LPCWSTR winpty_error_msg(winpty_error_ptr_t err);
    cdef void winpty_error_free(winpty_error_ptr_t err);
