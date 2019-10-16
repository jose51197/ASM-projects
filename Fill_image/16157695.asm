; Jose Pablo Gonzalez Alvarado 
; 2016157695 
; Kirstein Gätjens
; Instituto tecnológico de Costa Rica 
; Escuela de computacion 
; Arquitectura de computadores
; 
; El programa recibe por linea de comandos un archivo en formato bmp 
; y lo despliega en pantalla, despues se le provee con un cursor 	
; con el cual puede seleccionar por medio del click izquierdo el lugar 
; a rellenar con el color insertado en la llamada al programa
; 
; Despliegue de imagen A
; Relleno de imagen B
; Paso de parametros por pila E(no implementado, overflow)
; Despliegue de la ayuda A
; Documentacion interna A
; Manejo del mouse A
; Despliegue del mouse B
; 



datos segment
	nombreArchivo db 128 dup(?)
	handl dw (?)
	buffy db ?
	fila dw 479
	columna dw 0
	relleno dw 1
	
	er db "Error en linea de comandos, revise$"
	er2 db "Archivo invalido$"
	ayuda db "Ayuda del programa",10,13
	      db "Ingrese de parametros el nombre del archivo a abrir y el color",10,13
		  db "Ejemplo: programa a.bmp 2",10,13
		  db "Solo se permiten colores del 0 al 15",10,13
		  db "El bmp debe ser de 640 x 480",10,13
		  db "Jose Gonzalez, 2016157695","$"
datos ends

pila segment stack 'stack'
	dw 32767 dup (?); quien sabe que puede pasar :P
pila ends

codigo segment
assume cs:codigo, ds:datos, ss:pila

inicio:
	mov ax, datos
	mov ds, ax
	mov ax, pila
	mov ss, ax
	
	mov si, 81h
	xor di,di
	cmp byte ptr es:[8*16],0; si no hay nada tire la ayuda
	je ayudita
	jmp leer
	
	erro:
	mov ax,0900h
	lea dx,er
	int 21h
	jmp yaValio
	
	ayudita:
	mov ax,0900h
	lea dx,ayuda
	int 21h
	jmp yaValio
	
	leer:
	inc si
	cmp byte ptr es:[si],20h;ya tiene el archivo y la extension
	je extension
	
	cmp byte ptr es:[si],0
	je erro
	
    mov al, byte ptr es:[si]
	mov byte ptr nombreArchivo[di],al
	inc di
	jmp leer
	
	extension:
	mov byte ptr nombreArchivo[di],0
	
	inc si
	
	mov ah, byte ptr es:[si]
	
	inc si
	cmp byte ptr es:[si],13
	jne dosDigitos
	sub ah, 30h
	mov byte ptr relleno[0], ah
	cmp byte ptr relleno[0], 9; si solo es un digito no puede ser mayor a 9
	ja erro
	jmp importante
	
	dosDigitos:
	mov al, byte ptr es:[si]
	sub ah, 30h
	sub al, 30h
	mov byte ptr relleno[0], al
	add byte ptr relleno[0],10
	cmp byte ptr relleno[0],15
	ja erro
;hasta aqui la linea de comandos
	
	
	
	
	
	;parte importante
	importante:	
	call cargarArchivo; funciona perfecto siguiendo bgr en vez de rgb
	
	mov ax,0; reseteo de mouse
	int 33h
	
	mov ax,1;mostrar
	int 33h
	mov ax, 3
	
	
	mouse:
	xor bx,bx
	int 33h
	cmp bx, 1
	jne mouse
	
	call plaga	
	mov ax, 3
	
	jmp mouse
	
	jmp yaValio

plaga proc near
	;aqui pone los dos pixeles obtenidos
		mov ax,2
		int 33h
		mov ah, 0dh
		xor bx,bx
		int 10h
		mov byte ptr relleno[1],al		
		call pixel
		
		mov ax,0; reseteo de mouse
		int 33h
		
		xor bx,bx
		mov ax,1;mostrar
		int 33h	
ret 
endp

