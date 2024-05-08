#define STATIC_TAG          "%"
#define BG_TAG              "BgOverlapFix"
#define LINE_STYLE          ENUM_LINE_STYLE

#define MAX_TYPE 15
#define MAX_SYNC_ITEMS 50

#define CHART_EVENT_SELECT_CONTEXTMENU CHARTEVENT_CUSTOM+1

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

void getCenterPos(const datetime& time1, const datetime& time2, double price1, double price2, datetime& outTime, double& outPrice)
{
    int x1,y1,x2,y2;
    int window = 0;
    ChartTimePriceToXY(ChartID(), window, time1, price1, x1, y1);
    ChartTimePriceToXY(ChartID(), window, time2, price2, x2, y2);
    x1 = (x1+x2)/2;
    y1 = (y1+y2)/2;
    ChartXYToTimePrice(ChartID(), x1, y1, window, outTime, outPrice);
    outPrice = (price1+price2)/2;
}

datetime getCenterTime(const datetime& time1, const datetime& time2)
{
    datetime centerTime;
    double price;
    double priceInp = ChartGetDouble(ChartID(),CHART_FIXED_MAX);
    getCenterPos(time1, time2, priceInp, priceInp, centerTime, price);
    return centerTime;
}

void unSelectAll()
{
    string currentItemId;
    string sparamItems[];
    int k;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        ObjectSet(objName, OBJPROP_SELECTED, 0);

        if (StringFind(objName, "_c0") == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        
        if (k != 3) continue;
        string itemId = sparamItems[0] + "_" + sparamItems[1];
        
        if (itemId == currentItemId) continue;
        currentItemId = itemId;
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, objName);
    }
    gContextMenu.clearContextMenu();
}

void unSelectAllExcept(string objId)
{
    string currentItemId;
    string sparamItems[];
    int k;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, objId) != -1) continue;

        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        ObjectSet(objName, OBJPROP_SELECTED, 0);

        if (StringFind(objName, "_c0") == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        
        if (k != 3) continue;
        string itemId = sparamItems[0] + "_" + sparamItems[1];
        
        if (itemId == currentItemId) continue;
        currentItemId = itemId;
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, objName);
    }
    gContextMenu.clearContextMenu();
}

string findItemUnderMouse(int posX, int posY)
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (ObjectGet(objName, OBJPROP_SELECTABLE) == false) continue;
        if (StringFind(objName, "_c") == -1) continue;

        int objType = ObjectType(objName);

        if (objType == OBJ_TREND || objType == OBJ_RECTANGLE)
        {
            int x1, y1, x2, y2;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME2), ObjectGet(objName, OBJPROP_PRICE2), x2, y2);

            int offset = 10;
            if (x1 > x2)
            {
                int temp = x1;
                x1 = x2;
                x2 = temp;
            }
            if (posX < (x1 - offset) || posX > (x2 + offset))
            {
                continue;
            }
            if (y1 > y2)
            {
                int temp = y1;
                y1 = y2;
                y2 = temp;
            }
            if (posY >= (y1 - offset) && posY < (y2 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_ARROW || objType == OBJ_TEXT)
        {
            int x1, y1;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);

            int offset = 10;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_LABEL)
        {
            int x1 = (int)ObjectGet(objName, OBJPROP_XDISTANCE);
            int y1 = (int)ObjectGet(objName, OBJPROP_YDISTANCE);

            int offset = 20;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
    }
    return "";
}

void EraseAll()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        // if (StringFind(objName, "Trade") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        ObjectDelete(objName);
    }
}

void EraseLowerTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) >= ChartPeriod())
            {
                continue;
            }
            ObjectDelete(objName);
        }
    }
}

void EraseThisTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "Trade") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;

        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) == ChartPeriod())
            {
                ObjectDelete(objName);
            }
        }
    }
}

void SetChartFree(bool bFree)
{
    // PrintFormat("bFree : %d", bFix);
    //--- reset the error value
    ResetLastError();
    //--- set property value
    if(!ChartSetInteger(ChartID(),CHART_SCALEFIX,0,bFree))
    {
        //--- display the error message in Experts journal
        Print(__FUNCTION__+", Error Code = ",GetLastError());
    }
}

