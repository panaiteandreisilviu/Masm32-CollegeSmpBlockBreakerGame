
;*************************************************************************
;
;		Proiect Laborator Sisteme cu MicroProcesoare
;		
;		Panaite Andrei Silviu 331AB
;
;		14 aprilie 2016
;
;		https://github.com/panaiteandreisilviu/Proiect-SMP
;
;*************************************************************************


;Nota: Doresc sa continui dezvoltarea programului astfel ca am decis ca
;	   notele si comentariile sa fie in engleza.

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
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include blocks.asm

include    masm32.inc
includelib masm32.lib
include    debug.inc
includelib debug.lib
   

.data
ClassName db "Proiect SMP",0
AppName  db "Proiect SMP",0
OurText  db "Sisteme cu MicroProcesoare",0
MsgBoxCaption  db "Game Over",0
MsgBoxCaption2  db "You Won!",0
MsgBoxText       db "Press OK to Restart.",0

WM_FINISH equ WM_USER+100h

testString db "Sisteme cu MicroProcesoare",0

;game data
playerString db "Player 1  ",0

pointsString db "Points  ",0

BlockHit db "Sounds/block_hit.wav",0
WallHit db "Sounds/wall_hit.wav",0

points dd 0

racket_x1 dd 200
racket_y1 dd 435
racket_x2 dd 300
racket_y2 dd 445

ball_x1 dd 15
ball_x2 dd 30
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
row1BottomY dd 90
row2BottomY dd 120
row3BottomY dd 150

;mouse position coordinates
mousePos POINT <>

.data?
hInstance HINSTANCE ?
CommandLine LPSTR ? ;command line handle (not used)
hwnd HANDLE ? ;window handle
ThreadID DWORD ?
szKey db 13 dup(?) ;for dword to ascii

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
	
	;message loop
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




		
;____________Message Proccessing procedure___________
		
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
	local hGray2Solidbrush:DWORD
	
	

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
			;mov eax, [edi]    			
			;mov racket_x1,eax;
			;dec acceleration
		.elseif wParam=="e" || wParam=="E"
			;mov edi, OFFSET blocks_row1
			;mov eax, [edi + 4] 		
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
		
		
		;______________Create Brushes____________
		RGB 50,50,50
		invoke CreatePen,PS_SOLID,1,eax	;border gray pen
		mov hPen,eax
		
		RGB 90,90,90
		invoke CreateSolidBrush,eax	;top header brush
		mov hGraySolidbrush,eax
		
		RGB 170,170,170
		invoke CreateSolidBrush,eax	;background/clear screen brush
		mov hGray2Solidbrush,eax
		
		RGB 120,120,120
		invoke CreateSolidBrush,eax	;racket brush
		mov hSolidbrush,eax
		
		invoke CreateSolidBrush,Red	;ball brush
		mov hRedSolidbrush,eax	
		;________________________________________
		
		
		;______________Clear Screen______________
		
		invoke SelectObject,hdc,hGray2Solidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,-10,-10,700,700
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;______________Header____________________
		
		invoke SelectObject,hdc,hGraySolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,0,0,470,40
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		
		;_________Draw window text_______________
		
		RGB    230,230,230
        invoke SetTextColor,hdc,eax
        RGB    90,90,90
        invoke SetBkColor,hdc,eax
		invoke TextOut,hdc,10,15,addr playerString,sizeof playerString-1
		
		invoke TextOut,hdc,350,15,addr pointsString,sizeof pointsString-1
		
		invoke dwtoa, points, ADDR szKey
		;dwtoa DWORD to ASCII 
		;(converts a dword string to a printable ascii string)
		invoke TextOut,hdc,400,15,addr szKey,sizeof szKey-1
		;invoke SetDlgItemText,hWnd,IDC_KEY,ADDR szKey 
		
		;________________________________________
		
	
		;___________Draw racket__________________
		invoke SelectObject,hdc,hSolidbrush
		mov hOldSolidbrush,eax
		invoke Rectangle,hdc,racket_x1,racket_y1,racket_x2,racket_y2
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;__________Draw Top Blocks_______________
		DrawBlocks ;Blocks.asm
		;________________________________________
		
		
		;___________Draw Ball____________________
		invoke SelectObject,hdc,hRedSolidbrush
		mov hOldSolidbrush,eax
		invoke Ellipse,hdc,ball_x1,ball_y1,ball_x2,ball_y2
		invoke SelectObject,hdc,hOldSolidbrush
		;________________________________________
		
		
		;__________Clear Brushes_________________
		invoke DeleteObject,hSolidbrush
		invoke DeleteObject,hRedSolidbrush
		invoke DeleteObject,hGraySolidbrush
		invoke DeleteObject,hGray2Solidbrush
		invoke DeleteObject,hRedSolidbrush
		invoke DeleteObject,hOldSolidbrush
		invoke DeleteObject,hPen
		invoke DeleteObject,hOldpen
		;_______________________________________
		
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

;_______________________________________





;__________Game Manager Thread__________

