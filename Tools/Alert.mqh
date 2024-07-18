#include "../Base/BaseItem.mqh"

#define ALERT_INDI_H "↑"
#define ALERT_INDI_L "↓"

enum EAlertType
{
    CREATE_ALERT,
    TEST_ALERT,
    CUTIL_NUM,
};

enum ENotiType
{
    ENotiPhone, // Phone
    ENotiPC,    // PC
    ENotiNone,  // Silent
};

input string        _Alert;                         // ●  A L E R T  ●
input ENotiType     InpNotiType     = ENotiPhone;   // Alert
input color         InpAlertColor   = clrGainsboro; // Color
      LINE_STYLE    InpAlertStyle   = STYLE_DOT;    // Style

class Alert : public BaseItem
{
// Internal Value
private:
string mAlertIndi;
string mAlertText;
// handleAlertVariable
string mListAlertStr;
string mCurAlertText;
string mListAlertArr[];
int    mAlertNumber;
bool   mIsAlertGoOver;
double mCurAlertPrice;
string mListAlertRemainStr;

// Component name
private:
    string cLn01;
    string cPtM0;
    string iTxtR;
// Value define for Item
private:
    datetime time1;
    double   price1;

public:
    Alert(CommonData* commonData, MouseInfo* mouseInfo);

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

// Internal Function
private:
    void initAlarm();
    void sendNotification(string msg);
public:
    void checkAlert();

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

static string Alert::Tag = ".TMAlert";

Alert::Alert(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Alert::Tag;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [CREATE_ALERT] = "Alert Line";
    mNameType [TEST_ALERT]   = "Test Alert";
    mTypeNum = CUTIL_NUM;
    mIndexType = 0;

    initAlarm();
}

// Internal Event
void Alert::prepareActive(){}
void Alert::createItem()
{
    ObjectCreate(iTxtR, OBJ_TEXT , 0, 0, 0);
    ObjectCreate(cLn01, OBJ_TREND, 0, 0, 0);
    ObjectCreate(cPtM0, OBJ_ARROW, 0, 0, 0);

    updateDefaultProperty();
    // updateTypeProperty();
}
void Alert::updateDefaultProperty()
{
    setObjectStyle(cLn01, InpAlertColor, InpAlertStyle, 0, true);
    ObjectSet(cLn01, OBJPROP_RAY  , true);
    
    ObjectSet(cPtM0, OBJPROP_COLOR, InpAlertColor);
    ObjectSet(cPtM0, OBJPROP_ARROWCODE, 2);

    setTextContent(iTxtR, "🔔", 8, FONT_TEXT, InpAlertColor);
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Alert::updateTypeProperty(){}
void Alert::activateItem(const string& itemId)
{
    iTxtR = itemId + TAG_INFO + "iTxtR";

    cLn01 = itemId + TAG_CTRL + "cLn01";
    cPtM0 = itemId + TAG_CTRM + "cPtM0";
    mAllItem += iTxtR+cPtM0+cLn01;
}
string Alert::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxtR";

    allItem += itemId + TAG_CTRM + "cPtM0";
    allItem += itemId + TAG_CTRL + "cLn01";
    return allItem;
}
void Alert::updateItemAfterChangeType(){}
void Alert::refreshData(){
    setItemPos(cLn01, time1, time1 + getDistanceBar(10), price1, price1);
    setItemPos(cPtM0, time1, price1);
    setItemPos(iTxtR, Time[0] + getDistanceBar(5), price1);

    int barT1 = iBarShift(ChartSymbol(), ChartPeriod(), time1);
    bool isUp = (price1 >= High[barT1]);
    ObjectSetInteger(0, iTxtR, OBJPROP_ANCHOR, isUp ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);

    int selected = (int)ObjectGet(cPtM0, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR, selected ? gClrForegrnd : InpAlertColor, cLn01+cPtM0+iTxtR);
}
void Alert::finishedJobDone(){}

// Chart Event
void Alert::onMouseMove()
{
}
void Alert::onMouseClick()
{
    if (mIndexType == CREATE_ALERT)
    {
        createItem();

        time1  = pCommonData.mMouseTime;
        price1 = pCommonData.mMousePrice;
        refreshData();

        // Function Config
        mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        setTextContent(cPtM0, mAlertIndi);
        mListAlertStr += cPtM0 + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification("↑﹉" + DoubleToString(gCommonData.mMousePrice, Digits) + "\nThông báo OK!");
    }
    mFinishedJobCb();
}
void Alert::onItemDrag(const string &itemId, const string &objId)
{
    if (pCommonData.mCtrlHold) {
        price1 = pCommonData.mMousePrice;
        time1  = pCommonData.mMouseTime;
    }
    else if (objId == cPtM0) {
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        price1 =          ObjectGet(objId, OBJPROP_PRICE1);
    }
    else if (objId == cLn01) {
        time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
        price1 =          ObjectGet(objId, OBJPROP_PRICE2);
    }

    mAlertText = ObjectGetString(ChartID(), cPtM0, OBJPROP_TEXT);
    StringReplace(mAlertText, ALERT_INDI_H, "");
    StringReplace(mAlertText, ALERT_INDI_L, "");
    mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
    mAlertText = mAlertIndi + mAlertText;
    setTextContent(cPtM0, mAlertText);

    if (StringFind(mListAlertStr, cPtM0) == -1) mListAlertStr += cPtM0 + ",";

    refreshData();
}
void Alert::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gClrForegrnd : InpAlertColor, cLn01+cPtM0+iTxtR);
}
void Alert::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLn01) {
        string description = ObjectDescription(objId);
        if (description != ""){
            setTextContent(objId, "");
            if (description == "-") description = "";
            setTextContent(iTxtR, "🔔"+description);
            price1 = ObjectGet(objId, OBJPROP_PRICE1);
            mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
            mAlertText = mAlertIndi + description;
            setTextContent(cPtM0, mAlertText);
        }
    }
}
// Internal Function

