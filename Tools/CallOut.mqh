#include "../Base/BaseItem.mqh"

// input string CallOut_;                              // ●  C A L L   O U T  ●
      int    CallOut_FontSize = 10;                 // Font Size
// input string InpCallOutPreset = "❌";    // Preset


string UNDER_LINE = "________________________________________________________________________________________";

class CallOut : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cTxtM;
    string cLn01;
    string iTxtU;
    string iTxBg;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    CallOut(CommonData* commonData, MouseInfo* mouseInfo);

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

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string CallOut::Tag = ".TMCallOut";

CallOut::CallOut(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = CallOut::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "CallOut";
    mIndexType = 0;
    mTypeNum = 0;
}

// Internal Event
void CallOut::prepareActive(){}
void CallOut::createItem()
{
    ObjectCreate(cLn01, OBJ_TREND, 0, 0, 0);
    ObjectCreate(iTxBg, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(iTxtU, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cTxtM, OBJ_TEXT , 0, 0, 0);
    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void CallOut::updateDefaultProperty()
{
    ObjectSet(iTxtU, OBJPROP_SELECTABLE, false);
    ObjectSet(iTxBg, OBJPROP_SELECTABLE, false);
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void CallOut::updateTypeProperty()
{
    setObjectStyle(cLn01, gClrForegrnd, 0, 1);
    //-------------------------------------------------------------
    setTextContent(cTxtM, DoubleToString(pCommonData.mMousePrice, 5), CallOut_FontSize  , FONT_BLOCK, gClrForegrnd);
    setTextContent(iTxtU,                                    "_____", CallOut_FontSize  , FONT_BLOCK, gClrForegrnd);
    setTextContent(iTxBg,                           getHalfBlock2(5), CallOut_FontSize*2, FONT_BLOCK, gClrTextBgnd);
    setCtrlItemSelectState(mAllItem, true);
}
void CallOut::activateItem(const string& itemId)
{
    cTxtM = itemId + TAG_CTRM + "cTxtM";
    cLn01 = itemId + TAG_CTRL + "cLn01";
    iTxtU = itemId + TAG_INFO + "iTxtU";
    iTxBg = itemId + TAG_INFO + "iTxBg";

    mAllItem += cTxtM+cLn01+iTxtU+iTxBg;
}
string CallOut::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxBg";
    allItem += itemId + TAG_INFO + "iTxtU";
    //--- Control item ---
    allItem += itemId + TAG_CTRM + "cTxtM";
    allItem += itemId + TAG_CTRL + "cLn01";

    return allItem;
}
void CallOut::updateItemAfterChangeType(){}
void CallOut::refreshData()
{
    setItemPos(cLn01, time1, time2, price1, price2);
    setItemPos(cTxtM, time2, price2);
    setItemPos(iTxtU, time2, price2);
    setItemPos(iTxBg, time2, price2);
    //-------------------------------------------------------------
    if (time1 > time2) setMultiInts(OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER, cTxtM+iTxtU+iTxBg);
    else setMultiInts(OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER, cTxtM+iTxtU+iTxBg);

    string callOutValue = ObjectDescription(cTxtM);
    int calloutLen = StringLen(callOutValue);
    setTextContent(iTxtU, StringSubstr(UNDER_LINE, 0, calloutLen));
    setTextContent(iTxBg, getHalfBlock2(calloutLen));
    if (calloutLen == 7 && StrToDouble(callOutValue) != 0.0)
    {
        setTextContent(cTxtM, DoubleToString(price1,5));
    }
    // additional leg
    int idx = 0;
    string additionalLeg = cLn01 + IntegerToString(idx);
    while (ObjectFind(additionalLeg) >= 0)
    {
        ObjectSet(additionalLeg, OBJPROP_TIME2 , time2);
        ObjectSet(additionalLeg, OBJPROP_PRICE2, price2);
        idx++;
        additionalLeg = cLn01 + IntegerToString(idx);
    }
}
void CallOut::finishedJobDone(){}

// Chart Event
void CallOut::onMouseMove()
{
    if (mFirstPoint == false)
    {
        return;
    }
    time2  = pCommonData.mMouseTime;
    price2 = pCommonData.mMousePrice;
    refreshData();
}
void CallOut::onMouseClick()
{
    if (mFirstPoint == false)
    {
        createItem();
        pMouseInfo.setText("");
        mFirstPoint = true;
        return;
    }
    mFinishedJobCb();
}
void CallOut::onItemDrag(const string &itemId, const string &objId)
{
    time1   = (datetime)ObjectGet(cLn01, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cLn01, OBJPROP_TIME2);
    price1  =           ObjectGet(cLn01, OBJPROP_PRICE1);
    price2  =           ObjectGet(cLn01, OBJPROP_PRICE2);

    if (objId == cTxtM)
    {
        time2   = (datetime)ObjectGet(cTxtM, OBJPROP_TIME1);
        price2  =           ObjectGet(cTxtM, OBJPROP_PRICE1);
    }
    else if (pCommonData.mCtrlHold == true)
    {
        double textPrice = ObjectGet(cTxtM, OBJPROP_PRICE1);
        if (price2 == textPrice)
        {
            price1 = pCommonData.mMousePrice;
        }
    }

    refreshData();
}
void CallOut::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    setCtrlItemSelectState(mAllItem, selected);
}
void CallOut::onItemChange(const string &itemId, const string &objId)
{
    setMultiProp(OBJPROP_COLOR, (color)ObjectGet(objId, OBJPROP_COLOR), cTxtM+cLn01+iTxtU);
    if (objId == cLn01) {
        string description = ObjectDescription(objId);
        if (description != ""){
            setTextContent(objId, "");
            setTextContent(cTxtM, description);
        }
    }
    onItemDrag(itemId, objId);
}
void CallOut::onItemDeleted(const string &itemId, const string &objId)
{
    if (objId == cTxtM || objId == cLn01 || objId == iTxtU)
    {
        BaseItem::onItemDeleted(itemId, objId);
    }
    // additional leg removing
    int idx = 0;
    string objName = "";
    do
    {
        objName = cLn01 + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}