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

    .type    memcpy_entries, @object
    .size    memcpy_entries, 548
memcpy_entries:
    .word    memcpy_16_16
    .word    memcpy_16_1
    .word    memcpy_16_2
    .space   4
    .word    memcpy_16_4
    .space   12
    .word    memcpy_16_8
    .space   28
    .word    memcpy_1_16
    .word    memcpy_1_1
    .word    memcpy_1_2
    .space   4
    .word    memcpy_1_4
    .space   12
    .word    memcpy_1_8
    .space   28
    .word    memcpy_2_16
    .word    memcpy_2_1
    .word    memcpy_2_2
    .space   4
    .word    memcpy_2_4
    .space   12
    .word    memcpy_2_8
    .space   92
    .word    memcpy_4_16
    .word    memcpy_4_1
    .word    memcpy_4_2
    .space   4
    .word    memcpy_4_4
    .space   12
    .word    memcpy_4_8
    .space   220
    .word    memcpy_8_16
    .word    memcpy_8_1
    .word    memcpy_8_2
    .space   4
    .word    memcpy_8_4
    .space   12
    .word    memcpy_8_8

memcpy:
    /* Calculate memcpy sub entry index */
    /* s1 */
    andi    t2, a0, 0xf
    subu    t1, zero, t2
    and     t1, t1, t2
    sll     t1, t1, 0x4
    /* s2 */
    andi    t2, a1, 0xf
    subu    t0, zero, t2
    and     t0, t0, t2
    or      t0, t0, t1
    sll     t0, t0, 0x2
    addiu   t2, jp, memcpy_entries-memcpy
    addu    t2, t2, t0
    lw      t2, 0x0(t2)
    /* Jump to target memcpy entry */
    jr      t2
    or      v0, a0, zero

memcpy_16_16:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_8_8
    subu    a3, a2, AT
    addu    a3, a3, a1
    gslq    t0, t1, 0x0(a1)
_memcpy_16_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_16_loop
    gslq    t0, t1, 0x0(a1)
    bgtz    AT, memcpy_8_8
    or      a2, AT, zero
    jr      ra
    nop

memcpy_16_8:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_8_8
    subu    a3, a2, AT
    addu    a3, a3, a1
    ld      t0, 0x8(a1)
_memcpy_16_8_loop:
    ld      t1, 0x0(a1)
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_8_loop
    ld      t0, 0x8(a1)
    bgtz    AT, memcpy_8_8
    or      a2, AT, zero
    jr      ra
    nop

memcpy_16_4:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_4_4
    subu    a3, a2, AT
    addu    a3, a3, a1
    ldl     t0, 0xf(a1)
_memcpy_16_4_loop:
    ldr     t0, 0x8(a1)
    ldl     t1, 0x7(a1)
    ldr     t1, 0x0(a1)
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_4_loop
    ldl     t0, 0xf(a1)
    bgtz    AT, memcpy_4_4
    or      a2, AT, zero
    jr      ra
    nop

