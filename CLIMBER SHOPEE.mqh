/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/
#include "Library/IMtHandler.mqh"
#define APP_TAG "CLIMBER SHOPEE"
class MtHandler: public IMtHandler
{
public:
    virtual void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    virtual void OnTick();
    virtual int OnInit();
};
int MtHandler::OnInit() {
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    
    initValue();
    return INIT_SUCCEEDED;
}
void MtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// INPUT - INIT - TINH TOAN
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
#define DCA_LIMIT 20

enum eTypeTrade {
    eUseDailyClose,
    eUseCenterPrice,
};

input string InpBotName = "CLB";

input string _L0_CONDITION;
input eTypeTrade InpTypeTrade   = eUseDailyClose;
input double     InpCenterPrice = 0;

input string _THONG_SO_HE_THONG;
input double InpInitVol         = 0.01;
input double InpVolMultiplier   = 2;
input int    InpTpAllGate       = 1;
input int    InpDcaLimit        = DCA_LIMIT;
input double InpLastSL          = 20;

input string _DCA_DISTANCES;
input double InpDcaDistances0   = 1;
input double InpDcaDistances1   = 1;
input double InpDcaDistances2   = 1;
input double InpDcaDistances3   = 1;
input double InpDcaDistances4   = 1;
input double InpDcaDistances5   = 1;
input double InpDcaDistances6   = 1;
input double InpDcaDistances7   = 1;
input double InpDcaDistances8   = 1;
input double InpDcaDistances9   = 1;
input double InpDcaDistances10  = 1;
input double InpDcaDistances11  = 1;
input double InpDcaDistances12  = 1;
input double InpDcaDistances13  = 1;
input double InpDcaDistances14  = 1;
input double InpDcaDistances15  = 1;
input double InpDcaDistances16  = 1;
input double InpDcaDistances17  = 1;
input double InpDcaDistances18  = 1;
input double InpDcaDistances19  = 1;

input string _TAKE_PROFIT_DISTANCES;
input double InpTpDistances0    = 2;
input double InpTpDistances1    = 2;
input double InpTpDistances2    = 2;
input double InpTpDistances3    = 2;
input double InpTpDistances4    = 2;
input double InpTpDistances5    = 2;
input double InpTpDistances6    = 2;
input double InpTpDistances7    = 2;
input double InpTpDistances8    = 2;
input double InpTpDistances9    = 2;
input double InpTpDistances10   = 2;
input double InpTpDistances11   = 2;
input double InpTpDistances12   = 2;
input double InpTpDistances13   = 2;
input double InpTpDistances14   = 2;
input double InpTpDistances15   = 2;
input double InpTpDistances16   = 2;
input double InpTpDistances17   = 2;
input double InpTpDistances18   = 2;
input double InpTpDistances19   = 2;


double gDcaDistances[DCA_LIMIT];
double gTpDistances[DCA_LIMIT];
double gVols[DCA_LIMIT];
double gCover;
// BUY Data
int    gBuyLayer = -1;
double gBuyStoploss;
double gBuyDcaPrices[DCA_LIMIT];
double gBuyTpPrices[DCA_LIMIT];
ulong  gBuyTickets[DCA_LIMIT];

