.386
.model flat, stdcall
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
includelib canvas.lib
extern BeginDrawing: proc
public start
.data
window_title DB "Jocul 2048",0
area_width EQU 640
area_height EQU 720
area DD 0

ok DD 0
randomNumber DD 0
scor DD 0
vector_elemente_joc DD 0,2,0,0,0,0,0,0,0,0,2,0,0,0,0
vector_elemente_reset DD 0,0,0,2,0,0,0,0,2,0,0,0,0,0,0,0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

coord_primul_elem_x EQU 166
coord_primul_elem_y EQU 163

grila_x EQU 120
grila_y EQU 120
table_line_size EQU 100

include digits.inc
include letters.inc

.code
linie_orizontala macro x,y,len,color
local bucla_linie_orizontala
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx,len
bucla_linie_orizontala:
	mov dword ptr [eax],color
	add eax,4
	loop bucla_linie_orizontala
endm

linie_verticala macro x,y,len,color
local bucla_linie_verticala
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx,len
bucla_linie_verticala:
	mov dword ptr [eax],color
	add eax,area_width*4
	loop bucla_linie_verticala
endm

adaugare_cifra_sau_numar macro val,zona,x,y
local cifra2, cifra4, cifra8, numarul16, ,numarul32, numarul64, ,numarul128, numarul256, numarul512, numarul1024, numarul2048, final_macro
	
	mov eax, val
	mov ebx, x
	cmp eax, 0
	jg cifra2
	make_text_macro ' ', zona, ebx, y
	jmp final_macro
cifra2:
	cmp eax, 2
	jg cifra4
	make_text_macro '2', zona, x, y
	jmp final_macro
cifra4:
	cmp eax, 4
	jg cifra8
	make_text_macro '4', zona, x, y
	jmp final_macro
cifra8:
	cmp eax, 8
	jg numarul16
	make_text_macro '8', zona, x, y
	jmp final_macro
numarul16:
	cmp eax, 16
	jg numarul32
	sbb ebx, 5
	make_text_macro '1', zona, ebx, y
	make_text_macro '6', zona, x+5, y
	jmp final_macro
numarul32:
	cmp eax,32
	jg numarul64
	sbb ebx,5
	make_text_macro '3', zona, ebx, y
	make_text_macro '2', zona, x+5, y
	jmp final_macro
numarul64:
	cmp eax,64
	jg numarul128
	sbb ebx,5
	make_text_macro '6', zona, ebx, y
	make_text_macro '4', zona, x+5, y
	jmp final_macro
numarul128:
	cmp eax,128
	jg numarul256
	sbb ebx,10
	make_text_macro '1', zona, ebx, y
	make_text_macro '2', zona, x, y
	add ebx, 20
	make_text_macro '8', zona, ebx, y
	jmp final_macro
numarul256:
	cmp eax,256
	jg numarul512
	sbb ebx,10
	make_text_macro '2', zona, ebx, y
	make_text_macro '5', zona, x, y
	add ebx,20
	make_text_macro '6', zona, ebx, y
	jmp final_macro
numarul512:
	cmp eax,512
	jg numarul1024
	sbb ebx,10
	make_text_macro '5', zona, ebx, y
	make_text_macro '1', zona, x, y
	add ebx,20
	make_text_macro '2', zona, ebx, y
	jmp final_macro
numarul1024:
	cmp eax, 1024
	jg numarul2048
	sbb ebx,15
	make_text_macro '1', zona, ebx, y
	make_text_macro '0', zona, x-5, y
	add ebx,20
	make_text_macro '2', zona, ebx, y
	add ebx,10
	make_text_macro '4', zona, ebx, y
	jmp final_macro
numarul2048:
	sbb ebx,15
	make_text_macro '2', zona, ebx, y
	make_text_macro '0', zona, x-5, y
	add ebx,20
	make_text_macro '4', zona, ebx, y
	add ebx,10
	make_text_macro '8', zona, ebx, y
final_macro:
endm

