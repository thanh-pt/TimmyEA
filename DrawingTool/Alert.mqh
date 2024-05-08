#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

enum EAlertType
{
    CREATE_ALERT,
    TEST_ALERT,
    CUTIL_NUM,
};

enum ENotiType
{
    ENotiPhone, // Phone Notification
    ENotiPC,    // PC Notification
};

input string    _Alert;                     // ● Alert ●
input bool      InpAlertActive = false;     // Alert Active
input ENotiType InpNotiType = ENotiPhone;   // Notification Type

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
        SetObjectStyle(cAlert, clrGainsboro, STYLE_DASHDOT, 0);
        ObjectSet(cAlert, OBJPROP_BACK , true);
        mAlertIndi = (ObjectGet(cAlert, OBJPROP_PRICE1) > Bid ? "[H]" : "[L]");
        ObjectSetText(cAlert, mAlertIndi + "Alert");
        // Add Alert to mListAlertStr
        mListAlertStr += cAlert + ",";
    }
    else if (mIndexType == TEST_ALERT){
        sendNotification(Symbol()+":\n" + "Test Alert");
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
        mAlertIndi = (priceAlert > Bid ? "[H]" : "[L]");

        if (StringFind(mAlertText, "[H]") == -1 && StringFind(mAlertText, "[L]") == -1 )
        {
            // Cannot found Indi => Add Indi
            mAlertText = mAlertIndi + " " + mAlertText;
            ObjectSetText(cAlert, mAlertText);
        }
        else if (StringFind(mAlertText, mAlertIndi) == -1)
        {
            // Indi not correct, remove old indi and replate new indi
            StringSetCharacter(mAlertText, 1, 'x');
            StringReplace(mAlertText, "[x]", mAlertIndi);
            ObjectSetText(cAlert, mAlertText);
        }

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
        mCurrentAlertPrice = ObjectGet(mListAlertArr[i], OBJPROP_PRICE1);
        mCurrentAlertText  = ObjectGetString(ChartID(), mListAlertArr[i], OBJPROP_TEXT);
        // Check Alert Price
        if (StringFind(mCurrentAlertText,"[H]") != -1)
        {
            mIsAlertReached = (Bid >= mCurrentAlertPrice);
        }
        else if (StringFind(mCurrentAlertText,"[L]") != -1)
        {
            mIsAlertReached = (Bid <= mCurrentAlertPrice);
        }

        // Send notification or save remain Alert
        if (mIsAlertReached == true)
        {
            sendNotification(Symbol()+":   "+ DoubleToString(mCurrentAlertPrice, gSymbolDigits) + "\n" + mCurrentAlertText);
            ObjectDelete(mListAlertArr[i]);
        }
        else
        {
            mListAlertRemainStr += mListAlertArr[i] + ",";
        }
    }
    mListAlertStr = mListAlertRemainStr;
}

void Alert::sendNotification(string msg)
{
    if (InpAlertActive == false) return;
    if (InpNotiType == ENotiPhone){
        SendNotification(msg);
    } else {
        Alert(msg);
    }
}
