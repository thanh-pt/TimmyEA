// Test với Local Host

// URL server Flask
string url = "http://127.0.0.1:80/api/";
string headers = "Content-Type: application/json\r\n";

void sendMsg(string msg){
    string result_headers;
    char result[];
    char data[];
    StringToCharArray(msg, data); // Chuyển chuỗi sang mảng ký tự


    // Gửi HTTP POST request
    int response_code = WebRequest("POST", url+"send", headers, 1000, data, result, result_headers);

    if (response_code == -1) {
        Print("Error in WebRequest: ", GetLastError());
    }
}

string getMsg(){
    string result_headers;
    char result[];
    char data[];

    // Gửi yêu cầu GET
    int response_code = WebRequest("GET", url+"get", headers, 1000, data, result, result_headers);
    
    if (response_code == -1) {
        Print("Error in WebRequest: ", GetLastError());
        return "-1";
    }
    
    return CharArrayToString(result);
}
