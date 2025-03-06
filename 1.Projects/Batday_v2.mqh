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
double gLowerPrice[MAX_STEP];
double gUpperPrice[MAX_STEP];
double gTotalLoss[MAX_STEP];

int gDefenseGate = 3;
double inpHeso = 1.0;
void initValue() {
    gLowerSteps[ 0] = 0.5; gUpperSteps[ 0] =   1;
    gLowerSteps[ 1] = 0.5; gUpperSteps[ 1] =   1;
    gLowerSteps[ 2] = 0.5; gUpperSteps[ 2] =   1;
    gLowerSteps[ 3] = 0.5; gUpperSteps[ 3] =   1;
    gLowerSteps[ 4] = 0.5; gUpperSteps[ 4] =   1;
    gLowerSteps[ 5] = 0.5; gUpperSteps[ 5] =   1;
    gLowerSteps[ 6] = 0.5; gUpperSteps[ 6] =   1;
    gLowerSteps[ 7] = 0.5; gUpperSteps[ 7] =   1;
    gLowerSteps[ 8] = 0.5; gUpperSteps[ 8] =   1;
    gLowerSteps[ 9] = 0.5; gUpperSteps[ 9] =   1;
    gLowerSteps[10] = 0.5; gUpperSteps[10] =   1;
    gLowerSteps[11] = 0.5; gUpperSteps[11] =   1;
    gLowerSteps[12] = 0.7; gUpperSteps[12] = 1.2;
    gLowerSteps[13] =   1; gUpperSteps[13] = 1.7;
    gLowerSteps[14] =   1; gUpperSteps[14] =   2;
    gLowerSteps[15] =   2; gUpperSteps[15] =   3;
    gLowerSteps[16] =   2; gUpperSteps[16] =   4;
    gLowerSteps[17] =   3; gUpperSteps[17] =   6;
    gLowerSteps[18] =   6; gUpperSteps[18] = 10.2;
    gLowerSteps[19] =  12; gUpperSteps[19] =  20;
    gSize[ 0] = 0.01;
    gSize[ 1] = 0.02;
    int i;
    for (i = 2; i < MAX_STEP; i++) {
        gSize[i] = inpHeso * calculateSize(i);
    }
    for (i = 0; i < MAX_STEP; i++) {
        gSize[i] = NormalizeDouble(gSize[i], 2);
    }
}


double calculateSize(int n) {
    double outputSize = 0;
    double total = 0;
    double suffix_sum = 0;
    double S_sum = 0;
    int i;

    for (i = 0; i <= n; i++) {
        suffix_sum += gLowerSteps[i];
    }

    for (i = 0; i < n; i++) {
        total += gSize[i] * suffix_sum;
        suffix_sum -= gLowerSteps[i];
        S_sum += gSize[i];
    }
    Print("Loss in ", n, " is:", total);
    gTotalLoss[n] = total;
    total -= gUpperSteps[n] * S_sum;
    
    return MathCeil(total/gUpperSteps[n] * 100)/100;
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

    printValueTable();
    return INIT_SUCCEEDED;
}
void MtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if (id == CHARTEVENT_OBJECT_CHANGE) {
        changeValueHandler(sparam);
    }
}

