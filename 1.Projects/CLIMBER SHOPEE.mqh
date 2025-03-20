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
#define LAYER_MAX 20

enum eTypeTrade {
    eUseDailyClose,
    eUseCenterPrice,
};

input string InpBotName = "CLB";

PAL_GROUP(L1_CONDITION, "ĐIỀU KIỆN L1")
input eTypeTrade InpTypeTrade   = eUseDailyClose;
input double     InpCenterPrice = 0;
input double     InpStartL1Space= 0;

PAL_GROUP(THONG_SO_HE_THONG, "THÔNG SỐ HỆ THỐNG")
input double InpVolInit         = 0.01;
input double InpVolMul          = 2;
input int    InpTpAllLayer      = 3;
input int    InpLayerLimit      = LAYER_MAX;
input double InpLastSL          = 5;

PAL_GROUP(DCA_DISTANCES, "KHOẢNG CÁCH DCA")
input double InpDcaDistances1   = 3;
input double InpDcaDistances2   = 3;
input double InpDcaDistances3   = 3;
input double InpDcaDistances4   = 3;
input double InpDcaDistances5   = 3;
input double InpDcaDistances6   = 3;
input double InpDcaDistances7   = 3;
input double InpDcaDistances8   = 3;
input double InpDcaDistances9   = 3;
input double InpDcaDistances10  = 3;
input double InpDcaDistances11  = 3;
input double InpDcaDistances12  = 3;
input double InpDcaDistances13  = 3;
input double InpDcaDistances14  = 3;
input double InpDcaDistances15  = 3;
input double InpDcaDistances16  = 3;
input double InpDcaDistances17  = 3;
input double InpDcaDistances18  = 3;
input double InpDcaDistances19  = 3;
input double InpDcaDistances20  = 3;

PAL_GROUP(TAKE_PROFIT_DISTANCES, "KHOẢNG CÁCH TP")
input double InpTpDistances1    = 3;
input double InpTpDistances2    = 3;
input double InpTpDistances3    = 3;
input double InpTpDistances4    = 3;
input double InpTpDistances5    = 3;
input double InpTpDistances6    = 3;
input double InpTpDistances7    = 3;
input double InpTpDistances8    = 3;
input double InpTpDistances9    = 3;
input double InpTpDistances10   = 3;
input double InpTpDistances11   = 3;
input double InpTpDistances12   = 3;
input double InpTpDistances13   = 3;
input double InpTpDistances14   = 3;
input double InpTpDistances15   = 3;
input double InpTpDistances16   = 3;
input double InpTpDistances17   = 3;
input double InpTpDistances18   = 3;
input double InpTpDistances19   = 3;
input double InpTpDistances20   = 3;


double gDcaDistances[LAYER_MAX];
double gTpDistances[LAYER_MAX];
double gVols[LAYER_MAX];
double gCover;
double gCenterPrice;
// BUY Data
int    gBuyLayer = -1;
double gBuyStoploss;
double gBuyDcaPrices[LAYER_MAX];
double gBuyTpPrices[LAYER_MAX];
ulong  gBuyTickets[LAYER_MAX];
// SELL Data
int    gSellLayer = -1;
double gSellStoploss;
double gSellDcaPrices[LAYER_MAX];
double gSellTpPrices[LAYER_MAX];
ulong  gSellTickets[LAYER_MAX];

