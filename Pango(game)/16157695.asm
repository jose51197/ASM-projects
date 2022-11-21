; Jose Pablo Gonzalez Alvarado 
; 2016157695 
; Kirstein Gätjens
; Instituto tecnológico de Costa Rica 
; Escuela de computacion 
; Arquitectura de computadores
; 
;
; Manual De usuario
; El siguiente programa de ahora en adelante referenciado como juego trata de un pinguino muy violento, 
; el pinguino patea bloques que se desplazan hasta salirse de la pantalla
; Hay ciertas reglas:
; 	* A teresa la mata el oso, el objetivo del juego es reunir las tres X.            
; 	* Puede patear diamantes y bloques, es la pinguina mas violenta existente.         
; 	* Los bloques, diamantes y teresa se pueden caer por los bordes. 
;	* Se pierde si se cae un diamante o teresa.               
;	* Los que no se sientan preparados pueden usa la S para pasar el nivel.           
;	* Se puede detener al oso algunos turnos golpeandolo con un bloque.
;
; Controles:                                                                      
; 	[space] Patear [esc] Salir [f1] Ayuda [alt-a] Acerca de [s o S] saltar nivel      
;	[+] Mas velocidad [-] Menos velocidad                                           
;
; Analisis de resultados:
; Documentacion                                                         A
; Funciones auxiliares 													A
; Deteccion de errores especificos										A
; Movimiento de teresa                 									A
; Movimiento del oso             										A
; Agendado de movimientos pendientes									A
; Deteccion de niveles invalidos										A
; Cerebro del oso(Basico)            									A
; Despliegue de pausa           										A
; Despliegue de acerca de       										A
; Deteccion de victoria                           						A
; Deteccion de derrota		 											A
; Deteccion de oso			      										A
; Deteccion de pango	  												A
; Generacion de colores													A
; Carga de archivo 														A
; Paso de niveles 														A
; Manejo de patadas														A

datos segment
handl dw 0
archivoNoValido db "Archivo no valido",10,13,'$'
nombreArchivo db "000.pgo",0
buffy db 0
color db 1
nops1 dw 2000
nops2 dw 30
turnosched db 0
pango dw 0; la localizacion del pinguino
oso dw 0;la localizacion del oso
nivel dw 0
dirpango db 0
movspendientes dw 256 dup (0); para almacenar bloques en movimiento en formato donde y direccion
indicemovs dw 0; para manejar los movimientos
turnoOso db 0
direccion dw 0;guarda la ultima tecla tocada
charsLeidos db 0
diamantes db 0
osos db 0
pangos db 0
charanterior db 0
perdedor db "      $$$$$$$                                             $$                    "
         db "      $$    $$                                            $$                    "
         db "      $$    $$   $$$$$$    $$$$$$    $$$$$$    $$$$$$   $$$$$$     $$$$$$       "
         db "      $$    $$  $$    $$  $$    $$  $$    $$  $$    $$    $$            $$      "
         db "      $$    $$  $$$$$$$$  $$        $$        $$    $$    $$       $$$$$$$      "
         db "      $$    $$  $$        $$        $$        $$    $$    $$  $$  $$    $$      "
         db "      $$$$$$$    $$$$$$$  $$        $$         $$$$$$      $$$$    $$$$$$$      "
			 
ganador db  "      $$     $$  $$              $$                          $$                 "
        db  "      $$     $$                  $$                                             "
        db  "      $$     $$  $$   $$$$$$$  $$$$$$     $$$$$$    $$$$$$   $$   $$$$$$        "
        db  "       $$   $$   $$  $$          $$      $$    $$  $$    $$  $$        $$       "
        db  "        $$ $$    $$  $$          $$      $$    $$  $$        $$   $$$$$$$       "
        db  "         $$$     $$  $$          $$  $$  $$    $$  $$        $$  $$    $$       "
        db  "          $      $$   $$$$$$$     $$$$    $$$$$$   $$        $$   $$$$$$$       "
		
ayuda   db  "            .S_sSSs     .S_SSSs     .S_sSSs      sSSSSs    sSSs_sSSs            "
        db  "           .SS~YS%%b   .SS~SSSSS   .SS~YS%%b    d%%%%SP   d%%SP~YS%%b           "
        db  "           S%S   `S%b  S%S   SSSS  S%S   `S%b  d%S'      d%S'     `S%b          "
        db  "           S%S    S%S  S%S    S%S  S%S    S%S  S%S       S%S       S%S          "
        db  "           S%S    d*S  S%S SSSS%S  S%S    S&S  S&S       S&S       S&S          "
        db  "           S&S   .S*S  S&S  SSS%S  S&S    S&S  S&S       S&S       S&S          "
        db  "           S&S_sdSSS   S&S    S&S  S&S    S&S  S&S       S&S       S&S          "
        db  "           S&S~YSSY    S&S    S&S  S&S    S&S  S&S sSSs  S&S       S&S          "
        db  "           S*S         S*S    S&S  S*S    S*S  S*b `S%%  S*b       d*S          "
        db  "           S*S         S*S    S*S  S*S    S*S  S*S   S%  S*S.     .S*S          "
        db  "           S*S         S*S    S*S  S*S    S*S   SS_sSSS   SSSbs_sdSSS           "
        db  "           S*S         SSS    S*S  S*S    SSS    Y~YSSY    YSSP~YSSY            "
        db  "           SP                 SP   SP                                           "
        db  "           Y                  Y    Y                                            "
		db  "                 Y la venganza del oso                                          "
		db  "                 Una historia de robos, patadas y maltrato animal               "
		
elEnter db  "                          Aprete enter para comenzar                            "
reintentoenter db  "                         Aprete enter para reintentar                           "
controles db"Controles:                                                                      "
          db"[space] Patear [esc] Salir [f1] Ayuda [alt-a] Acerca de [s o S] Soy debil       "
          db"[+] Mas velocidad [-] Menos velocidad                                           "
acerca   db "            Nombre: Jose Pablo Gonzalez Alvarado Carnet:2016157695              "
         db "                                 Niveles: 85-89                                 "
		 db "                           Jueguito de Teresa y el oso                          "
easteregg db"                              Se puede patear al oso en las o y cambian de color"
instrucc db "A teresa la mata el oso, el objetivo del juego es reunir las tres X.            "
		 db "Puede patear diamantes y bloques, es la pinguina mas violenta existente.        " 
		 db "Los bloques, diamantes y teresa se pueden caer por los bordes.                  "
		 
		 db "Se pierde si se cae un diamante o teresa.                                       "
		 db "Los que no se sientan preparados pueden usa la S para pasar el nivel.           "
		 db "Se puede detener al oso algunos turnos golpeandolo con un bloque.               "
