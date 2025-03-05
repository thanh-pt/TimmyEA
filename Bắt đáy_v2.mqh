/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/
#include "IMtHandler.mqh"
#define APP_TAG "EA_Bắt đáy_V2"

#define MAX_STEP 20

double gLowerSteps[MAX_STEP];
double gUpperSteps[MAX_STEP];
double gSize[MAX_STEP];
ulong  gTickets[MAX_STEP];

int gDefenseGate = 3;
double heso = 1.7;
void initValue() {
    gLowerSteps[ 0] = 7; gUpperSteps[ 0] =  5;
    gLowerSteps[ 1] = 7; gUpperSteps[ 1] =  5;
    gLowerSteps[ 2] = 3; gUpperSteps[ 2] =  5;
    gLowerSteps[ 3] = 3; gUpperSteps[ 3] =  5;
    gLowerSteps[ 4] = 3; gUpperSteps[ 4] =  5;
    gLowerSteps[ 5] = 3; gUpperSteps[ 5] =  5;
    gLowerSteps[ 6] = 3; gUpperSteps[ 6] =  5;
    gLowerSteps[ 7] = 3; gUpperSteps[ 7] =  5;
    gLowerSteps[ 8] = 3; gUpperSteps[ 8] =  5;
    gLowerSteps[ 9] = 3; gUpperSteps[ 9] =  5;
    gLowerSteps[10] = 3; gUpperSteps[10] =  5;
    gLowerSteps[11] = 3; gUpperSteps[11] =  5;
    gLowerSteps[12] = 3; gUpperSteps[12] =  5;
    gLowerSteps[13] = 3; gUpperSteps[13] =  5;
    gLowerSteps[14] = 3; gUpperSteps[14] =  5;
    gLowerSteps[15] = 3; gUpperSteps[15] =  5;
    gLowerSteps[16] = 3; gUpperSteps[16] =  5;
    gLowerSteps[17] = 3; gUpperSteps[17] =  5;
    gLowerSteps[18] = 3; gUpperSteps[18] =  5;
    gLowerSteps[19] = 3; gUpperSteps[19] =  5;
    gSize[ 0] = 0.01;
    gSize[ 1] = 0.02;
    gSize[ 2] = heso * calculateSize( 2);
    gSize[ 3] = heso * calculateSize( 3);
    gSize[ 4] = heso * calculateSize( 4);
    gSize[ 5] = heso * calculateSize( 5);
    gSize[ 6] = heso * calculateSize( 6);
    gSize[ 7] = heso * calculateSize( 7);
    gSize[ 8] = heso * calculateSize( 8);
    gSize[ 9] = heso * calculateSize( 9);
    gSize[10] = heso * calculateSize(10);
    gSize[11] = heso * calculateSize(11);
    gSize[12] = heso * calculateSize(12);
    gSize[13] = heso * calculateSize(13);
    gSize[14] = heso * calculateSize(14);
    gSize[15] = heso * calculateSize(15);
    gSize[16] = heso * calculateSize(16);
    gSize[17] = heso * calculateSize(17);
    gSize[18] = heso * calculateSize(18);
    gSize[19] = heso * calculateSize(19);
    
    gSize[ 0] = NormalizeDouble(gSize[ 0], 2);
    gSize[ 1] = NormalizeDouble(gSize[ 1], 2);
    gSize[ 2] = NormalizeDouble(gSize[ 2], 2);
    gSize[ 3] = NormalizeDouble(gSize[ 3], 2);
    gSize[ 4] = NormalizeDouble(gSize[ 4], 2);
    gSize[ 5] = NormalizeDouble(gSize[ 5], 2);
    gSize[ 6] = NormalizeDouble(gSize[ 6], 2);
    gSize[ 7] = NormalizeDouble(gSize[ 7], 2);
    gSize[ 8] = NormalizeDouble(gSize[ 8], 2);
    gSize[ 9] = NormalizeDouble(gSize[ 9], 2);
    gSize[10] = NormalizeDouble(gSize[10], 2);
    gSize[11] = NormalizeDouble(gSize[11], 2);
    gSize[12] = NormalizeDouble(gSize[12], 2);
    gSize[13] = NormalizeDouble(gSize[13], 2);
    gSize[14] = NormalizeDouble(gSize[14], 2);
    gSize[15] = NormalizeDouble(gSize[15], 2);
    gSize[16] = NormalizeDouble(gSize[16], 2);
    gSize[17] = NormalizeDouble(gSize[17], 2);
    gSize[18] = NormalizeDouble(gSize[18], 2);
    gSize[19] = NormalizeDouble(gSize[19], 2);
}