int gCurStep = -1;
double gDailyOpen;
double gPreHi;
double gPreLo;
MqlDateTime gStCurDt;
datetime    gCurDt;
string      gStrCurTime, gStrPreTime;
void MtHandler::OnTick() {
    //return;
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
        if (gCurStep == -1) {
            gCurStep++;
            PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
            gTickets[gCurStep] = PAL::ResultOrder();
            gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
            gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
            noteStep(gCurStep, Time[0], PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
        }
    }

    if (PAL::Bid() >= gUpperPrice[gCurStep]) {
        Print("Reach gUpperPrice[", gCurStep, "] = ", gUpperPrice[gCurStep]);
        if (gCurStep >= gDefenseGate) {
            Print("Reach gDefenseGate:", gDefenseGate);
            for (int i = 0; i <= gCurStep; i++) {
                Print("Close ticket:", gTickets[i]);
                PAL::PositionClose(gTickets[i]);
                hideStep(i);
            }
            gCurStep = -1;
        }
        else {
            Print("Close Last Trade Upper Step");
            PAL::PositionClose(gTickets[gCurStep]);
            hideStep(gCurStep);
            gCurStep--;
        }
        // Open new L1
        // if (gStCurDt.hour >= 19) {
        //     return;
        // }
        if (gCurStep >= 0) return;
        gCurStep++;
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        noteStep(gCurStep, Time[0], PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
    }
    else if (PAL::Bid() <= gLowerPrice[gCurStep]){
        // if (gStCurDt.hour >= 19 && gCurStep == 0) {
        //     return;
        // }
        Print("Reach gLowerPrice[", gCurStep, "] = ", gLowerPrice[gCurStep]);
        
        gCurStep++;
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        noteStep(gCurStep, Time[0], PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
        // TODO: Hide Lower Price...?
        // hideStep(gCurStep);
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

string fixedText(string str, int size) {
    int spaceSize = size - StringLen(str);
    if (spaceSize <= 0) return str;
    return StringSubstr("                                  ", 0, spaceSize) + str;
}
string fixedText(double dvalue, int decimal, int size) {
    string str = DoubleToString(dvalue, decimal);
    int spaceSize = size - StringLen(str);
    if (spaceSize <= 0) return str;
    return StringSubstr("                    ", 0, spaceSize) + str;
}

void printValueTable()
{
    string objSnSize;
    string objLowerStep;
    string objUpperStep;
    string strSnSize;
    createLabel("objValueTableHeader", "STEP LOWER   UPPER    SIZE", 10, 15);
    for (int i = 0; i < MAX_STEP; i++){
        strSnSize = IntegerToString(i);
        objSnSize    = "objSnSize" + strSnSize;
        objLowerStep = "objLowerStep" + strSnSize;
        objUpperStep = "objUpperStep" + strSnSize;
        strSnSize = fixedText(strSnSize, 2) + fixedText(gSize[i], 2, 24);
        createLabel(objSnSize   , strSnSize                      , 10, 30 + 15*i);
        createLabel(objLowerStep, fixedText(gLowerSteps[i], 1, 5), 40, 30 + 15*i);
        createLabel(objUpperStep, fixedText(gUpperSteps[i], 1, 5),100, 30 + 15*i);
    }
}
void changeValueHandler(string sparam) {
    double value;
    if (StringFind(sparam, "objLowerStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objLowerStep", "");
        gLowerSteps[StringToInteger(sparam)] = value;
    }
    else if (StringFind(sparam, "objUpperStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objUpperStep", "");
        gUpperSteps[StringToInteger(sparam)] = value;
    }
    else {
        return;
    }
    int i;
    for (i = 2; i < MAX_STEP; i++) {
        gSize[i] = inpHeso * calculateSize(i);
    }
    for (i = 0; i < MAX_STEP; i++) {
        gSize[i] = NormalizeDouble(gSize[i], 2);
    }
    printValueTable();
}

void hideStep(int step) {
    string objCurStep   = "objCurStep" + IntegerToString(step);
    string objLowerStep = objCurStep + "Lower";
    string objUpperStep = objCurStep + "Upper";
    ObjectSetInteger(0, objCurStep  , OBJPROP_TIME, 0, 0);
    ObjectSetInteger(0, objLowerStep, OBJPROP_TIME, 0, 0);
    ObjectSetInteger(0, objUpperStep, OBJPROP_TIME, 0, 0);
}
void noteStep(int step, datetime curTime, double curPrice, double upperPrice, double lowerPrice)
{
    string objCurStep = "objCurStep" + IntegerToString(step);
    string objLowerStep = objCurStep + "Lower";
    string objUpperStep = objCurStep + "Upper";
    ObjectCreate(0,     objCurStep, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objCurStep, OBJPROP_COLOR, clrLightGray);
    ObjectSetInteger(0, objCurStep, OBJPROP_ANCHOR, ANCHOR_RIGHT);
    ObjectSetInteger(0, objCurStep, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objCurStep, OBJPROP_BACK, false);
    ObjectSetInteger(0, objCurStep, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objCurStep, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objCurStep, OBJPROP_TEXT, "S"+ IntegerToString(step) +"--");
    ObjectSetDouble(0,  objCurStep, OBJPROP_PRICE, 0, curPrice);
    ObjectSetInteger(0, objCurStep, OBJPROP_TIME, 0, curTime);

    ObjectCreate(0,     objLowerStep, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objLowerStep, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, objLowerStep, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, objLowerStep, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLowerStep, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLowerStep, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objLowerStep, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objLowerStep, OBJPROP_TEXT, "---");
    ObjectSetDouble(0,  objLowerStep, OBJPROP_PRICE, 0, lowerPrice);
    ObjectSetInteger(0, objLowerStep, OBJPROP_TIME, 0, curTime + 5*PeriodSeconds(_Period));

    ObjectCreate(0,     objUpperStep, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objUpperStep, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, objUpperStep, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, objUpperStep, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objUpperStep, OBJPROP_BACK, false);
    ObjectSetInteger(0, objUpperStep, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objUpperStep, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objUpperStep, OBJPROP_TEXT, "---");
    ObjectSetDouble(0,  objUpperStep, OBJPROP_PRICE, 0, upperPrice);
    ObjectSetInteger(0, objUpperStep, OBJPROP_TIME, 0, curTime + 5*PeriodSeconds(_Period));
    // if (gCurStep >= gDefenseGate) {
    // }
    //
}