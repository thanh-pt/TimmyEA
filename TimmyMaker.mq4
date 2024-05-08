//+------------------------------------------------------------------+
//|                                                   TimmyMaker.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property strict
color gColorMousePoint = clrSlateGray;
#include "Home/Controller.mqh"
#include "Home/CommonData.mqh"
#include "InfoItem/CrossHair.mqh"
#include "InfoItem/ContextMenu.mqh"
#include "InfoItem/MouseInfo.mqh"

void FinishedJobFunc();
void detectMouseDraging(const string &sparam);

Trade* gpTrade;

CommonData  gCommonData;
MouseInfo   gMouseInfo(&gCommonData);
Controller  gController(&gCommonData, &gMouseInfo);
CrossHair   gCrossHair(&gCommonData);
ContextMenu gContextMenu();

int    gSymbolDigits= 0;
double gScaleRange = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_DELETE, true);
    
    // Init global variable
    gController.setFinishedJobCB(FinishedJobFunc);

    gSymbolDigits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
    if (gSymbolDigits == 0) gSymbolDigits = 5;

//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   gContextMenu.clearContextMenu();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
    gController.handleOntick();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
       switch (id)
    {
    case CHARTEVENT_KEYDOWN:
        gController.handleKeyEvent(lparam);
    break;

    case CHARTEVENT_MOUSE_MOVE:
        gCommonData.updateMousePosition(lparam, dparam, sparam);
        gCrossHair.onMouseMove();
        gMouseInfo.onMouseMove();
        detectMouseDraging(sparam);
    case CHARTEVENT_CLICK:
        gController.handleIdEventOnly(id);
        break;

    // event need sparam
    case CHARTEVENT_OBJECT_CLICK:
    case CHARTEVENT_OBJECT_DELETE:
        gContextMenu.onItemClick(sparam);
        gCrossHair.onObjectDeleted(sparam);
        gMouseInfo.onObjectDeleted(sparam);
    case CHARTEVENT_OBJECT_DRAG:
    case CHARTEVENT_OBJECT_CHANGE:
        gController.handleSparamEvent(id, sparam);
    break;
    case CHARTEVENT_CHART_CHANGE:
        gContextMenu.clearContextMenu();
    break;
    default:
        // PrintFormat("%d", id);
    break;
    }
  }
//+------------------------------------------------------------------+
void FinishedJobFunc()
{
    gController.finishedJob();
}

// Tạo biến globle cho đỡ tốn công tạo xoá biến
string gTargetItem;
bool gIsPress;
int gPreviousOption;
void detectMouseDraging(const string &sparam)
{
    int option = StrToInteger(sparam);
    // Press event
    if ((option & 0x01) != 0 && (gPreviousOption & 0x01) == 0)
    {
        gIsPress = true;
        gTargetItem = findItemUnderMouse(gCommonData.mMouseX, gCommonData.mMouseY);
    }
    else
        // Release event
        if ((option & 0x01) == 0 && (gPreviousOption & 0x01) != 0)
        {
            gIsPress = false;
            gTargetItem = "";
        }
    // Press and draging
    if (gIsPress && (option & 0x01) != 0)
    {
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, gTargetItem);
    }

    gPreviousOption = option;
}