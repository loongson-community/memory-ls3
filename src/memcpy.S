/*
 ============================================================================
 Name        : memcpy.S
 Author      : Heiher <root@heiher.info>
               Chen Jie <chenj@lemote.com>
 Version     : 1.2.0
 Copyright   : Copyright (c) 2013 everyone.
 Description : The memcpy for Loongson 3.
 ============================================================================
 */

#include <sys/asm.h>
#include <sys/regdef.h>

#define ENTRIES         10
#define PADDING         3
#define ENTRY_PADDING   .space   (PTRSIZE*PADDING)
#define ENTRIES_SIZE    (PTRSIZE*(ENTRIES+PADDING))

#if _MIPS_SIM == _ABI64

#define ENTRY           .dword

#define ADDU            daddu
#define ADDIU           daddiu
#define SUBU            dsubu
#define SLL             dsll
#define LOADP           gsldx

#else /* _ABIO32 || _ABIN32 */

#define ENTRY           .word

#define ADDU            addu
#define ADDIU           addiu
#define SUBU            subu
#define SLL             sll
#define LOADP           gslwx

#endif

#define _MEMCPY_ALIGN_SPACE(a, b) \
    .space  0x80-(_memcpy_less_##b##_base-_memcpy_less_##b)- \
                 (.-_memcpy_less_##a##_base)

#define _MEMCPY_MAKE_DQW_MULS(symbol) \
    SUBU    t0, a3, a1; \
    andi    t0, t0, 0x1f; \
    ADDU    a0, a0, t0; \
    bnez    t0, symbol##_; \
    ADDU    a1, a1, t0

/* void * memcpy (void *s1, const void *s2, size_t n); */
    .text    
    .align  2

    .type   _memcpy_loop_entries, @object
    .size   _memcpy_loop_entries, ENTRIES_SIZE
_memcpy_loop_entries:
    ENTRY   _memcpy_16_1_2
    ENTRY   _memcpy_16_1_2
    ENTRY   _memcpy_16_4
    ENTRY   _memcpy_16_8
    ENTRY   _memcpy_16_16
    ENTRY_PADDING
    ENTRY   _memcpy_4_2_1_16
    ENTRY   _memcpy_4_2_1_16
    ENTRY   _memcpy_4_2_1_16
    ENTRY   _memcpy_8_16
    ENTRY   _memcpy_16_16

    .globl  memcpy
    .ent    memcpy, 0
    .set    push
    .set    noreorder    
    .set    noat
    .set    arch=loongson3a

memcpy:
    /* if less then 0x36 bytes */
    sltiu   t2, a2, 0x36
    ADDIU   t8, jp, _memcpy_less_0_base-memcpy
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
    /* calculate the entry address by index */
    .set    arch=mips64r2
    ins     ta3, ta0, 0x3, 0x1
    .set    arch=loongson3a
    sll     ta2, ta3, PTRLOG
    ADDIU   t2, jp, _memcpy_loop_entries-memcpy
    LOADP   ta3, 0x0(t2, ta2)
    /* head padding */
    movz    t1, t0, ta0
    ori     t3, zero, 0x10
    subu    t3, t3, t1
    /* calculate s1, s2, n (16-byte aligned) */
    ADDU    a0, a0, t3
    ADDU    a1, a1, t3
    SUBU    t2, a2, t3
    andi    a2, t2, 0xf
    SUBU    t2, t2, a2
    ADDU    a3, a1, t2
    /* goto head padding copies */
    andi    t0, t3, 0x7
    sll     t1, t0, 0x7
    subu    t2, t3, t0
    sll     t2, t2, 0x1
    ADDU    t0, t8, t1
    SUBU    ta0, t0, t2
    andi    t0, a2, 0x7
    SLL     t1, t0, 0x7
    SUBU    t2, a2, t0
    SLL     t2, t2, 0x1
    ADDU    t0, t8, t1
    jr      ta0
    SUBU    t8, t0, t2

_memcpy_less:
    andi    t0, a2, 0x7
    ADDU    a0, a0, a2
    SLL     t1, t0, 0x7
    SUBU    t2, a2, t0
    ADDU    a1, a1, a2
    SLL     t2, t2, 0x1
    ADDU    t0, t8, t1
    SUBU    t0, t0, t2
    jr      t0
    or      ta3, ra, zero

_memcpy_have_16:
    /* index (bit 3) */
    sltiu   ta0, t1, 0x1
    ADDU    a3, a1, a2
    andi    a2, a2, 0xf
    /* calculate the entry address by index */
    .set    arch=mips64r2
    ins     ta3, ta0, 0x3, 0x1
    .set    arch=loongson3a
    ADDIU   t2, jp, _memcpy_loop_entries-memcpy
    sll     ta2, ta3, PTRLOG
    SUBU    a3, a3, a2
    LOADP   ta3, 0x0(t2, ta2)
    andi    t0, a2, 0x7
    SLL     t1, t0, 0x7
    SUBU    t2, a2, t0
    SLL     t2, t2, 0x1
    ADDU    t0, t8, t1
    jr      ta3
    SUBU    t8, t0, t2

_memcpy_16_16:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_16_16)
    gslq    t0, t1, 0x0(a1)
_memcpy_16_16_loop:
    ADDIU   a0, a0, 0x20
    ADDIU   a1, a1, 0x20
    gssq    t0, t1, -0x20(a0)
_memcpy_16_16_:
    gslqc1  $f4, $f6, -0x10(a1)
    gssqc1  $f4, $f6, -0x10(a0)
    bnel    a1, a3, _memcpy_16_16_loop
    gslq    t0, t1, 0x0(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_16_8:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_16_8)
    ld      t0, 0x8(a1)
_memcpy_16_8_loop:
    ld      t1, 0x0(a1)
    ADDIU   a0, a0, 0x20
    ADDIU   a1, a1, 0x20
    gssq    t0, t1, -0x20(a0)
_memcpy_16_8_:
    ldc1    $f4, -0x08(a1)
    ldc1    $f6, -0x10(a1)
    gssqc1  $f4, $f6, -0x10(a0)
    bnel    a1, a3, _memcpy_16_8_loop
    ld      t0, 0x8(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_16_4:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_16_4)
    lwu     t2, 0xc(a1)
_memcpy_16_4_loop:
    lwu     t0, 0x8(a1)
    lwu     t3, 0x4(a1)
    lwu     t1, 0x0(a1)
    ADDIU   a0, a0, 0x20
    .set    arch=mips64r2
    dinsu   t0, t2, 32, 32
    dinsu   t1, t3, 32, 32
    .set    arch=loongson3a
    ADDIU   a1, a1, 0x20
    gssq    t0, t1, -0x20(a0)
_memcpy_16_4_:
    lwu     t2, -0x04(a1)
    lwu     t3, -0x08(a1)
    lwu     t0, -0x0c(a1)
    lwu     t1, -0x10(a1)
    .set    arch=mips64r2
    dinsu   t3, t2, 32, 32
    dinsu   t1, t0, 32, 32
    .set    arch=loongson3a
    gssq    t3, t1, -0x10(a0)
    bnel    a1, a3, _memcpy_16_4_loop
    lwu     t2, 0xc(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_16_1_2:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_16_1_2)
    ldl     t0, 0xf(a1)
_memcpy_16_1_2_loop:
    ldr     t0, 0x8(a1)
    ldl     t1, 0x7(a1)
    ldr     t1, 0x0(a1)
    ADDIU   a0, a0, 0x20
    ADDIU   a1, a1, 0x20
    gssq    t0, t1, -0x20(a0)
_memcpy_16_1_2_:
    gsldlc1 $f4, -0x01(a1)
    gsldrc1 $f4, -0x08(a1)
    gsldlc1 $f6, -0x09(a1)
    gsldrc1 $f6, -0x10(a1)
    gssqc1  $f4, $f6, -0x10(a0)
    bnel    a1, a3, _memcpy_16_1_2_loop
    ldl     t0, 0xf(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_8_16:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_8_16)
    gslq    t0, t1, 0x0(a1)
_memcpy_8_16_loop:
    ADDIU   a0, a0, 0x20
    ADDIU   a1, a1, 0x20
    sd      t0, -0x18(a0)
    sd      t1, -0x20(a0)
_memcpy_8_16_:
    gslqc1  $f4, $f6, -0x10(a1)
    sdc1    $f4, -0x08(a0)
    sdc1    $f6, -0x10(a0)
    bnel    a1, a3, _memcpy_8_16_loop
    gslq    t0, t1, 0x0(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_4_2_1_16:
    _MEMCPY_MAKE_DQW_MULS(_memcpy_4_2_1_16)
    gslq    t0, t1, 0x0(a1)
_memcpy_4_2_1_16_loop:
    ADDIU   a0, a0, 0x20
    ADDIU   a1, a1, 0x20
    sdl     t0, -0x11(a0)
    sdr     t0, -0x18(a0)
    sdl     t1, -0x19(a0)
    sdr     t1, -0x20(a0)
_memcpy_4_2_1_16_:
    gslqc1  $f4, $f6, -0x10(a1)
    gssdlc1 $f4, -0x01(a0)
    gssdrc1 $f4, -0x08(a0)
    gssdlc1 $f6, -0x09(a0)
    gssdrc1 $f6, -0x10(a0)
    bnel    a1, a3, _memcpy_4_2_1_16_loop
    gslq    t0, t1, 0x0(a1)
    ADDU    a0, a0, a2
    ADDU    a1, a1, a2
    jr      t8
    or      ta3, ra, zero

_memcpy_less_0:
    ldl     t0, -0x29(a1)
    ldr     t0, -0x30(a1)
    sdl     t0, -0x29(a0)
    sdr     t0, -0x30(a0)
    gsldlc1 $f8, -0x21(a1)
    gsldrc1 $f8, -0x28(a1)
    gssdlc1 $f8, -0x21(a0)
    gssdrc1 $f8, -0x28(a0)
    ldl     ta2, -0x19(a1)
    ldr     ta2, -0x20(a1)
    sdl     ta2, -0x19(a0)
    sdr     ta2, -0x20(a0)
    gsldlc1 $f6, -0x11(a1)
    gsldrc1 $f6, -0x18(a1)
    gssdlc1 $f6, -0x11(a0)
    gssdrc1 $f6, -0x18(a0)
    ldl     ta1, -0x09(a1)
    ldr     ta1, -0x10(a1)
    sdl     ta1, -0x09(a0)
    sdr     ta1, -0x10(a0)
    gsldlc1 $f4, -0x01(a1)
    gsldrc1 $f4, -0x08(a1)
    gssdlc1 $f4, -0x01(a0)
    gssdrc1 $f4, -0x08(a0)
_memcpy_less_0_base:
    jr      ta3
    nop

    _MEMCPY_ALIGN_SPACE(0, 1)
_memcpy_less_1:
    ldl     t1, -0x2a(a1)
    ldr     t1, -0x31(a1)
    sdl     t1, -0x2a(a0)
    sdr     t1, -0x31(a0)
    gsldlc1 $f8, -0x22(a1)
    gsldrc1 $f8, -0x29(a1)
    gssdlc1 $f8, -0x22(a0)
    gssdrc1 $f8, -0x29(a0)
    ldl     t0, -0x1a(a1)
    ldr     t0, -0x21(a1)
    sdl     t0, -0x1a(a0)
    sdr     t0, -0x21(a0)
    gsldlc1 $f6, -0x12(a1)
    gsldrc1 $f6, -0x19(a1)
    gssdlc1 $f6, -0x12(a0)
    gssdrc1 $f6, -0x19(a0)
    ldl     ta2, -0x0a(a1)
    ldr     ta2, -0x11(a1)
    sdl     ta2, -0x0a(a0)
    sdr     ta2, -0x11(a0)
    gsldlc1 $f4, -0x02(a1)
    gsldrc1 $f4, -0x09(a1)
    gssdlc1 $f4, -0x02(a0)
    gssdrc1 $f4, -0x09(a0)
_memcpy_less_1_base:
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)

    _MEMCPY_ALIGN_SPACE(1, 2)
_memcpy_less_2:
    ldl     t1, -0x2b(a1)
    ldr     t1, -0x32(a1)
    sdl     t1, -0x2b(a0)
    sdr     t1, -0x32(a0)
    gsldlc1 $f8, -0x23(a1)
    gsldrc1 $f8, -0x2a(a1)
    gssdlc1 $f8, -0x23(a0)
    gssdrc1 $f8, -0x2a(a0)
    ldl     t0, -0x1b(a1)
    ldr     t0, -0x22(a1)
    sdl     t0, -0x1b(a0)
    sdr     t0, -0x22(a0)
    gsldlc1 $f6, -0x13(a1)
    gsldrc1 $f6, -0x1a(a1)
    gssdlc1 $f6, -0x13(a0)
    gssdrc1 $f6, -0x1a(a0)
    ldl     ta2, -0x0b(a1)
    ldr     ta2, -0x12(a1)
    sdl     ta2, -0x0b(a0)
    sdr     ta2, -0x12(a0)
    gsldlc1 $f4, -0x03(a1)
    gsldrc1 $f4, -0x0a(a1)
    gssdlc1 $f4, -0x03(a0)
    gssdrc1 $f4, -0x0a(a0)
_memcpy_less_2_base:
    lbu     ta1, -0x02(a1)
    sb      ta1, -0x02(a0)
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)

    _MEMCPY_ALIGN_SPACE(2, 3)