Amalo    db "        Archivo invalido, revise que el nivel cumpla con las limitaciones       "
		 db "                   Aprete enter para cargar el siguiente nivel                  "


screen db 4160 dup(?); reservo la memoria para la matriz del archivo
porsiacaso db 2000 dup(?)
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
	mov ax, 0b800h;direccion de memoria de video
    mov es, ax ; se la mandamos al es
	xor ax,ax; para nada mas hacer copy paste de esto despues
	push 65000;para condicion de parada de limpiar la pila
	
	
	call superpangobros
	call reinicio
	recargar:
	call cargarArchivo
	call verificar
	juego:
	call pausa
	call movimientopango
	call superoso
	call dibujarPantalla
	call victoria
	call buscapango
	call matopinguino; para ver que teresa no se murio
	call teclas
	call scheduler
	call bruto
	jmp juego
	
bruto proc near
mov diamantes,0
push si
xor si,si
mov cx,2000
diamantitos2:
	cmp byte ptr screen[si],"X"
	jne lingotes2
	inc diamantes
lingotes2:	
inc si
inc si
loop diamantitos2
cmp diamantes,3
jne fallo2
pop si
ret 
fallo2:
call baboso
endp

verificar proc near;verifica que solo haya un oso, tres diamantes y un pango, ademas de que un diamante no este en una esquina,call archivoMalo
push si
push cx
xor si,si
mov cx, 2000
ositos:
	cmp byte ptr screen[si],"Q"
	jne osotes
	inc osos
osotes:	
inc si
inc si
loop ositos
cmp osos,1
ja fallo
xor si,si
mov cx,2000
panguitos:
	cmp byte ptr screen[si],"&"
	jne pangotes
	inc pangos
pangotes:	
inc si
inc si
loop panguitos
cmp pangos,1
ja fallo

xor si,si
mov cx,2000
diamantitos:
	cmp byte ptr screen[si],"X"
	jne lingotes
	inc diamantes
lingotes:	
inc si
inc si
loop diamantitos
cmp diamantes,3
jne fallo

cmp byte ptr screen[0],"X"
je fallo
cmp byte ptr screen[158],"X"
je fallo
cmp byte ptr screen[3840],"X"
je fallo
cmp byte ptr screen[3098],"X"
je fallo
pop cx
pop si
ret
fallo:
call archivoMalo
endp

matopinguino proc near
push cx
push si
mov cx,2000
xor si,si
buscarpinguinovivo:
	cmp byte ptr screen[si],"&"
	je pinguinovivo
	inc si
	inc si
loop buscarpinguinovivo
call baboso
pinguinovivo:
pop si
pop cx
ret
endp

reinicio proc near
	vaciandoPila:
		pop ax
		cmp ax,65000
		je pilavacia
	jmp vaciandoPila
	
	pilavacia:
	mov cx, 2000
	xor si,si
	pantallitavacia:
		mov word ptr screen[si],0020h
		inc si
		inc si
	loop pantallitavacia
	push 65000
	mov charanterior,0
	mov turnosched,0
	mov dirpango,0
	mov osos,0
	mov direccion,0
	mov oso,0
	mov pangos,0
	mov diamantes,0
	xor si,si
	deshaciendomovs:
	cmp byte ptr movspendientes[0],0
	je sinmovs
	
	call mover
	jmp deshaciendomovs
	sinmovs:
	jmp recargar
endp

teclas proc near 
    mov ah,01;hay pendiente alguna tecla?
	int 16h
	jz nomenos
	xor ax, ax;cual tecla esta pendiente? en ah los scan codes, en al los asciis
	int 16h
	teclitas:
	cmp ah,72;tecla de arriba
	jne noarriba
	call arriba
	
	noarriba:
	cmp ah,80;tecla de abajo
	jne noabajo
	call abajo
	
	noabajo:
	cmp ah,75;tecla de izquierda
	jne noizquierda
	call izquierda
	
	noizquierda:
	cmp ah,77;tecla de derecha
	jne noderecha
	call derecha
	
	noderecha:
	cmp ah,30;alt-a o acercaDe
	jne noacerk
	call acerk
	
	noacerk:
	cmp ah,59;ayuda
	jne noayudita
	call ayudita
	
	noayudita:
	cmp al,27;escape
	jne noescape
	jmp final
	
	noescape:
	cmp al,32;space
	jne nospace
	call patear
	
	nospace:
	cmp al,115;debilucho
	je sisiguiente
	cmp al,83;debilucho
	jne nosiguiente
	sisiguiente:
	call siguiente
	
	nosiguiente:
	cmp al,43;+
	jne nomas
	cmp nops2,1
	je nomas
	dec nops2
	
	nomas:
	cmp al,45;-
	jne nomenos
	inc nops2
	nomenos:
ret
endp


movimientopango proc near
	cmp dirpango,0
	je pateoGolpeo
	cmp direccion,72;arriba
	jne noseguirarriba
	call arriba
	noseguirarriba:
	
	cmp direccion,80;abajo
	jne noseguirabajo
	call abajo
	noseguirabajo:
	
	cmp direccion,75;izquierda
	jne noseguirizq
	call izquierda
	noseguirizq:
	
	cmp direccion,77;derecha
	jne noseguirder
	call derecha
	noseguirder:
	
	pateoGolpeo:
	ret
endp
arriba proc near
	push si
	push ax
	cmp direccion,72;si ya esta viendo en esta direccion mover, sino nada mas indicar mov
	je moverarriba
	mov direccion,72
	mov dirpango,0
	jmp nopuedearriba
	
	moverarriba:
	mov si, pango
	cmp si,160
	jb suicidioarriba
	cmp byte ptr screen[si-160]," ";el campo a moverse
	jne nopuedearriba
	
	mov dirpango,1
	mov ax, word ptr screen[si];la posicion de pango
	mov word ptr screen[si-160], ax;siguiente bloque
	mov word ptr screen[si]," "
	sub pango,160
	
nopuedearriba:
pop ax
pop si
ret
suicidioarriba:
pop ax
pop si
pop ax;para borrar la direccion que quedo en la pila y mantenerla  limpia
call perdio
endp

perdio proc near
xor si,si
call linea
call baboso
inutil:
jmp inutil
pop ax 
jmp inicio
endp

