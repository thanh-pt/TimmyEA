#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

input string          Zz_;                          // ●  Z I G Z A G  ●
input color           Zz_Color = clrMidnightBlue;   // Color
input ELineStyle      Zz_Style = eLineSolid1;       // Style

class ZigZag : public BaseItem
{
// Internal Value
private:
    int    mLineIndex;
    string mTempLine;
    
// Component name
private:
    string cline;
// Value define for Item
private:
    datetime time1;
    datetime time2;
    double price1;
    double price2;

public:
    ZigZag(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

ZigZag::ZigZag(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mIndexType = 0;
    mTypeNum = 0;
}

// Internal Event
void ZigZag::prepareActive()
{
    mLineIndex = 0;
    mTempLine = "";
}
void ZigZag::createItem()
{
    mTempLine = cline + "#" + IntegerToString(mLineIndex++);
    ObjectCreate(mTempLine, OBJ_TREND, 0, pCommonData.mMouseTime, pCommonData.mMousePrice);
    updateDefaultProperty();
}
void ZigZag::updateDefaultProperty()
{
    SetObjectStyle(mTempLine, Zz_Color, getLineStyle(Zz_Style), getLineWidth(Zz_Style));
    ObjectSet(mTempLine, OBJPROP_BACK , true);
    ObjectSetString(ChartID(), mTempLine ,OBJPROP_TOOLTIP,"\n");
}
void ZigZag::updateTypeProperty(){}
void ZigZag::activateItem(const string& itemId)
{
    cline = itemId + "_cline";
}
void ZigZag::updateItemAfterChangeType(){}
void ZigZag::refreshData(){}
void ZigZag::finishedJobDone()
{
    if (mTempLine != "")
    {
        ObjectDelete(mTempLine);
        mTempLine = "";
    }
}

// Chart Event
void ZigZag::onMouseMove()
{
    ObjectSet(mTempLine, OBJPROP_TIME2,  pCommonData.mMouseTime);
    ObjectSet(mTempLine, OBJPROP_PRICE2, pCommonData.mMousePrice);
}
void ZigZag::onMouseClick()
{
    createItem();
}
void ZigZag::onItemDrag(const string &itemId, const string &objId)
{
    int i = 0;
    string objName;
    do
    {
        objName = cline + "#" + IntegerToString(i);
        if (objName == objId)
        {
            break;
        }
        i++;
    }
    while (ObjectFind(objName) >= 0);

    time1   = (datetime)ObjectGet(objId, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(objId, OBJPROP_TIME2);
    price1  =           ObjectGet(objId, OBJPROP_PRICE1);
    price2  =           ObjectGet(objId, OBJPROP_PRICE2);
    if (pCommonData.mCtrlHold == true) {
        if (pCommonData.mMouseTime == time1){
            price1 = pCommonData.mMousePrice;
            ObjectSet(objId, OBJPROP_PRICE1, price1);
        } else if (pCommonData.mMouseTime == time2){
            price2 = pCommonData.mMousePrice;
            ObjectSet(objId, OBJPROP_PRICE2, price2);
        }
    }

    string nextObj = cline + "#" + IntegerToString(i+1);
    string prevObj = cline + "#" + IntegerToString(i-1);
    ObjectSet(nextObj, OBJPROP_TIME1,  time2 );
    ObjectSet(nextObj, OBJPROP_PRICE1, price2);
    ObjectSet(prevObj, OBJPROP_TIME2,  time1 );
    ObjectSet(prevObj, OBJPROP_PRICE2, price1);
}
void ZigZag::onItemClick(const string &itemId, const string &objId)
{
    int objSelected = (int)ObjectGet(objId, OBJPROP_SELECTED);

    int i = 0;
    string objName;
    do
    {
        objName = cline + "#" + IntegerToString(i);
        ObjectSet(objName, OBJPROP_SELECTED, objSelected);
        i++;
    }
    while (ObjectFind(objName) >= 0);
}
void ZigZag::onItemChange(const string &itemId, const string &objId)
{
    int propColor = (int)ObjectGet(objId, OBJPROP_COLOR);
    int propWidth = (int)ObjectGet(objId, OBJPROP_WIDTH);
    int propStyle = (int)ObjectGet(objId, OBJPROP_STYLE);
    int propBkgrd = (int)ObjectGet(objId, OBJPROP_BACK);
    int i = 0;
    string objName;
    do
    {
        objName = cline + "#" + IntegerToString(i);
        SetObjectStyle(objName, propColor, propStyle, propWidth);
        ObjectSet(objName, OBJPROP_BACK,  propBkgrd);
        i++;
    }
    while (ObjectFind(objName) >= 0);
}