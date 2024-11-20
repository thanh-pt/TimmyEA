#import "kernel32.dll"
bool UnmapViewOfFile(int lpBaseAddress);  // Unmap vùng bộ nhớ đã ánh xạ
int CreateFileMappingA(int hFile, int lpAttributes, int flProtect, int dwMaximumSizeHigh, int dwMaximumSizeLow, string lpName);
int OpenFileMappingA(int dwDesiredAccess, bool bInheritHandle, string lpName);
int MapViewOfFile(int hFileMappingObject, int dwDesiredAccess, int dwFileOffsetHigh, int dwFileOffsetLow, int dwNumberOfBytesToMap);
bool WriteProcessMemory(int hProcess, int lpBaseAddress, uchar &lpBuffer[], int nSize, int &lpNumberOfBytesWritten);
bool ReadProcessMemory(int hProcess, int lpBaseAddress, uchar &lpBuffer[], int nSize, int &lpNumberOfBytesRead);
bool CloseHandle(int hObject);
int GetLastError();
#import

int CreateSharedMemory(string name, int size) {
    int PAGE_READWRITE = 0x04;
    int hMapFile = CreateFileMappingA(
        INVALID_HANDLE,   
        0,                
        PAGE_READWRITE,   
        0,                
        size,             
        name              
    );
    if (hMapFile == 0) {
        Print("Failed to create shared memory, error: ", GetLastError());
        return -1;
    }
    Print("Shared memory created successfully: ", name);
    return hMapFile;
}

int AttachSharedMemory(string name, int size) {
    int FILE_MAP_ALL_ACCESS = 0x000F001F;
    int hMapFile = OpenFileMappingA(FILE_MAP_ALL_ACCESS, false, name);
    if (hMapFile == 0) {
        Print("Failed to open shared memory, error: ", GetLastError());
        return -1;
    }
    int lpBaseAddress = MapViewOfFile(
        hMapFile,
        FILE_MAP_ALL_ACCESS,
        0, 0, size
    );
    if (lpBaseAddress == 0) {
        Print("Failed to map view of file, error: ", GetLastError());
        CloseHandle(hMapFile);
        return -1;
    }
    Print("Shared memory attached successfully");
    return lpBaseAddress;
}

void WriteToSharedMemory(int lpBaseAddress, string data) {
    uchar buffer[];
    StringToCharArray(data, buffer);
    int bytesWritten = 0;
    if (!WriteProcessMemory(0xFFFFFFFF, lpBaseAddress, buffer, ArraySize(buffer), bytesWritten)) {
        Print("Failed to write to shared memory, error: ", GetLastError());
    }
}


string ReadFromSharedMemory(int lpBaseAddress, int size) {
    uchar buffer[];
    ArrayResize(buffer, size);
    int bytesRead = 0;
    if (!ReadProcessMemory(0xFFFFFFFF, lpBaseAddress, buffer, size, bytesRead)) {
        Print("Failed to read from shared memory, error: ", GetLastError());
        return "";
    }
    string data = CharArrayToString(buffer);
    return data;
}


void DetachSharedMemory(int lpBaseAddress, int hMapFile) {
    UnmapViewOfFile(lpBaseAddress);
    CloseHandle(hMapFile);
    Print("Shared memory detached and closed");
}