void initValue() {
    gDcaDistances[ 0] = InpDcaDistances0;  gTpDistances[ 0] = InpTpDistances0;
    gDcaDistances[ 1] = InpDcaDistances1;  gTpDistances[ 1] = InpTpDistances1;
    gDcaDistances[ 2] = InpDcaDistances2;  gTpDistances[ 2] = InpTpDistances2;
    gDcaDistances[ 3] = InpDcaDistances3;  gTpDistances[ 3] = InpTpDistances3;
    gDcaDistances[ 4] = InpDcaDistances4;  gTpDistances[ 4] = InpTpDistances4;
    gDcaDistances[ 5] = InpDcaDistances5;  gTpDistances[ 5] = InpTpDistances5;
    gDcaDistances[ 6] = InpDcaDistances6;  gTpDistances[ 6] = InpTpDistances6;
    gDcaDistances[ 7] = InpDcaDistances7;  gTpDistances[ 7] = InpTpDistances7;
    gDcaDistances[ 8] = InpDcaDistances8;  gTpDistances[ 8] = InpTpDistances8;
    gDcaDistances[ 9] = InpDcaDistances9;  gTpDistances[ 9] = InpTpDistances9;
    gDcaDistances[10] = InpDcaDistances10; gTpDistances[10] = InpTpDistances10;
    gDcaDistances[11] = InpDcaDistances11; gTpDistances[11] = InpTpDistances11;
    gDcaDistances[12] = InpDcaDistances12; gTpDistances[12] = InpTpDistances12;
    gDcaDistances[13] = InpDcaDistances13; gTpDistances[13] = InpTpDistances13;
    gDcaDistances[14] = InpDcaDistances14; gTpDistances[14] = InpTpDistances14;
    gDcaDistances[15] = InpDcaDistances15; gTpDistances[15] = InpTpDistances15;
    gDcaDistances[16] = InpDcaDistances16; gTpDistances[16] = InpTpDistances16;
    gDcaDistances[17] = InpDcaDistances17; gTpDistances[17] = InpTpDistances17;
    gDcaDistances[18] = InpDcaDistances18; gTpDistances[18] = InpTpDistances18;
    gDcaDistances[19] = InpDcaDistances19; gTpDistances[19] = InpTpDistances19;
    
    int i;
    gVols[0] = InpInitVol;
    // Calculate Raw Vols
    for (i = 1; i < DCA_LIMIT; i++) gVols[i] = InpVolMultiplier * gVols[i-1];
    // Normalize Vols
    for (i = 0; i < DCA_LIMIT; i++) gVols[i] = NormalizeDouble(MathCeil(gVols[i] * 100)/100, 2);
    for (i = 1; i < InpDcaLimit; i++) gCover += gDcaDistances[i];
    gCover += InpLastSL;
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// ON_TICK - LOGIC XỬ LÝ
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

MqlDateTime gStCurDt;
datetime    gCurDt;
string      gStrCurDate = "";
string      gStrPreDate = "";

double      gPreDailyClose = 0;

bool        gbCreateNewL0  = true;
void MtHandler::OnTick() {
    // LOGIC CHECK NEW DAY
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    TimeToStruct(gCurDt, gStCurDt);
    gStrCurDate = TimeToString(gCurDt, TIME_DATE);
    if (gStrCurDate != gStrPreDate) {
        gPreDailyClose = iClose(_Symbol, PERIOD_D1, 1);
        gStrPreDate = gStrCurDate;
    }

    /*
    // LOGIC SELECT TIME TO TRADE - SHOULD REMOVE IN FUTURE - OR HAVE INPUT FOR IT
    // Exclude sunday
    if (gStCurDt.day_of_week == 0) return;
    // Monday
    if (gStCurDt.day_of_week == 1) {
        // Morning Monday
        if (gStCurDt.hour < 12) {
            gbCreateNewL0 = false;
            refreshDashBoard();
        }
        // Start trading from afternoon
        else {
            gbCreateNewL0 = true;
            refreshDashBoard();
        }
    }
    // After noon friday
    else if (gStCurDt.day_of_week == 5 && gStCurDt.hour > 12) {
        gbCreateNewL0 = false;
        refreshDashBoard();
    }
    */

    // Cannot open trade in 22 EST hour - Maintain time of broker
    if (gStCurDt.hour == 22) return;

    if (gBuyLayer >= 0) {
        if (PAL::Bid() >= gBuyTpPrices[gBuyLayer]) {
            if (gBuyLayer >= InpTpAllGate) gBuyLayer = -1;
            else gBuyLayer--;
        }
        else if (PAL::Ask() <= gBuyDcaPrices[gBuyLayer]){
            createBuyDca();
        }
    }

    // No running trade
    if (gBuyLayer < 0) createBuyL0();

    // ROBOT LOGIC - BUY LOGIC - TODO: develop SELL logic
}

void createBuyL0()
{
    // L0 Condition
    if (gbCreateNewL0 == false) return;

    Print(APP_TAG, "New L0 | Time:", gStCurDt.hour);
    gBuyLayer++;
    gBuyTpPrices[gBuyLayer] = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    gBuyStoploss = PAL::Bid() - gCover;
    PAL::Buy(gVols[gBuyLayer], NULL, 0, gBuyStoploss, gBuyTpPrices[gBuyLayer], InpBotName + "|L"+IntegerToString(gBuyLayer));
    gBuyTickets[gBuyLayer] = PAL::ResultOrder();
    for (int i = 0; i < InpDcaLimit; i++) {
        //
    }
}

void createBuyDca()
{
    // DCA Condition
    if (gBuyLayer >= InpDcaLimit-1) return;

    gBuyLayer++;
    gBuyTpPrices[gBuyLayer] = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    PAL::Buy(gVols[gBuyLayer], NULL, 0, gBuyStoploss, gBuyTpPrices[gBuyLayer], InpBotName + "|L"+IntegerToString(gBuyLayer));
    gBuyTickets[gBuyLayer] = PAL::ResultOrder();
    if (gBuyLayer >= InpTpAllGate) {
        for (int i = 0; i < gBuyLayer; i++) {
            PAL::PositionModify(gBuyTickets[i], gBuyStoploss, gBuyTpPrices[gBuyLayer]);
        }
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
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////