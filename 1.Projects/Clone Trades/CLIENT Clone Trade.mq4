//+------------------------------------------------------------------+
//|                   Clone Trade for Price Action Trader CLIENT.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property strict
#include "CommonCloneTrade.mqh"

int OnInit()
{
//--- create timer
    if (ipcInit() == false) return INIT_FAILED;
    EventSetTimer(1);
    gOldData = "";
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
    if (reason <= REASON_RECOMPILE || reason == REASON_PARAMETERS){
        ipcDeinit();
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
//
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---
    string newData = "";
    newData = getMsg();
    if (gOldData == newData) return;
    if (newData == "-1") return;
    Print("newData:", newData);
    string newDataBak = newData;

    string orgTradeId = "";
    string tradeData = "";
    int startIdx = 0;
    int endIdx  = 0;

    string dataItems[];
    double priceEN = 0;
    double priceSL = 0;
    double priceTP = 0;

    int orderType = 0;
    int clientOrderType = 0;
    for (int i = OrdersTotal() - 1; i >=0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) == false) continue;
        orgTradeId = OrderComment();
        startIdx = StringFind(newData, orgTradeId);
        clientOrderType = OrderType();
        if (startIdx == -1) { // Trade has not exited in Host anymore!
            if (clientOrderType == OP_BUYLIMIT || clientOrderType == OP_SELLLIMIT){
                OrderDelete(OrderTicket());
            }
            continue;
        }

        endIdx = StringFind(newData, ";", startIdx);
        tradeData = StringSubstr(newData, startIdx, endIdx - startIdx+1);

        // Looking for different in price
        StringSplit(tradeData,',', dataItems);
        priceEN = StrToDouble(dataItems[3]);
        priceSL = StrToDouble(dataItems[4]);
        priceTP = StrToDouble(dataItems[5]);

        orderType = getOrderType(dataItems[2]);
        adjustSetup(orderType, priceEN, priceSL, priceTP);

        if((MathAbs(priceSL - OrderStopLoss()  ) > 0.0000001)
        || (MathAbs(priceTP - OrderTakeProfit()) > 0.0000001)){
            if (orderType != clientOrderType) {
                // Trường hợp trade đã active tại Host và BE. Nhưng Client chưa active được lệnh
                if (orderType == OP_BUY && priceSL >= priceEN) OrderDelete(OrderTicket());
                if (orderType == OP_SELL && priceSL <= priceEN) OrderDelete(OrderTicket());
                continue;
            }
            updateTrade(dataItems[1], dataItems[0] ,OrderOpenPrice(), priceSL, priceTP);
        }
        else {
            Print("Trade: ", tradeData, " NO CHANGE");
        }

        // Remove tradeData đã duyệt
        StringReplace(newData, tradeData, "");
    }
    gOldData = newDataBak;
    if (newData == "") return;

    string newTradeItems[];
    int k = StringSplit(newData,';', newTradeItems);

    for (int i = 0; i < k; i++){
        if (StringFind(newTradeItems[i], "LIMIT") == -1) continue;
        if (StringFind(newTradeItems[i], "BUY")   != -1) orderType = OP_BUYLIMIT;
        else orderType = OP_SELLLIMIT;
        // create trade
        StringSplit(newTradeItems[i],',', dataItems);
        priceEN = StrToDouble(dataItems[3]);
        priceSL = StrToDouble(dataItems[4]);
        priceTP = StrToDouble(dataItems[5]);
        adjustSetup(orderType, priceEN, priceSL, priceTP);

        goLive(dataItems[1], dataItems[0] ,priceEN, priceSL, priceTP);
        return;
    }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---
}
//+------------------------------------------------------------------+


bool updateTrade(string pair, string orgId, double priceEN, double priceSL, double priceTP) 
{
    priceTP = NormalizeDouble(priceTP, 5);
    priceEN = NormalizeDouble(priceEN, 5);
    priceSL = NormalizeDouble(priceSL, 5);
    bool ret = OrderModify(OrderTicket(), priceEN, priceSL, priceTP, 0);
    if (ret == false) {
        Print("OrderModify ticket: ", OrderTicket(), " failed with error: ",GetLastError());
    }
    return ret;
}

void goLive(string pair, string orgId, double priceEN, double priceSL, double priceTP)
{
    double point        = floor(fabs(priceEN-priceSL) * Trd_ContractSize);
    double tradeSize    = NormalizeDouble(floor(InpCost / (point+InpCom) * 100)/100, 2);
    priceTP = NormalizeDouble(priceTP, 5);
    priceEN = NormalizeDouble(priceEN, 5);
    priceSL = NormalizeDouble(priceSL, 5);

    int Cmd = ((priceTP > priceEN) ? OP_BUYLIMIT : OP_SELLLIMIT);

    int Slippage = 200;
    int OrderNumber=OrderSend(pair,Cmd,tradeSize,priceEN,Slippage,priceSL,priceTP, orgId);
    if (OrderNumber <= 0) {
        Print("OrderSend failed with error: ",GetLastError());
        return;
    }
}
