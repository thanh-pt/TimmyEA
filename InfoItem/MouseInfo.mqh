#include "../CommonData.mqh"
#include "../Utility.mqh"

input color MouseInfo_Color = clrBlack; // Mouse Color

class MouseInfo
{
private:
    CommonData* pCommonData;
    string mObjMouseInfo;
public:
    MouseInfo(CommonData* commonData)
    {
        pCommonData = commonData;
        mObjMouseInfo = STATIC_TAG+"MouseInfo";
        initDrawing();
    }
    void initDrawing()
    {
        ObjectCreate(mObjMouseInfo, OBJ_LABEL, 0, 0, 0);
        ObjectSetText(mObjMouseInfo, "", 10, "Consolas");
        ObjectSet(mObjMouseInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjMouseInfo, OBJPROP_COLOR, MouseInfo_Color);
        ObjectSetString( 0, mObjMouseInfo, OBJPROP_TOOLTIP,"\n");
        ObjectSetInteger(0, mObjMouseInfo, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    void onMouseMove()
    {
        ObjectSet(mObjMouseInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX+20);
        ObjectSet(mObjMouseInfo, OBJPROP_YDISTANCE, pCommonData.mMouseY);
    }
    void onObjectDeleted(const string& objectName)
    {
        if (objectName == mObjMouseInfo)
        {
            initDrawing();
        }
    }
public:
    void setText(const string tIcon)
    {
        ObjectSetText(mObjMouseInfo, tIcon);
    }
};