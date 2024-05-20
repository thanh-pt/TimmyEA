#ifndef UtilityHeader_mql
#define UtilityHeader_mql

#define STATIC_TAG          "%"
#define BG_TAG              "BgOverlapFix"
#define LINE_STYLE          ENUM_LINE_STYLE
// #define TAG_CTRL "_zct" // TODO <- update to this
#define TAG_CTRM "_cM"
#define TAG_CTRL "_c"
#define TAG_INFO "_0inf"

#define MAX_TYPE 15

#define CHART_EVENT_SELECT_CONTEXTMENU CHARTEVENT_CUSTOM+1
#define FULL_BLOCK "██████████████████████████████████████████████████████████████████"

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

#include "UtilityStore/SyncItem.mqh"
#include "UtilityStore/GetAction.mqh"
#include "UtilityStore/SetAction.mqh"

string gStrRand[] = {
    "TẬP TRUNG vào nguyên tắc.",
    "BÁM SÁT kế hoạch.",
    "SỢ mất tiền.",
    "GIAO DỊCH theo kế hoạch.",
    "Kỳ vọng thực tế.",
    "SỢ THẤT BẠI, PHẠM SAI LẦM.",
    "ĐÚC KẾT bài học.",
    "CẮT GIẢM rủi ro.",
    "Tự tin nội tại.",
    "TĂNG áp lực.",
    "VÔ KỶ LUẬT, PHẢN ỨNG BỐC ĐỒNG.",
    "TỰ khiến bản thân.",
    "GIẢI QUYẾT vấn đề.",
    "Kết quả ngẫu nhiên.",
    "TƯ DUY dài hạn.",
    "KHÔNG GIAO DỊCH.",
    "Khiêm tốn.",
    "HỌC CÁCH thua cuộc.",
    "GIỎI duy nhất.",
    "TẬP TRUNG vào quá trình.",
    "LẬP KẾ HOẠCH.",
    "TẠO quy trình.",
    "Ngủ đủ giấc.",
    "KHÔNG VỚI giao dịch.",
    "KỶ LUẬT ĐÁNH BẠI.",
    "CHÚ TRỌNG chất lượng.",
    "THỰC HIỆN giao dịch.",
    "Thời điểm thoát lệnh.",
    "Kẻ thù lớn nhất.",
    "LUÔN là học sinh.",
    "KIỂM SOÁT rủi ro.",
    "HỌC TẬP từ người thành công.",
    "So sánh bản thân.",
    "TUÂN THỦ nguyên tắc, QUẢN LÝ rủi ro.",
};

void EraseAll()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        // if (StringFind(objName, "Trade") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        ObjectDelete(objName);
    }
}

void EraseLowerTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, STATIC_TAG) != -1) continue;
        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) >= ChartPeriod())
            {
                continue;
            }
            ObjectDelete(objName);
        }
    }
}

void EraseThisTF()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "Trade") != -1) continue;
        if (StringFind(objName, STATIC_TAG) != -1) continue;

        string sparamItems[];
        int k1=StringSplit(objName,'_',sparamItems);
        if (k1 == 3)
        {
            string strInfoItem[];
            int k2 = StringSplit(sparamItems[1],'#',strInfoItem);
            if (k2 == 2 && StrToInteger(strInfoItem[0]) == ChartPeriod())
            {
                ObjectDelete(objName);
            }
        }
    }
}

int hashString(string str)
{
    int hashChk = 0;
    for (int i = 0; i < StringLen(str); i++) hashChk += ((i+1)*StringGetCharacter(str, i));
    return hashChk;
}

void removeBackgroundOverlap(string target)
{
    int targetId = getObjectTimeId(target);
    string bgItem  = "";
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectFind(ChartID(), objName) != 0) continue;
        if (ObjectType(objName) != OBJ_RECTANGLE) continue;
        if (ObjectGet (objName, OBJPROP_BACK) == false) continue;
        if (StringFind(objName, BG_TAG) != -1) continue;
        if (objName == target) continue;
        bgItem = BG_TAG;
        int objId = getObjectTimeId(objName);
        if (targetId > objId) bgItem += (IntegerToString(targetId) +"."+ IntegerToString(objId));
        else bgItem += (IntegerToString(objId) +"."+ IntegerToString(targetId));
        ObjectDelete(bgItem);
    }
}