_memcpy_less_3:
    ldl     t1, -0x2c(a1)
    ldr     t1, -0x33(a1)
    sdl     t1, -0x2c(a0)
    sdr     t1, -0x33(a0)
    gsldlc1 $f8, -0x24(a1)
    gsldrc1 $f8, -0x2b(a1)
    gssdlc1 $f8, -0x24(a0)
    gssdrc1 $f8, -0x2b(a0)
    ldl     t0, -0x1c(a1)
    ldr     t0, -0x23(a1)
    sdl     t0, -0x1c(a0)
    sdr     t0, -0x23(a0)
    gsldlc1 $f6, -0x14(a1)
    gsldrc1 $f6, -0x1b(a1)
    gssdlc1 $f6, -0x14(a0)
    gssdrc1 $f6, -0x1b(a0)
    ldl     ta2, -0x0c(a1)
    ldr     ta2, -0x13(a1)
    sdl     ta2, -0x0c(a0)
    sdr     ta2, -0x13(a0)
    gsldlc1 $f4, -0x04(a1)
    gsldrc1 $f4, -0x0b(a1)
    gssdlc1 $f4, -0x04(a0)
    gssdrc1 $f4, -0x0b(a0)
_memcpy_less_3_base:
    lbu     ta1, -0x03(a1)
    sb      ta1, -0x03(a0)
    lbu     ta1, -0x02(a1)
    sb      ta1, -0x02(a0)
    lbu     ta0, -0x01(a1)
    jr      ta3
    sb      ta0, -0x01(a0)

    _MEMCPY_ALIGN_SPACE(3, 4)
