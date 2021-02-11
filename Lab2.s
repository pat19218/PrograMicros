 ;Archivo:	Lab1.S
 ;Dispositivo:	PIC16f887
 ;Autor:	Cristhofer Patzan
 ;Compilador:	pic-as (v2.30), MPLABX V5.40
 ;
 ;Programa:	contadores con push buttons
 ;Hardware:	LEDs en el puerto B y D, Button en el puerto A
 ;
 ;Creado: 9 feb, 2021
 ;Última modificación: 9 feb, 2021

 ;------------------------------------------------------------------------------
 ; Configuration word 1
 ; PIC16F887 Configuration Bit Settings
 ; Assembly source line config statements
 ;------------------------------------------------------------------------------
 PROCESSOR 16F887
 #include <xc.inc>

; CONFIG1
  CONFIG  FOSC = XT		; Oscillator Selection bits (RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
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

 ;------------------------------------------------------------------------------
 ;  Variables
 ;------------------------------------------------------------------------------
 
 PSECT udata_bank0  ;common memory //Program sector en el banco 0
    cont:   DS 1 ;1 byte

    
 PSECT resVect, class=CODE, abs, delta=2
 ;------------------------------------------------------------------------------
 ;  Vector reset
 ;------------------------------------------------------------------------------
 
 ORG 00h    ;  posición 0000h para el reset
 resetVec:
    PAGESEL main
    goto main
    
    
 PSECT code, delta=2, abs
 ORG 100h   ;posicion para el código
 
 ;------------------------------------------------------------------------------
 ;  Configuracion microprcesador
 ;------------------------------------------------------------------------------
 
 main:
    banksel ANSEL   ;Selecciono el banco donde esta ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISA
    bsf	    TRISA, 0	;Confi. pines del puerto A como entrada
    bsf	    TRISA, 1
    bsf	    TRISA, 2
    bsf	    TRISA, 3
    bsf	    TRISA, 4
    
    clrf    TRISB	;Confi. pines del puerto B, C y D como salida
    bsf	    TRISB, 5	;Desactivo puertos para que solo sean 4 bits.
    bsf	    TRISB, 6
    bsf	    TRISB, 7

    clrf    TRISD
    bsf	    TRISD, 4
    bsf	    TRISD, 5
    bsf	    TRISD, 6
    bsf	    TRISD, 7
    
    clrf    TRISC
    bsf	    TRISC, 4
    bsf	    TRISC, 5
    bsf	    TRISC, 6
    bsf	    TRISC, 7
    
    banksel PORTB   ;Me asegure que empiece en cero
    clrf    PORTB
    clrf    PORTD 
    clrf    PORTC 
    
 ;------------------------------------------------------------------------------
 ;  loop principal
 ;------------------------------------------------------------------------------
 
  loop:
    ;parte 1 CONTADOR 1
    btfsc    PORTA, 0	
    call     inc_portc	
    btfsc    PORTA, 1	
    call     dec_portc	
    
    ;parte 2 CONTADOR 2
    btfsc    PORTA, 2	
    call     inc_portd	
    btfsc    PORTA, 3	
    call     dec_portd	
    
    ;parte 3 SUMA CON CARRY
    btfsc    PORTA, 4
    call     suma_port
    goto     loop		; loop 4ever
  
 ;------------------------------------------------------------------------------
 ;	sub rutinas
 ;------------------------------------------------------------------------------
 
  inc_portc:		; loop de incremento de bit por botonazo
    btfsc   PORTA, 0	;
    goto    $-1
    incf    PORTC, F	;
    return
  
  dec_portc:		; loop de incremento de bit por botonazo
    btfsc   PORTA, 1	;
    goto    $-1
    decf    PORTC, F	;
    return
    
  inc_portd:		; loop de incremento de bit por botonazo
    btfsc   PORTA, 2	;
    goto    $-1
    incf    PORTD, F	;
    return
  
  dec_portd:		; loop de incremento de bit por botonazo
    btfsc   PORTA, 3	;
    goto    $-1
    decf    PORTD, F	;
    return
   
  suma_port:
    movf    PORTC, 0	;guardo los datos del puerto C
    addwf   PORTD, 0	;sumo los datos del puerto C con los datos del puerto D
    movwf   PORTB	;Muevo los resultados al puerto B
    btfsc   PORTA, 4	;si A4 es 0 limpio y salgo, si es 1 repito el codigo
    goto    $-4
    clrf    PORTB
    return
    
END