pixel proc near
	
	mov ah, 0dh
	int 10h; obtengo el color
	
	cmp al, byte ptr relleno[1]
	jne regreso; si no es el que toco regrese
	
	cmp al, byte ptr relleno[0]; para ahorrar algo de pila, si ese pixel ya esta de ese color
	je regreso
	
	;validaciones para que no pase ninguna estupidez
	cmp cx, 640
	ja regreso
	
	cmp dx, 480
	ja regreso
	
	;momento de recursividad
	mov ah, 0ch
	mov al, byte ptr relleno[0]; di si llego aqui es porque es de igual color al tocado
	int 10h; lo pintare	
	
	inc dx
	call pixel;arriba
	dec dx
	
	dec cx
	call pixel;izquierda
	inc cx
	
	inc cx
	call pixel;derecha
	dec cx
	
	dec dx
	call pixel;abajo
	inc dx
regreso:
ret
endp

;dibuja la imagen en pantalla
cargarArchivo proc near
	push ax
	push bx 
	push cx
	push dx
	
	jmp abriendo
	noAbrio2:
	mov ax,0900h
	lea dx,er2
	int 21h
	jmp yaValio
	
	abriendo:
	lea dx,nombreArchivo
	mov ax, 3d00h
	int 21h
	jc noAbrio2
	mov handl,ax
	;en este punto ya tengo el archivo cargado
	mov ax, 12h; modo de video a 16 colores 640 x 480
	int 10h ;hasta aqui bien en teoria
	;moverme a offset donde esta el otro offset
	mov bx, handl
	mov ax, 4200h;aumento el puntero a esa posicion con base al principio del archivo
	xor cx,cx
	mov dx,0ah; el offset al cual moverme
	int 21h
	
	;cargo el offset del comienzo del archivo
	mov ax, 3F00h
	mov cx,1; cantidad de bytes a leer
	lea dx,buffy
	int 21h;aqui ya tengo caracter en buffy
	
	; aqui tengo en buffy el offset que ocupo
	mov ax, 4200h;aumento el puntero a esa posicion con base al principio del archivo
	xor cx,cx
	xor dh,dh; el offset al cual moverme
	mov dl,buffy;
	int 21h
	; aqui ya estoy en la carnita del archivo
	
	
	xor bh,bh; en 0 para pagina
	
	cargaPixeles:
		mov ax, 3F00h
		mov cx,1; cantidad de bytes a leer
		lea dx,buffy
		int 21h;aqui ya tengo caracter en buffy
		cmp ax,0; si ax es 0 no se leyo nada
		je abrio
		
		;aqui pone los dos pixeles obtenidos
		mov ah,0ch
		mov al, buffy;color
		and al, 11110000b; color obtenido1
		ror al,4
		call bgr
		mov cx, columna
		mov dx, fila
		int 10h
		inc columna
		

		mov al, buffy;color
		and al, 00001111b; color obtenido
		call bgr
		mov cx, columna
		mov dx, fila
		int 10h
		inc columna
		
		
		
		;para subir digamos
		cmp columna, 640
		jne cambio
		dec fila
		mov columna,0
	
	cambio:
		mov ax, 4201h;aumento el puntero
		xor cx,cx
		xor dx,dx
		int 21h
	jmp cargaPixeles
	
	abrio:
	pop dx
	pop cx 
	pop bx
	pop ax
	ret
	
endp

;es la rutina que me normaliza los colores de un bmp
bgr proc near
	push ax
	and al,00000100b;dejo nada mas el "rojo" rgb
	cmp al,100b
	je hayRojo
	
	pop ax
	push ax
	
	and al,00000001b; para nada mas dejar el "azul"
	cmp al, 1; hay azul y no rojo
	jne losDos
	
	pop ax
	and al, 11111110b
	or al,  00000100b; pongo el "azul" en lugar del rojo
	
	
	jmp cambiado
	
	hayRojo:
	pop ax
	push ax
	
	and al,00000001b; para nada mas dejar el azul
	cmp al, 1
	je losDos
	
	pop ax
	and al, 11111010b;quito el azul
	or al,  00000001b; pongo el rojo
	jmp cambiado
	
	losDos:
	pop ax

cambiado:
ret
endp
yaValio:
	mov ax, 4c00h
	int 21h
codigo ends
end inicio