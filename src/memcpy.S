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

    .type   _memcpy_loop_entries, @object
    .size   _memcpy_loop_entries, 48
_memcpy_loop_entries:
    .word   _memcpy_16_1
    .word   _memcpy_16_2
    .word   _memcpy_16_4
    .word   _memcpy_16_8
    .word   _memcpy_16_16
    .space  12
    .word   _memcpy_1_16
    .word   _memcpy_2_16
    .word   _memcpy_4_16
    .word   _memcpy_8_16

memcpy:
    sltiu   t2, a2, 0x1f
    bnez    t2, _memcpy_less
    or      v0, a0, zero
    /* s1 % 16 = [1, 16] */
    andi    t0, a0, 0xf
    sltiu   t2, t0, 0x1
    sll     t2, t2, 0x4
    addu    t0, t2, t0
    /* s2 % 16 = [1, 16]*/
    andi    t1, a1, 0xf
    sltiu   t2, t1, 0x1
    sll     t2, t2, 0x4
    addu    t1, t2, t1
    /* index (bit 3) */
    sltu    t2, t0, t1
    sll     t7, t2, 0x3
    /* sort */
    subu    t2, zero, t2
    nor     t3, t2, zero
    /* t6 = MIN (t0, t1) */
    and     t4, t0, t2
    and     t5, t1, t3
    addu    t6, t4, t5
    /* t1 = MAX (t0, t1) */
    and     t4, t0, t3
    and     t5, t1, t2
    addu    t1, t4, t5
    /* index (bit 2-0) */
    subu    t2, t1, t6
    ori     t2, t2, 0x10
    subu    t3, zero, t2
    and     t2, t2, t3
    ori     t3, zero, 0x1f
    clz     t2, t2
    subu    t2, t3, t2
    /* calculate the entry address by index */
    or      t6, t7, t2
    sll     t6, t6, 0x2
    addiu   t2, jp, _memcpy_loop_entries-memcpy
    addu    t2, t2, t6
    lw      t7, 0x0(t2)
    /* head padding */
    ori     t3, zero, 0x10
    subu    t3, t3, t1
    /* calculate s1, s2, n (16-byte aligned) */
    addu    a0, a0, t3
    addu    a1, a1, t3
    subu    t2, a2, t3
    andi    a2, t2, 0xf
    subu    t2, t2, a2
    addu    a3, a1, t2
    /* goto head padding copies */
    sll     t3, t3, 0x3
    sll     t4, a2, 0x3
    addiu   t5, jp, _memcpy_1_1_base-memcpy
    subu    t6, t5, t3
    jr      t6
    subu    t8, t5, t4

_memcpy_less:
    addu    a0, a0, a2
    addu    a1, a1, a2
    sll     a2, a2, 0x3
    addiu   t0, jp, _memcpy_1_1_base-memcpy
    subu    t0, t0, a2
    jr      t0
    or      t7, ra, zero

_memcpy_16_16:
    gslq    t0, t1, 0x0(a1)
_memcpy_16_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_16_loop
    gslq    t0, t1, 0x0(a1)
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_16_8:
    ld      t0, 0x8(a1)
_memcpy_16_8_loop:
    ld      t1, 0x0(a1)
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_8_loop
    ld      t0, 0x8(a1)
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_16_4:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_16_2:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_16_1:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_8_16:
    gslq    t0, t1, 0x0(a1)
_memcpy_8_16_loop:
    addiu   a0, a0, 0x10
    addiu   a1, a1, 0x10
    sd      t0, -0x08(a0)
    sd      t1, -0x10(a0)
    bnel    a1, a3, _memcpy_8_16_loop
    gslq    t0, t1, 0x0(a1)
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_4_16:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_2_16:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_1_16:
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
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      t7, ra, zero

_memcpy_1_1:
    lbu     t2, -0x1f(a1)
    sb      t2, -0x1f(a0)
    lbu     t1, -0x1e(a1)
    sb      t1, -0x1e(a0)
    lbu     t0, -0x1d(a1)
    sb      t0, -0x1d(a0)
    lbu     t6, -0x1c(a1)
    sb      t6, -0x1c(a0)
    lbu     t5, -0x1b(a1)
    sb      t5, -0x1b(a0)
    lbu     t4, -0x1a(a1)
    sb      t4, -0x1a(a0)
    lbu     t3, -0x19(a1)
    sb      t3, -0x19(a0)
    lbu     t2, -0x18(a1)
    sb      t2, -0x18(a0)
    lbu     t1, -0x17(a1)
    sb      t1, -0x17(a0)
    lbu     t0, -0x16(a1)
    sb      t0, -0x16(a0)
    lbu     t6, -0x15(a1)
    sb      t6, -0x15(a0)
    lbu     t5, -0x14(a1)
    sb      t5, -0x14(a0)
    lbu     t4, -0x13(a1)
    sb      t4, -0x13(a0)
    lbu     t3, -0x12(a1)
    sb      t3, -0x12(a0)
    lbu     t2, -0x11(a1)
    sb      t2, -0x11(a0)
    lbu     t1, -0x10(a1)
    sb      t1, -0x10(a0)
    lbu     t0, -0x0f(a1)
    sb      t0, -0x0f(a0)
    lbu     t6, -0x0e(a1)
    sb      t6, -0x0e(a0)
    lbu     t5, -0x0d(a1)
    sb      t5, -0x0d(a0)
    lbu     t4, -0x0c(a1)
    sb      t4, -0x0c(a0)
    lbu     t3, -0x0b(a1)
    sb      t3, -0x0b(a0)
    lbu     t2, -0x0a(a1)
    sb      t2, -0x0a(a0)
    lbu     t1, -0x09(a1)
    sb      t1, -0x09(a0)
    lbu     t0, -0x08(a1)
    sb      t0, -0x08(a0)
    lbu     t6, -0x07(a1)
    sb      t6, -0x07(a0)
    lbu     t5, -0x06(a1)
    sb      t5, -0x06(a0)
    lbu     t4, -0x05(a1)
    sb      t4, -0x05(a0)
    lbu     t3, -0x04(a1)
    sb      t3, -0x04(a0)
    lbu     t2, -0x03(a1)
    sb      t2, -0x03(a0)
    lbu     t1, -0x02(a1)
    sb      t1, -0x02(a0)
    lbu     t0, -0x01(a1)
    sb      t0, -0x01(a0)
_memcpy_1_1_base:
    jr      t7
    nop

    .end    memcpy
    .set    pop

