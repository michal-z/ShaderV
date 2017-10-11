format PE GUI
entry Start

macro GetFunc lib*,name* {
        push    name#$
        push    [lib]
        call    [w32GetProcAddress]
        mov     [name],eax
}
macro calli addr* {
        call    [addr]
}

section '.text' code readable executable

  CreateShader:
        push    ebx esi
        push    0                       ; hTemplateFile
        push    0x00000080              ; dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
        push    3                       ; dwCreationAndDesposition = OPEN_EXISTING
        push    0                       ; lpSecurityAttributes
        push    0                       ; dwShareMode
        push    0x80000000              ; dwDesiredAccess = GENERIC_READ
        push    ShaderFileName          ; lpFileName
        calli   w32CreateFile
        cmp     eax,0xFFFFFFFF
        je      .skip
        mov     ebx,eax                 ; ebx = fileHandle
        push    0                       ; lpFileHighSize
        push    ebx                     ; hFile = fileHandle
        calli   w32GetFileSize
        mov     esi,eax                 ; esi = fileSize
        push    0                       ; lpOverlapped
        push    BytesRead               ; lpNumberOfBytesRead
        push    esi                     ; nNumberOfBytesToRead = fileSize
        push    [ShaderCode]            ; lpBuffer
        push    ebx                     ; hFile = fileHandle
        calli   w32ReadFile
        push    ebx                     ; fileHandle
        calli   w32CloseHandle
        push    20
        calli   w32Sleep
        mov     eax,[ShaderCode]
        mov     byte [eax+esi],0        ; store 0 to mark end of string
        push    [Shader]
        calli   glDeleteProgram         ; delete old shader
        push    ShaderCode              ; pointer to pointer of shader code
        push    1                       ; number of source strings
        push    0x8B30                  ; GL_FRAGMENT_SHADER
        calli   glCreateShaderProgramv
        mov     [Shader],eax
        push    [Shader]                ; GL program to use
        calli   glUseProgram
    .skip:
        pop     esi ebx
        ret

  Main:
        push    0x04                    ; flProtect = PAGE_READWRITE
        push    0x00003000              ; flAllocationType = MEM_COMMIT|MEM_RESERVE
        push    64*1024                 ; dwSize = 64KB
        push    0                       ; lpAddress
        calli   w32VirtualAlloc
        mov     [ShaderCode],eax
        push    0                       ; lpParam
        push    0                       ; hInstance
        push    0                       ; hMenu
        push    0                       ; hWndParent
        push    720                     ; nHeight
        push    1280                    ; nWidth
        push    0                       ; y
        push    0                       ; x
        push    0x90000000              ; dwStyle = WS_POPUP|WS_VISIBLE
        push    0                       ; lpWindowName
        push    WinClassName            ; lpClassName
        push    0x00000008              ; dwExStyle = WS_EX_TOPMOST
        calli   w32CreateWindowEx
        push    eax                     ; hwnd
        calli   w32GetDC
        mov     ebx,eax                 ; ebx = hdc
        push    PixelFormatDesc
        push    ebx                     ; hdc
        calli   w32ChoosePixelFormat
        push    PixelFormatDesc
        push    eax                     ; pixel format id
        push    ebx                     ; hdc
        calli   w32SetPixelFormat
        push    ebx                     ; hdc
        calli   wglCreateContext
        push    eax                     ; GL context
        push    ebx                     ; hdc
        calli   wglMakeCurrent
        push    glUseProgram$
        calli   wglGetProcAddress
        mov     [glUseProgram],eax
        push    glCreateShaderProgramv$
        calli   wglGetProcAddress
        mov     [glCreateShaderProgramv],eax
        push    glDeleteProgram$
        calli   wglGetProcAddress
        mov     [glDeleteProgram],eax
        call    CreateShader
        push    1                       ; ask for 1 ms timer resolution
        calli   w32timeBeginPeriod
        calli   w32timeGetTime
        mov     edi,eax                 ; edi = beginTime
    .mainLoop:
        push    0x0001                  ; PM_REMOVE
        push    0
        push    0
        push    0
        push    Message
        calli   w32PeekMessage
        push    'S'
        calli   w32GetAsyncKeyState
        push    eax
        push    0x11                    ; VK_CONTROL
        calli   w32GetAsyncKeyState
        pop     ecx
        and     eax,0x8000
        and     ecx,0x8000
        and     eax,ecx
        jz      .1
        call    CreateShader
    .1: calli   w32timeGetTime
        sub     eax,edi                 ; currentTime = time - beginTime
        push    eax
        fild    dword [esp]
        fstp    dword [esp]
        calli   glTexCoord1f
        push    1
        push    1
        push    -1
        push    -1
        calli   glRecti
        push    ebx                     ; hdc
        calli   w32SwapBuffers
        push    'Q'
        calli   w32GetAsyncKeyState
        push    eax
        push    0x11                    ; VK_CONTROL
        calli   w32GetAsyncKeyState
        pop     ecx
        and     eax,0x8000
        and     ecx,0x8000
        and     eax,ecx
        jnz     .exit
        jmp     .mainLoop
    .exit:
        ret

  Start:
        push    Kernel32$
        calli   w32LoadLibrary
        mov     [Kernel32],eax
        push    User32$
        calli   w32LoadLibrary
        mov     [User32],eax
        push    Gdi32$
        calli   w32LoadLibrary
        mov     [Gdi32],eax
        push    OpenGL32$
        calli   w32LoadLibrary
        mov     [OpenGL32],eax
        push    WinMM$
        calli   w32LoadLibrary
        mov     [WinMM],eax
        GetFunc Kernel32,w32ExitProcess
        GetFunc Kernel32,w32VirtualAlloc
        GetFunc Kernel32,w32Sleep
        GetFunc Kernel32,w32CreateFile
        GetFunc Kernel32,w32ReadFile
        GetFunc Kernel32,w32GetFileSize
        GetFunc Kernel32,w32CloseHandle
        GetFunc User32,w32GetAsyncKeyState
        GetFunc User32,w32CreateWindowEx
        GetFunc User32,w32GetDC
        GetFunc User32,w32PeekMessage
        GetFunc User32,w32DispatchMessage
        GetFunc User32,w32SetProcessDPIAware
        GetFunc Gdi32,w32SwapBuffers
        GetFunc Gdi32,w32SetPixelFormat
        GetFunc Gdi32,w32ChoosePixelFormat
        GetFunc WinMM,w32timeGetTime
        GetFunc WinMM,w32timeBeginPeriod
        GetFunc OpenGL32,wglGetProcAddress
        GetFunc OpenGL32,wglMakeCurrent
        GetFunc OpenGL32,wglCreateContext
        GetFunc OpenGL32,glTexCoord1f
        GetFunc OpenGL32,glRecti
        calli   w32SetProcessDPIAware
        call    Main
        push    0
        calli   w32ExitProcess
        ret

