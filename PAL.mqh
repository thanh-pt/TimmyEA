class PAL
{
    static ulong lastOrderResult;
public:
    static bool PositionClose(ulong ticket);
    static ulong ResultOrder();
    static bool Buy(double size, string symbol = NULL, double slippage = 0, double tp=0, double sl=0, string cmt = NULL);
    static bool Sell(double size, string symbol = NULL, double slippage = 0, double tp=0, double sl=0, string cmt = NULL);
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

bool PAL::Buy(double size, string symbol, double slippage, double tp, double sl, string cmt) {
    gCTrade.Buy(size, symbol, slippage, tp, sl, cmt);
    return false;
}

bool PAL::Sell(double size, string symbol, double slippage, double tp, double sl, string cmt) {
    gCTrade.Sell(size, symbol, slippage, tp, sl, cmt);
    return false;
}

double PAL::Ask() {
    return SymbolInfoDouble(_Symbol,SYMBOL_ASK);
}

double PAL::Bid() {
    return SymbolInfoDouble(_Symbol,SYMBOL_BID);
}