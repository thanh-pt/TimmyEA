#include "../Base/BaseItem.mqh"
#include "../Utility.mqh"

// input string          ItemTemplate_ = "ItemTemplate Config";

enum ItemTemplateType
{
    TYPE_NUM,
};

class ItemTemplate : public BaseItem
{
// Internal Value
private:
// Component name
private:
// Value define for Item
private:

public:
    ItemTemplate(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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

ItemTemplate::ItemTemplate(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "ItemTemplate1";
    mTypeNum = TYPE_NUM;
    mIndexType = 0;
}

// Internal Event
void ItemTemplate::prepareActive(){}
void ItemTemplate::createItem(){}
void ItemTemplate::updateDefaultProperty(){}
void ItemTemplate::updateTypeProperty(){}
void ItemTemplate::activateItem(const string& itemId){}
void ItemTemplate::updateItemAfterChangeType(){}
void ItemTemplate::refreshData(){}
void ItemTemplate::finishedJobDone(){}

// Chart Event
void ItemTemplate::onMouseMove(){}
void ItemTemplate::onMouseClick(){}
void ItemTemplate::onItemDrag(const string &itemId, const string &objId){}
void ItemTemplate::onItemClick(const string &itemId, const string &objId){}
void ItemTemplate::onItemChange(const string &itemId, const string &objId){}
void ItemTemplate::onItemDeleted(const string &itemId, const string &objId){}