abajo proc near
push si
	push ax
	cmp direccion,80;si ya esta viendo en esta direccion mover, sino nada mas indicar mov
	je moverabajo
	mov direccion,80
	mov dirpango,0
	jmp nopuedeabajo
	
	moverabajo:
	mov si, pango
	cmp si,3840
	ja suicidioabajo
	cmp byte ptr screen[si+160]," ";el campo a moverse
	jne nopuedeabajo
	
	mov dirpango,1
	mov ax, word ptr screen[si];la posicion de pango
	mov word ptr screen[si+160], ax;siguiente bloque
	mov word ptr screen[si]," "
	add pango,160
	
nopuedeabajo:
pop ax
pop si
ret
suicidioabajo:
pop ax
pop si
pop ax;para borrar la direccion que quedo en la pila y mantenerla  limpia
call perdio
endp

izquierda proc near
	push si
	push ax
	push bx
	push dx
	cmp direccion,75;si ya esta viendo en esta direccion mover, sino nada mas indicar mov
	je moverizquierda
	mov direccion,75
	mov dirpango,0
	jmp nopuedeizquierda
	
	moverizquierda:
	mov si, pango
	mov bx,160
	xor dx,dx
	mov ax,si
	div bx
	cmp dx,0
	je suicidioizquierda
	
	cmp byte ptr screen[si-2]," "
	jne nopuedeizquierda
	
	mov dirpango,1
	mov ax, word ptr screen[si];la posicion de pango
	mov word ptr screen[si-2], ax;siguiente bloque
	mov word ptr screen[si]," "
	dec pango
	dec pango
	
nopuedeizquierda:
pop dx
pop bx
pop ax
pop si
ret
suicidioizquierda:
pop ax;para borrar la direccion que quedo en la pila y mantenerla  limpia
pop ax
pop ax
pop si
pop ax
call perdio
endp

derecha proc near
	push si
	push ax
	push bx
	push cx
	push dx
	cmp direccion,77;si ya esta viendo en esta direccion mover, sino nada mas indicar mov
	je moverderecha
	mov direccion,77
	mov dirpango,0
	jmp nopuedederecha
	
	moverderecha:
	
	mov si, pango
	mov bx,160
	xor dx,dx
	mov ax,si
	div bx
	cmp dx,158;residuo 158 indica q esta lo mas a la derecha posible
	je suicidioderecha
	
	cmp byte ptr screen[si+2]," "
	jne nopuedederecha
	mov dirpango,1
	mov ax, word ptr screen[si];la posicion de pango y bueno pango en si (&)
	mov word ptr screen[si+2], ax;siguiente bloque
	mov word ptr screen[si]," ";a donde estaba pango
	inc pango
	inc pango
	
nopuedederecha:
pop dx
pop cx
pop bx
pop ax
pop si
ret
suicidioderecha:
pop ax;para borrar la direccion que quedo en la pila y mantenerla  limpia
pop ax
pop ax
pop ax
pop si
pop ax
call perdio
endp

ayudita proc near
	push si
	push ax
	push cx
	push di
	xor si,si
	mov ah, 10000b
	mov al,20h
	mov cx, 80
	bordeazul:;primera y ultima linea
		mov word ptr es:[si],ax
		mov word ptr es:[si+3840],ax
		inc si
		inc si
	loop bordeazul
	xor ah,ah
	call linea
	mov cx,80*14
	mov ah, 0001001b;azul claro
	xor di,di
	logopango:
		mov al, byte ptr ayuda[di]
		mov word ptr es:[si],ax
		inc si
		inc si 
		inc di
	loop logopango
	call linea
	call linea
	mov cx, 80*2
	xor di,di
	mov ah, 1010b;v erde claro
	ayuditacontroles:
		mov al, byte ptr controles[di]
		inc di
		mov word ptr es:[si],ax
		inc si
		inc si
	loop ayuditacontroles
	call linea
	
	animacionayudita:
	mov cx,80
	mov ah, 1111b
	xor di,di
	mov si,4000-640
	masayuda:
		mov al,byte ptr instrucc[di]
		mov  word ptr es:[si],ax
		mov al,byte ptr instrucc[di+80]
		mov  word ptr es:[si+160],ax
		mov al,byte ptr instrucc[di+160]
		mov  word ptr es:[si+320],ax
		inc di
		
		inc si
		inc si
	loop masayuda
	
	mov cx,400
	esperando1:
	push cx
	mov cx,5000
	esperandocualquiertecla1:
		nop
		mov ah,01;hay pendiente alguna tecla?
		int 16h
		jnz tecladocadayudita
	loop esperandocualquiertecla1
	pop cx
	loop esperando1
	
	
	mov si, 4000-640
	mov cx,80
	mov di,80*3
	mov ah,1111b
	masayuda2:
		mov al,byte ptr instrucc[di]
		mov  word ptr es:[si],ax
		mov al,byte ptr instrucc[di+80]
		mov  word ptr es:[si+160],ax
		mov al,byte ptr instrucc[di+160]
		mov  word ptr es:[si+320],ax
		inc di
		
		inc si
		inc si
	loop masayuda2
	mov cx,400
	esperando2:
	push cx
	mov cx,5000
	esperandocualquiertecla2:
		nop
		mov ah,01;hay pendiente alguna tecla?
		int 16h
		jnz tecladocadayudita
	loop esperandocualquiertecla2
	pop cx
	loop esperando2
	jmp animacionayudita
	
	tecladocadayudita:
	pop cx; ya que esta el valor al que le hice push antes
	pop di
	pop cx
	pop ax
	pop si	
ret
endp

acerk proc near
	push si
	push ax
	push cx
	mov ah, 01100000b; mis esquinas
	mov al, 20h; espacion en blanco
	mov word ptr es:[1606],ax;esquina superior izq
	mov word ptr es:[1606+160],ax
	mov word ptr es:[1606+320],ax
	mov word ptr es:[1606+480],ax
	mov word ptr es:[1606+640],ax;esquina inferiorizq
	
	mov word ptr es:[1606+160+146],ax
	mov word ptr es:[1606+320+146],ax
	mov word ptr es:[1606+480+146],ax
	
	mov word ptr es:[1606+146],ax;esquina derecha superior
	mov word ptr es:[1606+640+146],ax;esquina inferior derecha
	
	mov cx,72; las que faltan-3
	mov si,1608
	mov di,4
	acerkletreroarriba:
		mov word ptr es:[si],ax
		mov word ptr es:[si+640],ax
		push ax
		
		mov ah, 1100b
		mov al, byte ptr acerca[di]
		mov word ptr es:[si+160],ax
		mov al, byte ptr acerca[di+80]
		mov word ptr es:[si+320],ax
		mov al, byte ptr acerca[di+160]
		mov word ptr es:[si+480],ax
		
		pop ax
		inc si
		inc si
		inc di
		loop acerkletreroarriba
	
	esperandocualquiertecla:
		mov ah,01;hay pendiente alguna tecla?
		int 16h
		jnz tecladocadaacerk
	jmp esperandocualquiertecla
	
	tecladocadaacerk:
	pop cx
	pop ax
	pop si	
