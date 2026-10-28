 .data
    arreglo:     .space 256      # Espacio en memoria para guardar las letras
    indice:      .word 0         # Posici�n actual dentro del arreglo
    msj_salida:  .asciiz "\n[Buffer tras 20 segundos]: "
    salto_linea: .asciiz "\n"

    respaldo_t0: .word 0
    respaldo_t1: .word 0
    respaldo_t2: .word 0

.text
principal:
 
    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    ori $t1, $t1, 0x0002        # Activar el bit de interrupci�n (Bit 1)
    sw $t1, 0($t0)

    mfc0 $t0, $12
    ori $t0, $t0, 0x0101        # Activar Global Interrupt Enable
    mtc0 $t0, $12

reiniciar_reloj:
    li $v0, 30                  # Syscall para obtener el tiempo del sistema
    syscall
    move $s0, $a0               # Guardar el tiempo inicial

bucle_principal:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0          # Tiempo actual - Tiempo inicial
    li $t1, 20000               # 20 segundos = 20,000 milisegundos
    bltu $t0, $t1, bucle_principal # Si no han pasado 20s, sigue esperando

    la $a0, msj_salida
    li $v0, 4
    syscall

    lw $t2, indice
    la $t3, arreglo
    add $t4, $t3, $t2
    sb $zero, 0($t4)

    move $a0, $t3
    li $v0, 4
    syscall
    
    la $a0, salto_linea
    li $v0, 4
    syscall

    sw $zero, indice
    j reiniciar_reloj

.text 0x80000180
rutina_interrupcion:
   
    sw $t0, respaldo_t0
    sw $t1, respaldo_t1
    sw $t2, respaldo_t2

    mfc0 $t0, $13
    andi $t0, $t0, 0x0100
    beq $t0, $zero, fin_interrupcion

    li $t0, 0xFFFF0004
    lw $t1, 0($t0)

    blt $t1, 65, fin_interrupcion
    bgt $t1, 90, fin_interrupcion

    lw $t0, indice
    li $t2, 255                 # L�mite para no da�ar la memoria
    beq $t0, $t2, fin_interrupcion       
    
    la $t2, arreglo
    add $t2, $t2, $t0           
    sb $t1, 0($t2)              
    
    addi $t0, $t0, 1            # Sumar 1 al �ndice
    sw $t0, indice

fin_interrupcion:

    lw $t2, respaldo_t2
    lw $t1, respaldo_t1
    lw $t0, respaldo_t0
    eret
