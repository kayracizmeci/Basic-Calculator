#Modules:
from itertools import repeat

import time

#Start:

print('--* BASIC CALCULATOR v0.4 *--')
print('Welcome to Basic Calculator v0.4!')



condition = True

while condition == True:
    # Choosing
    print('\nPlease choose the operation you want to do:')
    print('1) Addition')
    print('2) Subtraction')
    print('3) Multiplication')
    print('4) Division')
    print('5) Square Root')
    print('6) Power')

    choice = input('Choose (1/2/3/4/5/6): ')

    if choice not in ['1', '2', '3', '4', '5', '6']:
        print('Invalid operation choice. Exiting...')
        exit()

    # Input section:

    try:
        if choice == '5':  # Square root only needs one number
            first_number = float(input('Enter number to take its square root: '))
            second_number = None

        elif choice == '6':  # Power: needs base + exponent
            first_number = float(input('Enter base number: '))
            second_number = float(input('Enter exponent: '))

        else:  # Normal 4 operations
            first_number = float(input('Enter first number: '))
            second_number = float(input('Enter second number: '))

    except ValueError:
        print('Invalid number input. Exiting...')
        exit()

    time.sleep(1.2)

    print('\nThank you for using Basic Calculator v0.4!')

    time.sleep(1)

    # Calculations:

    if choice == '1':
        print('Result:', first_number + second_number)

    elif choice == '2':
        print('Result:', first_number - second_number)

    elif choice == '3':
        print('Result:', first_number * second_number)

    elif choice == '4':
        if second_number == 0:
            print("You can't divide by 0!")
        else:
            print('Result:', first_number / second_number)

    elif choice == '5':
        if first_number < 0:
            print("You can't take the square root of a negative number!")
        else:
            print('Result:', first_number ** 0.5)

    elif choice == '6':
        print('Result:', first_number ** second_number)

    Answer_1 = input('Do you wanna do more operations? y/n').lower()

    if Answer_1 == 'y':
        continue
    elif Answer_1 == 'n':
        break
    else:
        print('Closing the program...')
        break