void scaleChart(bool isUp)
{
    if (gScaleRange == 0) {
        gScaleRange = ((High[1]-Low[1])+(High[2]-Low[2])+(High[3]-Low[3])+(High[4]-Low[4])+(High[5]-Low[5])+(High[6]-Low[6])+(High[7]-Low[7]))/35;
    }
    ChartSetInteger(ChartID(), CHART_SCALEFIX, 0, 1);
    double chartMin = 0;
    double chartMax = 0;
    long chart_ID = ChartID();
    ChartGetDouble(chart_ID,CHART_FIXED_MAX,0,chartMax);
    ChartGetDouble(chart_ID,CHART_FIXED_MIN,0,chartMin);
    if (isUp) {
        chartMax = chartMax + gScaleRange;
        chartMin = chartMin - gScaleRange;
    }
    else {
        chartMax = chartMax - gScaleRange;
        chartMin = chartMin + gScaleRange;
    }
    ChartSetDouble(chart_ID,CHART_FIXED_MAX,chartMax);
    ChartSetDouble(chart_ID,CHART_FIXED_MIN,chartMin);
}

string getTFString()
{
    string result = "";
    int period = ChartPeriod();
    if (period < PERIOD_H1)
    {
        result = "m";
        result += IntegerToString(period);
        return result;
    }
    if (period < PERIOD_D1)
    {
        result = "h";
        result += IntegerToString(period/PERIOD_H1);
        return result;
    }
    if (period < PERIOD_W1)
    {
        result = "d";
        return result;
    }
    if (period < PERIOD_MN1)
    {
        result = "w";
        return result;
    }
    result = "mn";
    return result;
}

void setItemPos(const string& objName, datetime time1, datetime time2, const double price1, const double price2)
{
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
    ObjectSet(objName, OBJPROP_TIME2 , time2);
    ObjectSet(objName, OBJPROP_PRICE2, price2);
}

void setItemPos(const string& objName, datetime time1, const double price1)
{
    ObjectSet(objName, OBJPROP_TIME1 , time1);
    ObjectSet(objName, OBJPROP_PRICE1, price1);
}

void setTextPos(const string& objName, datetime time1, const double price1)
{
    ObjectSet(objName, OBJPROP_TIME1,  time1);

    string textContent = ObjectDescription(objName);
    if (textContent == "" || textContent == "Text")
    {
        ObjectSet(objName, OBJPROP_PRICE1, 0);
    }
    else
    {
        ObjectSet(objName, OBJPROP_PRICE1, price1);
    }
}

void multiSetProp(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSet("."+sparamItems[i], property, value);
    }
}

void multiSetStrs(int property, string value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetString(ChartID(), "."+sparamItems[i], property, value);
    }
}

void multiSetInts(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetInteger(ChartID(), "."+sparamItems[i], property, value);
    }
}

void SetRectangleBackground(string obj, color c)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , true);
    ObjectSet(obj, OBJPROP_STYLE, 2); // Dot as default
}

void SetObjectStyle(string obj, color c, int style, int width)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , false);
    ObjectSet(obj, OBJPROP_RAY  , false);
    ObjectSet(obj, OBJPROP_STYLE, style);
    ObjectSet(obj, OBJPROP_WIDTH, width);
}

int getObjectTimeId(string objId)
{
    int startP = StringFind(objId, "#");
    if (startP < 0) return hashString(objId);
    int endP = StringFind(objId, "_", startP);
    if (endP < 0) return hashString(objId);
    string timeIdStr = StringSubstr(objId, startP+1, endP-startP-1);
    return StrToInteger(timeIdStr);
}

int hashString(string str)
{
    int hashChk = 0;
    for (int i = 0; i < StringLen(str); i++) hashChk += ((i+1)*StringGetCharacter(str, i));
    return hashChk;
}

void removeBackgroundOverlap(string target)
{
    int targetId = getObjectTimeId(target);
    string bgItem  = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectFind(ChartID(), objName) != 0) continue;
        if (ObjectType(objName) != OBJ_RECTANGLE) continue;
        if (ObjectGet (objName, OBJPROP_BACK) == false) continue;
        if (StringFind(objName, BG_TAG) != -1) continue;
        if (objName == target) continue;
        bgItem = BG_TAG;
        int objId = getObjectTimeId(objName);
        if (targetId > objId) bgItem += (IntegerToString(targetId) +"."+ IntegerToString(objId));
        else bgItem += (IntegerToString(objId) +"."+ IntegerToString(targetId));
        ObjectDelete(bgItem);
    }
}