;Acest macro ne copiaza vectorul de reset in vectorul principal
copy_reset_vector macro v,vaux
local copy_loop
	mov eax,0
	copy_loop:
	mov ecx,vaux[eax]
	mov v[eax],ecx
	add eax,4
	cmp eax,64
	jne copy_loop
endm

;Procedurile de adunare a elementelor(sus, jos, stanga, dreapta)
adunare_stanga proc
	mov ebx, 0
adunare_stanga_loop:
    mov ecx, vector_elemente_joc[ebx + 4]
    cmp vector_elemente_joc[ebx], ecx
    jne incrementari
	cmp ebx, 44
	je incrementari
	cmp ebx, 28
	je incrementari
	cmp ebx, 12
	je incrementari
    shl vector_elemente_joc[ebx], 1
    mov vector_elemente_joc[ebx + 4], 0
incrementari:
    add ebx, 4
    cmp ebx, 56
    jle adunare_stanga_loop

ret 0
adunare_stanga endp

adunare_dreapta proc
	mov ebx, 60
adunare_dreapta_loop:
    mov ecx, vector_elemente_joc[ebx - 4]
    cmp vector_elemente_joc[ebx], ecx
    jne decrementari
	cmp ebx, 48
	je decrementari
	cmp ebx, 32
	je decrementari
	cmp ebx, 16
	je decrementari
    shl vector_elemente_joc[ebx], 1
    mov vector_elemente_joc[ebx - 4], 0
decrementari:
    sub ebx, 4
    cmp ebx, 4
    jge adunare_dreapta_loop

ret 0
adunare_dreapta endp

adunare_sus proc
	mov ebx, 0
adunare_sus_loop:
    mov ecx, vector_elemente_joc[ebx + 16]
    cmp vector_elemente_joc[ebx], ecx
    jne incrementari
    shl vector_elemente_joc[ebx], 1
    mov vector_elemente_joc[ebx + 16], 0
incrementari:
    add ebx, 4
    cmp ebx, 56
    jle adunare_sus_loop

ret 0
adunare_sus endp

adunare_jos proc
	mov ebx, 60
adunare_jos_loop:
    mov ecx, vector_elemente_joc[ebx - 16]
    cmp vector_elemente_joc[ebx], ecx
    jne decrementari
    shl vector_elemente_joc[ebx], 1
    mov vector_elemente_joc[ebx - 16], 0
decrementari:
    sub ebx, 4
    cmp ebx, 4
    jge adunare_jos_loop

ret 0
adunare_jos endp

;Schimbarea elementului
change_element macro x, y ;se muta y in x, y devenind 0
    mov ebx, y
    xor ecx, ecx
    mov y, ecx
    mov x, ebx
endm

;Macro-urile de mutare ale elementelor( sus, jos, stanga, dreapta )
mutare_element_linia2_sus macro x
local exit_macro
	mov eax,x
	mov edx, eax
	add edx, 16
	cmp vector_elemente_joc[edx],0
	je exit_macro
	cmp vector_elemente_joc[edx-16],0
	jne exit_macro
	change_element vector_elemente_joc[edx-16],vector_elemente_joc[edx]
	mov ok,1
exit_macro:
endm

mutare_element_linia3_sus macro x
local exit_macro,if_not_1
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+32],0
	je exit_macro
	cmp vector_elemente_joc[edx+16],0
	jne exit_macro
	cmp vector_elemente_joc[edx],0
	jne if_not_1
	change_element vector_elemente_joc[edx],vector_elemente_joc[edx+32]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+16],vector_elemente_joc[edx+32]
	mov ok,1
exit_macro:
endm

mutare_element_linia4_sus macro x
local exit_macro,if_not_1,if_not_2
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+48],0
	je exit_macro
	cmp vector_elemente_joc[edx+32],0
	jne exit_macro
	cmp vector_elemente_joc[edx+16],0
	jne if_not_2
	cmp vector_elemente_joc[edx],0
	jne if_not_1
	change_element vector_elemente_joc[edx],vector_elemente_joc[edx+48]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+16],vector_elemente_joc[edx+48]
	mov ok,1
