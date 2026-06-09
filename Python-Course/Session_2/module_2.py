# from collections import defaultdict as dd
# from itertools import product
from typing import Any, Dict, List, Tuple
from unittest import result


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    result = data_1.copy()
    for k, v in data_2.items():
        if k in result:
            result[k] = result[k] + v
        else:
            result[k] = v
    return result


def task_2():
    result = {}

    for num in range(1,16):
        result[num] = num**2
    return result
print(task_2())

def task_3(data: Dict[Any, List[str]]):
    result = ['']

    for key in data:
        new_result = []
        for combo in result:
            for letter in data[key]:
                new_result.append(combo + letter)
        result = new_result
    return result


def task_4(data: Dict[str, int]):
    sorted_keys = sorted(data, key=lambda k: data[k], reverse=True)
    return sorted_keys[:3]


def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    final_dict = {}
    for color, number in data:
        if color not in final_dict:
            final_dict[color] = [number]
        else:
            final_dict[color].append(number)
    return final_dict

def task_6(data: List[Any]):
    final_list = []
    for item in data:
        if item not in final_list:
            final_list.append(item)
    return final_list


def task_7(words: List[str]) -> str:
    if not words:
        return ""
    prefix = words[0]

    for word in words[1:]:
        while not word.startswith(prefix):
            prefix = prefix[:-1]
            if not prefix:
                return ""

    return prefix


def task_8(haystack: str, needle: str) -> int:
    if needle == "":
        return 0

    h_len = len(haystack)
    n_len = len(needle)
    for i in range(h_len - n_len + 1):
        chunk = haystack[i: i + n_len]

        if chunk == needle:
            return i
    return -1

