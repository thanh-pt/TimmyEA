//+------------------------------------------------------------------+
//|                                                   TimmyMaker.mq4 |
//|                                                    Timmy Ham Hoc |
//|                       https://www.youtube.com/@TimmyTraderHamHoc |
//+------------------------------------------------------------------+
#property strict
input bool  gAlertActive = false; // Alert Active
color gColorMousePoint = clrSlateGray;
#include "InfoItem/CrossHair.mqh"
#include "InfoItem/MouseInfo.mqh"
#include "InfoItem/Templates.mqh"
#include "Controller.mqh"
#include "CommonData.mqh"

void FinishedJobFunc();
void detectMouseDraging(const string &sparam);

LongShort* gpLongShort;

CommonData gCommonData;
CrossHair  gCrossHair(&gCommonData);
MouseInfo  gMouseInfo(&gCommonData);
Templates  gTemplates();
Controller gController(&gCommonData, &gMouseInfo);

string gListAlert = "";
string gAlertText = "";
string gAlertArr[];
int    gAlertTotal  = 0;
bool   gAlertReach  = false;
double gAlertPrice  = 0;
string gAlertRemain = "";
int    gSymbolDigits= 0;
double gScaleRange = 0;

void initAlarm()
{
    string alertLine = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        alertLine = ObjectName(i);
        if (StringFind(alertLine, "cAlert") == -1) continue;
        // Add Alert to the list
        if (gListAlert != "") gListAlert += ",";
        gListAlert += alertLine;
    }
}

void checkAlert()
{
    gAlertTotal  = StringSplit(gListAlert,',',gAlertArr);
    gAlertRemain = "";
    for (int i = 0; i < gAlertTotal; i++)
    {
        // Check valid Alert
        if (ObjectFind(gAlertArr[i]) < 0) continue;
        if (StringFind(gAlertArr[i], "cAlert") == -1) continue;

        // Get Alert information
        gAlertReach = false;
        gAlertPrice = ObjectGet(gAlertArr[i], OBJPROP_PRICE1);
        gAlertText  = ObjectGetString(ChartID(), gAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (StringFind(gAlertText,"[H]") != -1)
        {
            gAlertReach = (Bid >= gAlertPrice);
        }
        else if (StringFind(gAlertText,"[L]") != -1)
        {
            gAlertReach = (Bid <= gAlertPrice);
        }

        // Send notification or save remain Alert
        if (gAlertReach == true)
        {
            SendNotification(Symbol()+":   "+ DoubleToString(gAlertPrice, gSymbolDigits) + "\n" + gAlertText);
            ObjectDelete(gAlertArr[i]);
        }
        else
        {
            gAlertRemain += gAlertArr[i] + ",";
        }
    }
    gListAlert = gAlertRemain;
}

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

    // Init function
    initAlarm();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   gTemplates.clearTemplates();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (gAlertActive) checkAlert();
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
        gTemplates.onItemClick(sparam);
        gCrossHair.onObjectDeleted(sparam);
        gMouseInfo.onObjectDeleted(sparam);
    case CHARTEVENT_OBJECT_DRAG:
    case CHARTEVENT_OBJECT_CHANGE:
        gController.handleSparamEvent(id, sparam);
    break;
    case CHARTEVENT_CHART_CHANGE:
        gTemplates.clearTemplates();
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