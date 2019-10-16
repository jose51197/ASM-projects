; Jose Pablo Gonzalez Alvarado 
; 2016157695 
; Kirstein Gätjens
; Instituto tecnológico de Costa Rica 
; Escuela de computacion 
; Arquitectura de computadores
; 
;
; Manual De usuario
; El siguiente programa cuenta con diversas funcionalidades que operan sobre fechas
; el usuario puede usar -h mes año para desplegar el calendario respectivo de ese mes
; tambien puede usar -d dia mes año para saber que dia de la semana fue ese dia ese año
; otra funcionalidad es mostrar la cantidad de dias entre dos fechas con -r seguido de 
; ambas fechas en formato dia mes año, tambien se puede usar -s dia mes año para desplegar que 
; dia del siglo fue ese, ademas de -f con la misma sintaxis que -s para saber que dia del siglo
; fue ese 
;
; Analisis de resultados:
; Documentacion                                                         A 
; Convertir de INT a ASCII para desplegar                               A
; Deteccion de errores con especificacion                               A
; Deteccion de opcion ingresada                                         A
; Deteccion de dia ingresado                                            A
; Deteccion de mes ingresado											A
; Deteccion de año ingresado											A
; Despliegue del calendario												A
; Despliegue del dia en letras											A
; Uso de arreglos y matrices											A
; Deteccion de años bisiestos											A
; Deteccion del dia de una fecha										A
; Contador del numero de dia segun el año								A
; Contador de distancia entre dos fechas								A
; Contador de numero de dia segun el siglo 								A
; Funciones auxiliares 													A
; Seguir estandares de salida estandar(ejemplos del profe)				A
; Deteccion de errores especificos										A
; 
; 
datos segment
listaDeDias db 7,15,21,28,38,45,53
;lista de offsets, porque me da pereza hacer tantos cmps

db "Domingo$"
db "Lunes$"
db "Martes$"
db "Miercoles$"
db "Jueves$"
db "Viernes$"
db "Sabado$"

numero db 16 dup(?)
exitaso db 13,10,"Esta vez si la hice *Vale por un mensaje de exito*"
;mini acercaDe
acerca db "Jose Pablo Gonzalez Alvarado",13,10,"2016157695, Arquitectura, Tarea de ASM",13,10,13,10,'$'
;acerca ends 
ayuda0 db "Ayuda del programa",10,13,"Utilice los siguientes comandos:",10,13,'$'
ayuda1 db "-a,-A para desplegar este mensaje",10,13
db "-h,-H seguido del mes y el anho para desplegar la hoja del calendario",10,13
db "Utilice los siguientes comandos seguidos de dia mes y anho:",10,13
db "-d,-D para buscar el dia de la semana de una fecha particular",10,13
db "-f,-F para buscar el numero de dia de una fecha particular",10,13
db "-r,-R de ambas fechas para indicar la diferencia de dias entre ellas",10,13
db "-s,-S para mostrar el dia del siglo de esa fecha",10,13,'$'
;ayuda ends
diasDeMeses db 0,31,28,31,30,31,30,31,31,30,31,30,31
tablasDeMeses db 0,6,2,2,5,0,3,5,1,4,6,2,4
LaHazel db "El dia es invalido o falta el mes$"
mesMal db 10,13,"El mes es invalido",10,13,'$'
numeroInvalido db "El a",164,"o es invalido",10,13,'$'
comandoInvalido db "Comando invalido, revise la ayuda para una guia",'$'
mesEnLetras db 16 dup(?)
enero db 5,"enero"
febrero db 7,"febrero"
marzo db 5,"marzo"
abril db 5,"abril"
mayo db 4,"mayo"
junio db 5,"junio"
julio db 5,"julio"
agosto db 6,"agosto"
septiembre db 10,"septiembre";segun la RAE ambas son validas
setiembre db 9,"setiembre"
octubre db 7,"octubre"
noviembre db 9,"noviembre"
diciembre db 9,"diciembre"
;las siguientes tienen el nombre de variable del algoritmo que nos dio 
a dw 0
b dw 0 
c dw 0
d dw 0 
e dw 0
;dia mes y año
dia db 0
mes db 0
anho dw 0
modoHoja db 0;
dia2 db 0 
mes2 db 0
anho2 dw 0
errorDeDia db "El dia ingresado no es de ese mes",10,13,'$'
diferenciaAnhos dw 0
primerBisiesto db 0

