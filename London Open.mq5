#property copyright "Timmy"
#property link "https://www.mql5.com/en/users/thanh01"
#property icon "T-black.ico"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   0


input int   InpLondonOpenHour = 10;
string      gStrDay;
MqlDateTime gdtStruct;
datetime    gLdOpenTime;
datetime    gLdCloseTime;
datetime    gLdEodTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
    const long &lparam,
    const double &dparam,
    const string &sparam)
{
//---
    if (id == CHARTEVENT_KEYDOWN && lparam == 'L') {
        int firstBarIdx = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
        int barCount = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
        TimeToStruct(iTime(_Symbol, PERIOD_CURRENT, firstBarIdx-barCount/2), gdtStruct);
        gdtStruct.hour = InpLondonOpenHour;
        gdtStruct.min = 0;
        gdtStruct.sec = 0;
        gLdOpenTime = StructToTime(gdtStruct);
        gdtStruct.hour = InpLondonOpenHour + 4;
        gLdCloseTime = StructToTime(gdtStruct);
        gdtStruct.hour = InpLondonOpenHour + 9;
        gLdEodTime = StructToTime(gdtStruct);
        int ldOpenIdx = iBarShift(_Symbol, PERIOD_CURRENT, gLdOpenTime);
        int ldCloseIdx = iBarShift(_Symbol, PERIOD_CURRENT, gLdCloseTime);
        double op = iOpen(_Symbol, PERIOD_CURRENT, ldOpenIdx);
        double hi = op;
        double lo = op;
        for (int i = ldOpenIdx; i >= ldCloseIdx; i--) {
            if (iHigh(_Symbol, PERIOD_CURRENT, i) > hi) hi = iHigh(_Symbol, PERIOD_CURRENT, i);
            if (iLow(_Symbol, PERIOD_CURRENT, i) < lo) lo = iLow(_Symbol, PERIOD_CURRENT, i);
        }
        gStrDay = TimeToString(gLdOpenTime, TIME_DATE);
        ObjectCreate(0,     gStrDay + "-LdO", OBJ_TREND, 0, 0, 0);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_RAY, false);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_BACK, true);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_COLOR, clrMidnightBlue);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_STYLE, STYLE_DASH);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_TIME, 0, gLdOpenTime);
        ObjectSetInteger(0, gStrDay + "-LdO", OBJPROP_TIME, 1, gLdCloseTime);
        ObjectSetDouble(0,  gStrDay + "-LdO", OBJPROP_PRICE, 0, op);
        ObjectSetDouble(0,  gStrDay + "-LdO", OBJPROP_PRICE, 1, op);
        ObjectCreate(0,     gStrDay + "-LdH", OBJ_TREND, 0, 0, 0);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_RAY, false);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_BACK, true);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_COLOR, clrDarkGreen);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_STYLE, STYLE_DOT);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_TIME, 0, gLdOpenTime);
        ObjectSetInteger(0, gStrDay + "-LdH", OBJPROP_TIME, 1, gLdCloseTime);
        ObjectSetDouble(0,  gStrDay + "-LdH", OBJPROP_PRICE, 0, hi);
        ObjectSetDouble(0,  gStrDay + "-LdH", OBJPROP_PRICE, 1, hi);
        ObjectCreate(0,     gStrDay + "-LdL", OBJ_TREND, 0, 0, 0);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_RAY, false);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_BACK, true);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_STYLE, STYLE_DOT);
        ObjectSetDouble(0,  gStrDay + "-LdL", OBJPROP_PRICE, 0, lo);
        ObjectSetDouble(0,  gStrDay + "-LdL", OBJPROP_PRICE, 1, lo);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_TIME, 0, gLdOpenTime);
        ObjectSetInteger(0, gStrDay + "-LdL", OBJPROP_TIME, 1, gLdCloseTime);
        ObjectCreate(0,     gStrDay + "-EOD", OBJ_VLINE, 0, 0, 0);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_RAY_RIGHT, true);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_RAY_LEFT, true);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_BACK, true);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_STYLE, STYLE_DOT);
        ObjectSetDouble(0,  gStrDay + "-EOD", OBJPROP_PRICE, 0, hi);
        ObjectSetDouble(0,  gStrDay + "-EOD", OBJPROP_PRICE, 1, lo);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_TIME, 0, gLdEodTime);
        ObjectSetInteger(0, gStrDay + "-EOD", OBJPROP_TIME, 1, gLdEodTime);
        ObjectSetString(0,  gStrDay + "-EOD", OBJPROP_TEXT, "EOD");
    }

}
