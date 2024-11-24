#property copyright "Timmy Ham Hoc"
#property link      "https://www.youtube.com/@TimmyTraderHamHoc"
#property version   "1.00"
#property strict

#define TAG_STATIC  "*"
#define TAG_TRADEID ".TMTrade_1#"
#define TAG_CTRM    "_cz"
#define TAG_CTRL    "_c"
#define TAG_INFO    "_I"

double gCost = 1.5; // Cost ($)
double gComm = 7;   // Comission ($)
double gdLotSize = MarketInfo(Symbol(), MODE_LOTSIZE);

class TradeWorker
{
private:
    // COMPONENT TAG //
    string tag_cPtWD;
    string tag_cPtTP;
    string tag_cPtEN;
    string tag_cPtSL;
    string tag_cPtBE;
    string tag_cBgSl;
    string tag_iBgTP;
    string tag_iLnTp;
    string tag_iLnEn;
    string tag_iLnSl;
    string tag_iLnBe;
    string tag_iTxT2;
    string tag_iTxE2;
    string tag_iTxS2;
    string tag_iTxtT;
    string tag_iTxtE;
    string tag_iTxtS;
    string tag_iTxtB;

public:
    TradeWorker();
    ~TradeWorker();
    void reqGoLive();
    void reqManageTrade();
    void reqAddSLTP();

private:
};

TradeWorker::TradeWorker()
{
    tag_cPtWD = TAG_CTRM + "cPtWD";
    tag_cPtTP = TAG_CTRL + "cPtTP";
    tag_cPtEN = TAG_CTRL + "cPtEN";
    tag_cPtSL = TAG_CTRL + "cPtSL";
    tag_cPtBE = TAG_CTRL + "cPtBE";
    tag_cBgSl = TAG_CTRL + "cBgSl";
    tag_iBgTP = TAG_INFO + "iBgTP";
    tag_iLnTp = TAG_INFO + "iLnTp";
    tag_iLnEn = TAG_INFO + "iLnEn";
    tag_iLnSl = TAG_INFO + "iLnSl";
    tag_iLnBe = TAG_INFO + "iLnBe";
    tag_iTxT2 = TAG_INFO + "iTxT2";
    tag_iTxE2 = TAG_INFO + "iTxE2";
    tag_iTxS2 = TAG_INFO + "iTxS2";
    tag_iTxtT = TAG_INFO + "iTxtT";
    tag_iTxtE = TAG_INFO + "iTxtE";
    tag_iTxtS = TAG_INFO + "iTxtS";
    tag_iTxtB = TAG_INFO + "iTxtB";
}

TradeWorker::~TradeWorker(){}

void TradeWorker::reqGoLive()
{
    //0. Get gCost/ gComm
    gCost = StrToDouble(ObjectDescription(TAG_STATIC + "Cost"));
    gComm = StrToDouble(ObjectDescription(TAG_STATIC + "Comm"));
    if (gCost <= 0) return;
    //1. Scan selected tradeObj and Get Data
    bool bDataReady = false;
    string objName;
    double priceTP = 0;
    double priceEN = 0;
    double priceSL = 0;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (StringFind(objName, tag_cPtWD) == -1) continue;
        StringReplace(objName, tag_cPtWD, "");
        priceTP = ObjectGet(objName + tag_cPtTP, OBJPROP_PRICE1);
        priceEN = ObjectGet(objName + tag_cPtEN, OBJPROP_PRICE1);
        priceSL = ObjectGet(objName + tag_cPtSL, OBJPROP_PRICE1);
        bDataReady = true;
        break;
    }
    //2. Go Live for it
    if (bDataReady == false) return;
    double point        = floor(fabs(priceEN-priceSL) * gdLotSize);
    double tradeSize    = NormalizeDouble(floor(gCost / (point+gComm) * 100)/100, 2);
    priceTP = NormalizeDouble(priceTP, Digits);
    priceEN = NormalizeDouble(priceEN, Digits);
    priceSL = NormalizeDouble(priceSL, Digits);

    int Cmd = ((priceTP > priceEN) ? OP_BUYLIMIT : OP_SELLLIMIT);

    int Slippage = 200;
    int OrderNumber=OrderSend(Symbol(),Cmd,tradeSize,priceEN,Slippage,priceSL,priceTP);
    if (OrderNumber <= 0) {
        Print("Order failed with error - ",GetLastError());
        Alert("Order failed with error - "+IntegerToString(GetLastError()));
        return;
    }
    Print("Order ",OrderNumber," open");
        
    //3. Delete tradeObj
    ObjectDelete(objName + tag_cPtWD);
}

