#include "../Base/BaseItem.mqh"

#define LONG_IDX 0

#define CTX_SPREAD      "Spread"
#define CTX_GOLIVE      "Go Live"
#define CTX_ADDSLTP     "Sl/TP"
#define CTX_AUTOBE      "Auto BE"

#define LIVE_INDI       "ʟɪᴠᴇ"

enum e_display
{
    HIDE,   // Hide
    SHOW,   // Always
    OPTION, // When Select
};

input string          Trd_; // ●  T R A D E  ●
//-------------------------------------------------
input double          Trd_Cost          = 0;       //Cost ($)
input e_display       Trd_ShowStats     = OPTION;  //Show Stats
input e_display       Trd_ShowDollar    = HIDE;    //Show Dollar
//-------------------------------------------------
input string          Trd_apperence; //→ Color:
      color           Trd_TextColor     = clrMidnightBlue;   // Text
      int             Trd_TextSize      = 8;                 // Text Size
input color           Trd_TpColor       = clrSteelBlue;      // TP Line
input color           Trd_SlColor       = clrChocolate;      // SL Line
input color           Trd_EnColor       = clrChocolate;      // EN Line
      int             Trd_LineWidth     = 1;                 // Line Width
input color           Trd_SlBkgrdColor  = clrLavenderBlush;  // SlBg
input color           Trd_TpBkgrdColor  = clrWhiteSmoke;     // TpBg

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
    string cPtWD ;
    string cPtSL ;
    string cPtEN ;
    string cPtBE ;
    string cPtTP ;
    string cBgSl ;

    string iBgTP ;
    string iLnTp ;
    string iLnEn ;
    string iLnSl ;
    string iLnBe ;
    string iTxT2 ;
    string iTxE2 ;
    string iTxS2 ;
    string iTxtT ;
    string iTxtE ;
    string iTxtS ;
    string iTxtB ;

// Value define for Item
private:
    datetime time1;
    datetime time2;
    double priceTP;
    double priceEN;
    double priceSL;
    double priceBE;

public:
    Trade(CommonData* commonData, MouseInfo* mouseInfo);

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
    void restoreBacktestingTrade();

// Alpha feature
    void initData();

public:
    static string getAllItem(string itemId);
    static string Tag;
};

static string Trade::Tag = ".TMTrade";

