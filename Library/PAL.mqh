#define _PAL_GROUP(gr, grStr) input group grStr

class PAL
{
    static ulong lastOrderResult;
public:
    static bool PositionClose(ulong ticket);
    static ulong ResultOrder();
    static bool Buy(double size, string symbol = NULL, double slippage = 0, double sl=0, double tp=0, string cmt = NULL);
    static bool Sell(double size, string symbol = NULL, double slippage = 0, double sl=0, double tp=0, string cmt = NULL);
    static bool  PositionModify(const ulong ticket,double sl,double tp);
    static double Ask();
    static double Bid();
};

ulong PAL::lastOrderResult = 0;
#include <Trade\Trade.mqh>
CTrade gCTrade;

bool PAL::PositionClose(ulong ticket) {
    return gCTrade.PositionClose(ticket);
}

ulong PAL::ResultOrder() {
    return gCTrade.ResultOrder();
}

bool PAL::Buy(double size, string symbol, double slippage, double sl, double tp, string cmt) {
    return gCTrade.Buy(size, symbol, slippage, sl, tp, cmt);
}

bool PAL::Sell(double size, string symbol, double slippage, double sl, double tp, string cmt) {
    return gCTrade.Sell(size, symbol, slippage, sl, tp, cmt);
}

double PAL::Ask() {
    return SymbolInfoDouble(_Symbol,SYMBOL_ASK);
}

double PAL::Bid() {
    return SymbolInfoDouble(_Symbol,SYMBOL_BID);
}

bool PAL::PositionModify(const ulong ticket, double sl, double tp) {
    return gCTrade.PositionModify(ticket, sl, tp);
}
