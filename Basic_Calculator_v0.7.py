
# Start


import time
import math

print('--* BASIC CALCULATOR v0.7 *--')
print('Welcome to Basic Calculator v0.7!')


# Operational Functions


def addition(a, b):
    return a + b

def subtraction(a, b):
    return a - b

def multiplication(a, b):
    return a * b

def division(a, b):
    return a / b

def square_root(a):
    return a ** 0.5

def power(a, b):
    return a ** b


# Geometrical Functions


def circle_area(r):
    return math.pi * r * r

def circle_perimeter(r):
    return 2 * math.pi * r

def rectangle_area(a, b):
    return a * b

def rectangle_perimeter(a, b):
    return 2 * (a + b)

def triangle_area(base, height):
    return (base * height) / 2


def get_float(prompt, allow_negative=False):
    while True:
        try:
            value = float(input(prompt))
            if not allow_negative and value < 0:
                print('Error: Value cannot be negative!')
                continue
            return value
        except ValueError:
            print('Invalid input! Please enter a valid number.')


# Mode Selection


while True:
    print('\nMain Menu')
    print('1) Operational Mode')
    print('2) Geometrical Mode')
    print('3) Exit Program')

    mode = input('Select a mode (1/2/3): ')


# Geometrical Operation Selection


    if mode == '2':
        while True:
            print('\nGeometrical Operations')
            print('1) Circle')
            print('2) Rectangle')
            print('3) Triangle')
            print('4) Change Mode')

            geo_choice = input('Select an option (1-4): ')

            # Geometrical Mode Calculations
            if geo_choice == '1':
                r = get_float('Enter radius: ')
                time.sleep(1)
                print('\nProcessing your calculation...')
                time.sleep(1)
                print('Circle Area:', circle_area(r))
                print('Circle Perimeter:', circle_perimeter(r))

            elif geo_choice == '2':
                a = get_float('Enter side A: ')
                b = get_float('Enter side B: ')
                time.sleep(1)
                print('\nProcessing your calculation...')
                time.sleep(1)
                print('Rectangle Area:', rectangle_area(a, b))
                print('Rectangle Perimeter:', rectangle_perimeter(a, b))

            elif geo_choice == '3':
                base = get_float('Enter base: ')
                height = get_float('Enter height: ')
                time.sleep(1)
                print('\nProcessing your calculation...')
                time.sleep(1)
                print('Triangle Area:', triangle_area(base, height))

            elif geo_choice == '4':
                print('Returning to main menu...')
                break

            else:
                print('Invalid option!')


    # Operational Mode Operation Selection


    elif mode == '1':
        while True:
            print('\nOperational Mode')
            print('1) Addition')
            print('2) Subtraction')
            print('3) Multiplication')
            print('4) Division')
            print('5) Square Root')
            print('6) Power')
            print('7) Change Mode')

            choice = input('Select an option (1-7): ')


            # Operational Mode Calculations

            if choice == '7':
                print('Returning to main menu...')
                break

            if choice == '5':
                first = get_float('Enter a number: ')
                second = None

            elif choice == '6':
                first = get_float('Enter base: ')
                second = get_float('Enter exponent:', allow_negative=True)

            elif choice in ['1', '2', '3', '4']:
                first = get_float('Enter first number: ')
                second = get_float('Enter second number: ')

            else:
                print('Invalid option!')
                continue

            time.sleep(1)
            print('\nProcessing your calculation...')
            time.sleep(1)

            if choice == '1':
                print(addition(first, second))
            elif choice == '2':
                print(subtraction(first, second))
            elif choice == '3':
                print(multiplication(first, second))
            elif choice == '4':
                if second == 0:
                    print('Error: Division by zero is not allowed!')
                else:
                    print(division(first, second))
            elif choice == '5':
                if first < 0:
                    print('Error: Cannot take square root of a negative number!')
                else:
                    print(square_root(first))
            elif choice == '6':
                print(power(first, second))


    # Exit


    elif mode == '3':
        for i in range(3, 0, -1):
            print(i)
            time.sleep(1)
        print('Program terminated :(')
        break

    else:
        print('Invalid mode selection!')
















































