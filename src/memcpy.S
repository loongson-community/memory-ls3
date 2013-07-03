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

    .type   _memcpy_loop_entries, @object
    .size   _memcpy_loop_entries, 52
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
    .word   _memcpy_16_16

    .globl  memcpy
    .ent    memcpy, 0
    .set    push
    .set    noreorder    
    .set    noat
    .set    arch=loongson3a

memcpy:
    /* if less then 0x1f bytes */
    sltiu   t2, a2, 0x1f
    addiu   t8, jp, _memcpy_less_base-memcpy
    bnez    t2, _memcpy_less
    or      v0, a0, zero
    andi    t0, a0, 0xf
    andi    t1, a1, 0xf
    /* index (bit 2-0) */
    subu    t2, t0, t1
    ori     t2, t2, 0x10
    subu    ta1, zero, t2
    and     t2, t2, ta1
    ori     ta1, zero, 0x1f
    clz     t2, t2
    /* if have 16-byte aligned address */
    sll     t3, t0, t1
    beq     t3, t0, _memcpy_have_16
    subu    ta3, ta1, t2
    /* index (bit 3) */
    sltu    ta0, t0, t1
    sll     t2, ta0, 0x3
    /* calculate the entry address by index */
    or      ta2, ta3, t2
    sll     ta2, ta2, 0x2
    addiu   t2, jp, _memcpy_loop_entries-memcpy
    gslwx   ta3, 0x0(t2, ta2)
    /* head padding */
    movz    t1, t0, ta0
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
    andi    t0, t3, 0x7
    sll     t1, t0, 0x7
    subu    t2, t3, t0
    sll     t2, t2, 0x1
    addu    t0, t8, t1
    subu    ta0, t0, t2
    andi    t0, a2, 0x7
    sll     t1, t0, 0x7
    subu    t2, a2, t0
    sll     t2, t2, 0x1
    addu    t0, t8, t1
    jr      ta0
    subu    t8, t0, t2

_memcpy_less:
    andi    t0, a2, 0x7
    addu    a0, a0, a2
    sll     t1, t0, 0x7
    subu    t2, a2, t0
    addu    a1, a1, a2
    sll     t2, t2, 0x1
    addu    t0, t8, t1
    subu    t0, t0, t2
    jr      t0
    or      ta3, ra, zero

_memcpy_have_16:
    /* index (bit 3) */
    sltiu   ta0, t1, 0x1
    addu    a3, a1, a2
    sll     t2, ta0, 0x3
    andi    a2, a2, 0xf
    /* calculate the entry address by index */
    or      ta2, ta3, t2
    addiu   t2, jp, _memcpy_loop_entries-memcpy
    sll     ta2, ta2, 0x2
    subu    a3, a3, a2
    gslwx   ta3, 0x0(t2, ta2)
    andi    t0, a2, 0x7
    sll     t1, t0, 0x7
    subu    t2, a2, t0
    sll     t2, t2, 0x1
    addu    t0, t8, t1
    jr      ta3
    subu    t8, t0, t2

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
    or      ta3, ra, zero

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
    or      ta3, ra, zero

_memcpy_16_4:
    lwu     t2, 0xc(a1)
_memcpy_16_4_loop:
    lwu     t0, 0x8(a1)
    lwu     t3, 0x4(a1)
    lwu     t1, 0x0(a1)
    addiu   a0, a0, 0x10
    .set    arch=mips64r2
    dins    t0, t2, 32, 32
    dins    t1, t3, 32, 32
    .set    arch=loongson3a
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_4_loop
    lwu     t2, 0xc(a1)
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_16_2:
    lwl     t3, 0xf(a1)
_memcpy_16_2_loop:
    lwr     t3, 0xc(a1)
    lwl     t0, 0xb(a1)
    lwr     t0, 0x8(a1)
    .set    arch=mips64r2
    lwl     t2, 0x7(a1)
    lwr     t2, 0x4(a1)
    lwl     t1, 0x3(a1)
    lwr     t1, 0x0(a1)
    addiu   a0, a0, 0x10
    dins    t0, t3, 32, 32
    dins    t1, t2, 32, 32
    .set    arch=loongson3a
    addiu   a1, a1, 0x10
    gssq    t0, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_2_loop
    lwl     t3, 0xf(a1)
    addu    a0, a0, a2
    addu    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

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
    or      ta3, ra, zero

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
    or      ta3, ra, zero

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
    or      ta3, ra, zero

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
    or      ta3, ra, zero

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
    or      ta3, ra, zero

_memcpy_less_0:
    ldl     ta2, -0x11(a1)
    ldr     ta2, -0x18(a1)
    sdl     ta2, -0x11(a0)
    sdr     ta2, -0x18(a0)
    ldl     ta1, -0x09(a1)
    ldr     ta1, -0x10(a1)
    sdl     ta1, -0x09(a0)
    sdr     ta1, -0x10(a0)
    ldl     ta0, -0x01(a1)
    ldr     ta0, -0x08(a1)
    sdl     ta0, -0x01(a0)
    sdr     ta0, -0x08(a0)
_memcpy_less_base:
    jr      ta3
    nop
    .space  0x80-(.-_memcpy_less_0)

