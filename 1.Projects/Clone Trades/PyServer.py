from flask import Flask, request

app = Flask(__name__)

shared_msg = "---"

# API thêm giao dịch
@app.route('/api/send', methods=['POST'])
def send_trade():
    global shared_msg
    shared_msg = request.data.decode('utf-8');
    return "OK", 200

# API lấy toàn bộ danh sách giao dịch
@app.route('/api/get', methods=['GET'])
def get_trades():
    return shared_msg, 200

# Chạy server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