void TradeWorker::reqManageTrade()
{
    //1. Scan listTradeObjId
    string objId = "";
    for (int i = 0 ; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS) == false) continue;
        if (OrderSymbol() != Symbol()) continue;
        objId = TAG_TRADEID + IntegerToString(OrderTicket());
        if (ObjectFind(objId + tag_cPtWD) < 0) {
            Print("Không tìm thấy TradeObj:", IntegerToString(OrderTicket()));
            continue;
        }
        //2. Is Bid Reached BE Line
        double priceBE = NormalizeDouble(ObjectGet(objId + tag_cPtBE, OBJPROP_PRICE1), Digits);
        double priceTP = NormalizeDouble(ObjectGet(objId + tag_cPtTP, OBJPROP_PRICE1), Digits);
        double priceEN = NormalizeDouble(ObjectGet(objId + tag_cPtEN, OBJPROP_PRICE1), Digits);
        bool isBUY = priceTP > priceEN;
        if ((isBUY && Bid >= priceBE) || (isBUY == false && Bid <= priceBE)) {
            //3. If BE_tag is on
            if (ObjectDescription(objId + tag_cPtBE) == "be"){
                int orderType = OrderType();
                //3.1. Is Pending trade -> Cancel Trade
                if (orderType == OP_BUYLIMIT || orderType == OP_SELLLIMIT){
                    if(OrderDelete(OrderTicket()) == true){
                        Print("OrderDelete successfully.");
                        ObjectSetText(objId + tag_cPtBE, "");
                        ObjectSetText(objId + tag_cPtWD, "");
                        ObjectSetText(objId + tag_iTxtB, "x");
                        ObjectSetText(objId + tag_iTxtE, "Canceled");
                    }
                    else
                        Print("Error in OrderDelete. Error code=",GetLastError());
                }
                //3.2. If Running trade -> Move Breakevent
                else if (orderType == OP_BUY || orderType == OP_SELL) {
                    // Tinh toan commission
                    priceEN = priceEN + (isBUY ? +1 : -1) * fabs(OrderCommission())/OrderLots() / gdLotSize;
                    if(OrderModify(OrderTicket(),OrderOpenPrice(),priceEN,OrderTakeProfit(),0) == true){
                        Print("OrderModify successfully.");
                        ObjectSetText(objId + tag_cPtBE, "");
                        ObjectSetText(objId + tag_iTxtB, "");
                    }
                    else
                        Print("Error in OrderModify. Error code=",GetLastError());
                }
            }
            //3. If PA_tag is on
            else if (ObjectDescription(objId + tag_cPtBE) == "pa"){
                Print("TODO");
            }
        }
    }
}

void TradeWorker::reqAddSLTP()
{
    //1. Scan selected tradeObj and Get Data
    bool bDataReady = false;
    string objName;
    double priceTP = 0;
    double priceEN = 0;
    double priceSL = 0;
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--) {
        objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (StringFind(objName, tag_cPtEN) == -1) continue;
        if (StringFind(objName, tag_cPtEN) == -1) continue;
        if (ObjectGet(objName, OBJPROP_ARROWCODE) == 2) continue;        

        StringReplace(objName, tag_cPtEN, "");
        priceTP = NormalizeDouble(ObjectGet(objName + tag_cPtTP, OBJPROP_PRICE1), Digits);
        priceEN = NormalizeDouble(ObjectGet(objName + tag_cPtEN, OBJPROP_PRICE1), Digits);
        priceSL = NormalizeDouble(ObjectGet(objName + tag_cPtSL, OBJPROP_PRICE1), Digits);
        bDataReady = true;
        break;
    }
    //2. Add SL/TP
    if (bDataReady == false) return;

    string sparamItems[];
    int k=StringSplit(objName,'#',sparamItems);
    if (k == 2){
        int orderTicket = StrToInteger(sparamItems[1]);
        if (OrderSelect(orderTicket, SELECT_BY_TICKET) != true) return;
        if (OrderTakeProfit() > 0 && OrderStopLoss() > 0) return;
        if(OrderModify(orderTicket,OrderOpenPrice(),priceSL,priceTP,0) == true){
            Print("OrderModify successfully.");
        }
        else
            Print("Error in OrderModify. Error code=",GetLastError());
    }
}