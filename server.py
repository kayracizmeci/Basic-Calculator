from fastapi import FastAPI
import uvicorn

app = FastAPI()

# Calculations


@app.post("/receive_data")
def receive_data(incoming_dict: dict):

    # Decoder

    val0 = incoming_dict.get("val0")
    val1 = incoming_dict.get("val1", 0)
    val2 = incoming_dict.get("val2", 0)

    # Filters 

    final_response = ''
    return final_response

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)