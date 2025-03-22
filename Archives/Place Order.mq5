//+------------------------------------------------------------------+
//|                                                   PlaceOrder.mq5 |
//|                                                            Timmy |
//|                            https://www.mql5.com/en/users/thanh01 |
//+------------------------------------------------------------------+
#property copyright "Timmy"
#property link      "https://www.mql5.com/en/users/thanh01"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade  gCTrade;

double  size = 0.01;
double  quangGia = 3;
int     soLuong = 10;

void OnStart()
{
    double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
    double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    double spread = ask-bid;

    gCTrade.Buy(size, NULL, 0, 0, ask+quangGia, "Buy0");
    gCTrade.Sell(size, NULL, 0, 0, bid-quangGia, "Sell0");
    for (int i = 1; i <= soLuong; i++){
        gCTrade.BuyStop(size, ask+(quangGia+spread)*i, NULL, 0, ask+(quangGia+spread)*i+quangGia,0, 0, "Buy"+IntegerToString(i));
        gCTrade.SellStop(size, bid-(quangGia+spread)*i, NULL, 0, bid-(quangGia+spread)*i-quangGia,0, 0, "Sell"+IntegerToString(i));
    }
}
//+------------------------------------------------------------------+
