from typing import List


def task_1(array: List[int], target: int) -> List[int]:
    seen = {}
    for item in array:
        complement = target - item
        if complement in seen:
            return [complement, item]
        seen[item] = True
    return []


def task_2(number: int) -> int:
    sign = -1 if number < 0 else 1
    number = abs(number)
    reversed_number = 0
    while number > 0:
        last_digit = number % 10
        reversed_number = reversed_number * 10 + last_digit
        number = number // 10

    return sign * reversed_number



def task_3(array: List[int]) -> int:
    for i in range(len(array)):
        index = abs(array[i]) - 1
        if array[index] < 0:
            return abs(array[i])
        array[index] = -array[index]
    return -1


def task_4(roman: str) -> int:
    values = {
        'I': 1, 'V': 5,  'X': 10,
        'L': 50, 'C': 100, 'D': 500, 'M': 1000
    }

    result = 0
    for i in range(len(roman)):
        curr = values[roman[i]]
        next = values[roman[i + 1]] if i + 1 < len(roman) else 0

        if curr < next:
            result -= curr
        else:
            result += curr
    return result


def task_5(array: List[int]) -> int:
 minimal = array[0]
 for item in array:
     if item < minimal:
         minimal = item
 return minimal