void Alert::initAlarm()
{
    mListAlertStr = "";
    mCurAlertText = "";
    mAlertNumber = 0;
    mIsAlertGoOver  = false;
    mCurAlertPrice = 0;
    mListAlertRemainStr = "";
    string alertLine = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        alertLine = ObjectName(i);
        if (StringFind(alertLine, Alert::Tag) == -1) continue;
        if (StringFind(alertLine, TAG_CTRM) == -1) continue;
        // Add Alert to the list
        if (mListAlertStr != "") mListAlertStr += ",";
        mListAlertStr += alertLine;
    }
}

void Alert::checkAlert()
{
    mAlertNumber  = StringSplit(mListAlertStr,',',mListAlertArr);
    mListAlertRemainStr = "";
    bool isHighAlert = false;
    for (int i = 0; i < mAlertNumber; i++) {
        // Check valid Alert
        if (ObjectFind(mListAlertArr[i]) < 0) continue;

        // Get Alert information
        mIsAlertGoOver  = false;
        mCurAlertPrice = ObjectGet(mListAlertArr[i], OBJPROP_PRICE1);
        mCurAlertText  = ObjectGetString(ChartID(), mListAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (StringFind(mCurAlertText,ALERT_INDI_H) != -1) {
            mIsAlertGoOver  = (Bid > mCurAlertPrice);
            isHighAlert = true;
        }
        else if (StringFind(mCurAlertText,ALERT_INDI_L) != -1){
            mIsAlertGoOver  = (Bid < mCurAlertPrice);
            isHighAlert = false;
        }

        // Send notification or save remain Alert
        if (mIsAlertGoOver) {
            StringReplace(mAlertText, ALERT_INDI_H, "");
            StringReplace(mAlertText, ALERT_INDI_L, "");
            sendNotification(   (isHighAlert ? ALERT_INDI_H : ALERT_INDI_L) + DoubleToString(mCurAlertPrice, Digits) + (mAlertText!="" ? "\n" : "")
                                + mAlertText);
            ObjectDelete(mListAlertArr[i]);
        }
        else {
            mListAlertRemainStr += mListAlertArr[i] + ",";
            if (Bid == mCurAlertPrice) {
                StringReplace(mAlertText, ALERT_INDI_H, "");
                StringReplace(mAlertText, ALERT_INDI_L, "");
                sendNotification(   (isHighAlert ? "↑﹉" : "↓﹍") + DoubleToString(mCurAlertPrice, Digits) + (mAlertText!="" ? "\n" : "")
                                    + mAlertText);
            }
        }
    }
    mListAlertStr = mListAlertRemainStr;
}

void Alert::sendNotification(string msg)
{
    if (InpNotiType == ENotiNone) return;
    if (InpNotiType == ENotiPhone){
        SendNotification(msg);
    } else {
        Alert(msg);
    }
}
