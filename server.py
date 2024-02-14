#!/usr/bin/env python

from pathlib import Path
from flask import Flask, jsonify, send_from_directory

challenge_dir = Path(__file__).parent / "acme/.well-known/acme-challenge"
port = 8080

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify({"message": "Welcome to the server!"})


@app.route("/.well-known/acme-challenge/<path:filename>")
def challenge(filename):
    challenge_file = challenge_dir / filename
    if challenge_file.exists():
        return send_from_directory(challenge_dir, filename, mimetype="text/plain")
    else:
        return "404 Not Found", 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port)
