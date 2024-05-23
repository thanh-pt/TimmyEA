#include "../Base/BaseItem.mqh"

enum TEXT_POS
{
    TXT_LEFT,   // Left
    TXT_CENTER, // Center
    TXT_RIGHT,  // Right
};

enum ETrendText{
    ETrendTextLeft,     // =------
    ETrendTextCenter,   // ---=---
    ETrendTextRight,    // ------=
    ETrendTextLeftArr,  // =------►
    ETrendTextCenterArr,// ---=---►
    ETrendTextRightArr, // ------►=
};

TEXT_POS getTextPos(ETrendText eTrendText){
    switch (eTrendText){
        case ETrendTextLeft     : return TXT_LEFT;
        case ETrendTextCenter   : return TXT_CENTER;
        case ETrendTextRight    : return TXT_RIGHT;
        case ETrendTextLeftArr  : return TXT_LEFT;
        case ETrendTextCenterArr: return TXT_CENTER;
        case ETrendTextRightArr : return TXT_RIGHT;
    }
    return TXT_CENTER;
}

input string Trend_; // ●  T R E N D  ●
      int        Trend_amount       = 7;            // Trend amount:
//--------------------------------------------
input string     Trend_1______Name  = "Flow";           // → Trend 1
input string     Trend_1_Text       = "";               // Text
input ETrendText Trend_1_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_1_Style      = eLineDot;         // Style
input color      Trend_1_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_2______Name  = "BoS";            // → Trend 2
input string     Trend_2_Text       = "";               // Text
input ETrendText Trend_2_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_2_Style      = eLineSolid1;      // Style
input color      Trend_2_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_3______Name  = "Swept";          // → Trend 3
input string     Trend_3_Text       = " x";             // Text
input ETrendText Trend_3_TxtPos     = ETrendTextRight;  // Text Position
input ELineStyle Trend_3_Style      = eLineSolid1;      // Style
input color      Trend_3_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_4______Name  = "Ch";             // → Trend 4
input string     Trend_4_Text       = "ch";             // Text
input ETrendText Trend_4_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_4_Style      = eLineDot;         // Style
input color      Trend_4_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_5______Name  = "IRL";            // → Trend 5
input string     Trend_5_Text       = "$";              // Text
input ETrendText Trend_5_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_5_Style      = eLineSolid1;      // Style
input color      Trend_5_Color      = clrGreen;         // Color
//--------------------------------------------
input string     Trend_6______Name  = "ERL";            // → Trend 6
input string     Trend_6_Text       = " $ $ $";         // Text
input ETrendText Trend_6_TxtPos     = ETrendTextRight;  // Text Position
input ELineStyle Trend_6_Style      = eLineSolid2;      // Style
input color      Trend_6_Color      = clrGreen;         // Color
//--------------------------------------------
input string     Trend_7______Name  = "Arw";            // → Trend 7
input string     Trend_7_Text       = "";               // Text
input ETrendText Trend_7_TxtPos     = ETrendTextCenterArr; // Text Position
input ELineStyle Trend_7_Style      = eLineSolid1;      // Style
input color      Trend_7_Color      = clrNavy;          // Color
//--------------------------------------------

// --- Reserved ---
string     Trend_8______Name  = "---";            // → Trend 8
string     Trend_8_Text       = "";               // Text
ETrendText Trend_8_TxtPos     = ETrendTextCenter; // Text Position
ELineStyle Trend_8_Style      = eLineSolid1;      // Style
color      Trend_8_Color      = clrGreen;         // Color
//--------------------------------------------
string     Trend_9______Name  = "---";            // → Trend 9
string     Trend_9_Text       = "";               // Text
ETrendText Trend_9_TxtPos     = ETrendTextCenter; // Text Position
ELineStyle Trend_9_Style      = eLineSolid1;      // Style
color      Trend_9_Color      = clrNavy;          // Color

enum TrendType
{
    TREND_1,
    TREND_2,
    TREND_3,
    TREND_4,
    TREND_5,
    TREND_6,
    TREND_7,
    TREND_8,
    TREND_9,
    TREND_NUM,
};

