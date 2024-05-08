#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string  _9 = "";
// TODO: Indi nay dang su dung moi Alert
int  Chartutil_WorkBeg   = 13 - 07; 
int  Chartutil_WorkEnd   = 18 - 07; 
int Chartutil_Asian_Beg  = 07 - 07;
int Chartutil_Asian_End  = 13 - 07;
int Chartutil_London_Beg = 14 - 07;
int Chartutil_London_End = 18 - 07;
int Chartutil_NY_Beg     = 19 - 07;
int Chartutil_NY_End     = 23 - 07;

enum ChartUtilType
{
    CREATE_ALERT,
    TEST_ALERT,
    CUTIL_NUM,
    SESSION_LINE, // Not use
    WORKING_AREA, // Not use
};

class ChartUtil : public BaseItem
{
// Internal Value
private:
string mAlertIndi;
string mAlertText;

// Component name
private:
    string cAlert;
// Value define for Item
private:

public:
    ChartUtil(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
    void createSessionLine(const datetime& date, int beg, int end, string mask);

// Chart Event
public:
    virtual void onMouseMove();
    virtual void onMouseClick();
    virtual void onItemDrag(const string &itemId, const string &objId);
    virtual void onItemClick(const string &itemId, const string &objId);
    virtual void onItemChange(const string &itemId, const string &objId);
};

ChartUtil::ChartUtil(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [CREATE_ALERT] = (gAlertActive ? "Alert" : "Alert disabled");
    mNameType [TEST_ALERT]   = "Test Alert";
    mTypeNum = CUTIL_NUM;
    mIndexType = 0;
}

// Internal Event
void ChartUtil::prepareActive(){}
void ChartUtil::createItem(){}
void ChartUtil::updateDefaultProperty(){}
void ChartUtil::updateTypeProperty(){}
void ChartUtil::activateItem(const string& itemId)
{
    cAlert = itemId + "_cAlert";
}
void ChartUtil::updateItemAfterChangeType(){}
void ChartUtil::refreshData(){}
void ChartUtil::finishedJobDone(){}

// Chart Event
void ChartUtil::onMouseMove()
{
}
void ChartUtil::onMouseClick()
{
    if (mIndexType == SESSION_LINE && ChartPeriod() <= PERIOD_M15){
        datetime mouseDate = StrToTime(TimeToStr(pCommonData.mMouseTime, TIME_DATE));
        // TODO: Tự động update session cho mùa đông
        createSessionLine(mouseDate, Chartutil_Asian_Beg, Chartutil_Asian_End, "As");
        createSessionLine(mouseDate, Chartutil_London_Beg, Chartutil_London_End, "Lo");
        createSessionLine(mouseDate, Chartutil_NY_Beg, Chartutil_NY_End, "NY");
    }
    if (mIndexType == WORKING_AREA)
    {
        // TODO: indi này chỉ vẽ trong trong TF H4 đổ xuống thôi
        // S1: Get Date only
        string strToday = TimeToStr(pCommonData.mMouseTime, TIME_DATE);
        // S2: Detect working time
        datetime dtToday = StrToTime(strToday);
        datetime openTime  = dtToday + 3600*Chartutil_WorkBeg;
        datetime closeTime = dtToday + 3600*Chartutil_WorkEnd;
        int beginBar = iBarShift(ChartSymbol(), ChartPeriod(), openTime );
        int endBar   = iBarShift(ChartSymbol(), ChartPeriod(), closeTime);

        // S3: Detect High Low
        double highest = High[beginBar];
        double lowest  = Low[beginBar];
        if (ChartPeriod() <= PERIOD_H4) {
            if (beginBar > 0)
            {
                for (int i = beginBar; i > endBar; i--){
                    if (High[i] > highest) highest = High[i];
                    if (Low[i] < lowest)   lowest  = Low[i];
                }
            }
            else
            {
                highest = iHigh(ChartSymbol(), PERIOD_D1, 1);
                lowest  = iLow(ChartSymbol(), PERIOD_D1, 1);
            }
        }
        else
        {
            mFinishedJobCb();
            return;
        }

        // S4: Create and set workingRect Position
        if (ObjectFind(strToday) < 0)
        {
            ObjectCreate(strToday, OBJ_RECTANGLE , 0, 0, 0);
            SetObjectStyle(strToday, clrDarkSlateGray, 2, 0);
        }
        setItemPos(strToday, openTime, closeTime, highest, lowest);
    }
    else if (mIndexType == CREATE_ALERT && gAlertActive)
    {
        ObjectCreate(cAlert, OBJ_HLINE, 0, 0, pCommonData.mMousePrice);
        SetObjectStyle(cAlert, clrGainsboro, STYLE_DASHDOT, 0);
        ObjectSet(cAlert, OBJPROP_BACK , true);
        mAlertIndi = (ObjectGet(cAlert, OBJPROP_PRICE1) > Bid ? "[H]" : "[L]");
        ObjectSetText(cAlert, mAlertIndi + "Alert");
        // Add Alert to gListAlert
        gListAlert += cAlert + ",";
    }
    else if (mIndexType == TEST_ALERT){
        SendNotification(Symbol()+":\n" + "Test Alert");
    }
    mFinishedJobCb();
}
void ChartUtil::onItemDrag(const string &itemId, const string &objId)
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

        if (StringFind(gListAlert, cAlert) == -1)
        {
            gListAlert += cAlert + ",";
        }
    }
}
void ChartUtil::onItemClick(const string &itemId, const string &objId){}
void ChartUtil::onItemChange(const string &itemId, const string &objId)
{
    if (objId == cAlert) onItemDrag(itemId, objId);
}
// Internal function
void ChartUtil::createSessionLine(const datetime& date, int beg, int end, string mask)
{
    string objBeg = TimeToStr(date, TIME_DATE)+mask+"Beg";
    string objEnd = TimeToStr(date, TIME_DATE)+mask+"End";
    if (ObjectFind(objBeg) >= 0) {
        // Toggle Session on/off
        ObjectDelete(objBeg);
        ObjectDelete(objEnd);
        return;
    }
    ObjectCreate(objBeg, OBJ_VLINE , 0, date + beg*3600, 0);
    ObjectCreate(objEnd, OBJ_VLINE , 0, date + end*3600, 0);
    ObjectSetString(ChartID(), objBeg, OBJPROP_TOOLTIP, "\n");
    ObjectSetString(ChartID(), objEnd, OBJPROP_TOOLTIP, "\n");
    ObjectSet(objBeg, OBJPROP_COLOR, clrGainsboro);
    ObjectSet(objEnd, OBJPROP_COLOR, clrGainsboro);
    if (mask == "Lo") ObjectSet(objEnd, OBJPROP_COLOR, clrBrown);
    if (mask == "As") ObjectSet(objEnd, OBJPROP_COLOR, clrDarkGreen);
    ObjectSet(objBeg, OBJPROP_STYLE, 2);
    ObjectSet(objEnd, OBJPROP_STYLE, 2);
    ObjectSet(objBeg, OBJPROP_BACK , true);
    ObjectSet(objEnd, OBJPROP_BACK , true);
    ObjectSet(objBeg, OBJPROP_SELECTABLE, false);
    ObjectSet(objEnd, OBJPROP_SELECTABLE, false);
    ObjectSetText(objBeg, mask);
    ObjectSetText(objEnd, mask+" E");
}