if_not_2:
	change_element vector_elemente_joc[edx+32],vector_elemente_joc[edx+48]
	mov ok,1
exit_macro:
endm


mutare_elemente_sus proc
	mutare_element_linia2_sus 0
	mutare_element_linia2_sus 4
	mutare_element_linia2_sus 8
	mutare_element_linia2_sus 12
	
	mutare_element_linia3_sus 0
	mutare_element_linia3_sus 4
	mutare_element_linia3_sus 8
	mutare_element_linia3_sus 12
	
	mutare_element_linia4_sus 0
	mutare_element_linia4_sus 4
	mutare_element_linia4_sus 8
	mutare_element_linia4_sus 12
	ret 0
mutare_elemente_sus endp


mutare_element_linia3_jos macro x
local exit_macro
	mov eax, x
	mov edx, eax
	add edx, 32
	cmp vector_elemente_joc[edx], 0
	je exit_macro
	add edx, 16
	cmp  vector_elemente_joc[edx], 0
	jne exit_macro
	change_element vector_elemente_joc[edx], vector_elemente_joc[edx-16]
	mov ok,1
exit_macro:
endm

mutare_element_linia2_jos macro x
local exit_macro,if_not_1
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+16],0
	je exit_macro
	cmp vector_elemente_joc[edx+32],0
	jne exit_macro
	cmp vector_elemente_joc[edx+48],0
	jne if_not_1
	change_element vector_elemente_joc[edx+48],vector_elemente_joc[edx+16]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+32],vector_elemente_joc[edx+16]
	mov ok,1
exit_macro:
endm

mutare_element_linia1_jos macro x
local exit_macro,if_not_1,if_not_2
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx],0
	je exit_macro
	cmp vector_elemente_joc[edx+16],0
	jne exit_macro
	cmp vector_elemente_joc[edx+32],0
	jne if_not_2
	cmp vector_elemente_joc[edx+48],0
	jne if_not_1
	change_element vector_elemente_joc[edx+48],vector_elemente_joc[eax]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+32],vector_elemente_joc[eax]
	mov ok,1
if_not_2:
	change_element vector_elemente_joc[edx+16],vector_elemente_joc[eax]
	mov ok,1
exit_macro:
endm


mutare_elemente_jos proc
	mutare_element_linia3_jos 0
	mutare_element_linia3_jos 4
	mutare_element_linia3_jos 8
	mutare_element_linia3_jos 12
	
	mutare_element_linia2_jos 0
	mutare_element_linia2_jos 4
	mutare_element_linia2_jos 8
	mutare_element_linia2_jos 12
	
	mutare_element_linia1_jos 0
	mutare_element_linia1_jos 4
	mutare_element_linia1_jos 8
	mutare_element_linia1_jos 12
	ret 0
mutare_elemente_jos endp


mutare_element_coloana2_stanga macro x
local exit_macro
	mov eax,x
	mov edx, eax
	add edx, 4
	cmp vector_elemente_joc[edx],0
	je exit_macro
	cmp vector_elemente_joc[edx-4],0
	jne exit_macro
	change_element vector_elemente_joc[edx-4],vector_elemente_joc[edx]
	mov ok,1
exit_macro:
endm

mutare_element_coloana3_stanga macro x
local exit_macro,if_not_1
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+8],0
	je exit_macro
	cmp vector_elemente_joc[edx+4],0
	jne exit_macro
	cmp vector_elemente_joc[edx],0
	jne if_not_1
	change_element vector_elemente_joc[edx],vector_elemente_joc[edx+8]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+4],vector_elemente_joc[edx+8]
	mov ok,1
exit_macro:
endm

mutare_element_coloana4_stanga macro x
local exit_macro,if_not_1,if_not_2
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+12],0
	je exit_macro
	cmp vector_elemente_joc[edx+8],0
	jne exit_macro
	cmp vector_elemente_joc[edx+4],0
	jne if_not_2
	cmp vector_elemente_joc[edx],0
	jne if_not_1
	change_element vector_elemente_joc[edx],vector_elemente_joc[edx+12]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+4],vector_elemente_joc[edx+12]
	mov ok,1
