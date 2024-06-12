#define MAX_SYNC_ITEMS 50

struct ObjectProperty
{
    // Common Property
    string      Name        ;
    ENUM_OBJECT Type        ;
    datetime    Time1       ;
    double      Price1      ;
    int         Style       ;
    int         Width       ;
    int         Back        ;
    int         Selectable  ;
    int         Hidden      ;
    color       Color       ;
    string      Text        ;
    string      Tooltip     ;
    // Property for 2 point item
    datetime    Time2       ;
    double      Price2      ;
    // Property for text item
    string      FontName    ;
    int         FontSize    ;
    int         Anchor      ;
    int         Corner      ;
    // Property for label
    int         XDistance   ;
    int         YDistance   ;
    // Others
    int         Ray         ;
    int         ArrowCode   ;
};

ObjectProperty gListSyncProp[MAX_SYNC_ITEMS+1];
void syncTimmyItem()
{
    // Find selected item
    long chartID = ChartID();
    int itemNum = 0;
    string objName      = "";
    string syncItemToTargetChartsStr = "";
    string splitItems[];
    int splitNum;
    string mainObj = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (StringFind(objName, TAG_CTRM) < 0) continue;
        splitNum = StringSplit(objName,'_',splitItems);
        if (splitNum != 3) continue;
        if (splitItems[0] == Rectangle::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Rectangle::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == Fibonacci::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Fibonacci::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == Trend::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Trend::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == Alert::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Alert::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == CallOut::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = CallOut::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == Point::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Point::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == Trade::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = Trade::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == ZigZag::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = ZigZag::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
        else if (splitItems[0] == LabelText::Tag){
            mainObj = objName;
            syncItemToTargetChartsStr = LabelText::getAllItem(splitItems[0] + "_" + splitItems[1]);
            break;
        }
    }

    splitNum=StringSplit(syncItemToTargetChartsStr,'.',splitItems);
    for (int i = 0; i < splitNum; i++)
    {
        if (splitItems[i] == "") continue;
        objName = "."+splitItems[i];
        ENUM_OBJECT objType = (ENUM_OBJECT)ObjectType(objName);
        if (objType == -1) continue; // Object chưa được tạo
        gListSyncProp[itemNum].Name         = objName;
        gListSyncProp[itemNum].Type         = objType;
        gListSyncProp[itemNum].Time1        = (datetime)ObjectGet(objName, OBJPROP_TIME1);
        gListSyncProp[itemNum].Price1       = ObjectGet(objName, OBJPROP_PRICE1);

        gListSyncProp[itemNum].Style        = (int)ObjectGet(objName, OBJPROP_STYLE);
        gListSyncProp[itemNum].Width        = (int)ObjectGet(objName, OBJPROP_WIDTH);
        gListSyncProp[itemNum].Back         = (int)ObjectGet(objName, OBJPROP_BACK);
        gListSyncProp[itemNum].Selectable   = (int)ObjectGet(objName, OBJPROP_SELECTABLE);
        gListSyncProp[itemNum].Hidden       = (int)ObjectGetInteger(chartID, objName, OBJPROP_HIDDEN);
        gListSyncProp[itemNum].Color        = (color)ObjectGet(objName, OBJPROP_COLOR);
        gListSyncProp[itemNum].Text         = ObjectDescription(objName);
        gListSyncProp[itemNum].Tooltip      = ObjectGetString(chartID, objName, OBJPROP_TOOLTIP);

        if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE || objType == OBJ_RECTANGLE) {
            gListSyncProp[itemNum].Time2    = (datetime)ObjectGet(objName, OBJPROP_TIME2);
            gListSyncProp[itemNum].Price2   = ObjectGet(objName, OBJPROP_PRICE2);
        }
        if (objType == OBJ_TEXT || objType == OBJ_LABEL) {
            gListSyncProp[itemNum].FontName = ObjectGetString(chartID, objName, OBJPROP_FONT);
            gListSyncProp[itemNum].FontSize = (int)ObjectGet(objName, OBJPROP_FONTSIZE);
            gListSyncProp[itemNum].Anchor   = (int)ObjectGet(objName, OBJPROP_ANCHOR);
            gListSyncProp[itemNum].Corner   = (int)ObjectGet(objName, OBJPROP_CORNER);
        }
        if (objType == OBJ_LABEL) {
            gListSyncProp[itemNum].XDistance= (int)ObjectGet(objName, OBJPROP_XDISTANCE);
            gListSyncProp[itemNum].YDistance= (int)ObjectGet(objName, OBJPROP_YDISTANCE);
        }
        if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE) {
            gListSyncProp[itemNum].Ray        = (int)ObjectGet(objName, OBJPROP_RAY);
        }
        if (objType == OBJ_ARROW) {
            gListSyncProp[itemNum].ArrowCode  = (int)ObjectGet(objName, OBJPROP_ARROWCODE);
        }

        itemNum++;
        if (itemNum >= MAX_SYNC_ITEMS) return;
    }

    if (itemNum == 0) {
        syncChartPosition();
        return;
    }

    long curChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    while(curChart > 0)
    {
        if (ChartSymbol(curChart) == chartSymbol && curChart != chartID) {
            // bool objectExit = (ObjectFind(curChart, mainObj) >= 0);
            for (int i = 0; i < itemNum; i++) {
                syncItemToTargetChart(gListSyncProp[i], curChart, false);
            }
        }
        curChart = ChartNext(curChart);
    }
}