_memcpy_less_1:
    ldl     t0, -0x12(a1)
    ldr     t0, -0x19(a1)
    sdl     t0, -0x12(a0)
    sdr     t0, -0x19(a0)
    ldl     ta2, -0x0a(a1)
    ldr     ta2, -0x11(a1)
    sdl     ta2, -0x0a(a0)
    sdr     ta2, -0x11(a0)
    ldl     ta1, -0x02(a1)
    ldr     ta1, -0x09(a1)
    sdl     ta1, -0x02(a0)
    sdr     ta1, -0x09(a0)
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)
    .space  0x80-(.-_memcpy_less_1)

_memcpy_less_2:
    ldl     t1, -0x13(a1)
    ldr     t1, -0x1a(a1)
    sdl     t1, -0x13(a0)
    sdr     t1, -0x1a(a0)
    ldl     t0, -0x0b(a1)
    ldr     t0, -0x12(a1)
    sdl     t0, -0x0b(a0)
    sdr     t0, -0x12(a0)
    ldl     ta2, -0x03(a1)
    ldr     ta2, -0x0a(a1)
    sdl     ta2, -0x03(a0)
    sdr     ta2, -0x0a(a0)
    lbu     ta1, -0x02(a1)
    sb      ta1, -0x02(a0)
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)
    .space  0x80-(.-_memcpy_less_2)

_memcpy_less_3:
    ldl     t1, -0x14(a1)
    ldr     t1, -0x1b(a1)
    sdl     t1, -0x14(a0)
    sdr     t1, -0x1b(a0)
    ldl     t0, -0x0c(a1)
    ldr     t0, -0x13(a1)
    sdl     t0, -0x0c(a0)
    sdr     t0, -0x13(a0)
    ldl     ta2, -0x04(a1)
    ldr     ta2, -0x0b(a1)
    sdl     ta2, -0x04(a0)
    sdr     ta2, -0x0b(a0)
    lbu     ta1, -0x03(a1)
    sb      ta1, -0x03(a0)
    lbu     ta1, -0x02(a1)
    sb      ta1, -0x02(a0)
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)
    .space  0x80-(.-_memcpy_less_3)

_memcpy_less_4:
    ldl     t0, -0x15(a1)
    ldr     t0, -0x1c(a1)
    sdl     t0, -0x15(a0)
    sdr     t0, -0x1c(a0)
    ldl     ta2, -0x0d(a1)
    ldr     ta2, -0x14(a1)
    sdl     ta2, -0x0d(a0)
    sdr     ta2, -0x14(a0)
    ldl     ta1, -0x05(a1)
    ldr     ta1, -0x0c(a1)
    sdl     ta1, -0x05(a0)
    sdr     ta1, -0x0c(a0)
    lwl     ta0, -0x1(a1)
    lwr     ta0, -0x4(a1)
    swl     ta0, -0x1(a0)
    jr      ta3
    swr     ta0, -0x4(a0)
    .space  0x80-(.-_memcpy_less_4)

_memcpy_less_5:
    ldl     t1, -0x16(a1)
    ldr     t1, -0x1d(a1)
    sdl     t1, -0x16(a0)
    sdr     t1, -0x1d(a0)
    ldl     t0, -0x0e(a1)
    ldr     t0, -0x15(a1)
    sdl     t0, -0x0e(a0)
    sdr     t0, -0x15(a0)
    ldl     ta2, -0x06(a1)
    ldr     ta2, -0x0d(a1)
    sdl     ta2, -0x06(a0)
    sdr     ta2, -0x0d(a0)
    lwl     ta1, -0x2(a1)
    lwr     ta1, -0x5(a1)
    swl     ta1, -0x2(a0)
    swr     ta1, -0x5(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)
    .space  0x80-(.-_memcpy_less_5)

_memcpy_less_6:
    ldl     t2, -0x17(a1)
    ldr     t2, -0x1e(a1)
    sdl     t2, -0x17(a0)
    sdr     t2, -0x1e(a0)
    ldl     t1, -0x0f(a1)
    ldr     t1, -0x16(a1)
    sdl     t1, -0x0f(a0)
    sdr     t1, -0x16(a0)
    ldl     t0, -0x07(a1)
    ldr     t0, -0x0e(a1)
    sdl     t0, -0x07(a0)
    sdr     t0, -0x0e(a0)
    lwl     ta2, -0x3(a1)
    lwr     ta2, -0x6(a1)
    swl     ta2, -0x3(a0)
    swr     ta2, -0x6(a0)
    lbu     ta1, -0x2(a1)
    sb      ta1, -0x2(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)
    .space  0x80-(.-_memcpy_less_6)

_memcpy_less_7:
    ldl     t3, -0x18(a1)
    ldr     t3, -0x1f(a1)
    sdl     t3, -0x18(a0)
    sdr     t3, -0x1f(a0)
    ldl     t2, -0x10(a1)
    ldr     t2, -0x17(a1)
    sdl     t2, -0x10(a0)
    sdr     t2, -0x17(a0)
    ldl     t1, -0x08(a1)
    ldr     t1, -0x0f(a1)
    sdl     t1, -0x08(a0)
    sdr     t1, -0x0f(a0)
    lwl     t0, -0x4(a1)
    lwr     t0, -0x7(a1)
    swl     t0, -0x4(a0)
    swr     t0, -0x7(a0)
    lbu     ta2, -0x3(a1)
    sb      ta2, -0x3(a0)
    lbu     ta1, -0x2(a1)
    sb      ta1, -0x2(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)
    .space  0x80-(.-_memcpy_less_7)

    .end    memcpy
    .set    pop

