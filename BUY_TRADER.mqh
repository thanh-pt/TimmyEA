/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/
#include "IMtHandler.mqh"
#define APP_TAG "BUY_TRADER"
#resource "BUY_TRADER_BG.bmp"
class MtHandler: public IMtHandler
{
public:
    virtual void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    virtual void OnTick();
    virtual int OnInit();
};
int MtHandler::OnInit() {
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    // ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    
    initValue();
    return INIT_SUCCEEDED;
}
void MtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if (id == CHARTEVENT_OBJECT_CHANGE) {
        dashBoardOnObjChange(sparam);
    }
    else if (id == CHARTEVENT_OBJECT_CLICK) {
        dashBoardOnObjClick(sparam);
    }
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// INIT - TINH TOAN
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
#define MAX_STEP 20

input double InpInitLot = 0.01;
input double InpLotMultiplier = 1.4;
input int    InpDefenseGate = 3;

input double InpLowerStep00 = 0.5;
input double InpLowerStep01 = 0.5;
input double InpLowerStep02 = 0.5;
input double InpLowerStep03 = 0.5;
input double InpLowerStep04 = 0.5;
input double InpLowerStep05 = 0.5;
input double InpLowerStep06 = 0.5;
input double InpLowerStep07 = 0.5;
input double InpLowerStep08 = 0.5;
input double InpLowerStep09 = 0.5;
input double InpLowerStep10 = 0.5;
input double InpLowerStep11 = 0.5;
input double InpLowerStep12 = 0.7;
input double InpLowerStep13 =   1;
input double InpLowerStep14 =   1;
input double InpLowerStep15 =   2;
input double InpLowerStep16 =   2;
input double InpLowerStep17 =   3;
input double InpLowerStep18 =   6;
input double InpLowerStep19 =  12;

input double InpUpperStep00 =    1;
input double InpUpperStep01 =    1;
input double InpUpperStep02 =    1;
input double InpUpperStep03 =    1;
input double InpUpperStep04 =    1;
input double InpUpperStep05 =    1;
input double InpUpperStep06 =    1;
input double InpUpperStep07 =    1;
input double InpUpperStep08 =    1;
input double InpUpperStep09 =    1;
input double InpUpperStep10 =    1;
input double InpUpperStep11 =    1;
input double InpUpperStep12 =  1.2;
input double InpUpperStep13 =  1.7;
input double InpUpperStep14 =    2;
input double InpUpperStep15 =    3;
input double InpUpperStep16 =    4;
input double InpUpperStep17 =    6;
input double InpUpperStep18 = 10.2;
input double InpUpperStep19 =   20;

double gLowerSteps[MAX_STEP];
double gUpperSteps[MAX_STEP];
double gSize[MAX_STEP];
ulong  gTickets[MAX_STEP];
double gLowerPrice[MAX_STEP];
double gUpperPrice[MAX_STEP];
double gCover[MAX_STEP];
double gLoad[MAX_STEP];
double gReward[MAX_STEP];

double gStoploss;

