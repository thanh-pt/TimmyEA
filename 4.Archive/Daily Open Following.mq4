#property strict

double inpStep = 1000; // Step (pt):
double inpTarget = 200; // Target (pt):

double gdLotSize = MarketInfo(Symbol(), MODE_LOTSIZE);

MqlDateTime gdtStruct;
string gCurDay = "";
string gPreDay = "";
bool bEod = true;
int gWinCount = 0;

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

int gTkL1 = 0;
int gTkL2 = 0;
int gTkL3 = 0;
int gTkL4 = 0;

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
}
void OnTick() {
    gCurDay = TimeToString(iTime(_Symbol, PERIOD_D1, 0), TIME_DATE);
    if (gCurDay != gPreDay) {
        TimeToStruct(iTime(_Symbol, PERIOD_D1, 0), gdtStruct);
        if (gdtStruct.day_of_week == 0) return;
        string objName = gPreDay + "_Report";
        ObjectCreate(objName, OBJ_TEXT, 0, 0, 0);
        // Default
        ObjectSet(objName, OBJPROP_HIDDEN, true);
        ObjectSet(objName, OBJPROP_BACK, false);
        ObjectSet(objName, OBJPROP_SELECTABLE, false);
        ObjectSetString(0, objName, OBJPROP_TOOLTIP, "\n");
        // Basic
        ObjectSet(objName, OBJPROP_TIME1, iTime(_Symbol, PERIOD_D1, 1));
        ObjectSet(objName, OBJPROP_PRICE1, iHigh(_Symbol, PERIOD_D1, 1));
        ObjectSet(objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
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
            gTkL1 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL1 = Ask;
            gPriceL2 = gPriceL1 - inpStep/gdLotSize;
            gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
            Print("L0 -> L1: ", gPriceL1);
        }
    }
    else if (gState == eL1) {
        // Chốt lời đánh tiếp diễn
        if (Bid >= gPriceExpected) {
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            gWinCount++;
            if (gWinCount == 2) {
                bEod = true;
                gWinCount = 0;
            }
            else {
                gState = eL1;
                gTkL1 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
                gPriceL1 = Ask;
                gPriceL2 = gPriceL1 - inpStep/gdLotSize;
                gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
            }
            Print("L1 -> L1: ", gPriceL1);
        }
        else if (Bid <= gPriceL2) {
            gState = eL2;
            gTkL2 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL2 = Ask;
            gPriceL3 = gPriceL2 - inpStep/gdLotSize;
            gPriceExpected = gPriceL2 + 3*inpStep/gdLotSize;
            Print("L1 -> L2: ", gPriceL2);
        }
    }
    else if (gState == eL2) {
        // Chốt lãi - Duy trì L1
        if (Bid >= gPriceExpected) {
            OrderSelect(gTkL2, SELECT_BY_TICKET);
            OrderClose(gTkL2, OrderLots(), Bid, 10, clrNONE);
            gWinCount++;
            if (gWinCount == 2) {
                bEod = true;
                gWinCount = 0;
                OrderSelect(gTkL1, SELECT_BY_TICKET);
                OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            }
            else {
                gState = eL1;
                gPriceExpected = gPriceL1 + 3*inpStep/gdLotSize;
                Print("L2 -> L1: ", gPriceL1);
            }
        }
        else if (Bid <= gPriceL3) {
            gTkL3 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL3 = Ask;
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
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            OrderSelect(gTkL2, SELECT_BY_TICKET);
            OrderClose(gTkL2, OrderLots(), Bid, 10, clrNONE);
            OrderSelect(gTkL3, SELECT_BY_TICKET);
            OrderClose(gTkL3, OrderLots(), Bid, 10, clrNONE);
            gState == eNoOrder;
            bEod = true;
            Print("Cau hoa thanh cong!");
        }
    }
}