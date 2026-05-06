from source import attack_demo
from source import token_verify_fixed
from source import token_verify_vulnerable


def test_vulnerable_functional_correctness_accepts_real_tag():
    message = b"hello"
    tag = token_verify_vulnerable.make_tag(message)
    assert token_verify_vulnerable.verify_message(message, tag)


def test_vulnerable_functional_correctness_rejects_bad_tag():
    message = b"hello"
    tag = bytearray(token_verify_vulnerable.make_tag(message))
    tag[0] ^= 1
    assert not token_verify_vulnerable.verify_message(message, bytes(tag))


def test_fixed_accepts_real_tag():
    message = b"hello"
    tag = token_verify_fixed.make_tag(message)
    assert token_verify_fixed.verify_message(message, tag)


def test_fixed_rejects_bad_tag():
    message = b"hello"
    tag = bytearray(token_verify_fixed.make_tag(message))
    tag[0] ^= 1
    assert not token_verify_fixed.verify_message(message, bytes(tag))


def test_cost_oracle_recovers_secret_tag():
    recovered = attack_demo.recover_tag(verbose=False)
    assert recovered == attack_demo.SECRET_TAG