void EraseBgOverlap()
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, BG_TAG) != -1) ObjectDelete(objName);
    }
}

double hue2rgb(double p, double q, double t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1./6) return p + (q - p) * 6 * t;
  if (t < 1./2) return q;
  if (t < 2./3) return p + (q - p) * (2./3 - t) * 6;
  return p;
}

color increaseLum(color c)
{
    // 0x00BBGGRR
    double r = (double)((c&0x000000FF)    );
    double g = (double)((c&0x0000FF00)>>8 );
    double b = (double)((c&0x00FF0000)>>16);
    double h,s,l;
    // 1. RGB -> HSL
    r /= 255;
    g /= 255;
    b /= 255;
    double max = MAX(MAX(r,g),b);
    double min = MIN(MIN(r,g),b);
    h = s = l = (max + min) / 2;
    if (max == min) h = s = 0; // achromatic
    else
    {
        double d = max - min;
        s = (l > 0.5) ? d / (2 - max - min) : d / (max + min);
        if      (max == r) h = (g - b) / d + (g < b ? 6 : 0);
        else if (max == g) h = (b - r) / d + 2;
        else if (max == b) h = (r - g) / d + 4;
        h /= 6;
    }
    // 2. Increase lum
    l -= 0.1;
    // 3. HSL -> RGB
    if (0 == s) r = g = b = l; // achromatic
    else
    {
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        double p = 2 * l - q;
        r = hue2rgb(p, q, h + 1./3) * 255;
        g = hue2rgb(p, q, h) * 255;
        b = hue2rgb(p, q, h - 1./3) * 255;
    }
    // 4. Combine RGB to color
    c = (color)((int)r|((int)g<<8)|((int)b<<16));
    return c;
}

color decreaseLum(color c)
{
    // 0x00BBGGRR
    double r = (double)((c&0x000000FF)    );
    double g = (double)((c&0x0000FF00)>>8 );
    double b = (double)((c&0x00FF0000)>>16);
    double h,s,l;
    // 1. RGB -> HSL
    r /= 255;
    g /= 255;
    b /= 255;
    double max = MAX(MAX(r,g),b);
    double min = MIN(MIN(r,g),b);
    h = s = l = (max + min) / 2;
    if (max == min) h = s = 0; // achromatic
    else
    {
        double d = max - min;
        s = (l > 0.5) ? d / (2 - max - min) : d / (max + min);
        if      (max == r) h = (g - b) / d + (g < b ? 6 : 0);
        else if (max == g) h = (b - r) / d + 2;
        else if (max == b) h = (r - g) / d + 4;
        h /= 6;
    }
    // 2. Increase lum
    l += 0.1;
    // 3. HSL -> RGB
    if (0 == s) r = g = b = l; // achromatic
    else
    {
        double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        double p = 2 * l - q;
        r = hue2rgb(p, q, h + 1./3) * 255;
        g = hue2rgb(p, q, h) * 255;
        b = hue2rgb(p, q, h - 1./3) * 255;
    }
    // 4. Combine RGB to color
    c = (color)((int)r|((int)g<<8)|((int)b<<16));
    return c;
}

