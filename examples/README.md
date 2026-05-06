# Example Set

Thirty self-contained Python functions, paired with fixtures the pipeline uses
for differential testing. Each directory has `source.py` (the function) and
`fixtures.py` (the test cases + Lean call sites).

| #  | Example                  | Aspect                          | Crypto-flavored |
|----|--------------------------|---------------------------------|:--------------:|
| 01 | `insecure_compare`       | byte equality, early-exit       | yes (HMAC tag compare) |
| 02 | `xor_bytes`              | byte-wise XOR                   | yes (one-time pad core) |
| 03 | `bytes_to_nat`           | big-endian byte → integer       | yes (DER / ECDSA encoding) |
| 04 | `factorial`              | recursive arithmetic            |                |
| 05 | `constant_time_select`   | branchless conditional spec     | yes (CT primitives) |
| 06 | `reverse_list`           | list reversal                   |                |
| 07 | `list_member`            | linear search                   |                |
| 08 | `count_occurrences`      | counting / fold                 |                |
| 09 | `is_palindrome`          | composition (reverse + equality)|                |
| 10 | `clamp`                  | bounded comparison (Int)        |                |
| 11 | `all_zero`               | byte predicate / universal check| yes            |
| 12 | `byte_sum`               | byte fold / sum                 | yes            |
| 13 | `max2`                   | maximum of two Nats             |                |
| 14 | `min2`                   | minimum of two Nats             |                |
| 15 | `abs_diff`               | Nat distance                    |                |
| 16 | `saturating_add8`        | one-byte saturating arithmetic  | yes            |
| 17 | `first_byte_or_zero`     | byte head with default          | yes            |
| 18 | `list_head_or_default`   | list head with default          |                |
| 19 | `list_sum`               | list fold / sum                 |                |
| 20 | `list_length`            | list length by counting         |                |
| 21 | `bool_to_nat`            | Bool encoding                   |                |
| 22 | `bool_implies`           | Boolean implication             |                |
| 23 | `same_length`            | public byte-length comparison   | yes            |
| 24 | `bounded_sub`            | subtraction clamped at zero     |                |
| 25 | `increment_all`          | list map                        |                |
| 26 | `product_or_one`         | list fold / product             |                |
| 27 | `any_true`               | existential Bool list predicate |                |
| 28 | `all_true`               | universal Bool list predicate   |                |
| 29 | `index0_equals`          | list head comparison            |                |
| 30 | `swap_pair`              | tuple product return            |                |

Run any example through the pipeline:

```bash
.venv/bin/python -m verify.pipeline --example examples/02_xor_bytes --provider gemini
.venv/bin/python -m verify.pipeline --example examples/04_factorial --provider openai
```

The pipeline:

1. AST-extracts the named function from `source.py`.
2. Asks the LLM (Gemini 3.1 Pro or GPT-5.5) to produce a Lean translation
   plus a functional-correctness theorem the model picks itself.
3. Compiles the resulting `RepoVerify/Autogen.lean` with `lake env lean`.
4. Repairs on compile failure (up to `--max-repair` rounds).
5. Validates with `#print axioms` (allowlist: `propext`, `Classical.choice`,
   `Quot.sound`).
6. Differential-tests the Lean `#eval` outputs against the Python function
   using the cases in `fixtures.py`.

## Fixture format

Each `fixtures.py` is a Python module exposing:

```python
FUNCTION = "name_in_source_py"           # required

# Optional. Defaults to "source.py" alongside fixtures.py.
SOURCE = "source.py"

# Optional. Defaults to camelCase of FUNCTION.
LEAN_FN = "customLeanName"

# (py_args_tuple, lean_call_str). Empty list = skip diff test.
CASES = [
    ((b"abc", b"abc"), "myFunc [97, 98, 99] [97, 98, 99]"),
    ...
]

# Optional converter for return values that the default doesn't cover.
def to_lean_value(v):
    return ...
```