double calculateSize(int n) {
    double total = 0;
    double suffix_sum = 0;
    double S_sum = 0;

    for (int i = 1; i < n; i++) {
        suffix_sum += gLowerSteps[i];
    }

    for (int i = 0; i < n - 1; i++) {
        total += gSize[i] * suffix_sum;
        suffix_sum -= gLowerSteps[i + 1];
        S_sum += gSize[i];
    }
    total -= gUpperSteps[n] * S_sum;

    return total/gUpperSteps[n];
}


class MtHandler: public IMtHandler
{
public:
    virtual void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    virtual void OnTick();
    virtual int OnInit();
};


int MtHandler::OnInit() {
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    
    initValue();
    return INIT_SUCCEEDED;
}
void MtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
}

int gCurStep = 0;
double gUpperPrice;
double gLowerPrice;
double gDailyOpen;
double gPreHi;
double gPreLo;
MqlDateTime gStCurDt;
datetime    gCurDt;
string      gStrCurTime, gStrPreTime;
void MtHandler::OnTick() {
    Print("VAO!");
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    TimeToStruct(gCurDt, gStCurDt);

    // Exclude sunday
    if (gStCurDt.day_of_week == 0) return;
    // Cannot open trade in 22 EST hour
    if (gStCurDt.hour == 22) return;

    gStrCurTime = TimeToString(gCurDt, TIME_DATE);
    if (gStrCurTime != gStrPreTime) {
        // New day handle
        gDailyOpen = iOpen(_Symbol, PERIOD_D1, 0);
        // Idea: Ve 50% - Quet Previous Low
        // gPreHi     = iHigh(_Symbol, PERIOD_D1, 1);
        // gPreLo     = iLow(_Symbol, PERIOD_D1, 1);
        gStrPreTime = gStrCurTime;
        if (gCurStep == 0) {
            gUpperPrice = gDailyOpen + gUpperSteps[gCurStep];
            gLowerPrice = gDailyOpen - gLowerSteps[gCurStep];
        }
    }

    if (PAL::Bid() >= gUpperPrice) {
        Print("Reach gUpperPrice:", gUpperPrice, " Step:", gCurStep);
        if (gCurStep >= gDefenseGate) {
            Print("Try to remove all trade -> Cau hoa");
            for (int i = 0; i < gCurStep; i++) {
                Print("Close ticket:", gTickets[i]);
                PAL::PositionClose(gTickets[i]);
            }
            gCurStep = 0;
        }
        else if (gCurStep > 0){
            Print("Close Last Trade Upper Step");
            PAL::PositionClose(gTickets[gCurStep-1]);
            gUpperPrice = (PAL::Ask() - gUpperSteps[gCurStep] + gLowerSteps[gCurStep]) + gUpperSteps[gCurStep-1];
            gLowerPrice = (PAL::Bid() - gUpperSteps[gCurStep] + gLowerSteps[gCurStep]) + gLowerSteps[gCurStep-1];
            gCurStep--;
            if (gCurStep != 0) return;
        }
        // Open new L1
        if (gStCurDt.hour >= 19) {
            return;
        }
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice = PAL::Bid() - gLowerSteps[gCurStep];
        gCurStep++;
    }
    else if (PAL::Bid() <= gLowerPrice){
        if (gStCurDt.hour >= 19 && gCurStep == 0) {
            return;
        }
        Print("Reach gLowerPrice:", gLowerPrice, " Step:", gCurStep);
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice = PAL::Bid() - gLowerSteps[gCurStep];
        gCurStep++;
    }
}



/// @brief Apprearence and Action
void createLabel(string objName, string text, int posX, int posY)
{
    ObjectCreate(0,     objName, OBJ_LABEL, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLightGray);
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objName, OBJPROP_BACK, false);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TEXT, text);
    ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, posX);
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, posY);
}