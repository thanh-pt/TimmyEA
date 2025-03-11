
#define APP_TAG "TRADING_LADDER"

string objLineL0 = APP_TAG+"objLineL0";
string objLineL1 = APP_TAG+"objLineL1";
string objLineL2 = APP_TAG+"objLineL2";
string objLineL3 = APP_TAG+"objLineL3";
string objLineSL = APP_TAG+"objLineSL";

string objTextL0 = APP_TAG+"objTextL0";
string objTextL1 = APP_TAG+"objTextL1";
string objTextL2 = APP_TAG+"objTextL2";
string objTextL3 = APP_TAG+"objTextL3";
string objTextSL = APP_TAG+"objTextSL";

string objArrowL1 = APP_TAG+"objArrowL1";
string objArrowL2 = APP_TAG+"objArrowL2";
string objArrowL3 = APP_TAG+"objArrowL3";

double priceL0 = 0;
double priceL1 = 0;
double priceL2 = 0;
double priceL3 = 0;
double priceSL = 0;

double lotL0 = 0.01;
double lotL1 = 0.01;
double lotL2 = 0.01;
double lotL3 = 0.01;

datetime time0;
datetime time1;
datetime time2;

bool    gIndiOn = true;
double  gContractSize = 100;//SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double& price[] ){return rates_total;}

