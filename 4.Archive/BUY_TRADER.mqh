/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/
#include "IMtHandler.mqh"
#define APP_TAG "BUY_TRADER"
#resource "BUY_TRADER_BG.bmp"

#define MAX_STEP 20

_PAL_GROUP(Varible, "Xin chao")

double gLowerSteps[MAX_STEP];
double gUpperSteps[MAX_STEP];
double gSize[MAX_STEP];
ulong  gTickets[MAX_STEP];
double gLowerPrice[MAX_STEP];
double gUpperPrice[MAX_STEP];
double gCover[MAX_STEP];
double gLoad[MAX_STEP];
double gReward[MAX_STEP];

int gDefenseGate = 3;
double inpHeso = 1.5;
void initValue() {
    inpHeso = 1.5;
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
    gLowerSteps[18] =   6; gUpperSteps[18] =10.2;
    gLowerSteps[19] =  12; gUpperSteps[19] =  20;
    gSize[0] = 0.01;
    gSize[1] = 0.01;
    gCover[0] = 0;
    gCover[1] = gLowerSteps[0];
    gLoad[0] = 0;
    gLoad[1] = gSize[0] * gLowerSteps[0] * 100;
    gReward[0] = gSize[0] * gUpperSteps[0] * 100;
    gReward[1] = gSize[1] * gUpperSteps[1] * 100;
    updateSizeOfStep();
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
        gReward[n] = total;
    }
    else {
        gReward[n] = gSize[n] * gUpperPrice[n];
    }
    
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

int         gCurStep = -1;
double      gDailyOpen;
double      gPreHi;
double      gPreLo;

MqlDateTime gStCurDt;
datetime    gCurDt;
string      gStrCurTime, gStrPreTime;

bool        gDoCreateNewS0  = true;
bool        gIsRunning      = true;
void MtHandler::OnTick() {
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
        gStrPreTime = gStrCurTime;
        if (gCurStep == -1 && gDoCreateNewS0 == true) {
            gCurStep++;
            PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
            gTickets[gCurStep] = PAL::ResultOrder();
            gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
            gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
            noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
        }
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
        // if (gStCurDt.hour >= 19) {
        //     return;
        // }
        if (gCurStep >= 0) return;
        // if (PAL::Bid() < gDailyOpen) {
        //     Print("Nen DO - Khong mo them lenh!");
        //     return;
        // }
        if (gDoCreateNewS0 == false) return;
        gCurStep++;
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
    }
    else if (gCurStep >= 0 && PAL::Ask() <= gLowerPrice[gCurStep]){
        // if (gStCurDt.hour >= 19 && gCurStep == 0) {
        //     return;
        // }
        Print("Reach gLowerPrice[", gCurStep, "] = ", gLowerPrice[gCurStep]);
        
        gCurStep++;
        PAL::Buy(gSize[gCurStep], NULL, 0, 0, 0, "S"+IntegerToString(gCurStep));
        gTickets[gCurStep] = PAL::ResultOrder();
        gUpperPrice[gCurStep] = PAL::Ask() + gUpperSteps[gCurStep];
        gLowerPrice[gCurStep] = PAL::Bid() - gLowerSteps[gCurStep];
        noteStep(gCurStep, TimeCurrent(), PAL::Ask(), gUpperPrice[gCurStep], gLowerPrice[gCurStep]);
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
    createLabel("objHeso"       , "- Hệ Số:"+DoubleToString(inpHeso, 1) , 10, 45);
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
        createLabel(objLowerStep, fixedText(gLowerSteps[i], 1, 5)   ,  35, 75 + 15*i);
        createLabel(objUpperStep, fixedText(gUpperSteps[i], 1, 5)   ,  75, 75 + 15*i);
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
        inpHeso = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
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

void updateSizeOfStep(){
    int i;
    for (i = 2; i < MAX_STEP; i++) {
        gSize[i] = inpHeso * calculateSize(i);
    }
    for (i = 0; i < MAX_STEP; i++) {
        gSize[i] = NormalizeDouble(gSize[i], 2);
        if (i >= gDefenseGate) {
            gReward[i] += gSize[i] * gUpperSteps[i];
        }
    }
    refreshDashBoard();
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