ret
endp

siguientenivel proc near
push ax
push bx
push cx
push dx
inc nivel
xor ah,ah
xor dx,dx
mov ax, nivel
mov bx, 10
div bx
mov byte ptr nombreArchivo[2],dl; el primer residuo es el tercer digito
add  byte ptr nombreArchivo[2],30h
xor dx,dx
div bx
mov byte ptr nombreArchivo[1],dl; segundo residuo el tercero
add byte ptr nombreArchivo[1],30h
xor dx,dx 
div bx
mov byte ptr nombreArchivo[0],dl; tercer digito
add byte ptr nombreArchivo[0],30h
pop dx
pop cx
pop bx
pop ax
ret
endp

siguiente proc near
mov bx, handl; cierro el archivo, sino me quedaria sin handls
mov ax, 3e00h
int 21h
call siguientenivel
call reinicio
endp


scheduler proc near
cmp turnosched,5
je procesar
inc turnosched
ret
procesar:
push si
push di
push ax
	
	xor si,si;movspenientes tiene direccion, locacion
	schedule:
	cmp word ptr movspendientes[si],0
	je terminarschedule
	mov di, word ptr movspendientes[si+2]; la localizacion en screen
	mov ax, word ptr screen[di];el ascii en si con color
	cmp al," "; con mucha insistencia y mucha velocidad se podian agendar movimientos de espacios vacios! esto los detecta y borra
	jne bugazoarreglado
	call mover
	bugazoarreglado:
	cmp word ptr movspendientes[si], 72;arriba
	je moverarribaschedule
	cmp word ptr movspendientes[si], 80;abajo
	je moverabajoschedule
	cmp word ptr movspendientes[si], 75;izq
	je moverizquierdaschedule1
	cmp word ptr movspendientes[si], 77;der
	je moverderechaschedule
	continuarschedule:
	add si,4
	jmp schedule
moverizquierdaschedule1:
jmp moverizquierdaschedule
moverarribaschedule:
jmp moverarribaschedule1

terminarschedule:
pop ax
pop di
pop si
mov turnosched,0
ret
	moverabajoschedule:
	cmp di,3840
	jb nodesechabajo
	mov byte ptr screen[di]," "
	jmp movimientocompleto
	
	nodesechabajo:
	cmp byte ptr screen[di+160],"0"; aqui se valida el siguiene movimiento
	je movimientocompleto1
	cmp byte ptr screen[di+160],"X"; aqui se valida el siguiene movimiento
	je movimientocompleto1
	cmp byte ptr screen[di+160],"L"; aqui se valida el siguiene movimiento
	je movimientocompletooso1
	mov byte ptr screen[di]," "; lo que dejo
	mov word ptr screen[di+160],ax; lo que muevo
	add word ptr movspendientes[si+2], 160
	jmp continuarschedule
	movimientocompletooso1:
	jmp movimientocompletooso
	movimientocompleto1:
	jmp movimientocompleto
	moverderechaschedule:
	push ax
	push bx
	push dx
	mov bx,160
	xor dx,dx
	mov ax,di
	div bx
	
	cmp dx,158;residuo 158 indica q esta lo mas a la derecha posible
	jne nodesechaderecha
	mov byte ptr screen[di]," "
	pop dx
	pop bx
	pop ax
	jmp movimientocompleto
	
	nodesechaderecha:
	pop dx
	pop bx
	pop ax
	cmp byte ptr screen[di+2],"0"; aqui se valida el siguiene movimiento
	je movimientocompleto1
	cmp byte ptr screen[di+2],"X"; aqui se valida el siguiene movimiento
	je movimientocompleto1
	cmp byte ptr screen[di+2],"L"; aqui se valida el siguiene movimiento
	je movimientocompletooso1
	
	mov byte ptr screen[di]," "; lo que dejo
	mov word ptr screen[di+2],ax; lo que muevo
	add word ptr movspendientes[si+2], 2
	jmp continuarschedule
	
	moverizquierdaschedule:
	push ax
	push bx
	push dx
	mov bx,160
	xor dx,dx
	mov ax,di
	div bx
	
	cmp dx,0;residuo 2 esta en la esquina
	jne nodesechaizquierda
	mov byte ptr screen[di]," "
	pop dx
	pop bx
	pop ax
	jmp movimientocompleto
	
	nodesechaizquierda:
	pop dx
	pop bx
	pop ax
	cmp byte ptr screen[di-2],"0"; aqui se valida el siguiene movimiento
	je movimientocompleto
	cmp byte ptr screen[di-2],"X"; aqui se valida el siguiene movimiento
	je movimientocompleto
	cmp byte ptr screen[di-2],"L"; aqui se valida el siguiene movimiento
	je movimientocompletooso
	cmp byte ptr screen[di-2],"Q"; aqui se valida el siguiene movimiento
	je movimientocompletooso
	
	mov byte ptr screen[di]," "; lo que dejo
	mov word ptr screen[di-2],ax; lo que muevo
	sub word ptr movspendientes[si+2], 2
	jmp continuarschedule
	
	moverarribaschedule1:; di contiene la direccion de lo que tengo que mover
	cmp di,160
	jnb nodesecharriba
	mov byte ptr screen[di]," "
	jmp movimientocompleto
	
	nodesecharriba:
	cmp byte ptr screen[di-160],"0";aqui se valida el siguiente movimiento
	je movimientocompleto
	cmp byte ptr screen[di-160],"X";aqui se valida el siguiente movimiento
	je movimientocompleto
	cmp byte ptr screen[di-160],"L";aqui se valida el siguiente movimiento
	je movimientocompletooso
	cmp byte ptr screen[di-160],"o";aqui se valida el siguiente movimiento
	je movimientocompletooso
	mov word ptr screen[di-160],ax; lo que muevo
	sub word ptr movspendientes[si+2], 160
	mov byte ptr screen[di]," "; lo que dejo
	jmp continuarschedule
	movimientocompletooso:
	sub turnooso,24
	movimientocompleto:
	call mover
	jmp continuarschedule