if_not_2:
	change_element vector_elemente_joc[edx+8],vector_elemente_joc[edx+12]
	mov ok,1
exit_macro:
endm


mutare_elemente_stanga proc
	mutare_element_coloana2_stanga 0
	mutare_element_coloana2_stanga 16
	mutare_element_coloana2_stanga 32
	mutare_element_coloana2_stanga 48
	
	mutare_element_coloana3_stanga 0
	mutare_element_coloana3_stanga 16
	mutare_element_coloana3_stanga 32
	mutare_element_coloana3_stanga 48
	
	mutare_element_coloana4_stanga 0
	mutare_element_coloana4_stanga 16
	mutare_element_coloana4_stanga 32
	mutare_element_coloana4_stanga 48
	ret 0
mutare_elemente_stanga endp


mutare_element_coloana3_dreapta macro x
local exit_macro
	mov eax,x
	mov edx, eax
	add edx, 8
	cmp vector_elemente_joc[edx],0
	je exit_macro
	add edx, 4
	cmp vector_elemente_joc[edx],0
	jne exit_macro
	change_element vector_elemente_joc[edx],vector_elemente_joc[edx-4]
	mov ok,1
exit_macro:
endm

mutare_element_coloana2_dreapta macro x
local exit_macro,if_not_1
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+4],0
	je exit_macro
	cmp vector_elemente_joc[edx+8],0
	jne exit_macro
	cmp vector_elemente_joc[edx+12],0
	jne if_not_1
	change_element vector_elemente_joc[edx+12],vector_elemente_joc[edx+4]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+8],vector_elemente_joc[edx+4]
	mov ok,1
exit_macro:
endm

mutare_element_coloana1_dreapta macro x
local exit_macro,if_not_1,if_not_2
	mov eax,x
	mov edx, eax
	cmp vector_elemente_joc[edx+0],0
	je exit_macro
	cmp vector_elemente_joc[edx+4],0
	jne exit_macro
	cmp vector_elemente_joc[edx+8],0
	jne if_not_2
	cmp vector_elemente_joc[edx+12],0
	jne if_not_1
	change_element vector_elemente_joc[edx+12],vector_elemente_joc[edx]
	mov ok,1
if_not_1:
	change_element vector_elemente_joc[edx+8],vector_elemente_joc[edx]
	mov ok,1
if_not_2:
	change_element vector_elemente_joc[edx+4],vector_elemente_joc[edx]
	mov ok,1
exit_macro:
endm


mutare_elemente_dreapta proc
	mutare_element_coloana3_dreapta 0
	mutare_element_coloana3_dreapta 16
	mutare_element_coloana3_dreapta 32
	mutare_element_coloana3_dreapta 48
	
	mutare_element_coloana2_dreapta 0
	mutare_element_coloana2_dreapta 16
	mutare_element_coloana2_dreapta 32
	mutare_element_coloana2_dreapta 48
	
	mutare_element_coloana1_dreapta 0
	mutare_element_coloana1_dreapta 16
	mutare_element_coloana1_dreapta 32
	mutare_element_coloana1_dreapta 48
	ret 0
mutare_elemente_dreapta endp


;Score-ul
score_increment proc 	
	mov eax,0
scor_loop:
	mov ebx,scor
	cmp vector_elemente_joc[eax],ebx
	jle urmatorul_element
	mov ebx,vector_elemente_joc[eax]
	mov scor,ebx
urmatorul_element:
	add eax,4
	cmp eax,64
	jne scor_loop
	ret 0
score_increment endp 


;Terminarea jocului(daca nu s-a ajuns la numarul 2048)
game_over proc			
	mov eax,0
game_over_loop:
	cmp vector_elemente_joc[eax],0
	je end_proc
	add eax,4
	cmp eax,64
	jne game_over_loop
	linie_orizontala area_width * 4, area_height, table_line_size * 4, 0 ;da crash la program(ca sa ne spuna ca am castigat jocul / am pierdut jocul)
	mov scor,0