void initValue() {
    gDcaDistances[ 0] = InpDcaDistances1 ; gTpDistances[ 0] = InpTpDistances1 ;
    gDcaDistances[ 1] = InpDcaDistances2 ; gTpDistances[ 1] = InpTpDistances2 ;
    gDcaDistances[ 2] = InpDcaDistances3 ; gTpDistances[ 2] = InpTpDistances3 ;
    gDcaDistances[ 3] = InpDcaDistances4 ; gTpDistances[ 3] = InpTpDistances4 ;
    gDcaDistances[ 4] = InpDcaDistances5 ; gTpDistances[ 4] = InpTpDistances5 ;
    gDcaDistances[ 5] = InpDcaDistances6 ; gTpDistances[ 5] = InpTpDistances6 ;
    gDcaDistances[ 6] = InpDcaDistances7 ; gTpDistances[ 6] = InpTpDistances7 ;
    gDcaDistances[ 7] = InpDcaDistances8 ; gTpDistances[ 7] = InpTpDistances8 ;
    gDcaDistances[ 8] = InpDcaDistances9 ; gTpDistances[ 8] = InpTpDistances9 ;
    gDcaDistances[ 9] = InpDcaDistances10; gTpDistances[ 9] = InpTpDistances10;
    gDcaDistances[10] = InpDcaDistances11; gTpDistances[10] = InpTpDistances11;
    gDcaDistances[11] = InpDcaDistances12; gTpDistances[11] = InpTpDistances12;
    gDcaDistances[12] = InpDcaDistances13; gTpDistances[12] = InpTpDistances13;
    gDcaDistances[13] = InpDcaDistances14; gTpDistances[13] = InpTpDistances14;
    gDcaDistances[14] = InpDcaDistances15; gTpDistances[14] = InpTpDistances15;
    gDcaDistances[15] = InpDcaDistances16; gTpDistances[15] = InpTpDistances16;
    gDcaDistances[16] = InpDcaDistances17; gTpDistances[16] = InpTpDistances17;
    gDcaDistances[17] = InpDcaDistances18; gTpDistances[17] = InpTpDistances18;
    gDcaDistances[18] = InpDcaDistances19; gTpDistances[18] = InpTpDistances19;
    gDcaDistances[19] = InpDcaDistances20; gTpDistances[19] = InpTpDistances20;
    
    int i;
    gVols[0] = InpVolInit;
    // Calculate Raw Vols
    for (i = 1; i < LAYER_MAX; i++) gVols[i] = InpVolMul * gVols[i-1];
    // Normalize Vols
    for (i = 0; i < LAYER_MAX; i++) gVols[i] = NormalizeDouble(MathCeil(gVols[i] * 100)/100, 2);
    for (i = 1; i < InpLayerLimit; i++) gCover += gDcaDistances[i];
    gCover += InpLastSL;

    if (InpTypeTrade == eUseCenterPrice) gCenterPrice = InpCenterPrice;
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
    if (gCurDt == 0) return;
    TimeToStruct(gCurDt, gStCurDt);
    gStrCurDate = TimeToString(gCurDt, TIME_DATE);
    if (gStrCurDate != gStrPreDate) {
        if (InpTypeTrade == eUseDailyClose) {
            gPreDailyClose = iClose(_Symbol, PERIOD_D1, 1);
            gCenterPrice = gPreDailyClose;

            datetime time0 = iTime(_Symbol, PERIOD_D1, 0);
            datetime time1 = time0 + PeriodSeconds(PERIOD_D1);
            double price = gCenterPrice;
            // Create Gốc mía
            string objName = APP_TAG + gStrCurDate + "Center Price";
            ObjectCreate(0,     objName, OBJ_TREND, 0, 0, 0);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGray);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time0);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time1);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 1, price);

            price = gCenterPrice+InpStartL1Space;
            objName = APP_TAG + gStrCurDate + "Upper Price";
            ObjectCreate(0,     objName, OBJ_TREND, 0, 0, 0);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLightGray);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time0);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time1);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 1, price);

            price = gCenterPrice-InpStartL1Space;
            objName = APP_TAG + gStrCurDate + "Lower Price";
            ObjectCreate(0,     objName, OBJ_TREND, 0, 0, 0);
            ObjectSetInteger(0, objName, OBJPROP_BACK, true);
            ObjectSetInteger(0, objName, OBJPROP_RAY, false);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLightGray);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time0);
            ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time1);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
            ObjectSetDouble(0,  objName, OBJPROP_PRICE, 1, price);
        }
        
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



    /////// BUY LOGIC ////////////////////////////////////////////
    if (gBuyLayer >= 0) {                                       //
        if (PAL::Bid() >= gBuyTpPrices[gBuyLayer]) {            //
            if (gBuyLayer >= InpTpAllLayer-1) gBuyLayer = -1;   //
            else gBuyLayer--;                                   //
        }                                                       //
        else if (PAL::Ask() <= gBuyDcaPrices[gBuyLayer]){       //
            createBuyDca();                                     //
        }                                                       //
    }                                                           //
    // No running trade                                         //
    if (gBuyLayer < 0) createBuyL1();                           //
    //////////////////////////////////////////////////////////////
    

    /////// SELL LOGIC ///////////////////////////////////////////
    if (gSellLayer >= 0) {                                      //
        if (PAL::Ask() <= gSellTpPrices[gSellLayer]) {          //
            if (gSellLayer >= InpTpAllLayer-1) gSellLayer = -1; //
            else gSellLayer--;                                  //
        }                                                       //
        else if (PAL::Bid() >= gSellDcaPrices[gSellLayer]){     //
            createSellDca();                                    //
        }                                                       //
    }                                                           //
    // No running trade                                         //
    if (gSellLayer < 0) createSellL1();                         //
    //////////////////////////////////////////////////////////////
}

