#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

input string Label_; // ● Label ●
input color  Label_Color = clrMidnightBlue; // Color

enum LabelTextType
{
    TYPE_NUM,
};

class LabelText : public BaseItem
{
// Internal Value
private:
    int itemDragIdx;
    int posX;
    int posY;
    int spaceSize;
// Component name
private:
    string cLbText;

// Value define for Item
private:

public:
    LabelText(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
    virtual void onUserRequest(const string &itemId, const string &objId);
};

LabelText::LabelText(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    // Init variable type
    mNameType [0] = "LabelText";
    mTypeNum = TYPE_NUM;
    mIndexType = 0;
    
    /* Size | Space
        10  | 15
        12  | 19
    */
    spaceSize = 19;
    mContextType = "Add";
}

// Internal Event
void LabelText::prepareActive(){}
void LabelText::createItem()
{
    ObjectCreate(cLbText, OBJ_LABEL, 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    ObjectSet(cLbText, OBJPROP_XDISTANCE, pCommonData.mMouseX);
    ObjectSet(cLbText, OBJPROP_YDISTANCE, pCommonData.mMouseY);
}
void LabelText::updateDefaultProperty()
{
    ObjectSetText(cLbText, "label", 12, "Consolas", Label_Color);
}
void LabelText::updateTypeProperty(){}
void LabelText::activateItem(const string& itemId)
{
    cLbText = itemId + "_cLbText";
}
void LabelText::updateItemAfterChangeType(){}
void LabelText::refreshData()
{
    ObjectSet(cLbText, OBJPROP_XDISTANCE, posX);
    ObjectSet(cLbText, OBJPROP_YDISTANCE, posY);
    int idx = 0;
    string additionalText = cLbText +"#"+ IntegerToString(idx);
    while (ObjectFind(additionalText) >= 0)
    {
        ObjectSet(additionalText, OBJPROP_XDISTANCE, posX);
        ObjectSet(additionalText, OBJPROP_YDISTANCE, posY+(idx+1)*spaceSize);
        idx++;
        additionalText = cLbText +"#"+ IntegerToString(idx);
    }
}
void LabelText::finishedJobDone(){}

// Chart Event
void LabelText::onMouseMove(){}
void LabelText::onMouseClick()
{
    createItem();
    mFinishedJobCb();
}
void LabelText::onItemDrag(const string &itemId, const string &objId)
{
    int size = (int)ObjectGet(objId, OBJPROP_FONTSIZE);
    if     (size == 10) spaceSize = 15;
    else if(size == 12) spaceSize = 19;

    itemDragIdx = -1;
    if (objId == cLbText)
    {
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE);
    }
    else
    {
        string sparamItems[];
        int k=StringSplit(objId,'#',sparamItems);
        if (k != 3) return;
        itemDragIdx = StrToInteger(sparamItems[2]);
        posX = (int)ObjectGet(objId, OBJPROP_XDISTANCE);
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE)-(itemDragIdx+1)*spaceSize;
    }
    refreshData();
}
void LabelText::onItemClick(const string &itemId, const string &objId)
{
    string lastItem = cLbText;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    ObjectSet(cLbText, OBJPROP_SELECTED, selected);

    int idx = 0;
    string additionalText = cLbText +"#"+ IntegerToString(idx);
    while (ObjectFind(additionalText) >= 0)
    {
        ObjectSet(additionalText, OBJPROP_SELECTED, selected);
        lastItem = additionalText;
        idx++;
        additionalText = cLbText +"#"+ IntegerToString(idx);
    }
    if (selected == true && objId == lastItem && pCommonData.mShiftHold) gContextMenu.openContextMenu(objId, mContextType, -1);
}
void LabelText::onItemChange(const string &itemId, const string &objId)
{
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    // font color size
    string font = ObjectGetString(ChartID(), objId, OBJPROP_FONT);
    color c     = (color)ObjectGet(objId, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(objId, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGetInteger(ChartID(), cLbText, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGetInteger(ChartID(), cLbText, OBJPROP_CORNER);
    
    ObjectSet(cLbText, OBJPROP_COLOR, c);
    ObjectSet(cLbText, OBJPROP_FONTSIZE, size);
    ObjectSetString(ChartID(), cLbText, OBJPROP_FONT, font);
    ObjectSetInteger(ChartID(), cLbText, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), cLbText, OBJPROP_CORNER, corner);

    int idx = 0;
    string additionalText = cLbText +"#"+ IntegerToString(idx);
    while (ObjectFind(additionalText) >= 0)
    {
        ObjectSet(additionalText, OBJPROP_COLOR, c);
        ObjectSet(additionalText, OBJPROP_FONTSIZE, size);
        ObjectSetString(ChartID(), additionalText, OBJPROP_FONT, font);
        ObjectSetInteger(ChartID(), additionalText, OBJPROP_ANCHOR, anchor);
        ObjectSetInteger(ChartID(), additionalText, OBJPROP_CORNER, corner);
        idx++;
        additionalText = cLbText +"#"+ IntegerToString(idx);
    }
}
void LabelText::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cLbText);
    int idx = 0;
    string objName = "";
    do
    {
        objName = cLbText +"#"+ IntegerToString(idx);
        idx++;
    }
    while (ObjectDelete(objName) == true);
}
void LabelText::onUserRequest(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);

    int newIdx = itemDragIdx+1;
    string objName = cLbText +"#"+ IntegerToString(newIdx);
    string tempContent1 = ObjectDescription(objName);
    while (ObjectFind(objName) >= 0)
    {
        newIdx++;
        objName = cLbText +"#"+ IntegerToString(newIdx);
    }
    ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
    string font = ObjectGetString(ChartID(), cLbText, OBJPROP_FONT);
    color c     = (color)ObjectGet(cLbText, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(cLbText, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGetInteger(ChartID(), cLbText, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGetInteger(ChartID(), cLbText, OBJPROP_CORNER);
    ObjectSet(objName, OBJPROP_COLOR, c);
    ObjectSet(objName, OBJPROP_FONTSIZE, size);
    ObjectSetString(ChartID(), objName, OBJPROP_FONT, font);
    ObjectSetInteger(ChartID(), objName, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), objName, OBJPROP_CORNER, corner);
    ObjectSet(objName, OBJPROP_XDISTANCE, posX);
    ObjectSet(objName, OBJPROP_YDISTANCE, posY+(newIdx+1)*spaceSize);

    gContextMenu.clearContextMenu();
}