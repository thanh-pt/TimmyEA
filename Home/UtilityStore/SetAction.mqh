
void setChartFree(bool bFree)
{
    ChartSetInteger(ChartID(),CHART_SCALEFIX,0,bFree);
}

void setScaleChart(bool isUp)
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

// - - - Begin: Overload Object Set Text
void setTextContent(string objName, string content){
    if (content == "" || content == "Text") content = EMPTY_STR;
    ObjectSetText(objName, content);
}
void setTextContent(string objName, string content, int size)
{
    if (content == "" || content == "Text") content = EMPTY_STR;
    ObjectSetText(objName, content, size);
}
void setTextContent(string objName, string content, int size, string font)
{
    if (content == "" || content == "Text") content = EMPTY_STR;
    ObjectSetText(objName, content, size, font);
}
void setTextContent(string objName, string content, int size, string font, color clr)
{
    if (content == "" || content == "Text") content = EMPTY_STR;
    ObjectSetText(objName, content, size, font, clr);
}
// - - - End: Overload Object Set Text

void setMultiProp(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSet("."+sparamItems[i], property, value);
    }
}

void setMultiStrs(int property, string value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetString(ChartID(), "."+sparamItems[i], property, value);
    }
}

void setMultiInts(int property, int value, string listObj)
{
    string sparamItems[];
    int k=StringSplit(listObj,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        ObjectSetInteger(ChartID(), "."+sparamItems[i], property, value);
    }
}

void setRectangleBackground(string obj, color c)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , true);
    ObjectSet(obj, OBJPROP_STYLE, 2); // Dot as default
}

void setObjectStyle(string obj, color c, int style, int width)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , false);
    ObjectSet(obj, OBJPROP_RAY  , false);
    ObjectSet(obj, OBJPROP_STYLE, style);
    ObjectSet(obj, OBJPROP_WIDTH, width);
}

void setObjectStyle(string obj, color c, int style, int width, bool isBack)
{
    ObjectSet(obj, OBJPROP_COLOR, c);
    ObjectSet(obj, OBJPROP_BACK , isBack);
    ObjectSet(obj, OBJPROP_RAY  , false);
    ObjectSet(obj, OBJPROP_STYLE, style);
    ObjectSet(obj, OBJPROP_WIDTH, width);
}

void setUnselectAll()
{
    string currentItemId;
    string sparamItems[];
    int k;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        ObjectSet(objName, OBJPROP_SELECTED, 0);

        if (StringFind(objName, TAG_CTRM) == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        
        if (k != 3) continue;
        string itemId = sparamItems[0] + "_" + sparamItems[1];
        
        if (itemId == currentItemId) continue;
        currentItemId = itemId;
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, objName);
    }
    gContextMenu.clearContextMenu();
}

void setUnselectAllExcept(string objId)
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

        if (StringFind(objName, TAG_CTRM) == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        
        if (k != 3) continue;
        string itemId = sparamItems[0] + "_" + sparamItems[1];
        
        if (itemId == currentItemId) continue;
        currentItemId = itemId;
        gController.handleSparamEvent(CHARTEVENT_OBJECT_DRAG, objName);
    }
    gContextMenu.clearContextMenu();
}

void setCtrlItemSelectState(string lstItem, int selecteState)
{
    string sparamItems[];
    int k=StringSplit(lstItem,'.',sparamItems);
    for (int i = 0; i < k; i++)
    {
        if (sparamItems[i] == "") continue;
        if (StringFind(sparamItems[i], TAG_CTRL) < 0) continue;
        ObjectSet("."+sparamItems[i], OBJPROP_SELECTED, selecteState);
    }
}