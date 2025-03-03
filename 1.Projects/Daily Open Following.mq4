#property strict

double inpStep = 100; // Step (pt):
double inpTarget = 200; // Target (pt):

double gdLotSize = MarketInfo(Symbol(), MODE_LOTSIZE);

MqlDateTime gdtStruct;
string gCurDay = "";
string gPreDay = "";
bool bEod = true;

enum eStage {
    eWait,
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
    gState = eWait;
    return INIT_SUCCEEDED;
}
void OnDeinit(const int reason) {
}
void OnTick() {
    gCurDay = TimeToString(iTime(_Symbol, PERIOD_D1, 0), TIME_DATE);
    if (gCurDay != gPreDay) {
        TimeToStruct(iTime(_Symbol, PERIOD_D1, 0), gdtStruct);
        if (gdtStruct.day_of_week == 0) return;
        gPreDay = gCurDay;
        if (bEod == true || gState == eWait) {
            gOpenPrice = iOpen(_Symbol, PERIOD_D1, 0);
            gPriceL1 = gOpenPrice + inpStep/gdLotSize;
            gState = eWait;
            bEod = false;
        }
        return;
    }
    if (bEod == true) return;

    if (gState == eWait) {
        if (Bid >= gPriceL1) {
            gState = eL1;
            gTkL1 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL1 = Ask;
            gPriceL2 = gPriceL1 - inpStep/gdLotSize;
            gPriceExpected = gPriceL1 + 2*inpStep/gdLotSize;
            Print(gCurDay + " L1: ", gPriceL1 , " L2: ", gPriceL1, " Ep:", gPriceExpected);
        }
    }
    else if (gState == eL1) {
        if (Bid >= gPriceExpected) {
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            bEod = true;
            Print("EOD: 1");
        }
        else if (Bid <= gPriceL2) {
            gState = eL2;
            gTkL2 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL2 = Ask;
            gPriceL3 = gPriceL2 - inpStep/gdLotSize;
            gPriceExpected = gPriceL2 + 2*inpStep/gdLotSize;
            Print(gCurDay + " L2: ", gPriceL2 , " L3: ", gPriceL3, " Ep:", gPriceExpected);
        }
    }
    else if (gState == eL2) {
        if (Bid >= gPriceExpected) {
            bEod = true;
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            OrderSelect(gTkL2, SELECT_BY_TICKET);
            OrderClose(gTkL2, OrderLots(), Bid, 10, clrNONE);
            Print("EOD: 2");
        }
        else if (Bid <= gPriceL3) {
            gTkL3 = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 10, 0, 0, NULL, 0, 0, Blue);
            gPriceL3 = Ask;
            gPriceL4 = gPriceL3 - inpStep/gdLotSize;
            gPriceExpected = gPriceL2; // Price cau hoa
            gState = eL3;
            Print(gCurDay + " L3: ", gPriceL3 , " L4: ", gPriceL4, " Ep:", gPriceExpected);
        }
    }
    else if (gState == eL3) {
        if (Bid >= gPriceExpected) {
            gState = eL1;
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), Bid, 10, clrNONE);
            OrderSelect(gTkL3, SELECT_BY_TICKET);
            OrderClose(gTkL3, OrderLots(), Bid, 10, clrNONE);
            
            gTkL1 = gTkL2;
            gPriceL1 = gPriceL2;
            gPriceL2 = gPriceL1 - inpStep/gdLotSize;
            gPriceExpected = gPriceL1 + 2*inpStep/gdLotSize;
            Print(gCurDay + " L1.2: ", gPriceL1 , " L2: ", gPriceL1, " Ep:", gPriceExpected);
        }
        else if (Bid <= gPriceL4) {
            OrderSelect(gTkL1, SELECT_BY_TICKET);
            OrderClose(gTkL1, OrderLots(), gPriceL4, 10, clrNONE);
            OrderSelect(gTkL2, SELECT_BY_TICKET);
            OrderClose(gTkL2, OrderLots(), gPriceL4, 10, clrNONE);
            OrderSelect(gTkL3, SELECT_BY_TICKET);
            OrderClose(gTkL3, OrderLots(), gPriceL4, 10, clrNONE);
            bEod = true;
            Print("EOD: 3");
        }
    }
}