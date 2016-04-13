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
include blocks.asm

.data
ClassName db "Proiect SMP",0
AppName  db "Proiect SMP",0
OurText  db "Sisteme cu MicroProcesoare",0

MsgBoxCaption  db "Game Over",0
MsgBoxText       db "Press OK to restart.",0


WM_FINISH equ WM_USER+100h

click db "Brush and pen",0
hatch db "hatched brush",0
Solid db "Solid Pen",0
brush db "Solid brush",0
testString db "Sisteme cu MicroProcesoare",0

playerString db "Player :  ",0

pointsString db "Points  ",0

racket_x1 dd 200
racket_y1 dd 435
racket_x2 dd 300
racket_y2 dd 445

ball_x1 dd 245
ball_x2 dd 260
ball_y1 dd 400
ball_y2 dd 385

blocks_row1 dd  1,1,1,1,1,1,1,1,1
blocks_row2 dd  1,1,1,1,1,1,1,1,1
blocks_row3 dd  1,1,1,1,1,1,1,1,1

ball_speed_x dd 5
ball_speed_y dd 5

acceleration dd 10

char WPARAM 9

blockOffset dd 3

rowOffset dd 20
row1BottomX dd 90
row2BottomX dd 120
row3BottomX dd 150



mousePos POINT <>
.data?
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwnd HANDLE ?
ThreadID DWORD ?

;hOldSolidbrush DWORD ? ;might fix memory leak?
;hOldpen:DWORD

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
           CW_USEDEFAULT,472,500,NULL,NULL,\
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
	local hGraySolidbrush:DWORD
	
	

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
		;	sub racket_y1, eax
		;.if wParam=="s" || wParam=="S" 
        ;    mov eax,acceleration
		;	add racket_y1, eax
		
		.if wParam=="a" || wParam=="A"
			mov eax,acceleration
			sub racket_x1, eax  
		.elseif wParam=="d" || wParam=="D"
			mov eax,acceleration
			add racket_x1, eax
		.elseif wParam=="q" || wParam=="Q"
			;mov edi, OFFSET blocks_row1
			;mov eax, [edi]     ; get number from warray			
			;mov racket_x1,eax;
			;dec acceleration
		.elseif wParam=="e" || wParam=="E"
			;mov edi, OFFSET blocks_row1
			;mov eax, [edi + 4]     ; get number from warray			
			;mov racket_x1,eax;
			;inc acceleration
		.endif
		
		mov eax,racket_x1
		mov racket_x2,eax
		add racket_x2,100
		
		mov eax,racket_y1
		mov racket_y2,eax
		add racket_y2,10
		
        invoke InvalidateRect, hWnd,NULL,FALSE
		invoke  UpdateWindow,hWnd
		
	.elseif uMsg==WM_MOUSEMOVE
		invoke ShowCursor,FALSE
		invoke GetCursorPos, ADDR mousePos
		mov eax,mousePos.x
		
		sub eax,140 ;centering cursor to racket
		
		mov racket_x1,eax
		add eax,100
		mov racket_x2,eax
		invoke InvalidateRect, hWnd,NULL,FALSE
		invoke  UpdateWindow,hWnd
		

		
	.elseif uMsg==WM_PAINT
		
		invoke BeginPaint,hWnd,addr ps
		mov hdc,eax
		
		
		;FIX ME CLEAR BRUSHES AFTER END PAINT
		
		;______________Create Brushes____________
		RGB 50,50,50
		invoke CreatePen,PS_SOLID,1,eax	;create our pen
		mov hPen,eax
		
		;invoke CreateHatchBrush,HS_BDIAGONAL,Red	; our hatch brush
		;mov hBrush,eax
		
		RGB 120,120,120
		invoke CreateSolidBrush,eax	;our solid brush
		mov hSolidbrush,eax
		
		
		invoke CreateSolidBrush,Red	;our solid brush
		mov hRedSolidbrush,eax	
		;________________________________________
		
		
		
		;______________Clear Screen______________
		RGB 170,170,170
		invoke CreateSolidBrush,eax	;our solid brush
		mov hGraySolidbrush,eax
		
		invoke SelectObject,hdc,hGraySolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,-10,-10,700,700
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;______________Header____________________
		RGB 90,90,90
		invoke CreateSolidBrush,eax	;our solid brush
		mov hGraySolidbrush,eax
		
		invoke SelectObject,hdc,hGraySolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,0,0,470,40
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		RGB    230,230,230
        invoke SetTextColor,hdc,eax
        RGB    90,90,90
        invoke SetBkColor,hdc,eax
		invoke TextOut,hdc,10,15,addr playerString,sizeof playerString-1
		
		invoke TextOut,hdc,350,15,addr pointsString,sizeof pointsString-1
		

		
		
	
		;___________Draw racket__________________
		invoke SelectObject,hdc,hSolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,racket_x1,racket_y1,racket_x2,racket_y2
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;__________Draw Blocks___________________
		DrawBlocks
		;________________________________________
		
		
		;___________Draw Ball____________________
		invoke SelectObject,hdc,hRedSolidbrush
		mov hOldSolidbrush,eax
		invoke Ellipse,hdc,ball_x1,ball_y1,ball_x2,ball_y2
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;invoke SelectObject,hdc,hPen
		;mov eax,hOldpen
		;invoke Ellipse,hdc,110,110,210,210
		;invoke SelectObject,hdc,hOldpen
		
		
		;invoke TextOut,hdc,racket_x1,racket_y1,ADDR acceleration,sizeof acceleration-1
		
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
	
GameLoop: 

	;aplly movement to ball
	mov eax,ball_speed_x
    sub ball_x1,eax;
    sub ball_x2,eax;
	
	mov eax,ball_speed_y
    sub ball_y1,eax;
    sub ball_y2,eax;
    
    
    ;__________Change Ball Direction_______
    cmp ball_x1,0
	jbe changeXDir
	
	cmp ball_x1,446
	jae changeXDir
    
    cmp ball_y1,50
	jbe changeYTopDir  
    
    cmp ball_y1,440
	jae changeYBottomDir
    ;_____________________________________
    
    ;_______Check for ball racket collision
    
    ;_____________________________________	
    invoke Sleep, 16 ;60FPS
    invoke InvalidateRect, hwnd,NULL,FALSE
	invoke  UpdateWindow,hwnd
	
LOOP GameLoop

        
changeYTopDir:
	;change y movement
	mov ebx,-1
	mov eax,ball_speed_y
	mul ebx
	mov ball_speed_y,eax
jmp  GameLoop
	

changeYBottomDir:
	mov ecx,racket_x1
	mov edx,racket_x2
	sub ecx,10
	add edx,10
	
	;check if ball is outside of racket area
	;cmp ball_x1,ecx
	;jbe gameOver
	
	;cmp ball_x1,edx
	;jae gameOver
	
	
	;change y movement
	mov ebx,-1
	mov eax,ball_speed_y
	mul ebx
	mov ball_speed_y,eax
jmp  GameLoop

changeXDir: 
	mov ebx,-1
	mov eax,ball_speed_x
	mul ebx
	mov ball_speed_x,eax
jmp  GameLoop



gameOver:
	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
	jmp resetGame
LOOP gameOver

resetGame:

	mov racket_x1,200
	mov racket_y1,435
	mov racket_x2,300
	mov racket_y2,445
	
	mov ball_x1,245
	mov ball_x2,260
	mov ball_y1,400
	mov ball_y2,385
	
	mov ball_speed_x,5
	mov ball_speed_y,5
	
	
	mov acceleration,10

	jmp GameLoop
LOOP resetGame
	
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
