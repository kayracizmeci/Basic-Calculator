from fastapi import FastAPI
import uvicorn
import math
import os
import json

app = FastAPI()

file_name = 'algorithm.json'

def save(data):
    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)


def load():
    try:
        with open(file_name, 'r') as f:
            data = json.load(f)
    except (json.JSONDecodeError, IOError):
        data = {}
    if not isinstance(data, dict): # If data is not a dictionary, returns an empty dictionary.
        data = {}
    return data

if not os.path.exists(file_name):
    save({})

operations = {
    'addition': lambda n1, n2: float(n1) + float(n2) if n1 != None and n2 != None else 'no value',
    'subtraction': lambda n1, n2: float(n1) - float(n2) if n1 != None and n2 != None else 'no value',
    'multiplication': lambda n1, n2: float(n1) * float(n2) if n1 != None and n2 != None else 'no value',
    'division': lambda n1, n2: float(n1) / float(n2) if n1 != None and n2 != None and float(n2) != 0 else 'no value/division by zero',
    'power': lambda n1, n2: ('no value' if n1 is None or n2 is None else ('no value/division by zero' if float(n1) == 0.0 and float(n2) < 0 else ('complex' if float(n1) < 0 and not float(n2).is_integer() else float(n1) ** float(n2)))),
    'square_root': lambda n1, n2: math.sqrt(float(n1)) if n1 != None and float(n1) >= 0 else 'undefined/complex',
    'percentage': lambda n1, n2: (float(n1) * float(n2)) / 100 if n1 != None and n2 != None else 'no value'
}

def algorithm_control(x, steps, operations):
    x = float(x) if x is not None else 0.0          
    if steps:
        steplen = len(steps) + 1
        for key in range(1, steplen): 
            if isinstance(x, str): break # If x is a string, breaks the loop.
            number_op = steps.get(str(key)) 
            if number_op:
                operation_value = float(number_op['number'])  
                operation_name = number_op['operation']
                selected_operation = operations.get(operation_name)  
                if selected_operation:
                    x = selected_operation(x, operation_value)
    return x

@app.post('/receive_data')
def receive_data(incoming_dict: dict):
    mod = incoming_dict.get('mod')

    if mod == 'op':
          operation = incoming_dict.get('operation')
          num1 = incoming_dict.get('num1', None)
          num2 = incoming_dict.get('num2', None)

   
    # Operation 
    if mod == 'op':
      selected_operation = operations.get(operation)  
      if selected_operation is None:
          return {'error': 'invalid operation', 'status': 'failed'}
      result = selected_operation(num1, num2)
      if isinstance(result, str):
          return {'error': result, 'status': 'failed'}
    
      return {'result': result, 'status': 'success'}
    
    # Algorithm
    if mod == 'alg':
        alg_mod = incoming_dict.get('alg_mod')
        data = load()  
        if alg_mod == 'save':
            alg_save_name = incoming_dict.get('alg_save_name') # We are getting the key for accesing the whole data.
            alg_data = incoming_dict.get(alg_save_name)
            data[alg_save_name] = alg_data
            save(data)
            return {'status': 'saved'}
        
        if alg_mod == 'run_save':
            alg_save_name = incoming_dict.get('alg_save_name') 
            steps = data.get(alg_save_name)
            x = incoming_dict.get('x')
            x = algorithm_control(x, steps, operations) # Runs the algorithm.
            return {'result': x, 'status': 'success'}
    
            
        if alg_mod == 'run':
            steps = incoming_dict.get('steps')
            x = (incoming_dict.get('x'))
            x = algorithm_control(x, steps, operations)
            return {'result': x, 'status': 'success'}
        

        if alg_mod == 'delete':
            alg_save_name = incoming_dict.get('alg_save_name') 
            removed_item = data.pop(alg_save_name, None) # Removes the item from the data.
            if removed_item is not None: 
                save(data) # Updates the data.
                return {'status': 'deleted'}
            else:
                return {'status': 'failed', 'error': f'there is no save as {alg_save_name}'}

       
        if alg_mod == 'clear_all':
            save({}) 
            return {'status': 'all_clean'}

# Server Starting
if __name__ == '__main__':
    host = '127.0.0.1'
    port = int(os.getenv('PORT', '54823'))
    uvicorn.run(app, host=host, port=port)