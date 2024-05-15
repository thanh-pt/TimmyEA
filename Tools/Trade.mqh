#include "../Base/BaseItem.mqh"
#include "../Home/Utility.mqh"

#define LONG_IDX 0

#define CTX_SPREAD      "Spread"
#define CTX_GOLIVE      "Go Live"
#define CTX_ADDSLTP     "Sl/TP"
#define CTX_AUTOBE      "Auto BE"

#define LIVE_INDI       "ʟɪᴠᴇ"

enum e_display
{
    HIDE, // Hide
    SHOW, // Show
    OPTION, // Selected → Show
};

input string          Trd_; // ● Trade ●
input string          Trd_apperence; //→ Giao diện:
//-------------------------------------------------
input color           Trd_TextColor     = clrMidnightBlue;   // Text Color
input int             Trd_TextSize      = 8;                 // Text Size
input color           Trd_TpColor       = clrSteelBlue;      // TP Color
input color           Trd_SlColor       = clrChocolate;      // SL Color
input color           Trd_EnColor       = clrChocolate;      // EN Color
input int             Trd_LineWidth     = 1;                 // Line Width
input color           Trd_SlBkgrdColor  = clrLavenderBlush;  // SlBg Color
input color           Trd_TpBkgrdColor  = clrWhiteSmoke;     // TpBg Color
//-------------------------------------------------
input string          Trd_calc; //→ Tính toán:
input double          Trd_Cost          = 5;     //Cost ($)
input e_display       Trd_ShowStats     = SHOW;  //Show Stats
input e_display       Trd_ShowPrice     = HIDE;  //Show Price
input e_display       Trd_ShowDollar    = HIDE;  //Show Dollar

int Trd_StlSpace = 2;

class Trade : public BaseItem
{
// Internal Value
private:
double mTradeLot;
string mNativeCurrency;
double mNativeCost;
double mSymbolCode;
double mStlSpace;
string mListLiveTradeStr;
string mListLiveTradeArr[];
string mLiveTradeCtx;

// Component name
private:
    string iBgndSL  ;
    string iBgndTP  ;
    string iTpLine  ;
    string iEnLine  ;
    string iSlLine  ;
    string iBeLine  ;
    string iTpPrice ;
    string iEnPrice ;
    string iSlPrice ;
    string iTpText  ;
    string iEnText  ;
    string iSlText  ;
    string iBeText  ;
    string cBoder   ;
    string cPointTP ;
    string cPointSL ;
    string cPointEN ;
    string cPointWD ;
    string cPointBE ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;

public:
    Trade(const string name, CommonData* commonData, MouseInfo* mouseInfo);

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
    virtual void onUserRequest(const string &itemId, const string &objId);
// Special functional
    void showHistory(bool isShow);
    void createTrade(int id, datetime _time1, datetime _time2, double _priceEN, double _priceSL, double _priceTP, double _priceBE);
    void scanLiveTrade();

// Alpha feature
    void initData();
};

Trade::Trade(const string name, CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = name;
    pCommonData = commonData;
    pMouseInfo = mouseInfo;

    mListLiveTradeStr = "";

    // Init variable type
    mNameType [0] = "Long";
    mNameType [1] = "Short";
    mIndexType = 0;
    mTypeNum = 2;

    mContextType  =        CTX_SPREAD;
    mContextType +=  "," + CTX_GOLIVE;

    mLiveTradeCtx  =        CTX_ADDSLTP;
    mLiveTradeCtx +=  "," + CTX_AUTOBE;

    // Other initialize
    string strSymbol = Symbol();
    mSymbolCode = 0;
    for (int i = 0; i < StringLen(strSymbol); i++)
    {
        mSymbolCode += strSymbol[i] * (i+1);
    }

    strSymbol = StringSubstr(strSymbol, 0, 6);
    mNativeCurrency = StringSubstr(strSymbol, StringLen(strSymbol)-3, 3);
    if (mNativeCurrency == "JPY")
    {
        mNativeCost = Trd_Cost * 1.49;
    }
    else if (strSymbol == "XAUUSD")
    {
        mNativeCost = Trd_Cost * 10;
    }
    else
    {
        mNativeCost = Trd_Cost;
    }
}

