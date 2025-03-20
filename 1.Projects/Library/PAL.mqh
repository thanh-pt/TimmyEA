#define PAL_GROUP(gr, grStr) input string gr;// grStr

class PAL
{
    static ulong lastOrderResult;
public:
    static bool PositionClose(ulong ticket);
    static ulong ResultOrder();
    static bool Buy(double size, string symbol = NULL, double slippage = 0, double tp=0, double sl=0, string cmt = NULL);
    static bool Sell(double size, string symbol = NULL, double slippage = 0, double tp=0, double sl=0, string cmt = NULL);
    static bool  PositionModify(const ulong ticket,double sl,double tp);
    static double Ask();
    static double Bid();
};

ulong PAL::lastOrderResult = 0;


bool PAL::PositionClose(ulong ticket) {
    if (OrderSelect(ticket, SELECT_BY_TICKET) == false) return false;
    return OrderClose(ticket, OrderLots(), Bid, 10, clrNONE);
}

ulong PAL::ResultOrder() {
    return lastOrderResult;
}

bool PAL::Buy(double size, string symbol, double slippage, double tp, double sl, string cmt) {
    lastOrderResult = OrderSend(symbol, OP_BUY, size, Ask, slippage, tp, sl, cmt, 0, 0, Blue);
    return false;
}

bool PAL::Sell(double size, string symbol, double slippage, double tp, double sl, string cmt) {
    lastOrderResult = OrderSend(symbol, OP_SELL, size, Bid, slippage, tp, sl, cmt, 0, 0, Blue);
    return false;
}

bool PAL::PositionModify(const ulong ticket, double sl, double tp) {
    if (OrderSelect(ticket, SELECT_BY_TICKET) == false) return false;
    return OrderModify(ticket, OrderOpenPrice(), sl, tp, 0, Blue);
}

double PAL::Ask() {
    return Ask;
}

double PAL::Bid() {
    return Bid;
}
