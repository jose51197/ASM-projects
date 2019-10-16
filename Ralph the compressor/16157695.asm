; Jose Pablo Gonzalez Alvarado 
; 2016157695 
; Kirstein Gätjens
; Instituto tecnológico de Costa Rica 
; Escuela de computacion 
; Arquitectura de computadores
;

; Manual
; 16157695 las opciones son -d para comprimir, -c para comprimir, las opciones no son Case Sensitive
; Si no se dijita ninguna opcion se va a desplegar la ayuda
; La ayuda tambien puede desplegarse por medio del comando -a o -A
; El programa recibe despues de un espacio el nombre del archivo a tratar
; Se desplegara mensajes de error especificos al fallo ocurrido
; En la salida estandar se dara una lista de los caracteres mas repetidos
; Ademas se provee al usuario de un porcentaje de compresion
; Se reporta en la salida estandar el tamano viejo y nuevo del archivo
; El nombre nuevo del archivo es el mismo del de entrada con la extension correspondiente 
;
; Analisis de resultados:
; Documentacion                                                         A 
; Convertir de INT a ASCII para desplegar                               A
; Deteccion de errores con especificacion                               A
; Comprimir el archivo                                                  A
; Descomprimir el archivo                                               A
; Ponerle el nombre al archivo                                          A
; Detectar la extension del archivo                                     A
; Asignar la extension a archivos de salida                             A
; Asignar extensiones de archivos inherentes                            A
; Creacion de archivos                                                  A
; Recorrer archivos                                                     A
; Ordenamiento de numeros(algoritmo inspirado en ordenamiento burbuja)  A
; Manejo de numeros flotantes(porcentaje)                               A
; 
;

datos segment
;variables que voy a usar para ordenar las apariciones, cada una va a contener un caracter y la cantidad de veces, 36 para no invadir territorio ajeno
apariciones dw 36 dup(?)
;variables de ayuda del programa
;voy a usar esta vara para meter todos los valores, 260 solo por si acaso, no es necesario podria ser 256 pero soy paranoico :P
contadorDeApariciones dw 260 dup (?)

ayuda0 db "Ayuda del programa",10,13,'$'
ayuda1 db "Utilice -c,-C para comprimir el archivo",10,13,"Utilice -d,-D para descomprimir el archivo",10,13,"Utilice -a,-A para desplegar este mensaje",10,13,'$'
;ayuda ends 
;mini acercaDe
acerca db 13,10,"*Vale por un mensaje de exito*",13,10,"Jose Pablo Gonzalez Alvarado",13,10,"2016157695, Arquitectura, Tarea de ASM",'$'
;acerca ends 

abundantes db "Caracteres mas abundantes:$"
;variables para el proc convertir a decimal, recibe el numero en ax 
numero db 128 dup(?)
;decimal ends
espacios db "           $"

nombreArchivo db 128 dup (?)
extension db 0
handl dw ?
handlN dw ?
buffy db ?
buffyW dw ?
comandoInvalido db "Comando invalido",'$'
archivoNoValido db "Archivo no valido",10,13,'$'
modo db 0; modo 0 es comprimir, modo 1 es descomprimir

;estas tres no se pueden separar
header db "RLP"
LasElegidas db 15 dup (?)
cantidadBytes dw 0;cuenta los bytes del archivo antes de comprimirlo
fix db 0;nunca la voy a usar, es para poder coger 21 de golpe y avanzar de una
cantidadBytesC dw 20;cuenta los bytes del compreso, empieza en 20 por los headers y lo demas que se escribe al principio
elPorcentaje db "Tasa de compresion: $"
elABytes db "Tamano sin comprimir: $"
elDBytes db "Tamano compreso: $"
bytes db " bytes",10,13,'$'
nible db (?); para la funcion codigos me regrese el nible respectivo a escribir
aEscribir db (9)
seDescomprimio db "Se ha descomprimido el archivo ingresado$"
huboPuntote db 0
datos ends

pila segment stack 'stack'
dw 512 dup (?)
pila ends

codigo segment
assume cs:codigo, ds:datos, ss:pila
inicio:
	mov ax, datos
	mov ds, ax
	mov ax, pila
	mov ss, ax
	mov si, 82h; para empezar a leer un caracter a la derecha
	
;aqui empieza el pedazo(de carnita)
;revision de como empieza lo que metieron
cmp byte ptr es:[si],'-'
je decision
cmp byte ptr es:[si],0;significa que esta vacia
je ayudita
jmp ecomando

