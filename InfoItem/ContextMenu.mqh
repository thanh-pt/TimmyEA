#include "../Home/UtilityHeader.mqh"

// input string ContexMenu_; // ●  C O N T E X T   M E N U  ●

#define MAX_ROW 4

class ContextMenu
{
private:
    string mActiveObjectId;
    string mContextMenu[];
    int    mSize;
    int    mMaxLength;
public:
    int mActivePos;
    string mActiveItemStr;
    bool   mIsOpen;

public:
    ContextMenu()
    {
        mIsOpen = false;
    }
    virtual void onItemClick(const string &objId)
    {
        if (StringFind(objId, "ContextMenu") == -1) return;

        string sparamItems[];
        int k=StringSplit(objId,'_',sparamItems);
        if (k != 2) return;

        mActivePos = StrToInteger(sparamItems[1]);
        string itemBgnd;
        for (int i = 0; i < mSize; i++)
        {
            itemBgnd = "ContextMenuBgnd_"+IntegerToString(i);
            if (i == mActivePos){
                ObjectSet(itemBgnd, OBJPROP_COLOR, gClrTextBgHl);
                string itemName = "ContextMenuName_"+IntegerToString(i);
                mActiveItemStr = StringTrimLeft(ObjectDescription(itemName));
            }
            else {
                ObjectSet(itemBgnd, OBJPROP_COLOR, gClrTextBgnd);
            }
        }
        gController.handleSparamEvent(CHART_EVENT_SELECT_CONTEXTMENU, mActiveObjectId);
    }
public:
    void openContextMenu(const string objId, const string data, const int activePos)
    {
        if (mIsOpen == true) clearContextMenu();
        mActiveObjectId = objId;
        mActivePos = activePos;
        mSize = StringSplit(data,',',mContextMenu);
        mMaxLength = 0;
        int tempLength;
        for (int i = 0; i < mSize; i++)
        {
            tempLength = StringLen(mContextMenu[i]);
            if (tempLength > mMaxLength) mMaxLength = tempLength;
        }
        mMaxLength += 2;
        for (int i = 0; i < mSize; i++)
        {
            drawItem(mContextMenu[i], i);
        }
        mIsOpen = true;
    }
    void clearContextMenu()
    {
        if (mIsOpen == false) return;
        mActiveObjectId = "";
        for (int i = 0; i < CTX_MAX; i++)
        {
            deleteItem(i);
        }
        mIsOpen = false;
    }
private:
    void drawItem(const string& name, int pos)
    {
        string itemName = "ContextMenuName_"+IntegerToString(pos);
        string itemBgnd = "ContextMenuBgnd_"+IntegerToString(pos);
        ObjectCreate(itemBgnd, OBJ_LABEL, 0, 0, 0);
        ObjectCreate(itemName, OBJ_LABEL, 0, 0, 0);
        ObjectSet(itemBgnd, OBJPROP_SELECTABLE, false);
        ObjectSet(itemName, OBJPROP_SELECTABLE, false);
        setTextContent(itemBgnd, getFullBL(mMaxLength), 8, FONT_BLOCK, gClrTextBgnd);
        setTextContent(itemName, getSpaceBL((mMaxLength-StringLen(name))/2)+name, 8, FONT_BLOCK, gClrForegrnd);
        ObjectSetString( 0, itemBgnd, OBJPROP_TOOLTIP,name);
        ObjectSetString( 0, itemName, OBJPROP_TOOLTIP,name);
        ObjectSetInteger(0, itemName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, itemBgnd, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        

        int topOffset  = gCommonData.mMouseY + 10 + (pos%MAX_ROW)*14;
        int leftOffset = gCommonData.mMouseX + 20 + (pos/MAX_ROW)*mMaxLength*7;

        ObjectSet(itemName, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemName, OBJPROP_YDISTANCE, topOffset);

        ObjectSet(itemBgnd, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemBgnd, OBJPROP_YDISTANCE, topOffset);

        if (pos == mActivePos)
        {
            ObjectSet(itemBgnd, OBJPROP_COLOR, gClrTextBgHl);
        }
    }
    void deleteItem(int pos)
    {
        string itemName = "ContextMenuName_"+IntegerToString(pos);
        string itemBgnd = "ContextMenuBgnd_"+IntegerToString(pos);
        ObjectDelete(itemName);
        ObjectDelete(itemBgnd);
    }
};