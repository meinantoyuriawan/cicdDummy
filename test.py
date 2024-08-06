import pytest

from main import helloPython

def test_helloPython():
    assert helloPython() == "hello Python"