end_proc:
	ret 0
game_over endp

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - s-a scurs intervalul fara click, 2 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] 
	cmp eax, 3
	jz evt_tastatura 
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_tastatura:
	mov eax, [ebp+arg2]
	cmp eax,'R'
	je buton_reset
	
	;Sagetile cu care ne miscam in joc
	cmp eax,'&'
	je sageata_sus
	cmp eax,'%'
	je sageata_stanga
	cmp eax,'('
	je sageata_jos
	cmp eax,27h
	je sageata_dreapta
	jmp afisare_litere

sageata_sus:
	mov ok,0
	call mutare_elemente_sus
	call adunare_sus
	cmp ok,1
	jne afisare_litere
	jmp adaugare_piesa_joc

sageata_jos:
	mov ok,0
	call mutare_elemente_jos
	call adunare_jos
	cmp ok,1
	jne afisare_litere
	jmp adaugare_piesa_joc

sageata_stanga:
	mov ok,0
	call mutare_elemente_stanga
	call adunare_stanga
	cmp ok,1
	jne afisare_litere
	jmp adaugare_piesa_joc

sageata_dreapta:
	mov ok,0
	call mutare_elemente_dreapta
	call adunare_dreapta
	cmp ok,1
	jne afisare_litere
	jmp adaugare_piesa_joc

adaugare_piesa_joc:

	call score_increment	
	mov eax, 0
generate_number2_loop:
	cmp vector_elemente_joc[eax], 0
	jne next_element
	cmp randomNumber, 2
	je generate_number4
	mov vector_elemente_joc[eax], 2
	inc randomNumber
	jmp afisare_litere
next_element:
	add eax, 4
	cmp eax, 60
	jle generate_number2_loop
	jmp afisare_litere
generate_number4:
	mov vector_elemente_joc[eax], 4
	mov randomNumber, 0
	
;Aici compar scorul(daca scor = 2048 => se termina jocul)	
	cmp scor, 2048
	je finish_game
	jmp afisare_litere
finish_game:
	linie_orizontala area_width * 4, area_height, table_line_size * 4, 0  ;da crash la program(ca sa ne spuna ca am castigat jocul/l-am pierdut)
	jmp afisare_litere
	
buton_reset:
	mov scor,0
	mov eax, 0
initializare_0:
	mov vector_elemente_joc[eax], 0
	add eax, 4
	cmp eax, 64
	jne initializare_0
	copy_reset_vector vector_elemente_joc,vector_elemente_reset
	
