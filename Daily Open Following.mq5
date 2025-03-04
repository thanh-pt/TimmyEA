#property strict

double inpStep = 1000; // Step (pt):
double inpTarget = 200; // Target (pt):

double gdLotSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

MqlDateTime gdtStruct;
string gCurDay = "";
string gPreDay = "";
bool bEod = true;
int gWinCount = 0;
int gTradeCount = 0;

enum eStage {
    eNoOrder,
    eL1,
    eL2,
    eL3,
    eL4,
};

eStage gState;
double gOpenPrice = 0.0;
double gPriceL1 = 0.0;
double gPriceL2 = 0.0;
double gPriceL3 = 0.0;
double gPriceL4 = 0.0;

ulong gTkL1 = 0;
ulong gTkL2 = 0;
ulong gTkL3 = 0;
ulong gTkL4 = 0;

ulong gTkKet = 0;
double gPriceExpected = 0;


int OnInit()
{
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    gState = eNoOrder;
    return INIT_SUCCEEDED;
}
void OnDeinit(const int reason) {
    Print("gTradeCount: ", gTradeCount);
}

#include <Trade\Trade.mqh>
CTrade gCTrade;
double Bid, Ask;
void OnTick() {
    Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    TimeToStruct(iTime(_Symbol, PERIOD_H1, 0), gdtStruct);
    if (gTkKet != 0) {
        Print("Try to close : ", gTkKet);
        if (gCTrade.PositionClose(gTkKet)) gTkKet = 0;
    }
    if ((gdtStruct.hour < 2 && gdtStruct.day_of_week == 1) || (gdtStruct.hour >= 13 && gdtStruct.day_of_week == 5)) {
        if (gTkL1 != 0 && gCTrade.PositionClose(gTkL1)){
            gTkL1 = 0;
        }
        if (gTkL2 != 0 && gCTrade.PositionClose(gTkL2)){
            gTkL2 = 0;
        }
        if (gTkL3 != 0 && gCTrade.PositionClose(gTkL3)){
            gTkL3 = 0;
        }
        bEod = true;
        gState = eNoOrder;
        return;
    }
    gCurDay = TimeToString(iTime(_Symbol, PERIOD_D1, 0), TIME_DATE);
    if (gCurDay != gPreDay) {
        if (gdtStruct.day_of_week == 0) return;
        string objName = gPreDay + "_Report";
        ObjectCreate(0, objName, OBJ_TEXT, 0, 0, 0);
        // Default
        ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, objName, OBJPROP_BACK, false);
        ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
        // Basic
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, iTime(_Symbol, PERIOD_D1, 1));
        ObjectSetDouble(0, objName, OBJPROP_PRICE, 0, iHigh(_Symbol, PERIOD_D1, 1));
        ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetString(0, objName, OBJPROP_TEXT, "W:" + IntegerToString(gWinCount) + " - Stt:" + IntegerToString(gState));

        if (bEod == true || gState == eNoOrder) {
            gOpenPrice = iOpen(_Symbol, PERIOD_D1, 0);
            gPriceL1 = gOpenPrice + inpStep/gdLotSize;
            gState = eNoOrder;
            bEod = false;
            gWinCount = 0;
        }
        gPreDay = gCurDay;
        return;
    }
    if (bEod == true) return;

    if (gState == eNoOrder) {
        if (Bid >= gPriceL1) {
            gState = eL1;
            gCTrade.Buy(0.01, _Symbol, 0, 0, 0, IntegerToString(gTradeCount) + ".L1");
            gTradeCount++;
            gTkL1 = gCTrade.ResultOrder();
            // gPriceL1 = Ask;
            gPriceL2 = gPriceL1 - inpStep/gdLotSize;
            gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
            Print("L0 -> L1: ", gPriceL1);
        }
    }
    else if (gState == eL1) {
        // Chốt lời đánh tiếp diễn
        if (Bid >= gPriceExpected) {
            if (gCTrade.PositionClose(gTkL1) == false) gTkKet = gTkL1;
            gWinCount++;
            if (gWinCount == 2) {
                bEod = true;
                gWinCount = 0;
            }
            else {
                gState = eL1;
                gCTrade.Buy(0.01, _Symbol, 0, 0, 0, IntegerToString(gTradeCount) + ".L1");
                gTradeCount++;
                gTkL1 = gCTrade.ResultOrder();
                // gPriceL1 = Ask;
                gPriceL2 = gPriceL1 - inpStep/gdLotSize;
                gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
            }
            Print("L1 -> L1: ", gPriceL1);
        }
        else if (Bid <= gPriceL2) {
            gState = eL2;
            
            gCTrade.Buy(0.01, _Symbol, 0, 0, 0, IntegerToString(gTradeCount) + ".L2");
            gTradeCount++;
            gTkL2 = gCTrade.ResultOrder();
            // gPriceL2 = Ask;
            gPriceL3 = gPriceL2 - inpStep/gdLotSize;
            gPriceExpected = gPriceL2 + 3*inpStep/gdLotSize;
            Print("L1 -> L2: ", gPriceL2);
        }
    }
    else if (gState == eL2) {
        // Chốt lãi - Duy trì L1
        if (Bid >= gPriceExpected) {
            if (gCTrade.PositionClose(gTkL2) == false) gTkKet = gTkL2;
            gWinCount++;
            if (gWinCount >= 2) {
                bEod = true;
                gWinCount = 0;
                if (gCTrade.PositionClose(gTkL1) == false) gTkKet = gTkL1;
                gCTrade.PositionClose(gTkL1);
            }
            else {
                gState = eL1;
                gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
                Print("L2 -> L1: ", gPriceL1);
            }
        }
        else if (Bid <= gPriceL3) {
            
            gCTrade.Buy(0.01, _Symbol, 0, 0, 0, IntegerToString(gTradeCount) + ".L3");
            gTradeCount++;
            gTkL3 = gCTrade.ResultOrder();
            // gPriceL3 = Ask;
            gPriceL4 = gPriceL3 - inpStep/gdLotSize;
            gPriceExpected = gPriceL2; // Price cau hoa
            gState = eL3;
            Print("L2 -> L3: ", gPriceL3);
        }
    }
    else if (gState == eL3) {
        // Chốt hoà
        if (Bid >= gPriceExpected) {
            gState = eL1;
            if (gCTrade.PositionClose(gTkL1) == false) gTkKet = gTkL1;
            if (gCTrade.PositionClose(gTkL2) == false) gTkKet = gTkL2;
            if (gCTrade.PositionClose(gTkL3) == false) gTkKet = gTkL3;
            gState = eNoOrder;
            bEod = true;
            Print("Cau hoa thanh cong!");
        }
    }
}