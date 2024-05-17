#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

input string          Fib_;    // ●  F I B O N A C I I  ●
//--------------------------------------------
input color           Fib_Bkgrd_Color = clrNONE;    // Bg Color
input ELineStyle      Fib_Style     = eLineSolid1;  // Style
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
    FIB_RANGE2,
    FIB_FULL,
    FIB_RANGE_EXT,
    FIB_NUM,
};

class Fibonacci : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string ckLne;
    string iFib0;
    string iFib1;
    string iFib2;
    string iFib3;
    string iFib4;
    string iFib5;
    string iTxt0;
    string iTxt1;
    string iTxt2;
    string iTxt3;
    string iTxt4;
    string iTxt5;

    string cPointL1;
    string cPointL2;
    string cPointR1;
    string cPointR2;
    string cPointC1;
    string cPointC2;

// Value define for Item
private:
    datetime time0;
    datetime time1;
    double price0;
    double price1;

    double   centerPrice;
    datetime centerTime;

public:
    Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

Fibonacci::Fibonacci(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mIndexType = 0;
    mNameType[FIB_RANGE]     = "Range";
    mNameType[FIB_RANGE2]    = "Range2";
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
    if (Fib_0_Color != clrNONE) ObjectCreate(iFib0, OBJ_TREND, 0, 0, 0);
    if (Fib_1_Color != clrNONE) ObjectCreate(iFib1, OBJ_TREND, 0, 0, 0);
    if (Fib_2_Color != clrNONE) ObjectCreate(iFib2, OBJ_TREND, 0, 0, 0);
    if (Fib_3_Color != clrNONE) ObjectCreate(iFib3, OBJ_TREND, 0, 0, 0);
    if (Fib_4_Color != clrNONE) ObjectCreate(iFib4, OBJ_TREND, 0, 0, 0);
    if (Fib_5_Color != clrNONE) ObjectCreate(iFib5, OBJ_TREND, 0, 0, 0);
    //------------------------------------------
    if (Fib_0_Color != clrNONE /*&& Fib_0_Text != ""*/) ObjectCreate(iTxt0, OBJ_TEXT, 0, 0, 0);
    if (Fib_1_Color != clrNONE /*&& Fib_1_Text != ""*/) ObjectCreate(iTxt1, OBJ_TEXT, 0, 0, 0);
    if (Fib_2_Color != clrNONE /*&& Fib_2_Text != ""*/) ObjectCreate(iTxt2, OBJ_TEXT, 0, 0, 0);
    if (Fib_3_Color != clrNONE /*&& Fib_3_Text != ""*/) ObjectCreate(iTxt3, OBJ_TEXT, 0, 0, 0);
    if (Fib_4_Color != clrNONE /*&& Fib_4_Text != ""*/) ObjectCreate(iTxt4, OBJ_TEXT, 0, 0, 0);
    if (Fib_5_Color != clrNONE /*&& Fib_5_Text != ""*/) ObjectCreate(iTxt5, OBJ_TEXT, 0, 0, 0);
    ObjectCreate(ckLne, OBJ_RECTANGLE, 0, 0, 0);

    ObjectCreate(cPointL1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointL2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointR2, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC1, OBJ_ARROW, 0, 0, 0);
    ObjectCreate(cPointC2, OBJ_ARROW, 0, 0, 0);

    updateDefaultProperty();
    updateTypeProperty();

    time0  = pCommonData.mMouseTime;
    price0 = pCommonData.mMousePrice;
}
void Fibonacci::updateDefaultProperty()
{
    multiSetProp(OBJPROP_STYLE        , getLineStyle(Fib_Style), iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_BACK         , true      , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_SELECTABLE   , false     , iFib0+iFib1+iFib2+iFib3+iFib4+iFib5
                                                   +iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);
    multiSetInts(OBJPROP_ANCHOR, ANCHOR_RIGHT     , iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5);

    multiSetProp(OBJPROP_ARROWCODE,       4, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_COLOR    , clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    
    multiSetStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Fibonacci::updateTypeProperty()
{
    //------------------------------------------
    ObjectSetText(iTxt0, Fib_0_Text + "  ", 7, NULL, Fib_0_Color);
    ObjectSetText(iTxt1, Fib_1_Text + "  ", 7, NULL, Fib_1_Color);
    ObjectSetText(iTxt2, Fib_2_Text + "  ", 7, NULL, Fib_2_Color);
    ObjectSetText(iTxt3, Fib_3_Text + "  ", 7, NULL, Fib_3_Color);
    ObjectSetText(iTxt4, Fib_4_Text + "  ", 7, NULL, Fib_4_Color);
    ObjectSetText(iTxt5, Fib_5_Text + "  ", 7, NULL, Fib_5_Color);
    //------------------------------------------
    SetRectangleBackground(ckLne, Fib_Bkgrd_Color);
    multiSetProp(OBJPROP_RAY, false, iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    multiSetProp(OBJPROP_WIDTH     , getLineWidth(Fib_Style), iFib0+iFib1+iFib2+iFib3+iFib4+iFib5);
    //------------------------------------------
    ObjectSet(iFib0, OBJPROP_COLOR, Fib_0_Color);
    ObjectSet(iFib1, OBJPROP_COLOR, Fib_1_Color);
    ObjectSet(iFib2, OBJPROP_COLOR, Fib_2_Color);
    ObjectSet(iFib3, OBJPROP_COLOR, Fib_3_Color);
    ObjectSet(iFib4, OBJPROP_COLOR, Fib_4_Color);
    ObjectSet(iFib5, OBJPROP_COLOR, Fib_5_Color);

    if (mIndexType != FIB_FULL) {
        multiSetProp(OBJPROP_COLOR, clrNONE, iFib3+iFib4+iFib5 + iTxt3+iTxt4+iTxt5);
    }
    if (mIndexType == FIB_RANGE || mIndexType == FIB_RANGE_EXT){
        ObjectSetText(iTxt2, "  ", 8);
        multiSetProp(OBJPROP_COLOR, clrDarkOrange, iFib2);
    }
    if (mIndexType == FIB_RANGE_EXT) {
        multiSetProp(OBJPROP_RAY, true, iFib0+iFib1);
    }
    if (mIndexType == FIB_RANGE2){
        ObjectSetText(iTxt0, "   ");
        ObjectSetText(iTxt1, "   ");
        ObjectSetText(iTxt2, "   ");
        SetRectangleBackground(ckLne, clrOldLace);
        multiSetProp(OBJPROP_WIDTH, getLineWidth(Fib_Style)+1, iFib0+iFib1);
    }
}
void Fibonacci::activateItem(const string& itemId)
{
    ckLne = itemId + "_c0Lne";
    iFib0 = itemId + "_iFib0";
    iFib1 = itemId + "_iFib1";
    iFib2 = itemId + "_iFib2";
    iFib3 = itemId + "_iFib3";
    iFib4 = itemId + "_iFib4";
    iFib5 = itemId + "_iFib5";
    iTxt0 = itemId + "_iTxt0";
    iTxt1 = itemId + "_iTxt1";
    iTxt2 = itemId + "_iTxt2";
    iTxt3 = itemId + "_iTxt3";
    iTxt4 = itemId + "_iTxt4";
    iTxt5 = itemId + "_iTxt5";

    cPointL1 = itemId + "_cPointL1";
    cPointL2 = itemId + "_cPointL2";
    cPointR1 = itemId + "_cPointR1";
    cPointR2 = itemId + "_cPointR2";
    cPointC1 = itemId + "_cPointC1";
    cPointC2 = itemId + "_cPointC2";

    mAllItem += ckLne+iFib0+iFib1+iFib2+iFib3+iFib4+iFib5+iTxt0+iTxt1+iTxt2+iTxt3+iTxt4+iTxt5
                +cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2;
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
    setItemPos(ckLne, time0, time1, price0, price1);
    setItemPos(iFib0, time0, time1, price0, price0);
    setItemPos(iFib1, time0, time1, price1, price1);
    setItemPos(iFib2, time0, time1, price2, price2);
    setItemPos(iFib3, time0, time1, price3, price3);
    setItemPos(iFib4, time0, time1, price4, price4);
    setItemPos(iFib5, time0, time1, price5, price5);
    //-------------------------------------------------
    setTextPos(iTxt0, time0, price0);
    setTextPos(iTxt1, time0, price1);
    setTextPos(iTxt2, time0, price2);
    setTextPos(iTxt3, time0, price3);
    setTextPos(iTxt4, time0, price4);
    setTextPos(iTxt5, time0, price5);
    //-------------------------------------------------
    getCenterPos(time0, time1, price0, price1, centerTime, centerPrice);

    setItemPos(cPointL1, time0, price0);
    setItemPos(cPointL2, time0, price1);
    setItemPos(cPointR1, time1, price0);
    setItemPos(cPointR2, time1, price1);
    setItemPos(cPointC1, time0, centerPrice);
    setItemPos(cPointC2, time1, centerPrice);
    //-------------------------------------------------
    int selected = (int)ObjectGet(ckLne, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+ckLne);
    //-------------------------------------------------
    if (mIndexType == FIB_RANGE || mIndexType == FIB_RANGE_EXT){
        bool isUp = (price1 > price0);
        ObjectSetText(iTxt0, isUp ? "𝙇𝙤  " : "𝙃𝙞  ", 8);
        ObjectSetText(iTxt1, isUp ? "𝙃𝙞  " : "𝙇𝙤  ", 8);
        multiSetProp(OBJPROP_COLOR, isUp ? clrGreen : clrRed  , iFib0+iTxt0);
        multiSetProp(OBJPROP_COLOR, isUp ? clrRed   : clrGreen, iFib1+iTxt1);
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
    if (objId == ckLne)
    {
        time0   = (datetime)ObjectGet(ckLne, OBJPROP_TIME1);
        time1   = (datetime)ObjectGet(ckLne, OBJPROP_TIME2);
        price0  =           ObjectGet(ckLne, OBJPROP_PRICE1);
        price1  =           ObjectGet(ckLne, OBJPROP_PRICE2);
    }
    else
    {
        if (pCommonData.mCtrlHold)
        {
            if (objId == cPointL1 || objId == cPointR2 || objId == cPointL2 || objId == cPointR1) ObjectSet(objId, OBJPROP_PRICE1, pCommonData.mMousePrice);
        }

        if (objId == cPointL1 || objId == cPointR2 )
        {
            time0  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
        }
        else if (objId == cPointL2 || objId == cPointR1)
        {
            time0  = (datetime)ObjectGet(cPointL2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointL2, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointR1, OBJPROP_PRICE1);
        }
        else
        {
            time0  = (datetime)ObjectGet(cPointL1, OBJPROP_TIME1);
            price0 =           ObjectGet(cPointL1, OBJPROP_PRICE1);
            time1  = (datetime)ObjectGet(cPointR2, OBJPROP_TIME1);
            price1 =           ObjectGet(cPointR2, OBJPROP_PRICE1);
            if (objId == cPointC1)
            {
                time0 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
            else if (objId == cPointC2)
            {
                time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
            }
        }
    }

    refreshData();
}
void Fibonacci::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, "_c") == -1) return;

    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2);
    multiSetProp(OBJPROP_SELECTED, selected, cPointL1+cPointL2+cPointR1+cPointR2+cPointC1+cPointC2+ckLne);
    if (selected)
    {
        unSelectAllExcept(itemId);
        if (StringFind(objId, "_c") >= 0 && pCommonData.mShiftHold)
            gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    }
}
void Fibonacci::onItemChange(const string &itemId, const string &objId){}
