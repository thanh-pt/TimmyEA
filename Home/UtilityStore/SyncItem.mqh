#define MAX_SYNC_ITEMS 50

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
    ObjectSetString(currChart , objProperty.objName, OBJPROP_TOOLTIP    , getTFString());
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