Dias        db " Dom  Lun  Mar  Mie  Jue  Vie  Sab  ",10,13,'$'

superMatrix db   0  , 0  , 0  , 0  , 0  , 0  , 0
			db   0  , 0  , 0  , 0  , 0  , 0  , 0
			db   0  , 0  , 0  , 0  , 0  , 0  , 0
			db   0  , 0  , 0  , 0  , 0  , 0  , 0
			db   0  , 0  , 0  , 0  , 0  , 0  , 0
			db   0  , 0  , 0  , 0  , 0  , 0  , 0
			
fila db 0
actual db 0;variable para ver a donde apunta si
actual2 db 0
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
	mov si, 82h
	mov ax,0900h;mi nombre y carnet
	lea dx, acerca 
	int 21h
;revision de como empieza lo que metieron
call espaciadores
comandos:
cmp byte ptr es:[si],'-'
je decision
cmp byte ptr es:[si],0;significa que esta vacia
je ayudita
jmp ecomando

help:
cmp byte ptr es:[si-1],13
jne ecomando
ayudita:
mov ah,09h
lea dx, ayuda0
int 21h
lea dx, ayuda1
int 21h
jmp final

;esto ya estaba hecho en la anterior, 
;me entraron ganas de implementar string instructios pero nah
decision:
add si,3;para que quede en los datos ingresados de una vez
cmp byte ptr es:[si-2],'A'
je help
cmp byte ptr es:[si-2],'a'
je help

cmp byte ptr es:[si-1],' '
jne ecomando

cmp byte ptr es:[si-2],'S'
je diaSiglo
cmp byte ptr es:[si-2],'s'
je diaSiglo

cmp byte ptr es:[si-2],'R'
je diferencia
cmp byte ptr es:[si-2],'r'
je diferencia

cmp byte ptr es:[si-2],'F'
je diaAnho
cmp byte ptr es:[si-2],'f'
je diaAnho

cmp byte ptr es:[si-2],'D'
je diasemana
cmp byte ptr es:[si-2],'d'
je diasemana

cmp byte ptr es:[si-2],'H'
je hoja
cmp byte ptr es:[si-2],'h'
je hoja
jmp ecomando
ret

ecomando: 
mov ah,09h;instruccion de imprimir
lea dx, comandoInvalido
int 21h
jmp final

;listo, no tocar
diaSiglo:
call procSiglo
call convertirImprimir
jmp final
encontrarAno:


;listo, no tocar
diferencia:;obtengo las primeras cosas
call odia 
call omes 
call oanho
call procDiferencia
call convertirImprimir;porque en ax esta el resultado
jmp final


;listo, no tocar
diaAnho:
call odia
call omes
call oanho;ya con todas las variables hago el calculo
;vale por una validacion de dtos extra en linea de comandos
call procDiaAnho
call convertirImprimir
jmp final

diasemana:
call odia
call omes
call oanho;ya con todas las variables hago el calculo
call procDiaSemana
mov si,ax
mov ax,0900h
xor dx,dx
mov dl,listaDeDias[si]
int 21h
jmp final



hoja:
inc modoHoja
call omes
call oanho
mov dia,1
call procDiaSemana; me regresa en ax el dia, 0 es domingo
mov si,ax;di es el dia de la semana
dec si
xor ax,ax
mov al,mes
mov di,ax
xor cx,cx
mov cl, diasDeMeses[di]

llenarMatrix:;se muy bien que es matriz
push si
add si,cx
mov superMatrix[si],cl
pop si
loop llenarMatrix 

