/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/

#define APP_TAG "EA_Bắt đáy"

#resource "PerrythePlatypusBG.bmp"

enum eStage {
    eNoTrade = 0,
    eL1      = 1,
    eL2      = 2,
    eL3      = 3,
    eL4      = 4,
    eL5      = 5,
    eL6      = 6,
};
double gprice1 = 0.0;
double gprice2 = 0.0;
double gprice3 = 0.0;
double gprice4 = 0.0;
double gprice5 = 0.0;
double gprice6 = 0.0;

double gpriceE1 = 0.0;
double gpriceE2 = 0.0;
double gpriceE3 = 0.0;
double gpriceE4 = 0.0;
double gpriceE5 = 0.0;
double gpriceE6 = 0.0;

input double InpStp1 =  10;
input double InpStp2 =   7;
input double InpStp3 = 0.5;
input double InpStp4 = 0.5;
input double InpStp5 = 0.5;
input double InpStp6 = 0.5;

input double InpE1 = 10;
input double InpE2 =  5;
input double InpE3 =  1;
input double InpE4 =  1;
input double InpE5 =  1;
input double InpE6 =  1;

input double InpSz1 = 0.01;
input double InpSz2 = 0.02;
      double InpSz3 = 0.00;
      double InpSz4 = 0.00;
      double InpSz5 = 0.00;
      double InpSz6 = 0.00;

bool gReadyStage = false;

int OnInit() {
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);

    InpSz3 = 1.7*(InpSz1*(InpStp2+InpStp3                        ) + InpSz2*(InpStp3                        )                                                                                 ) / InpE3  - (InpSz1 + InpSz2                            );
    InpSz4 = 1.7*(InpSz1*(InpStp2+InpStp3+InpStp4                ) + InpSz2*(InpStp3+InpStp4                ) + InpSz3*(InpStp4                )                                              ) / InpE4  - (InpSz1 + InpSz2 + InpSz3                   );
    InpSz5 = 1.7*(InpSz1*(InpStp2+InpStp3+InpStp4+InpStp5        ) + InpSz2*(InpStp3+InpStp4+InpStp5        ) + InpSz3*(InpStp4+InpStp5        ) + InpSz4*(InpStp5        )                   ) / InpE5  - (InpSz1 + InpSz2 + InpSz3 + InpSz4          );
    InpSz6 = 1.7*(InpSz1*(InpStp2+InpStp3+InpStp4+InpStp5+InpStp6) + InpSz2*(InpStp3+InpStp4+InpStp5+InpStp6) + InpSz3*(InpStp4+InpStp5+InpStp6) + InpSz4*(InpStp5+InpStp6) + InpSz5*(InpStp6)) / InpE6  - (InpSz1 + InpSz2 + InpSz3 + InpSz4 + InpSz5 );
    InpSz3 = NormalizeDouble(InpSz3, 2);
    InpSz4 = NormalizeDouble(InpSz4, 2);
    InpSz5 = NormalizeDouble(InpSz5, 2);
    InpSz6 = NormalizeDouble(InpSz6, 2);
    
    initProfileApprearence();
    return INIT_SUCCEEDED;
}

#include <Trade\Trade.mqh>
CTrade gCTrade;
double Bid, Ask;
MqlDateTime gStCurTime;
datetime    gCurDt;
string      gStrCurTime, gStrPreTime;
eStage      gState;

int     gL6ReachedCount = 0;