_memcpy_less_4:
    gsldlc1 $f10, -0x2d(a1)
    gsldrc1 $f10, -0x34(a1)
    gssdlc1 $f10, -0x2d(a0)
    gssdrc1 $f10, -0x34(a0)
    ldl     ta2, -0x25(a1)
    ldr     ta2, -0x2c(a1)
    sdl     ta2, -0x25(a0)
    sdr     ta2, -0x2c(a0)
    gsldlc1 $f8, -0x1d(a1)
    gsldrc1 $f8, -0x24(a1)
    gssdlc1 $f8, -0x1d(a0)
    gssdrc1 $f8, -0x24(a0)
    ldl     ta1, -0x15(a1)
    ldr     ta1, -0x1c(a1)
    sdl     ta1, -0x15(a0)
    sdr     ta1, -0x1c(a0)
    gsldlc1 $f6, -0x0d(a1)
    gsldrc1 $f6, -0x14(a1)
    gssdlc1 $f6, -0x0d(a0)
    gssdrc1 $f6, -0x14(a0)
    ldl     ta0, -0x05(a1)
    ldr     ta0, -0x0c(a1)
    sdl     ta0, -0x05(a0)
    sdr     ta0, -0x0c(a0)
_memcpy_less_4_base:
    gslwlc1 $f4, -0x1(a1)
    gslwrc1 $f4, -0x4(a1)
    gsswlc1 $f4, -0x1(a0)
    jr      ta3
    gsswrc1 $f4, -0x4(a0)

    _MEMCPY_ALIGN_SPACE(4, 5)
