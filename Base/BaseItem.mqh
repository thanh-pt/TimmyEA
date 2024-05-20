#include "../Home/CommonData.mqh"
#include "../Home/UtilityHeader.mqh"
#include "../InfoItem/MouseInfo.mqh"

typedef void(*FinishedJob)();

class BaseItem
{
private:
    string      mContextItems[];
protected:
    string      mItemName;
    CommonData* pCommonData;
    MouseInfo*  pMouseInfo;
    FinishedJob mFinishedJobCb;
protected:
    bool        mFirstPoint;
    int         mIndexType;
    int         mTypeNum;
    string      mNameType[CTX_MAX];
    string      mContextType;
    string      mTData;
    string      mAllItem;

protected:
    string createMouseInfo();

// Internal Event:
protected:
    virtual void prepareActive(){};
    virtual void createItem()=0;
    virtual void updateDefaultProperty(){};
    virtual void updateTypeProperty(){};
    virtual void activateItem(const string& itemId)=0;
    virtual void updateItemAfterChangeType(){};
    virtual void refreshData()=0;
    virtual void finishedJobDone(){};
    virtual void storeTData();

// Chart Event:
public:
    virtual void onMouseMove(){}
    virtual void onMouseClick(){}
    virtual void onItemDrag(const string &itemId, const string &objId)=0;
    virtual void onItemClick(const string &itemId, const string &objId){};
    virtual void onItemChange(const string &itemId, const string &objId){};
    virtual void onItemDeleted(const string &itemId, const string &objId);
    virtual void onUserRequest(const string &itemId, const string &objId);

public:
    void startActivate(FinishedJob cb);
    void finishedDeactivate();
    void changeActiveType();
    void changeActiveType(int type);
    void touchItem(const string& itemId);

public:
    ~BaseItem();
};

BaseItem::~BaseItem()
{
}

void BaseItem::startActivate(FinishedJob cb)
{
    ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
    if (mTypeNum == 0)
    {
        pMouseInfo.setText(mItemName);
    }
    else
    {
        pMouseInfo.setText(createMouseInfo());
    }
    mFirstPoint = false;
    mFinishedJobCb = cb;
    prepareActive();
    string itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(TimeLocal());
    mTData = itemId + "_mTData";
    mAllItem = mTData;
    activateItem(itemId);
}

void BaseItem::finishedDeactivate()
{
    storeTData();
    ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
    finishedJobDone();
}

void BaseItem::touchItem(const string& itemId)
{
    mTData      = itemId + "_mTData";
    mAllItem    = mTData;
    activateItem(itemId);
    mIndexType  = StrToInteger(ObjectDescription(mTData));
}

void BaseItem::changeActiveType(int type)
{
    if (mTypeNum <= 0 || type >= mTypeNum) return;

    mIndexType = type;
    pMouseInfo.setText(createMouseInfo());
    updateItemAfterChangeType();
    storeTData();
}

void BaseItem::changeActiveType()
{
    if (mTypeNum <= 0) return;

    if((++mIndexType) >= mTypeNum)
    {
        mIndexType = 0;
    }
    
    pMouseInfo.setText(createMouseInfo());
    updateItemAfterChangeType();
    storeTData();
}

string BaseItem::createMouseInfo()
{
    string mouseInfo = "";
    for (int i = 0; i < mTypeNum; i++)
    {
        if (i == mIndexType)
        {
            mouseInfo += "(" + IntegerToString(i+1) + "." + mNameType[i] + ") ";
            continue;
        }
        mouseInfo += IntegerToString(i+1) + "." + mNameType[i] + " ";
    }
    return mouseInfo;
}

void BaseItem::storeTData()
{
    if (ObjectFind(mTData) < 0) ObjectCreate(mTData, OBJ_TEXT, 0, 0, 0);
    ObjectSetText (mTData, IntegerToString(mIndexType));
}

void BaseItem::onUserRequest(const string &itemId, const string &objId)
{
    touchItem(itemId);
    mIndexType = gContextMenu.mActivePos;
    storeTData();
    updateTypeProperty();
    onItemDrag(itemId, objId);
}

void BaseItem::onItemDeleted(const string &itemId, const string &objId)
{
    int k=StringSplit(mAllItem,'.',mContextItems);
    for (int i = 0; i < k; i++)
    {
        if (mContextItems[i] == "") continue;
        ObjectDelete("."+mContextItems[i]);
    }
}