void syncItemToTargetChart(ObjectProperty &objProp, long chartId, bool objectExit)
{
    ENUM_OBJECT objType = objProp.Type;
    if(objectExit == false) {
        ObjectCreate(chartId,
                    objProp.Name,
                    objProp.Type,
                    0,
                    objProp.Time1,
                    objProp.Price1);
    }
    else {
    }
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_TIME1, objProp.Time1);
    ObjectSetDouble (chartId, objProp.Name, OBJPROP_PRICE1, objProp.Price1);
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_STYLE      , objProp.Style      );
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_WIDTH      , objProp.Width      );
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_BACK       , objProp.Back       );
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_SELECTABLE , objProp.Selectable );
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_HIDDEN     , objProp.Hidden     );
    ObjectSetInteger(chartId, objProp.Name, OBJPROP_COLOR      , objProp.Color      );
    ObjectSetString(chartId , objProp.Name, OBJPROP_TEXT       , objProp.Text       );
    ObjectSetString(chartId , objProp.Name, OBJPROP_TOOLTIP    , getTFString());

    if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE || objType == OBJ_RECTANGLE) {
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_TIME2, objProp.Time2);
        ObjectSetDouble (chartId, objProp.Name, OBJPROP_PRICE2, objProp.Price2);
    }
    if (objType == OBJ_TEXT || objType == OBJ_LABEL) {
        ObjectSetString(chartId , objProp.Name, OBJPROP_FONT       , objProp.FontName);
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_FONTSIZE   , objProp.FontSize);
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_ANCHOR     , objProp.Anchor);
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_CORNER     , objProp.Corner);
    }
    if (objType == OBJ_LABEL) {
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_XDISTANCE, objProp.XDistance);
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_YDISTANCE, objProp.YDistance);
    }
    if (objType == OBJ_TREND || objType == OBJ_TRENDBYANGLE) {
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_RAY        , objProp.Ray        );
    }
    if (objType == OBJ_ARROW) {
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_ARROWCODE  , objProp.ArrowCode  );
        // Remove color of Arrow
        ObjectSetInteger(chartId, objProp.Name, OBJPROP_COLOR      , clrNONE);
    }
}

void deleteTimmyItem()
{
    // Find selected item
    string objName = "";
    string mainObj = ""; 
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (StringFind(objName, TAG_CTRM) < 0) continue;
        mainObj = objName;
        break;
    }
    if (mainObj == "") return;

    long curChart = ChartFirst();
    while(curChart > 0)
    {
        ObjectDelete(curChart, mainObj);
        curChart = ChartNext(curChart);
    }
}

void syncChartPosition()
{
    // Find current POS
    int shift = iBarShift(ChartSymbol(), ChartPeriod(), gCommonData.mMouseTime);
    int distance_m = shift * Period();
    
    double fixedMax = ChartGetDouble(ChartID(),CHART_FIXED_MAX);
    double fixedMin = ChartGetDouble(ChartID(),CHART_FIXED_MIN);

    long curChart = ChartFirst();
    string chartSymbol = ChartSymbol();
    int curPeriod;
    long chartID = ChartID();
    while(curChart > 0)
    {
        if (ChartSymbol(curChart) == chartSymbol && curChart != chartID) {
            curPeriod = ChartPeriod(curChart);
            shift = distance_m / curPeriod;
            ChartNavigate(curChart, CHART_END, -shift);
            ChartSetDouble(curPeriod,CHART_FIXED_MAX, fixedMax);
            ChartSetDouble(curPeriod,CHART_FIXED_MIN, fixedMin);
        }
        curChart = ChartNext(curChart);
    }
}