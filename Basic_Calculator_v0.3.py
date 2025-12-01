
#Modules

import time
import random

#Start

print('--* BASIC CALCULATOR v0.3 *--')

# Random Mode
random_mode = input(
    'Do you wanna enable random mode? '
    '(what it does is in case you dont select a number correctly '
    'it will select a random number for you. y/n'
).lower()


Random_First_Numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 31, 23, 14, 12, 13, 85, 23, 27, 19]
Random_Second_Numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 34, 56, 78, 98, 23, 45, 12, 72, 31]

if random_mode == 'y':
    random_mode = True
elif random_mode == 'n':
    random_mode = False
else:
    print('Answer with y/n!')
    exit()

# Choosing
print('\nPlease choose the operation you want to do:')
print('1) Addition')
print('2) Subtraction')
print('3) Multiplication')
print('4) Division')

choice = input('Choose (1/2/3/4): ')

# Random Mode Choosing Part
if random_mode:
    if choice.isdigit() and choice in ['1', '2', '3', '4']:
        pass
    else:
        print('Choosing the operation randomly. Next time please answer with numbers.')
        choice = random.choice(['1', '2', '3', '4'])
        print(f'Randomly selected operation: {choice}')
else:
    # If Random Mode Is Closed Leave
    if choice not in ['1', '2', '3', '4']:
        print('Invalid operation choice and random mode is off. Exiting...')
        exit()

try:
    first_number = float(input('Enter first number: '))
    second_number = float(input('Enter second number: '))
except ValueError:
    if random_mode:
        print('Please enter a number next time. Picking numbers randomly...')
        first_number = random.choice(Random_First_Numbers)
        second_number = random.choice(Random_Second_Numbers)
        time.sleep(1)
        print(f'Randomly picked numbers: {first_number} and {second_number}')
    else:
        print('Invalid number input and random mode is off. Exiting...')
        exit()

time.sleep(1.5)

print('\nThank you for using Basic Calculator v0.3!')

time.sleep(1.5)

# Calculations
if choice == '1':
    print('Result:', first_number + second_number)
    time.sleep(2)
elif choice == '2':
    print('Result:', first_number - second_number)
    time.sleep(2)
elif choice == '3':
    print('Result:', first_number * second_number)
    time.sleep(2)
elif choice == '4':
    if second_number == 0:
        print("You can't divide a number by 0! Please try again.")
        print('Closing the program in 3 seconds')
        time.sleep(1)
        print('3')
        time.sleep(1)
        print('2')
        time.sleep(1)
        print('1')
        print('Program closed. Goodbye see you next time!')
    else:
        print('Result:', first_number / second_number)
        time.sleep(2)
