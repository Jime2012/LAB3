;Archivo: Lab3.s
;Dispositivo: PIC16F887
;Autor: Jimena de la Rosa
;Compilador: pic-as (v2.30). MPLABX v5.40
;Programa: laboratorio 1
;Hardware: LEDs en el puerto A
;Creado: 07 FEB, 2022
;Ultima modificacion: 07 FEB, 2022
    
PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
PSECT UDATA_BANK0,global,class=RAM,space=1,delta=1,noexec
  
  GLOBAL  CONT, ASCII, CONT_SEG 
    
  CONT: DS 1; SE NOMBRAN LAS VARIBLES A UTILIZAR
  ASCII: DS 1
  CONT_SEG: DS 1

PSECT resVect, class=CODE, abs, delta=2
ORG 000h ; posicion del vector de reseteo

resVect:
    GOTO main

PSECT CODE, delta=2, abs
ORG 100h
 
;configuraciones

main:
    CALL CONFIG_RELOJ
    CALL CONFIG_TMR0
    BSF	    STATUS, 5
    BSF	    STATUS, 6; BANCO 3 
    CLRF    ANSEL
    CLRF    ANSELH
    
    BCF	    STATUS,6 ; BANCO 1
    BSF	    TRISA, 0 ; RA0 como entrada
    BSF	    TRISA, 1 ; RA1 como entrada
    MOVLW   0xF0     ; usar 11110000 para dejar solo 4 bits de salida
    MOVWF   TRISB    ; usar esa configuracion en la salida B
    MOVWF   TRISD    ; usar esa configuracion en la salida d  
    CLRF    TRISC    ; usar esa configuracion en la salida C
    BCF	    STATUS, 5; banco 00
    CLRF    PORTB    ; se quita lo que exista en la salida B
    CLRF    PORTC    ; se quita lo que exista en la salida C
    CLRF    PORTD    ; se quita lo que exista en la salida D
    CLRF    CONT    ; se limpia las salidas de los contadores
    CLRF    CONT_SEG
    CLRF    ASCII
    
    
;RUTINA PRINCIPAL
    
CHECKBOTON:
    CALL CONTADOR_SEG; se llama el contador de seg
    INCF PORTD, F; SE INCREMENTA 1
    MOVF ASCII, W; se mueve el valor del contador a W
    SUBWF PORTD, W; se resta el valor del PortD a W
    BANKSEL STATUS
    BTFSS STATUS, 2; se revisa si la resta es igual a cero
    GOTO CHECKBOTON; si tiene se regresa
    BCF  PORTD, 0; REINICIAR EL CONTADOR DE SEGUNDOS
    BCF  PORTD, 1; REINICIAR EL CONTADOR DE SEGUNDOS
    BCF  PORTD, 2; REINICIAR EL CONTADOR DE SEGUNDOS
    BCF  PORTD, 3; REINICIAR EL CONTADOR DE SEGUNDOS
    BTFSC PORTD, 4; se revisa si el bit esta encendido 
    GOTO $+2 ; si esta, se adelanta dos instrucciones
    BSF PORTD, 4; si no esta encendido, se enciende
    BTFSS PORTD, 4; se revisa si esta encendido
    GOTO $+2; si  no esta encendido, se adelanta dos casillas
    BCF PORTD,4; si esta encendido, se apaga
    GOTO CHECKBOTON; volver a revisar botones
    
    
BOTON1:
    BTFSC PORTA, 0; se revisa que no se siga apachando el boton
    GOTO BOTON1 ; si no se repite la funcion
    MOVF CONT, W ; se mueve el valor del contador al W
    MOVWF ASCII ; se copia el valor al otro contador
    MOVF CONT, W ; se vuelve a poner el valor en W
    CALL TABLA ; se llama a la tabla
    MOVWF PORTC; se ubica el valor de la tabla en la salida C
    INCF CONT ; se incrementa el contador
    BTFSC CONT, 4; se revisa que el contador no tenga mas de 4 bits
    CLRF CONT; si tiene mas de 4 bits se reinicia
    RETURN
    
BOTON2:
    BTFSC PORTA,1 ; se revisa que no se siga apachando el boton
    GOTO BOTON2; si no se repite la funcion
    CLRF ASCII; SE LIMPIA EL VALOR
    MOVF CONT, W; se mueve el valor del contador a W
    MOVWF ASCII; se mueve el valor de W a ASCII
    MOVF CONT, W; se mueve el valor del conatdor a W
    CALL TABLA; se llama la tabla
    MOVWF PORTC; se mueve el valor de w de la tabla a C
    DECF CONT; se decrementa el contador
    BTFSC CONT, 4; se revisa que solo hayan 4 bits
    CLRF CONT; si hay mas, se limpia
    RETURN  
;subrutinas

ORG 200H
TABLA:
    CLRF PCLATH
    BSF  PCLATH, 1
    ANDLW 0X0F; SE ASEGURA QUE SOLO EXISTAN 4 BITS
    ADDWF PCL
    RETLW 01000000B;0
    RETLW 01111001B;1
    RETLW 00100100B;2
    RETLW 00110000B;3
    RETLW 00011001B;4
    RETLW 00010010B;5
    RETLW 00000010B;6
    RETLW 01111000B;7
    RETLW 00000000B;8
    RETLW 00010000B;9
    RETLW 00001000B;A
    RETLW 00000011B;B
    RETLW 01000110B;C
    RETLW 00100001B;D
    RETLW 00000110B;E
    RETLW 00001110B;F

CONFIG_RELOJ:
    BANKSEL OSCCON
    BSF OSCCON, 0; RELOJ INTERNO
    BCF OSCCON, 4; OSCILADOR DE 1MH
    BCF OSCCON, 5
    BSF OSCCON, 6
    RETURN
    
CONFIG_TMR0:
   BANKSEL OPTION_REG
    BCF PSA
    BCF PS0; PRESCALER DE 1:128
    BSF PS1
    BSF PS2 
    BCF T0CS ; RELOJ INTERNO
    MOVLW 61 ; 100MS
    
    BANKSEL TMR0
    MOVWF TMR0 ; CARGAMOS EL VALOR INICIAL
    BCF   T0IF; LIMPIAMOS LA BANDERA
    RETURN
    
REINICIO_TMR0:
    BANKSEL TMR0
    MOVLW   61		; 100 ms 
    MOVWF   TMR0	; Cargamos valor inicial
    BCF	    T0IF	; Limpiamos bandera
    RETURN

CONTADOR_SEG:
    MOVLW  10	    ; ESCRIBIR 10 EN W
    MOVWF  CONT_SEG     ;PASAR EL 10 A CONT_SEG
    BTFSS T0IF; SE REVISA SI ESTA ENCENDIDO
    GOTO $-1	 ; SI NO ESTA ENCENDIDO REGRESA AL INICIO
    BTFSC PORTA, 0 ;si el boton no esta presionado, saltar a la otra inst
    CALL  BOTON1   ; si esta presionado ir a la instruccion del boton 
    BTFSC PORTA, 1 ; se repite con el resto de botones
    CALL  BOTON2
    CALL REINICIO_TMR0; SI ESTA ENCENDIDO, SE REINICIA EL TMR0
    INCF PORTB, F; SE INCREMENTA 1
    DECFSZ CONT_SEG, 1  ;DECRECER 1 EN CONT_SEG
    GOTO   $-9	    ;REPETIR LA INSTRUCCION DESDE  CHECAR EL T0IF
    RETURN		    
END