endp

; recibe en si el movimiento a eliminar
mover proc near
push si
push ax

moviendo:
	cmp word ptr movspendientes[si],0
	je movido
	
	mov ax, word ptr movspendientes[si+4]; muevale la siguiente a la actual
	mov word ptr movspendientes[si],ax
	mov ax, word ptr movspendientes[si+6]; muevale el char siguiente a la actual+2
	mov word ptr movspendientes[si+2],ax
	
	
	add si,4;me muevo 4 bytes
jmp moviendo

movido:
mov word ptr movspendientes[si],0; lo dejo como estaba
mov word ptr movspendientes[si+2],0; lo dejo como estaba
mov indicemovs,si
sub indicemovs,4
pop ax
pop si
ret
endp


patear proc near
push si
push ax
push bx
push cx
push dx
	mov dirpango,0
	mov si,pango

	cmp direccion, 72;arriba
	jne nopateoarriba
	
	cmp si,160
	jb pateo1
	cmp byte ptr screen[si-160],"L" 
	je pateo1
	cmp byte ptr screen[si-160],"Q" 
	je pateo1
	cmp byte ptr screen[si-160]," " 
	je pateo1
	
	
	cmp byte ptr screen[si-160],"o";pobre oso, lo patearon en las "o"
	jne novaliente1
	mov byte ptr screen[si-159],0100b
	jmp pateo
	
	pateo1:
	jmp pateo
	
	novaliente1:
	cmp si,320
	jb estalloarriba
	cmp byte ptr screen[si-320],"X"; el que esta arriba de ese
	je estalloarribaV
	cmp byte ptr screen[si-320],"L"; el que esta arriba de ese
	je estalloarribaV
	cmp byte ptr screen[si-320],"o"; el que esta arriba de ese
	je estalloarribaV
	cmp byte ptr screen[si-320],"0"; el que esta arriba de ese
	jne movimientoarribaagendado
	
	estalloarribaV:
	cmp byte ptr screen[si-160],"X"
	je pateo1
	
	estalloarriba:
	mov byte ptr screen[si-160]," "
	jmp pateo
	
	movimientoarribaagendado:
	push di
	mov di, indicemovs; el actual indice donde puedo hacer schedule
	mov word ptr movspendientes[di],72; le muevo movimiento arriba
	mov word ptr movspendientes[di+2],si; le muevo la localizacion en pantalla
	sub word ptr movspendientes[di+2],160;
	add indicemovs,4
	pop di
	
	jmp pateo
	
	
	
	nopateoarriba:
	cmp direccion, 80;abajo
	jne nopateoabajo
	cmp byte ptr screen[si+320],"L" 
	je pateo1
	cmp byte ptr screen[si+320],"o" 
	je pateo1
	cmp byte ptr screen[si+160],"Q" 
	je pateo1
	cmp byte ptr screen[si+160]," " 
	je pateo1
	
	cmp si,3840
	ja pateo1
	cmp si,3680
	jae estalloabajo
	
	cmp byte ptr screen[si+320],"X"; el que esta abajo de ese
	je estalloabajoV
	cmp byte ptr screen[si+320],"Q"; el que esta abajo de ese
	je estalloabajoV
	cmp byte ptr screen[si+320],"0"; el que esta abajo de ese
	jne movimientoabajoagendado
	estalloabajoV:
	cmp byte ptr screen[si+160],"X"
	je pateo2
	
	estalloabajo:
	mov byte ptr screen[si+160]," "
	jmp pateo
	
	movimientoabajoagendado:
	push di
	mov di, indicemovs; el actual indice donde puedo hacer schedule
	mov word ptr movspendientes[di],80; le muevo movimiento arriba
	mov word ptr movspendientes[di+2],si; le muevo la localizacion en pantalla
	add word ptr movspendientes[di+2],160;
	add indicemovs,4
	pop di
	jmp pateo
	
	pateo2:
	jmp pateo
	
	nopateoabajo:
	cmp direccion, 75;izq
	jne nopateoizq
	cmp byte ptr screen[si-2],"Q" 
	je pateo2
	cmp byte ptr screen[si-2],"L" 
	je pateo2
	cmp byte ptr screen[si-2]," " 
	je pateo2
	
	mov bx,160
	xor dx,dx
	mov ax,si
	div bx 
	cmp dx,2
	je estalloizq; esta en una esquina
	
	cmp byte ptr screen[si-4],"X"
	je estalloizqV
	cmp byte ptr screen[si-4],"0"
	jne movimientoizqagendado
	estalloizqV:
	cmp byte ptr screen[si-2],"X"
	je pateo2
	estalloizq:
	mov byte ptr screen[si-2]," "
	jmp pateo
	movimientoizqagendado:
	push di
	mov di, indicemovs; el actual indice donde puedo hacer schedule
	mov word ptr movspendientes[di],75; le muevo movimiento izquierda
	mov word ptr movspendientes[di+2],si; le muevo la localizacion en pantalla a la cual moverse
	dec word ptr movspendientes[di+2]
	dec word ptr movspendientes[di+2]
	add indicemovs,4
	pop di
	jmp pateo
	
	
	nopateoizq:
	cmp direccion, 77;der
	jne pateo
	cmp byte ptr screen[si+2],"L" 
	je pateo
	cmp byte ptr screen[si+2]," " 
	je pateo
	cmp byte ptr screen[si+3],00001111b
	je pateo
	
	cmp byte ptr screen[si+4],"X"
	je estalloderV
	cmp byte ptr screen[si+4],"0"
	jne movimientoderagendado
	estalloderV:
	cmp byte ptr screen[si+2],"X"
	je pateo
	estalloder:
	
	mov byte ptr screen[si+2]," "
	jmp pateo
	movimientoderagendado:
	push di
	mov di, indicemovs; el actual indice donde puedo hacer schedule
	mov word ptr movspendientes[di],77; le muevo movimiento derecha
	mov word ptr movspendientes[di+2],si; le muevo la localizacion en pantalla a la cual moverse
	inc word ptr movspendientes[di+2]
	inc word ptr movspendientes[di+2]
	add indicemovs,4
	pop di
	jmp pateo
	
	pateo:

pop dx
pop cx
pop bx
pop ax
pop si
ret
endp