class Trend : public BaseItem
{
// Internal Value
private:
    string   mDispText [CTX_MAX];
    TEXT_POS mTextPos  [CTX_MAX];
    color    mColorType[CTX_MAX];
    int      mStyleType[CTX_MAX];
    int      mWidthType[CTX_MAX];
    bool     mShowArrow[CTX_MAX];

// Component name
private:
    string cLnM0;
    string cPt01;
    string cPt02;
    string iAng0;
    string iTxtC;
    string iTxtR;
    string iTxtL;
    string iTxtA;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;

public:
    Trend(CommonData* commonData, MouseInfo* mouseInfo);

// Internal Event
public:
    virtual void activateItem(const string& itemId);
    virtual void refreshData();
    virtual void createItem();
    virtual void updateDefaultProperty();
    virtual void updateTypeProperty();
    virtual void prepareActive();
    virtual void updateItemAfterChangeType();
private:

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

static string Trend::Tag = ".TMTrend";

Trend::Trend(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Trend::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [TREND_1] = Trend_1______Name ;
    mDispText [TREND_1] = Trend_1_Text      ;
    mTextPos  [TREND_1] = getTextPos(Trend_1_TxtPos);
    mColorType[TREND_1] = Trend_1_Color     ;
    mStyleType[TREND_1] = getLineStyle(Trend_1_Style);
    mWidthType[TREND_1] = getLineWidth(Trend_1_Style);
    mShowArrow[TREND_1] = (Trend_1_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_2] = Trend_2______Name ;
    mDispText [TREND_2] = Trend_2_Text      ;
    mTextPos  [TREND_2] = getTextPos(Trend_2_TxtPos);
    mColorType[TREND_2] = Trend_2_Color     ;
    mStyleType[TREND_2] = getLineStyle(Trend_2_Style);
    mWidthType[TREND_2] = getLineWidth(Trend_2_Style);
    mShowArrow[TREND_2] = (Trend_2_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_3] = Trend_3______Name ;
    mDispText [TREND_3] = Trend_3_Text      ;
    mTextPos  [TREND_3] = getTextPos(Trend_3_TxtPos);
    mColorType[TREND_3] = Trend_3_Color     ;
    mStyleType[TREND_3] = getLineStyle(Trend_3_Style);
    mWidthType[TREND_3] = getLineWidth(Trend_3_Style);
    mShowArrow[TREND_3] = (Trend_3_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_4] = Trend_4______Name ;
    mDispText [TREND_4] = Trend_4_Text      ;
    mTextPos  [TREND_4] = getTextPos(Trend_4_TxtPos);
    mColorType[TREND_4] = Trend_4_Color     ;
    mStyleType[TREND_4] = getLineStyle(Trend_4_Style);
    mWidthType[TREND_4] = getLineWidth(Trend_4_Style);
    mShowArrow[TREND_4] = (Trend_4_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_5] = Trend_5______Name ;
    mDispText [TREND_5] = Trend_5_Text      ;
    mTextPos  [TREND_5] = getTextPos(Trend_5_TxtPos);
    mColorType[TREND_5] = Trend_5_Color     ;
    mStyleType[TREND_5] = getLineStyle(Trend_5_Style);
    mWidthType[TREND_5] = getLineWidth(Trend_5_Style);
    mShowArrow[TREND_5] = (Trend_5_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_6] = Trend_6______Name ;
    mDispText [TREND_6] = Trend_6_Text      ;
    mTextPos  [TREND_6] = getTextPos(Trend_6_TxtPos);
    mColorType[TREND_6] = Trend_6_Color     ;
    mStyleType[TREND_6] = getLineStyle(Trend_6_Style);
    mWidthType[TREND_6] = getLineWidth(Trend_6_Style);
    mShowArrow[TREND_6] = (Trend_6_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_7] = Trend_7______Name ;
    mDispText [TREND_7] = Trend_7_Text      ;
    mTextPos  [TREND_7] = getTextPos(Trend_7_TxtPos);
    mColorType[TREND_7] = Trend_7_Color     ;
    mStyleType[TREND_7] = getLineStyle(Trend_7_Style);
    mWidthType[TREND_7] = getLineWidth(Trend_7_Style);
    mShowArrow[TREND_7] = (Trend_7_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_8] = Trend_8______Name ;
    mDispText [TREND_8] = Trend_8_Text      ;
    mTextPos  [TREND_8] = getTextPos(Trend_8_TxtPos);
    mColorType[TREND_8] = Trend_8_Color     ;
    mStyleType[TREND_8] = getLineStyle(Trend_8_Style);
    mWidthType[TREND_8] = getLineWidth(Trend_8_Style);
    mShowArrow[TREND_8] = (Trend_8_TxtPos>=ETrendTextLeftArr);     ;
    //--------------------------------------------
    mNameType [TREND_9] = Trend_9______Name;
    mDispText [TREND_9] = Trend_9_Text     ;
    mTextPos  [TREND_9] = getTextPos(Trend_9_TxtPos);
    mColorType[TREND_9] = Trend_9_Color    ;
    mStyleType[TREND_9] = getLineStyle(Trend_9_Style);
    mWidthType[TREND_9] = getLineWidth(Trend_9_Style);
    mShowArrow[TREND_9] = (Trend_9_TxtPos>=ETrendTextLeftArr);    ;
    //--------------------------------------------
    mIndexType = 0;
    mTypeNum = MathMin(Trend_amount, TREND_NUM);
    for (int i = 0; i < mTypeNum; i++)
    {
        mContextType += mNameType[i];
        if (i < mTypeNum-1) mContextType += ",";
    }
}

// Internal Event
void Trend::prepareActive(){}

void Trend::activateItem(const string& itemId)
{
    cLnM0 = itemId + TAG_CTRM + "cLnM0";
    cPt01 = itemId + TAG_CTRL + "cPt01";
    cPt02 = itemId + TAG_CTRL + "cPt02";
    iAng0 = itemId + TAG_INFO + "iAng0";
    iTxtC = itemId + TAG_INFO + "iTxtC";
    iTxtR = itemId + TAG_INFO + "iTxtR";
    iTxtL = itemId + TAG_INFO + "iTxtL";
    iTxtA = itemId + TAG_INFO + "iTxtA";

    mAllItem += cLnM0+cPt01+cPt02+iTxtC+iTxtR+iTxtL+iAng0+iTxtA;
}
string Trend::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iAng0";
    allItem += itemId + TAG_INFO + "iTxtC";
    allItem += itemId + TAG_INFO + "iTxtR";
    allItem += itemId + TAG_INFO + "iTxtL";
    allItem += itemId + TAG_INFO + "iTxtA";
    //--- Control item ---
    allItem += itemId + TAG_CTRM + "cLnM0";
    allItem += itemId + TAG_CTRL + "cPt01";
    allItem += itemId + TAG_CTRL + "cPt02";

