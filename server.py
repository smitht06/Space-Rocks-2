from flask import Flask, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app)


@app.after_request
def add_header(response):
    response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
    response.headers["Cross-Origin-Embedder-Policy"] = "require-corp"
    return response


@app.route("/")
def index():
    return send_from_directory(".", "space-rocks.html")


if __name__ == "__main__":
    app.run(port=8000)