dibujarPantalla proc near 
	push si
	push ax
	push cx 
	mov cx, 2000
	xor si,si
	
	refresh:
		mov ax, word ptr screen[si]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
        loop refresh
	pop cx
	pop ax
	pop si
	ret
endp

cargarArchivo proc near
	push ax
	push bx 
	push cx
	push dx
	
	jmp abriendo
	noAbrio2:
	call siguientenivel
	
	abriendo:
	lea dx,nombreArchivo
	mov ax, 3d00h
	int 21h
	jc noAbrio2
	mov handl,ax
	; en este punto ya tengo el archivo cargado
	xor si,si
	
	mov bx,handl
	
	leer:
	mov ax, 3F00h
	mov cx,1; cantidad de bytes a leer
	lea dx,buffy
	int 21h;aqui ya tengo caracter en buffy
	
	cmp ax,0; si ax es 0 no se leyo nada
	je abrio

	mov al, buffy
	
	cmp al,"&";reviso si ya tengo a pango
	jne nopanguito
	mov pango,si;registramos a pango
	mov ah, 1111b
	jmp paredOVacio
	nopanguito:
	cmp al, 13
	jne nocambiolinea
	cmp charanterior,10
	jne maslineas
	mov cx, 80
	mov ax,20h
	jmp espaciosvaciosarchivo
	maslineas:
	mov ax,si
	add ax,160
	xor dx,dx 
	mov cx,160
	div cx
	cmp dx,0
	je cambio; se escribio toda la linea
	
	mov cx,160
	sub cx,dx
	shr cx,1;division entre 2
	;en dx residuo y en ax cociente
	mov ax,20h;un espacio en negro
	espaciosvaciosarchivo:
		mov word ptr screen[si],ax;el color junto el caracter
		inc si
		inc si
	loop espaciosvaciosarchivo
	
	jmp cambio
	
	nocambiolinea:
	cmp al, 10
	jne normal
	jmp cambio
	normal:
	cmp al," "
	je paredOVacio
	
	call generacolor
	
	cmp al, "X"
	jne paredOVacio
	mov ah, 1011b
	paredOVacio:
	mov word ptr screen[si],ax;el color junto el caracter
	inc si
	inc si
	cambio:
	mov charanterior,al
	mov ax, 4201h;aumentar el puntero
	xor cx,cx;los ocupo en 0 porque son el offset desde esa posicion
	xor dx,dx;
	int 21h
	jmp leer
	
	abrio:
	call pintaoso
	pop dx
	pop cx 
	pop bx
	pop ax
	ret
	
endp

