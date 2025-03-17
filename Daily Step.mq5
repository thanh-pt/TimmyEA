#property copyright "Timmy"
#property link "https://www.mql5.com/en/users/thanh01"
#property icon "T-black.ico"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   0

input double InpPriceStep = 10;
string      gStrDay;
MqlDateTime gdtStruct;
datetime    gDatetime;

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
    if (rates_total != prev_calculated) {
        gDatetime = iTime(_Symbol, PERIOD_CURRENT, 0);
        double op = iOpen(_Symbol, PERIOD_D1, 0);
        string objFibStep = "*TODAY" + "-FbStep";
        double step = 10;
        ObjectCreate(0,     objFibStep, OBJ_FIBO, 0, 0, 0);
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY, false);
        ObjectSetInteger(0, objFibStep, OBJPROP_BACK, true);
        ObjectSetInteger(0, objFibStep, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 0, gDatetime + 5*PeriodSeconds(_Period));
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 1, iTime(_Symbol, PERIOD_D1, 0) + PeriodSeconds(PERIOD_D1));
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 0, op+InpPriceStep);
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 1, op);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELS, 32);
        int i = 0;
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 2);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrGoldenrod);
        ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
        ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, 0));
        for (i = 1; i < 16; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrRed);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, 0));
        }
        for (i = 16; i < 32; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrGreen);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, 15-i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*(15-i), 0));
        }
    }
    return(rates_total);
}
//+------------------------------------------------------------------+

void OnChartEvent(const int id,
    const long &lparam,
    const double &dparam,
    const string &sparam)
{
//---
    if (id == CHARTEVENT_KEYDOWN && lparam == 'K') {
        int fstBarIdx = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
        int lstBarIdx = fstBarIdx - (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
        if (lstBarIdx < 0) lstBarIdx = 0;
        gDatetime = iTime(_Symbol, PERIOD_CURRENT, lstBarIdx);
        TimeToStruct(gDatetime, gdtStruct);
        gdtStruct.hour = 0;
        gdtStruct.min  = 0;
        gdtStruct.sec  = 0;

        int d1Idx = iBarShift(_Symbol, PERIOD_D1, gDatetime);
        gDatetime = StructToTime(gdtStruct);
        gStrDay = TimeToString(gDatetime, TIME_DATE);
        double op = iOpen(_Symbol, PERIOD_D1, d1Idx);
        string objFibStep = gStrDay + "-FbStep";
        ObjectCreate(0,     objFibStep, OBJ_FIBO, 0, 0, 0);
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY, false);
        ObjectSetInteger(0, objFibStep, OBJPROP_BACK, true);
        ObjectSetInteger(0, objFibStep, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 0, gDatetime);
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 1, gDatetime + PeriodSeconds(_Period));
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 0, op+InpPriceStep);
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 1, op);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELS, 32);
        int i = 0;
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 2);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrGoldenrod);
        ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
        ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, 0));
        for (i = 1; i < 16; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrRed);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, 0));
        }
        for (i = 16; i < 32; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrGreen);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, 15-i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*(15-i), 0));
        }
    }
}
