#include "../Home/CommonData.mqh"

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
        setTextContent(mObjMouseInfo, "", 10, FONT_TEXT);
        ObjectSet(mObjMouseInfo, OBJPROP_SELECTABLE, false);
        ObjectSet(mObjMouseInfo, OBJPROP_COLOR, gForegroundColor);
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
        setTextContent(mObjMouseInfo, tIcon);
    }
};