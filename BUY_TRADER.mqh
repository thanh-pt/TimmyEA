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
#define DCA_LIMIT 20

input string THONG_SO_HE_THONG="";
input double InpInitVol=0.01;
input double InpVolMultiplier=1.4;
input int    InpTpAllGate=5;
input int    InpDcaLimit=DCA_LIMIT;

input string DCA_DISTANCES="";
input double InpDcaDistances0 =0.5;
input double InpDcaDistances1 =0.5;
input double InpDcaDistances2 =0.5;
input double InpDcaDistances3 =0.5;
input double InpDcaDistances4 =0.5;
input double InpDcaDistances5 =0.5;
input double InpDcaDistances6 =0.5;
input double InpDcaDistances7 =0.5;
input double InpDcaDistances8 =0.5;
input double InpDcaDistances9 =0.5;
input double InpDcaDistances10=0.5;
input double InpDcaDistances11=0.5;
input double InpDcaDistances12=0.5;
input double InpDcaDistances13=0.5;
input double InpDcaDistances14=0.5;
input double InpDcaDistances15=0.5;
input double InpDcaDistances16=0.5;
input double InpDcaDistances17=0.5;
input double InpDcaDistances18=0.5;
input double InpDcaDistances19=0.5;

input string TAKE_PROFIT_DISTANCES="";
input double InpTpDistances0 =1.5;
input double InpTpDistances1 =1.5;
input double InpTpDistances2 =1.5;
input double InpTpDistances3 =1.5;
input double InpTpDistances4 =1.5;
input double InpTpDistances5 =1.5;
input double InpTpDistances6 =1.5;
input double InpTpDistances7 =1.5;
input double InpTpDistances8 =1.5;
input double InpTpDistances9 =1.5;
input double InpTpDistances10=1.5;
input double InpTpDistances11=1.5;
input double InpTpDistances12=1.5;
input double InpTpDistances13=1.5;
input double InpTpDistances14=1.5;
input double InpTpDistances15=1.5;
input double InpTpDistances16=1.5;
input double InpTpDistances17=1.5;
input double InpTpDistances18=1.5;
input double InpTpDistances19=1.5;

string gSetFile = "config.set";

double gDcaDistances[DCA_LIMIT];
double gTpDistances[DCA_LIMIT];
double gVols[DCA_LIMIT];
ulong  gTickets[DCA_LIMIT];
double gDcaPrices[DCA_LIMIT];
double gTpPrices[DCA_LIMIT];
double gCovers[DCA_LIMIT];
double gLoads[DCA_LIMIT];
double gRewards[DCA_LIMIT];

double gStoploss;

double  gMultiplier        = 0;
int     gDcaLimit     = 0;
int     gDefenseGate = 0;
void initValue() {
    gMultiplier      = InpVolMultiplier;
    gDcaLimit        = InpDcaLimit;
    gDefenseGate     = InpTpAllGate;
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
    updateSizeOfStep();
}
void updateSizeOfStep(){
    int i;
    gVols[0] = NormalizeDouble(InpInitVol,2);
    gCovers[0] = 0;
    gLoads[0] = 0;
    gRewards[0] = gVols[0] * gTpDistances[i] * 100;
    for (i = 1; i < DCA_LIMIT; i++) {
        gVols[i] = NormalizeDouble(gMultiplier * calculateSize(i), 2);
        gRewards[i] += gVols[i] * gTpDistances[i] * 100;
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
        suffix_sum += gDcaDistances[i];
    }
    gCovers[n] = suffix_sum;

    for (i = 0; i < n; i++) {
        total += gVols[i] * suffix_sum;
        suffix_sum -= gDcaDistances[i];
        S_sum += gVols[i];
    }
    gLoads[n] = total * 100;
    total -= gTpDistances[n] * S_sum;
    if (n >= gDefenseGate) {
        gRewards[n] = -total * 100;
    }
    else {
        gRewards[n] = 0;
        return InpInitVol;
    }
    
    return MathCeil(total/gTpDistances[n] * 100)/100;
}

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// ON_TICK - LOGIC XỬ LÝ
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
int         gCurLayer = -1;

