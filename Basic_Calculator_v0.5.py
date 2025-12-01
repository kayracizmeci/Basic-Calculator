














# Modules:
from itertools import repeat
import time

# Start:

print('--* BASIC CALCULATOR v0.5 *--')
print('Welcome to Basic Calculator v0.5!')

condition = True

while condition == True:

    # Choosing

    print('\nPlease choose the operation you want to perform:')
    print('1) Addition')
    print('2) Subtraction')
    print('3) Multiplication')
    print('4) Division')
    print('5) Square Root')
    print('6) Power')

    choice = input('Select an option (1/2/3/4/5/6): ')

    while choice not in ['1', '2', '3', '4', '5', '6']:
        print('Invalid operation! Please select a valid option.')
        print('1) Addition')
        print('2) Subtraction')
        print('3) Multiplication')
        print('4) Division')
        print('5) Square Root')
        print('6) Power')
        choice = input('Select an option (1/2/3/4/5/6): ')
        continue


    # Input section:

    # Square root (only 1 number)
    if choice == '5':
        while True:
            first_number = input("Enter a number to calculate its square root: ")
            try:
                first_number = float(first_number)
                second_number = None
                break
            except ValueError:
                print("Invalid input! Please enter a valid number.")

    # Power (base + exponent)
    elif choice == '6':
        while True:
            first_number = input("Enter the base number: ")
            try:
                first_number = float(first_number)
                break
            except ValueError:
                print("Invalid input! Please enter a valid number.")

        while True:
            second_number = input("Enter the exponent: ")
            try:
                second_number = float(second_number)
                break
            except ValueError:
                print("Invalid input! Please enter a valid number.")

    # Normal 4 operations
    else:
        while True:
            first_number = input("Enter the first number: ")
            try:
                first_number = float(first_number)
                break
            except ValueError:
                print("Invalid input! Please enter a valid number.")

        while True:
            second_number = input("Enter the second number: ")
            try:
                second_number = float(second_number)
                break
            except ValueError:
                print("Invalid input! Please enter a valid number.")


    # Calculations:

    time.sleep(1.2)

    print('\nProcessing your calculation...')

    time.sleep(1)

    if choice == '1':
        print('Result:', first_number + second_number)

    elif choice == '2':
        print('Result:', first_number - second_number)

    elif choice == '3':
        print('Result:', first_number * second_number)

    elif choice == '4':
        if second_number == 0:
            print("Error: Division by zero is not allowed!")
        else:
            print('Result:', first_number / second_number)

    elif choice == '5':
        if first_number < 0:
            print("Error: Cannot compute the square root of a negative number!")
        else:
            print('Result:', first_number ** 0.5)

    elif choice == '6':
        print('Result:', first_number ** second_number)

    Answer_1 = input('Would you like to perform another operation? (y/n): ').lower()

    if Answer_1 == 'y':
        continue
    elif Answer_1 == 'n':
        break
    else:
        print('Invalid response. Closing the program...')
        break











