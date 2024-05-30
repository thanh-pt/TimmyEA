#include "../Base/BaseItem.mqh"

input string          Fib_;    // ●  F I B O N A C I I  ●
//--------------------------------------------
input color           Fib_Bkgrd_Color = clrNONE;    // Bg Color
input ELineStyle      Fib_Style     = eLineSolid;  // Style
//--------------------------------------------
string          Fib_0;    //→ Fib 0
double          Fib_0_Ratio = 0;              // Ratio
string          Fib_0_Text  = "0";            // Text
color           Fib_0_Color = clrGray;        // Color
//--------------------------------------------
string          Fib_1;    //→ Fib 1
double          Fib_1_Ratio = 1;              // Ratio
string          Fib_1_Text  = "1";            // Text
color           Fib_1_Color = clrGray;        // Color
//--------------------------------------------
string          Fib_2;    //→ Fib 2
double          Fib_2_Ratio = 0.5;            // Ratio
string          Fib_2_Text  = "0.5";          // Text
color           Fib_2_Color = clrLightGray;   // Color
//--------------------------------------------
string          Fib_3_Text  = "0.382";
double          Fib_3_Ratio = 0.382;
color           Fib_3_Color = clrLightGray;
//--------------------------------------------
string          Fib_4_Text  = "-0.27";
double          Fib_4_Ratio = -0.27;
color           Fib_4_Color = clrDarkOrange;
//--------------------------------------------
string          Fib_5_Text  = "-0.62";
double          Fib_5_Ratio = -0.62;
color           Fib_5_Color = clrRed;

enum FibType
{
    FIB_RANGE,
    FIB_FULL,
    FIB_RANGE_EXT,
    FIB_NUM,
    FIB_RANGE2, // Don't use this
};

class Fibonacci : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cBgM0;
    string cPtL1;
    string cPtL2;
    string cPtR1;
    string cPtR2;
    string cPtC1;
    string cPtC2;

    string iLn00;
    string iLn01;
    string iLn02;
    string iLn03;
    string iLn04;
    string iLn05;
    string iTxt0;
    string iTxt1;
    string iTxt2;
    string iTxt3;
    string iTxt4;
    string iTxt5;

// Value define for Item
private:
    datetime time0;
    datetime time1;
    double price0;
    double price1;

    double   centerPrice;
    datetime centerTime;

public:
    Fibonacci(CommonData* commonData, MouseInfo* mouseInfo);

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

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Fibonacci::Tag = ".TMFib";

Fibonacci::Fibonacci(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Fibonacci::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mIndexType = 0;
    mNameType[FIB_RANGE]     = "Range";
    // mNameType[FIB_RANGE2]    = "Range2";
    mNameType[FIB_RANGE_EXT] = "RangeExt";
    mNameType[FIB_FULL]      = "Fib";
    mTypeNum = FIB_NUM;
    for (int i = 0; i < mTypeNum; i++)
    {
        mContextType += mNameType[i];
        if (i < mTypeNum-1) mContextType += ",";
    }
}

