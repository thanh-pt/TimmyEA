#include "../Home/CommonData.mqh"

class MouseInfo
{
private:
    CommonData* pCommonData;
    string mObjMouseInfo;
    string mObjMouseBgnd;
public:
    MouseInfo(CommonData* commonData)
    {
        pCommonData = commonData;
        mObjMouseInfo = STATIC_TAG+"MouseInfo";
        mObjMouseBgnd = STATIC_TAG+"mObjMouseBgnd";
        initDrawing();
    }
    void initDrawing()
    {
        // Background
        ObjectCreate(mObjMouseBgnd, OBJ_LABEL, 0, 0, 0);
        setTextContent(mObjMouseBgnd, "", 20, FONT_TEXT, gClrTextBgnd);
        ObjectSet(mObjMouseBgnd, OBJPROP_SELECTABLE, false);
        ObjectSetString( 0, mObjMouseBgnd, OBJPROP_TOOLTIP,"\n");
        ObjectSetInteger(0, mObjMouseBgnd, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
        // Content
        ObjectCreate(mObjMouseInfo, OBJ_LABEL, 0, 0, 0);
        setTextContent(mObjMouseInfo, "", 10, FONT_TEXT, gClrForegrnd);
        ObjectSet(mObjMouseInfo, OBJPROP_SELECTABLE, false);
        ObjectSetString( 0, mObjMouseInfo, OBJPROP_TOOLTIP,"\n");
        ObjectSetInteger(0, mObjMouseInfo, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
    }
    void onMouseMove()
    {
        ObjectSet(mObjMouseInfo, OBJPROP_XDISTANCE, pCommonData.mMouseX+20);
        ObjectSet(mObjMouseInfo, OBJPROP_YDISTANCE, pCommonData.mMouseY);
        ObjectSet(mObjMouseBgnd, OBJPROP_XDISTANCE, pCommonData.mMouseX+20);
        ObjectSet(mObjMouseBgnd, OBJPROP_YDISTANCE, pCommonData.mMouseY);
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
        setTextContent(mObjMouseInfo, " " + tIcon);
        if (tIcon != "") setTextContent(mObjMouseBgnd, getHalfBlock2(StringLen(tIcon)));
        else setTextContent(mObjMouseBgnd, "");
    }
};