void createBuyL1()
{
    // L0 Condition
    int i = 0;
    string objName;
    for (i = 0; i <= InpLayerLimit; i++){
        objName = APP_TAG + "BUY L" + IntegerToString(i);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, 0);
    }
    if (gbCreateNewL0 == false) return;
    if (PAL::Bid() > gCenterPrice-InpStartL1Space) return;

    // Create new L1
    gBuyLayer++;
    gBuyTpPrices[gBuyLayer] = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    gBuyStoploss = PAL::Bid() - gCover;
    PAL::Buy(gVols[gBuyLayer], NULL, 0, gBuyStoploss, gBuyTpPrices[gBuyLayer], InpBotName + "|Buy L"+IntegerToString(gBuyLayer));
    gBuyTickets[gBuyLayer] = PAL::ResultOrder();

    // Hien thi BUY GRID
    double dcaPrice = PAL::Ask();
    double spread = PAL::Ask() - PAL::Bid();
    datetime curTime = iTime(_Symbol, PERIOD_CURRENT, 0) + 10 * PeriodSeconds(_Period);
    for (i = 1; i <= InpLayerLimit; i++) {
        objName = APP_TAG + "BUY L" + IntegerToString(i);
        ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
        ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(i));
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, dcaPrice);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
        dcaPrice -= gDcaDistances[i-1]+spread;
    }
    objName = APP_TAG + "BUY L" + IntegerToString(InpTpAllLayer);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(InpTpAllLayer) + " tp gộp");
    objName = APP_TAG + "BUY L0";
    ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______SL");
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, gBuyStoploss);
    ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
}

void createBuyDca()
{
    // DCA Condition
    if (gBuyLayer >= InpLayerLimit-1) {
        if (PAL::Ask() <= gBuyStoploss) gBuyLayer = -1;
        return;
    }

    gBuyLayer++;
    gBuyTpPrices[gBuyLayer] = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    PAL::Buy(gVols[gBuyLayer], NULL, 0, gBuyStoploss, gBuyTpPrices[gBuyLayer], InpBotName + "|Buy L"+IntegerToString(gBuyLayer));
    gBuyTickets[gBuyLayer] = PAL::ResultOrder();
    
    // Tp Gộp
    if (gBuyLayer >= InpTpAllLayer-1) {
        for (int i = 0; i < gBuyLayer; i++) {
            PAL::PositionModify(gBuyTickets[i], gBuyStoploss, gBuyTpPrices[gBuyLayer]);
        }
    }
}

void createSellL1()
{
    // L0 Condition
    int i = 0;
    string objName;
    for (i = 0; i <= InpLayerLimit; i++) {
        objName = APP_TAG + "SELL L" + IntegerToString(i);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, 0);
    }
    if (gbCreateNewL0 == false) return;
    if (PAL::Bid() < gCenterPrice+InpStartL1Space) return;

    // Create new L1
    gSellLayer++;
    gSellTpPrices[gSellLayer] = PAL::Bid() - gTpDistances[gSellLayer];
    gSellDcaPrices[gSellLayer] = PAL::Ask() + gDcaDistances[gSellLayer];
    gSellStoploss = PAL::Ask() + gCover;
    PAL::Sell(gVols[gSellLayer], NULL, 0, gSellStoploss, gSellTpPrices[gSellLayer], InpBotName + "|Sell L"+IntegerToString(gSellLayer));
    gSellTickets[gSellLayer] = PAL::ResultOrder();

    // Hien thi Sell GRID
    double dcaPrice = PAL::Bid();
    double spread = PAL::Ask() - PAL::Bid();
    datetime curTime = iTime(_Symbol, PERIOD_CURRENT, 0) + 10 * PeriodSeconds(_Period);
    for (i = 1; i <= InpLayerLimit; i++) {
        objName = APP_TAG + "SELL L" + IntegerToString(i);
        ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
        ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(i));
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, dcaPrice);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
        dcaPrice += gDcaDistances[i-1]+spread;
    }
    objName = APP_TAG + "SELL L" + IntegerToString(InpTpAllLayer);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrYellow);
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(InpTpAllLayer) + " tp gộp");
    objName = APP_TAG + "SELL L0";
    ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______SL");
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, gSellStoploss);
    ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
}

void createSellDca()
{
    // DCA Condition
    if (gSellLayer >= InpLayerLimit-1) {
        if (PAL::Bid() >= gSellStoploss) gSellLayer = -1;
        return;
    }

    gSellLayer++;
    gSellTpPrices[gSellLayer] = PAL::Bid() - gTpDistances[gSellLayer];
    gSellDcaPrices[gSellLayer] = PAL::Ask() + gDcaDistances[gSellLayer];
    PAL::Sell(gVols[gSellLayer], NULL, 0, gSellStoploss, gSellTpPrices[gSellLayer], InpBotName + "|Sell L"+IntegerToString(gSellLayer));
    gSellTickets[gSellLayer] = PAL::ResultOrder();
    
    // Tp Gộp
    if (gSellLayer >= InpTpAllLayer-1) {
        for (int i = 0; i < gSellLayer; i++) {
            PAL::PositionModify(gSellTickets[i], gSellStoploss, gSellTpPrices[gSellLayer]);
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