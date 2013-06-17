/*
 ============================================================================
 Name        : memcpy.S
 Author      : Heiher <admin@heiher.info>
 Version     : 0.0.1
 Copyright   : Copyright (c) 2013 everyone.
 Description : 
 ============================================================================
 */

#include <sys/regdef.h>

/* void * memcpy (void *s1, const void *s2, size_t n); */
    .text    
    .align  2
    .globl  memcpy
    .ent    memcpy, 0
    .set    push
    .set    noreorder    
    .set    noat
    .set    arch=loongson3a

memcpy:
    .cpload jp
    /* Calculate memcpy sub entry index */
    /* s1 */
    ori     t0, zero, 0x8
    andi    t2, a0, 0xf /* 16-byte */
    sgt     t2, t2, zero
    srl     t0, t0, t2
    andi    t2, a0, 0x7 /* 8-byte */
    sgt     t2, t2, zero
    srl     t0, t0, t2
    andi    t2, a0, 0x3 /* 4-byte */
    sgt     t2, t2, zero
    srl     t0, t0, t2
    andi    t2, a0, 0x1 /* 2-byte */
    sgt     t2, t2, zero
    srl     t0, t0, t2
    sll     t0, t0, 0x4
    /* s2 */
    ori     t1, zero, 0x8
    andi    t2, a1, 0xf /* 16-byte */
    sgt     t2, t2, zero
    srl     t1, t1, t2
    andi    t2, a1, 0x7 /* 8-byte */
    sgt     t2, t2, zero
    srl     t1, t1, t2
    andi    t2, a1, 0x3 /* 4-byte */
    sgt     t2, t2, zero
    srl     t1, t1, t2
    andi    t2, a1, 0x1 /* 2-byte */
    sgt     t2, t2, zero
    srl     t1, t1, t2
    or      t0, t0, t1
    sll     t0, t0, 0x2
    lw      t2, %got(memcpy_entries)(gp)
    addu    t2, t2, t0
    lw      t2, %lo(memcpy_entries)(t2)
    /* Jump to target memcpy entry */
    jr      t2
    or      v0, a0, zero

memcpy_16_16:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_8_8
    nop
    gslq    t0, t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    gssq    t0, t1, 0x0(a0)
    b       memcpy_16_16
    addiu   a0, a0, 0x10
memcpy_16_8:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_8_8
    nop
    ld      t0, 0x8(a1)
    ld      t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    gssq    t0, t1, 0x0(a0)
    b       memcpy_16_8
    addiu   a0, a0, 0x10
memcpy_16_4:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_4_4
    nop
    ldl     t0, 0xf(a1)
    ldr     t0, 0x8(a1)
    ldl     t1, 0x7(a1)
    ldr     t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    gssq    t0, t1, 0x0(a0)
    b       memcpy_16_4
    addiu   a0, a0, 0x10
memcpy_16_2:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_2_2
    daddi   t3, zero, -1
    dsrl    t3, t3, 32
    lwl     t2, 0xf(a1)
    lwr     t2, 0xc(a1)
    dsll    t2, t2, 32
    lwl     t0, 0xb(a1)
    lwr     t0, 0x8(a1)
    and     t0, t0, t3
    or      t0, t0, t2
    lwl     t2, 0x7(a1)
    lwr     t2, 0x4(a1)
    dsll    t2, t2, 32
    lwl     t1, 0x3(a1)
    lwr     t1, 0x0(a1)
    and     t1, t1, t3
    or      t1, t1, t2
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    gssq    t0, t1, 0x0(a0)
    b       memcpy_16_2
    addiu   a0, a0, 0x10
memcpy_16_1:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_1_1
    nop
    lbu     t7, 0xf(a1)
    dsll    t7, t7, 56
    lbu     t6, 0xe(a1)
    dsll    t6, t6, 48
    or      t5, t6, t7
    lbu     t7, 0xd(a1)
    dsll    t7, t7, 40
    lbu     t6, 0xc(a1)
    dsll    t6, t6, 32
    or      t4, t6, t7
    lbu     t7, 0xb(a1)
    dsll    t7, t7, 24
    lbu     t6, 0xa(a1)
    dsll    t6, t6, 16
    or      t3, t6, t7
    lbu     t7, 0x9(a1)
    dsll    t7, t7, 8
    lbu     t0, 0x8(a1)
    or      t6, t7, t3
    or      t0, t0, t6
    or      t6, t4, t5
    or      t0, t0, t6
    lbu     t7, 0x7(a1)
    dsll    t7, t7, 56
    lbu     t6, 0x6(a1)
    dsll    t6, t6, 48
    or      t5, t6, t7
    lbu     t7, 0x5(a1)
    dsll    t7, t7, 40
    lbu     t6, 0x4(a1)
    dsll    t6, t6, 32
    or      t4, t6, t7
    lbu     t7, 0x3(a1)
    dsll    t7, t7, 24
    lbu     t6, 0x2(a1)
    dsll    t6, t6, 16
    or      t3, t6, t7
    lbu     t7, 0x1(a1)
    dsll    t7, t7, 8
    lbu     t1, 0x0(a1)
    or      t6, t7, t3
    or      t1, t1, t6
    or      t6, t4, t5
    or      t1, t1, t6
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    gssq    t0, t1, 0x0(a0)
    b       memcpy_16_1
    addiu   a0, a0, 0x10