decision:
inc si
cmp byte ptr es:[si],'C'
je comp
cmp byte ptr es:[si],'c'
je comp
cmp byte ptr es:[si],'D'
je dcomp
cmp byte ptr es:[si],'d'
je dcomp
cmp byte ptr es:[si],'A'
je help
cmp byte ptr es:[si],'a'
je help
jmp ecomando

help:
inc si
cmp byte ptr es:[si],13
jne ecomando
ayudita:
mov ah,09h
lea dx, ayuda0
int 21h
lea dx, ayuda1
int 21h
jmp final

comp:
inc si
cmp byte ptr es:[si],' '
jne ecomando
inc si
jmp carnita

dcomp:
inc si
cmp byte ptr es:[si],' '
jne ecomando
inc si
inc modo
jmp carnita

ecomando: 
mov ah,09h;instruccion de imprimir
lea dx, comandoInvalido
int 21h
jmp final

;aqui lo que seria el main :P
carnita:
call colocarNombre; de DOS a string terminado en 0
cmp modo,1
je elOtroModo

;modo comprimir :) , terminado 
call abrir;abre y cuenta las apariciones
call contar;organiza la lista apariciones
call imprimirMasUsados; imprime al usuario los mas usados
call Elegidas;para hacer una lista de los caracteres que mas aparecen
call compresor
call PorcentajeCompresion;para desplegar el resultado final
jmp final




;esto queda por implementar
elOtroModo:
call descomprimir
jmp final

descomprimir proc near
	jmp empezarDescompresion
	noAbrio2:
	mov ah,09h;instruccion de imprimir
	lea dx, archivoNoValido
	int 21h
	jmp final
	
	empezarDescompresion:
	;abro el archivo
	lea dx,nombreArchivo
	mov ax, 3d00h
	int 21h
	jc noAbrio2
	mov handl,ax
	;leo el archivo
	
	xor si,si 
	cambiarExtensionAtxt:
	inc si
	cmp nombreArchivo[si],'.'
	jne cambiarExtensionAtxt
	inc si 
	mov nombreArchivo[si],'t'
	inc si 
	mov nombreArchivo[si],'x'
	inc si 
	mov nombreArchivo[si],'t'
	inc si 
	mov nombreArchivo[si],'$'
	
	
	
	;hasta aqui ya bautizamos a nuestro nuevo archivo de texto
	mov ax,3c00h
	xor cx,cx
	lea dx, nombreArchivo
	int 21h
	;el archivo de texto ha sido creado
	mov handlN,ax;handleN es el nuevo archivo, le escribo con aEscribir
	mov cantidadBytesC,0
	
	
	
	mov ax, 3F00h
	mov bx,handl
	mov cx,20;para guardar los caracteres mas usados
	lea dx,header
	int 21h
	cmp ax,0; si ax es 0 no se leyo nada
	je descomprimio
	
	rlpATxt:
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo 1 byte en buffy
	
	
	cmp ax,0; si ax es 0 no se leyo nada
	je descomprimio
	
	
	;cantidadBytesC es la cantidad de bytes que he escrito
	
	
	
	mov al, buffy;muevo el caracter al al
	mov cx,4
	shiftRBuffy:;shr para que quede 0000xxxx
	shr al,1
	loop shiftRBuffy
	
	cmp al,1111b;codigo de lo que sigue esta sin comprimir
	je DnoComprimible1
	
	call obtenerCaracter
	mov aEscribir,al
	call escribir
	
	
	
	codigo2:
	mov ax, cantidadBytes
	cmp ax,cantidadBytesC
	je descomprimio
	
	mov al, buffy;muevo el caracter al ah
	and al, 00001111b; para que queden los ultimos 4
	cmp al,1111b
	je DnoComprimible2
	
	call obtenerCaracter
	mov aEscribir,al
	call escribir
	
	yaDEscribio:;es una variable para que todas las 4 posibilidades terminen aqui
	;para mover el puntero a los siguiente bytes
	mov ax, 4201h
	xor cx,cx
	xor dx,dx
	int 21h
	jmp rlpATxt
	
	
	descomprimio:;cerrar archivo 
	mov ax,0900h
	lea dx, seDescomprimio
	int 21h
	call linea
	ret
	DnoComprimible1:
	mov al, buffy
	mov cx,4
	shiftLal:
	shl al,1
	loop shiftLal
	mov aEscribir,al
	mov ax, 4201h
	xor cx,cx
	xor dx,dx
	int 21h
	
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo el siguiente byte en buffy
	
	mov al,buffy
	
	mov cx,4
	shiftRal:
	shr al,1
	loop shiftRal
	
	or aEscribir,al
	call escribir
	jmp codigo2
	
	
	
	DnoComprimible2:
	;apunto al siguiente byte
	mov ax, 4201h
	xor cx,cx
	xor dx,dx 
	int 21h
	
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo el siguiente byte en buffy
	
	mov al,buffy
	mov aEscribir,al
	call escribir
	jmp yaDEscribio
	
	
