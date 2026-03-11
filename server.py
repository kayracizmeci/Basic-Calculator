from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.post('/receive_data')
def receive_data(incoming_dict: dict):

    # Decoder
    operation = incoming_dict.get('operation')
    num1 = incoming_dict.get('num1', 0) 
    num2 = incoming_dict.get('num2', 0)

    # Lambda Operations And Filter
    operations = {
        'addition': lambda n1, n2: n1 + n2,
        'subtraction': lambda n1, n2: n1 - n2,
        'multiplication': lambda n1, n2: n1 * n2,
        'division': lambda n1, n2: n1 / n2 if n2 != 0 else 'division by 0',
    }

    # Controls
    selected_operation = operations.get(operation)
    if selected_operation is None:
        return {'error': 'invalid operation', 'status': 'failed'}
 
    result = selected_operation(num1, num2)
    final_response = {'result': result}
    if isinstance(result, str):
        final_response =  {'error': result, 'status':'failed'}
    else:
        final_response =  {'result': result, 'status':'success'}
    return final_response


# Server Starting
if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=8000)