memcpy_8_16:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_8_8
    nop
    gslq    t0, t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    sd      t0, 0x8(a0)
    sd      t1, 0x0(a0)
    b       memcpy_8_16
    addiu   a0, a0, 0x10
memcpy_8_8:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_4_4
    nop
    ld      t0, 0x0(a1)
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sd      t0, 0x0(a0)
    b       memcpy_8_8
    addiu   a0, a0, 0x8
memcpy_8_4:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_4_4
    nop
    ldl     t0, 0x7(a1)
    ldr     t0, 0x0(a1)
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sd      t0, 0x0(a0)
    b       memcpy_8_4
    addiu   a0, a0, 0x8
memcpy_8_2:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_2_2
    daddi   t3, zero, -1
    dsrl    t3, t3, 32
    lwl     t2, 0x7(a1)
    lwr     t2, 0x4(a1)
    dsll    t2, t2, 32
    lwl     t0, 0x3(a1)
    lwr     t0, 0x0(a1)
    and     t0, t0, t3
    or      t0, t0, t2
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sd      t0, 0x0(a0)
    b       memcpy_8_2
    addiu   a0, a0, 0x8
memcpy_8_1:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_1_1
    nop
    lbu     t7, 0x7(a1)
    dsll    t7, t7, 56
    lbu     t6, 0x6(a1)
    dsll    t6, t6, 48
    or      t5, t6, t7
    lbu     t7, 0x5(a1)
    dsll    t7, t7, 40
    lbu     t6, 0x4(a1)
    dsll    t6, t6, 32
    or      t4, t6, t7
    lbu     t7, 0x3(a1)
    dsll    t7, t7, 24
    lbu     t6, 0x2(a1)
    dsll    t6, t6, 16
    or      t3, t6, t7
    lbu     t7, 0x1(a1)
    dsll    t7, t7, 8
    lbu     t0, 0x0(a1)
    or      t6, t7, t3
    or      t0, t0, t6
    or      t6, t4, t5
    or      t0, t0, t6
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sd      t0, 0x0(a0)
    b       memcpy_8_1
    addiu   a0, a0, 0x8
memcpy_4_16:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_4_4
    nop
    gslq    t0, t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    sdl     t1, 0x7(a0)
    sdr     t1, 0x0(a0)
    sdl     t0, 0xf(a0)
    sdr     t0, 0x8(a0)
    b       memcpy_4_16
    addiu   a0, a0, 0x10
memcpy_4_8:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_4_4
    nop
    ld      t0, 0x0(a1)
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sdl     t0, 0x7(a0)
    sdr     t0, 0x0(a0)
    b       memcpy_4_8
    addiu   a0, a0, 0x8
memcpy_4_4:
    slti    AT, a2, 0x4
    bnez    AT, memcpy_2_2
    nop
    lwu     t0, 0x0(a1)
    addiu   a1, a1, 0x4
    addi    a2, a2, -0x4
    sw      t0, 0x0(a0)
    b       memcpy_4_4
    addiu   a0, a0, 0x4
memcpy_4_2:
    slti    AT, a2, 0x4
    bnez    AT, memcpy_2_2
    nop
    lwl     t0, 0x3(a1)
    lwr     t0, 0x0(a1)
    addiu   a1, a1, 0x4
    addi    a2, a2, -0x4
    sw      t0, 0x0(a0)
    b       memcpy_4_2
    addiu   a0, a0, 0x4
memcpy_4_1:
    slti    AT, a2, 0x4
    bnez    AT, memcpy_1_1
    nop
    lbu     t7, 0x3(a1)
    dsll    t7, t7, 24
    lbu     t6, 0x2(a1)
    dsll    t6, t6, 16
    or      t5, t6, t7
    lbu     t4, 0x1(a1)
    dsll    t4, t4, 8
    or      t3, t4, t5
    lbu     t0, 0x0(a1)
    or      t0, t0, t3
    addiu   a1, a1, 0x4
    addi    a2, a2, -0x4
    sw      t0, 0x0(a0)
    b       memcpy_4_1
    addiu   a0, a0, 0x4
memcpy_2_16:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_2_2
    nop
    gslq    t0, t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    swl     t1, 0x3(a0)
    swr     t1, 0x0(a0)
    dsrl    t1, t1, 32
    swl     t1, 0x7(a0)
    swr     t1, 0x4(a0)
    swl     t0, 0xb(a0)
    swr     t0, 0x8(a0)
    dsrl    t0, t0, 32
    swl     t0, 0xf(a0)
    swr     t0, 0xc(a0)
    b       memcpy_2_16
    addiu   a0, a0, 0x10