Trade::Trade(CommonData* commonData, MouseInfo* mouseInfo)
{
    mItemName = Trade::Tag;
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
    ObjectCreate(iBgTP , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(iLnTp , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnBe , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnEn , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iLnSl , OBJ_TREND     , 0, 0, 0);
    ObjectCreate(iTxT2 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxE2 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxS2 , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtT , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtE , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtS , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(iTxtB , OBJ_TEXT      , 0, 0, 0);
    ObjectCreate(cBgSl , OBJ_RECTANGLE , 0, 0, 0);
    ObjectCreate(cPtTP , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtSL , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtEN , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtWD , OBJ_ARROW     , 0, 0, 0);
    ObjectCreate(cPtBE , OBJ_ARROW     , 0, 0, 0);

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
    ObjectSet(cBgSl, OBJPROP_BACK, true);
    ObjectSet(iBgTP, OBJPROP_BACK, true);
    //-------------------------------------------------
    setMultiProp(OBJPROP_ARROWCODE , 4    , cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    
    setMultiProp(OBJPROP_SELECTED  , true , cBgSl+cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    setMultiProp(OBJPROP_RAY       , false, iLnTp+iLnBe+iLnEn+iLnSl);
    setMultiProp(OBJPROP_SELECTABLE, false, iBgTP+iLnTp+iLnBe+iLnEn+iLnSl+iTxT2+iTxE2+iTxS2+iTxtT+iTxtE+iTxtS+iTxtB);

    setMultiProp(OBJPROP_COLOR, gColorMousePoint, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
    //-------------------------------------------------
    setMultiStrs(OBJPROP_TOOLTIP, "\n", mAllItem);
}
void Trade::updateTypeProperty()
{
    ObjectSet(cBgSl, OBJPROP_COLOR, Trd_SlBkgrdColor);
    ObjectSet(iBgTP, OBJPROP_COLOR, Trd_TpBkgrdColor);
    ObjectSet(iLnBe, OBJPROP_WIDTH, 1);
    ObjectSet(iLnBe, OBJPROP_STYLE, 2);
    //-------------------------------------------------
    setMultiProp(OBJPROP_COLOR, Trd_TpColor  , iLnTp+iLnBe);
    setMultiProp(OBJPROP_COLOR, Trd_EnColor  , iLnEn);
    setMultiProp(OBJPROP_COLOR, Trd_SlColor  , iLnSl);
    setMultiProp(OBJPROP_COLOR, Trd_TextColor, iTxtT+iTxtE+iTxtS+iTxtB+iTxT2+iTxE2+iTxS2);
    //-------------------------------------------------
    setMultiProp(OBJPROP_WIDTH   , Trd_LineWidth, iLnTp+iLnEn+iLnSl);
    setMultiProp(OBJPROP_FONTSIZE, Trd_TextSize , iTxT2+iTxE2+iTxS2+iTxtT+iTxtE+iTxtS+iTxtB+iTxT2+iTxE2+iTxS2);
}
void Trade::activateItem(const string& itemId)
{
    cPtWD = itemId + TAG_CTRM + "cPtWD";
    cPtSL = itemId + TAG_CTRL + "cPtSL";
    cPtEN = itemId + TAG_CTRL + "cPtEN";
    cPtBE = itemId + TAG_CTRL + "cPtBE";
    cPtTP = itemId + TAG_CTRL + "cPtTP";
    cBgSl = itemId + TAG_CTRL + "cBgSl";
    iBgTP = itemId + TAG_INFO + "iBgTP";
    iLnTp = itemId + TAG_INFO + "iLnTp";
    iLnEn = itemId + TAG_INFO + "iLnEn";
    iLnSl = itemId + TAG_INFO + "iLnSl";
    iLnBe = itemId + TAG_INFO + "iLnBe";
    iTxT2 = itemId + TAG_INFO + "iTxT2";
    iTxE2 = itemId + TAG_INFO + "iTxE2";
    iTxS2 = itemId + TAG_INFO + "iTxS2";
    iTxtT = itemId + TAG_INFO + "iTxtT";
    iTxtE = itemId + TAG_INFO + "iTxtE";
    iTxtS = itemId + TAG_INFO + "iTxtS";
    iTxtB = itemId + TAG_INFO + "iTxtB";

    mAllItem += iBgTP+iLnTp+iLnEn+iLnSl+iLnBe+iTxT2+iTxE2+iTxS2+iTxtT+iTxtE+iTxtS+iTxtB;
    mAllItem += cPtTP+cPtSL+cPtEN+cPtWD+cPtBE+cBgSl;
}

string Trade::getAllItem(string itemId)
{
    string allItem = itemId + "_mTData";
    allItem += itemId + TAG_INFO + "iBgTP";
    allItem += itemId + TAG_INFO + "iLnTp";
    allItem += itemId + TAG_INFO + "iLnEn";
    allItem += itemId + TAG_INFO + "iLnSl";
    allItem += itemId + TAG_INFO + "iLnBe";
    allItem += itemId + TAG_INFO + "iTxT2";
    allItem += itemId + TAG_INFO + "iTxE2";
    allItem += itemId + TAG_INFO + "iTxS2";
    allItem += itemId + TAG_INFO + "iTxtT";
    allItem += itemId + TAG_INFO + "iTxtE";
    allItem += itemId + TAG_INFO + "iTxtS";
    allItem += itemId + TAG_INFO + "iTxtB";
    //--- Control item ---
    allItem += itemId + TAG_CTRL + "cBgSl";
    allItem += itemId + TAG_CTRM + "cPtWD";
    allItem += itemId + TAG_CTRL + "cPtSL";
    allItem += itemId + TAG_CTRL + "cPtEN";
    allItem += itemId + TAG_CTRL + "cPtBE";
    allItem += itemId + TAG_CTRL + "cPtTP";

    return allItem;
}

void Trade::updateItemAfterChangeType(){}
void Trade::refreshData()
{
    datetime centerTime = getCenterTime(time1, time2);
    
    setItemPos(cBgSl  , time1, time2, priceEN, priceSL);
    setItemPos(iBgTP  , time1, time2, priceEN, priceTP);
    setItemPos(iLnTp  , time1, time2, priceTP, priceTP);
    setItemPos(iLnEn  , time1, time2, priceEN, priceEN);
    setItemPos(iLnSl  , time1, time2, priceSL, priceSL);
    setItemPos(iLnBe  , time1, time2, priceBE, priceBE);
    //-------------------------------------------------
    setItemPos(cPtTP , time2, priceTP);
    setItemPos(cPtSL , time2, priceSL);
    setItemPos(cPtEN , time1, priceEN);
    setItemPos(cPtWD , time2, priceEN);
    setItemPos(cPtBE , time2, priceBE);
    //-------------------------------------------------
    setItemPos(iTxtT  , centerTime, priceTP);
    setItemPos(iTxtE  , centerTime, priceEN);
    setItemPos(iTxtS  , centerTime, priceSL);
    setItemPos(iTxtB  , time2, priceBE);

    setTextPos(iTxT2, centerTime, priceTP);
    setTextPos(iTxE2, centerTime, priceEN);
    setTextPos(iTxS2, centerTime, priceSL);
    //-------------------------------------------------
    ObjectSetInteger(0, iTxtE, OBJPROP_ANCHOR, ANCHOR_LOWER);
    if (priceTP > priceSL) {
        ObjectSetInteger(0,iTxtS, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iTxtT, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0,iTxtB, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
        ObjectSetInteger(0,iTxT2, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iTxE2, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iTxS2, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    else {
        ObjectSetInteger(0,iTxtS, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0,iTxtT, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iTxtB, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
        ObjectSetInteger(0,iTxT2, OBJPROP_ANCHOR, ANCHOR_LOWER);
        ObjectSetInteger(0,iTxE2, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(0,iTxS2, OBJPROP_ANCHOR, ANCHOR_UPPER);
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
    double tpPip       = slPip * rr;
    double realCost    = 0;
    // 2. Thông tin hiển thị
    bool   selectState = (bool)ObjectGet(cPtWD, OBJPROP_SELECTED);
    bool   showStats   = (Trd_ShowStats  == SHOW) || (Trd_ShowStats  == OPTION && selectState);
    bool   showDollar  = (Trd_Cost != 0) && ((Trd_ShowDollar == SHOW) || (Trd_ShowDollar == OPTION && selectState));
    
    // 3. String Data để hiển thị
    string strTpInfo   = ""; // pip + dola
    string strSlInfo   = ""; // pip + dola
    string strEnInfo   = ObjectDescription(cPtWD); // Cmt + lot 
    string strBeInfo   = ObjectDescription(cPtBE); // BE RR + pip
    
    if (strBeInfo != ""){
        strBeInfo += ": ";
        if (!showStats){
            strBeInfo += DoubleToString(be,1) + "  ";
        }
    }
    if (showStats) {
        double bePip = be * slPip;
        strTpInfo += DoubleToString(tpPip, 1) + "ᴘ";
        strBeInfo += DoubleToString(be,1) + " ~ " + DoubleToString(bePip, 1) + "ᴘ ";
        strSlInfo += DoubleToString(slPip, 1) + "ᴘ";
    }
    //-------------------------------------------------
    if (showDollar) {
        realCost = mTradeLot*slPip*10/mNativeCost*Trd_Cost;
        if (showStats) {
            strTpInfo += " ~ ";
            strSlInfo += " ~ ";
        }
        strTpInfo += DoubleToString(rr*realCost, 2) + "$";
        strSlInfo += DoubleToString(realCost, 2) + "$";
        if (strEnInfo != "") strEnInfo += " ";
        strEnInfo += DoubleToString(mTradeLot,2) + "lot";
    }
    string strRRInfo = "";
    string strRR = DoubleToString(rr,1);
    for (int i = 0; i < StringLen(strRR); i++) {
        strRRInfo += StringSubstr(strRR, i, 1);
        strRRInfo += " ";
    }
    strRRInfo += "ʀ";
    //-------------------------------------------------
    ObjectSetText(iTxT2, strTpInfo);
    ObjectSetText(iTxE2, EMPTY_STR);
    ObjectSetText(iTxS2, EMPTY_STR);
    //-------------------------------------------------
    ObjectSetText(iTxtT, strRRInfo);
    ObjectSetText(iTxtE, strEnInfo);
    ObjectSetText(iTxtS, strSlInfo);
    ObjectSetText(iTxtB, strBeInfo);
    int selected = (int)ObjectGet(cPtWD, OBJPROP_SELECTED);
    setMultiProp(OBJPROP_COLOR, selected ? gColorMousePoint : clrNONE, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);

}
void Trade::finishedJobDone()
{
    mFirstPoint = true;
}

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
    priceTP =           ObjectGet(cPtTP, OBJPROP_PRICE1);
    priceEN =           ObjectGet(cPtEN, OBJPROP_PRICE1);
    priceSL =           ObjectGet(cPtSL, OBJPROP_PRICE1);
    priceBE =           ObjectGet(cPtBE, OBJPROP_PRICE1);
    time1   = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
    time2   = (datetime)ObjectGet(cPtWD, OBJPROP_TIME1);
    if (objId == cBgSl)
    {
        datetime newtime1 = (datetime)ObjectGet(cBgSl, OBJPROP_TIME1);
        datetime newtime2 = (datetime)ObjectGet(cBgSl, OBJPROP_TIME2);
        datetime timeCenter;
        double newSlPrice;
        getCenterPos(newtime1, newtime2, priceTP, priceTP, timeCenter, newSlPrice);
        if (timeCenter == pCommonData.mMouseTime) {
            priceEN     = ObjectGet(cBgSl, OBJPROP_PRICE1);
            newSlPrice  = ObjectGet(cBgSl, OBJPROP_PRICE2);
            priceBE += (newSlPrice-priceSL);
            priceTP += (newSlPrice-priceSL);
            priceSL = newSlPrice;
            time1 = newtime1;
            time2 = newtime2;
        }
        else {
            // move edge -> ignore
        }
    }
    else
    {
        if (pCommonData.mCtrlHold == true)
        {
            if      (objId == cPtTP) priceTP = pCommonData.mMousePrice;
            else if (objId == cPtEN) priceEN = pCommonData.mMousePrice;
            else if (objId == cPtSL) priceSL = pCommonData.mMousePrice;
            else if (objId == cPtBE) priceBE = pCommonData.mMousePrice;
        }
        if (objId == cPtEN && pCommonData.mShiftHold == true){
            priceEN =           ObjectGet(cPtWD, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
        }
    }
    refreshData();
}
void Trade::onItemClick(const string &itemId, const string &objId)
{
    if (StringFind(objId, TAG_CTRL) < 0) return;
    int selected = (int)ObjectGet(objId, OBJPROP_SELECTED);
    if (selected && objId == cPtWD && pCommonData.mShiftHold && Trd_Cost != 0)
    {
        // onItemDrag(itemId, objId); //=> update lastest data
        if (ObjectDescription(cPtWD) == LIVE_INDI){
            gContextMenu.openContextMenu(objId, mLiveTradeCtx, -1);
        }
        else{
            gContextMenu.openContextMenu(objId, mContextType, -1);
        }   
    }
    setCtrlItemSelectState(mAllItem, selected);
    setMultiProp(OBJPROP_COLOR, selected ? gColorMousePoint : clrNONE, cPtTP+cPtSL+cPtEN+cPtWD+cPtBE);
}
void Trade::onItemChange(const string &itemId, const string &objId)
{
    onItemDrag(itemId, objId);
}

//-------------------------------------------------------------------
void Trade::showHistory(bool isShow)
{
    string sparamItems[];
    int k;
    string objId;
    for (int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string objName = ObjectName(i);
        if (StringFind(objName, TAG_CTRM) == -1) continue;
        k=StringSplit(objName,'_',sparamItems);
        if (k != 3 || sparamItems[0] != mItemName)
        {
            continue;
        }
        objId = sparamItems[0] + "_" + sparamItems[1];
        activateItem(objId);
        if (isShow)
        {
            priceTP =           ObjectGet(cPtTP, OBJPROP_PRICE1);
            priceEN =           ObjectGet(cPtEN, OBJPROP_PRICE1);
            priceSL =           ObjectGet(cPtSL, OBJPROP_PRICE1);
            priceBE =           ObjectGet(cPtBE, OBJPROP_PRICE1);
            time1   = (datetime)ObjectGet(cBgSl, OBJPROP_TIME1);
            time2   = (datetime)ObjectGet(cBgSl, OBJPROP_TIME2);
            refreshData();
            continue;
        }
        
        if ((bool)ObjectGet(cPtWD, OBJPROP_SELECTED)) continue;
        if (ObjectDescription(cPtWD) != "") continue; // Don't hide live trade
        // Hide Item
        ObjectSet(cBgSl, OBJPROP_PRICE1, 0);
        ObjectSet(iBgTP, OBJPROP_PRICE1, 0);
        ObjectSet(iLnTp, OBJPROP_PRICE1, 0);
        ObjectSet(iLnBe, OBJPROP_PRICE1, 0);
        ObjectSet(iLnEn, OBJPROP_PRICE1, 0);
        ObjectSet(iLnSl, OBJPROP_PRICE1, 0);
        ObjectSet(cBgSl, OBJPROP_PRICE2, 0);
        ObjectSet(iBgTP, OBJPROP_PRICE2, 0);
        ObjectSet(iLnTp, OBJPROP_PRICE2, 0);
        ObjectSet(iLnBe, OBJPROP_PRICE2, 0);
        ObjectSet(iLnEn, OBJPROP_PRICE2, 0);
        ObjectSet(iLnSl, OBJPROP_PRICE2, 0);

        ObjectSet(iTxT2, OBJPROP_TIME1, 0);
        ObjectSet(iTxE2, OBJPROP_TIME1, 0);
        ObjectSet(iTxS2, OBJPROP_TIME1, 0);
        ObjectSet(iTxtT, OBJPROP_TIME1, 0);
        ObjectSet(iTxtE, OBJPROP_TIME1, 0);
        ObjectSet(iTxtS, OBJPROP_TIME1, 0);
        ObjectSet(iTxtB, OBJPROP_TIME1, 0);
        ObjectSet(cPtTP, OBJPROP_TIME1, 0);
        ObjectSet(cPtSL, OBJPROP_TIME1, 0);
        ObjectSet(cPtEN, OBJPROP_TIME1, 0);
        ObjectSet(cPtWD, OBJPROP_TIME1, 0);
        ObjectSet(cPtBE, OBJPROP_TIME1, 0);
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
            priceBE = ObjectGet(cPtBE, OBJPROP_PRICE1);
            time1 = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
            time2 = (datetime)ObjectGet(cPtWD, OBJPROP_TIME1);
            // Xoá trade item
            ObjectDelete(cPtWD);
            // Tạo trade mới theo Order number
            createTrade(OrderNumber, time1, time2, priceEN, priceSL, priceTP, priceBE);
            ObjectSetText(cPtWD, LIVE_INDI);
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
        ObjectSetText(cPtBE, "be");
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
    if (Trd_Cost == 0) return;

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
    if (mFirstPoint == false) return; // User are trying to draw new trade
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
            ObjectSetText(cPtWD, "");
            ObjectSetText(iTxtE,"");
            continue;
        }
        // 2. Lệnh đã đóng chưa?
        if (OrderCloseTime() != 0){
            ObjectSetText(cPtWD, "");
            ObjectSetText(iTxtE,"");
            continue;
        }
        // 3. Lệnh đang mở cần được control
        /// A. Load data
        priceTP = OrderTakeProfit();
        priceEN = OrderOpenPrice();
        priceSL = OrderStopLoss();
        orderType = OrderType();
        isBuy = (orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP);
        // Lệnh chưa set SL
        if (priceSL == 0.0) {
            priceSL = NormalizeDouble(priceEN - (isBuy ? 1 : -1) * mNativeCost / OrderLots() / 100000, 5);
        } 
        // Lệnh đã đặt BE hoặc SL dương
        else if ((isBuy ? 1 : -1) * (priceSL - priceEN) >= 0) {
            isBeManage = true;
            priceSL = NormalizeDouble(priceEN - (isBuy ? 1 : -1) * mNativeCost / OrderLots() / 100000, 5);
        }
        // Lệnh chưa set TP
        if (priceTP <= 0.0){
            priceTP = 4*priceEN - 3*priceSL; // Set TP = 3R
        }

        /// B. Kiểm tra Trade đã có trên đồ thị chưa
        // Trade chưa tồn tại trên đồ thị -> Tạo mới
        if (ObjectFind(ChartID(), cPtWD) != 0) {
            time1 = OrderOpenTime();
            time2 = time1 + ChartPeriod()*1800;
            priceBE = 2*priceEN - priceSL;
            createTrade(OrderTicket(), time1, time2, priceEN, priceSL, priceTP, priceBE);
        }
        // Trade đã tồn tại trên đồ thị
        else {
            time1 = (datetime)ObjectGet(cPtEN, OBJPROP_TIME1);
            time2 = (datetime)ObjectGet(cPtWD, OBJPROP_TIME1);
            priceBE = ObjectGet(cPtBE, OBJPROP_PRICE1);
        }

        /// C. Chức năng Check Auto BE/Out
        if (isBeManage == false && ObjectDescription(cPtBE) == "be") {
            // Lệnh đã vào
            if ((orderType == OP_BUY && Bid >= priceBE) || (orderType == OP_SELL && Bid <= priceBE)) {
                if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0) == true){
                    Print("OrderModify successfully.");
                    ObjectSetText(cPtBE, "");
                }
                else
                    Print("Error in OrderModify. Error code=",GetLastError());
            }
            // Lệnh chưa vào
            else if ((orderType == OP_BUYLIMIT && Bid >= priceBE) || (orderType == OP_SELLLIMIT && Bid <= priceBE)) {
                if(OrderDelete(OrderTicket()) == true){
                    Print("OrderDelete successfully.");
                    ObjectSetText(cPtBE, "");
                }
                else
                    Print("Error in OrderDelete. Error code=",GetLastError());
            }
        }

        /// D. Reload & Others
        ObjectSetText(cPtWD, LIVE_INDI);
        refreshData();
        // Add remain Item
        mListLiveTradeStr += mListLiveTradeArr[i] + ",";
    }
}

void Trade::restoreBacktestingTrade()
{
    long chartID = ChartID();
    string objEn = "";
    string enData = "";

    string sparamItems[];
    double size;
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
        time2   = time1 + ChartPeriod()*600; // = time1 + 10 candle = time1 + 10 * 60* period
        // Step 3: Create Trade
        createTrade(idx, time1, time2, priceEN, priceSL, priceTP, priceBE);
    }
}