int OnInit() {
/*
    time0 = iTime(_Symbol, PERIOD_CURRENT, 0);
    double quangGia = (iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1)) / 4;
    priceL0  = iOpen(_Symbol, PERIOD_CURRENT, 0);
    priceL1  = priceL0 + quangGia * 1;
    priceL2  = priceL0 + quangGia * 2;
    priceL3  = priceL0 + quangGia * 3;
    priceSL  = priceL0 + quangGia * 5;
    createObj();
    refreshLadder();
    */
    return INIT_SUCCEEDED;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {

    if (id == CHARTEVENT_OBJECT_DRAG || id == CHARTEVENT_OBJECT_CLICK) {
        if (StringFind(sparam, APP_TAG) != -1) {
            priceL0 = ObjectGetDouble(0, objLineL0, OBJPROP_PRICE, 0);
            priceL1 = ObjectGetDouble(0, objLineL1, OBJPROP_PRICE, 0);
            priceL2 = ObjectGetDouble(0, objLineL2, OBJPROP_PRICE, 0);
            priceL3 = ObjectGetDouble(0, objLineL3, OBJPROP_PRICE, 0);
            priceSL = ObjectGetDouble(0, objLineSL, OBJPROP_PRICE, 0);
            time0 = ObjectGetInteger(0, objLineL0, OBJPROP_TIME, 0);
            refreshLadder();
        }
    }
    else if (id == CHARTEVENT_OBJECT_CHANGE && (StringFind(sparam, APP_TAG+"objTextL") != -1)){
        double value = StringToDouble(ObjectGetString(0, sparam, OBJPROP_TEXT));

        if (sparam == objTextL0) lotL0 = value;
        else if (sparam == objTextL1) lotL1 = value;
        else if (sparam == objTextL2) lotL2 = value;
        else if (sparam == objTextL3) lotL3 = value;
        refreshLadder();
    }
    else if (id == CHARTEVENT_KEYDOWN && lparam == 'L') {
        gIndiOn = !gIndiOn;
        if (gIndiOn == false) {
            time0 = 0;
        }
        else {
            time0 = iTime(_Symbol, PERIOD_CURRENT, 0);
            double quangGia = (iHigh(_Symbol, PERIOD_CURRENT, 1) - iLow(_Symbol, PERIOD_CURRENT, 1)) / 4;
            priceL0  = iOpen(_Symbol, PERIOD_CURRENT, 0);
            priceL1  = priceL0 + quangGia * 1;
            priceL2  = priceL0 + quangGia * 2;
            priceL3  = priceL0 + quangGia * 3;
            priceSL  = priceL0 + quangGia * 5;
            createObj();
        }
        refreshLadder();
    }
}

void refreshLadder()
{
    time1 = time0+5*PeriodSeconds(_Period);
    time2 = time0+10*PeriodSeconds(_Period);
    ObjectSetInteger(0, objLineL0, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objLineL0, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objLineL0, OBJPROP_PRICE, 0, priceL0);
    ObjectSetDouble(0,  objLineL0, OBJPROP_PRICE, 1, priceL0);
    ObjectSetInteger(0, objLineL1, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objLineL1, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objLineL1, OBJPROP_PRICE, 0, priceL1);
    ObjectSetDouble(0,  objLineL1, OBJPROP_PRICE, 1, priceL1);
    ObjectSetInteger(0, objLineL2, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objLineL2, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objLineL2, OBJPROP_PRICE, 0, priceL2);
    ObjectSetDouble(0,  objLineL2, OBJPROP_PRICE, 1, priceL2);
    ObjectSetInteger(0, objLineL3, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objLineL3, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objLineL3, OBJPROP_PRICE, 0, priceL3);
    ObjectSetDouble(0,  objLineL3, OBJPROP_PRICE, 1, priceL3);
    ObjectSetInteger(0, objLineSL, OBJPROP_TIME, 0, time0);
    ObjectSetInteger(0, objLineSL, OBJPROP_TIME, 1, time1);
    ObjectSetDouble(0,  objLineSL, OBJPROP_PRICE, 0, priceSL);
    ObjectSetDouble(0,  objLineSL, OBJPROP_PRICE, 1, priceSL);

    ObjectSetInteger(0, objArrowL1, OBJPROP_TIME, 0, time1);
    ObjectSetInteger(0, objArrowL1, OBJPROP_TIME, 1, time2);
    ObjectSetDouble(0,  objArrowL1, OBJPROP_PRICE, 0, priceL1);
    ObjectSetInteger(0, objArrowL2, OBJPROP_TIME, 0, time1);
    ObjectSetInteger(0, objArrowL2, OBJPROP_TIME, 1, time2);
    ObjectSetDouble(0,  objArrowL2, OBJPROP_PRICE, 0, priceL2);
    ObjectSetInteger(0, objArrowL3, OBJPROP_TIME, 0, time1);
    ObjectSetInteger(0, objArrowL3, OBJPROP_TIME, 1, time2);
    ObjectSetDouble(0,  objArrowL3, OBJPROP_PRICE, 0, priceL3);

    ObjectSetInteger(0, objTextL0, OBJPROP_TIME, 0, time1);
    ObjectSetDouble(0,  objTextL0, OBJPROP_PRICE, 0, priceL0);
    ObjectSetInteger(0, objTextL1, OBJPROP_TIME, 0, time1);
    ObjectSetDouble(0,  objTextL1, OBJPROP_PRICE, 0, priceL1);
    ObjectSetInteger(0, objTextL2, OBJPROP_TIME, 0, time1);
    ObjectSetDouble(0,  objTextL2, OBJPROP_PRICE, 0, priceL2);
    ObjectSetInteger(0, objTextL3, OBJPROP_TIME, 0, time1);
    ObjectSetDouble(0,  objTextL3, OBJPROP_PRICE, 0, priceL3);
    ObjectSetInteger(0, objTextSL, OBJPROP_TIME, 0, time1);
    ObjectSetDouble(0,  objTextSL, OBJPROP_PRICE, 0, priceSL);


    string textL0 = "L0 " + DoubleToString(lotL0,2) + " Target!!!";
    string textL1 = "L1 "        + DoubleToString(lotL1,2) + " " + DoubleToString(MathAbs(priceL1-priceL0),1);
    string textL2 = "L2 "        + DoubleToString(lotL2,2) + " " + DoubleToString(MathAbs(priceL2-priceL1),1);
    string textL3 = "L3 "        + DoubleToString(lotL3,2) + " " + DoubleToString(MathAbs(priceL3-priceL2),1);
    string textSL = "SL -";
    double totalLoss = lotL0 * MathAbs(priceL0-priceSL) * gContractSize;
    totalLoss += lotL1 * MathAbs(priceL1-priceSL) * gContractSize;
    totalLoss += lotL2 * MathAbs(priceL2-priceSL) * gContractSize;
    totalLoss += lotL3 * MathAbs(priceL3-priceSL) * gContractSize;
    textSL += DoubleToString(totalLoss, 2) + "$" + " " + DoubleToString(MathAbs(priceL0-priceSL),1);

    double priceE1 = (lotL0 * priceL0 + lotL1 * priceL1) / (lotL0 + lotL1);
    double priceE2 = (lotL0 * priceL0 + lotL1 * priceL1 + lotL2 * priceL2) / (lotL0 + lotL1 + lotL2);
    double priceE3 = (lotL0 * priceL0 + lotL1 * priceL1 + lotL2 * priceL2 + lotL3 * priceL3) / (lotL0 + lotL1 + lotL2 + lotL3);
    
    ObjectSetDouble(0,  objArrowL1, OBJPROP_PRICE, 1, priceE1);
    ObjectSetDouble(0,  objArrowL2, OBJPROP_PRICE, 1, priceE2);
    ObjectSetDouble(0,  objArrowL3, OBJPROP_PRICE, 1, priceE3);

    ObjectSetString(0, objTextL0, OBJPROP_TEXT, textL0);
    ObjectSetString(0, objTextL1, OBJPROP_TEXT, textL1);
    ObjectSetString(0, objTextL2, OBJPROP_TEXT, textL2);
    ObjectSetString(0, objTextL3, OBJPROP_TEXT, textL3);
    ObjectSetString(0, objTextSL, OBJPROP_TEXT, textSL);
    
    ChartRedraw();
}

void createObj(){
    ObjectCreate(0,     objLineL0, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objLineL0, OBJPROP_RAY, false);
    ObjectSetInteger(0, objLineL0, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLineL0, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLineL0, OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, objLineL0, OBJPROP_WIDTH, 2);

    ObjectCreate(0,     objLineL1, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objLineL1, OBJPROP_RAY, false);
    ObjectSetInteger(0, objLineL1, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLineL1, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLineL1, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objLineL1, OBJPROP_WIDTH, 2);

    ObjectCreate(0,     objLineL2, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objLineL2, OBJPROP_RAY, false);
    ObjectSetInteger(0, objLineL2, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLineL2, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLineL2, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objLineL2, OBJPROP_WIDTH, 2);

    ObjectCreate(0,     objLineL3, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objLineL3, OBJPROP_RAY, false);
    ObjectSetInteger(0, objLineL3, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLineL3, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLineL3, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objLineL3, OBJPROP_WIDTH, 2);

    ObjectCreate(0,     objLineSL, OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, objLineSL, OBJPROP_RAY, false);
    ObjectSetInteger(0, objLineSL, OBJPROP_BACK, false);
    ObjectSetInteger(0, objLineSL, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objLineSL, OBJPROP_COLOR, clrCrimson);
    ObjectSetInteger(0, objLineSL, OBJPROP_WIDTH, 2);

    ObjectCreate(0,     objTextL0, OBJ_TEXT, 0, 0, 0);
    ObjectSetInteger(0, objTextL0, OBJPROP_BACK, false);
    ObjectSetInteger(0, objTextL0, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objTextL0, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objTextL0, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0,  objTextL0, OBJPROP_FONT, "Consolas");

    ObjectSetInteger(0, objTextL0, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectCreate(0,     objTextL1, OBJ_TEXT, 0, 0, 0);
    ObjectSetInteger(0, objTextL1, OBJPROP_BACK, false);
    ObjectSetInteger(0, objTextL1, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objTextL1, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objTextL1, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0,  objTextL1, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, objTextL1, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);

    ObjectCreate(0,     objTextL2, OBJ_TEXT, 0, 0, 0);
    ObjectSetInteger(0, objTextL2, OBJPROP_BACK, false);
    ObjectSetInteger(0, objTextL2, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objTextL2, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objTextL2, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0,  objTextL2, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, objTextL2, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);

    ObjectCreate(0,     objTextL3, OBJ_TEXT, 0, 0, 0);
    ObjectSetInteger(0, objTextL3, OBJPROP_BACK, false);
    ObjectSetInteger(0, objTextL3, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objTextL3, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objTextL3, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0,  objTextL3, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, objTextL3, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);

    ObjectCreate(0,     objTextSL, OBJ_TEXT, 0, 0, 0);
    ObjectSetInteger(0, objTextSL, OBJPROP_BACK, false);
    ObjectSetInteger(0, objTextSL, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objTextSL, OBJPROP_COLOR, clrMidnightBlue);
    ObjectSetInteger(0, objTextSL, OBJPROP_FONTSIZE, 9);
    ObjectSetString(0,  objTextSL, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, objTextSL, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    
    ObjectCreate(0,     objArrowL1, OBJ_ARROWED_LINE, 0, 0, 0);
    ObjectSetInteger(0, objArrowL1, OBJPROP_RAY, false);
    ObjectSetInteger(0, objArrowL1, OBJPROP_BACK, false);
    ObjectSetInteger(0, objArrowL1, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objArrowL1, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, objArrowL1, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objArrowL1, OBJPROP_STYLE, 2);

    ObjectCreate(0,     objArrowL2, OBJ_ARROWED_LINE, 0, 0, 0);
    ObjectSetInteger(0, objArrowL2, OBJPROP_RAY, false);
    ObjectSetInteger(0, objArrowL2, OBJPROP_BACK, false);
    ObjectSetInteger(0, objArrowL2, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objArrowL2, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, objArrowL2, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objArrowL2, OBJPROP_STYLE, 2);
    
    ObjectCreate(0,     objArrowL3, OBJ_ARROWED_LINE, 0, 0, 0);
    ObjectSetInteger(0, objArrowL3, OBJPROP_RAY, false);
    ObjectSetInteger(0, objArrowL3, OBJPROP_BACK, false);
    ObjectSetInteger(0, objArrowL3, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, objArrowL3, OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, objArrowL3, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, objArrowL3, OBJPROP_STYLE, 2);
}