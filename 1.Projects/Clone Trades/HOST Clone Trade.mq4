//+------------------------------------------------------------------+
//|                     Clone Trade for Price Action Trader HOST.mq4 |
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
    ipcDeinit();
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
    int orderType = 0;
    string strOrderType = "";
    double priceEN = 0;
    double priceSL = 0;
    double priceTP = 0;
    double size    = 0;
    for (int i = 0 ; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS) == false) continue;
        orderType = OrderType();
        strOrderType = getOrderTypeStr(OrderType());
        if (strOrderType == "") continue;

        priceEN = OrderOpenPrice() ;
        priceSL = OrderStopLoss()  ;
        priceTP = OrderTakeProfit();
        
        if (priceSL == 0.0) {
            continue; // Tạm thời là continue...
            // Quy đổi Lot -> SL
            size = OrderLots();
            // if invalid SL -> continue (ex:SL < 5pip)
        }

        revertOrgSetup(orderType, priceEN, priceSL, priceTP);

        newData += IntegerToString(OrderTicket()) + ",";
        newData += OrderSymbol() + ",";
        newData += strOrderType + ",";

        newData += DoubleToString(priceEN, 5) + ",";
        newData += DoubleToString(priceSL, 5) + ",";
        newData += DoubleToString(priceTP, 5) + ",;";
    }
    if (gOldData != newData) {
        Print("newData: ", newData);
        sendMsg(newData);
        gOldData = newData;
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
