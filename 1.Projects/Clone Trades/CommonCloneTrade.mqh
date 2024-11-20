#include "IPCWrapper.mqh"

string gOldData = "";

input double InpCost    = 1.5;  // Risk ($)
input double InpCom     = 7;    // Comission/lot ($)
input double InpSpread  = 0;    // Spread (point)
input double InpSlSpace = 1;    // Space for SL (point)
input int    Trd_ContractSize = 100000;  // Contract Size


void revertOrgSetup(int orderType, double& priceEN, double& priceSL, double& priceTP) {
    if (orderType == OP_BUYLIMIT || orderType == OP_BUY){
        priceEN -= InpSpread/Trd_ContractSize;
        if (orderType == OP_BUY && priceSL > priceEN) { // Lệnh này đã khớp và được set BE
            priceSL -= InpCom/Trd_ContractSize;
        }
    }
    else if (orderType == OP_SELLLIMIT || orderType == OP_SELL){
        if (priceTP != 0.0) priceTP -= InpSpread/Trd_ContractSize;
        priceSL -= InpSpread/Trd_ContractSize;
        if (orderType == OP_SELL && priceSL < priceEN) { // Lệnh này đã khớp và được set BE
            priceSL += InpCom/Trd_ContractSize;
        }
    }
}

void adjustSetup(int orderType, double& priceEN, double& priceSL, double& priceTP) {
    if (orderType == OP_BUYLIMIT || orderType == OP_BUY){
        priceEN += InpSpread/Trd_ContractSize;
        if (orderType == OP_BUY && priceSL > priceEN) { // Lệnh này đã khớp và được set BE
            priceSL += InpCom/Trd_ContractSize;
        }
    }
    else if (orderType == OP_SELLLIMIT || orderType == OP_SELL){
        if (priceTP != 0.0) priceTP += InpSpread/Trd_ContractSize;
        priceSL += InpSpread/Trd_ContractSize;
        if (orderType == OP_SELL && priceSL < priceEN) { // Lệnh này đã khớp và được set BE
            priceSL -= InpCom/Trd_ContractSize;
        }
    }
}