section '.data' data readable writeable

  Shader dd 0
  ShaderCode dd 0

  BytesRead:
  Message:
  PixelFormatDesc:
    dd 0
    dd 0x00000021 ; PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
    db 32 dup 0

  Kernel32 dd 0
  User32 dd 0
  Gdi32 dd 0
  OpenGL32 dd 0
  WinMM dd 0

  w32ExitProcess dd 0
  w32VirtualAlloc dd 0
  w32Sleep dd 0
  w32CreateFile dd 0
  w32ReadFile dd 0
  w32GetFileSize dd 0
  w32CloseHandle dd 0
  w32CreateWindowEx dd 0
  w32GetDC dd 0
  w32ChoosePixelFormat dd 0
  w32SetPixelFormat dd 0
  w32timeGetTime dd 0
  w32timeBeginPeriod dd 0
  w32PeekMessage dd 0
  w32DispatchMessage dd 0
  w32SwapBuffers dd 0
  w32GetAsyncKeyState dd 0
  w32SetProcessDPIAware dd 0

  wglGetProcAddress dd 0
  wglMakeCurrent dd 0
  wglCreateContext dd 0

  glUseProgram dd 0
  glCreateShaderProgramv dd 0
  glDeleteProgram dd 0
  glTexCoord1f dd 0
  glRecti dd 0

  WinClassName db 'static',0
  ShaderFileName db 'ShaderV.glsl',0

  Kernel32$ db 'Kernel32.dll',0
  User32$ db 'User32.dll',0
  Gdi32$ db 'Gdi32.dll',0
  OpenGL32$ db 'OpenGL32.dll',0
  WinMM$ db 'WinMM.dll',0
  w32ExitProcess$ db 'ExitProcess',0
  w32VirtualAlloc$ db 'VirtualAlloc',0
  w32Sleep$ db 'Sleep',0
  w32CreateFile$ db 'CreateFileA',0
  w32ReadFile$ db 'ReadFile',0
  w32GetFileSize$ db 'GetFileSize',0
  w32CloseHandle$ db 'CloseHandle',0
  w32CreateWindowEx$ db 'CreateWindowExA',0
  w32GetDC$ db 'GetDC',0
  w32ChoosePixelFormat$ db 'ChoosePixelFormat',0
  w32SetPixelFormat$ db 'SetPixelFormat',0
  w32timeGetTime$ db 'timeGetTime',0
  w32timeBeginPeriod$ db 'timeBeginPeriod',0
  w32PeekMessage$ db 'PeekMessageA',0
  w32DispatchMessage$ db 'DispatchMessageA',0
  w32SetProcessDPIAware$ db 'SetProcessDPIAware',0
  w32SwapBuffers$ db 'SwapBuffers',0
  w32GetAsyncKeyState$ db 'GetAsyncKeyState',0
  wglCreateContext$ db 'wglCreateContext',0
  wglMakeCurrent$ db 'wglMakeCurrent',0
  wglGetProcAddress$ db 'wglGetProcAddress',0
  glUseProgram$ db 'glUseProgram',0
  glCreateShaderProgramv$ db 'glCreateShaderProgramv',0
  glDeleteProgram$ db 'glDeleteProgram',0
  glTexCoord1f$ db 'glTexCoord1f',0
  glRecti$ db 'glRecti',0

section '.idata' import data readable writeable

                        dd 0,0,0
                        dd rva Kernel32$
                        dd rva w32LoadLibrary
                        dd 0,0,0,0,0
  w32LoadLibrary        dd rva LoadLibrary$
  w32GetProcAddress     dd rva GetProcAddress$
                        dd 0
  LoadLibrary$          dw 0
                        db 'LoadLibraryA',0
  GetProcAddress$       dw 0
                        db 'GetProcAddress',0

section '.reloc' fixups data readable discardable