ulong gTicketL1 = 0;
ulong gTicketL2 = 0;
ulong gTicketL3 = 0;
ulong gTicketL4 = 0;
ulong gTicketL5 = 0;
ulong gTicketL6 = 0;
void OnTick() {
    // if (gReadyStage == false) return; TODO
    Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    gCurDt = iTime(_Symbol, PERIOD_CURRENT, 0);
    TimeToStruct(gCurDt, gStCurTime);

    // Exclude sunday
    if (gStCurTime.day_of_week == 0) return;
    if (gStCurTime.hour == 22) return;
    gStrCurTime = TimeToString(gCurDt, TIME_DATE);

    if (gStrCurTime != gStrPreTime) {
        // New day handle
        gprice1 = iOpen(_Symbol, PERIOD_D1, 0) - InpStp1;
        gStrPreTime = gStrCurTime;
    }

    switch (gState)
    {
    case eNoTrade:{
        if (Bid <= gprice1) {
            gState = eL1;
            initL1();
        }
    }
        break;
    case eL1     :{
        if (Bid >= gpriceE1) {
            gCTrade.PositionClose(gTicketL1);
            gState = eNoTrade;
        }
        else if (Bid <= gprice2) {
            gState = eL2;
            gCTrade.Buy(InpSz2, NULL, 0, 0, 0, "L2");
            gTicketL2 = gCTrade.ResultOrder();
            gpriceE2 = Ask + InpE2;
            gprice3 = Bid - InpStp3;
        }
    }
        break;
    case eL2     :{
        if (Bid >= gpriceE2) {
            gCTrade.PositionClose(gTicketL2);
            gState = eL1;
        }
        else if (Bid <= gprice3) {
            gState = eL3;
            gCTrade.Buy(InpSz3, NULL, 0, 0, 0, "L3");
            gTicketL3 = gCTrade.ResultOrder();
            gpriceE3 = Ask + InpE3;
            gprice4 = Bid - InpStp4;
        }
    }
        break;
    case eL3     :{
        if (Bid >= gpriceE3) {
            gCTrade.PositionClose(gTicketL1);
            gCTrade.PositionClose(gTicketL2);
            gCTrade.PositionClose(gTicketL3);
            initL1();
            gState = eL1;
        }
        else if (Bid <= gprice4) {
            gCTrade.Buy(InpSz4, NULL, 0, 0, 0, "L4");
            gTicketL4 = gCTrade.ResultOrder();
            gpriceE4 = Ask + InpE4;
            gprice5 = Bid - InpStp5;
            gState = eL4;
        }
    }
        break;
    case eL4     :{
        if (Bid >= gpriceE4) {
            gCTrade.PositionClose(gTicketL1);
            gCTrade.PositionClose(gTicketL2);
            gCTrade.PositionClose(gTicketL3);
            gCTrade.PositionClose(gTicketL4);
            initL1();
            gState = eL1;
        }
        else if (Bid <= gprice5) {
            gCTrade.Buy(InpSz5, NULL, 0, 0, 0, "L5");
            gTicketL5 = gCTrade.ResultOrder();
            gpriceE5 = Ask + InpE5;
            gprice6 = Bid - InpStp6;
            gState = eL5;
        }
    }
        break;
    case eL5     :{
        if (Bid >= gpriceE5) {
            gCTrade.PositionClose(gTicketL1);
            gCTrade.PositionClose(gTicketL2);
            gCTrade.PositionClose(gTicketL3);
            gCTrade.PositionClose(gTicketL4);
            gCTrade.PositionClose(gTicketL5);
            initL1();
            gState = eL1;
        }
        else if (Bid <= gprice6) {
            gCTrade.Buy(InpSz6, NULL, 0, 0, 0, "L6");
            gTicketL6 = gCTrade.ResultOrder();
            gpriceE6 = Ask + InpE6;
            gState = eL6;

            createLabel("L6 Count", "L6 Count: " + IntegerToString(gL6ReachedCount++), 20, 200);
        }
    }
        break;
    case eL6     :{
        if (Bid >= gpriceE6) {
            gCTrade.PositionClose(gTicketL1);
            gCTrade.PositionClose(gTicketL2);
            gCTrade.PositionClose(gTicketL3);
            gCTrade.PositionClose(gTicketL4);
            gCTrade.PositionClose(gTicketL5);
            gCTrade.PositionClose(gTicketL6);
            initL1();
            gState = eL1;
        }
        // else if (Bid <= ) {
        //     //HOW TO CUT LOSS?
        // }
    }
        break;
    default:
        break;
    }
    // createLabel(objLabelHL, "*_____________________", 145, 130 - 15*gState);
}

void initL1() {
    gCTrade.Buy(InpSz1, NULL, 0, 0, 0, "L1");
    gTicketL1 = gCTrade.ResultOrder();
    gpriceE1 = Ask + InpE1;
    gprice2 = Bid - InpStp2;
}

bool initEA() {
    // TODO
    // Bật BOT - Kiểm tra thông tin các lệnh hiện hành
    // Nếu lệnh này dính từ đêm qua -> Yêu cầu người xử lý -> return false + thong bao loi
    // Nếu lệnh mới vào - Do bật tắt bot -> Nạp dữ liệu vào RAM -> return true
    return false;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if (id == CHARTEVENT_OBJECT_CLICK) handleClick(sparam);
}

