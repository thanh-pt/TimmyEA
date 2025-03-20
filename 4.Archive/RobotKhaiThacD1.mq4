#include "PAL.mqh"


input double    InpQuangGia = 3;
input int       InpSoLuongLenh = 30;

int OnInit()
{
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    return INIT_SUCCEEDED;
}


#define NOTRADE  0
#define TANCONG  1
#define PHONGTHU 2

int gState = 0;

string gPreDay;
string gCurDay;
double gOpenPrice;
void OnTick() {
    // Phase 0 - Kiểm tra ngày - Lệnh tồn
    gCurDay = TimeToString(TimeCurrent(), TIME_DATE);
    if (gCurDay != gPreDay) {
        gOpenPrice = iOpen(_Symbol, PERIOD_D1, 0);
    }

    // Phase 1 - Tấn công = L0
    if (PAL::Bid() > gOpenPrice){
        if (gState == NOTRADE || gState == TANCONG) {
            //
        }
    }
    // Phase 2 - Gỡ lệnh treo L0
    else {
        //
    }
}