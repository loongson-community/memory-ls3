/*
 ============================================================================
 Name        : strlen.S
 Author      : Heiher <r@hev.cc>
 Version     : 1.0.0
 Copyright   : Copyright (c) 2014 everyone.
 Description : The strlen for Loongson 3.
 ============================================================================
 */

#include <sys/asm.h>
#include <sys/regdef.h>

#define ADDIU   PTR_ADDIU
#define SUBU    PTR_SUBU

/* WANRING: This program may be cause a memory access error(overflow). */

/* size_t strlen(const char *s); */

    .globl  strlen
    .ent    strlen, 0
    .type   strlen, @function
    .set    push
    .set    noreorder
    .set    noat
    .set    arch=loongson3a

strlen:
    lui     t2, 0x0101
    lui     t3, 0x8080
    ori     t2, 0x0101
    ori     t3, 0x8080
    dins    t2, t2, 32, 32
    dins    t3, t3, 32, 32
    andi    t0, a0, 0x3
    beqz    t0, _loop_a
    or      v0, zero, a0
_loop_u:
    ldl     t0, 7(a0)
    ldr     t0, 0(a0)
    dsubu   a2, t0, t2
    nor     a3, zero, t0
    and     a3, a3, t3
    and     a2, a3
    beqzl   a2, _loop_u
    ADDIU   a0, 8
_mc8_u:
    dext    t2, t0, 0, 8
    dsrl    t0, 8
    bnezl   t2, _mc8_u
    ADDIU   a0, 1
    jr      ra
    SUBU    v0, a0, v0

_loop_a:
    ld      t0, 0(a0)
    dsubu   a2, t0, t2
    nor     a3, zero, t0
    and     a3, a3, t3
    and     a2, a3
    beqzl   a2, _loop_a
    ADDIU   a0, 8
_mc8_a:
    dext    t2, t0, 0, 8
    dsrl    t0, 8
    bnezl   t2, _mc8_a
    ADDIU   a0, 1
    jr      ra
    SUBU    v0, a0, v0

    .end    strlen
    .size   strlen, .-strlen
    .set    pop

