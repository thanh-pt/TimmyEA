#define PAL_GROUP(gr, grStr) input group grStr

class PAL
{
    static ulong lastOrderResult;
public:
    static bool PositionClose(ulong ticket);
    static ulong ResultOrder();
    static bool Buy(double size, double sl=0, double tp=0, string cmt = NULL, double slippage = 0, string symbol = NULL);
    static bool Sell(double size, double sl=0, double tp=0, string cmt = NULL, double slippage = 0, string symbol = NULL);
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

bool PAL::Buy(double size, double sl, double tp, string cmt, double slippage, string symbol) {
    return gCTrade.Buy(size, NULL, 0, sl, tp, cmt);
}

bool PAL::Sell(double size, double sl, double tp, string cmt, double slippage, string symbol) {
    return gCTrade.Sell(size, NULL, 0, sl, tp, cmt);
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