memcpy_2_8:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_2_2
    nop
    ld      t0, 0x0(a1)
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    swl     t0, 0x3(a0)
    swr     t0, 0x0(a0)
    dsrl    t0, t0, 32
    swl     t0, 0x7(a0)
    swr     t0, 0x4(a0)
    b       memcpy_2_8
    addiu   a0, a0, 0x8
memcpy_2_4:
    slti    AT, a2, 0x4
    bnez    AT, memcpy_2_2
    nop
    lwu     t0, 0x0(a1)
    addiu   a1, a1, 0x4
    addi    a2, a2, -0x4
    swl     t0, 0x3(a0)
    swr     t0, 0x0(a0)
    b       memcpy_2_4
    addiu   a0, a0, 0x4
memcpy_2_2:
    slti    AT, a2, 0x2
    bnez    AT, memcpy_1_1
    nop
    lhu     t0, 0x0(a1)
    addiu   a1, a1, 0x2
    addi    a2, a2, -0x2
    sh      t0, 0x0(a0)
    b       memcpy_2_2
    addiu   a0, a0, 0x2
memcpy_2_1:
    slti    AT, a2, 0x2
    bnez    AT, memcpy_1_1
    nop
    lbu     t1, 0x1(a1)
    dsll    t1, t1, 8
    lbu     t0, 0x0(a1)
    or      t0, t0, t1
    addiu   a1, a1, 0x2
    addi    a2, a2, -0x2
    sh      t0, 0x0(a0)
    b       memcpy_2_1
    addiu   a0, a0, 0x2
memcpy_1_16:
    slti    AT, a2, 0x10
    bnez    AT, memcpy_1_1
    nop
    gslq    t0, t1, 0x0(a1)
    addiu   a1, a1, 0x10
    addi    a2, a2, -0x10
    sb      t1, 0x0(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x1(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x2(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x3(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x4(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x5(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x6(a0)
    dsrl    t1, t1, 8
    sb      t1, 0x7(a0)
    sb      t0, 0x8(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x9(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xa(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xb(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xc(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xd(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xe(a0)
    dsrl    t0, t0, 8
    sb      t0, 0xf(a0)
    b       memcpy_1_16
    addiu   a0, a0, 0x10
memcpy_1_8:
    slti    AT, a2, 0x8
    bnez    AT, memcpy_1_1
    nop
    ld      t0, 0x0(a1)
    addiu   a1, a1, 0x8
    addi    a2, a2, -0x8
    sb      t0, 0x0(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x1(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x2(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x3(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x4(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x5(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x6(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x7(a0)
    b       memcpy_1_8
    addiu   a0, a0, 0x8
memcpy_1_4:
    slti    AT, a2, 0x4
    bnez    AT, memcpy_1_1
    nop
    lwu     t0, 0x0(a1)
    addiu   a1, a1, 0x4
    addi    a2, a2, -0x4
    sb      t0, 0x0(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x1(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x2(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x3(a0)
    b       memcpy_1_4
    addiu   a0, a0, 0x4
memcpy_1_2:
    slti    AT, a2, 0x2
    bnez    AT, memcpy_1_1
    nop
    lhu     t0, 0x0(a1)
    addiu   a1, a1, 0x2
    addi    a2, a2, -0x2
    sb      t0, 0x0(a0)
    dsrl    t0, t0, 8
    sb      t0, 0x1(a0)
    b       memcpy_1_2
    addiu   a0, a0, 0x2
memcpy_1_1:
    blez    a2, _memcpy_finish
    addu    a3, a1, a2
    lbu     t0, 0x0(a1)
_memcpy_1_1_loop:
    addiu   a0, a0, 0x1
    addiu   a1, a1, 0x1
    sb      t0, -1(a0)
    bne     a1, a3, _memcpy_1_1_loop
    lbu     t0, 0x0(a1)
_memcpy_finish:
    jr      ra
    nop

    .end    memcpy
    .set    pop

    .data
    .align   2
    .type    memcpy_entries, @object
    .size    memcpy_entries, 548
memcpy_entries:
    .word    memcpy_1_1
    .word    memcpy_1_2
    .word    memcpy_1_4
    .space   4
    .word    memcpy_1_8
    .space   12
    .word    memcpy_1_16
    .space   28
    .word    memcpy_2_1
    .word    memcpy_2_2
    .word    memcpy_2_4
    .space   4
    .word    memcpy_2_8
    .space   12
    .word    memcpy_2_16
    .space   28
    .word    memcpy_4_1
    .word    memcpy_4_2
    .word    memcpy_4_4
    .space   4
    .word    memcpy_4_8
    .space   12
    .word    memcpy_4_16
    .space   92
    .word    memcpy_8_1
    .word    memcpy_8_2
    .word    memcpy_8_4
    .space   4
    .word    memcpy_8_8
    .space   12
    .word    memcpy_8_16
    .space   220
    .word    memcpy_16_1
    .word    memcpy_16_2
    .word    memcpy_16_4
    .space   4
    .word    memcpy_16_8
    .space   12
    .word    memcpy_16_16

