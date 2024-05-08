#include "../Utility.mqh"

input string Templ_; // ● Template ●
input color Templ_TextColor = clrBlack;     // Text Color
input color Templ_BgColor1  = clrGray;      // Bg Color
input color Templ_BgColor2  = clrLightGray; // Selected Color

#define TEXT_FULL_BLOCK "██████████████████████████████████████████████████████████████████"
#define MAX_ROW 4

class Templates
{
private:
    string mActiveObjectId;
    string mTemplates[];
    int    mSize;
    int    mMaxLength;
    bool   mIsOpen;
public:
    int mActivePos;

public:
    Templates()
    {
        mIsOpen = false;
    }
    virtual void onItemClick(const string &objId)
    {
        // Todo check template item or not?
        if (StringFind(objId, "Templates") == -1) return;

        string sparamItems[];
        int k=StringSplit(objId,'_',sparamItems);
        if (k != 2) return;

        mActivePos = StrToInteger(sparamItems[1]);
        string itemBgnd;
        for (int i = 0; i < mSize; i++)
        {
            itemBgnd = "TemplatesBgnd_"+IntegerToString(i);
            if (i == mActivePos){
                ObjectSet(itemBgnd, OBJPROP_COLOR, Templ_BgColor2);
            }
            else {
                ObjectSet(itemBgnd, OBJPROP_COLOR, Templ_BgColor1);
            }
        }
        gController.handleSparamEvent(CHART_EVENT_SELECT_TEMPLATES, mActiveObjectId);
    }
public:
    void openTemplates(const string objId, const string data, const int activePos)
    {
        if (mIsOpen == true) clearTemplates();
        mActiveObjectId = objId;
        mActivePos = activePos;
        mSize = StringSplit(data,',',mTemplates);
        mMaxLength = 0;
        int tempLength;
        for (int i = 0; i < mSize; i++)
        {
            tempLength = StringLen(mTemplates[i]);
            if (tempLength > mMaxLength) mMaxLength = tempLength;
        }
        mMaxLength += 2;
        for (int i = 0; i < mSize; i++)
        {
            drawItem(mTemplates[i], i);
        }
        mIsOpen = true;
    }
    void clearTemplates()
    {
        if (mIsOpen == false) return;
        mActiveObjectId = "";
        for (int i = 0; i < MAX_TYPE; i++)
        {
            deleteItem(i);
        }
        mIsOpen = false;
    }
private:
    void drawItem(const string& name, int pos)
    {
        string itemName = "TemplatesName_"+IntegerToString(pos);
        string itemBgnd = "TemplatesBgnd_"+IntegerToString(pos);
        ObjectCreate(itemBgnd, OBJ_LABEL, 0, 0, 0);
        ObjectCreate(itemName, OBJ_LABEL, 0, 0, 0);
        ObjectSet(itemBgnd, OBJPROP_SELECTABLE, false);
        ObjectSet(itemName, OBJPROP_SELECTABLE, false);
        ObjectSetText(itemBgnd, StringSubstr(TEXT_FULL_BLOCK, 0, mMaxLength), 10, "Consolas", Templ_BgColor1);
        ObjectSetText(itemName,                                     " "+name, 10, "Consolas", Templ_TextColor);
        ObjectSetInteger(0, itemName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
        ObjectSetInteger(0, itemBgnd, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);

        int topOffset  = gCommonData.mMouseY + 10 + (pos%MAX_ROW)*16;
        int leftOffset = gCommonData.mMouseX + 20 + (pos/MAX_ROW)*mMaxLength*8;

        ObjectSet(itemName, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemName, OBJPROP_YDISTANCE, topOffset);

        ObjectSet(itemBgnd, OBJPROP_XDISTANCE, leftOffset);
        ObjectSet(itemBgnd, OBJPROP_YDISTANCE, topOffset);

        if (pos == mActivePos)
        {
            ObjectSet(itemBgnd, OBJPROP_COLOR, Templ_BgColor2);
        }
    }
    void deleteItem(int pos)
    {
        string itemName = "TemplatesName_"+IntegerToString(pos);
        string itemBgnd = "TemplatesBgnd_"+IntegerToString(pos);
        ObjectDelete(itemName);
        ObjectDelete(itemBgnd);
    }
};