endp 

obtenerCaracter proc near ;recibe un codigo en al y devuelve caracter en al
xor si,si
xor ah,ah
mov si,ax
mov al,byte ptr LasElegidas[si]
ret
endp

;calcula e imprime cuanto se comprimio un archivo, afecta ax y bx y dx y si
PorcentajeCompresion proc near ;tamanoos sin comprimir y compreso
	mov ax,cantidadBytes
	call convertir
	mov ax,0900h
	lea dx, elABytes
	int 21h
	lea dx, numero
	int 21h
	lea dx,bytes
	int 21h 
	mov ax,cantidadBytesC
	call convertir
	mov ax,0900h
	lea dx, elDBytes
	int 21h
	lea dx, numero
	int 21h
	lea dx,bytes
	int 21h 
	xor dx,dx
	mov ax,cantidadBytesC
	mov bx,10000
	mul bx;ax por 100, resultado en dx:ax
	mov bx,cantidadBytes
	div bx;ahora en ax tengo el numero
	call convertir;ahora la var numero contiene el porcentaje
	mov ax,0900h
	lea dx, elPorcentaje
	int 21h
	mov ah, 02h
	xor si,si
	imprimirPorcentaje:
	cmp byte ptr numero[si+2],'$'
	je puntito
	cmp byte ptr numero[si],'$'
	je finishPorcentaje
	huboPuntito:
	mov dl, byte ptr numero[si]
	int 21h
	inc si
	jmp imprimirPorcentaje
	finishPorcentaje:
	mov dl, '%'
	int 21h
	call linea
	ret 
	puntito:
	cmp huboPuntote,0
	jne huboPuntito
	inc huboPuntote
	mov dl, '.'
	int 21h
	jmp huboPuntito
endp
compresor proc near
	;creamos un archivo con el nombre del otro con extension 
	xor si,si 
	cambiarExtension:
	inc si
	cmp nombreArchivo[si],'.'
	jne cambiarExtension
	inc si 
	mov nombreArchivo[si],'r'
	inc si 
	mov nombreArchivo[si],'l'
	inc si 
	mov nombreArchivo[si],'p'
	inc si 
	mov nombreArchivo[si],'$'

	mov ax,3c00h
	xor cx,cx
	lea dx, nombreArchivo
	int 21h
	mov handlN,ax;handleN es el nuevo archivo

	xor si,si
	
	;leo el archivo anterior desde el principio(al en 0)
	mov ax, 4200h
	mov bx,handl
	xor cx,cx
	xor dx,dx
	int 21h
	
	
	mov ax,4000h
	mov bx,handlN
	mov cx,20;escribo el rlp-repeticiones-bytes en el archivo
	lea dx, header;de header para abajo estan todos esos datos
	int 21h
	;en este punto el puntero deberia estar listo para seguir escribiendo