void scanBackgroundOverlap(string target)
{
    color targetColor = (color)ObjectGet(target, OBJPROP_COLOR);
    if (targetColor == clrNONE) return;
    if (ObjectGet(target, OBJPROP_BACK) == false) return;

    double price1  =           ObjectGet(target, OBJPROP_PRICE1);
    double price2  =           ObjectGet(target, OBJPROP_PRICE2);
    datetime time1 = (datetime)ObjectGet(target, OBJPROP_TIME1);
    datetime time2 = (datetime)ObjectGet(target, OBJPROP_TIME2);
    int targetId = getObjectTimeId(target);
    string bgItem = "";

    if (price1 > price2)
    {
        double tempP = price1;
        price1 = price2;
        price2 = tempP;
    }
    if (time1 > time2)
    {
        datetime tempT = time1;
        time1 = time2;
        time2 = tempT;
    }

    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectFind(ChartID(), objName) != 0) continue;
        if (ObjectType(objName) != OBJ_RECTANGLE) continue;
        if (ObjectGet (objName, OBJPROP_BACK) == false) continue;
        if (ObjectGet (objName, OBJPROP_COLOR) == clrNONE) continue;
        if (StringFind(objName, BG_TAG) != -1) continue;
        if (StringFind(objName, "Rectangle") == -1) continue;
        if (objName == target) continue;

        double cprice1  = ObjectGet(objName, OBJPROP_PRICE1);
        double cprice2  = ObjectGet(objName, OBJPROP_PRICE2);
        if (cprice1 > cprice2)
        {
            double tempP = cprice1;
            cprice1 = cprice2;
            cprice2 = tempP;
        }
        datetime ctime1 = (datetime)ObjectGet(objName, OBJPROP_TIME1);
        datetime ctime2 = (datetime)ObjectGet(objName, OBJPROP_TIME2);
        if (ctime1 > ctime2)
        {
            datetime tempT = ctime1;
            ctime1 = ctime2;
            ctime2 = tempT;
        }
        int objId = getObjectTimeId(objName);
        bgItem = BG_TAG;
        if (targetId > objId) bgItem += (IntegerToString(targetId) +"."+ IntegerToString(objId));
        else bgItem += (IntegerToString(objId) +"."+ IntegerToString(targetId));

        // Case 2 rectangle does not touch
        if (price2 <= cprice1 || cprice2 <= price1 || time2 <= ctime1 || ctime2 <= time1)
        {
            if (ObjectFind(bgItem) >= 0)
            {
                ObjectDelete(bgItem);
            }
            continue;
        }
        color colorBgColor = (color)ObjectGet(objName, OBJPROP_COLOR);
        if (ObjectFind(bgItem) < 0)
        {
            ObjectCreate(bgItem, OBJ_RECTANGLE , 0, 0, 0);
            ObjectSet(bgItem   , OBJPROP_SELECTABLE, false);
            ObjectSetString(ChartID(), bgItem, OBJPROP_TOOLTIP, "\n");
        }
        if (colorBgColor == targetColor)
        {
            setRectangleBackground(bgItem, increaseLum(targetColor));
        }
        else
        {
            setRectangleBackground(bgItem, decreaseLum(targetColor));
        }

        if (cprice1 < price1) cprice1 = price1;
        if (cprice2 > price2) cprice2 = price2;
        if (ctime1 < time1) ctime1 = time1;
        if (ctime2 > time2) ctime2 = time2;
        setItemPos(bgItem, ctime1, ctime2, cprice1, cprice2);
    }
}

int weekOfYear(datetime date)
{
    return (TimeDayOfYear(date)+TimeDayOfWeek(StrToTime(IntegerToString(TimeYear(date))+".01.01"))-2)/7;
}

string strDayOfWeek(datetime date)
{
    int dayOfWeek = TimeDayOfWeek(date);
    string retDayOfW = "";
    switch (dayOfWeek)
    {
        case 0: retDayOfW = "CN"; break;
        case 1: retDayOfW = "T2"; break;
        case 2: retDayOfW = "T3"; break;
        case 3: retDayOfW = "T4"; break;
        case 4: retDayOfW = "T5"; break;
        case 5: retDayOfW = "T6"; break;
        case 6: retDayOfW = "T7"; break;
        // case 0: retDayOfW = "Su"; break;
        // case 1: retDayOfW = "Mo"; break;
        // case 2: retDayOfW = "Tu"; break;
        // case 3: retDayOfW = "We"; break;
        // case 4: retDayOfW = "Th"; break;
        // case 5: retDayOfW = "Fr"; break;
        // case 6: retDayOfW = "Sa"; break;
    }
    return retDayOfW;
}

int higherTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_M15;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_D1; break;
        case PERIOD_H4:  retTF = PERIOD_D1; break;
        case PERIOD_M15: retTF = PERIOD_H4; break;
        case PERIOD_M5: retTF = PERIOD_M15; break;
        case PERIOD_M1: retTF = PERIOD_M5; break;
    }
    return retTF;
}

int lowerTF()
{
    int currentTf = ChartPeriod();
    int retTF = PERIOD_M15;
    switch (currentTf)
    {
        case PERIOD_D1:  retTF = PERIOD_H4; break;
        case PERIOD_H4:  retTF = PERIOD_M15; break;
        case PERIOD_M15: retTF = PERIOD_M5; break;
        case PERIOD_M5:  retTF = PERIOD_M1; break;
        case PERIOD_M1:  retTF = PERIOD_M1; break;
    }
    return retTF;
}

void restoreBacktestingTrade() // TODO: Đẩy vào Trade Class
{
    long chartID = ChartID();
    string objEn = "";
    string enData = "";

    string sparamItems[];
    double size;

    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;
    datetime time1;
    datetime time2; // = time1 + 10 candle
    bool isBuy;

    for (int idx = 0; idx < 1000; idx++) {
        // Step 1: Find obj
        objEn = "sim#3d_en#" + IntegerToString(idx);
        if (ObjectFind(objEn) < 0) continue;

        // Step 2: extract data
        enData = ObjectGetString(chartID, objEn, OBJPROP_TOOLTIP);
        StringSplit(enData,'\n',sparamItems);
        size    = StrToDouble(StringSubstr(sparamItems[1], 6, 4));
        time1   = (datetime)ObjectGet(objEn, OBJPROP_TIME1);
        isBuy   = ((color)ObjectGet(objEn, OBJPROP_COLOR) == clrBlue);

        priceEN = ObjectGet(objEn, OBJPROP_PRICE1);
        priceSL = NormalizeDouble(priceEN - (isBuy ? 1 : -1) * 100 / size / 100000, 5);
        priceTP = priceEN + 2 * (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        priceBE = priceEN + (isBuy ? 1 : -1) * fabs(priceEN-priceSL);
        time2   = time1 + ChartPeriod()*600;
        // Step 3: Create Trade
        gpTrade.createTrade(idx, time1, time2, priceEN, priceSL, priceTP, priceBE);
    }
}


//---------------------
enum ELineStyle {
    eLineDot        ,   //Dot
    eLineSolid1     ,   //Solid
    eLineDash       ,   //Dash
    eLineDashDot    ,   //DashDot
    eLineDashDotDot ,   //DashDotDot
    eLineSolid2     ,   //Solid Bold
    eLineSolid3     ,   //Solid Extra Bold
    eLineSolid4     ,   //Solid Ultra Bold
    eLineSolid5     ,   //Solid Extreme Bold
};

int getLineWidth(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot       : return 1;
        case eLineSolid1    : return 1;
        case eLineDash      : return 1;
        case eLineDashDot   : return 1;
        case eLineDashDotDot: return 1;
        case eLineSolid2    : return 2;
        case eLineSolid3    : return 3;
        case eLineSolid4    : return 4;
        case eLineSolid5    : return 5;
    }
    return 0;
}

int getLineStyle(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot       : return STYLE_DOT  ;
        case eLineSolid1    : return STYLE_SOLID;
        case eLineDash      : return STYLE_DASH ;
        case eLineDashDot   : return STYLE_DASHDOT;
        case eLineDashDotDot: return STYLE_DASHDOTDOT;
        case eLineSolid2    : return STYLE_SOLID;
        case eLineSolid3    : return STYLE_SOLID;
        case eLineSolid4    : return STYLE_SOLID;
        case eLineSolid5    : return STYLE_SOLID;
    }
    return STYLE_SOLID;
}

#endif