GameThread PROC USES ecx Param:DWORD 
	
	
;_________Game Logic loop_______________
GameLoop: 

	;apply movement to ball
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
    
    
    
    ;_______Check for block collision_____
    
    mov eax,row1BottomY
	cmp ball_y1,eax
	je row1Collision
	
	mov eax , row2BottomY
	cmp ball_y1,eax
	je row2Collision
	
	mov eax , row3BottomY
	cmp ball_y1,eax
	je row3Collision
    ;_____________________________________
    
    
    ;________Check for game win___________
    
    mov ecx, OFFSET blocks_row1
    mov edx, OFFSET blocks_row2
    mov edi, OFFSET blocks_row3
    mov eax,0 ;loop counter
    mov ebx,0 ; win flag
    
    checkGameWin:
		;calculates sum of block row arrays
		;if sum is zero game has been won
    	add ebx,[ecx + eax*4]
		add ebx,[edx + eax*4]
		add ebx,[edi + eax*4]
		inc eax
    	cmp eax,8
    jbe checkGameWin
    
    ;PrintDec ebx
    
    cmp ebx,0
    jz gameWin
    ;_____________________________________
	
    
    
    invoke Sleep, 16 ;60FPS
    invoke InvalidateRect, hwnd,NULL,FALSE
	invoke  UpdateWindow,hwnd
	
jmp GameLoop


;_________Change ball direction___________
        
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
	cmp ball_x1,ecx
	jbe gameOver
	
	cmp ball_x1,edx
	jae gameOver
		
	invoke PlaySound, ADDR WallHit, NULL,SND_FILENAME or SND_ASYNC
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
	invoke PlaySound, ADDR WallHit, NULL,SND_FILENAME or SND_ASYNC
jmp  GameLoop

;____________________________________


;_________Ball Row collision_________
row3Collision:
	mov eax,0
	mov ebx,50
	mov ecx,ball_x1
	
	cmp ecx,50 ;ugly fix
	jb lessThan50_3
	calculateOffset3:
	sub ecx,50
	inc eax
	cmp ecx,50
	ja calculateOffset3
	
	
	lessThan50_3:
	mov ecx, OFFSET blocks_row3 ; base pointer
	mov edx,1
	cmp [ecx + eax*4],edx
	je collisionDetected3
	
	jmp GameLoop
	
	
	collisionDetected3:
		add points,10
		mov edx,0
		mov [ecx + eax*4],edx     ; get value from array
		invoke PlaySound, ADDR BlockHit, NULL,SND_FILENAME or SND_ASYNC
		jmp changeYTopDir
		
jmp GameLoop


row2Collision:

mov eax,0
	mov ebx,50
	mov ecx,ball_x1
	
	cmp ecx,50 ;ugly fix
	jb lessThan50_2
	calculateOffset2:
	sub ecx,50
	inc eax
	cmp ecx,50
	ja calculateOffset2
	
	lessThan50_2:
	mov ecx, OFFSET blocks_row2 ; base pointer
	mov edx,1
	cmp [ecx + eax*4],edx
	je collisionDetected2
	
	jmp GameLoop
	
	
	collisionDetected2:
		add points,10
		mov edx,0
		mov [ecx + eax*4],edx     ; get value from array
		invoke PlaySound, ADDR BlockHit, NULL,SND_FILENAME or SND_ASYNC
		jmp changeYTopDir

jmp GameLoop


row1Collision:

mov eax,0
	mov ebx,50
	mov ecx,ball_x1
	
	cmp ecx,50 ;ugly fix
	jb lessThan50_1
	calculateOffset1:
	sub ecx,50
	inc eax
	cmp ecx,50
	ja calculateOffset1
	lessThan50_1:
	
	mov ecx, OFFSET blocks_row1 ; base pointer
	mov edx,1
	cmp [ecx + eax*4],edx
	je collisionDetected1
	
	jmp GameLoop
	
	
	collisionDetected1:
		add points,10
		mov edx,0
		mov [ecx + eax*4],edx     ; get value from array
		invoke PlaySound, ADDR BlockHit, NULL,SND_FILENAME or SND_ASYNC
		jmp changeYTopDir
		

jmp GameLoop

;___________________________________




gameOver:
	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
	mov points,0
	jmp resetGame
LOOP gameOver

gameWin:
	invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption2, MB_OK
	jmp resetGame
LOOP gameWin

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
	
	;Reset row block 1
	mov eax,0
	mov edx,1
	resetBlockRow1:
	mov ecx, OFFSET blocks_row1 ; base pointer
	mov [ecx + eax*4],edx
	inc eax
	cmp eax,8 ;number of iterarions
	jbe resetBlockRow1
	
	;Reset row block 2
	mov eax,0
	mov edx,1
	resetBlockRow2:
	mov ecx, OFFSET blocks_row2 ; base pointer
	mov [ecx + eax*4],edx
	inc eax
	cmp eax,8 ;number of iterarions
	jbe resetBlockRow2
	
	;Reset row block 3
	mov eax,0
	mov edx,1
	resetBlockRow3:
	mov ecx, OFFSET blocks_row3 ; base pointer for array
	mov [ecx + eax*4],edx
	inc eax
	cmp eax,8 ;number of iterarions
	jbe resetBlockRow3
	
	jmp GameLoop
jmp resetGame
	
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