void EraseBgOverlap()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, BG_TAG) != -1) ObjectDelete(objName);
    }
}

double hue2rgb(double p, double q, double t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1./6) return p + (q - p) * 6 * t;
  if (t < 1./2) return q;
  if (t < 2./3) return p + (q - p) * (2./3 - t) * 6;
  return p;
}

color increaseLum(color c)
{
    // 0x00BBGGRR
    double r = (double)((c&0x000000FF)    );
    double g = (double)((c&0x0000FF00)>>8 );
    double b = (double)((c&0x00FF0000)>>16);
    double h,s,l;
    // 1. RGB -> HSL
    r /= 255;
    g /= 255;
    b /= 255;
    double max = MAX(MAX(r,g),b);
    double min = MIN(MIN(r,g),b);
    h = s = l = (max + min) / 2;
    if (max == min) h = s = 0; // achromatic
    else
    {
        double d = max - min;
        s = (l > 0.5) ? d / (2 - max - min) : d / (max + min);
        if      (max == r) h = (g - b) / d + (g < b ? 6 : 0);
        else if (max == g) h = (b - r) / d + 2;
        else if (max == b) h = (r - g) / d + 4;
        h /= 6;
    }
    // 2. Increase lum
    l -= 0.1;
    // 3. HSL -> RGB
    if (0 == s) r = g = b = l; // achromatic
    else
    {
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        double p = 2 * l - q;
        r = hue2rgb(p, q, h + 1./3) * 255;
        g = hue2rgb(p, q, h) * 255;
        b = hue2rgb(p, q, h - 1./3) * 255;
    }
    // 4. Combine RGB to color
    c = (color)((int)r|((int)g<<8)|((int)b<<16));
    return c;
}

color decreaseLum(color c)
{
    // 0x00BBGGRR
    double r = (double)((c&0x000000FF)    );
    double g = (double)((c&0x0000FF00)>>8 );
    double b = (double)((c&0x00FF0000)>>16);
    double h,s,l;
    // 1. RGB -> HSL
    r /= 255;
    g /= 255;
    b /= 255;
    double max = MAX(MAX(r,g),b);
    double min = MIN(MIN(r,g),b);
    h = s = l = (max + min) / 2;
    if (max == min) h = s = 0; // achromatic
    else
    {
        double d = max - min;
        s = (l > 0.5) ? d / (2 - max - min) : d / (max + min);
        if      (max == r) h = (g - b) / d + (g < b ? 6 : 0);
        else if (max == g) h = (b - r) / d + 2;
        else if (max == b) h = (r - g) / d + 4;
        h /= 6;
    }
    // 2. Increase lum
    l += 0.1;
    // 3. HSL -> RGB
    if (0 == s) r = g = b = l; // achromatic
    else
    {
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        double p = 2 * l - q;
        r = hue2rgb(p, q, h + 1./3) * 255;
        g = hue2rgb(p, q, h) * 255;
        b = hue2rgb(p, q, h - 1./3) * 255;
    }
    // 4. Combine RGB to color
    c = (color)((int)r|((int)g<<8)|((int)b<<16));
    return c;
}

