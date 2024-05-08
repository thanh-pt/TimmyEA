#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

input string CallOut_;                              // ● Call-Out ●
input color  CallOut_Color    = clrMidnightBlue;    // Color
input int    CallOut_FontSize = 10;                 // Font Size


string UNDER_LINE = "________________________________________________________________________________________";

class CallOut : public BaseItem
{
// Internal Value
private:

// Component name
private:
    string cLbText;
    string cPtLine;
    string iUdLine;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    CallOut(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

CallOut::CallOut(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
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
    ObjectCreate(cPtLine, OBJ_TREND, 0, 0, 0);
    ObjectCreate(iUdLine, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cLbText, OBJ_TEXT , 0, 0, 0);
    updateTypeProperty();
    updateDefaultProperty();
    time1  = pCommonData.mMouseTime;
    price1 = pCommonData.mMousePrice;
}
void CallOut::updateDefaultProperty()
{
    ObjectSet(iUdLine, OBJPROP_SELECTABLE, false);
    multiSetStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void CallOut::updateTypeProperty()
{
    SetObjectStyle(cPtLine, CallOut_Color, 0, 1);
    //-------------------------------------------------------------
    ObjectSetText(cLbText, DoubleToString(pCommonData.mMousePrice, 5), CallOut_FontSize, "Consolas", CallOut_Color);
    ObjectSetText(iUdLine,                                    "_____", CallOut_FontSize, "Consolas", CallOut_Color);
    ObjectSet(cLbText, OBJPROP_SELECTED, true);
}
void CallOut::activateItem(const string& itemId)
{
    cLbText = itemId + "_cLbText";
    cPtLine = itemId + "_cPtLine";
    iUdLine = itemId + "_iUdLine";

    mAllItem += cLbText+cPtLine+iUdLine;
}
void CallOut::updateItemAfterChangeType(){}
void CallOut::refreshData()
{
    setItemPos(cPtLine, time1, time2, price1, price2);
    setItemPos(cLbText, time2, price2);
    setItemPos(iUdLine, time2, price2);
    //-------------------------------------------------------------
    if (time1 > time2)
    {
        ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(ChartID(), iUdLine, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
    }
    else
    {
        ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        ObjectSetInteger(ChartID(), iUdLine, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    string callOutValue = ObjectDescription(cLbText);
    int calloutLen = StringLen(callOutValue);
    ObjectSetText(iUdLine, StringSubstr(UNDER_LINE, 0, calloutLen));
    if (calloutLen == 7 && StrToDouble(callOutValue) != 0.0)
    {
        ObjectSetText(cLbText, DoubleToString(price1,5));
    }
    // additional leg
    int idx = 0;
    string additionalLeg = cPtLine + IntegerToString(idx);
    while (ObjectFind(additionalLeg) >= 0)
    {
        ObjectSet(additionalLeg, OBJPROP_TIME2 , time2);
        ObjectSet(additionalLeg, OBJPROP_PRICE2, price2);
        idx++;
        additionalLeg = cPtLine + IntegerToString(idx);
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
    time1   = (datetime)ObjectGet(cPtLine, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPtLine, OBJPROP_TIME2);
    price1  =           ObjectGet(cPtLine, OBJPROP_PRICE1);
    price2  =           ObjectGet(cPtLine, OBJPROP_PRICE2);

    if (objId == cLbText)
    {
        time2   = (datetime)ObjectGet(cLbText, OBJPROP_TIME1);
        price2  =           ObjectGet(cLbText, OBJPROP_PRICE1);
    }
    else if (pCommonData.mCtrlHold == true)
    {
        double textPrice = ObjectGet(cLbText, OBJPROP_PRICE1);
        if (price2 == textPrice)
        {
            price1 = pCommonData.mMousePrice;
        }
    }

    refreshData();
}
void CallOut::onItemClick(const string &itemId, const string &objId){}
void CallOut::onItemChange(const string &itemId, const string &objId)
{
    multiSetProp(OBJPROP_COLOR, (color)ObjectGet(objId, OBJPROP_COLOR), cLbText+cPtLine+iUdLine);
    onItemDrag(itemId, objId);
}
void CallOut::onItemDeleted(const string &itemId, const string &objId)
{
    if (objId == cLbText || objId == cPtLine || objId == iUdLine)
    {
        BaseItem::onItemDeleted(itemId, objId);
    }
    // additional leg removing
    int idx = 0;
    string objName = "";
    do
    {
        objName = cPtLine + IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}