    return allItem;
}

void Trend::refreshData()
{
    // Update Main Compoment
    setItemPos(cLnM0, time1, time2, price1, price2);
    setItemPos(cPt01, time1, price1);
    setItemPos(cPt02, time2, price2);
    setItemPos(iAng0, time1, time2, price1-price1, price2-price1);
    setTextPos(iTxtA, time2, price2);
    double angle=ObjectGet(iAng0, OBJPROP_ANGLE);
    ObjectSet(iTxtA, OBJPROP_ANGLE,  angle-90.0);

    // Update Text
    setTextPos(iTxtC, time3, price3);
    setTextPos(iTxtR, time2, price2);
    setTextPos(iTxtL, time1, price1);

    bool isUp = false;
    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);
    if (barT1 > barT2 && price1 >= High[barT1]) isUp = true;
    else if (barT2 > barT1 && price2 >= High[barT2]) isUp = true;

    if (angle > 000 && angle <=  90) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    }
    else if (angle > 090 && angle <  180) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    }
    else if (angle > 180 && angle <= 270) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    else if (angle > 270 && angle <  360) {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
    }
    else if (angle == 0) 
    {
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);

        if (barT1 < barT2) ObjectSet(iTxtA, OBJPROP_ANGLE,  90.0); // case 180*
    }
    if (price1 == price2){
        ObjectSetInteger(0, iTxtC, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        ObjectSetInteger(0, iTxtL, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);
    }
    // Customization

    int selected = (int)ObjectGet(cLnM0, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR   , selected ? gColorMousePoint : clrNONE, cPt01+cPt02);
}