void scanBackgroundOverlap(string target)
{
    color targetColor = (color)ObjectGet(target, OBJPROP_COLOR);
    if (targetColor == clrNONE) return;
    if (ObjectGet(target, OBJPROP_BACK) == false) return;

    double price1  =           ObjectGet(target, OBJPROP_PRICE1);
    double price2  =           ObjectGet(target, OBJPROP_PRICE2);
    datetime time1 = (datetime)ObjectGet(target, OBJPROP_TIME1);
    datetime time2 = (datetime)ObjectGet(target, OBJPROP_TIME2);
    int targetId = getObjectTimeId(target);
    string bgItem = "";

    if (price1 > price2)
    {
        double tempP = price1;
        price1 = price2;
        price2 = tempP;
    }
    if (time1 > time2)
    {
        datetime tempT = time1;
        time1 = time2;
        time2 = tempT;
    }

    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectFind(ChartID(), objName) != 0) continue;
        if (ObjectType(objName) != OBJ_RECTANGLE) continue;
        if (ObjectGet (objName, OBJPROP_BACK) == false) continue;
        if (ObjectGet (objName, OBJPROP_COLOR) == clrNONE) continue;
        if (StringFind(objName, BG_TAG) != -1) continue;
        if (StringFind(objName, "Rectangle") == -1) continue;
        if (objName == target) continue;

        double cprice1  = ObjectGet(objName, OBJPROP_PRICE1);
        double cprice2  = ObjectGet(objName, OBJPROP_PRICE2);
        if (cprice1 > cprice2)
        {
            double tempP = cprice1;
            cprice1 = cprice2;
            cprice2 = tempP;
        }
        datetime ctime1 = (datetime)ObjectGet(objName, OBJPROP_TIME1);
        datetime ctime2 = (datetime)ObjectGet(objName, OBJPROP_TIME2);
        if (ctime1 > ctime2)
        {
            datetime tempT = ctime1;
            ctime1 = ctime2;
            ctime2 = tempT;
        }
        int objId = getObjectTimeId(objName);
        bgItem = BG_TAG;
        if (targetId > objId) bgItem += (IntegerToString(targetId) +"."+ IntegerToString(objId));
        else bgItem += (IntegerToString(objId) +"."+ IntegerToString(targetId));

        // Case 2 rectangle does not touch
        if (price2 <= cprice1 || cprice2 <= price1 || time2 <= ctime1 || ctime2 <= time1)
        {
            if (ObjectFind(bgItem) >= 0)
            {
                ObjectDelete(bgItem);
            }
            continue;
        }
        color colorBgColor = (color)ObjectGet(objName, OBJPROP_COLOR);
        if (ObjectFind(bgItem) < 0)
        {
            ObjectCreate(bgItem, OBJ_RECTANGLE , 0, 0, 0);
            ObjectSet(bgItem   , OBJPROP_SELECTABLE, false);
            ObjectSetString(ChartID(), bgItem, OBJPROP_TOOLTIP, "\n");
        }
        if (colorBgColor == targetColor)
        {
            SetRectangleBackground(bgItem, increaseLum(targetColor));
        }
        else
        {
            SetRectangleBackground(bgItem, decreaseLum(targetColor));
        }

        if (cprice1 < price1) cprice1 = price1;
        if (cprice2 > price2) cprice2 = price2;
        if (ctime1 < time1) ctime1 = time1;
        if (ctime2 > time2) ctime2 = time2;
        setItemPos(bgItem, ctime1, ctime2, cprice1, cprice2);
    }
}

int weekOfYear(datetime date)
{
    return (TimeDayOfYear(date)+TimeDayOfWeek(StrToTime(IntegerToString(TimeYear(date))+".01.01"))-2)/7;
}

string strDayOfWeek(datetime date)
{
    int dayOfWeek = TimeDayOfWeek(date);
    string retDayOfW = "";
    switch (dayOfWeek)
    {
        case 0: retDayOfW = "CN"; break;
        case 1: retDayOfW = "T2"; break;
        case 2: retDayOfW = "T3"; break;
        case 3: retDayOfW = "T4"; break;
        case 4: retDayOfW = "T5"; break;
        case 5: retDayOfW = "T6"; break;
        case 6: retDayOfW = "T7"; break;
        // case 0: retDayOfW = "Su"; break;
        // case 1: retDayOfW = "Mo"; break;
        // case 2: retDayOfW = "Tu"; break;
        // case 3: retDayOfW = "We"; break;
        // case 4: retDayOfW = "Th"; break;
        // case 5: retDayOfW = "Fr"; break;
        // case 6: retDayOfW = "Sa"; break;
    }
    return retDayOfW;
}

struct ObjectProperty
{
    string      objName        ;
    ENUM_OBJECT objType        ;
    datetime    objTime1       ;
    datetime    objTime2       ;
    double      objPrice1      ;
    double      objPrice2      ;
    color       objColor       ;
    int         objStyle       ;
    int         objWidth       ;
    int         objBack        ;
    int         objSelectable  ;
    int         objFontSize    ;
    int         objRay         ;
    int         objArrowCode   ;
    int         objAnchorPoint ;
    int         objCornerPoint ;
    string      objText        ;
    string      objFontName    ;
    string      objTooltip     ;
};

