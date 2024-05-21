#include "../Base/BaseItem.mqh"

input string Label_; // ●  L A B E L  ●
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
    string cTxtM;
    string cTxtX;
    string iTxBg;
    string iTBgX;

// Value define for Item
private:

public:
    LabelText(CommonData* commonData, MouseInfo* mouseInfo);

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

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string LabelText::Tag = ".TMLabel";

LabelText::LabelText(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = LabelText::Tag;
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
    ObjectCreate(iTxBg, OBJ_LABEL, 0, 0, 0);
    ObjectCreate(cTxtM, OBJ_LABEL, 0, 0, 0);
    updateDefaultProperty();
    updateTypeProperty();
    posX = pCommonData.mMouseX;
    posY = pCommonData.mMouseY;
    refreshData();
}
void LabelText::updateDefaultProperty()
{
    ObjectSetText(cTxtM, getRandStr(), 10, "Consolas", Label_Color);
    ObjectSetText(iTxBg, "   ", 10, "Consolas", clrLightGray);
}
void LabelText::updateTypeProperty(){}
void LabelText::activateItem(const string& itemId)
{
    cTxtM = itemId + TAG_CTRM + "cTxtM";
    cTxtX = itemId + TAG_CTRL + "cTxtX";
    iTxBg = itemId + TAG_INFO + "iTxBg";
    iTBgX = itemId + TAG_INFO + "iTBgX";
}
string LabelText::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iTxBg";
    allItem += itemId + TAG_CTRM + "cTxtM";

    string tBgX   = itemId + TAG_INFO + "iTBgX";
    string txtX   = itemId + TAG_CTRL + "cTxtX";
    int i = 1;
    string objiTBgX = tBgX + "#" + IntegerToString(i++);
    string objCTxtX = txtX + "#" + IntegerToString(i);
    while (ObjectFind(objCTxtX) >= 0){
        allItem += objiTBgX;
        allItem += objCTxtX;
        objCTxtX = txtX + "#" + IntegerToString(i);
        objiTBgX = tBgX + "#" + IntegerToString(i++);
    }

    return allItem;
}
void LabelText::updateItemAfterChangeType(){}
void LabelText::refreshData()
{
    ObjectSet(cTxtM, OBJPROP_XDISTANCE, posX);
    ObjectSet(cTxtM, OBJPROP_YDISTANCE, posY);
    ObjectSet(iTxBg, OBJPROP_XDISTANCE, posX);
    ObjectSet(iTxBg, OBJPROP_YDISTANCE, posY);
    int maxLen = StringLen(ObjectDescription(cTxtM));
    int strLen = 0;

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        ObjectSet(objCTxtX, OBJPROP_XDISTANCE, posX);
        ObjectSet(objCTxtX, OBJPROP_YDISTANCE, posY+(idx)*spaceSize);
        ObjectSet(objiTBgX, OBJPROP_XDISTANCE, posX);
        ObjectSet(objiTBgX, OBJPROP_YDISTANCE, posY+(idx)*spaceSize);
        strLen = StringLen(ObjectDescription(objCTxtX));
        if (strLen > maxLen) maxLen = strLen;
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    }
    idx--;
    string bgBlock = getFullBlock(maxLen);
    while (idx >= 1){
        objiTBgX = iTBgX +"#"+ IntegerToString(idx--);
        ObjectSetText(objiTBgX, bgBlock);
    }
    ObjectSetText(iTxBg, bgBlock);
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

    itemDragIdx = 0;
    if (objId == cTxtM)
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
        posY = (int)ObjectGet(objId, OBJPROP_YDISTANCE)-itemDragIdx*spaceSize;
    }
    refreshData();
}
void LabelText::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);

    string lastItem = cTxtM;
    ObjectSet(cTxtM, OBJPROP_SELECTED, selected);

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        ObjectSet(objCTxtX, OBJPROP_SELECTED, selected);
        lastItem = objCTxtX;
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    }
    if (selected == true && objId == lastItem && pCommonData.mShiftHold) gContextMenu.openContextMenu(objId, mContextType, -1);
}
void LabelText::onItemChange(const string &itemId, const string &objId)
{
    // font color size
    string font = ObjectGetString(ChartID(), objId, OBJPROP_FONT);
    color c     = (color)ObjectGet(objId, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(objId, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGetInteger(ChartID(), cTxtM, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGetInteger(ChartID(), cTxtM, OBJPROP_CORNER);
    
    ObjectSet(cTxtM, OBJPROP_COLOR, c);
    ObjectSet(cTxtM, OBJPROP_FONTSIZE, size);
    ObjectSetString(ChartID(), cTxtM, OBJPROP_FONT, font);
    ObjectSetInteger(ChartID(), cTxtM, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), cTxtM, OBJPROP_CORNER, corner);
    ObjectSet(iTxBg, OBJPROP_FONTSIZE, size);
    ObjectSetString(ChartID(),  iTxBg, OBJPROP_FONT, font);
    ObjectSetInteger(ChartID(), iTxBg, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), iTxBg, OBJPROP_CORNER, corner);

    int idx = 1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(idx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        ObjectSet(objCTxtX, OBJPROP_COLOR, c);
        ObjectSet(objCTxtX, OBJPROP_FONTSIZE, size);
        ObjectSetString(ChartID(), objCTxtX, OBJPROP_FONT, font);
        ObjectSetInteger(ChartID(), objCTxtX, OBJPROP_ANCHOR, anchor);
        ObjectSetInteger(ChartID(), objCTxtX, OBJPROP_CORNER, corner);
        
        ObjectSet(objiTBgX, OBJPROP_FONTSIZE, size);
        ObjectSetString(ChartID(),  objiTBgX, OBJPROP_FONT, font);
        ObjectSetInteger(ChartID(), objiTBgX, OBJPROP_ANCHOR, anchor);
        ObjectSetInteger(ChartID(), objiTBgX, OBJPROP_CORNER, corner);
        idx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
    }
}
void LabelText::onItemDeleted(const string &itemId, const string &objId)
{
    ObjectDelete(cTxtM);
    ObjectDelete(iTxBg);
    int idx = 1;
    string objCTxtX;
    string objiTBgX;
    do
    {
        objCTxtX = cTxtX +"#"+ IntegerToString(idx);
        objiTBgX = iTBgX +"#"+ IntegerToString(idx);
        ObjectDelete(objiTBgX);
        idx++;
    }
    while (ObjectDelete(objCTxtX) == true);
}
void LabelText::onUserRequest(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);

    int newIdx = itemDragIdx+1;
    string objCTxtX = cTxtX +"#"+ IntegerToString(newIdx);
    string objiTBgX = iTBgX +"#"+ IntegerToString(newIdx);
    while (ObjectFind(objCTxtX) >= 0)
    {
        newIdx++;
        objCTxtX = cTxtX +"#"+ IntegerToString(newIdx);
        objiTBgX = iTBgX +"#"+ IntegerToString(newIdx);
    }
    ObjectCreate(objiTBgX, OBJ_LABEL, 0, 0, 0);
    ObjectCreate(objCTxtX, OBJ_LABEL, 0, 0, 0);
    string font = ObjectGetString(ChartID(), cTxtM, OBJPROP_FONT);
    color c     = (color)ObjectGet(cTxtM, OBJPROP_COLOR);
    int size    = (int)  ObjectGet(cTxtM, OBJPROP_FONTSIZE);
    int anchor  = (int)  ObjectGetInteger(ChartID(), cTxtM, OBJPROP_ANCHOR);
    int corner  = (int)  ObjectGetInteger(ChartID(), cTxtM, OBJPROP_CORNER);

    ObjectSet(objCTxtX, OBJPROP_XDISTANCE, posX);
    ObjectSet(objCTxtX, OBJPROP_YDISTANCE, posY+(newIdx)*spaceSize);
    ObjectSetText(objCTxtX, getRandStr(), size, font, c);
    ObjectSetInteger(ChartID(), objCTxtX, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), objCTxtX, OBJPROP_CORNER, corner);

    ObjectSet(objiTBgX, OBJPROP_XDISTANCE, posX);
    ObjectSet(objiTBgX, OBJPROP_YDISTANCE, posY+(newIdx)*spaceSize);
    ObjectSetText(objiTBgX, getFullBlock(StringLen(ObjectDescription(objCTxtX))), size, font, clrLightGray);
    ObjectSetInteger(ChartID(), objiTBgX, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(ChartID(), objiTBgX, OBJPROP_CORNER, corner);

    gContextMenu.clearContextMenu();
}