call imprimeMatriz
jmp final



procDiaSemana proc near

	mov ax,anho
	mov cx,anho
	cmp anho,1999
	jbe sumar2

	restar2:
	sub anho,100
	cmp anho,2000
	jna restoTodo
	sub a,2
	jmp restar2

	sumar2:
	inc a
	sumasde2:
	add anho,100
	cmp anho,2000
	jnb restoTodo
	add a,2
	jmp sumasde2
	restoTodo:
	
	mov ax,cx
	xor dx,dx
	mov bx,100
	div bx
	push dx;los dos ultimos digitos del año
	
	
	mov bx,4
	mov ax,dx
	xor dx,dx
	div bx
	pop dx
	add ax,dx;al cociente le sumamos los dos digitos
	mov b,ax
	mov ax,cx;recupero el anho nuevamente
	
	xor dx,dx
	mov bx,100 
	div bx
	cmp dx,0
	je CesPositivo
	
	xor dx,dx 
	mov bx,400
	mov ax,cx
	div bx
	cmp dx,0
	je CesNegativo
	
	xor dx,dx
	mov bx,4
	mov ax,cx
	div bx
	cmp dx,0
	je CesNegativo
	
	CesPositivo:
	xor ah,ah
	mov al,mes
	mov si,ax
	mov al,byte ptr tablasDeMeses[si]
	mov d,ax;d contiene su valor necesario
	
	mov al,dia
	mov e,ax
	
	xor ax,ax
	add ax,a
	add ax,b
	add ax,c
	add ax,d
	add ax,e
	
	xor dx,dx
	mov bx,7
	div bx
	
	mov ax,dx; le movemos el residuo
	ret
	
	CesNegativo:
	cmp mes,2
	jnbe CesPositivo
	mov c,-1
	jmp CesPositivo
endp

;calcula la diferencia de dias entre el 1 de enero de un siglo y el
;insertado por el usuario
procSiglo proc near
	push si
	call odia 
	call omes
	call oanho
	pop si;si apunta al primer numero
	dec si

	mov dia,1;1 
	mov mes,1;enero
	
	mov ax,anho
	mov bx,100
	xor dx,dx
	div bx
	xor dx,dx
	mul bx
	mov anho,ax;siglo
	call procDiferencia
	mov bx,anho2
	cmp anho,bx
	je nocompensar
	inc ax
	nocompensar:
	inc ax
	ret
endp

procDiferencia proc near
	push si
	call procDiaAnho; me regresa en ax los dias del ano 1
	cmp diasDeMeses[2],29
	jne nofueBisiesto1
	inc primerBisiesto
	
	nofueBisiesto1:
	mov diasDeMeses[2],28;por si fue bisiesto el calculo
	mov diferenciaAnhos,ax
	
	
	
	mov al,dia 
	mov dia2,al 
	mov al,mes 
	mov mes2,al
	mov ax,anho
	mov anho2,ax
	pop si
	inc si
	
	call odia
	call omes
	call oanho
	
	call procDiaAnho; me regresa en ax los dias del ano 2
	;en este punto ya tengo las dos fechas y sus dias del año	
	
	sub ax,diferenciaAnhos;a la segunda le quito la primera
	jns nocomplementar
	not ax
	inc ax
	
	
	nocomplementar:
	mov diferenciaAnhos,ax
	mov ax,anho2
	sub ax,anho
	jns nocomplementar1
	
	not ax;complemento el numero pues me dio negativo
	inc ax
	
	cmp primerBisiesto,1
	jne nocomplementar1
	
	cmp mes2,2
	jbe nocomplementar1
	
	cmp dia2,28
	jbe nocomplementar1
	
	dec diferenciaAnhos


	nocomplementar1:
	
	mov bx,365
	push ax;pues contiene el resultado de la resta de los anhos
	xor dx,dx; por paranoia 
	mul bx;la diferencia de los anhos por 365
	
	add diferenciaAnhos,ax; le sumo los dias de los anos en medio
	
	pop ax
	xor dx,dx
	mov bx,4
	div bx
	add diferenciaAnhos,ax
	
	mov ax,diferenciaAnhos
	ret