void syncItem(ObjectProperty &objProperty, long currChart, bool objectExit)
{
    ENUM_OBJECT objType = objProperty.objType;
    if(objectExit == false) {
        ObjectCreate(currChart,
                    objProperty.objName,
                    objProperty.objType,
                    0,
                    objProperty.objTime1,
                    objProperty.objPrice1,
                    objProperty.objTime2,
                    objProperty.objPrice2);
    }
    else {
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_TIME1, objProperty.objTime1);
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_TIME2, objProperty.objTime2);
        ObjectSetDouble (currChart, objProperty.objName, OBJPROP_PRICE1, objProperty.objPrice1);
        ObjectSetDouble (currChart, objProperty.objName, OBJPROP_PRICE2, objProperty.objPrice2);
    }
    ObjectSetInteger(currChart, objProperty.objName, OBJPROP_COLOR      , objProperty.objColor      );
    ObjectSetInteger(currChart, objProperty.objName, OBJPROP_STYLE      , objProperty.objStyle      );
    ObjectSetInteger(currChart, objProperty.objName, OBJPROP_WIDTH      , objProperty.objWidth      );
    ObjectSetInteger(currChart, objProperty.objName, OBJPROP_BACK       , objProperty.objBack       );
    ObjectSetInteger(currChart, objProperty.objName, OBJPROP_SELECTABLE , objProperty.objSelectable );
    ObjectSetString(currChart , objProperty.objName, OBJPROP_TEXT       , objProperty.objText       );
    ObjectSetString(currChart , objProperty.objName, OBJPROP_TOOLTIP    , objProperty.objTooltip    );
    if (objType == OBJ_TEXT || objType == OBJ_LABEL) {
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_FONTSIZE   , objProperty.objFontSize   );
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_ANCHOR     , objProperty.objAnchorPoint);
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_CORNER     , objProperty.objCornerPoint);
        ObjectSetString(currChart , objProperty.objName, OBJPROP_FONT       , objProperty.objFontName   );
    }
    if (objType == OBJ_LABEL) {
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_XDISTANCE, (int)objProperty.objPrice1);
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_YDISTANCE, (int)objProperty.objPrice2);
    }
    if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE) {
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_RAY        , objProperty.objRay        );
    }
    if (objType == OBJ_ARROW) {
        ObjectSetInteger(currChart, objProperty.objName, OBJPROP_ARROWCODE  , objProperty.objArrowCode  );
    }
}

ObjectProperty gListSelectedObjProp[MAX_SYNC_ITEMS+1];

void syncSelectedItem()
{
    // Find selected item
    long chartID = ChartID();
    int selectedItemNum = 0;
    string objName      = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) != 0) {
            gListSelectedObjProp[selectedItemNum].objName       = objName;
            ENUM_OBJECT objType = (ENUM_OBJECT)ObjectGetInteger(chartID, objName, OBJPROP_TYPE);
            gListSelectedObjProp[selectedItemNum].objType       = objType;
            gListSelectedObjProp[selectedItemNum].objTime1      = (datetime)ObjectGetInteger(chartID, objName, OBJPROP_TIME1);
            gListSelectedObjProp[selectedItemNum].objTime2      = (datetime)ObjectGetInteger(chartID, objName, OBJPROP_TIME2);
            gListSelectedObjProp[selectedItemNum].objPrice1     = ObjectGetDouble(chartID, objName, OBJPROP_PRICE1);
            gListSelectedObjProp[selectedItemNum].objPrice2     = ObjectGetDouble(chartID, objName, OBJPROP_PRICE2);
            if (StringFind(objName, "_cPoint") != -1) {
                gListSelectedObjProp[selectedItemNum].objColor = clrNONE;
            }
            else {
                gListSelectedObjProp[selectedItemNum].objColor  = (color)ObjectGet(objName, OBJPROP_COLOR);
            }
            gListSelectedObjProp[selectedItemNum].objStyle      = (int)ObjectGet(objName, OBJPROP_STYLE     );
            gListSelectedObjProp[selectedItemNum].objWidth      = (int)ObjectGet(objName, OBJPROP_WIDTH     );
            gListSelectedObjProp[selectedItemNum].objBack       = (int)ObjectGet(objName, OBJPROP_BACK      );
            gListSelectedObjProp[selectedItemNum].objSelectable = (int)ObjectGet(objName, OBJPROP_SELECTABLE);
            gListSelectedObjProp[selectedItemNum].objText       = ObjectDescription(objName);
            gListSelectedObjProp[selectedItemNum].objTooltip    = ObjectGetString(chartID, objName, OBJPROP_TOOLTIP);
            if (objType == OBJ_TEXT || objType == OBJ_LABEL) {
                gListSelectedObjProp[selectedItemNum].objFontName   = ObjectGetString(chartID, objName, OBJPROP_FONT);
                gListSelectedObjProp[selectedItemNum].objFontSize   = (int)ObjectGet(objName, OBJPROP_FONTSIZE  );
                gListSelectedObjProp[selectedItemNum].objAnchorPoint= (int)ObjectGet(objName, OBJPROP_ANCHOR    );
                gListSelectedObjProp[selectedItemNum].objCornerPoint= (int)ObjectGet(objName, OBJPROP_CORNER    );
            }
            if (objType == OBJ_LABEL) {
                gListSelectedObjProp[selectedItemNum].objPrice1     = ObjectGet(objName, OBJPROP_XDISTANCE);
                gListSelectedObjProp[selectedItemNum].objPrice2     = ObjectGet(objName, OBJPROP_YDISTANCE);
            }
            if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE) {
                gListSelectedObjProp[selectedItemNum].objRay        = (int)ObjectGet(objName, OBJPROP_RAY       );
            }
            if (objType == OBJ_ARROW) {
                gListSelectedObjProp[selectedItemNum].objArrowCode  = (int)ObjectGet(objName, OBJPROP_ARROWCODE );
            }

            selectedItemNum++;
            if (selectedItemNum >= MAX_SYNC_ITEMS) return;
        }
    }

    long currChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    while(currChart > 0)
    {
        if (ChartSymbol(currChart) == chartSymbol && currChart != chartID) {
            bool objectExit = (ObjectFind(currChart, gListSelectedObjProp[0].objName) >= 0);
            for (int i = 0; i < selectedItemNum; i++) {
                syncItem(gListSelectedObjProp[i], currChart, objectExit);
            }
        }
        currChart = ChartNext(currChart);
    }
}