afisare_litere:

	call game_over 
	
	;Adaugarea elementelor pe tabla de joc
	adaugare_cifra_sau_numar vector_elemente_joc[0], area, coord_primul_elem_x, coord_primul_elem_y
	adaugare_cifra_sau_numar vector_elemente_joc[4], area, coord_primul_elem_x + 100, coord_primul_elem_y
	adaugare_cifra_sau_numar vector_elemente_joc[8], area, coord_primul_elem_x + 200, coord_primul_elem_y
	adaugare_cifra_sau_numar vector_elemente_joc[12], area, coord_primul_elem_x + 300, coord_primul_elem_y
	
	adaugare_cifra_sau_numar vector_elemente_joc[16], area, coord_primul_elem_x, coord_primul_elem_y + 100
	adaugare_cifra_sau_numar vector_elemente_joc[20], area, coord_primul_elem_x + 100, coord_primul_elem_y + 100
	adaugare_cifra_sau_numar vector_elemente_joc[24], area, coord_primul_elem_x + 200, coord_primul_elem_y + 100
	adaugare_cifra_sau_numar vector_elemente_joc[28], area, coord_primul_elem_x + 300, coord_primul_elem_y + 100
	
	adaugare_cifra_sau_numar vector_elemente_joc[32], area, coord_primul_elem_x, coord_primul_elem_y + 200
	adaugare_cifra_sau_numar vector_elemente_joc[36], area, coord_primul_elem_x + 100, coord_primul_elem_y + 200
	adaugare_cifra_sau_numar vector_elemente_joc[40], area, coord_primul_elem_x + 200, coord_primul_elem_y + 200
	adaugare_cifra_sau_numar vector_elemente_joc[44], area, coord_primul_elem_x + 300, coord_primul_elem_y + 200
	
	adaugare_cifra_sau_numar vector_elemente_joc[48], area, coord_primul_elem_x, coord_primul_elem_y + 300
	adaugare_cifra_sau_numar vector_elemente_joc[52], area, coord_primul_elem_x + 100, coord_primul_elem_y + 300
	adaugare_cifra_sau_numar vector_elemente_joc[56], area, coord_primul_elem_x + 200, coord_primul_elem_y + 300
	adaugare_cifra_sau_numar vector_elemente_joc[60], area, coord_primul_elem_x + 300, coord_primul_elem_y + 300
	
	;scriem un mesaj( in cazul meu, se va afisa Proiect 2048 )
	make_text_macro 'P', area, 250, 50
	make_text_macro 'R', area, 260, 50
	make_text_macro 'O', area, 270, 50
	make_text_macro 'I', area, 280, 50
	make_text_macro 'E', area, 290, 50
	make_text_macro 'C', area, 300, 50
	make_text_macro 'T', area, 310, 50
	make_text_macro '2', area, 340, 50
	make_text_macro '0', area, 350, 50
	make_text_macro '4', area, 360, 50
	make_text_macro '8', area, 370, 50
	
	;Afisor scor
	make_text_macro 'S', area, 270, 530
	make_text_macro 'C', area, 280, 530
	make_text_macro 'O', area, 290, 530
	make_text_macro 'R', area, 300, 530
	make_text_macro 'E', area, 310, 530
	make_text_macro ' ', area, 320, 530
	adaugare_cifra_sau_numar scor,area, 350, 530
	
	;Tabla de joc
	linie_orizontala grila_x, grila_y + table_line_size, table_line_size * 4, 0
	linie_verticala grila_x + table_line_size, grila_y, table_line_size * 4, 0

	linie_orizontala grila_x, grila_y + table_line_size * 2, table_line_size * 4, 0
	linie_verticala grila_x + table_line_size * 2, grila_y, table_line_size * 4, 0
	
	linie_orizontala grila_x, grila_y + table_line_size * 3, table_line_size * 4, 0
	linie_verticala grila_x + table_line_size * 3, grila_y, table_line_size * 4, 0
	
	linie_orizontala grila_x, grila_y, table_line_size * 4, 0
	linie_verticala grila_x, grila_y, table_line_size * 4, 0
	
	linie_orizontala grila_x, grila_y + table_line_size * 4, table_line_size * 4, 0
	linie_verticala grila_x + table_line_size * 4, grila_y, table_line_size * 4, 0
	
	;Mesaj Reset
	make_text_macro 'P',area, 180, 580
	make_text_macro 'R',area, 190, 580
	make_text_macro 'E',area, 200, 580
	make_text_macro 'S',area, 210, 580
	make_text_macro 'S',area, 220, 580
	
	make_text_macro 'R',area, 240, 580
	
	make_text_macro 'T',area, 260, 580
	make_text_macro 'O',area, 270, 580
	
	make_text_macro 'R',area, 290, 580
	make_text_macro 'E',area, 300, 580
	make_text_macro 'S',area, 310, 580
	make_text_macro 'T',area, 320, 580
	make_text_macro 'A',area, 330, 580
	make_text_macro 'R',area, 340, 580
	make_text_macro 'T',area, 350, 580
	
	make_text_macro 'T',area, 370, 580
	make_text_macro 'H',area, 380, 580
	make_text_macro 'E',area, 390, 580
	
	make_text_macro 'G',area, 410, 580
	make_text_macro 'A',area, 420, 580
	make_text_macro 'M',area, 430, 580
	make_text_macro 'E',area, 440, 580
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;terminarea programului
	push 0
	call exit
end start