// Internal Event
void Trade::prepareActive(){}
void Trade::createItem()
{
    ObjectCreate(iBgndSL  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iBgndTP  , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iTpLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iBeLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iEnLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iSlLine  , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iTpPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iEnPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iSlPrice , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTpText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iEnText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iSlText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iBeText  , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBoder   , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPointTP , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointSL , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointEN , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointWD , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPointBE , OBJ_ARROW     , 0, 0, 0);

    updateTypeProperty();
    updateDefaultProperty();
}
void Trade::initData()
{
    time1   = pCommonData.mMouseTime;
    priceEN = pCommonData.mMousePrice;
    static int wd = 0;
    ChartXYToTimePrice(ChartID(), (int)pCommonData.mMouseX+100, (int)pCommonData.mMouseY+(mIndexType == LONG_IDX ? 50:-50), wd,  time2, priceSL);
    priceTP = 4*priceEN - 3*priceSL;
    priceBE = 2*priceEN - 1*priceSL;
}
void Trade::updateDefaultProperty()
{
    //-------------------------------------------------
    ObjectSet(iBgndSL, OBJPROP_BACK, true);
    ObjectSet(iBgndTP, OBJPROP_BACK, true);
    //-------------------------------------------------
    ObjectSet(cBoder, OBJPROP_BACK, false);
    ObjectSet(cBoder, OBJPROP_COLOR, clrNONE);
    //-------------------------------------------------
    multiSetProp(OBJPROP_ARROWCODE , 4    , cPointWD+cPointBE);
    multiSetProp(OBJPROP_ARROWCODE , 4    , cPointTP+cPointSL);
    ObjectSet(cPointEN, OBJPROP_ARROWCODE, 4);
    
    multiSetProp(OBJPROP_SELECTED  , true , cPointTP+cPointSL+cPointEN+cPointWD+cPointBE);
    multiSetProp(OBJPROP_RAY       , false, iTpLine+iBeLine+iEnLine+iSlLine);
    multiSetProp(OBJPROP_SELECTABLE, false, iBgndSL+iBgndTP+iTpLine+iBeLine+iEnLine+iSlLine+iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText);
    //-------------------------------------------------
    multiSetStrs(OBJPROP_TOOLTIP, "\n", iBgndSL+iBgndTP+iTpLine+iBeLine+iEnLine+iSlLine+iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText+cBoder+cPointTP+cPointSL+cPointEN+cPointWD+cPointBE);
}
void Trade::updateTypeProperty()
{
    ObjectSet(iBgndSL, OBJPROP_COLOR, Trd_SlBkgrdColor);
    ObjectSet(iBgndTP, OBJPROP_COLOR, Trd_TpBkgrdColor);
    ObjectSet(iBeLine, OBJPROP_WIDTH, 1);
    ObjectSet(iBeLine, OBJPROP_STYLE, 2);
    //-------------------------------------------------
    multiSetProp(OBJPROP_COLOR, Trd_TpColor  , iTpLine+iBeLine+cPointTP+cPointBE);
    multiSetProp(OBJPROP_COLOR, Trd_EnColor  , iEnLine+cPointEN+cPointWD);
    multiSetProp(OBJPROP_COLOR, Trd_SlColor  , iSlLine+cPointSL);
    multiSetProp(OBJPROP_COLOR, Trd_TextColor, iTpText+iEnText+iSlText+iBeText+iTpPrice+iEnPrice+iSlPrice);
    //-------------------------------------------------
    multiSetProp(OBJPROP_WIDTH   , Trd_LineWidth, iTpLine+iEnLine+iSlLine);
    multiSetProp(OBJPROP_FONTSIZE, Trd_TextSize , iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText+iTpPrice+iEnPrice+iSlPrice);
}
void Trade::activateItem(const string& itemId)
{
    iBgndSL  = itemId + "_iBgndSL";
    iBgndTP  = itemId + "_iBgndTP";
    iTpLine  = itemId + "_iTpLine";
    iEnLine  = itemId + "_iEnLine";
    iSlLine  = itemId + "_iSlLine";
    iBeLine  = itemId + "_iBeLine";
    iTpPrice = itemId + "_iTpPrice";
    iEnPrice = itemId + "_iEnPrice";
    iSlPrice = itemId + "_iSlPrice";
    iTpText  = itemId + "_iTpText";
    iEnText  = itemId + "_iEnText";
    iSlText  = itemId + "_iSlText";
    iBeText  = itemId + "_iBeText";
    cBoder   = itemId + "_cBoder";
    cPointTP = itemId + "_cPointTP";
    cPointSL = itemId + "_cPointSL";
    cPointEN = itemId + "_c0PointEN";
    cPointWD = itemId + "_ckPointWD";
    cPointBE = itemId + "_cPointBE";

    mAllItem += iBgndSL+iBgndTP+iTpLine+iEnLine+iSlLine+iBeLine+iTpPrice+iEnPrice+iSlPrice+iTpText+iEnText+iSlText+iBeText;
    mAllItem += cBoder+cPointTP+cPointSL+cPointEN+cPointWD+cPointBE;
}
void Trade::updateItemAfterChangeType(){}
void Trade::refreshData()
{
    if (ObjectFind(ChartID(), iBgndSL) < 0)
    {
        createItem();
    }
    datetime centerTime = getCenterTime(time1, time2);
    
    setItemPos(iBgndSL  , time1, time2, priceEN, priceSL);
    setItemPos(iBgndTP  , time1, time2, priceEN, priceTP);
    setItemPos(cBoder   , time1, time2, priceSL, priceTP);
    setItemPos(iTpLine  , time1, time2, priceTP, priceTP);
    setItemPos(iEnLine  , time1, time2, priceEN, priceEN);
    setItemPos(iSlLine  , time1, time2, priceSL, priceSL);
    setItemPos(iBeLine  , time1, time2, priceBE, priceBE);
    //-------------------------------------------------
    setItemPos(cPointTP , time2, priceTP);
    setItemPos(cPointSL , time2, priceSL);
    setItemPos(cPointEN , time1, priceEN);
    setItemPos(cPointWD , time2, priceEN);
    setItemPos(cPointBE , time2, priceBE);
    //-------------------------------------------------
    setItemPos(iTpText  , centerTime, priceTP);
    setItemPos(iEnText  , centerTime, priceEN);
    setItemPos(iSlText  , centerTime, priceSL);
    setItemPos(iBeText  , time2, priceBE);
    //-------------------------------------------------
    ObjectSetInteger(0, iEnText, OBJPROP_ANCHOR, ANCHOR_LOWER);
    if (priceTP > priceSL)
    {
        ObjectSetInteger(0, iSlText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0, iTpText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, iBeText, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0,iTpPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iEnPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iSlPrice, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    else
    {
        ObjectSetInteger(0, iSlText, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0, iTpText, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0, iBeText, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0,iTpPrice, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0,iEnPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iSlPrice, OBJPROP_ANCHOR, ANCHOR_UPPER);
    }
    //-------------------------------------------------
    //            TÍNH TOÁN CÁC THỨ
    //-------------------------------------------------
    // 1. Thông tin lệnh
    double slPip       = floor(fabs(priceEN-priceSL) * (pow(10, gSymbolDigits)))/10;
    if (slPip <= 0.001) return;

    double rr          = (priceTP-priceEN) / (priceEN-priceSL);
    double be          = (priceBE-priceEN) / (priceEN-priceSL);
    
    mTradeLot          = floor(mNativeCost / slPip * 10)/100;
    double realCost    = mTradeLot*slPip*10/mNativeCost*Trd_Cost;
    // 2. Thông tin hiển thị
    bool   selectState = (bool)ObjectGet(cPointWD, OBJPROP_SELECTED);
    bool   showStats   = (Trd_ShowStats  == SHOW) || (Trd_ShowStats  == OPTION && selectState);
    bool   showPrice   = (Trd_ShowPrice  == SHOW) || (Trd_ShowPrice  == OPTION && selectState);
    bool   showDollar  = (Trd_ShowDollar == SHOW) || (Trd_ShowDollar == OPTION && selectState);
    
    // 3. String Data để hiển thị
    string strTpInfo   = DoubleToString(rr,1) + "ʀ"; // RR + dola
    string strEnInfo   = ObjectDescription(cPointWD); // lot 
    string strSlInfo   = ""; // pip + dola
    string strBeInfo   = ObjectDescription(cPointBE); // RR1

    if (showStats)
    {
        if (strBeInfo != "") strBeInfo += ": ";
        // strTpInfo += DoubleToString(rr,1) + "ʀ";
        strBeInfo += DoubleToString(be,1) + "ʀ  ";
        strSlInfo += DoubleToString(slPip, 1) + "ᖰ";
    }
    //-------------------------------------------------
    if (showDollar)
    {
        if (showStats)
        {
            strTpInfo += " ~ ";
            strSlInfo += " ~ ";
        }
        strTpInfo += DoubleToString(rr*realCost, 2) + "$";
        strSlInfo += DoubleToString(realCost, 2) + "$";
    }
    //-------------------------------------------------
    if (showPrice)
    {
        ObjectSetText(iTpPrice, DoubleToString(priceTP, gSymbolDigits));
        ObjectSetText(iEnPrice, DoubleToString(priceEN, gSymbolDigits));
        ObjectSetText(iSlPrice, DoubleToString(priceSL, gSymbolDigits));
        if (strEnInfo != "") strEnInfo += " ";
        strEnInfo += DoubleToString(mTradeLot,2) + "lot";
    }
    else
    {
        ObjectSetText(iTpPrice, "");
        ObjectSetText(iEnPrice, "");
        ObjectSetText(iSlPrice, "");
    }
    
    setTextPos(iTpPrice, centerTime, priceTP);
    setTextPos(iEnPrice, centerTime, priceEN);
    setTextPos(iSlPrice, centerTime, priceSL);
    //-------------------------------------------------
    ObjectSetText(iTpText, strTpInfo);
    ObjectSetText(iEnText, strEnInfo);
    ObjectSetText(iSlText, strSlInfo);
    ObjectSetText(iBeText, strBeInfo);
    //scanBackgroundOverlap(iBgndSL);
    //scanBackgroundOverlap(iBgndTP);

}
void Trade::finishedJobDone(){}

// Chart Event
void Trade::onMouseMove(){}
void Trade::onMouseClick()
{
    createItem();
    initData();
    refreshData();
    mFinishedJobCb();
}
void Trade::onItemDrag(const string &itemId, const string &objId)
{
    priceTP =           ObjectGet(cPointTP, OBJPROP_PRICE1);
    priceEN =           ObjectGet(cPointEN, OBJPROP_PRICE1);
    priceSL =           ObjectGet(cPointSL, OBJPROP_PRICE1);
    priceBE =           ObjectGet(cPointBE, OBJPROP_PRICE1);
    time1   = (datetime)ObjectGet(cBoder  , OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPointWD, OBJPROP_TIME1);
    if (objId == cBoder)
    {
        datetime newtime1 = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
        datetime newtime2 = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
        double newtpPrice =           ObjectGet(cBoder, OBJPROP_PRICE2);
        double newslPrice =           ObjectGet(cBoder, OBJPROP_PRICE1);

        if ((newtime1 == time1 && newslPrice == priceSL) || (newtime2 == time2 && newtpPrice == priceTP))
        {
            // move edge -> ignore
        }
        else
        {
            priceBE += (newtpPrice-priceTP);
            priceEN += (newtpPrice-priceTP);
            priceSL = newslPrice;
            priceTP = newtpPrice;
            time1 = newtime1;
            time2 = newtime2;
        }
    }
    else
    {
        if (pCommonData.mCtrlHold == true)
        {
            if      (objId == cPointTP) priceTP = pCommonData.mMousePrice;
            else if (objId == cPointEN) priceEN = pCommonData.mMousePrice;
            else if (objId == cPointSL) priceSL = pCommonData.mMousePrice;
            else if (objId == cPointBE) priceBE = pCommonData.mMousePrice;
        }
        if (objId == cPointEN && pCommonData.mShiftHold == true){
            priceEN =           ObjectGet(cPointWD, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cPointEN, OBJPROP_TIME1);
        }
    }
    refreshData();
}
void Trade::onItemClick(const string &itemId, const string &objId)
{
    int selectState = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (objId == cPointTP || objId == cPointSL || objId == cPointEN || objId == cPointWD || objId == cPointBE)
    {
        ObjectSet(cPointTP, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointSL, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointEN, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointWD, OBJPROP_SELECTED, selectState);
        ObjectSet(cPointBE, OBJPROP_SELECTED, selectState);
    }
    onItemDrag(itemId, objId);
    if (objId == cPointWD && selectState == true && Trd_ShowPrice != HIDE && pCommonData.mShiftHold)
    {
        if (ObjectDescription(cPointWD) == LIVE_INDI){
            gContextMenu.openContextMenu(objId, mLiveTradeCtx, -1);
        }
        else{
            gContextMenu.openContextMenu(objId, mContextType, -1);
        }
    }
}
void Trade::onItemChange(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);
}

//-------------------------------------------------------------------
void Trade::showHistory(bool isShow)
{
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, "ckPointWD") == -1)
        {
            continue;
        }
        string sparamItems[];
        int k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName)
        {
            continue;
        }
        string objId = sparamItems[0] + "_" + sparamItems[1];
        activateItem(objId);
        if (isShow)
        {
            priceTP =           ObjectGet(cPointTP, OBJPROP_PRICE1);
            priceEN =           ObjectGet(cPointEN, OBJPROP_PRICE1);
            priceSL =           ObjectGet(cPointSL, OBJPROP_PRICE1);
            priceBE =           ObjectGet(cPointBE, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cBoder, OBJPROP_TIME1);
            time2   = (datetime)ObjectGet(cBoder, OBJPROP_TIME2);
            refreshData();
            continue;
        }
        
        if ((bool)ObjectGet(cPointWD, OBJPROP_SELECTED)) continue;
        if (ObjectDescription(cPointWD) != "") continue; // Don't hide live trade
        // Hide Item
        ObjectSet(iBgndSL , OBJPROP_PRICE1, 0);
        ObjectSet(iBgndTP , OBJPROP_PRICE1, 0);
        ObjectSet(iTpLine , OBJPROP_PRICE1, 0);
        ObjectSet(iBeLine , OBJPROP_PRICE1, 0);
        ObjectSet(iEnLine , OBJPROP_PRICE1, 0);
        ObjectSet(iSlLine , OBJPROP_PRICE1, 0);
        ObjectSet(cBoder  , OBJPROP_PRICE1, 0);
        ObjectSet(iBgndSL , OBJPROP_PRICE2, 0);
        ObjectSet(iBgndTP , OBJPROP_PRICE2, 0);
        ObjectSet(iTpLine , OBJPROP_PRICE2, 0);
        ObjectSet(iBeLine , OBJPROP_PRICE2, 0);
        ObjectSet(iEnLine , OBJPROP_PRICE2, 0);
        ObjectSet(iSlLine , OBJPROP_PRICE2, 0);
        ObjectSet(cBoder  , OBJPROP_PRICE2, 0);

        ObjectSet(iTpPrice, OBJPROP_TIME1, 0);
        ObjectSet(iEnPrice, OBJPROP_TIME1, 0);
        ObjectSet(iSlPrice, OBJPROP_TIME1, 0);
        ObjectSet(iTpText , OBJPROP_TIME1, 0);
        ObjectSet(iEnText , OBJPROP_TIME1, 0);
        ObjectSet(iSlText , OBJPROP_TIME1, 0);
        ObjectSet(iBeText , OBJPROP_TIME1, 0);
        ObjectSet(cPointTP, OBJPROP_TIME1, 0);
        ObjectSet(cPointSL, OBJPROP_TIME1, 0);
        ObjectSet(cPointEN, OBJPROP_TIME1, 0);
        ObjectSet(cPointWD, OBJPROP_TIME1, 0);
        ObjectSet(cPointBE, OBJPROP_TIME1, 0);
        
        //removeBackgroundOverlap(iBgndSL);
        //removeBackgroundOverlap(iBgndTP);
    }
}

