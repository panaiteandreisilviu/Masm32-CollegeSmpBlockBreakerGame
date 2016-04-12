.386
.model flat, stdcall   
option casemap:none 

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
include \masm32\include\masm32rt.inc

.data
ClassName db "Proiect SMP",0
AppName  db "Proiect SMP",0
OurText  db "Sisteme cu MicroProcesoare",0

WM_FINISH equ WM_USER+100h

click db "Brush and pen",0
hatch db "hatched brush",0
Solid db "Solid Pen",0
brush db "Solid brush",0
testString db "Sisteme cu MicroProcesoare",0


xpos1 dd 200
ypos1 dd 420
xpos2 dd 300
ypos2 dd 440

ball_x1 dd 245
ball_x2 dd 260
ball_y1 dd 400
ball_y2 dd 385

acceleration dd 10

char WPARAM 9

mousePos POINT <>
.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwnd HANDLE ?
ThreadID DWORD ?
.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
	mov CommandLine,eax
	
	;__________Create Thread__________
	mov  eax,OFFSET GameThread 
    invoke CreateThread,NULL,NULL,eax,\ 
    	NULL,0,\ 
        ADDR ThreadID 
    invoke CloseHandle,eax 
    ;_________________________________
                
	invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax



;__________Window creation and Message Loop__________
	
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL wc:WNDCLASSEX
	LOCAL msg:MSG
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,0
	invoke LoadCursor,NULL,IDC_CROSS
	mov   wc.hCursor,eax
	invoke RegisterClassEx, addr wc
	INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,500,500,NULL,NULL,\
           hInst,NULL
	mov   hwnd,eax
	INVOKE ShowWindow, hwnd,SW_SHOWNORMAL
	INVOKE UpdateWindow, hwnd
	.WHILE TRUE
		INVOKE GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		INVOKE TranslateMessage, ADDR msg
		INVOKE DispatchMessage, ADDR msg
		
	.ENDW
	mov     eax,msg.wParam
	ret
WinMain endp

;____________________________________________________


		
		
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL hdc:HDC
	LOCAL ps:PAINTSTRUCT
	LOCAL rect:RECT
	local hPen:DWORD
	local hBrush:DWORD
	local hOldpen:DWORD
	local hOldbrush:DWORD
	local hSolidbrush:DWORD
	local hOldSolidbrush:DWORD
	local hRedSolidbrush:DWORD
	local hBlackSolidbrush:DWORD
	
	

	;initializare dialogWindow
	.IF uMsg==WM_INITDIALOG
		mov eax,wParam
		RGB 100,100,00
		invoke SetBkColor,eax,White
		invoke GetStockObject,WHITE_BRUSH
		ret
		
	.ELSEIF uMsg==WM_CHAR
        
        push wParam 
        pop  char
 
		;.elseif wParam=="w" || wParam=="W"
        ;	mov eax,acceleration
		;	sub ypos1, eax
		;.if wParam=="s" || wParam=="S" 
        ;    mov eax,acceleration
		;	add ypos1, eax
		
		.if wParam=="a" || wParam=="A"
			mov eax,acceleration
			sub xpos1, eax  
		.elseif wParam=="d" || wParam=="D"
			mov eax,acceleration
			add xpos1, eax
		.elseif wParam=="q" || wParam=="Q"
			dec acceleration
		.elseif wParam=="e" || wParam=="E"
			inc acceleration
		.endif
		
		mov eax,xpos1
		mov xpos2,eax
		add xpos2,100
		
		mov eax,ypos1
		mov ypos2,eax
		add ypos2,20
		
        invoke InvalidateRect, hWnd,NULL,FALSE
		invoke  UpdateWindow,hWnd
		
	.elseif uMsg==WM_MOUSEMOVE
		invoke ShowCursor,FALSE
		invoke GetCursorPos, ADDR mousePos
		mov eax,mousePos.x
		sub eax,140
		mov xpos1,eax
		add eax,100
		mov xpos2,eax
		invoke InvalidateRect, hWnd,NULL,FALSE
		invoke  UpdateWindow,hWnd
		

		
	.elseif uMsg==WM_PAINT
		
		invoke BeginPaint,hWnd,addr ps
		mov hdc,eax
		
		;______________Create Brushes_________________
		RGB 50,50,50
		invoke CreatePen,PS_SOLID,1,eax	;create our pen
		mov hPen,eax
		
		invoke CreateHatchBrush,HS_BDIAGONAL,Red	; our hatch brush
		mov hBrush,eax
		
		RGB 120,120,120
		invoke CreateSolidBrush,eax	;our solid brush
		mov hSolidbrush,eax	
		
		
		invoke CreateSolidBrush,Red	;our solid brush
		mov hRedSolidbrush,eax	
		;____________________________________________
		
		
		
		;______________Clear Screen__________________
		RGB 170,170,170
		invoke CreateSolidBrush,eax	;our solid brush
		mov hBlackSolidbrush,eax
		
		invoke SelectObject,hdc,hBlackSolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,-10,-10,1500,1500
		invoke SelectObject,hdc,hOldSolidbrush
		;___________________________________________
		
	
		;___________Draw racket____________________
		invoke SelectObject,hdc,hSolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,xpos1,ypos1,xpos2,ypos2
		invoke SelectObject,hdc,hOldSolidbrush
		;__________________________________________
		
		
		;___________Draw Ball____________________
		invoke SelectObject,hdc,hRedSolidbrush
		mov hOldSolidbrush,eax
		invoke Ellipse,hdc,ball_x1,ball_y1,ball_x2,ball_y2
		invoke SelectObject,hdc,hOldSolidbrush
		;__________________________________________
		
		
		;invoke SelectObject,hdc,hPen
		;mov eax,hOldpen
		;invoke Ellipse,hdc,110,110,210,210
		;invoke SelectObject,hdc,hOldpen
		
		
		
		;invoke TextOut,hdc,xpos1,ypos1,ADDR acceleration,sizeof acceleration-1
		
		invoke EndPaint,hWnd,addr ps
		
		
	.ELSEIF uMsg==WM_FINISH 
      	invoke MessageBox,NULL,ADDR testString,ADDR AppName,MB_OK 
	
	
	.ELSEIF uMsg==WM_SIZE
		ret 0
	
	.ELSEIF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
		
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp




;__________Game Manager Thread__________

GameThread PROC USES ecx Param:DWORD 
        mov  ecx,900000000
Loop1: 
        add  eax,eax 
        dec  ecx 
        jz   Get_out 
        jmp  Loop1 
Get_out: 
        invoke PostMessage,hwnd,WM_FINISH,NULL,NULL 
        ret 
GameThread ENDP

;______________________________________




ClrScreen macro
		
	RGB 150,150,150
	invoke CreateSolidBrush,eax	;our solid brush
	mov hSolidbrush,eax
	invoke SelectObject,hdc,hSolidbrush
	mov hOldSolidbrush,eax
	invoke Rectangle,hdc,-15,-15,2000,2000
	invoke SelectObject,hdc,hOldSolidbrush

endm



end start
