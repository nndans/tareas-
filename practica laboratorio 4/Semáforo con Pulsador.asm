.data
    boton_presionado: .word 0     # Bandera: 0 = No pulsado, 1 = Pulsado
    msj_verde:        .asciiz "\nSemaforo en verde, esperando pulsador...\n"
    msj_boton:        .asciiz "\nPulsador activado: en 20 segundos, el semaforo cambiara a amarillo.\n"
    msj_amarillo:     .asciiz "\nSemaforo en amarillo, en 10 segundos, semaforo en rojo.\n"
    msj_rojo:         .asciiz "\nSemaforo en rojo, en 30 segundos, semaforo en verde.\n"

    respaldo_t0:      .word 0
    respaldo_t1:      .word 0

.text
principal:

    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    ori $t1, $t1, 0x0002
    sw $t1, 0($t0)

    mfc0 $t0, $12
    ori $t0, $t0, 0x0101
    mtc0 $t0, $12

estado_verde:

    sw $zero, boton_presionado
    la $a0, msj_verde
    li $v0, 4
    syscall

esperar_pulsador:

    lw $t0, boton_presionado
    beq $t0, $zero, esperar_pulsador 

    la $a0, msj_boton
    li $v0, 4
    syscall

    li $a0, 20000
    li $v0, 32
    syscall

    la $a0, msj_amarillo
    li $v0, 4
    syscall

    li $a0, 10000
    li $v0, 32
    syscall

    la $a0, msj_rojo
    li $v0, 4
    syscall

    li $a0, 30000
    li $v0, 32
    syscall

    j estado_verde

.text 0x80000180
rutina_interrupcion:

    sw $t0, respaldo_t0
    sw $t1, respaldo_t1

    mfc0 $t0, $13
    andi $t0, $t0, 0x0100
    beq $t0, $zero, fin_interrupcion

    li $t0, 0xFFFF0004
    lw $t1, 0($t0)

    beq $t1, 115, activar_bandera
    beq $t1, 83, activar_bandera
    j fin_interrupcion

activar_bandera:

    li $t0, 1
    sw $t0, boton_presionado

fin_interrupcion:

    lw $t1, respaldo_t1
    lw $t0, respaldo_t0
    eret
