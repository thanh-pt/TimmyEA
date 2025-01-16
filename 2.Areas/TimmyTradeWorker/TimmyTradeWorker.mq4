#include "TradeWorker.mqh"

#property strict

TradeWorker tradeWorker;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    tradeWorker.reqManageTrade();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_KEYDOWN && lparam == '5') tradeWorker.reqGoLive();
    // if (id == CHARTEVENT_KEYDOWN && lparam == '2') tradeWorker.reqAddSLTP();
}
//+------------------------------------------------------------------+