miNombre proc near
	push si
	push di
	push ax
	push cx 
	
	mov ah, 00011011b;fondo argb en este caso azul oscuro y cyan claro 
	mov cx, 80
	xor di,di
	mov si, 3840;ultima linea del DOS
	
	nombreAPantalla:
		mov al, byte ptr acerca[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
		inc di
        loop nombreAPantalla
	pop cx
	pop ax
	pop di
	pop si
	ret
endp


baboso proc near

	mov cx, 25
	xor si,si
	mov ah, 1000000b
	mov al, 178; dark shade
	lineasconshade:
		call linea
	loop lineasconshade
	lineasvacias:
	mov ah, 10001100b;blink fondo argb fondo negro con blink, letras rojas
	mov cx, 560; 5x80
	xor di,di
	mov si, 160*9;linea a mitad de la pantalla
	
	letreroPerdedor:
		mov al, byte ptr perdedor[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
		inc di
        loop letreroPerdedor
	mov ah,1111b; blanco
	mov cx,80
	mov si, 3040
	xor di,di
	
	apreteEnterReintento:
		mov al, byte ptr reintentoEnter[di]
		mov word ptr es:[si],ax
		inc di
		inc si
		inc si
	loop apreteEnterReintento
	
	esperandoreintento:
		mov ah, 01;hay pendiente alguna tecla?
		int 16h
		jz esperandoreintento
		xor ah, ah;cual tecla esta pendiente?
		int 16h
		cmp al,13
		je reintentando
		xor al,al
	jmp esperandoreintento
	
	reintentando:
	call reinicio
	
	ret
endp
; dibuja victoria en la pantalla
notanbaboso proc near
	push si
	push di
	push ax
	push cx 
	mov cx, 560; 5x80
	xor di,di
	mov si, 1600;linea a mitad de la pantalla
	
	letreroGanador:
		mov al, byte ptr ganador[di]
		call generaColor
		or ah,10000000b; para ponerle el blink
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
		inc di
        loop letreroGanador
	mov cx,80
	mov di,80
	mov si,160*23
	letrerganador:
		mov al, byte ptr Amalo[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
		inc di
        loop letrerGanador
		
	Yagano:
		mov ah, 01;hay pendiente alguna tecla?
        int 16h
		jz Yagano
		xor ah, ah;cual tecla esta pendiente?
        int 16h
		cmp al,13
		je siguientelvl
		jmp Yagano
		
	siguientelvl:
	call siguiente
	pop cx
	pop ax
	pop di
	pop si
	ret
endp

superpangobros proc near 
	push si
	push di
	push ax
	push cx 
	mov cx, 16*80
	xor di,di
	xor si,si;linea a principio de pantalla
	mov ah, 00000100b
	pangopeligroso:
		mov al, byte ptr ayuda[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si   
		inc di
        loop pangopeligroso
	call linea; es una rutina que da una linea
	call linea
	xor di,di
	mov ah, 10001111b; blinking fondo negro, color blanco
	mov cx, 80
	entersito:
		mov al, byte ptr elEnter[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si
		inc di
        loop entersito
	call linea
	call linea 
	mov cx, 80*3
	mov ah, 00000001b;color azul fondo negro
	xor di,di
	apachurrale:
		mov al, byte ptr controles[di]
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si
		inc di
        loop apachurrale
		
	call miNombre;
	
	esperandoEnter:;el enter es el acii 13
		
		
		mov cx, 80
		mov si,4000
		mov di,80
		mov ah, 00011011b
		
		nombrecarnet:
			mov al,byte ptr acerca[di]
			dec di
			mov ah, 00011011b
			mov word ptr es:[si],ax
			dec si
			dec si
			push cx 
			mov cx,10000
			
			animacionNombre:;el delay entre poner cada letra
				nop
				mov ah, 01;hay pendiente alguna tecla?
				int 16h
				jz continualoopnombre
				xor ah, ah;cual tecla esta pendiente?
				int 16h
				cmp al,13
				je unEnter
			continualoopnombre:
			loop animacionNombre
			pop cx
		loop nombrecarnet
		
		mov cx,5
		superdelayeaster:
		push cx
		mov cx,65000
		delayeaster:;el delay entre la animacion 1 y la 2
			nop
			mov ah, 01;hay pendiente alguna tecla?
			int 16h
			jz continuadelayeaster
			xor ah, ah;cual tecla esta pendiente?
			int 16h
			cmp al,13
			je unEnter
		continuadelayeaster:
		loop delayeaster
		pop cx
		loop superdelayeaster
		
		mov cx, 80
		mov si,3840
		xor di,di
		mov ah, 00001010b
		consejoeaster:
			mov al,byte ptr easteregg[di]
			inc di
			mov ah, 00001010b
			mov word ptr es:[si],ax
			inc si
			inc si
			push cx 
			mov cx,10000
			animacion:;el delay entre poner cada letra
				nop
				mov ah, 01;hay pendiente alguna tecla?
				int 16h
				jz continualoopanimacion
				xor ah, ah;cual tecla esta pendiente?
				int 16h
				cmp al,13
				je unEnter
				continualoopanimacion:
			loop animacion
			pop cx
		loop consejoeaster
		
		jmp esperandoEnter
		
	unEnter:
	pop cx
	pop cx
	pop ax
	pop di
	pop si
ret
endp

linea proc near
	push cx
	push ax
	mov al, " "
	mov cx,80;una linea
	liniesita:
		mov word ptr es:[si], ax; el char a escribir
        inc si    
        inc si
        loop liniesita
	pop ax
	pop cx
ret
endp
pausa proc near
	mov cx,nops2; el multiplicador
	
	P1:     push cx
			mov cx, nops1;el numero
		
		P2:     nop
		loop P2
		
			pop cx
    loop P1
ret
endp
generaColor proc near; una rutina simple que sigue un algoritmo secuencial
	
	inc color
	cmp color,1111b
	je resetcolor
	cmp color,1011b;que seria cyan el color de los diamantes
	je incFavor
	
	jmp generado
	
	resetcolor:
	mov color,1
	jmp generado
	
	incFavor:;valor no permitido detectado
	inc color
	
	generado:
	mov ah,color
	ret
endp

pintaoso proc near
push si
push cx
push ax
push dx
push bx
	xor si,si
	mov cx,3840
	osoperdido:
	cmp byte ptr screen[si],"Q"
	je continuarbusquedaoso
	inc si
	inc si
	loop osoperdido
	
	continuarbusquedaoso:
	mov oso,si
	xor dx,dx
	mov ax, si
	mov bx, 160
	div bx
	cmp dx, 0
	je errorArchivo

	cmp byte ptr screen[si-2]," "
	jne errorArchivo
	cmp byte ptr screen[si-4]," "
	jne errorArchivo
	cmp byte ptr screen[si-6]," "
	jne errorArchivo
	cmp byte ptr screen[si+158]," "
	jne errorArchivo
	cmp byte ptr screen[si+156]," "
	jne errorArchivo
	cmp byte ptr screen[si+154]," "
	jne errorArchivo
	mov byte ptr screen[si+1],1111b
	mov byte ptr screen[si-2],"0"
	mov byte ptr screen[si-1],1111b
	mov byte ptr screen[si-4],"0"
	mov byte ptr screen[si-3],1111b
	mov byte ptr screen[si-6],"0"
	mov byte ptr screen[si-5],1111b
	mov byte ptr screen[si+158],"L"
	mov byte ptr screen[si+159],1111b
	mov byte ptr screen[si+156],"o"
	mov byte ptr screen[si+157],1111b
	mov byte ptr screen[si+154],"L"
	mov byte ptr screen[si+155],1111b
	jmp tenemosaloso
	
	
	
errorArchivo:
call archivoMalo
tenemosaloso:
pop bx
pop dx
pop ax
pop cx
pop si
ret
endp 
archivoMalo proc near
push cx
push ax
push si
push di
	mov cx,25
	xor si,si
	mov ah,00110000b
	
	loopmalo:
	call linea
	loop loopmalo
	
	mov cx,80*2
	mov si,160*12
	xor di,di
	mov ah, 11101111b
	loopmalito:
		mov al, byte ptr Amalo[di]
		mov word ptr es:[si],ax
		inc si
		inc si
		inc di
	loop loopmalito
	xor ax,ax
	prub:
	int 16h
	cmp al,13
	je aceptorealidad
	xor ax,ax
	jmp prub
aceptorealidad:
pop di
pop si
pop cx
pop ax
call siguiente
call reinicio
endp

victoria proc near
push si
push cx
push di
push ax
mov cx, 128
xor si,si
pendienteX:
	mov di, word ptr movspendientes[si]
	inc si
	inc si
	cmp byte ptr screen[di],"X"
	je finalvictoria
loop pendienteX
mov cx,2000
xor si,si

loopvictorioso:
	cmp byte ptr screen[si],"X"
	je puedeganar
	inc si
	inc si
loop loopvictorioso
jmp finalvictoria

puedeganar:; tengo en si un diamante, de hecho, el primero
cmp si,4000-320
jnb todaviapuede
cmp byte ptr screen[si+160],"X"
jne todaviapuede
cmp byte ptr screen[si+320],"X"
jne todaviapuede
call notanbaboso; y ese proc se encarga de hacer todo lo demas
todaviapuede:
cmp byte ptr screen[si+2],"X"
jne finalvictoria
cmp byte ptr screen[si+4],"X"
jne finalvictoria
call notanbaboso
finalvictoria:
pop ax
pop di
pop cx
pop si
ret
endp

buscapango proc near; creada para arreglar un bug
push si
push cx
mov si, pango
cmp byte ptr screen[si],"&"
je wtf
xor si,si
mov cx,2000
buscandoapango:
cmp byte ptr screen[si],"&"
je pangoencontrado
inc si
inc si
loop buscandoapango
jmp wtf
pangoencontrado:
mov pango,si
wtf:
pop cx
pop si
ret
endp


superoso proc near; la variable oso apunta a la Q del oso
push si
push ax
push bx
	cmp turnoOso,12
	je turnodeosito
	inc turnoOso
	jmp osomovido
	
	turnodeosito:
	mov turnoOso,0
	
	;cerebro
	mov ax,pango
	mov bx,oso
	sub ax, bx;si me da negativo complemento
	cmp ax,0
	jnb nocomplementar
	not ax
	inc ax
	nocomplementar:
	cmp ax, 160
	jb direccionOso; para decidir la direccion ya que estan en la misma linea
	
	mov ax, pango
	
	cmp ax,bx
	jb intentarmoverosoarriba1
	
	jmp intentarmoverosoabajo
	
	intentarmoverosoarriba1:
	jmp intentarmoverosoarriba
	
	direccionOso:
	mov ax, pango
	mov bx, oso
	bajopango:
		cmp ax, 160
		jb bajadopango
		sub ax,160
	jmp bajopango
	
	bajadopango:
		cmp bx, 160
		jb bajadoOso
		sub bx,160
	jmp bajadopango
	
	bajadoOso:; en este punto "estan en la misma linea"
	cmp ax, bx
	jae intentarmoverderecha
	
	intentarmoverizquierda:
	mov si,oso
	cmp byte ptr screen[si-8],"0"
	je nopude
	cmp byte ptr screen[si+152],"0"
	je nopude
	cmp byte ptr screen[si-8],"X"
	je nopude
	cmp byte ptr screen[si+152],"X"
	je nopude
	;mueve el oso a su izquierda
	
	mov ax, word ptr screen[si+154];L
	mov word ptr screen[si+152],ax
	mov ax, word ptr screen[si+156];o
	mov word ptr screen[si+154],ax
	mov ax, word ptr screen[si+158];L
	mov word ptr screen[si+156],ax
	
	mov ax, word ptr screen[si-6];0
	mov word ptr screen[si-8],ax
	mov ax, word ptr screen[si-4];0
	mov word ptr screen[si-6],ax
	mov ax, word ptr screen[si-2];0
	mov word ptr screen[si-4],ax
	mov ax, word ptr screen[si];Q
	mov word ptr screen[si-2],ax
	mov byte ptr screen[si]," "
	mov byte ptr screen[si+158]," "
	sub oso,2
	jmp osomovido
	
	nopude:
	jmp osomovido
	
	intentarmoverderecha:
	mov si, oso
	cmp byte ptr screen[si+2],"0"
	je nopude
	cmp byte ptr screen[si+162],"0"
	je nopude
	cmp byte ptr screen[si+162],"X"
	je nopude
	cmp byte ptr screen[si+2],"X"
	je nopude
	;mueve el oso a su derecha
	mov ax, word ptr screen[si+158];L
	mov word ptr screen[si+160],ax
	mov ax, word ptr screen[si+156];o
	mov word ptr screen[si+158],ax
	mov ax, word ptr screen[si+154];L
	mov word ptr screen[si+156],ax
	
	mov ax, word ptr screen[si];Q
	mov word ptr screen[si+2],ax
	mov ax, word ptr screen[si-2];0
	mov word ptr screen[si],ax
	mov ax, word ptr screen[si-4];0
	mov word ptr screen[si-2],ax
	mov ax, word ptr screen[si-6];0
	mov word ptr screen[si-4],ax
	
	mov byte ptr screen[si-6]," "
	mov byte ptr screen[si+154]," "
	
	add oso,2
	jmp osomovido
	
	direccionOso2:
	jmp direccionOso
	
	;intenta mover al oso abajo, sino decide una direccion
	intentarmoverosoabajo:
	mov si,oso
	cmp si, 3680
	ja direccionOso2
	cmp byte ptr screen[si+160],"0"
	je direccionOso2
	cmp byte ptr screen[si+320],"0"
	je direccionOso2
	cmp byte ptr screen[si+318],"0"
	je direccionOso2
	cmp byte ptr screen[si+316],"0"
	je direccionOso2
	cmp byte ptr screen[si+314],"0"
	je direccionOso1
	cmp byte ptr screen[si+160],"X"
	je direccionOso1
	cmp byte ptr screen[si+320],"X"
	je direccionOso1
	cmp byte ptr screen[si+318],"X"
	je direccionOso1
	cmp byte ptr screen[si+316],"X"
	je direccionOso1
	cmp byte ptr screen[si+314],"X"
	je direccionOso1
	;aqui mueve al oso abajo
	mov ax, word ptr screen[si+154];L
	mov word ptr screen[si+314],ax
	mov ax, word ptr screen[si+156];o
	mov word ptr screen[si+316],ax
	mov ax, word ptr screen[si+158];L
	mov word ptr screen[si+318],ax
	mov ax, word ptr screen[si];Q
	mov word ptr screen[si+160],ax
	mov ax, word ptr screen[si-2];0
	mov word ptr screen[si+158],ax
	mov ax, word ptr screen[si-4];0
	mov word ptr screen[si+156],ax
	mov ax, word ptr screen[si-6];0
	mov word ptr screen[si+154],ax
	mov byte ptr screen[si-2]," "
	mov byte ptr screen[si-4]," "
	mov byte ptr screen[si-6]," "
	mov byte ptr screen[si]," "
	add oso,160
	jmp osomovido
	direccionOso1:
	jmp direccionOso
	intentarmoverosoarriba:
	mov si,oso
	;validaciones de lo que tiene arriba
	cmp byte ptr screen[si-160],"0"
	je direccionOso1
	cmp byte ptr screen[si-162],"0"
	je direccionOso1
	cmp byte ptr screen[si-164],"0"
	je direccionOso1
	cmp byte ptr screen[si-166],"0"
	je direccionOso1
	cmp byte ptr screen[si-160],"X"
	je direccionOso1
	cmp byte ptr screen[si-162],"X"
	je direccionOso1
	cmp byte ptr screen[si-164],"X"
	je direccionOso1
	cmp byte ptr screen[si-166],"X"
	je direccionOso1
	;aqui mueve al oso arriba
	mov ax, word ptr screen[si];Q
	mov word ptr screen[si-160],ax
	mov ax, word ptr screen[si-2];0
	mov word ptr screen[si-162],ax
	mov ax, word ptr screen[si-4];0
	mov word ptr screen[si-164],ax
	mov ax, word ptr screen[si-6];0
	mov word ptr screen[si-166],ax
	mov ax, word ptr screen[si+154];L
	mov word ptr screen[si-6],ax
	mov ax, word ptr screen[si+156];o
	mov word ptr screen[si-4],ax
	mov ax, word ptr screen[si+158];L
	mov word ptr screen[si-2],ax
	mov byte ptr screen[si+154]," "
	mov byte ptr screen[si+156]," "
	mov byte ptr screen[si+158]," "
	mov byte ptr screen[si]," "
	sub oso,160
	jmp osomovido

osomovido:
pop bx
pop ax
pop si
ret
endp



final:
    mov ax, 4C00h
    int 21h

codigo ends
end inicio