// Internal Event
void Fibonacci::prepareActive(){}
void Fibonacci::createItem()
{
    if (Fib_0_Color != clrNONE) ObjectCreate(iLn00, OBJ_TREND, 0, 0, 0);
    if (Fib_1_Color != clrNONE) ObjectCreate(iLn01, OBJ_TREND, 0, 0, 0);
    if (Fib_2_Color != clrNONE) ObjectCreate(iLn02, OBJ_TREND, 0, 0, 0);
    if (Fib_3_Color != clrNONE) ObjectCreate(iLn03, OBJ_TREND, 0, 0, 0);
    if (Fib_4_Color != clrNONE) ObjectCreate(iLn04, OBJ_TREND, 0, 0, 0);
    if (Fib_5_Color != clrNONE) ObjectCreate(iLn05, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (Fib_0_Color != clrNONE /*&& Fib_0_Text != ""*/) ObjectCreate(iTxt0, OBJ_TEXT, 0, 0, 0);
    if (Fib_1_Color != clrNONE /*&& Fib_1_Text != ""*/) ObjectCreate(iTxt1, OBJ_TEXT, 0, 0, 0);
    if (Fib_2_Color != clrNONE /*&& Fib_2_Text != ""*/) ObjectCreate(iTxt2, OBJ_TEXT, 0, 0, 0);
    if (Fib_3_Color != clrNONE /*&& Fib_3_Text != ""*/) ObjectCreate(iTxt3, OBJ_TEXT, 0, 0, 0);
    if (Fib_4_Color != clrNONE /*&& Fib_4_Text != ""*/) ObjectCreate(iTxt4, OBJ_TEXT, 0, 0, 0);
    if (Fib_5_Color != clrNONE /*&& Fib_5_Text != ""*/) ObjectCreate(iTxt5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(cBgM0, OBJ_RECTANGLE, 0, 0, 0);

    ObjectCreate(cPtL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPtC2, OBJ_ARROW, 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    setMultiProp(OBJPROP_STYLE        , getLineStyle(Fib_Style), iLn00+iLn01+iLn02+iLn03+iLn04+iLn05);
    setMultiProp(OBJPROP_BACK         , true      , iLn00+iLn01+iLn02+iLn03+iLn04+iLn05);
    setMultiProp(OBJPROP_SELECTABLE   , false     , iLn00+iLn01+iLn02+iLn03+iLn04+iLn05
                                                   +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    setMultiInts(OBJPROP_ANCHOR, ANCHOR_RIGHT     , iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    setMultiInts(OBJPROP_HIDDEN, true, iLn00+iLn01+iLn02+iLn03+iLn04+iLn05
                                      +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);

    setMultiProp(OBJPROP_ARROWCODE,       4, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
    setMultiProp(OBJPROP_COLOR    , clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
    
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Fibonacci::updateTypeProperty()
{
    //------------------------------------------
    setTextContent(iTxt0, Fib_0_Text + "  ", 7, FONT_TEXT, Fib_0_Color);
    setTextContent(iTxt1, Fib_1_Text + "  ", 7, FONT_TEXT, Fib_1_Color);
    setTextContent(iTxt2, Fib_2_Text + "  ", 7, FONT_TEXT, Fib_2_Color);
    setTextContent(iTxt3, Fib_3_Text + "  ", 7, FONT_TEXT, Fib_3_Color);
    setTextContent(iTxt4, Fib_4_Text + "  ", 7, FONT_TEXT, Fib_4_Color);
    setTextContent(iTxt5, Fib_5_Text + "  ", 7, FONT_TEXT, Fib_5_Color);
    //------------------------------------------
    setRectangleBackground(cBgM0, Fib_Bkgrd_Color);
    setMultiProp(OBJPROP_RAY, false, iLn00+iLn01+iLn02+iLn03+iLn04+iLn05);
    setMultiProp(OBJPROP_WIDTH     , getLineWidth(Fib_Style), iLn00+iLn01+iLn02+iLn03+iLn04+iLn05);
    //------------------------------------------
    ObjectSet(iLn00, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(iLn01, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(iLn02, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(iLn03, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(iLn04, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(iLn05, OBJPROP_COLOR, Fib_5_Color);

    if (mIndexType != FIB_FULL) {
        setMultiProp(OBJPROP_COLOR, clrNONE, iLn03+iLn04+iLn05 + iTxt3+iTxt4+iTxt5);
    }
    if (mIndexType == FIB_RANGE || mIndexType == FIB_RANGE_EXT){
        setTextContent(iTxt2, EMPTY_STR, 8);
        setMultiProp(OBJPROP_COLOR, clrDarkOrange, iLn02);
    }
    if (mIndexType == FIB_RANGE_EXT) {
        setMultiProp(OBJPROP_RAY, true, iLn00+iLn01);
        setMultiProp(OBJPROP_WIDTH, getLineWidth(Fib_Style)+1, iLn00+iLn01);
        setRectangleBackground(cBgM0, C'252,252,252');
    }
    if (mIndexType == FIB_RANGE2){
        setTextContent(iTxt0, EMPTY_STR);
        setTextContent(iTxt1, EMPTY_STR);
        setTextContent(iTxt2, EMPTY_STR);
        setRectangleBackground(cBgM0, clrOldLace);
        setMultiProp(OBJPROP_WIDTH, getLineWidth(Fib_Style)+1, iLn00+iLn01);
    }
}
void Fibonacci::activateItem(const string& itemId)
{
    cBgM0 = itemId + TAG_CTRM + "cBgM0";
    cPtL1 = itemId + TAG_CTRL + "cPtL1";
    cPtL2 = itemId + TAG_CTRL + "cPtL2";
    cPtR1 = itemId + TAG_CTRL + "cPtR1";
    cPtR2 = itemId + TAG_CTRL + "cPtR2";
    cPtC1 = itemId + TAG_CTRL + "cPtC1";
    cPtC2 = itemId + TAG_CTRL + "cPtC2";
    iLn00 = itemId + TAG_INFO + "iLn00";
    iLn01 = itemId + TAG_INFO + "iLn01";
    iLn02 = itemId + TAG_INFO + "iLn02";
    iLn03 = itemId + TAG_INFO + "iLn03";
    iLn04 = itemId + TAG_INFO + "iLn04";
    iLn05 = itemId + TAG_INFO + "iLn05";
    iTxt0 = itemId + TAG_INFO + "iTxt0";
    iTxt1 = itemId + TAG_INFO + "iTxt1";
    iTxt2 = itemId + TAG_INFO + "iTxt2";
    iTxt3 = itemId + TAG_INFO + "iTxt3";
    iTxt4 = itemId + TAG_INFO + "iTxt4";
    iTxt5 = itemId + TAG_INFO + "iTxt5";

    mAllItem += cBgM0+iLn00+iLn01+iLn02+iLn03+iLn04+iLn05+iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5
                +cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2;
}

string Fibonacci::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iLn00";
    allItem += itemId + TAG_INFO + "iLn01";
    allItem += itemId + TAG_INFO + "iLn02";
    allItem += itemId + TAG_INFO + "iLn03";
    allItem += itemId + TAG_INFO + "iLn04";
    allItem += itemId + TAG_INFO + "iLn05";
    allItem += itemId + TAG_INFO + "iTxt0";
    allItem += itemId + TAG_INFO + "iTxt1";
    allItem += itemId + TAG_INFO + "iTxt2";
    allItem += itemId + TAG_INFO + "iTxt3";
    allItem += itemId + TAG_INFO + "iTxt4";
    allItem += itemId + TAG_INFO + "iTxt5";
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

void Fibonacci::updateItemAfterChangeType()
{
    updateTypeProperty();
}
void Fibonacci::refreshData()
{
    double price2 = price1-Fib_2_Ratio*(price1-price0);
    double price3 = price1-Fib_3_Ratio*(price1-price0);
    double price4 = price1-Fib_4_Ratio*(price1-price0);
    double price5 = price1-Fib_5_Ratio*(price1-price0);
    //-------------------------------------------------
    setItemPos(cBgM0, time0, time1, price0, price1);
    setItemPos(iLn00, time0, time1, price0, price0);
    setItemPos(iLn01, time0, time1, price1, price1);
    setItemPos(iLn02, time0, time1, price2, price2);
    setItemPos(iLn03, time0, time1, price3, price3);
    setItemPos(iLn04, time0, time1, price4, price4);
    setItemPos(iLn05, time0, time1, price5, price5);
    //-------------------------------------------------
    setItemPos(iTxt0, time0, price0);
    setItemPos(iTxt1, time0, price1);
    setItemPos(iTxt2, time0, price2);
    setItemPos(iTxt3, time0, price3);
    setItemPos(iTxt4, time0, price4);
    setItemPos(iTxt5, time0, price5);
    //-------------------------------------------------
    getCenterPos(time0, time1, price0, price1, centerTime, centerPrice);

    setItemPos(cPtL1, time0, price0);
    setItemPos(cPtL2, time0, price1);
    setItemPos(cPtR1, time1, price0);
    setItemPos(cPtR2, time1, price1);
    setItemPos(cPtC1, time0, centerPrice);
    setItemPos(cPtC2, time1, centerPrice);
    //-------------------------------------------------
    int selected = (int)ObjectGet(cBgM0, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
    setMultiProp(OBJPROP_SELECTED, selected, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2+cBgM0);
    //-------------------------------------------------
    if (mIndexType == FIB_RANGE || mIndexType == FIB_RANGE_EXT){
        bool isUp = (price1 > price0);
        setTextContent(iTxt0, isUp ? "𝙇 " : "𝙃 ", 8);
        setTextContent(iTxt1, isUp ? "𝙃 " : "𝙇 ", 8);
        setMultiProp(OBJPROP_COLOR, isUp ? clrGreen : clrRed  , iLn00+iTxt0);
        setMultiProp(OBJPROP_COLOR, isUp ? clrRed   : clrGreen, iLn01+iTxt1);
    }

}
void Fibonacci::finishedJobDone(){}

// Chart Event
void Fibonacci::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
    refreshData();
}
void Fibonacci::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Fibonacci::onItemDrag(const string &itemId, const string &objId)
{
    gContextMenu.clearContextMenu();
    if (objId == cBgM0)
    {
        time0   = (datetime)ObjectGet(cBgM0, OBJPROP_TIME1);
        time1   = (datetime)ObjectGet(cBgM0, OBJPROP_TIME2);
        price0  =           ObjectGet(cBgM0, OBJPROP_PRICE1);
        price1  =           ObjectGet(cBgM0, OBJPROP_PRICE2);
    }
    else
    {
        if (pCommonData.mCtrlHold)
        {
            if (objId == cPtL1 || objId == cPtR2 || objId == cPtL2 || objId == cPtR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
        }

        if (objId == cPtL1 || objId == cPtR2 )
        {
            time0  = (datetime)ObjectGet(cPtL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPtL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPtR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPtR2, OBJPROP_PRICE1);
        }
        else if (objId == cPtL2 || objId == cPtR1)
        {
            time0  = (datetime)ObjectGet(cPtL2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPtL2, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPtR1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPtR1, OBJPROP_PRICE1);
        }
        else
        {
            time0  = (datetime)ObjectGet(cPtL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPtL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPtR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPtR2, OBJPROP_PRICE1);
            if (objId == cPtC1)
            {
                time0 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
            else if (objId == cPtC2)
            {
                time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
        }
    }

    refreshData();
}
void Fibonacci::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && pCommonData.mShiftHold) gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gColorMousePoint : clrNONE, cPtL1+cPtL2+cPtR1+cPtR2+cPtC1+cPtC2);
}
void Fibonacci::onItemChange(const string &itemId, const string &objId){}