endp
;queda en ax el resultado
procDiaAnho proc near

	xor dx,dx
	mov ax,anho
	mov bx,400
	div bx
	cmp dx,0
	je esBisiesto
	
	xor dx,dx
	mov ax,anho
	mov bx,4
	div bx
	cmp dx,0
	jne diaAnhonoBisiesto
	
	xor dx,dx
	mov ax,anho
	mov bx,100
	div bx
	cmp dx,0
	je diaAnhonoBisiesto
	
	esBisiesto:
	inc byte ptr diasDeMeses[2];febrero con 29 dias

	diaAnhonoBisiesto:
	xor ax,ax
	dec mes
	mov al,mes;apunta al mes anterior en diasDeMeses

	mov si,ax;apuntar al mes anterior para sumar sus dias
	mov cx,ax;la cantidad de meses restantes

	mov al,dia
	xor bx,bx
	cmp cx,0
	je Cxescero
	cicloDiaAnho:
	mov bl, byte ptr diasDeMeses[si]
	dec si
	add ax,bx
	loop cicloDiaAnho;se cae si cx es 0
	
	Cxescero:
	ret
endp

;tomando en cuenta que si apunte al año lo convierte a int
oanho Proc near
call espaciadores
	mov bx,10
	mov anho,0
	multiplicando:
	mov ax,anho
	cmp byte ptr es:[si],13
	je anhoobtenido
	mul bx

	mov dl,byte ptr es:[si]
	sub dl,30h
	cmp dl,9
	ja numerror
	add al,dl
	mov anho,ax
	inc si
	jmp multiplicando
	
	numerror:
	cmp byte ptr es:[si],20h
	je anhoobtenido
	mov ax,0900h
	lea dx, numeroInvalido
	int 21h
	jmp final
	anhoobtenido:
	call cantidadDiasMes
	ret
endp

;verifica que el mes seleccionado tenga esos dias
cantidadDiasMes proc near
	push ax
	push bx
	push si
	xor ax,ax
	mov al,mes
	mov si,ax
	xor bx,bx
	mov bl,dia
	
	cmp modoHoja,1
	je noHayDia
	cmp bl,0
	je definitivoError
	noHayDia:
	cmp bl,byte ptr diasDeMeses[si]
	ja errorDias
	
	falsaAlarma:
	pop si 
	pop bx
	pop ax
	ret

errorDias:
cmp dia,29
je puedeSerBisiesto
definitivoError:
mov ax,0900h
lea dx,errorDeDia
int 21h
jmp final



puedeSerBisiesto:

xor dx,dx
mov ax,anho
mov bx,400
div bx
cmp dx,0
je falsaAlarma

mov ax,anho
xor dx,dx
mov bx,100
div bx
cmp dx,0
je definitivoError

mov ax,anho
xor dx,dx
mov bx,4
div bx
cmp dx,0
je falsaAlarma

jmp definitivoError


endp


aMinusculas proc near
	push si
	minuscular:
	cmp byte ptr es:[si],13
	je listo
	cmp byte ptr es:[si],20h
	je listo
	cmp byte ptr es:[si],97
	jb disminuir
	inc si
	jmp minuscular
	listo:
	pop si
	ret
	disminuir:
	add byte ptr es:[si],20h
	inc si
	jmp minuscular
endp


