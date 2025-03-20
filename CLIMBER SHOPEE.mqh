/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/
#include "Library/IMtHandler.mqh"
#define APP_TAG "CLIMBER SHOPEE"
#define BTN_ONOFFCREATEL1 APP_TAG+"btnNewL1"
class MtHandler: public IMtHandler
{
public:
    virtual void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    virtual void OnTick();
    virtual int OnInit();
};
int MtHandler::OnInit() {
    gInitBot = false;
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    
    initValue();
    InitBOT();
    displayDashboard();
    return INIT_SUCCEEDED;
}
void MtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if (id == CHARTEVENT_OBJECT_CLICK) {
        handleClick(sparam);
    }
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
bool   gInitBot = false;
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
    gVols[0] = NormalizeDouble(InpVolInit, 2);
    // Calculate Vols
    for (i = 1; i < LAYER_MAX; i++) {
        gVols[i] = MathCeil(InpVolMul * gVols[i-1] * 100)/100;
        gVols[i] = NormalizeDouble(gVols[i], 2);
    }
    // Calculate Cover
    for (i = 0; i < InpLayerLimit-1; i++) gCover += gDcaDistances[i];
    gCover += InpLastSL;

    gCenterPrice = InpCenterPrice;
}

void InitBOT(){
    strBuyPrefix  = InpBotName + "|Buy L";
    strSellPrefix = InpBotName + "|Sell L";

    ENUM_POSITION_TYPE type;
    double priceOpen;
    double spread = PAL::Ask() - PAL::Bid();
    string comment;
    int layer = 0;
    gBuyLayer = -1;
    gSellLayer = -1;
    for (int i = 0; i < PositionsTotal(); i++) {
        PositionSelectByTicket(PositionGetTicket(i));
        type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        comment = PositionGetString(POSITION_COMMENT);
        if (StringFind(comment, strBuyPrefix) != -1) {
            StringReplace(comment, strBuyPrefix, "");
            layer = (int)StringToInteger(comment);
            priceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
            gBuyTickets[layer] = PositionGetInteger(POSITION_TICKET);
            gBuyTpPrices[layer] = PositionGetDouble(POSITION_TP);
            gBuyDcaPrices[layer] = priceOpen - gDcaDistances[layer];
            if (layer > gBuyLayer) gBuyLayer = layer;
            if (layer == 0) {
                gBuyStoploss = priceOpen - spread - gCover;
                displayGridLevel("BUY", priceOpen, spread, gBuyStoploss);
            }
        }
        else if (StringFind(comment, strSellPrefix) != -1) {
            StringReplace(comment, strSellPrefix, "");
            layer = (int)StringToInteger(comment);
            priceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
            gSellTickets[layer] = PositionGetInteger(POSITION_TICKET);
            gSellTpPrices[layer] = PositionGetDouble(POSITION_TP);
            gSellDcaPrices[layer] = priceOpen + gDcaDistances[layer];
            if (layer > gSellLayer) gSellLayer = layer;
            if (layer == 0) {
                gSellStoploss = priceOpen + spread + gCover;
                displayGridLevel("SELL", priceOpen, spread, gBuyStoploss);
            }
        }
    }
    gbCreateNewL1 = true;
    if (StringFind(ObjectGetString(0, BTN_ONOFFCREATEL1, OBJPROP_TEXT), "[OFF]") != -1) gbCreateNewL1 =  false;
    gInitBot = true;
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

bool        gbCreateNewL1  = true;
string      strBuyPrefix  = InpBotName + "|Buy L";
string      strSellPrefix = InpBotName + "|Sell L";
void MtHandler::OnTick() {
    if (gInitBot == false) return;
    // LOGIC CHECK NEW DAY
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    if (gCurDt == 0) return;
    TimeToStruct(gCurDt, gStCurDt);
    gStrCurDate = TimeToString(gCurDt, TIME_DATE);
    if (gStrCurDate != gStrPreDate) {
        if (InpTypeTrade == eUseDailyClose) {
            gPreDailyClose = iClose(_Symbol, PERIOD_D1, 1);
            gCenterPrice = gPreDailyClose;

            displayCloseD1();
        }
        gStrPreDate = gStrCurDate;
    }

    // TODO: Time to turn off

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
    hideGridLevel("BUY");
    // L1 Condition
    if (gbCreateNewL1 == false) return;
    if (PAL::Bid() > gCenterPrice-InpStartL1Space) return;

    // Create new L1
    gBuyLayer++;
    gBuyTpPrices[gBuyLayer]  = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    gBuyStoploss = PAL::Bid() - gCover;
    if (PAL::Buy(gVols[gBuyLayer], gBuyStoploss, gBuyTpPrices[gBuyLayer], strBuyPrefix+IntegerToString(gBuyLayer))){
        gBuyTickets[gBuyLayer] = PAL::ResultOrder();
        displayGridLevel("BUY", PAL::Ask(), PAL::Ask()-PAL::Bid(), gBuyStoploss);
    }
    else gBuyLayer = -1;
    displayDashboard();
}
void createSellL1()
{
    hideGridLevel("SELL");
    // L1 Condition
    if (gbCreateNewL1 == false) return;
    if (PAL::Bid() < gCenterPrice+InpStartL1Space) return;

    // Create new L1
    gSellLayer++;
    gSellTpPrices[gSellLayer]  = PAL::Bid() - gTpDistances[gSellLayer];
    gSellDcaPrices[gSellLayer] = PAL::Ask() + gDcaDistances[gSellLayer];
    gSellStoploss = PAL::Ask() + gCover;
    if (PAL::Sell(gVols[gSellLayer], gSellStoploss, gSellTpPrices[gSellLayer], strSellPrefix+IntegerToString(gSellLayer))) {
        gSellTickets[gSellLayer] = PAL::ResultOrder();
        displayGridLevel("SELL", PAL::Bid(), PAL::Ask()-PAL::Bid(), gSellStoploss);
    }
    else gSellLayer = -1;
    displayDashboard();
}

void createBuyDca()
{
    // DCA Condition
    if (gBuyLayer >= InpLayerLimit-1) {
        if (PAL::Ask() <= gBuyStoploss) gBuyLayer = -1;
        return;
    }

    gBuyLayer++;
    gBuyTpPrices[gBuyLayer]  = PAL::Ask() + gTpDistances[gBuyLayer];
    gBuyDcaPrices[gBuyLayer] = PAL::Bid() - gDcaDistances[gBuyLayer];
    if (PAL::Buy(gVols[gBuyLayer], gBuyStoploss, gBuyTpPrices[gBuyLayer], strBuyPrefix+IntegerToString(gBuyLayer))){
        gBuyTickets[gBuyLayer] = PAL::ResultOrder();
    }
    else gBuyLayer--;
    
    // Tp Gộp
    if (gBuyLayer >= InpTpAllLayer-1) {
        for (int i = 0; i < gBuyLayer; i++) {
            PAL::PositionModify(gBuyTickets[i], gBuyStoploss, gBuyTpPrices[gBuyLayer]);
        }
    }
    displayDashboard();
}
void createSellDca()
{
    // DCA Condition
    if (gSellLayer >= InpLayerLimit-1) {
        if (PAL::Bid() >= gSellStoploss) gSellLayer = -1;
        return;
    }

    gSellLayer++;
    gSellTpPrices[gSellLayer]  = PAL::Bid() - gTpDistances[gSellLayer];
    gSellDcaPrices[gSellLayer] = PAL::Ask() + gDcaDistances[gSellLayer];
    if (PAL::Sell(gVols[gSellLayer], gSellStoploss, gSellTpPrices[gSellLayer], strSellPrefix+IntegerToString(gSellLayer))){
        gSellTickets[gSellLayer] = PAL::ResultOrder();
    }
    else gSellLayer--;
    
    // Tp Gộp
    if (gSellLayer >= InpTpAllLayer-1) {
        for (int i = 0; i < gSellLayer; i++) {
            PAL::PositionModify(gSellTickets[i], gSellStoploss, gSellTpPrices[gSellLayer]);
        }
    }
    displayDashboard();
}
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// GIAO DIỆN - HIỂN THỊ
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/// @brief Apprearence and Action
void createLabel(string objName, string text, int posX, int posY, int size = 10, color clr = clrNavy)
{
    ObjectCreate(0,     objName, OBJ_LABEL, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    // ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objName, OBJPROP_BACK, false);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, size);
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

void handleClick(string sparam){
    if (StringFind(sparam, BTN_ONOFFCREATEL1) != -1) {
        gbCreateNewL1 = !gbCreateNewL1;
        displayDashboard();
    }
}
void displayDashboard() {
    createLabel(APP_TAG+"BG1"    , "███████"        , 0, 55, 32, clrLightSlateGray);
    createLabel(APP_TAG+"BG2"    , "███████"        , 0, 25, 32, clrDarkSeaGreen);
    createLabel(APP_TAG+"BotName", "♟ "+InpBotName , 0, 75, 20);
    createLabel(APP_TAG+"State"  , "SELL:"+IntegerToString(gSellLayer+1)+"  BUY:"+IntegerToString(gBuyLayer+1), 10, 54);
    if (gbCreateNewL1) createLabel(BTN_ONOFFCREATEL1, "NEW L1: [ ON]", 10, 30, 14, clrGreen);
    else               createLabel(BTN_ONOFFCREATEL1, "NEW L1: [OFF]", 10, 30, 14, clrCrimson);
}
void hideGridLevel(string tag) {
    string objName;
    for (int i = 0; i <= InpLayerLimit; i++){
        objName = APP_TAG + tag + IntegerToString(i);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, 0);
    }
}
void displayGridLevel(string tag, double price, double spread, double& lastSL) {
    int fliper = 1;
    string objName;
    datetime curTime = iTime(_Symbol, PERIOD_CURRENT, 0) + 10 * PeriodSeconds(_Period);
    color clr = clrRed;
    if (tag == "BUY") {
        fliper = -1;
        clr = clrGreen;
    }

    for (int i = 1; i <= InpLayerLimit; i++) {
        objName = APP_TAG + tag + IntegerToString(i);
        ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
        ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
        ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
        ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(i));
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
        price = price + fliper * (gDcaDistances[i-1]+spread);
    }
    objName = APP_TAG + tag + IntegerToString(InpTpAllLayer);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrGold);
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______L" + IntegerToString(InpTpAllLayer) + " tp gộp");
    objName = APP_TAG + tag + "0";
    ObjectCreate(0,     objName, OBJ_TEXT, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetString(0,  objName, OBJPROP_TEXT, "_______SL");
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, lastSL);
    ObjectSetInteger(0, objName, OBJPROP_TIME, 0, curTime);
}
void displayCloseD1(){
    datetime time0 = iTime(_Symbol, PERIOD_D1, 0);
    datetime time1 = time0 + PeriodSeconds(PERIOD_D1);
    // Create Gốc mía
    string objName = APP_TAG + gStrCurDate + "Close D1";
    ObjectCreate(0,     objName, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_BACK, true);
    ObjectSetInteger(0, objName, OBJPROP_RAY, false);
    ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
    ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, gCenterPrice);
    ObjectSetDouble(0,  objName, OBJPROP_PRICE, 1, gCenterPrice);
    if (InpStartL1Space > 0) {
        double price = gCenterPrice+InpStartL1Space;
        objName = APP_TAG + gStrCurDate + "Upper Price";
        ObjectCreate(0,     objName, OBJ_TREND, 0, 0, 0);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);
        ObjectSetInteger(0, objName, OBJPROP_RAY, false);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
        ObjectSetString(0,  objName, OBJPROP_TOOLTIP, "\n");
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrDarkGray);
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
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clrDarkGray);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time0);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time1);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 0, price);
        ObjectSetDouble(0,  objName, OBJPROP_PRICE, 1, price);
    }
}
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////