_memcpy_less_5:
    gsldlc1 $f10, -0x2e(a1)
    gsldrc1 $f10, -0x35(a1)
    gssdlc1 $f10, -0x2e(a0)
    gssdrc1 $f10, -0x35(a0)
    ldl     t0, -0x26(a1)
    ldr     t0, -0x2d(a1)
    sdl     t0, -0x26(a0)
    sdr     t0, -0x2d(a0)
    gsldlc1 $f8, -0x1e(a1)
    gsldrc1 $f8, -0x25(a1)
    gssdlc1 $f8, -0x1e(a0)
    gssdrc1 $f8, -0x25(a0)
    ldl     ta2, -0x16(a1)
    ldr     ta2, -0x1d(a1)
    sdl     ta2, -0x16(a0)
    sdr     ta2, -0x1d(a0)
    gsldlc1 $f6, -0x0e(a1)
    gsldrc1 $f6, -0x15(a1)
    gssdlc1 $f6, -0x0e(a0)
    gssdrc1 $f6, -0x15(a0)
    ldl     ta1, -0x06(a1)
    ldr     ta1, -0x0d(a1)
    sdl     ta1, -0x06(a0)
    sdr     ta1, -0x0d(a0)
_memcpy_less_5_base:
    gslwlc1 $f4, -0x2(a1)
    gslwrc1 $f4, -0x5(a1)
    gsswlc1 $f4, -0x2(a0)
    gsswrc1 $f4, -0x5(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)

    _MEMCPY_ALIGN_SPACE(5, 6)
