# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import random

random.seed(23453456346236)


def diff_unsigned(e):
    lower = random.randint(1 / 2 * (2**e), 3 / 4 * (2**e))
    upper = random.randint(3 / 4 * (2**e), 2**e - 1)
    res = lower - upper
    res = (1 << e) + res if res < 0 else res
    print(f"e = {e}")
    print(f"lower: {hex(lower)}")
    print(f"upper: {hex(upper)}")
    print(f"resul: {hex(res)}\n")


diff_unsigned(16)
diff_unsigned(32)
diff_unsigned(64)
diff_unsigned(128)
diff_unsigned(256)
