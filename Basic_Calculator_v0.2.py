import time

print('--* BASIC CALCULATOR v0.2 *--')

#Choosing
print('\nPlease choose the operation you want to do:')
print("1) Addition")
print("2) Subtraction")
print('3) Multiplication')
print('4) Division')

choice = input("Choose (1/2/3/4): ")

first_number = float(input("Enter first number: "))
second_number = float(input("Enter second number: "))


#Waiting(For realism you can remove it if you want.)

time.sleep(1.5)

print('\nThank you for using Basic Calculator v0.2!')

time.sleep(1.5)

#Calculations
if choice == "1":
    print("Result:", first_number + second_number)
elif choice == "2":
    print("Result:", first_number - second_number)
elif choice == "3":
    print("Result:", first_number * second_number)
elif choice == '4':
    print('Result:', first_number / second_number)
else:
    print('Invalid Operation! Please try again.')