leerYEscribir:
	jmp brinquito
	FueEscritoTodo:
	ret
	
	brinquito:
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo 1 byte en buffy
	
	cmp ax,0; si ax es 0 no se leyo nada
	je FueEscritoTodo
	
	;le muevo buffy a ah para comparar los bytes
	mov ah,buffy
	call codigos;llamo a codigos con el primer codigo en ah, me lo regresa en ah
	
	;una vez que tengo el codigo lo pongo en los 4 mas significativos de ah
	mov cx,4
	siginificativosAH1:
	shl ah, 1
	loop siginificativosAH1; en ah me queda xxxx0000
	
	mov aEscribir,ah;le meto el codigo de 4 bits
	
	cmp aEscribir,11110000b;datos no comprimibles han sido encontrados
	je escribirTodo1
	
	escribioTodo1:
	;para mover el puntero al siguiente byte
	mov ax, 4201h
	xor cx,cx
	xor dx,dx 
	int 21h
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo el byte en buffy
	
		
	mov ah,buffy
	call codigos;llamo a codigos con el primer codigo en ah, me lo regresa en ah
	
	or aEscribir,ah;le meto el codigo de 4 bits restante
	push ax;para ver que era despues
	call escribir;escribo los codigos
	pop ax
	
	cmp ah,1111b;si ya lo habia escrito escribo el resto
	je escribirTodo2
	
	yaEscribio:;es una variable para que todas las 4 posibilidades terminen aqui
	;para mover el puntero a los siguiente bytes
	mov ax, 4201h
	xor cx,cx
	xor dx,dx 
	int 21h
	jmp leerYEscribir
	
	
	escribirTodo2:; en este escribo el codigo faltante 
	
	mov al,buffy;buffy contiene lo que busco
	mov aEscribir,al
	call escribir
	
	jmp yaEscribio
	
	
	;si el primero codigo de cuatro bits es 1111
	escribirTodo1:;en este punto aEscribir contiene 11110000 y esta listo
	;para mover el puntero a los siguiente bytes
	;buffy ya contiene la primera parte, no hay necesidad de llamarlo de nuevo
	mov ah,buffy;ah contiene en lo bajo lo que busco 
	and ah,11110000b; mantengo los mas siginificativos
	mov cx,4
	
	mantenerSignificativos:
	shr ah,1
	loop mantenerSignificativos
	
	add aEscribir,ah ;ah va a tener en sus bajos 4 bits
	;a escribir contiene 1111xxxx donde xxxx es la primera parte del codigo a escribir
	call escribir
	
	mov ah, buffy
	and ah,00001111b;mantengo los mas significativos
	
	mov cx,4
	corrimientoLAH:
	shl ah,1
	loop corrimientoLAH
	
	mov aEscribir,ah;a escribir contiene 4 bits seguidos de 0000
	jmp escribioTodo1;termine esa parte :P

	
endp 

;escribe el contenido de aEscribir en el archivo
escribir proc near
;escribo 8 bits al archivo
	push ax
	push bx
	push cx 
	push dx
	mov ax,4000h
	mov bx,handlN
	mov cx,1
	lea dx, aEscribir
	int 21h
	mov aEscribir,0
	inc cantidadBytesC
	;listo
	pop dx
	pop cx
	pop bx 
	pop ax
	ret 
endp

;recibe una letra en ah y retorna en ah su codigo
codigos proc near
	xor si,si 
	xor al,al
	busqueda:
	cmp byte ptr LasElegidas[si],ah
	je iguales
	inc si 
	cmp si,1111b ;si se llego a este codigo no se encontro
	jne busqueda
	iguales:
	mov ax,si
	xchg ah,al
	ret 
endp 

Elegidas proc near 
	xor si,si 
	inc si
	xor di,di
	moverElegidas:
	add si,4
	mov ax, word ptr apariciones[si]
	mov byte ptr LasElegidas[di],ah
	inc di
	cmp di,15
	je seleccionNatural
	jmp moverElegidas	
	seleccionNatural:
	ret 
endp 

;convertir es totalmente funcional, recibe el numero en ax
convertir Proc near
	xor di,di
	mov bx,10
	xor cx,cx
	dividir:
	xor dx,dx
	div bx
	push dx
	inc cx
	cmp ax,10
	jnb dividir
	add ax, 30h
	mov byte ptr numero[di], al
	inc di
	montar:
	pop ax
	add ax, 30h
	mov byte ptr numero[di], al
	inc di
	loop montar
	mov byte ptr numero[di], '$'; le meto el asciiDolar para terminar
	ret
endp

;Cuenta las apariciones de una letra, el ascii de la letra es su posicion /2
contar proc near
	xor di,di
	xor dx,dx 
	mov bx,2
	contador:
	mov ax,dx
	push dx 
	mul bx
	pop dx
	mov di,ax
	mov ax,word ptr contadorDeApariciones[di]
	;en este punto ax contiene el numero de apariciones y dx el caracter
	push dx
	call ordenar
	pop dx
	inc dx
	cmp dx,257
	je contoTodos
	jmp contador
	contoTodos:
	ret
endp 

