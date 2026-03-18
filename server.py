from fastapi import FastAPI
import uvicorn
import math
import os
import json

app = FastAPI()


file_name = 'algorithm.json'
if not os.path.exists(file_name):
    with open(file_name, 'w') as f:
        json.dump({}, f)
try:
    with open(file_name, 'r') as f:
        save_data = json.load(f)
except (json.JSONDecodeError, IOError):
    save_data = {}
if not isinstance(save_data, dict):
    save_data = {}

def algorithm_control(x, steps, operations):
    x = float(x) if x is not None else 0.0          
    if steps:
        steplen = len(steps) + 1
        for key in range(1, steplen): 
            if isinstance(x, str): break
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

    # Decoder
    mod = incoming_dict.get('mod')
        
    if mod == 'op':
          operation = incoming_dict.get('operation')
          num1 = incoming_dict.get('num1', None)
          num2 = incoming_dict.get('num2', None)
    
    # Lambda Operations And Filter
    operations = {
        'addition': lambda n1, n2: float(n1) + float(n2) if n1 != None and n2 != None else 'no value',
        'subtraction': lambda n1, n2: float(n1) - float(n2) if n1 != None and n2 != None else 'no value',
        'multiplication': lambda n1, n2: float(n1) * float(n2) if n1 != None and n2 != None else 'no value',
        'division': lambda n1, n2: float(n1) / float(n2) if n1 != None and n2 != None and float(n2) != 0 else 'no value/division by zero',
        'power': lambda n1, n2: float(n1) ** float(n2) if n1 != None and n2 != None and float(n1) > 0 and float(n2).is_integer() else 'complex',
        'square_root': lambda n1, n2: math.sqrt(float(n1)) if n1 != None and float(n1) >= 0 else 'undefined/complex',
        'percentage': lambda n1, n2: (float(n1) * float(n2)) / 100 if n1 != None and n2 != None else 'no value'
    }

    # Controls

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

        if alg_mod == 'save':
            alg_save_name = incoming_dict.get('alg_save_name') # We are getting the key for accesing the whole data.
            alg_data = incoming_dict.get(alg_save_name)
            save_data[alg_save_name] = alg_data
            with open(file_name, 'w') as f:
                json.dump(save_data, f, indent=4)      
            return {'status': 'saved'}
        
        if alg_mod == 'run_save':
            alg_save_name = incoming_dict.get('alg_save_name') 
            steps = save_data.get(alg_save_name)
            x = incoming_dict.get('x')
            x = algorithm_control(x, steps, operations)
            return {'result': x, 'status': 'success'}
    
            
        if alg_mod == 'run':
            steps = incoming_dict.get('steps')
            x = (incoming_dict.get('x'))
            x = algorithm_control(x, steps, operations)
            return {'result': x, 'status': 'success'}
        

        if alg_mod == 'delete':
            alg_save_name = incoming_dict.get('alg_save_name')
            removed_item = save_data.pop(alg_save_name, None)
            if removed_item is not None:
                with open(file_name, 'w') as f:
                    json.dump(save_data, f, indent=4)
                return {'status': 'deleted'}
            else:
                return {'status': 'failed', 'error': f'there is no save as {alg_save_name}'}

       
        if alg_mod == 'clear_all':
            save_data.clear() 
            with open(file_name, 'w') as f:
                json.dump({}, f, indent=4) 
            return {'status': 'all_clean'}

# Server Starting
if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=8000)