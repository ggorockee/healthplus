
import pytest

def test_always_pass():
    assert True

def test_basic_math():
    assert 1 + 1 == 2

def test_string_operations():
    assert 'hello' + ' world' == 'hello world'

def test_list_operations():
    assert [1, 2, 3] + [4, 5] == [1, 2, 3, 4, 5]

def test_dict_operations():
    assert {'a': 1, 'b': 2}['a'] == 1