MqlDateTime gStCurDt;
datetime    gCurDt;
string      gStrCurDate = "";
string      gStrPreDate = "";

bool        gbCreateNewL0  = true;
bool        gIsRunning      = true;
void MtHandler::OnTick() {
    if (gIsRunning == false) return;

    // LOGIC CHECK NEW DAY
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    TimeToStruct(gCurDt, gStCurDt);
    gStrCurDate = TimeToString(gCurDt, TIME_DATE);
    if (gStrCurDate != gStrPreDate) {
        DailyReport(gStrCurDate, gStrPreDate);
        gStrPreDate = gStrCurDate;
        createL0();
    }

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

    // Cannot open trade in 22 EST hour - Maintain time of broker
    if (gStCurDt.hour == 22) return;

    // No running trade
    if (gCurLayer < 0) return;

    // ROBOT LOGIC - BUY LOGIC - TODO: develop SELL logic
    if (PAL::Bid() >= gTpPrices[gCurLayer]) {
        if (gCurLayer >= gDefenseGate) {
            for (int i = gCurLayer; i >= 0; i--) closeStep(i);
            gCurLayer = -1;
        }
        else {
            closeStep(gCurLayer);
            gCurLayer--;
        }
        createL0();
    }
    else if (PAL::Ask() <= gDcaPrices[gCurLayer]){
        createDCA();
    }
}

void createL0()
{
    if (gCurLayer >= 0) return;
    if (gbCreateNewL0 == false) return;

    Print(APP_TAG, "New L0 | Time:", gStCurDt.hour);
    gCurLayer++;
    gTpPrices[gCurLayer] = PAL::Ask() + gTpDistances[gCurLayer];
    gDcaPrices[gCurLayer] = PAL::Bid() - gDcaDistances[gCurLayer];
    gStoploss = PAL::Bid() - gCovers[gDcaLimit-1] - 20;
    PAL::Buy(gVols[gCurLayer], NULL, 0, gStoploss, gTpPrices[gCurLayer], "L"+IntegerToString(gCurLayer));
    gTickets[gCurLayer] = PAL::ResultOrder();
    openStep(gCurLayer, TimeCurrent(), PAL::Ask(), gTpPrices[gCurLayer], gDcaPrices[gCurLayer]);
}

void createDCA()
{
    if (gCurLayer >= gDcaLimit-1) return;

    gCurLayer++;
    gTpPrices[gCurLayer] = PAL::Ask() + gTpDistances[gCurLayer];
    gDcaPrices[gCurLayer] = PAL::Bid() - gDcaDistances[gCurLayer];
    PAL::Buy(gVols[gCurLayer], NULL, 0, gStoploss, gTpPrices[gCurLayer], "L"+IntegerToString(gCurLayer));
    gTickets[gCurLayer] = PAL::ResultOrder();
    openStep(gCurLayer, TimeCurrent(), PAL::Ask(), gTpPrices[gCurLayer], gDcaPrices[gCurLayer]);
    if (gCurLayer >= gDefenseGate) {
        for (int i = 0; i < gCurLayer; i++) {
            PAL::PositionModify(gTickets[i], gStoploss, gTpPrices[gCurLayer]);
            modifyStep(i, gTpPrices[gCurLayer], gStoploss);
        }
    }
}