int     gDefenseGate = 3;
double  gHeso = 1.0;
void initValue() {
    gHeso = InpLotMultiplier;
    gDefenseGate = InpDefenseGate;
    gLowerSteps[ 0] = InpLowerStep00; gUpperSteps[ 0] = InpUpperStep00;
    gLowerSteps[ 1] = InpLowerStep01; gUpperSteps[ 1] = InpUpperStep01;
    gLowerSteps[ 2] = InpLowerStep02; gUpperSteps[ 2] = InpUpperStep02;
    gLowerSteps[ 3] = InpLowerStep03; gUpperSteps[ 3] = InpUpperStep03;
    gLowerSteps[ 4] = InpLowerStep04; gUpperSteps[ 4] = InpUpperStep04;
    gLowerSteps[ 5] = InpLowerStep05; gUpperSteps[ 5] = InpUpperStep05;
    gLowerSteps[ 6] = InpLowerStep06; gUpperSteps[ 6] = InpUpperStep06;
    gLowerSteps[ 7] = InpLowerStep07; gUpperSteps[ 7] = InpUpperStep07;
    gLowerSteps[ 8] = InpLowerStep08; gUpperSteps[ 8] = InpUpperStep08;
    gLowerSteps[ 9] = InpLowerStep09; gUpperSteps[ 9] = InpUpperStep09;
    gLowerSteps[10] = InpLowerStep10; gUpperSteps[10] = InpUpperStep10;
    gLowerSteps[11] = InpLowerStep11; gUpperSteps[11] = InpUpperStep11;
    gLowerSteps[12] = InpLowerStep12; gUpperSteps[12] = InpUpperStep12;
    gLowerSteps[13] = InpLowerStep13; gUpperSteps[13] = InpUpperStep13;
    gLowerSteps[14] = InpLowerStep14; gUpperSteps[14] = InpUpperStep14;
    gLowerSteps[15] = InpLowerStep15; gUpperSteps[15] = InpUpperStep15;
    gLowerSteps[16] = InpLowerStep16; gUpperSteps[16] = InpUpperStep16;
    gLowerSteps[17] = InpLowerStep17; gUpperSteps[17] = InpUpperStep17;
    gLowerSteps[18] = InpLowerStep18; gUpperSteps[18] = InpUpperStep18;
    gLowerSteps[19] = InpLowerStep19; gUpperSteps[19] = InpUpperStep19;
    updateSizeOfStep();
}
void updateSizeOfStep(){
    int i;
    gSize[0] = NormalizeDouble(InpInitLot,2);
    gCover[0] = 0;
    gLoad[0] = 0;
    gReward[0] = gSize[0] * gUpperSteps[i] * 100;
    for (i = 1; i < MAX_STEP; i++) {
        gSize[i] = NormalizeDouble(gHeso * calculateSize(i), 2);
        gReward[i] += gSize[i] * gUpperSteps[i] * 100;
    }
    refreshDashBoard();
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
    gCover[n] = suffix_sum;

    for (i = 0; i < n; i++) {
        total += gSize[i] * suffix_sum;
        suffix_sum -= gLowerSteps[i];
        S_sum += gSize[i];
    }
    gLoad[n] = total * 100;
    total -= gUpperSteps[n] * S_sum;
    if (n >= gDefenseGate) {
        gReward[n] = -total * 100;
    }
    else {
        gReward[n] = 0;
        return InpInitLot;
    }
    
    return MathCeil(total/gUpperSteps[n] * 100)/100;
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// ON_TICK - LOGIC XỬ LÝ
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
int         gCurStep = -1;
double      gDailyOpen;
double      gPreHi;
double      gPreLo;

MqlDateTime gStCurDt;
datetime    gCurDt;

bool        gDoCreateNewS0  = true;
bool        gIsRunning      = true;
void MtHandler::OnTick() {
    if (gIsRunning == false) return;
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    TimeToStruct(gCurDt, gStCurDt);

    // Specific time to trade
    // Exclude sunday
    if (gStCurDt.day_of_week == 0) return;
    // Monday
    if (gStCurDt.day_of_week == 1) {
        // Morning Monday
        if (gStCurDt.hour < 12) {
            gDoCreateNewS0 = false;
            refreshDashBoard();
        }
        // Start trading from afternoon
        else {
            gDoCreateNewS0 = true;
            refreshDashBoard();
        }
    }
    // After noon friday
    else if (gStCurDt.day_of_week == 5 && gStCurDt.hour > 12) {
        gDoCreateNewS0 = false;
        refreshDashBoard();
    }
    // Cannot open trade in 22 EST hour - Maintain time of broker
    if (gStCurDt.hour == 22) return;

    if (gCurStep == -1) {
        if (gDoCreateNewS0 == false) return;
        
        gCurStep++;
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        gStoploss = PAL::Bid() - gCover[MAX_STEP-1] - 20;
        PAL::Buy(gSize[gCurStep], NULL, 0, gStoploss, gUpperPrice[gCurStep], "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
    }

    if (PAL::Bid() >= gUpperPrice[gCurStep]) {
        Print("Reach gUpperPrice[", gCurStep, "] = ", gUpperPrice[gCurStep]);
        if (gCurStep >= gDefenseGate) {
            Print("Reach gDefenseGate:", gDefenseGate);
            for (int i = gCurStep; i >= 0; i--) {
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
        if (gCurStep >= 0) return;
        // if (PAL::Bid() < gDailyOpen) {
        //     Print("Nen DO - Khong mo them lenh!");
        //     return;
        // }
        if (gDoCreateNewS0 == false) return;
        gCurStep++;
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        gStoploss = PAL::Bid() - gCover[MAX_STEP-1] - 20;
        PAL::Buy(gSize[gCurStep], NULL, 0, gStoploss, gUpperPrice[gCurStep], "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
        
    }
    else if (PAL::Ask() <= gLowerPrice[gCurStep]){
        Print("Reach gLowerPrice[", gCurStep, "] = ", gLowerPrice[gCurStep]);
        
        gCurStep++;
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        PAL::Buy(gSize[gCurStep], NULL, 0, gStoploss, gUpperPrice[gCurStep], "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
        // TODO: Hide Lower Price...?
        // hideStep(gCurStep);
    }
}


//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// GIAO DIỆN - HIỂN THỊ
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
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
    return StringSubstr("                                                                               ", 0, spaceSize) + str;
}
string fixedText(double dvalue, int decimal, int size) {
    string str = DoubleToString(dvalue, decimal);
    return fixedText(str, size);
}

void refreshDashBoard()
{
    string objBackGround = "objBackGround";
    ObjectCreate(0,objBackGround,OBJ_BITMAP_LABEL,0,0,0);
    ObjectSetInteger(0,objBackGround,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetInteger(0,objBackGround,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
    ObjectSetInteger(0,objBackGround,OBJPROP_XDISTANCE,10);
    ObjectSetInteger(0,objBackGround,OBJPROP_YDISTANCE,20);
    ObjectSetString(0,objBackGround,OBJPROP_BMPFILE,0,"::BUY_TRADER_BG.bmp");
    //Bảng thông số:
    string objIndex;
    string objLowerStep;
    string objUpperStep;
    string objLtCovLoad;
    string strIndex;
    string strLotCoverLoad;

    int loadsLength = StringLen(DoubleToString(gLoad[MAX_STEP-1], 2));
    int rewardsLength = StringLen(DoubleToString(gReward[MAX_STEP-1], 2));

    createLabel("objSetup"      , "         THÔNG SỐ HỆ THỐNG"          , 10, 30);
    createLabel("objHeso"       , "- Hệ Số:"+DoubleToString(gHeso, 1) , 10, 45);
    createLabel("objDefenseGate", "- Defense Gate:"+IntegerToString(gDefenseGate) , 160, 45);
    createLabel("objTableHeader", "ST Lower Upper"  , 10, 60);
    createLabel("objLtCovLoadHeader", fixedText("Lot",5) + " "+ fixedText("Cover", 5) + " " +
                                      fixedText("Load", loadsLength) + " " + fixedText("Reward", rewardsLength), 115, 60);
    for (int i = 0; i < MAX_STEP; i++){
        strIndex = IntegerToString(i);
        objIndex            = "objIndex"        + strIndex;
        objLowerStep        = "objLowerStep"    + strIndex;
        objUpperStep        = "objUpperStep"    + strIndex;
        objLtCovLoad        = "objLtCovLoad" + strIndex;
        strLotCoverLoad = fixedText(gSize[i], 2, 5) + " " + fixedText(gCover[i], 1, 5) + " " + 
                          fixedText(gLoad[i], 2, loadsLength) + " " + fixedText(gReward[i], 2, rewardsLength);

        createLabel(objIndex    , fixedText(strIndex, 2)            ,  10, 75 + 15*i);
        createLabel(objLowerStep, fixedText(gLowerSteps[i], 1, 5)   ,  30, 75 + 15*i);
        createLabel(objUpperStep, fixedText(gUpperSteps[i], 1, 5)   ,  70, 75 + 15*i);
        createLabel(objLtCovLoad, strLotCoverLoad                   , 115, 75 + 15*i);
    }
    // Feature:
    createLabel("objFeature",       "      TÍNH NĂNG"                                           , 330, 30);
    createLabel("objIsRunning",     "- Chạy BOT:     " +   (gIsRunning ? " [ON]"   : "[OFF]")   , 330, 45);
    createLabel("objIsCreateNewS0", "- Tạo mới S0: " + (gDoCreateNewS0 ? " [TRUE]" : "[FALSE]") , 330, 60);
    createLabel("objBtnCloseAll",   "- Đóng tất cả:[Close]"                                     , 330, 75);
}
void dashBoardOnObjClick(string sparam) {
    if (StringFind(sparam, "objIsCreateNewS0") != -1) {
        gDoCreateNewS0 = !gDoCreateNewS0;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objIsRunning") != -1) {
        gIsRunning = !gIsRunning;
        updateSizeOfStep();
    } 
}
void dashBoardOnObjChange(string sparam) {
    double value;
    if (StringFind(sparam, "objLowerStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objLowerStep", "");
        gLowerSteps[StringToInteger(sparam)] = value;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objUpperStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objUpperStep", "");
        gUpperSteps[StringToInteger(sparam)] = value;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objHeso") != -1) {
        gHeso = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objDefenseGate") != -1) {
        gDefenseGate = (int)StringToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
        updateSizeOfStep();
    }
    else {
        return;
    }
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
    ObjectSetString(0,  objLowerStep, OBJPROP_TEXT, "---"+"L"+ IntegerToString(step));
    ObjectSetDouble(0,  objLowerStep, OBJPROP_PRICE, 0, lowerPrice);
    ObjectSetInteger(0, objLowerStep, OBJPROP_TIME, 0, curTime + 5*PeriodSeconds(_Period));

    ObjectCreate(0,     objUpperStep, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objUpperStep, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, objUpperStep, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(0, objUpperStep, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objUpperStep, OBJPROP_BACK, false);
    ObjectSetInteger(0, objUpperStep, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objUpperStep, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objUpperStep, OBJPROP_TEXT, "---"+"U"+ IntegerToString(step));
    ObjectSetDouble(0,  objUpperStep, OBJPROP_PRICE, 0, upperPrice);
    ObjectSetInteger(0, objUpperStep, OBJPROP_TIME, 0, curTime + 5*PeriodSeconds(_Period));
    // if (gCurStep >= gDefenseGate) {
    // }
    //
}
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////