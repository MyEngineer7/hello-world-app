from flask import Flask, jsonify
import socket

# Initialize Flask application
app = Flask(__name__)

# Root endpoint that returns Hello World
@app.route('/')
def hello_world():
    return jsonify({
        'message': 'Hello, World!',
        'hostname': socket.gethostname()
    })

# Health check endpoint for monitoring
@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

# Run the application
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000) 