;TODO
;asume que si esta apuntado a la primera letra del mes
omes Proc near
call espaciadores
	call aMinusculas
	xchg di,si
	push di

	cicloEnero:
	xor ch,ch
	mov cl, byte ptr enero[0]
	mov si,offset enero
	inc si
	repe cmpsb
	je esEnero

	pop di;regreso al principio de la tira en ES
	push di;guardo de nuevo este numero
	jmp ciclofebrero

	esEnero:
	mov mes,1
	jmp mesIdentificado

	ciclofebrero:
	xor ch,ch
	mov cl, byte ptr febrero[0]
	mov si, offset febrero
	inc si
	repe cmpsb
	je esfebrero
	pop di
	push di
	jmp ciclomarzo
	esfebrero:
	mov mes,2
	jmp mesIdentificado
	ciclomarzo:
	xor ch,ch
	mov cl, byte ptr marzo[0]
	mov si, offset marzo
	inc si
	repe cmpsb
	je esmarzo
	pop di
	push di
	jmp cicloabril
	esmarzo:
	mov mes,3
	jmp mesIdentificado
	cicloabril:
	xor ch,ch
	mov cl, byte ptr abril[0]
	mov si, offset abril
	inc si
	repe cmpsb
	je esabril
	pop di
	push di
	jmp ciclomayo
	esabril:
	mov mes,4
	jmp mesIdentificado
	ciclomayo:
	xor ch,ch
	mov cl, byte ptr mayo[0]
	mov si, offset mayo
	inc si
	repe cmpsb
	je esmayo
	pop di
	push di
	jmp ciclojunio
	esmayo:
	mov mes,5
	jmp mesIdentificado
	ciclojunio:
	xor ch,ch
	mov cl, byte ptr junio[0]
	mov si, offset junio
	inc si
	repe cmpsb
	je esjunio
	pop di
	push di
	jmp ciclojulio
	esjunio:
	mov mes,6
	jmp mesIdentificado
	ciclojulio:
	xor ch,ch
	mov cl, byte ptr julio[0]
	mov si, offset julio
	inc si
	repe cmpsb
	je esjulio
	pop di
	push di
	jmp cicloagosto
	esjulio:
	mov mes,7
	jmp mesIdentificado
	cicloagosto:
	xor ch,ch
	mov cl, byte ptr agosto[0]
	mov si, offset agosto
	inc si
	repe cmpsb
	je esagosto
	pop di
	push di
	jmp cicloseptiembre
	esagosto:
	mov mes,8
	jmp mesIdentificado
	
	cicloseptiembre:
	xor ch,ch
	mov cl, byte ptr septiembre[0]
	mov si, offset septiembre
	inc si
	repe cmpsb
	je esseptiembre
	pop di
	push di
	jmp ciclosetiembre
	esseptiembre:
	mov mes,9
	jmp mesIdentificado
	
	ciclosetiembre:;el caso de escribirlos diferente
	xor ch,ch
	mov cl, byte ptr setiembre[0]
	mov si, offset setiembre
	inc si
	repe cmpsb
	je esseptiembre
	pop di
	push di
	jmp ciclooctubre
	
	
	
	
	ciclooctubre:
	xor ch,ch
	mov cl, byte ptr octubre[0]
	mov si, offset octubre
	inc si
	repe cmpsb
	je esoctubre
	pop di
	push di
	jmp ciclonoviembre
	esoctubre:
	mov mes,10
	jmp mesIdentificado
	ciclonoviembre:
	xor ch,ch
	mov cl, byte ptr noviembre[0]
	mov si, offset noviembre
	inc si
	repe cmpsb
	je esnoviembre
	pop di
	push di
	jmp ciclodiciembre
	esnoviembre:
	mov mes,11
	jmp mesIdentificado

	ciclodiciembre:
	xor ch,ch
	mov cl, byte ptr diciembre[0]
	mov si, offset diciembre
	inc si
	repe cmpsb
	je esdiciembre
	jmp mesIdentificado

	esdiciembre:
	mov mes,12
	jmp mesIdentificado

	mesIdentificado:
	pop si;ocupo deshacerme de esa basura
	mov si,di
	inc si;listo, apuntando al año
	cmp mes,0
	je mesEstaMal
	ret
	mesEstaMal:
	mov ax,0900h
	lea dx, mesMal
	int 21h
	jmp final
endp



