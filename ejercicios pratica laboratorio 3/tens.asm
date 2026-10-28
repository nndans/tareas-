.data
.data
TensionControl: .word 0
TensionEstado:  .word 0
TensionSistol:  .word 0
TensionDiastol: .word 0

.text
.globl main

main:
    # 1. Ejecutar la medicion de presion
    jal controlador_tension
    
    # 2. Salir del programa
    li $v0, 10
    syscall

controlador_tension:
    la $t0, TensionControl
    li $t1, 1
    sw $t1, 0($t0)          # Escribe 1 en TensionControl para iniciar

espera_medicion:
    la $t0, TensionEstado
    lw $t1, 0($t0)          # Carga el estado del equipo
    beq $t1, $zero, espera_medicion  # Mientras sea 0, sigue midiendo
    
    la $t0, TensionSistol
    lw $v0, 0($t0)          # Carga la sistolica en $v0
    
    la $t0, TensionDiastol
    lw $v1, 0($t0)          # Carga la diastolica en $v1
    
    jr $ra                  # Retorna al main