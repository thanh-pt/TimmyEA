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
input LINE_STYLE    InpAlertStyle   = STYLE_DOT;    // Style

class Alert : public BaseItem
{
// Internal Value
private:
string mAlertIndi;
string mAlertText;
// handleAlertVariable
string mListAlertStr;
string mCurrentAlertText;
string mListAlertArr[];
int    mAlertNumber;
bool   mIsAlertReached;
bool   mIsAlertGoOver;
double mCurrentAlertPrice;
string mListAlertRemainStr;

// Component name
private:
    string cLnM0;
// Value define for Item
private:

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
    cLnM0 = itemId + TAG_CTRM + "cLnM0";
}
string Alert::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_CTRM + "cLnM0";
    return allItem;
}
void Alert::updateItemAfterChangeType(){}
void Alert::refreshData(){}
void Alert::finishedJobDone(){}

// Chart Event
void Alert::onMouseMove()
{
}
void Alert::onMouseClick()
{
    if (mIndexType == CREATE_ALERT)
    {
        ObjectCreate(cLnM0, OBJ_HLINE, 0, 0, pCommonData.mMousePrice);
        setObjectStyle(cLnM0, InpAlertColor, InpAlertStyle, 0);
        // ObjectSet(cLnM0, OBJPROP_BACK , true);
        mAlertIndi = (ObjectGet(cLnM0, OBJPROP_PRICE1) > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        setTextContent(cLnM0, mAlertIndi + "Alert");
        // Add Alert to mListAlertStr
        mListAlertStr += cLnM0 + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification("Alert OK!");
    }
    mFinishedJobCb();
}
void Alert::onItemDrag(const string &itemId, const string &objId)
{
    if (objId == cLnM0)
    {
        double priceAlert = ObjectGet(cLnM0, OBJPROP_PRICE1);
        if (pCommonData.mCtrlHold == true)
        {
            priceAlert = pCommonData.mMousePrice;
            ObjectSet(cLnM0, OBJPROP_PRICE1, priceAlert);
        }
        mAlertText = ObjectGetString(ChartID(), cLnM0, OBJPROP_TEXT);
        mAlertIndi = (priceAlert > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        StringReplace(mAlertText, ALERT_INDI_H, "");
        StringReplace(mAlertText, ALERT_INDI_L, "");

        mAlertText = mAlertIndi + " " + mAlertText;
        setTextContent(cLnM0, mAlertText);

        if (StringFind(mListAlertStr, cLnM0) == -1)
        {
            mListAlertStr += cLnM0 + ",";
        }
    }
}
void Alert::onItemClick(const string &itemId, const string &objId){}
void Alert::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cLnM0) onItemDrag(itemId, objId);
}
// Internal Function

void Alert::initAlarm()
{
    mListAlertStr = "";
    mCurrentAlertText = "";
    mAlertNumber = 0;
    mIsAlertReached = false;
    mIsAlertGoOver  = false;
    mCurrentAlertPrice = 0;
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
    for (int i = 0; i < mAlertNumber; i++)
    {
        // Check valid Alert
        if (ObjectFind(mListAlertArr[i]) < 0) continue;
        // if (StringFind(mListAlertArr[i], TAG_CTRM) == -1) continue;

        // Get Alert information
        mIsAlertReached = false;
        mIsAlertGoOver  = false;
        mCurrentAlertPrice = ObjectGet(mListAlertArr[i], OBJPROP_PRICE1);
        mCurrentAlertText  = ObjectGetString(ChartID(), mListAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (StringFind(mCurrentAlertText,ALERT_INDI_H) != -1)
        {
            mIsAlertReached = (Bid >= mCurrentAlertPrice);
            mIsAlertGoOver  = (Bid > mCurrentAlertPrice);
        }
        else if (StringFind(mCurrentAlertText,ALERT_INDI_L) != -1)
        {
            mIsAlertReached = (Bid <= mCurrentAlertPrice);
            mIsAlertGoOver  = (Bid < mCurrentAlertPrice);
        }

        // Send notification or save remain Alert
        if (mIsAlertReached == true)
        {
            sendNotification("[" + Symbol() + "/" + getTFString() + "]\n" +
                            mCurrentAlertText + "\n" +
                            DoubleToString(mCurrentAlertPrice, gSymbolDigits));
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