;funciona!!
colocarNombre Proc near
	xor di,di
	seguir:
	mov al,byte ptr es:[si]
	mov byte ptr nombreArchivo[di],al
	inc di
	inc si 
	cmp al,'.'
	je punto
	huboExtension:
	cmp byte ptr es:[si],13
	jne seguir
	cmp extension,1
	jne ponertxt
	
	terminar:
	mov byte ptr nombreArchivo[di],0
	ret
	
	punto:
	mov extension,1
	jmp huboExtension
	
	ponertxt:
	cmp modo,1
	je anadirRLP
	mov byte ptr nombreArchivo[di],'.'
	inc di
	mov byte ptr nombreArchivo[di],'t'
	inc di
	mov byte ptr nombreArchivo[di],'x'
	inc di
	mov byte ptr nombreArchivo[di],'t'
	inc di
	jmp terminar
	
	anadirRLP:
	mov byte ptr nombreArchivo[di],'.'
	inc di
	mov byte ptr nombreArchivo[di],'R'
	inc di
	mov byte ptr nombreArchivo[di],'L'
	inc di
	mov byte ptr nombreArchivo[di],'P'
	inc di
	jmp terminar
endp

abrir Proc near
	push ax
	push bx
	push cx
	push dx
	;abro el archivo
	lea dx,nombreArchivo
	mov ax, 3d00h
	int 21h
	jc noAbrio
	mov handl,ax
	;leo el archivo
	leer:
	mov ax, 3F00h
	mov bx,handl
	mov cx,1
	lea dx,buffy
	int 21h;aqui ya tengo caracter en buffy
	cmp ax,0; si ax es 0 no se leyo nada 
	je abrio	
	xor si,si
	xor ah,ah
	mov al,buffy
	mov bx,2
	mul bx
	add si,ax
	inc word ptr contadorDeApariciones[si]
	inc cantidadBytes
	mov ax, 4201h
	xor cx,cx
	xor dx,dx 
	int 21h	
	jmp leer
	abrio:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	noAbrio:
	mov ah,09h;instruccion de imprimir
	lea dx, archivoNoValido
	int 21h
	jmp final
endp 

;agarra la lista apariciones y la imprime a consola
imprimirMasUsados proc near
	push ax
	push dx
	mov ah,09h;instruccion de imprimir
	mov si,0
	mov ax,0900h;instruccion de imprimir hasta $
	lea dx, abundantes
	int 21h
	call linea
	siguienteCaracter:
	add si,4
	
	mov ax,0200h;imprimir caracter 
	mov dx, apariciones[si+2]
	cmp dx,33
	jb hashtag
	int 21h
	mov dx,' '
	int 21h
	eraMenor:
	int 21h
	mov ax,0900h;instruccion de imprimir hasta $
	lea dx, espacios
	int 21h
	
	mov ax,apariciones[si]
	call convertir
	mov ax,0900h
	lea dx, numero
	int 21h
	call linea
	cmp si,60
	je dejarDeImprimir
	jmp siguienteCaracter
	
	hashtag:
	mov ax,dx
	call convertir
	;imprimo el hastag 
	mov ax,0200h;imprimir caracter
	mov dx,'#'
	int 21h
	;imprimo el numero
	mov ax,0900h;instruccion de imprimir hasta $
	lea dx, numero
	jmp eraMenor
	dejarDeImprimir:
	pop dx
	pop ax
	ret
endp 

;recibe el numero en ax y el caracter en dx decide donde colocarlo al encontrar un numero mayor a el
;funciona!!
ordenar proc near
	push ax
	push dx
	xor di,di
	mov si,60
	seguirOrdenando:
	cmp ax,word ptr apariciones[si]
	jae cambiar
	cambio:
	sub si,4;bajo dos words
	cmp si,0
	je ordeno
	jmp seguirOrdenando
	ordeno:
	pop dx 
	pop ax
	ret
	cambiar:
	xchg ax,word ptr apariciones[si];guardo el actual en ax y lo cambio por ax
	mov word ptr apariciones[si+4],ax
	mov ax,word ptr apariciones[si]
	xchg dx,word ptr apariciones[si+2];guardo el actual en ax y lo cambio por ax
	mov word ptr apariciones[si+6],dx
	mov dx,word ptr apariciones[si+2]
	jmp cambio
endp

linea proc near 
	mov ah, 02h
	mov dl, 13; retorno de carro
	int 21h
	mov dl, 10; cambio de linea 
	int 21h 
	mov ah,09h
	ret
endp


final:
;cierro los archivos
xor al,al
mov  ah, 3eh
mov  bx, handlN
int  21h  
mov  ah, 3eh
mov  bx, handl
int  21h 
mov ax,0900h
lea dx, acerca
int 21h
mov ax, 4C00h
int 21h
codigo ends
end inicio