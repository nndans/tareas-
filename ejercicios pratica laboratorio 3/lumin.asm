.data
LuzControl: .word 0
LuzEstado:  .word 0
LuzDatos:   .word 0

.text
.globl main

main:
    # 1. Iniciar el sensor
    jal InicializarSensorLuz
    
    # 2. Leer los datos recuperados
    jal LeerLuminosidad
    
    # 3. Salir del programa
    li $v0, 10
    syscall

InicializarSensorLuz:
    la $t0, LuzControl
    li $t1, 1
    sw $t1, 0($t0)          # Escribe 1 en LuzControl (enciende el sensor)

espera_init:
    la $t0, LuzEstado
    lw $t1, 0($t0)          # Lee el estado del hardware
    beq $t1, $zero, espera_init  # Si vale 0, reintenta (espera activa)
    
    jr $ra                  # Retorna si cambio a 1 o -1

LeerLuminosidad:
    la $t0, LuzEstado
    lw $t1, 0($t0)          # Carga el estado actual
    
    li $t2, -1
    beq $t1, $t2, error_sensor   # Si es -1, salta a la rutina de error
    
    la $t0, LuzDatos
    lw $v0, 0($t0)          # $v0 = valor de luz leido
    li $v1, 0               # $v1 = 0 (lectura correcta)
    jr $ra

error_sensor:
    li $v0, 0               # $v0 = 0 (sin dato valido)
    li $v1, -1              # $v1 = -1 (codigo de error)
    jr $ra