; ya se que es un despelote de codigo, pero yo lo entiendo y funciona bien
; cada rutina tiene un nombre significativo, asi que es facil de seguir
imprimeMatriz proc near
	mov ax, 0900h
	lea dx, Dias
	int 21h

	mov cx,6;6 filas
	mov bx, 7

	imprimirSemanas:
	push cx
	xor ah,ah
	xor dx,dx
	mov al,fila
	inc fila
	mov cx,7;7 columnas
	mul bx;resultado en ax
	mov si,ax

	xor dh,dh
	xor ax,ax
	mov dx,186
	call borde
	imprimirDias:
	xor ah,ah
	mov al,superMatrix[si]
	cmp al,0
	je imprimirEspacios
	call espacioUnico
	call convertirImprimir
	call espacioUnico
	imprimioEspacios:
	inc si
	mov dx,186
	call borde
	loop imprimirDias
	call linea
	call separador
	mov dx,185
	call borde
	call linea
	pop cx
	loop imprimirSemanas
	ret
	imprimirEspacios:
	call espacioUnico
	call espacioUnico
	call espacioUnico
	call espacioUnico
	jmp imprimioEspacios
endp




;para cuestiones de imprimir calendario 
espacioUnico proc near
	push ax
	push dx
	mov dx,' '
	mov ax,0200h
	int 21h
	pop dx
	pop ax
	ret
endp

;Imprime un lindo borde 
borde proc near
	push ax
	push dx
	mov ax,0200h
	int 21h
	pop dx
	pop ax
	ret
endp


separador proc near
	
	push ax
	push dx 
	push cx
	mov cx,7;34/numero de 21h en rayitas

	mov ax,0200h
	rayitas:
	mov dx,206
	int 21h
	mov dx,205
	int 21h
	int 21h
	int 21h
	int 21h

	loop rayitas
	pop cx
	pop dx
	pop ax
	ret
endp

;en teoria "si" apunta a un numero, sino entro en paranoia
;agarra el dia de la linea de comandos
odia Proc near
call espaciadores
	mov ah, byte ptr es:[si]
	sub ah,30h
	cmp ah,10
	jnb hazel
	inc si;comparo el siguiente byte con espacio
	cmp byte ptr es:[si],20h
	je soloUno
	mov al, byte ptr es:[si]
	sub al,30h
	cmp al,10
	jnb hazel
	aad;ya tengo el numero convertido
	inc si;deberia ser espacio vacio
	mov bl,byte ptr es:[si]
	mov actual,bl
	cmp byte ptr es:[si],20h
	jne hazel
	inc si;la primera letra del mes en teoria
	yaTengoElDia:
	cmp al,32
	jnb hazel
	mov dia,al
	ret
	
	soloUno:
	xchg ah,al
	inc si
	jmp yaTengoElDia
	hazel:;una amiga me pidio hacer algo con el nombre de ella, asi que hice un error
	mov ax,0900h
	lea dx,LaHazel
	int 21h
	mov ax,4c00h
	int 21h
endp

;codigo propio de mi tarea pasada :P
;utiliza convertir e imprime
convertirImprimir Proc near
	call convertir
	mov ax,0900h
	lea dx, numero
	int 21h
	ret 
endp
;convertir es totalmente funcional
;recibe el numero en ax y me lo convierte a decimal en ascii
convertir Proc near
	push di
	push dx
	push cx
	push bx
	
	
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
	mov byte ptr numero[di], '$'
	
	pop bx
	pop cx
	pop dx
	pop di
	ret
endp

linea proc near 
	mov ah, 02h
	mov dl, 13; retorno de carro
	int 21h
	mov dl, 10; cambio de linea 
	int 21h 
	ret
endp

espaciadores proc near
	espaciosHubo:
	cmp byte ptr es:[si],20h
	jne espacios
	inc si
	jmp espaciosHubo
	espacios:
	ret
	endp
	
final:
	mov ax, 0900h
	lea dx, exitaso
	mov ax, 4C00h
	int 21h

codigo ends
end inicio