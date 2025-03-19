#property copyright "Timmy"
#property link "https://www.mql5.com/en/users/thanh01"
#property icon "T-black.ico"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   0

input double InpPriceStep = 9;
input bool   InpRay = false;
datetime    gDatetime;
datetime    gPreDatetime;
datetime    gEodTime;
bool        gInit = false;

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
    gDatetime = iTime(_Symbol, PERIOD_D1, 0);
    if (gDatetime - TimeCurrent() > PeriodSeconds(PERIOD_D1)) return rates_total;
    if (gDatetime != gPreDatetime) {
        gPreDatetime = gDatetime;
        gEodTime = gDatetime + PeriodSeconds(PERIOD_D1);
        double op = iOpen(_Symbol, PERIOD_D1, 0);
        string objFibStep = "*TODAY" + "-FbStep";
        ObjectCreate(0,     objFibStep, OBJ_FIBO, 0, 0, 0);
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY_LEFT, InpRay);
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY_RIGHT, InpRay);
        ObjectSetInteger(0, objFibStep, OBJPROP_BACK, true);
        ObjectSetInteger(0, objFibStep, OBJPROP_COLOR, clrNONE);
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 0, TimeCurrent() + PeriodSeconds(_Period));
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 1, gEodTime);
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 0, op+InpPriceStep);
        ObjectSetDouble(0,  objFibStep, OBJPROP_PRICE, 1, op);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELS, 32);
        int i = 0;
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 2);
        ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrGoldenrod);
        ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
        ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, _Digits) + "("+DoubleToString(InpPriceStep,1)+")");
        for (i = 1; i < 16; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrBlack);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*i, _Digits));
        }
        for (i = 16; i < 32; i++) {
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELSTYLE, i, STYLE_SOLID);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELWIDTH, i, 1);
            ObjectSetInteger(0, objFibStep, OBJPROP_LEVELCOLOR, i, clrMidnightBlue);
            ObjectSetDouble(0,  objFibStep, OBJPROP_LEVELVALUE, i, 15-i);
            ObjectSetString(0,  objFibStep, OBJPROP_LEVELTEXT,  i, DoubleToString(op+InpPriceStep*(15-i), _Digits));
        }
    }
    else if (rates_total != prev_calculated) {
        string objFibStep = "*TODAY" + "-FbStep";
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY_LEFT, InpRay);
        ObjectSetInteger(0, objFibStep, OBJPROP_RAY_RIGHT, InpRay);
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 0, TimeCurrent() + PeriodSeconds(_Period));
        ObjectSetInteger(0, objFibStep, OBJPROP_TIME, 1, gEodTime);
    }
    return(rates_total);
}
//+------------------------------------------------------------------+