void Trade::onUserRequest(const string &itemId, const string &objId)
{
    // Add Live Trade
    if (gContextMenu.mActiveItemStr == CTX_GOLIVE)
    {
        priceEN   = NormalizeDouble(priceEN, gSymbolDigits);
        priceSL   = NormalizeDouble(priceSL, gSymbolDigits);
        priceTP   = NormalizeDouble(priceTP, gSymbolDigits);
        mTradeLot = NormalizeDouble(mTradeLot, 2);
        int Cmd = ((priceTP > priceEN) ? OP_BUYLIMIT : OP_SELLLIMIT);
    
        int OrderNumber;
        int Slippage = 200;
        OrderNumber=OrderSend(Symbol(),Cmd,mTradeLot,priceEN,Slippage,priceSL,priceTP);
        if(OrderNumber>0){
            Print("Order ",OrderNumber," open");
            // Lấy những thông tin từ trade cũ
            priceBE = ObjectGet(cPointBE, OBJPROP_PRICE1);
            time1 = (datetime)ObjectGet(cBoder  , OBJPROP_TIME1);
            time2 = (datetime)ObjectGet(cPointWD, OBJPROP_TIME1);
            // Xoá trade item
            ObjectDelete(cPointWD);
            // Tạo trade mới theo Order number
            createTrade(OrderNumber, time1, time2, priceEN, priceSL, priceTP, priceBE);
            ObjectSetText(cPointWD, LIVE_INDI);
            mListLiveTradeStr += IntegerToString(OrderNumber) + ",";
        }
        else{
            Print("Order failed with error - ",GetLastError());
            Alert("Order failed with error - "+IntegerToString(GetLastError()));
        }
    }
    // Add Spread Feature
    else if (gContextMenu.mActiveItemStr == CTX_SPREAD)
    {
        onItemDrag(itemId, objId);
        double spread = (double)SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
        mStlSpace = (double)Trd_StlSpace / pow(10, gSymbolDigits);
        spread = spread / pow(10, gSymbolDigits);

        if (priceEN > priceSL) {
            // Buy order
            priceEN += spread;
            priceSL -= mStlSpace;
        } else {
            // Sell order
            priceTP += spread;
            priceSL += spread+mStlSpace;
        }
        refreshData();
    }
    // Add TP/SL if they don't have
    else if (gContextMenu.mActiveItemStr == CTX_ADDSLTP)
    {
        string sparamItems[];
        int k=StringSplit(itemId,'#',sparamItems);
        if (k == 2){
            if(OrderModify(OrderTicket(),OrderOpenPrice(),priceSL,priceTP,0) == true){
                Print("OrderModify successfully.");
            }
            else
                Print("Error in OrderModify. Error code=",GetLastError());
        }
    }
    else if (gContextMenu.mActiveItemStr == CTX_AUTOBE)
    {
        ObjectSetText(cPointBE, "be");
        refreshData();
    }
    gContextMenu.clearContextMenu();
}