void syncDeleteSelectedItem()
{
    // Find selected item
    string listSelectedItem[20];
    int selectedItemNum = 0;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) != 0) {
            listSelectedItem[selectedItemNum] = objName;

            selectedItemNum++;
            if (selectedItemNum >= MAX_SYNC_ITEMS) return;
        }
    }

    long currChart = ChartFirst();
    while(currChart > 0)
    {
        for (int i = 0; i < selectedItemNum; i++) {
            ObjectDelete(currChart, listSelectedItem[i]);
        }
        currChart = ChartNext(currChart);
    }
}

int higherTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_M15;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_D1; break;
        case PERIOD_H4:  retTF = PERIOD_D1; break;
        case PERIOD_M15: retTF = PERIOD_H4; break;
        case PERIOD_M5: retTF = PERIOD_M15; break;
        case PERIOD_M1: retTF = PERIOD_M5; break;
    }
    return retTF;
}

int lowerTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_M15;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_H4; break;
        case PERIOD_H4:  retTF = PERIOD_M15; break;
        case PERIOD_M15: retTF = PERIOD_M5; break;
        case PERIOD_M5:  retTF = PERIOD_M1; break;
        case PERIOD_M1:  retTF = PERIOD_M1; break;
    }
    return retTF;
}

void restoreBacktestingTrade() // TODO: Đẩy vào Trade Class
{
    long chartID = ChartID();
    string objEn = "";
    string enData = "";

    string sparamItems[];
    double size;

    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;
    datetime time1;
    datetime time2; // = time1 + 10 candle
    bool isBuy;

    for (int idx = 0; idx < 1000; idx++) {
        // Step 1: Find obj
        objEn = "sim#3d_en#" + IntegerToString(idx);
        if (ObjectFind(objEn) < 0) continue;

        // Step 2: extract data
        enData = ObjectGetString(chartID, objEn, OBJPROP_TOOLTIP);
        StringSplit(enData,'\n',sparamItems);
        size    = StrToDouble(StringSubstr(sparamItems[1], 6, 4));
        time1   = (datetime)ObjectGet(objEn, OBJPROP_TIME1);
        isBuy   = ((color)ObjectGet(objEn, OBJPROP_COLOR) == clrBlue);

        priceEN = ObjectGet(objEn, OBJPROP_PRICE1);
        priceSL = NormalizeDouble(priceEN - (isBuy ? 1 : -1) * 100 / size / 100000, 5);
        priceTP = priceEN + 2 * (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        priceBE = priceEN + (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        time2   = time1 + ChartPeriod()*600;
        // Step 3: Create Trade
        gpTrade.createTrade(idx, time1, time2, priceEN, priceSL, priceTP, priceBE);
    }
}