_memcpy_less_6:
    ldl     t1, -0x27(a1)
    ldr     t1, -0x2e(a1)
    sdl     t1, -0x27(a0)
    sdr     t1, -0x2e(a0)
    gsldlc1 $f8, -0x1f(a1)
    gsldrc1 $f8, -0x26(a1)
    gssdlc1 $f8, -0x1f(a0)
    gssdrc1 $f8, -0x26(a0)
    ldl     t0, -0x17(a1)
    ldr     t0, -0x1e(a1)
    sdl     t0, -0x17(a0)
    sdr     t0, -0x1e(a0)
    gsldlc1 $f6, -0x0f(a1)
    gsldrc1 $f6, -0x16(a1)
    gssdlc1 $f6, -0x0f(a0)
    gssdrc1 $f6, -0x16(a0)
    ldl     ta2, -0x07(a1)
    ldr     ta2, -0x0e(a1)
    sdl     ta2, -0x07(a0)
    sdr     ta2, -0x0e(a0)
_memcpy_less_6_base:
    gslwlc1 $f4, -0x3(a1)
    gslwrc1 $f4, -0x6(a1)
    gsswlc1 $f4, -0x3(a0)
    gsswrc1 $f4, -0x6(a0)
    lbu     ta1, -0x2(a1)
    sb      ta1, -0x2(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)

    _MEMCPY_ALIGN_SPACE(6, 7)
_memcpy_less_7:
    ldl     t3, -0x28(a1)
    ldr     t3, -0x2f(a1)
    sdl     t3, -0x28(a0)
    sdr     t3, -0x2f(a0)
    gsldlc1 $f8, -0x20(a1)
    gsldrc1 $f8, -0x27(a1)
    gssdlc1 $f8, -0x20(a0)
    gssdrc1 $f8, -0x27(a0)
    ldl     t2, -0x18(a1)
    ldr     t2, -0x1f(a1)
    sdl     t2, -0x18(a0)
    sdr     t2, -0x1f(a0)
    gsldlc1 $f6, -0x10(a1)
    gsldrc1 $f6, -0x17(a1)
    gssdlc1 $f6, -0x10(a0)
    gssdrc1 $f6, -0x17(a0)
    ldl     t0, -0x08(a1)
    ldr     t0, -0x0f(a1)
    sdl     t0, -0x08(a0)
    sdr     t0, -0x0f(a0)
_memcpy_less_7_base:
    gslwlc1 $f4, -0x4(a1)
    gslwrc1 $f4, -0x7(a1)
    gsswlc1 $f4, -0x4(a0)
    gsswrc1 $f4, -0x7(a0)
    lbu     ta2, -0x3(a1)
    sb      ta2, -0x3(a0)
    lbu     ta1, -0x2(a1)
    sb      ta1, -0x2(a0)
    lbu     ta0, -0x1(a1)
    jr      ta3
    sb      ta0, -0x1(a0)

    .end    memcpy
    .set    pop