/// @brief Apprearence and Action
string objBackGround    = APP_TAG + "AvatarBG";
string objBtnStart      = APP_TAG + "BtnStart";
string objLabelHL       = APP_TAG + "LabelHL";
string objLabelHD       = APP_TAG + "LabelHD";
string objLabelL1       = APP_TAG + "LabelL1";
string objLabelL2       = APP_TAG + "LabelL2";
string objLabelL3       = APP_TAG + "LabelL3";
string objLabelL4       = APP_TAG + "LabelL4";
string objLabelL5       = APP_TAG + "LabelL5";
string objLabelL6       = APP_TAG + "LabelL6";
void initProfileApprearence() {
    // ObjectCreate(0,objBackGround,OBJ_BITMAP_LABEL,0,0,0);
    // ObjectSetInteger(0,objBackGround,OBJPROP_CORNER,CORNER_LEFT_LOWER);
    // ObjectSetInteger(0,objBackGround,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
    // ObjectSetInteger(0,objBackGround,OBJPROP_XDISTANCE,0);
    // ObjectSetInteger(0,objBackGround,OBJPROP_YDISTANCE,0);
    // ObjectSetString(0,objBackGround,OBJPROP_BMPFILE,0,"::PerrythePlatypusBG.bmp");

    /*
    createLabel(objLabelHD, "    Step  Size  Expect"                                                                                                               , 10, 130);
    createLabel(objLabelL1, " L1 " + fixedText(DoubleToString(InpStp1,0),4) + " " +fixedText(DoubleToString(InpSz1,2),5)+" " + fixedText(DoubleToString(InpE1,0),7), 10, 115);
    createLabel(objLabelL2, " L2 " + fixedText(DoubleToString(InpStp2,0),4) + " " +fixedText(DoubleToString(InpSz2,2),5)+" " + fixedText(DoubleToString(InpE2,0),7), 10, 100);
    createLabel(objLabelL3, " L3 " + fixedText(DoubleToString(InpStp3,0),4) + " " +fixedText(DoubleToString(InpSz3,2),5)+" " + fixedText(DoubleToString(InpE3,0),7), 10,  85);
    createLabel(objLabelL4, " L4 " + fixedText(DoubleToString(InpStp4,0),4) + " " +fixedText(DoubleToString(InpSz4,2),5)+" " + fixedText(DoubleToString(InpE4,0),7), 10,  70);
    createLabel(objLabelL5, " L5 " + fixedText(DoubleToString(InpStp5,0),4) + " " +fixedText(DoubleToString(InpSz5,2),5)+" " + fixedText(DoubleToString(InpE5,0),7), 10,  55);
    createLabel(objLabelL6, " L6 " + fixedText(DoubleToString(InpStp6,0),4) + " " +fixedText(DoubleToString(InpSz6,2),5)+" " + fixedText(DoubleToString(InpE6,0),7), 10,  40);
    */
}

void handleClick(string sparam)
{
    if (sparam == objBtnStart) {
        if (initEA() == false) {
            // Thông báo lỗi
            return;
        }
        gReadyStage = true;
    }
    // else if () {}
}

void createLabel(string objName, string text, int posX, int posY)
{
    ObjectCreate(0,     objName, OBJ_LABEL, 0, 0, 0, 0, 0);
    ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLightGray);
    ObjectSetInteger(0, objName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
    ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, objName, OBJPROP_BACK, false);
    ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
    ObjectSetString(0,  objName, OBJPROP_FONT, "Consolas");
    ObjectSetString(0,  objName, OBJPROP_TEXT, text);
    ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, posX);
    ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, posY);
}

#define TXT_SPACE_BLOCK "                    "
string fixedText(string str, int size) {
    int spaceSize = size - StringLen(str);
    if (spaceSize <= 0) return str;
    return StringSubstr(TXT_SPACE_BLOCK, 0, spaceSize) + str;
}

/*
       Step  Size  Expect
  L1   -    0.01   3000
  L2   700  0.02   3000
  L3   100  0.xx    200
  L4   100  0.xx    200
  L5   100  0.xx    200
  L6   100  0.xx    200
*_____________________


  */