#property copyright "Timmy"
#property link      "https://www.mql5.com/en/users/thanh01"
#property icon      "T-black.ico"
#property indicator_chart_window
#property indicator_plots 0

#define APP_TAG "*MTF Candles"

input int             InpCandleNumber = 100;
input ENUM_TIMEFRAMES InpTimeFrame  = PERIOD_D1;
input color           InpColorUp    = Gainsboro;
input color           InpColorDn    = Thistle;
input bool            InpFill       = true;
input bool            InpLiveCandle = true;

double gLiveHi, gLiveLo, gLiveOp, gLiveCl;
datetime gLivedtOp;
datetime gLivedtCl;
bool gInit = false;

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
    if (InpLiveCandle) {
        gLiveHi   = iHigh(_Symbol, InpTimeFrame, 0);
        gLiveLo   = iLow(_Symbol, InpTimeFrame, 0);
        gLiveOp   = iOpen(_Symbol, InpTimeFrame, 0);
        gLiveCl   = iClose(_Symbol, InpTimeFrame, 0);
        gLivedtOp = iTime(_Symbol, InpTimeFrame, 0);
        gLivedtCl = gLivedtOp + PeriodSeconds(InpTimeFrame);
        updateLiveCandle(gLiveHi, gLiveLo, gLiveOp, gLiveCl, gLivedtOp, gLivedtCl);
    }
    if (gInit == false && prev_calculated > 0 && prev_calculated == rates_total) {
        drawFixedCandle();
    }
    return rates_total;
}

void drawFixedCandle(){
    double Hi, Lo, Op, Cl;
    datetime dtOp;
    datetime dtCl;
    gCandleIdx = 0;
    dtOp = iTime(_Symbol, InpTimeFrame, InpCandleNumber);
    if (dtOp == 0) return;
    if (InpTimeFrame < PERIOD_W1) {
        for (int barIdx = InpCandleNumber; barIdx > 0; barIdx--) {
            dtOp = iTime(_Symbol, InpTimeFrame, barIdx);
            if (TimeDayOfWeekMQL4(dtOp) == 0) continue; 
            Hi = iHigh(_Symbol, InpTimeFrame, barIdx);
            Lo = iLow(_Symbol, InpTimeFrame, barIdx);
            Op = iOpen(_Symbol, InpTimeFrame, barIdx);
            Cl = iClose(_Symbol, InpTimeFrame, barIdx);
            dtCl = dtOp + PeriodSeconds(InpTimeFrame) - PeriodSeconds(_Period);
            drawingCandle(Hi, Lo, Op, Cl, dtOp, dtCl);
        }
    }
    else {
        for (int barIdx = InpCandleNumber; barIdx > 0; barIdx--) {
            dtOp = iTime(_Symbol, InpTimeFrame, barIdx);
            Hi = iHigh(_Symbol, InpTimeFrame, barIdx);
            Lo = iLow(_Symbol, InpTimeFrame, barIdx);
            Op = iOpen(_Symbol, InpTimeFrame, barIdx);
            Cl = iClose(_Symbol, InpTimeFrame, barIdx);
            dtCl = dtOp + PeriodSeconds(InpTimeFrame) - PeriodSeconds(_Period);
            drawingCandle(Hi, Lo, Op, Cl, dtOp, dtCl);
        }
    }
    gInit = true;
}


int gCandleIdx = 0;
void drawingCandle(double hi, double lo, double op, double cl, datetime dtOp, datetime dtCl)
{
    string candleTag = APP_TAG + IntegerToString(InpTimeFrame) + IntegerToString(gCandleIdx++);
    datetime wichTime = (dtOp+dtCl)/2;
    ObjectCreate(0,     candleTag + "-Body", OBJ_RECTANGLE, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_FILL, InpFill);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 0, dtOp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 1, dtCl);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, op);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, cl);
    ObjectSetString(0,  candleTag + "-Body", OBJPROP_TOOLTIP, "\n");

    ObjectCreate(0,     candleTag + "-Wick1", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, hi);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, op>cl ? op : cl);
    ObjectSetString(0,  candleTag + "-Wick1", OBJPROP_TOOLTIP, "\n");

    ObjectCreate(0,     candleTag + "-Wick2", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, lo);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, op>cl ? cl : op);
    ObjectSetString(0,  candleTag + "-Wick2", OBJPROP_TOOLTIP, "\n");
}

void hideUnusedCandle ()
{
    string candleTag;
    while (gCandleIdx < 1000)
    {
        candleTag = APP_TAG + IntegerToString(InpTimeFrame) + IntegerToString(gCandleIdx++);
        ObjectDelete(0, candleTag + "-Body" );
        ObjectDelete(0, candleTag + "-Wick1");
        ObjectDelete(0, candleTag + "-Wick2");
    }
}

void updateLiveCandle(double hi, double lo, double op, double cl, datetime dtOp, datetime dtCl)
{
    string candleTag = APP_TAG + IntegerToString(InpTimeFrame) + "Live";
    if (InpTimeFrame <= _Period || InpLiveCandle == false) {
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
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_FILL, InpFill);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 0, dtOp);
    ObjectSetInteger(0, candleTag + "-Body", OBJPROP_TIME, 1, dtCl);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 0, op);
    ObjectSetDouble(0,  candleTag + "-Body", OBJPROP_PRICE, 1, cl);
    ObjectSetString(0,  candleTag + "-Body", OBJPROP_TOOLTIP, "\n");

    ObjectCreate(0,     candleTag + "-Wick1", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick1", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 0, hi);
    ObjectSetDouble(0,  candleTag + "-Wick1", OBJPROP_PRICE, 1, op>cl ? op : cl);
    ObjectSetString(0,  candleTag + "-Wick1", OBJPROP_TOOLTIP, "\n");

    ObjectCreate(0,     candleTag + "-Wick2", OBJ_TREND, 0, 0, 0);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_BACK, true);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_RAY, false);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_COLOR, op>cl ? InpColorDn : InpColorUp);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 0, wichTime);
    ObjectSetInteger(0, candleTag + "-Wick2", OBJPROP_TIME, 1, wichTime);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 0, lo);
    ObjectSetDouble(0,  candleTag + "-Wick2", OBJPROP_PRICE, 1, op>cl ? cl : op);
    ObjectSetString(0,  candleTag + "-Wick2", OBJPROP_TOOLTIP, "\n");
}

int TimeDayOfWeekMQL4(datetime date)
{
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_week);
}
