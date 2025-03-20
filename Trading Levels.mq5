//+------------------------------------------------------------------+
//|                                               Trading Levels.mq5 |
//|                                                            Timmy |
//|                           https://www.mql5.com/en/users/thanh01/ |
//+------------------------------------------------------------------+
#property copyright "Timmy"
#property link      "https://www.mql5.com/en/users/thanh01/"
#property version   "1.00"
#property indicator_chart_window
#define APP_TAG "*TradeLevel"

enum eLevelType {
    eBUY  = POSITION_TYPE_BUY,
    eSELL = POSITION_TYPE_SELL,
    eBOTH,
};

input eLevelType InpLevelType = eBUY;
input bool       InpOverload = false;

bool gIsShowTradeLevel = false;
bool gIsOverLoad = false;
int gPnlFactor = (InpLevelType == eBUY ? 1:-1);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    gIsShowTradeLevel = (bool) ChartGetInteger(0, CHART_SHOW_TRADE_LEVELS);
    if (gIsShowTradeLevel == false || InpOverload == true) {
        int levelCount = 0;
        gIsOverLoad = (gIsShowTradeLevel && InpOverload);
        gLevelIndex = 0;
        gDealIdx = 1;
        int type;
        for (int i = 0; i < PositionsTotal(); i++) {
            PositionSelectByTicket(PositionGetTicket(i));
            type = (int)PositionGetInteger(POSITION_TYPE);
            if (InpLevelType == eBOTH || type == InpLevelType) {
                drawDeal(PositionGetDouble(POSITION_PRICE_OPEN),
                        PositionGetDouble(POSITION_TP),
                        PositionGetDouble(POSITION_SL),
                        PositionGetDouble(POSITION_VOLUME),
                        type);
                levelCount++;
            } 
        }
        for (int i = 0; i < OrdersTotal(); i++) {
            OrderSelect(OrderGetTicket(i));
            type = (int)OrderGetInteger(ORDER_TYPE);
            if (InpLevelType == eBOTH || type == InpLevelType+2 || type == InpLevelType+4) {
                drawDeal(OrderGetDouble(ORDER_PRICE_OPEN),
                        OrderGetDouble(ORDER_TP),
                        OrderGetDouble(ORDER_SL),
                        OrderGetDouble(ORDER_VOLUME_CURRENT),
                        type);
                levelCount++;
            }
        }
        hideTradeLevel();
        if (levelCount > 0) ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, 1);
        else ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, 0);
    }
    else {
        gLevelIndex = 0;
        ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR, 0);
        hideTradeLevel();
    }
    return(rates_total);
}
//+------------------------------------------------------------------+

int gDealIdx;
void drawDeal(double priceOpen, double priceTP, double priceSL, double vol, int type)
{
    string text;
    if (gIsOverLoad) {
        switch (type) {
            case ORDER_TYPE_BUY       : text += "                                           "; break;
            case ORDER_TYPE_SELL      : text += "                                           "; break;
            case ORDER_TYPE_BUY_LIMIT : text += "                                           "; break;
            case ORDER_TYPE_SELL_LIMIT: text += "                                           "; break;
            case ORDER_TYPE_BUY_STOP  : text += "                                           "; break;
            case ORDER_TYPE_SELL_STOP : text += "                                           "; break;
        }
        text += "#" + IntegerToString(gDealIdx);
        drawTradeLevel(priceOpen, text, clrNONE);
        if (priceTP != 0) {
            text = "      #" + IntegerToString(gDealIdx) + ", "+ DoubleToString(gPnlFactor*(priceTP-priceOpen)*vol*100,2)+"$";
            drawTradeLevel(priceTP, text, clrNONE);
        }
        if (priceSL != 0) {
            text = "      #" + IntegerToString(gDealIdx) + ", "+ DoubleToString(gPnlFactor*(priceSL-priceOpen)*vol*100,2) +"$";
            drawTradeLevel(priceSL, text, clrNONE);
        }
    }
    else {
        text = "#" + IntegerToString(gDealIdx);
        switch (type) {
            case ORDER_TYPE_BUY       : text += " BUY ";        break;
            case ORDER_TYPE_SELL      : text += " SELL ";       break;
            case ORDER_TYPE_BUY_LIMIT : text += " BUY LM ";      break;
            case ORDER_TYPE_SELL_LIMIT: text += " SELL LM ";     break;
            case ORDER_TYPE_BUY_STOP  : text += " BUY STOP ";    break;
            case ORDER_TYPE_SELL_STOP : text += " SELL STOP ";   break;
        }
        text += DoubleToString(vol,2) + " at " + DoubleToString(priceOpen, _Digits);
        drawTradeLevel(priceOpen, text, clrGreen);
        if (priceTP != 0) {
            text = "TP#" + IntegerToString(gDealIdx) + ", "+ DoubleToString(gPnlFactor*(priceTP-priceOpen)*vol*100,2)+"$";
            drawTradeLevel(priceTP, text, clrRed);
        }
        if (priceSL != 0) {
            text = "SL#" + IntegerToString(gDealIdx) + ", "+ DoubleToString(gPnlFactor*(priceSL-priceOpen)*vol*100,2) +"$";
            drawTradeLevel(priceSL, text, clrRed);
        }
    }
    gDealIdx++;
}

int gLevelIndex = 0;
void drawTradeLevel(double price, string text, color clr) {
    string objName = APP_TAG + IntegerToString(gLevelIndex++);
    ObjectCreate(0,     objName, OBJ_HLINE, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASHDOT);
    ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
    ObjectSetString(0,  objName, OBJPROP_TEXT, text);
}

void hideTradeLevel()
{
    string objName;
    while (gLevelIndex < 100)
    {
        objName = APP_TAG + IntegerToString(gLevelIndex++);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, 0);
    }
}
