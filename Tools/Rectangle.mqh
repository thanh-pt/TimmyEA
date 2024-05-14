#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

input string            Rect_;                              //● Supply & Demand ●
input color             Rect_Text_Color  = clrMidnightBlue; //Text Color
//-----------------------------------------------------------
      string            Rect_Sz_Name       = "Sz";
input color             Rect_Sz_Color      = C'255,200,200'; // Sz Color
//-----------------------------------------------------------
      string            Rect_SzLight_Name  = "lSz";
input color             Rect_SzLight_Color = C'255,234,234'; // Sz Light Color
//-----------------------------------------------------------
      string            Rect_Dz_Name       = "Dz";
input color             Rect_Dz_Color      = C'209,225,237'; // Dz Color
//-----------------------------------------------------------
      string            Rect_DzLight_Name  = "lDz";
input color             Rect_DzLight_Color = C'232,240,247'; // Dz Light Color
//-----------------------------------------------------------

enum RectangleType
{
    SZ_POI_TYPE,
    DZ_POI_TYPE,
    RECT_NUM,
    //Disable Light Type
    SZ_LIGHT_TYPE,
    DZ_LIGHT_TYPE,
};

class Rectangle : public BaseItem
{
// Internal Value
private:
    color mPropColor[MAX_TYPE];

// Component name
private:
    string cBkgnd;
    string iCText;
    string iLText;
    string iRText;

    string iLine1;
    string iLine2;
    string iLine3;

    string cPointL1;
    string cPointL2;
    string cPointR1;
    string cPointR2;
    string cPointC1;
    string cPointC2;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;

    double   centerPrice;
    datetime centerTime;

public:
    Rectangle(const string name, CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void prepareActive();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void activateItem(const string& itemId);
    virtual void updateItemAfterChangeType();
    virtual void refreshData();
    virtual void finishedJobDone();

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
    virtual void onItemDeleted(const string &itemId, const string &objId);
    virtual void onUserRequest(const string &itemId, const string &objId);
};

Rectangle::Rectangle(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [SZ_POI_TYPE]   = Rect_Sz_Name      ;
    mPropColor[SZ_POI_TYPE]   = Rect_Sz_Color     ;
    //------------------------------------------
    mNameType [DZ_POI_TYPE]   = Rect_Dz_Name      ;
    mPropColor[DZ_POI_TYPE]   = Rect_Dz_Color     ;
    //------------------------------------------
    mNameType [SZ_LIGHT_TYPE] = Rect_SzLight_Name ;
    mPropColor[SZ_LIGHT_TYPE] = Rect_SzLight_Color;
    //------------------------------------------
    mNameType [DZ_LIGHT_TYPE] = Rect_DzLight_Name ;
    mPropColor[DZ_LIGHT_TYPE] = Rect_DzLight_Color;
    //------------------------------------------
    mIndexType = 0;
    mTypeNum = RECT_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mContextType += mNameType[i];
        if (i < mTypeNum-1) mContextType += ",";
    }
    mContextType += "," + "Range";
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(cPointL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC2, OBJ_ARROW, 0, 0, 0);

