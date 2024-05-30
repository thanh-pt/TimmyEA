#include "../Base/BaseItem.mqh"

input string            Rect_;                              // ●  S U P P L Y   D E M A N D  ●
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

#define CTX_RANGE   "Range"
#define CTX_NORANGE "xRange"

enum RectangleType
{
    SZ_LIGHT_TYPE,
    SZ_POI_TYPE,
    DZ_LIGHT_TYPE,
    DZ_POI_TYPE,
    RECT_NUM,
};

class Rectangle : public BaseItem
{
// Internal Value
private:
    color mPropColor[CTX_MAX];

// Component name
private:
    string cBgM0;
    string cPtL1;
    string cPtL2;
    string cPtR1;
    string cPtR2;
    string cPtC1;
    string cPtC2;

    string iTxtC;
    string iTxtL;
    string iTxtR;
    string iLn01;
    string iLn02;
    string iLn03;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double   price1;
    double   price2;

    double   centerPrice;
    datetime centerTime;

public:
    Rectangle(CommonData* commonData, MouseInfo* mouseInfo);

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

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Rectangle::Tag = ".TMRect";

Rectangle::Rectangle(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Rectangle::Tag;
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
    mContextType += "," + CTX_RANGE;
    mContextType += "," + CTX_NORANGE;
}

// Internal Event
void Rectangle::prepareActive(){}
void Rectangle::createItem()
{
    ObjectCreate(cBgM0, OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPtL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtC2, OBJ_ARROW, 0, 0, 0);

    ObjectCreate(iTxtC, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtL, OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtR, OBJ_TEXT      , 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();
    // Value define update
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Rectangle::updateDefaultProperty()
{
    setMultiProp(OBJPROP_ARROWCODE,       4, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
    setMultiProp(OBJPROP_COLOR    , clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);

    setTextContent(iTxtC, "", 8, FONT_TEXT, Rect_Text_Color);
    setTextContent(iTxtL, "", 8, FONT_TEXT, Rect_Text_Color);
    setTextContent(iTxtR, "", 8, FONT_TEXT, Rect_Text_Color);

    ObjectSetInteger(ChartID(), iTxtC, OBJPROP_ANCHOR, ANCHOR_CENTER);
    ObjectSetInteger(ChartID(), iTxtL, OBJPROP_ANCHOR, ANCHOR_LEFT);
    ObjectSetInteger(ChartID(), iTxtR, OBJPROP_ANCHOR, ANCHOR_RIGHT);

    setMultiProp(OBJPROP_SELECTABLE, false         , iTxtC+iTxtL+iTxtR);
    setMultiStrs(OBJPROP_TOOLTIP   , "\n"          , mAllItem);
}
void Rectangle::updateTypeProperty()
{
    setRectangleBackground(cBgM0, mPropColor[mIndexType]);
}
void Rectangle::activateItem(const string& itemId)
{
    cBgM0 = itemId + TAG_CTRM + "cBgM0";
    cPtL1 = itemId + TAG_CTRL + "cPtL1";
    cPtL2 = itemId + TAG_CTRL + "cPtL2";
    cPtR1 = itemId + TAG_CTRL + "cPtR1";
    cPtR2 = itemId + TAG_CTRL + "cPtR2";
    cPtC1 = itemId + TAG_CTRL + "cPtC1";
    cPtC2 = itemId + TAG_CTRL + "cPtC2";
    iTxtC = itemId + TAG_INFO + "iTxtC";
    iTxtL = itemId + TAG_INFO + "iTxtL";
    iTxtR = itemId + TAG_INFO + "iTxtR";
    iLn01 = itemId + TAG_INFO + "iLn01";
    iLn02 = itemId + TAG_INFO + "iLn02";
    iLn03 = itemId + TAG_INFO + "iLn03";

    mAllItem += cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2+cBgM0
                +iTxtC+iTxtL+iTxtR
                +iLn01+iLn02+iLn03;
}

string Rectangle::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxtC";
    allItem += itemId + TAG_INFO + "iTxtL";
    allItem += itemId + TAG_INFO + "iTxtR";
    allItem += itemId + TAG_INFO + "iLn01";
    allItem += itemId + TAG_INFO + "iLn02";
    allItem += itemId + TAG_INFO + "iLn03";
    //--- Control item ---
    allItem += itemId + TAG_CTRM + "cBgM0";
    allItem += itemId + TAG_CTRL + "cPtL1";
    allItem += itemId + TAG_CTRL + "cPtL2";
    allItem += itemId + TAG_CTRL + "cPtR1";
    allItem += itemId + TAG_CTRL + "cPtR2";
    allItem += itemId + TAG_CTRL + "cPtC1";
    allItem += itemId + TAG_CTRL + "cPtC2";

    return allItem;
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

    setItemPos(cPtL1, time1, price1);
    setItemPos(cPtL2, time1, price2);
    setItemPos(cPtR1, time2, price1);
    setItemPos(cPtR2, time2, price2);
    setItemPos(cPtC1, time1, centerPrice);
    setItemPos(cPtC2, time2, centerPrice);

    setItemPos(cBgM0, time1, time2, price1, price2);
    setItemPos(iLn01, time1, time2, price1, price1);
    setItemPos(iLn02, time1, time2, centerPrice, centerPrice);
    setItemPos(iLn03, time1, time2, price2, price2);
    //-------------------------------------------------
    setItemPos(iTxtL, time1 + ChartPeriod()*60, centerPrice);
    setItemPos(iTxtR, time2 - ChartPeriod()*60, centerPrice);
    setItemPos(iTxtC, centerTime, centerPrice);
    //-------------------------------------------------
    setTextContent(iTxtL, ObjectDescription(cPtC1));
    setTextContent(iTxtR, ObjectDescription(cPtC2));
    //-------------------------------------------------
    scanBackgroundOverlap(cBgM0);
    //-------------------------------------------------
    int selected = (int)ObjectGet(cBgM0, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
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
        if (objId == cPtL1 || objId == cPtR2 || objId == cPtL2 || objId == cPtR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
    }

    if (objId == cPtL1 || objId == cPtR2 )
    {
        time1  = (datetime)ObjectGet(cPtL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPtL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPtR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPtR2, OBJPROP_PRICE1);
    }
    else if (objId == cPtL2 || objId == cPtR1)
    {
        time1  = (datetime)ObjectGet(cPtL2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPtL2, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPtR1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPtR1, OBJPROP_PRICE1);
    }
    else
    {
        time1  = (datetime)ObjectGet(cPtL1, OBJPROP_TIME1);
        price1 =           ObjectGet(cPtL1, OBJPROP_PRICE1);
        time2  = (datetime)ObjectGet(cPtR2, OBJPROP_TIME1);
        price2 =           ObjectGet(cPtR2, OBJPROP_PRICE1);
        if (objId == cPtC1)
        {
            time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
        else if (objId == cPtC2)
        {
            time2 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        }
    }
    if (objId == cBgM0)
    {
        if (MathAbs(time2-time1)/ChartPeriod()/60 > 15)
        {
            time1  = (datetime)ObjectGet(cBgM0, OBJPROP_TIME1);
            time2  = (datetime)ObjectGet(cBgM0, OBJPROP_TIME2);
            price1 =           ObjectGet(cBgM0, OBJPROP_PRICE1);
            price2 =           ObjectGet(cBgM0, OBJPROP_PRICE2);
        }
    }
    refreshData();
}
void Rectangle::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && pCommonData.mShiftHold) gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gColorMousePoint : clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
}
void Rectangle::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cBgM0) {
        string description = ObjectDescription(objId);
        if (description != ""){
            setTextContent(objId, "");
            setTextContent(iTxtC, (description == "-") ? EMPTY_STR : description);
        }
    }
    onItemDrag(itemId, objId);
}
void Rectangle::onItemDeleted(const string &itemId, const string &objId)
{
    BaseItem::onItemDeleted(itemId, objId);
    removeBackgroundOverlap(cBgM0);
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
    } else if (gContextMenu.mActiveItemStr == CTX_RANGE) {
        ObjectCreate(iLn01, OBJ_TREND, 0, 0, 0);
        ObjectCreate(iLn02, OBJ_TREND, 0, 0, 0);
        ObjectCreate(iLn03, OBJ_TREND, 0, 0, 0);
        
        setMultiProp(OBJPROP_SELECTABLE, false, iLn01+iLn02+iLn03);
        setObjectStyle(iLn01, clrGray, 0, 0, true);
        setObjectStyle(iLn02, clrSilver, 0, 0, true);
        setObjectStyle(iLn03, clrGray, 0, 0, true);
        onItemDrag(itemId, objId);
    } else if (gContextMenu.mActiveItemStr == CTX_NORANGE) {
        setObjectStyle(iLn01, clrNONE, 0, 0);
        setObjectStyle(iLn02, clrNONE, 0, 0);
        setObjectStyle(iLn03, clrNONE, 0, 0);
    }
}
