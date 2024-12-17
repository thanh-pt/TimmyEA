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
        if (orderType == OP_BUY && priceSL >= priceEN) priceSL = OrderOpenPrice() + InpCom/Trd_ContractSize;
        priceEN += InpSpread/Trd_ContractSize;
    }
    else if (orderType == OP_SELLLIMIT || orderType == OP_SELL){
        if (orderType == OP_SELL && priceSL <= priceEN) priceSL = OrderOpenPrice() - InpCom/Trd_ContractSize;
        else {
            priceSL += InpSpread/Trd_ContractSize;
        }
        if (priceTP != 0.0) priceTP += InpSpread/Trd_ContractSize;
    }
}

string getOrderTypeStr(int orderType)
{
    switch (orderType)
    {
    case OP_BUYLIMIT:   return "BUYLIMIT";
    case OP_SELLLIMIT:  return "SELLLIMIT";
    case OP_BUY:        return "BUYED";
    case OP_SELL:       return "SELLED";
    }
    return "";
}

int getOrderType(string orderTypeStr)
{

    if (orderTypeStr == "BUYLIMIT" ) return OP_BUYLIMIT ;
    if (orderTypeStr == "SELLLIMIT") return OP_SELLLIMIT;
    if (orderTypeStr == "BUYED"    ) return OP_BUY      ;
    if (orderTypeStr == "SELLED"   ) return OP_SELL     ;
    return -1;
}