    ObjectCreate(iCText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iLText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iRText, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBkgnd, OBJ_RECTANGLE , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    // Value define update
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Rectangle::updateDefaultProperty()
{
    multiSetProp(OBJPROP_ARROWCODE,       4, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_COLOR    , clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);

    ObjectSetText(iCText, "");
    ObjectSetText(iLText, "");
    ObjectSetText(iRText, "");

    ObjectSetInteger(ChartID(), iCText, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), iLText, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(ChartID(), iRText, OBJPROP_ANCHOR, ANCHOR_RIGHT);

    multiSetProp(OBJPROP_COLOR     , Rect_Text_Color, iCText+iLText+iRText);
    multiSetProp(OBJPROP_SELECTABLE, false         , iCText+iLText+iRText);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"          , cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+cBkgnd+iCText+iLText+iRText);
}
void Rectangle::updateTypeProperty()
{
    SetRectangleBackground(cBkgnd, mPropColor[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    cBkgnd = itemId + "_c0Bkgnd";
    iCText = itemId + "_0iCText";
    iLText = itemId + "_0iLText";
    iRText = itemId + "_0iRText";

    iLine1 = itemId + "_0iLine1";
    iLine2 = itemId + "_0iLine2";
    iLine3 = itemId + "_0iLine3";

    cPointL1 = itemId + "_cPointL1";
    cPointL2 = itemId + "_cPointL2";
    cPointR1 = itemId + "_cPointR1";
    cPointR2 = itemId + "_cPointR2";
    cPointC1 = itemId + "_cPointC1";
    cPointC2 = itemId + "_cPointC2";

    mAllItem += cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+cBkgnd
                +iCText+iLText+iRText
                +iLine1+iLine2+iLine3;
}
void Rectangle::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
    }
}
void Rectangle::refreshData()
{
    getCenterPos(time1, time2, price1, price2, centerTime, centerPrice);

    setItemPos(cPointL1, time1, price1);
    setItemPos(cPointL2, time1, price2);
    setItemPos(cPointR1, time2, price1);
    setItemPos(cPointR2, time2, price2);
    setItemPos(cPointC1, time1, centerPrice);
    setItemPos(cPointC2, time2, centerPrice);

    setItemPos(cBkgnd, time1, time2, price1, price2);
    setItemPos(iLine1, time1, time2, price1, price1);
    setItemPos(iLine2, time1, time2, centerPrice, centerPrice);
    setItemPos(iLine3, time1, time2, price2, price2);
    //-------------------------------------------------
    setTextPos(iLText, time1 + ChartPeriod()*60, centerPrice);
    setTextPos(iRText, time2 - ChartPeriod()*60, centerPrice);
    setTextPos(iCText, centerTime, centerPrice);
    //-------------------------------------------------
    scanBackgroundOverlap(cBkgnd);
    //-------------------------------------------------
    int selected = (int)ObjectGet(cBkgnd, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+cBkgnd+iCText+iLText+iRText);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
}
void Rectangle::finishedJobDone(){}

// Chart Event
void Rectangle::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2  = pCommonData.mMouseTime;
    price2 = pCommonData.mMousePrice;
    refreshData();
}
void Rectangle::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Rectangle::onItemDrag(const string &itemId, const string &objId)
{
    gContextMenu.clearContextMenu();
    if (pCommonData.mCtrlHold)
    {
        if (objId == cPointL1 || objId == cPointR2 || objId == cPointL2 || objId == cPointR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
    }

    if (objId == cPointL1 || objId == cPointR2 )
    {
        time1  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
    }
    else if (objId == cPointL2 || objId == cPointR1)
    {
        time1  = (datetime)ObjectGet(cPointL2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointL2, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointR1, OBJPROP_PRICE1);
    }
    else
    {
        time1  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
        if (objId == cPointC1)
        {
            time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
        else if (objId == cPointC2)
        {
            time2 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
    }
    if (objId == cBkgnd)
    {
        if (MathAbs(time2-time1)/ChartPeriod()/60 > 15)
        {
            time1  = (datetime)ObjectGet(cBkgnd, OBJPROP_TIME1);
            time2  = (datetime)ObjectGet(cBkgnd, OBJPROP_TIME2);
            price1 =           ObjectGet(cBkgnd, OBJPROP_PRICE1);
            price2 =           ObjectGet(cBkgnd, OBJPROP_PRICE2);
        }
    }
    refreshData();
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, "_0i") >= 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, mAllItem);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    if (selected) {
        unSelectAllExcept(itemId);
        if (StringFind(objId, "_c") >= 0 && pCommonData.mShiftHold)
            gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    }
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    string targetItem;
    if (objId == cBkgnd)        targetItem = iCText;
    else if (objId == cPointC2) targetItem = iRText;
    else if (objId == cPointC1) targetItem = iLText;
    else                      return;
    
    string txtContent = ObjectDescription(objId);
    if (txtContent == "" ) return;
    if (txtContent == "-") txtContent = "";
    ObjectSetText(targetItem, txtContent);
    ObjectSetText(objId, "");
    onItemDrag(itemId, objId);
}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    BaseItem::onItemDeleted(itemId, objId);
    removeBackgroundOverlap(cBkgnd);
}
void Rectangle::onUserRequest(const string &itemId, const string &objId)
{
    touchItem(itemId);
    if (gContextMenu.mActivePos < RECT_NUM)
    {
        mIndexType = gContextMenu.mActivePos;
        storeTData();
        updateTypeProperty();
        onItemDrag(itemId, objId);
    } else if (gContextMenu.mActiveItemStr == "Range") {
        ObjectCreate(iLine1, OBJ_TREND, 0, 0, 0);
        ObjectCreate(iLine2, OBJ_TREND, 0, 0, 0);
        ObjectCreate(iLine3, OBJ_TREND, 0, 0, 0);
        
        multiSetProp(OBJPROP_SELECTABLE, false, iLine1+iLine2+iLine3);
        SetObjectStyle(iLine1, clrGray, 0, 0);
        SetObjectStyle(iLine2, clrGray, 0, 0);
        SetObjectStyle(iLine3, clrGray, 0, 0);
        onItemDrag(itemId, objId);
    }
}
