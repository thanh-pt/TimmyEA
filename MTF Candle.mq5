#property copyright "Timmy"
#property link      "https://www.mql5.com/en/users/thanh01"
#property icon      "T-black.ico"
#property indicator_chart_window
#property indicator_plots 0

#define APP_TAG "Static*MTF Candles"

enum eCandleType{
    eBackground,    // Background
    eBorder,        // Boder
};

// input eCandleType     InpCandleType = eBackground; // TODO
input ENUM_TIMEFRAMES InpTimeFrame  = PERIOD_D1;
input color           InpColorUp    = Gainsboro;
input color           InpColorDn    = Thistle;
input string          InpHotkey     = "D";

bool gIndiOn = true;
double gLiveHi, gLiveLo, gLiveOp, gLiveCl;
datetime gLivedtOp;
datetime gLivedtCl;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    // Update live candle
    gLiveHi = iHigh(_Symbol, InpTimeFrame, 0);
    gLiveLo = iLow(_Symbol, InpTimeFrame, 0);
    gLiveOp = iOpen(_Symbol, InpTimeFrame, 0);
    gLiveCl = iClose(_Symbol, InpTimeFrame, 0);
    gLivedtOp = iTime(_Symbol, InpTimeFrame, 0);
    gLivedtCl = gLivedtOp + PeriodSeconds(InpTimeFrame);
    updateLiveCandle(gLiveHi, gLiveLo, gLiveOp, gLiveCl, gLivedtOp, gLivedtCl);
    return rates_total;
}

string gCurDate = "";
string gPreDate = "";
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_KEYDOWN && lparam == InpHotkey[0]) {
        gIndiOn = !gIndiOn;
        updateLiveCandle(gLiveHi, gLiveLo, gLiveOp, gLiveCl, gLivedtOp, gLivedtCl);
    }
    if (InpTimeFrame <= _Period || gIndiOn == false) {
        gCandleIdx = 0;
        gPreDate = "";
        hideUnusedCandle();
        return;
    }
    // Update Death Candles
    int fstVisibleBar   = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
    int lstVisibleBar   = fstVisibleBar - (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
    if (lstVisibleBar < 0) lstVisibleBar = 0;
    datetime dt         = iTime(_Symbol, PERIOD_CURRENT, fstVisibleBar);
    datetime dtEnd      = iTime(_Symbol, PERIOD_CURRENT, lstVisibleBar);
    gCurDate            = TimeToString(dt, TIME_DATE);
    if (gCurDate != gPreDate) {
        gPreDate = gCurDate;
        int barIdx;
        double Hi, Lo, Op, Cl;
        datetime dtOp;
        datetime dtCl;
        gCandleIdx = 0;
        while (true)
        {
            barIdx = iBarShift(_Symbol, InpTimeFrame, dt, true);
            if (dt > dtEnd) break;
            if (barIdx > 0){
                Hi = iHigh(_Symbol, InpTimeFrame, barIdx);
                Lo = iLow(_Symbol, InpTimeFrame, barIdx);
                Op = iOpen(_Symbol, InpTimeFrame, barIdx);
                Cl = iClose(_Symbol, InpTimeFrame, barIdx);
                dtOp = iTime(_Symbol, InpTimeFrame, barIdx);
                dtCl = dtOp + PeriodSeconds(InpTimeFrame);
                drawingCandle(Hi, Lo, Op, Cl, dtOp, dtCl);
            }
            dt += PeriodSeconds(InpTimeFrame);
        }
        hideUnusedCandle();
    }
}


int gCandleIdx = 0;
void drawingCandle(double hi, double lo, double op, double cl, datetime dtOp, datetime dtCl)
{
    string candleTag = APP_TAG + IntegerToString(gCandleIdx++);
    datetime wichTime = (dtOp+dtCl)/2;
    ObjectCreate(0,     candleTag + "-Body", OBJ_RECTANGLE, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_FILL, true);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 0, dtOp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 1, dtCl);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, op);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, cl);

    ObjectCreate(0,     candleTag + "-Wick1", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, hi);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, op>cl ? op : cl);

    ObjectCreate(0,     candleTag + "-Wick2", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, lo);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, op>cl ? cl : op);
}

void hideUnusedCandle ()
{
    string candleTag;
    while (gCandleIdx < 1000)
    {
        candleTag = APP_TAG + IntegerToString(gCandleIdx++);
        ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, 0);
        ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, 0);
        ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, 0);
    }
}

void updateLiveCandle(double hi, double lo, double op, double cl, datetime dtOp, datetime dtCl)
{
    string candleTag = APP_TAG + "Live";
    if (InpTimeFrame <= _Period || gIndiOn == false) {
        ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, 0);
        ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, 0);
        ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, 0);
        ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, 0);
        return;
    }
    datetime wichTime = (dtOp+dtCl)/2;
    ObjectCreate(0,     candleTag + "-Body", OBJ_RECTANGLE, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_FILL, true);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 0, dtOp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 1, dtCl);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, op);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, cl);

    ObjectCreate(0,     candleTag + "-Wick1", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, hi);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, op>cl ? op : cl);

    ObjectCreate(0,     candleTag + "-Wick2", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, lo);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, op>cl ? cl : op);
}