memcpy_16_2:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwl     t2, 0xf(a1)
_memcpy_16_2_loop:
    lwr     t2, 0xc(a1)
    lwl     t0, 0xb(a1)
    lwr     t0, 0x8(a1)
    .set    arch=mips64r2
    dins    t0, t2, 32, 32
    lwl     t2, 0x7(a1)
    lwr     t2, 0x4(a1)
    lwl     t1, 0x3(a1)
    lwr     t1, 0x0(a1)
    dins    t1, t2, 32, 32
    .set    arch=loongson3a
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_2_loop
    lwl     t2, 0xf(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_16_1:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lbu     t0, 0x8(a1)
_memcpy_16_1_loop:
    lbu     t2, 0x9(a1)
    .set    arch=mips64r2
    dins    t0, t2, 8, 8
    lbu     t2, 0xa(a1)
    dins    t0, t2, 16, 8
    lbu     t2, 0xb(a1)
    dins    t0, t2, 24, 8
    lbu     t2, 0xc(a1)
    dins    t0, t2, 32, 8
    lbu     t2, 0xd(a1)
    dins    t0, t2, 40, 8
    lbu     t2, 0xe(a1)
    dins    t0, t2, 48, 8
    lbu     t2, 0xf(a1)
    dins    t0, t2, 56, 8
    lbu     t1, 0x0(a1)
    lbu     t2, 0x1(a1)
    dins    t1, t2, 8, 8
    lbu     t2, 0x2(a1)
    dins    t1, t2, 16, 8
    lbu     t2, 0x3(a1)
    dins    t1, t2, 24, 8
    lbu     t2, 0x4(a1)
    dins    t1, t2, 32, 8
    lbu     t2, 0x5(a1)
    dinsu   t1, t2, 40, 8
    lbu     t2, 0x6(a1)
    dinsu   t1, t2, 48, 8
    lbu     t2, 0x7(a1)
    dinsu   t1, t2, 56, 8
    .set    arch=loongson3a
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_1_loop
    lbu     t0, 0x8(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_8_16:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_8_8
    subu    a3, a2, AT
    addu    a3, a3, a1
    gslq    t0, t1, 0x0(a1)
_memcpy_8_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    sd      t0, -0x08(a0)
    sd      t1, -0x10(a0)
    bnel    a1, a3, _memcpy_8_16_loop
    gslq    t0, t1, 0x0(a1)
    bgtz    AT, memcpy_8_8
    or      a2, AT, zero
    jr      ra
    nop

memcpy_8_8:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_4_4
    subu    a3, a2, AT
    addu    a3, a3, a1
    ld      t0, 0x0(a1)
_memcpy_8_8_loop:
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sd      t0, -0x8(a0)
    bnel    a1, a3, _memcpy_8_8_loop
    ld      t0, 0x0(a1)
    bgtz    AT, memcpy_4_4
    or      a2, AT, zero
    jr      ra
    nop

memcpy_8_4:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_4_4
    subu    a3, a2, AT
    addu    a3, a3, a1
    ldl     t0, 0x7(a1)
_memcpy_8_4_loop:
    ldr     t0, 0x0(a1)
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sd      t0, -0x8(a0)
    bnel    a1, a3, _memcpy_8_4_loop
    ldl     t0, 0x7(a1)
    bgtz    AT, memcpy_4_4
    or      a2, AT, zero
    jr      ra
    nop

memcpy_8_2:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwl     t2, 0x7(a1)
_memcpy_8_2_loop:
    lwr     t2, 0x4(a1)
    lwl     t0, 0x3(a1)
    lwr     t0, 0x0(a1)
    .set    arch=mips64r2
    dins    t0, t2, 32, 32
    .set    arch=loongson3a
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sd      t0, -0x8(a0)
    bnel    a1, a3, _memcpy_8_2_loop
    lwl     t2, 0x7(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_8_1:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lbu     t0, 0x0(a1)
_memcpy_8_1_loop:
    lbu     t2, 0x1(a1)
    .set    arch=mips64r2
    dins    t0, t2, 8, 8
    lbu     t2, 0x2(a1)
    dins    t0, t2, 16, 8
    lbu     t2, 0x3(a1)
    dins    t0, t2, 24, 8
    lbu     t2, 0x4(a1)
    dins    t0, t2, 32, 8
    lbu     t2, 0x5(a1)
    dinsu   t0, t2, 40, 8
    lbu     t2, 0x6(a1)
    dinsu   t0, t2, 48, 8
    lbu     t2, 0x7(a1)
    dinsu   t0, t2, 56, 8
    .set    arch=loongson3a
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sd      t0, -0x8(a0)
    bnel    a1, a3, _memcpy_8_1_loop
    lbu     t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_4_16:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_4_4
    subu    a3, a2, AT
    addu    a3, a3, a1
    gslq    t0, t1, 0x0(a1)
_memcpy_4_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    sdl     t1, -0x09(a0)
    sdr     t1, -0x10(a0)
    sdl     t0, -0x01(a0)
    sdr     t0, -0x08(a0)
    bnel    a1, a3, _memcpy_4_16_loop
    gslq    t0, t1, 0x0(a1)
    bgtz    AT, memcpy_4_4
    or      a2, AT, zero
    jr      ra
    nop

memcpy_4_8:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_4_4
    subu    a3, a2, AT
    addu    a3, a3, a1
    ld      t0, 0x0(a1)
_memcpy_4_8_loop:
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sdl     t0, -0x1(a0)
    sdr     t0, -0x8(a0)
    bnel    a1, a3, _memcpy_4_8_loop
    ld      t0, 0x0(a1)
    bgtz    AT, memcpy_4_4
    or      a2, AT, zero
    jr      ra
    nop

memcpy_4_4:
    andi    AT, a2, 0x3
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwu     t0, 0x0(a1)
_memcpy_4_4_loop:
    addiu   a0, a0, 0x4
    addiu   a1, a1, 0x4
    sw      t0, -0x4(a0)
    bnel    a1, a3, _memcpy_4_4_loop
    lwu     t0, 0x0(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_4_2:
    andi    AT, a2, 0x3
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwl     t0, 0x3(a1)
_memcpy_4_2_loop:
    lwr     t0, 0x0(a1)
    addiu   a0, a0, 0x4
    addiu   a1, a1, 0x4
    sw      t0, -0x4(a0)
    bnel    a1, a3, _memcpy_4_2_loop
    lwl     t0, 0x3(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_4_1:
    andi    AT, a2, 0x3
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lbu     t0, 0x0(a1)
_memcpy_4_1_loop:
    lbu     t2, 0x1(a1)
    .set    arch=mips64r2
    ins     t0, t2, 8, 8
    lbu     t2, 0x2(a1)
    ins     t0, t2, 16, 8
    lbu     t2, 0x3(a1)
    ins     t0, t2, 24, 8
    .set    arch=loongson3a
    addiu   a0, a0, 0x4
    addiu   a1, a1, 0x4
    sw      t0, -0x4(a0)
    bnel    a1, a3, _memcpy_4_1_loop
    lbu     t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_2_16:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    gslq    t0, t1, 0x0(a1)
_memcpy_2_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    swl     t1, -0x0d(a0)
    swr     t1, -0x10(a0)
    dsrl    t1, t1, 32
    swl     t1, -0x09(a0)
    swr     t1, -0x0c(a0)
    swl     t0, -0x05(a0)
    swr     t0, -0x08(a0)
    dsrl    t0, t0, 32
    swl     t0, -0x1(a0)
    swr     t0, -0x4(a0)
    bnel    a1, a3, _memcpy_2_16_loop
    gslq    t0, t1, 0x0(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_2_8:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    ld      t0, 0x0(a1)
_memcpy_2_8_loop:
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    swl     t0, -0x5(a0)
    swr     t0, -0x8(a0)
    dsrl    t0, t0, 32
    swl     t0, -0x1(a0)
    swr     t0, -0x4(a0)
    bnel    a1, a3, _memcpy_2_8_loop
    ld      t0, 0x0(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_2_4:
    andi    AT, a2, 0x3
    beq     AT, a2, memcpy_2_2
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwu     t0, 0x0(a1)
_memcpy_2_4_loop:
    addiu   a0, a0, 0x4
    addiu   a1, a1, 0x4
    swl     t0, -0x1(a0)
    swr     t0, -0x4(a0)
    bnel    a1, a3, _memcpy_2_4_loop
    lwu     t0, 0x0(a1)
    bgtz    AT, memcpy_2_2
    or      a2, AT, zero
    jr      ra
    nop

memcpy_2_2:
    andi    AT, a2, 0x1
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lhu     t0, 0x0(a1)
_memcpy_2_2_loop:
    addiu   a0, a0, 0x2
    addiu   a1, a1, 0x2
    sh      t0, -0x2(a0)
    bnel    a1, a3, _memcpy_2_2_loop
    lhu     t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_2_1:
    andi    AT, a2, 0x1
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lbu     t1, 0x1(a1)
_memcpy_2_1_loop:
    dsll    t1, t1, 8
    lbu     t0, 0x0(a1)
    or      t0, t0, t1
    addiu   a0, a0, 0x2
    addiu   a1, a1, 0x2
    sh      t0, -0x2(a0)
    bnel    a1, a3, _memcpy_2_1_loop
    lbu     t1, 0x1(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_1_16:
    andi    AT, a2, 0xf
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    gslq    t0, t1, 0x0(a1)
_memcpy_1_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    sb      t1, -0x10(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0f(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0e(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0d(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0c(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0b(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x0a(a0)
    dsrl    t1, t1, 8
    sb      t1, -0x09(a0)
    sb      t0, -0x08(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x07(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x06(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x05(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x04(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x03(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x02(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x01(a0)
    bnel    a1, a3, _memcpy_1_16_loop
    gslq    t0, t1, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_1_8:
    andi    AT, a2, 0x7
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    ld      t0, 0x0(a1)
_memcpy_1_8_loop:
    addiu   a0, a0, 0x8
    addiu   a1, a1, 0x8
    sb      t0, -0x8(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x07(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x06(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x05(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x04(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x03(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x02(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x01(a0)
    bnel    a1, a3, _memcpy_1_8_loop
    ld      t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_1_4:
    andi    AT, a2, 0x3
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lwu     t0, 0x0(a1)
_memcpy_1_4_loop:
    addiu   a0, a0, 0x4
    addiu   a1, a1, 0x4
    sb      t0, -0x4(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x3(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x2(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x1(a0)
    bnel    a1, a3, _memcpy_1_4_loop
    lwu     t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_1_2:
    andi    AT, a2, 0x1
    beq     AT, a2, memcpy_1_1
    subu    a3, a2, AT
    addu    a3, a3, a1
    lhu     t0, 0x0(a1)
_memcpy_1_2_loop:
    addiu   a0, a0, 0x2
    addiu   a1, a1, 0x2
    sb      t0, -0x2(a0)
    dsrl    t0, t0, 8
    sb      t0, -0x1(a0)
    bnel    a1, a3, _memcpy_1_2_loop
    lhu     t0, 0x0(a1)
    bgtz    AT, memcpy_1_1
    or      a2, AT, zero
    jr      ra
    nop

memcpy_1_1:
    blez    a2, _memcpy_finish
    addu    a3, a1, a2
    lbu     t0, 0x0(a1)
_memcpy_1_1_loop:
    addiu   a0, a0, 0x1
    addiu   a1, a1, 0x1
    sb      t0, -1(a0)
    bnel    a1, a3, _memcpy_1_1_loop
    lbu     t0, 0x0(a1)

_memcpy_finish:
    jr      ra
    nop

    .end    memcpy
    .set    pop

