from fastapi import FastAPI
import uvicorn
import math

app = FastAPI()

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
        'addition': lambda n1, n2: n1 + n2 if n1 != None and n2 != None else 'no value',
        'subtraction': lambda n1, n2: n1 - n2 if n1 != None and n2 != None else 'no value',
        'multiplication': lambda n1, n2: n1 * n2 if n1 != None and n2 != None else 'no value',
        'division': lambda n1, n2: n1 / n2 if n1 != None and n2 != None and n2 != 0 else 'no value/division by zero',
        'power': lambda n1, n2: n1 ** n2 if n1 != None and n2 != None and n1 > 0 and float(n2).is_integer() else 'complex',
        'square_root': lambda n1, n2: math.sqrt(n1) if n1 != None and n1 >= 0 else 'undefined/complex',
        'percentage': lambda n1, n2: (n1 * n2) / 100 if n1 != None and n2 != None else 'no value'
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
        if alg_mod == 'run':
            steps = incoming_dict.get('steps')
            x = incoming_dict.get('x')
            steplen = len(steps) + 1 # Adding one for getting all values in the range.
            
            for key in range(1, steplen): 
                number_op = steps.get(str(key)) 
                if number_op:
                    operation_value = number_op['number'] # Getting the number that operation comes with.
                    operation_name = number_op['operation']
                    selected_operation = operations.get(operation_name)
                    
                    if selected_operation:
                        operation_value = int(operation_value)
                        x = selected_operation(x, operation_value) # x is the number that user enters at the end.
            
            return {'result': x, 'status': 'success'}

# Server Starting
if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=8000)