void Trade::createTrade(int id, datetime _time1, datetime _time2, double _priceEN, double _priceSL, double _priceTP, double _priceBE)
{
    string itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + IntegerToString(id);
    activateItem(itemId);
    createItem();
    time1 = _time1;
    time2 = _time2;
    priceTP = _priceTP;
    priceEN = _priceEN;
    priceSL = _priceSL;
    priceBE = _priceBE;
    refreshData();
}

void Trade::scanLiveTrade()
{
    if (Trd_ShowPrice == HIDE) return;

    // First scanning
    if (mListLiveTradeStr == ""){
        int openedTrade = 0;
        int tradePos    = -1;
        for( int i = 0 ; i < OrdersTotal() ; i++ ) { 
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES ) == false) continue;
            if (OrderSymbol() != Symbol()) continue;
            mListLiveTradeStr += IntegerToString(OrderTicket()) + ",";
        }
        return;
    }

    // Manage Trade
    int k=StringSplit(mListLiveTradeStr,',',mListLiveTradeArr);
    mListLiveTradeStr = "";
    bool isBuy = false;
    bool isBeManage = false;
    int orderType = 0;
    string itemId = "";
    for (int i = 0; i < k-1; i++){
        itemId = mItemName + "_" +IntegerToString(ChartPeriod()) + "#" + mListLiveTradeArr[i];
        activateItem(itemId);
        // 1. Check lệnh đã cancel chưa?
        if (OrderSelect(StrToInteger(mListLiveTradeArr[i]), SELECT_BY_TICKET, MODE_TRADES) == false) {
            ObjectSetText(cPointWD, "");
            ObjectSetText(iEnText,"");
            continue;
        }
        // 2. Lệnh đã đóng chưa?
        if (OrderCloseTime() != 0){
            ObjectSetText(cPointWD, "");
            ObjectSetText(iEnText,"");
            continue;
        }
        // 3. Lệnh đang mở cần được control
        /// A. Load data
        priceTP = OrderTakeProfit();
        priceEN = OrderOpenPrice();
        priceSL = OrderStopLoss();
        orderType = OrderType();
        // Lệnh chưa set SL
        if (priceSL == 0) {
            priceSL = NormalizeDouble(priceEN - mNativeCost / OrderLots() / 100000, 5);
        }
        isBuy = (orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP);
        // Lệnh đã đặt BE hoặc SL dương
        if ((isBuy ? 1 : -1) * (priceSL - priceEN) >= 0) {
            isBeManage = true;
            priceSL = NormalizeDouble(priceEN + mNativeCost / OrderLots() / 100000, 5);
        }
        // Lệnh chưa set TP
        if (priceTP <= 0.0){
            priceTP = 4*priceEN - 3*priceSL;
        }

        /// B. Kiểm tra Trade đã có trên đồ thị chưa
        // Trade chưa tồn tại trên đồ thị -> Tạo mới
        if (ObjectFind(ChartID(), cPointWD) != 0) {
            time1 = OrderOpenTime();
            time2 = time1 + ChartPeriod()*1800;
            priceBE = 2*priceEN - priceSL;
            createTrade(OrderTicket(), time1, time2, priceEN, priceSL, priceTP, priceBE);
        }
        // Trade đã tồn tại trên đồ thị
        else {
            time1 = (datetime)ObjectGet(cBoder  , OBJPROP_TIME1);
            time2 = (datetime)ObjectGet(cPointWD, OBJPROP_TIME1);
            priceBE = ObjectGet(cPointBE, OBJPROP_PRICE1);
        }

        /// C. Chức năng Check Auto BE/Out
        if (isBeManage == false && ObjectDescription(cPointBE) == "be") {
            // Lệnh đã vào
            if ((orderType == OP_BUY && Bid >= priceBE) || (orderType == OP_SELL && Bid <= priceBE)) {
                if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0) == true){
                    Print("OrderModify successfully.");
                    ObjectSetText(cPointBE, "");
                }
                else
                    Print("Error in OrderModify. Error code=",GetLastError());
            }
            // Lệnh chưa vào
            else if ((orderType == OP_BUYLIMIT && Bid >= priceBE) || (orderType == OP_SELLLIMIT && Bid <= priceBE)) {
                if(OrderDelete(OrderTicket()) == true){
                    Print("OrderDelete successfully.");
                    ObjectSetText(cPointBE, "");
                }
                else
                    Print("Error in OrderDelete. Error code=",GetLastError());
            }
        }

        /// D. Reload & Others
        ObjectSetText(cPointWD, LIVE_INDI);
        refreshData();
        // Add remain Item
        mListLiveTradeStr += mListLiveTradeArr[i] + ",";
    }
}
