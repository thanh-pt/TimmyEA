#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

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
    string cAlert;
// Value define for Item
private:

public:
    Alert(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
};

Alert::Alert(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
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
    cAlert = itemId + "_cAlert";
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
        ObjectCreate(cAlert, OBJ_HLINE, 0, 0, pCommonData.mMousePrice);
        SetObjectStyle(cAlert, InpAlertColor, InpAlertStyle, 0);
        // ObjectSet(cAlert, OBJPROP_BACK , true);
        mAlertIndi = (ObjectGet(cAlert, OBJPROP_PRICE1) > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        ObjectSetText(cAlert, mAlertIndi + "Alert");
        // Add Alert to mListAlertStr
        mListAlertStr += cAlert + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification("Alert OK!");
    }
    mFinishedJobCb();
}
void Alert::onItemDrag(const string &itemId, const string &objId)
{
    if (objId == cAlert)
    {
        double priceAlert = ObjectGet(cAlert, OBJPROP_PRICE1);
        if (pCommonData.mCtrlHold == true)
        {
            priceAlert = pCommonData.mMousePrice;
            ObjectSet(cAlert, OBJPROP_PRICE1, priceAlert);
        }
        mAlertText = ObjectGetString(ChartID(), cAlert, OBJPROP_TEXT);
        mAlertIndi = (priceAlert > Bid ? ALERT_INDI_H : ALERT_INDI_L);
        StringReplace(mAlertText, ALERT_INDI_H, "");
        StringReplace(mAlertText, ALERT_INDI_L, "");

        mAlertText = mAlertIndi + " " + mAlertText;
        ObjectSetText(cAlert, mAlertText);

        if (StringFind(mListAlertStr, cAlert) == -1)
        {
            mListAlertStr += cAlert + ",";
        }
    }
}
void Alert::onItemClick(const string &itemId, const string &objId){}
void Alert::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cAlert) onItemDrag(itemId, objId);
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
        if (StringFind(alertLine, "cAlert") == -1) continue;
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
        if (StringFind(mListAlertArr[i], "cAlert") == -1) continue;

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