void Trend::createItem()
{
    ObjectCreate(iAng0, OBJ_TRENDBYANGLE, 0, 0, 0);
    ObjectCreate(iTxtA, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cLnM0, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(iTxtC, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iTxtR, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iTxtL, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cPt01, OBJ_ARROW       , 0, 0, 0);
    ObjectCreate(cPt02, OBJ_ARROW       , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    setMultiProp(OBJPROP_ARROWCODE , 4      , cPt01+cPt02);
    setMultiProp(OBJPROP_WIDTH     , 5      , cPt01+cPt02);
    setMultiProp(OBJPROP_SELECTABLE, false  , iTxtA+iAng0+iTxtC+iTxtR+iTxtL);
    setMultiProp(OBJPROP_COLOR     , clrNONE, cPt01+cPt02+iAng0);
    setMultiStrs(OBJPROP_TOOLTIP   , "\n"   , mAllItem);

    setMultiProp(OBJPROP_RAY     , false, cLnM0+iAng0);
    ObjectSetInteger(ChartID(), iTxtA, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText(iTxtC, "", 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText(iTxtR, "", 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText(iTxtL, "", 8, "Consolas", mColorType[mIndexType]);

    if      (mTextPos[mIndexType] == TXT_CENTER) ObjectSetText (iTxtC,  mDispText[mIndexType]);
    else if (mTextPos[mIndexType] == TXT_RIGHT)  ObjectSetText (iTxtR,  mDispText[mIndexType]);
    else                                         ObjectSetText (iTxtL,  mDispText[mIndexType]);

    ObjectSetText (iTxtA,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    setObjectStyle(cLnM0,  mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
    setMultiProp  (OBJPROP_BACK , true, cLnM0+iAng0);
}
void Trend::updateItemAfterChangeType()
{
    if (mFirstPoint == true)
    {
        updateTypeProperty();
        refreshData();
    }
}

//Chart Event
void Trend::onItemDrag(const string &itemId, const string &objId)
{
    gContextMenu.clearContextMenu();

    if (objId == cLnM0){
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        time2 = (datetime)ObjectGet(objId, OBJPROP_TIME2);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
        price2 =          ObjectGet(objId, OBJPROP_PRICE2);
        if (pCommonData.mMouseTime == time1){
            if (pCommonData.mShiftHold == true) price1 = price2;
            else if (pCommonData.mCtrlHold == true) price1 = pCommonData.mMousePrice;
        }
        else if (pCommonData.mMouseTime == time2){
            if (pCommonData.mShiftHold == true) price2 = price1;
            else if (pCommonData.mCtrlHold == true) price2 = pCommonData.mMousePrice;
        }
    }
    else if (objId == cPt01) {
        time2   = (datetime)ObjectGet(cPt02, OBJPROP_TIME1);
        price2  =           ObjectGet(cPt02, OBJPROP_PRICE1);

        time1 = (datetime)ObjectGet(cPt01, OBJPROP_TIME1);
        if (pCommonData.mShiftHold == true) price1 = price2;
        else if (pCommonData.mCtrlHold == true) price1 = pCommonData.mMousePrice;
        else price1 = ObjectGet(cPt01, OBJPROP_PRICE1);
    }
    else if (objId == cPt02) {
        time1   = (datetime)ObjectGet(cPt01, OBJPROP_TIME1);
        price1  =           ObjectGet(cPt01, OBJPROP_PRICE1);

        time2 = (datetime)ObjectGet(cPt02, OBJPROP_TIME1);
        if (pCommonData.mShiftHold == true) price2 = price1;
        else if (pCommonData.mCtrlHold == true) price2 = pCommonData.mMousePrice;
        else price2 = ObjectGet(cPt02, OBJPROP_PRICE1);
    }

    getCenterPos(time1, time2, price1, price2, time3, price3);

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && pCommonData.mShiftHold) gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gColorMousePoint : clrNONE, cPt01+cPt02);
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLnM0) setMultiProp(OBJPROP_COLOR, (color)ObjectGet(cLnM0, OBJPROP_COLOR), iTxtC+iTxtR+iTxtL+iTxtA);
    if (objId == cPt01 || objId == cPt02 || objId == cLnM0){
        string strLbText = ObjectDescription(cLnM0);
        string strRtText = ObjectDescription(cPt02);
        string strLtText = ObjectDescription(cPt01);
        if (strLbText != "") ObjectSetText(iTxtC, strLbText);
        if (strRtText != "") ObjectSetText(iTxtR, strRtText);
        if (strLtText != "") ObjectSetText(iTxtL, strLtText);
        if (strLbText == "-") ObjectSetText(iTxtC, EMPTY_STR);
        if (strRtText == "-") ObjectSetText(iTxtR, EMPTY_STR);
        if (strLtText == "-") ObjectSetText(iTxtL, EMPTY_STR);
        ObjectSetText(cLnM0, "");
        ObjectSetText(cPt02, "");
        ObjectSetText(cPt01, "");
    }
    onItemDrag(itemId, objId);
}
void Trend::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void Trend::onMouseMove()
{
    if (mFirstPoint == false) return;
    if (pCommonData.mShiftHold) {
        price2 = price1;
    }
    else {
        price2 = pCommonData.mMousePrice;
    }
    time2  = pCommonData.mMouseTime;
    getCenterPos(time1, time2, price1, price2, time3, price3);
    refreshData();
}
