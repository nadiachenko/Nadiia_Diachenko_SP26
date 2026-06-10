import time
#from datetime import time
from typing import List

Matrix = List[List[int]]


def task_1(exp: int):
    def power(n):
        return n ** exp
    return power


def task_2(*args, **kwags):
    for value in args:
        print(value)
    for value in kwags.values():
        print(value)


def helper(func):
    def wrapper(*args, **kwargs):
        print("Hi, friend! What's your name?")
        result = func(*args, **kwargs)
        print("See you soon!")
        return result
    return wrapper



@helper
def task_3(name: str):
    print(f"Hello! My name is {name}.")


def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        run_time = end - start
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        return result
    return wrapper


@timer
def task_4():
    return len([1 for _ in range(0, 10**8)])


def task_5(matrix: Matrix) -> Matrix:
    rows = len(matrix)
    cols = len(matrix[0])

    transposed = [[0] * rows for _ in range(cols)]

    for i in range(rows):
        for j in range(cols):
            transposed[j][i] = matrix[i][j]

    return transposed


def task_6(queue: str):
    balance = 0

    for char in queue:
        if char == '(':
            balance += 1
        elif char == ')':
            balance -= 1

        if balance < 0:
            return False
    return balance == 0
