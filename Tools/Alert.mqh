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
string mCurAlertIndi;
string mListAlertArr[];
int    mAlertNumber;
bool   mIsAlertReached;
bool   mIsAlertGoOver;
double mCurAlertPrice;
string mListAlertRemainStr;

// Component name
private:
    string cLn01;
    string cPtM0;
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
void Alert::createItem(){}
void Alert::updateDefaultProperty(){}
void Alert::updateTypeProperty(){}
void Alert::activateItem(const string& itemId)
{
    cPtM0 = itemId + TAG_CTRM + "cPtM0";
    cLn01 = itemId + TAG_CTRL + "cLn01";
    mAllItem += cPtM0+cLn01;
}
string Alert::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_CTRM + "cPtM0";
    allItem += itemId + TAG_CTRL + "cLn01";
    return allItem;
}
void Alert::updateItemAfterChangeType(){}
void Alert::refreshData(){
    setItemPos(cLn01, time1, time1 + 3*Period()*60, price1, price1);
    setItemPos(cPtM0, time1, price1);

    int selected = (int)ObjectGet(cPtM0, OBJPROP_SELECTED);
    ObjectSet(cLn01, OBJPROP_COLOR, selected ? clrRed : InpAlertColor);
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
        ObjectCreate(cPtM0, OBJ_ARROW, 0, 0, pCommonData.mMousePrice);
        ObjectCreate(cLn01, OBJ_TREND, 0, 0, pCommonData.mMousePrice);

        setObjectStyle(cLn01, InpAlertColor, InpAlertStyle, 0, true);
        ObjectSet(cLn01, OBJPROP_RAY  , true);
        
        ObjectSet(cPtM0, OBJPROP_COLOR, clrNONE);
        ObjectSet(cPtM0, OBJPROP_ARROWCODE  , 4);

        time1  = pCommonData.mMouseTime;
        price1 = pCommonData.mMousePrice;
        refreshData();

        // Function Config
        mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        setTextContent(cPtM0, mAlertIndi);
        mListAlertStr += cPtM0 + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification("Alert OK!");
    }
    mFinishedJobCb();
}
void Alert::onItemDrag(const string &itemId, const string &objId)
{
    time1 = (datetime)ObjectGet(objId, OBJPROP_TIME1);
    price1 =          ObjectGet(objId, OBJPROP_PRICE1);
    if (pCommonData.mCtrlHold) {
        price1 = pCommonData.mMousePrice;
    }

    mAlertIndi = (price1 > Bid ? ALERT_INDI_H : ALERT_INDI_L);
    setTextContent(cPtM0, mAlertIndi);

    if (StringFind(mListAlertStr, cPtM0) == -1) mListAlertStr += cPtM0 + ",";

    refreshData();
}
void Alert::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    setCtrlItemSelectState(mAllItem, selected);
    ObjectSet(cLn01, OBJPROP_COLOR, selected ? clrRed : InpAlertColor);
}
void Alert::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLn01) onItemDrag(itemId, objId);
}
// Internal Function

void Alert::initAlarm()
{
    mListAlertStr = "";
    mCurAlertIndi = "";
    mAlertNumber = 0;
    mIsAlertReached = false;
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
    for (int i = 0; i < mAlertNumber; i++) {
        // Check valid Alert
        if (ObjectFind(mListAlertArr[i]) < 0) continue;

        // Get Alert information
        mIsAlertReached = false;
        mIsAlertGoOver  = false;
        mCurAlertPrice = ObjectGet(mListAlertArr[i], OBJPROP_PRICE1);
        mCurAlertIndi  = ObjectGetString(ChartID(), mListAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (mCurAlertIndi == ALERT_INDI_H) {
            mIsAlertReached = (Bid >= mCurAlertPrice);
            mIsAlertGoOver  = (Bid > mCurAlertPrice);
        }
        else if (mCurAlertIndi == ALERT_INDI_L) {
            mIsAlertReached = (Bid <= mCurAlertPrice);
            mIsAlertGoOver  = (Bid < mCurAlertPrice);
        }

        // Send notification or save remain Alert
        if (mIsAlertReached == true) {
            sendNotification("[" + Symbol() + "/" + getTFString() + "]\n" +
                            mCurAlertIndi + "\n" +
                            DoubleToString(mCurAlertPrice, Digits));
        }
        if (mIsAlertGoOver) ObjectDelete(mListAlertArr[i]);
        else mListAlertRemainStr += mListAlertArr[i] + ",";
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
