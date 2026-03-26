# OpenTitan - Design and optimization of PQC ISA extension for OTBN
This repository is the work of a semester project at ETH Zürich, with the goal of consolidating existing work about efficient PQC implementations and proposing and implementing an efficient ISA SIMD extension such that lattice-based cryptography can be executed efficiently on the OpenTitan Big Number accelerator.

> This work has now been upstreamed into the official OpenTitan repo! See [lowRISC/opentitan#29344](https://github.com/lowRISC/opentitan/pull/29344) and [lowRISC/opentitan#29395](https://github.com/lowRISC/opentitan/pull/29395).

![OpenTitan logo](https://docs.opentitan.org/doc/opentitan-logo.png)

## About the project

[OpenTitan](https://opentitan.org) is an open source silicon Root of Trust
(RoT) project.  OpenTitan will make the silicon RoT design and implementation
more transparent, trustworthy, and secure for enterprises, platform providers,
and chip manufacturers.  OpenTitan is administered by [lowRISC
CIC](https://www.lowrisc.org) as a collaborative project to produce high
quality, open IP for instantiation as a full-featured product. See the
[OpenTitan site](https://opentitan.org/) and [OpenTitan
docs](https://opentitan.org/book) for more information about the project.

## About this repository
This repository contains a SIMD ISA extension implementation for the co-processor [OpenTitan Big Number Accelerator](https://opentitan.org/book/hw/ip/otbn/index.html) (OTBN).
The OTBN is a RISC-V alike processor with special 256-bit wide registers to accelerate cryptographic workloads based on big integer arithmetics (like RSA).

In contrast to established cryptographic schemes, the new Post-Quantum-Cryptography schemes, like ML-DSA, are based on module lattice problems.
These problems require the computation on polynomials on finite fields where most numbers easily can be represented within 32 bits as most of the computations are performed over the ring of integers modulo a small prime (mostly within 32 bits).
The most salient computation is the Number Theoretic Transform (NTT), which is a special kind of a discrete Fast Fourier Transformation.
Therefore, SIMD instructions operating on the 256-bit wide registers would enable the parallel computation of the FFT butterfly computation.

## Proposed and implemented instructions
The main idea for the ISA extension stems from the work [“Towards ML-KEM i& ML-DSA on OpenTitan](https://eprint.iacr.org/2024/1192).
The following instructions were added operating on the 256-bit wide registers.
The parameter `<elen>` can either be `.2Q` for 128-bit elements, `.4D` for 64-bit and `.8S` or `.16H` representing 32-bits or 16-bits elements, respectively.
The instruction encoding can be found in [./hw/ip/otbn/data/bignum-insns.yml](./hw/ip/otbn/data/bignum-insns.yml).
- `bn.addv(m).<elen> <wdr>, <wrs1>, <wrs2>`:
  Add the vector elements in WDRs `<wrs>` and `<wrs2>` element wise and store the result in the WDR `<wdr>`.
  The results are truncated in case of an overflow. If the modulo variant is selected a pseudo reduction is performed, meaning if an individual result is equal to or larger than MOD, MOD is subtracted from it.
- `bn.subv(m).<elen> <wdr>, <wrs1>, <wrs2>`:
  Subtract the vector elements in WDR register `<wrs2>` from `<wrs1>` element wise and store the result in the WDR `<wdr>`.
  The results are truncated to the element length. If the modulo variant is selected a pseudo reduction is performed meaning if an individual result is negative, MOD is added to it.
- `bn.mulv(m)(l).<elen> <wdr>, <wrs1>, <wrs2>[, <lane>]`:
  Multiply elements in WDRs `<wrs1>` and `<wrs2>` element wise and store the result in the WDR `<wdr>`.
  The results are truncated to the element length.
  This instruction supports only element lengths of type `.8S` or `.16H`.
  The suffix `l` specifies a lane wise operation where all elements of `<wrs1>` are multiplied with a fixed element in `<wrs2>` at the index specified by `<lane>`.
  This applies to both the regular and modulo multiplication.
  If the modulo variant is selected instead of a regular multiplication a Montgomery multiplication is performed for all elements. This requires the modulus value and the corresponding element length’s Montgomery constant to be placed in the MOD WSR. The input operands must be transformed into the Montgomery representation accordingly before executing this instruction.
  This instructions takes 3 cycles for a regular multiplication and 12 cycles for a Montgomery multiplication.
  With a multi-cycle implementation, it is possible to reuse hardware in the BN-MAC module.
- `bn.trn1/bn.trn2.<elen> <wdr>, <wrs1>, <wrs2>`:
  Interleaves the vectors in `<wrs1>` and `<wrs2>`
  The `bn.trn1` places even-indexed vector elements from `<wrs1>` into even-indexed elements of `<wrd>` and even-indexed vector elements from `<wrs2>` are placed into odd-indexed elements of `<wrd>`.
  For `bn.trn2` it is vice versa.
  Odd-indexed vector elements from `<wrs1>` are placed into even-indexed elements of wrd and odd-indexed vector elements from `<wrs2>` are placed into odd-indexed elements of `<wrd>`.
- `bn.shv.<elen> <wdr>, <wsr> <shift_type> <shift_bits>`:
  Logically shifts each element of vector `<wrs>` by `<shift_bits>` bits in `<shift_type>` direction.
  The options for `<shift_type>` are << or >> for left or right shift, respectively.

### Benefits of new instructions
The new instructions allow a parallel computation of the NTT butterfly, resulting in a NTT speed-up of around 3.4x.
The benchmarks can be found on the branch `benchmark` (94bdc0a069d3eb3a26dd579350844315fd66e0f1) at `./sw/otbn/ntt/tests/` (`ntt_mldsa_test.s`, `intt_mldsa_test.s`).
The actual NTT implementation is at `/sw/otbn/ntt/ntt_mldsa.s` and `/sw/otbn/ntt/intt_mldsa.s`, respectively.

## Optimization
After synthesis, it was discovered that the new modulo multiplication is relatively huge.
There are two optimizations implemented.

### Optimization 1: No conditional subtraction
To optimize the design, a HW-SW optimization was proposed by adapting the implemented Montgomery multiplication (`bn.mulvm`).
The last step of the Montgomery multiplication is a conditional subtraction.
This subtraction was implemented in hardware.
However, one can replace this hardware with an additional `bn.addvm` instruction as the conditional subtraction is inherent to the pseudo modulo reduction (subtracting MOD if equal or greater than MOD).
This optimization converts a Montgomery multiplication from
```
bn.mulvm.8S w1, w2, w3
```
to
```
bn.mulvm.8S w1, w2, w3
bn.addvm.8S w1, w1, w0 /* where w0 is all-zero */
```
The optimized design can be found on the branch `opt-no-subtractor` (0fc63fd8aa988dcda144c81fc6edb5c07b5869eb).

This change results in a smaller design (area wise) and better timing.
But the total execution time rises from 12 cycles to 13 cycles, resulting in a NTT speed-up of around 3.27x (-5%) at a fixed clock frequency.
The relevant benchmarks can be found on the branch `benchmark` (94bdc0a069d3eb3a26dd579350844315fd66e0f1) at `./sw/otbn/ntt/tests/` (`ntt_mldsa_exp_reduction_test.s`, `intt_mldsa_exp_reduction_test.s.s`).
The actual NTT implementation is at `/sw/otbn/ntt/ntt_mldsa_exp_reduction.s` and `/sw/otbn/ntt/intt_mldsa_exp_reduction.s`, respectively.

### Optimization 2: No 16-bit support
The resulting design has still a relatively large area overhead and a bad timing.
As many PCQ schemes don't need 16-bit multiplications, the 16-bit multiplication support is removed.
This allows to simplify the lane selection and also the vectorized multiplier can be implemented with fewer partial product generations (fewer but larger multipliers).
With less partial products the side-channel attack (SCA) mitigations can also be reduced, resulting in a better optimized design.

This results in a quite smaller area overhead of only +14% @ 8ns.
The design can be found on the branch `opt-no16b` (7c4a12c207657cfc422054a4a57c019ff26b2e89).

## Open Points
For a full and secure implementation of ML-DSA, future work is definitively required on the following topics:
- The instructions `bn.mulvm(l)` have the limitation that the source and destination WDRs may not be the same.
  This is due to the complexity of predecoding the register write signals and could not be addressed within the project time frame.
- The control signals for the BN MAC blankers, generated by the FSM, are unstable and therefore render certain security measures ineffective.
  In addition, the RTL implementation of the lane selection generates leakage across vector elements.
- The reviewed literature reported instruction and data memory requirements up to 64 KiB for ML-DSA whereas the current OTBN only provides 4 KiB and 8 KiB of data and instruction memory, respectively.
  This requires further work to investigate whether more memory is required or if there is a smart solution.

## Future optimization ideas
### Support only 32-bit elements in BN ALU
As shown with the 2nd optimization, dropping the 16-bit support drastically reduced the area overhead.
This should also be considered for the remaining instructions implemented in the Bignum ALU.
However, this will mostly bring timing improvements as we can reduce the adder cascade.

### Opcode complexity tradeoff
Another idea is to split the complex multiplication instructions into multiple instructions.
This way, a `bn.mulvm` instruction would require the programmer to write multiple instructions in series.
With this, some of the FSM logic can be transferred into the software code and thus allows a simpler hardware implementation of the control logic, especially in regards to the control signal predecoding.
The drawback here is, that the OTBN has a RISC opcode architecture and thus only limited numbers of opcodes.
Wasting these precious opcodes and increasing programming complexity as well as code size is probably not worth the area savings.

## Related work
This implementation is inspired by the work of:

A. Abdulrahman, F. Oberhansl, H. N. H. Pham, J. Philipoom, P. Schwabe, T. Stelzer, and A. Zankl:
“Towards ML-KEM i& ML-DSA on OpenTitan”,
Cryptology ePrint Archive, Paper 2024/1192, 2024.
Available: https://eprint.iacr.org/2024/1192

# Original Readme
This repository contains hardware, software and utilities written as part of the
OpenTitan project. It is structured as monolithic repository, or "monorepo",
where all components live in one repository. It exists to enable collaboration
across partners participating in the OpenTitan project.

## Documentation

The project contains comprehensive documentation of all IPs and tools. You can
access it [online at docs.opentitan.org](https://docs.opentitan.org/).

## How to contribute

Have a look at [CONTRIBUTING](CONTRIBUTING.md) and our [documentation on
project organization and processes](./doc/project_governance/README.md)
for guidelines on how to contribute code to this repository.

## Licensing

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see [LICENSE](https://github.com/lowRISC/opentitan/blob/master/LICENSE) for full text).
