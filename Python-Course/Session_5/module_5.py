
import os
from pathlib import Path
from random import choice
from random import seed
from typing import List, Union
import re
import requests
from requests.exceptions import RequestException




S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    seed(1)
    with open(PATH_TO_NAMES, "r", encoding="utf-8") as f_names:
        names = []
        for line in f_names:
            if line.strip():
                cleaned_line = line.strip().lower()
                names.append(cleaned_line)
    names.sort()
    surnames = []
    with open(PATH_TO_SURNAMES, "r", encoding="utf-8") as f_sur:
        for line in f_sur:
            if line.strip():
                surnames.append(line.strip().lower())

    with open(PATH_TO_OUTPUT, "w", encoding="utf-8") as f_out:
        for name in names:
            random_surname = choice(surnames)
            f_out.write(f"{name} {random_surname}\n")


def task_2(top_k: int):
    with open(PATH_TO_STOP_WORDS, "r", encoding="utf-8") as f_stop:
        stop_words = set()
        for line in f_stop:
         if line.strip():
            stop_words.add(line.strip().lower())
    with open(PATH_TO_TEXT, "r", encoding="utf-8") as f_text:
        text_content = f_text.read().lower()
    all_words = re.findall(r"[a-z]+", text_content)
    filtered_words = []
    for word in all_words:
        if word not in stop_words:
            filtered_words.append(word)
    word_counts = {}
    for word in filtered_words:
         if word in word_counts:
            word_counts[word] += 1
         else:
            word_counts[word] = 1
    sorted_tuples = sorted(word_counts.items(), key=lambda item: item[1], reverse=True)
    return sorted_tuples[:top_k]


def task_3(url: str):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response
    except RequestException as e:
        raise RequestException

def task_4(data: List[Union[int, str, float]]):
    total_sum = 0.0
    for item in data:
        try:
            total_sum += item
        except TypeError:
            total_sum += float(item)
    if total_sum.is_integer():
        return int(total_sum)
    return total_sum

def task_5():
    var1, var2 = input("Enter number: ").split()
    try:
        result = float(var1)/float(var2)
        print(result)
    except ZeroDivisionError:
        print("Can't divide by zero")
    except ValueError:
        print("Entered value is wrong")
