#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

enum TEXT_POS
{
    TXT_LEFT,   // Left
    TXT_CENTER, // Center
    TXT_RIGHT,  // Right
};

enum ETrendText{
    ETrendTextLeft,     // Left
    ETrendTextCenter,   // Center
    ETrendTextRight,    // Right
    ETrendTextLeftArr,  // Left + Arrow
    ETrendTextCenterArr,// Center + Arrow
    ETrendTextRightArr, // Right + Arrow
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
input int        Trend_amount       = 7;            // Trend amount:
//--------------------------------------------
input string     Trend_1______Name  = "BOS";            // → Trend 1
input string     Trend_1_Text       = "";               // Text
input ETrendText Trend_1_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_1_Style      = eLineSolid1;      // Style
input color      Trend_1_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_2______Name  = "Break";          // → Trend 2
input string     Trend_2_Text       = "";               // Text
input ETrendText Trend_2_TxtPos     = ETrendTextCenter; // Text Position
input ELineStyle Trend_2_Style      = eLineDot;         // Style
input color      Trend_2_Color      = clrNavy;          // Color
//--------------------------------------------
input string     Trend_3______Name  = "Swept";          // → Trend 3
input string     Trend_3_Text       = "x";              // Text
input ETrendText Trend_3_TxtPos     = ETrendTextCenter; // Text Position
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
input string     Trend_6_Text       = "  $$$";          // Text
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
    string   mDispText [MAX_TYPE];
    TEXT_POS mTextPos  [MAX_TYPE];
    color    mColorType[MAX_TYPE];
    int      mStyleType[MAX_TYPE];
    int      mWidthType[MAX_TYPE];
    bool     mShowArrow[MAX_TYPE];

// Component name
private:
    string cPoint1;
    string cPoint2;
    string cMTrend;
    string iAngle0;
    string iLbText;
    string iRtText;
    string iLtText;
    string iArrowT;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    datetime time3;
    double price1;
    double price2;
    double price3;

public:
    Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

Trend::Trend(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
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
    cPoint1 = itemId + "_c2Point1";
    cPoint2 = itemId + "_c2Point2";
    cMTrend = itemId + "_c1MTrend";
    iLbText = itemId + "_0iLbText";
    iRtText = itemId + "_0iRtText";
    iLtText = itemId + "_0iLtText";
    iAngle0 = itemId + "_0iAngle0";
    iArrowT = itemId + "_0iArrowT";

    mAllItem += cPoint1+cPoint2+cMTrend+iLbText+iRtText+iLtText+iAngle0+iArrowT;
}

void Trend::refreshData()
{
    // Update Main Compoment
    setItemPos(cMTrend, time1, time2, price1, price2);
    setItemPos(cPoint1, time1, price1);
    setItemPos(cPoint2, time2, price2);
    setItemPos(iAngle0, time1, time2, price1, price2);
    setTextPos(iArrowT, time2, price2);
    double angle=ObjectGet(iAngle0, OBJPROP_ANGLE);
    ObjectSet(iArrowT, OBJPROP_ANGLE,  angle-90.0);

    // Update Text
    setTextPos(iLbText, time3, price3);
    setTextPos(iRtText, time2, price2);
    setTextPos(iLtText, time1, price1);

    bool isUp = false;
    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    int barT2 = iBarShift(ChartSymbol(), ChartPeriod(), time2);
    if (barT1 > barT2 && price1 >= High[barT1]) isUp = true;
    else if (barT2 > barT1 && price2 >= High[barT2]) isUp = true;
    // // idea check isUp/Down based on time3
    // int barT3 = iBarShift(ChartSymbol(), ChartPeriod(), time3);
    // isUp = (price3 >= High[barT3]);

    if (angle > 000 && angle <=  90) {
        ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iRtText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(0, iLtText, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    }
    else if (angle > 090 && angle <  180) {
        ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iRtText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0, iLtText, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    }
    else if (angle > 180 && angle <= 270) {
        ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_RIGHT_LOWER : ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iRtText, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iLtText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    else if (angle > 270 && angle <  360) {
        ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER  : ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0, iRtText, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, iLtText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
    }
    else if (angle == 0) 
    {
        ObjectSetInteger(0, iLbText, OBJPROP_ANCHOR, isUp ? ANCHOR_LOWER : ANCHOR_UPPER);
        ObjectSetInteger(0, iRtText, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_LEFT : ANCHOR_RIGHT);
        ObjectSetInteger(0, iLtText, OBJPROP_ANCHOR, barT1 > barT2 ? ANCHOR_RIGHT: ANCHOR_LEFT);

        if (barT1 < barT2) ObjectSet(iArrowT, OBJPROP_ANGLE,  90.0); // case 180*
    }
    // Customization
}

void Trend::createItem()
{
    ObjectCreate(iAngle0, OBJ_TRENDBYANGLE, 0, 0, 0);
    ObjectCreate(iArrowT, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cMTrend, OBJ_TREND       , 0, 0, 0);
    ObjectCreate(iLbText, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iRtText, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(iLtText, OBJ_TEXT        , 0, 0, 0);
    ObjectCreate(cPoint1, OBJ_ARROW       , 0, 0, 0);
    ObjectCreate(cPoint2, OBJ_ARROW       , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void Trend::updateDefaultProperty()
{
    multiSetProp(OBJPROP_ARROWCODE , 4      , cPoint1+cPoint2);
    multiSetProp(OBJPROP_WIDTH     , 5      , cPoint1+cPoint2);
    multiSetProp(OBJPROP_SELECTABLE, false  , iArrowT+iAngle0+iLbText+iRtText+iLtText);
    multiSetProp(OBJPROP_COLOR     , clrNONE, cPoint1+cPoint2+iAngle0);
    multiSetStrs(OBJPROP_TOOLTIP   , "\n"   , mAllItem);

    multiSetProp(OBJPROP_RAY     , false, cMTrend+iAngle0);
    ObjectSetInteger(ChartID(), iArrowT, OBJPROP_ANCHOR, ANCHOR_CENTER);
}
void Trend::updateTypeProperty()
{
    ObjectSetText(iLbText, "", 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText(iRtText, "", 8, "Consolas", mColorType[mIndexType]);
    ObjectSetText(iLtText, "", 8, "Consolas", mColorType[mIndexType]);

    if      (mTextPos[mIndexType] == TXT_CENTER) ObjectSetText (iLbText,  mDispText[mIndexType]);
    else if (mTextPos[mIndexType] == TXT_RIGHT)  ObjectSetText (iRtText,  mDispText[mIndexType]);
    else                                         ObjectSetText (iLtText,  mDispText[mIndexType]);

    ObjectSetText (iArrowT,  mShowArrow[mIndexType] ? "▲" : "", 9, "Consolas", mShowArrow[mIndexType] ? mColorType[mIndexType] : clrNONE);
    SetObjectStyle(cMTrend,  mColorType[mIndexType],          mStyleType[mIndexType],  mWidthType[mIndexType]);
    multiSetProp  (OBJPROP_BACK , true, cMTrend+iAngle0);
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
    time1 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME1);
    time2 = (datetime)ObjectGet(cMTrend, OBJPROP_TIME2);
    price1 =          ObjectGet(cMTrend, OBJPROP_PRICE1);
    price2 =          ObjectGet(cMTrend, OBJPROP_PRICE2);
    
    if (objId == cPoint1) {
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        if (pCommonData.mShiftHold) {
            price1 = price2;
        }
        else if (pCommonData.mCtrlHold) {
            price1 = pCommonData.mMousePrice;
        }
        else {
            price1 = ObjectGet(objId, OBJPROP_PRICE1);
        }
    }
    else if (objId == cPoint2) {
        time2 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        if (pCommonData.mShiftHold) {
            price2 = price1;
        }
        else if (pCommonData.mCtrlHold) {
            price2 = pCommonData.mMousePrice;
        }
        else {
            price2 = ObjectGet(objId, OBJPROP_PRICE1);
        }
    }
    else if (objId == cMTrend && pCommonData.mCtrlHold){
        price1 = pCommonData.mMousePrice;
        price2 = pCommonData.mMousePrice;
    }

    getCenterPos(time1, time2, price1, price2, time3, price3);

    refreshData();
}
void Trend::onItemClick(const string &itemId, const string &objId)
{
    string targetobj = objId;
    if (objId == iAngle0 || objId == iArrowT || objId == iLbText)
    {
        if ((int)ObjectGet(cMTrend, OBJPROP_SELECTED) == 0) return;
        targetobj = cMTrend;
    }
    int selected = (int)ObjectGet(targetobj, OBJPROP_SELECTED);
    multiSetProp(OBJPROP_SELECTED, selected, mAllItem);
    if (selected && StringFind(objId, "_c") >= 0 && pCommonData.mShiftHold){
        gContextMenu.openContextMenu(objId, mContextType, mIndexType);
    }
}
void Trend::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cMTrend) multiSetProp(OBJPROP_COLOR, (color)ObjectGet(cMTrend, OBJPROP_COLOR), iLbText+iRtText+iLtText+iArrowT);
    if (objId == cPoint1 || objId == cPoint2 || objId == cMTrend){
        string strLbText = ObjectDescription(cMTrend);
        string strRtText = ObjectDescription(cPoint2);
        string strLtText = ObjectDescription(cPoint1);
        if (strLbText != "") ObjectSetText(iLbText, strLbText);
        if (strRtText != "") ObjectSetText(iRtText, strRtText);
        if (strLtText != "") ObjectSetText(iLtText, strLtText);
        if (strLbText == ".") ObjectSetText(iLbText, "");
        if (strRtText == ".") ObjectSetText(iRtText, "");
        if (strLtText == ".") ObjectSetText(iLtText, "");
        ObjectSetText(cMTrend, "");
        ObjectSetText(cPoint2, "");
        ObjectSetText(cPoint1, "");
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
