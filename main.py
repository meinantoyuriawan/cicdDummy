from flask import Flask

app = Flask(__name__)

def helloPython():
    return "hello Python"

@app.route('/')
def hello():
    hello = helloPython()
    return hello