void DailyReport(string endDate, string startDate)
{
    if (startDate == "") return;
    datetime end = StringToTime(endDate);
    datetime start = StringToTime(startDate);
    HistorySelect(start,end);
    int totalDeals = HistoryDealsTotal();
    if (totalDeals == 0) return;
    double  totalProfit = 0.0;
    string  lowestStep = "-";
    double  profit;
    ulong   ticket;
    string  comment;
    int     dealEntry;
    int     dealCount=0;
    for(int i = 0; i < totalDeals; i++) {
        ticket = HistoryDealGetTicket(i);
        dealEntry = (int)HistoryDealGetInteger(ticket,DEAL_ENTRY);
        if(dealEntry == DEAL_ENTRY_OUT) {
            profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            totalProfit += profit;
        }
        else if (dealEntry == DEAL_ENTRY_IN) {
            comment = HistoryDealGetString(ticket, DEAL_COMMENT);
            if (comment > lowestStep) lowestStep = comment;
            dealCount++;
        }
    }
    
    int file_handle=FileOpen("StrategyTesterReport.csv",FILE_READ|FILE_WRITE|FILE_CSV);
    if(file_handle!=INVALID_HANDLE)
    {
        FileSeek(file_handle,0,SEEK_END);
        FileWrite(file_handle, startDate, dealCount, lowestStep, totalProfit);
        FileClose(file_handle);
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

    int loadsLength = StringLen(DoubleToString(gLoads[gDcaLimit-1], 2));
    int rewardsLength = StringLen(DoubleToString(gRewards[gDcaLimit-1], 2));

    createLabel("objSetup"      , "         THÔNG SỐ HỆ THỐNG"          , 10, 30);
    createLabel("objHeso"       , "●Hệ Số:"+DoubleToString(gMultiplier, 1)             ,  10, 45);
    createLabel("objDefenseGate", "●Defense Gate:"+IntegerToString(gDefenseGate) , 105, 45);
    createLabel("objMaxStep"    , "●Max Step:"+IntegerToString(gDcaLimit)         , 230, 45);
    createLabel("objTableHeader", "STT Lower Upper"  , 10, 60);
    createLabel("objLtCovLoadHeader", fixedText("Lot",5) + " "
                                    + fixedText("Cover", 5) + " "
                                    + fixedText("Load", loadsLength) + " "
                                    + fixedText("Reward", rewardsLength), 120, 60);
    int i;
    for (i = 0; i < gDcaLimit; i++){
        strIndex = IntegerToString(i);
        objIndex            = "objIndex"        + strIndex;
        objLowerStep        = "objLowerStep"    + strIndex;
        objUpperStep        = "objUpperStep"    + strIndex;
        objLtCovLoad        = "objLtCovLoad" + strIndex;
        strLotCoverLoad = fixedText(gVols[i], 2, 5) + " "
                        + fixedText(gCovers[i], 1, 5) + " "
                        + fixedText(gLoads[i], 2, loadsLength) + " "
                        + fixedText(gRewards[i], 2, rewardsLength);
        createLabel(objIndex    , fixedText(strIndex, 3)            ,  10, 75 + 15*i);
        createLabel(objLowerStep, fixedText(gDcaDistances[i], 1, 5) ,  40, 75 + 15*i);
        createLabel(objUpperStep, fixedText(gTpDistances[i], 1, 5)  ,  80, 75 + 15*i);
        createLabel(objLtCovLoad, strLotCoverLoad                   , 120, 75 + 15*i);
    }
    strIndex = IntegerToString(gDefenseGate);
    ObjectSetString(0, "objIndex" + strIndex, OBJPROP_TEXT, fixedText("►"+strIndex,3));
    for (i = gDcaLimit; i < DCA_LIMIT; i++) {
        strIndex     = IntegerToString(i);
        objIndex     = "objIndex"     + strIndex;
        objLowerStep = "objLowerStep" + strIndex;
        objUpperStep = "objUpperStep" + strIndex;
        objLtCovLoad = "objLtCovLoad" + strIndex;
        ObjectDelete(0, objIndex    );
        ObjectDelete(0, objLowerStep);
        ObjectDelete(0, objUpperStep);
        ObjectDelete(0, objLtCovLoad);
    }
    // Feature:
    createLabel("objFeature",       "      TÍNH NĂNG"                                           , 330, 30);
    createLabel("objIsRunning",     "● Chạy BOT:     " +   (gIsRunning ? " [ON]"   : "[OFF]")   , 330, 45);
    createLabel("objIsCreateNewS0", "● Tạo mới L0:  " + (gbCreateNewL0 ? " [TRUE]" : "[FALSE]") , 330, 60);
    createLabel("objBtnCloseAll",   "● Đóng tất cả:[Close]"                                     , 330, 75);
    createLabel("objConfigFile",    "● Conf::" + gSetFile                                       , 330, 90);
    createLabel("objBtnSaveSetup",  "          ---> [Save]"                                     , 330, 105);
}
void dashBoardOnObjClick(string sparam) {
    if (StringFind(sparam, "objIsCreateNewS0") != -1) {
        gbCreateNewL0 = !gbCreateNewL0;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objIsRunning") != -1) {
        gIsRunning = !gIsRunning;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objBtnSaveSetup") != -1) {
        saveSetup();
    }
}
void dashBoardOnObjChange(string sparam) {
    double value;
    if (StringFind(sparam, "objLowerStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objLowerStep", "");
        gDcaDistances[StringToInteger(sparam)] = value;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objUpperStep") != -1) {
        value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        StringReplace(sparam, "objUpperStep", "");
        gTpDistances[StringToInteger(sparam)] = value;
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objHeso") != -1) {
        gMultiplier = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objDefenseGate") != -1) {
        gDefenseGate = (int)StringToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objMaxStep") != -1) {
        gDcaLimit = (int)StringToInteger(ObjectGetString(0, sparam, OBJPROP_TEXT));
        updateSizeOfStep();
    }
    else if (StringFind(sparam, "objConfigFile") != -1) {
        gSetFile = ObjectGetString(0, sparam, OBJPROP_TEXT);
        updateSizeOfStep();
    }
    else {
        return;
    }
}

void saveSetup() {
    int file_handle=FileOpen(gSetFile,FILE_READ|FILE_WRITE|FILE_TXT);
    if(file_handle!=INVALID_HANDLE)
    {
        FileWrite(file_handle,"InpInitVol=" + DoubleToString(InpInitVol));
        FileWrite(file_handle,"InpVolMultiplier=" + DoubleToString(gMultiplier));
        FileWrite(file_handle,"InpTpAllGate=" + IntegerToString(gDefenseGate));
        FileWrite(file_handle,"InpDcaLimit=" + IntegerToString(gDcaLimit));
        for (int i = 0; i < DCA_LIMIT; i++) {
            FileWrite(file_handle,"InpDcaDistances" + IntegerToString(i) + "="+ DoubleToString(gDcaDistances[i]));
            FileWrite(file_handle,"InpTpDistances" + IntegerToString(i) + "="+ DoubleToString(gTpDistances[i]));
        }
        FileClose(file_handle);
        Alert("Writen to:\n" + TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + gSetFile);
    }
}

void modifyStep(int step, double upperPrice, double lowerPrice) {
    string objCurStep   = "objCurStep" + IntegerToString(step);
    string objLowerStep = objCurStep + "Lower";
    string objUpperStep = objCurStep + "Upper";
    ObjectSetDouble(0, objLowerStep, OBJPROP_PRICE, 0, lowerPrice);
    ObjectSetDouble(0, objUpperStep, OBJPROP_PRICE, 0, upperPrice);
}

void closeStep(int step) {
    string objCurStep   = "objCurStep" + IntegerToString(step);
    string objLowerStep = objCurStep + "Lower";
    string objUpperStep = objCurStep + "Upper";
    ObjectSetInteger(0, objCurStep  , OBJPROP_TIME, 0, 0);
    ObjectSetInteger(0, objLowerStep, OBJPROP_TIME, 0, 0);
    ObjectSetInteger(0, objUpperStep, OBJPROP_TIME, 0, 0);
}
void openStep(int step, datetime curTime, double curPrice, double upperPrice, double lowerPrice)
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
}
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////