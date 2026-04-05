from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional, Dict
import uvicorn
import math
import os
import json
import aiofiles


class Step(BaseModel):
    number: float
    operation: str

class CalculationReq(BaseModel):
    mod: str

    # Algorithm Mode
    alg_mod: Optional[str] = None
    x: Optional[float] = None
    alg_save_name: Optional[str] = None
    steps: Optional[Dict[str, Step]] = None

    # Operational Mode
    operation: Optional[str] = None
    num1: Optional[float] = None
    num2: Optional[float] = None

app = FastAPI()

file_name = 'algorithm.json'

async def save(data):
    async with aiofiles.open(file_name, 'w') as f:
        await f.write(json.dumps(data, indent=4))


async def load():
    try:
        if not os.path.exists(file_name):
            return {}
        async with aiofiles.open(file_name, 'r') as f:
            data_raw = await f.read() 
            data = json.loads(data_raw) if data_raw else {} 
    except (json.JSONDecodeError, IOError):
        data = {}
    if not isinstance(data, dict): # If data is not a dictionary, returns an empty dictionary.
        data = {}
    return data


operations = {
    'addition': lambda n1, n2: n1 + n2,
    'subtraction': lambda n1, n2: n1 - n2,
    'multiplication': lambda n1, n2: n1 * n2,
    'division': lambda n1, n2: n1 / n2 if n2 != 0 else 'division by zero',
    'power': lambda n1, n2: (
        'undefined' if n1 == 0 and n2 < 0 else (
            'complex' if n1 < 0 and not float(n2).is_integer() else n1 ** n2
        )
    ),
    'square_root': lambda n1, n2: math.sqrt(n1) if n1 >= 0 else 'undefined/complex',
    'percentage': lambda n1, n2: (n1 * n2) / 100
}

def algorithm_control(x: float | None, steps: Dict[str, Step] | None, operations: dict):
    if x is None:
        x = 0.0     
    if steps:
        for key in sorted(steps.keys(), key=int): 
            if isinstance(x, str): 
                break  
            number_op = steps.get(str(key)) 
            if number_op:
                is_dict = isinstance(number_op, dict)     
                operation_value = number_op['number'] if is_dict else number_op.number
                operation_name = number_op['operation'] if is_dict else number_op.operation
                selected_operation = operations.get(operation_name)  
                if selected_operation:
                    x = selected_operation(x, operation_value)
    return x

@app.post('/receive_data')
async def receive_data(data: CalculationReq):
   
    # Operation 
    if data.mod == 'op':
      selected_operation = operations.get(data.operation)  
      if selected_operation is None:
          return {'error': 'invalid operation', 'status': 'failed'}
      elif data.num1 is None:
          return {'error': 'no value', 'status': 'failed'}
      elif data.operation != 'square_root' and data.num2 is None:
          return {'error': 'no value', 'status': 'failed'}
      
      result = selected_operation(data.num1, data.num2 if data.num2 is not None else 0)
      
      if isinstance(result, str):
            return {'error': result, 'status': 'failed'}
      else:
            return {'result': result, 'status': 'success'}
      
    # Algorithm
    elif data.mod == 'alg':  
        if data.alg_mod == 'save':
            if not data.alg_save_name:
                return {'status': 'failed', 'error': 'missing save name'}
            if not data.steps:
                return {'status': 'failed', 'error': 'missing steps'}
            all_saved_data = await load() # We are using load for accessing to the data
            steps = {key: value.model_dump() for key, value in data.steps.items()}
            all_saved_data[data.alg_save_name] = steps
            await save(all_saved_data)
            return {'status': 'saved', 'name': data.alg_save_name}      
        
        elif data.alg_mod == 'run_save':
            if not data.alg_save_name:
                return {'status': 'failed', 'error': 'missing save name'}
            all_saved_data = await load()
            saved_steps = all_saved_data.get(data.alg_save_name) 
            if not saved_steps:
                return {'status': 'failed', 'error': f'there is no save as {data.alg_save_name}'}
            x = algorithm_control(data.x, saved_steps, operations) 
            if isinstance(x, str):
                return {'status': 'failed', 'error': x}
            return {'result': x, 'status': 'success'}
    
            
        elif data.alg_mod == 'run':
            if not data.steps:
                return {'status': 'failed', 'error': 'missing steps'}
            x = algorithm_control(data.x, data.steps, operations)
            if isinstance(x, str):
                return {'status': 'failed', 'error': x}
            return {'result': x, 'status': 'success'}
        

        elif data.alg_mod == 'delete':
            if not data.alg_save_name:
                return {'status': 'failed', 'error': 'missing save name'}
            all_saved_data = await load()  
            removed_item = all_saved_data.pop(data.alg_save_name, None) 
            
            if removed_item is not None: 
                await save(all_saved_data) 
                return {'status': 'deleted', 'name': data.alg_save_name}
            else:
                return {'status': 'failed', 'error': f'there is no save as {data.alg_save_name}'}

       
        elif data.alg_mod == 'clear_all':
            await save({}) 
            return {'status': 'all_clean'}
        else:
            return {'status': 'failed', 'error': 'invalid algorithm mode'}
    else:
        return {'status': 'failed', 'error': 'invalid mode'}
        
# Server Starting
if __name__ == '__main__':
    host = '127.0.0.1'
    port = int(os.getenv('PORT', '54823'))
    uvicorn.run(app, host=host, port=port)