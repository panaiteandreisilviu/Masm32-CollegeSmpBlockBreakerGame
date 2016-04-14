DrawBlocks macro
	
	invoke SelectObject,hdc,hSolidbrush
	mov hOldSolidbrush,eax
	
	mov esi,0 ;loop counter
	mov edi,50 ;horizontal position offset
	drawRow1:
		
		;check if block has been destroyed
		mov ebx, OFFSET blocks_row1 ; base pointer
		mov eax, [ebx + esi*4]      ; get value from array (ebx is base pointer, esi is offset)		
		cmp eax,0
		jz skipDraw1
				
		mov eax,esi
		mul edi ;edi*esi
		
		add eax,blockOffset
		mov ebx,eax; x1
		add eax,edi
		sub eax,blockOffset
		mov ecx,eax; x2
		
		mov eax,row1BottomY; y2
		mov edx ,row1BottomY
		sub edx ,rowOffset ;y1
		invoke Rectangle,hdc,ebx,edx,ecx,eax
		
		skipDraw1:
		inc esi
		cmp esi,8
	jbe drawRow1
	
	
	
	mov esi,0 ;loop counter
	mov edi,50 ;horizontal position offset
	drawRow2:
		
		;mov edi, OFFSET bl		;check if block has been destroyed
		mov ebx, OFFSET blocks_row2 ; base pointer
		mov eax, [ebx + esi*4]      ; get value from array (ebx is base pointer, esi is offset)		
		cmp eax,0
		jz skipDraw2
		
		mov eax,esi
		mul edi ;edi*esi
		
		add eax,blockOffset
		mov ebx,eax; x1
		add eax,edi
		sub eax,blockOffset
		mov ecx,eax; x2
		
		mov eax,row2BottomY; y2
		mov edx ,row2BottomY
		sub edx ,rowOffset ;y1
		invoke Rectangle,hdc,ebx,edx,ecx,eax
		
		skipDraw2:
		inc esi
		cmp esi,8
	jbe drawRow2
	
	
	
	mov esi,0 ;loop counter
	mov edi,50 ;horizontal position offset
	drawRow3:
		
		;mov edi, OFFSET bl		;check if block has been destroyed
		mov ebx, OFFSET blocks_row3 ; base pointer
		mov eax, [ebx + esi*4]      ; get value from array (ebx is base pointer, esi is offset)		
		cmp eax,0
		jz skipDraw3
		
		mov eax,esi
		mul edi ;edi*esi
		
		add eax,blockOffset
		mov ebx,eax; block.x1
		add eax,edi
		sub eax,blockOffset
		mov ecx,eax; block.x2
		
		mov eax,row3BottomY; y2
		mov edx ,row3BottomY
		sub edx ,rowOffset ;y1
		invoke Rectangle,hdc,ebx,edx,ecx,eax
		
		skipDraw3:
		inc esi
		cmp esi,8
	jbe drawRow3
	
			

	;invoke Rectangle,hdc,0,0,50,20
	;invoke Rectangle,hdc,50,0,100,20
	;invoke Rectangle,hdc,100,0,150,20
	;invoke Rectangle,hdc,150,0,200,20
	;invoke Rectangle,hdc,200,0,250,20
	;invoke Rectangle,hdc,250,0,300,20
	;invoke Rectangle,hdc,300,0,350,20
	;invoke Rectangle,hdc,350,0,400,20
	;invoke Rectangle,hdc,400,0,450,20
	
	
	
	invoke SelectObject,hdc,hOldSolidbrush
endm