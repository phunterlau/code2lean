"""Deterministic timing-leak demonstration.

This is not a noisy wall-clock timing attack. Instead, it exposes the number of
byte comparisons performed by the vulnerable implementation. In real systems,
that comparison count can become measurable latency.
"""

from __future__ import annotations

import hashlib
import hmac

SECRET_KEY = b"demo-secret-key"
MESSAGE = b"transfer $1000 to Bob"


def make_tag(message: bytes) -> bytes:
    return hmac.new(SECRET_KEY, message, hashlib.sha256).digest()


SECRET_TAG = make_tag(MESSAGE)


def insecure_compare_with_cost(expected: bytes, supplied: bytes) -> tuple[bool, int]:
    """Same logic as insecure_compare, plus observable comparison count."""
    cost = 0

    if len(expected) != len(supplied):
        return False, cost

    for i in range(len(expected)):
        cost += 1
        if expected[i] != supplied[i]:
            return False, cost

    return True, cost


def oracle(candidate: bytes) -> tuple[bool, int]:
    """Attacker-facing oracle: acceptance plus timing/cost signal."""
    return insecure_compare_with_cost(SECRET_TAG, candidate)


def recover_tag(verbose: bool = True) -> bytes:
    """Recover SECRET_TAG using the cost leak.

    The final byte needs the boolean success signal because all candidates with
    the correct prefix perform the same number of comparisons on the final
    byte; only the exact tag returns True.
    """
    n = len(SECRET_TAG)
    guess = bytearray(b"\x00" * n)

    for i in range(n):
        best_byte = 0
        best_score = (-1, 0)  # (cost, accepted-as-int)

        for b in range(256):
            candidate = bytearray(guess)
            candidate[i] = b

            ok, cost = oracle(bytes(candidate))
            score = (cost, 1 if ok else 0)

            if score > best_score:
                best_score = score
                best_byte = b

        guess[i] = best_byte
        if verbose:
            print(f"Recovered byte {i:02d}: {best_byte:02x}, score={best_score}")

    return bytes(guess)


if __name__ == "__main__":
    recovered = recover_tag(verbose=True)

    print()
    print("real tag     :", SECRET_TAG.hex())
    print("recovered tag:", recovered.hex())
    print("success      :", hmac.compare_digest(SECRET_TAG, recovered))
