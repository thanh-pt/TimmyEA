#include "../Base/BaseItem.mqh"
#include "../Tools/Trade.mqh"
#include "../Tools/Alert.mqh"
#include "../Tools/Trend.mqh"
#include "../Tools/Rectangle.mqh"
#include "../Tools/ZigZag.mqh"
#include "../Tools/CallOut.mqh"
#include "../Tools/Fibonacci.mqh"
#include "../Tools/Points.mqh"
#include "../Tools/Label.mqh"
#include "../InfoItem/MouseInfo.mqh"

#define CHECK_NOT_ACTIVE_RETURN if(mActive == IDX_NONE){return;}
#define CHECK_ACTIVE_RETURN if(mActive != IDX_NONE){return;}

#define IDX_NONE        -1
#define IDX_TREND       0
#define IDX_ZIGZAG      1
#define IDX_RECTANGLE   2
#define IDX_FIBONACI    3
#define IDX_CALLOUT     4
#define IDX_TRADE       5
#define IDX_ALERT       6
#define IDX_POINT       7
#define IDX_LABEL       8

#define ITEM_TREND      ".Trend"
#define ITEM_ZIGZAG     ".ZigZag"
#define ITEM_RECTANGLE  ".Rectangle"
#define ITEM_FIBONACI   ".Fibonacci"
#define ITEM_CALLOUT    ".CallOut"
#define ITEM_TRADE      ".Trade"
#define ITEM_ALERT      ".Alert"
#define ITEM_POINT      ".Point"
#define ITEM_LABEL      ".Label"

class Controller
{
private:
    BaseItem*   mListItem[10];
    int         mActive;
    FinishedJob mFinishedJobCb;
    MouseInfo*  pMouseInfo;
    bool        mbActiveErase;

private:
    int findItemIdByKey(const int key);
    int findItemIdByName(const string& name);

public:
    Controller(CommonData* commonData, MouseInfo* mouseInfo);
    ~Controller();

public:
    void handleKeyEvent(const long &key);
    void handleIdEventOnly(const int id);
    void handleSparamEvent(const int id, const string& sparam);
    void handleOntick();
    void setFinishedJobCB(FinishedJob cb);
    void finishedJob();
};

void Controller::Controller(CommonData* commonData, MouseInfo* mouseInfo)
{
    pMouseInfo = mouseInfo;
    mActive = IDX_NONE;
    mListItem[IDX_TREND     ]    = new Trend     ( ITEM_TREND     , commonData, mouseInfo);
    mListItem[IDX_ZIGZAG    ]    = new ZigZag    ( ITEM_ZIGZAG    , commonData, mouseInfo);
    mListItem[IDX_RECTANGLE ]    = new Rectangle ( ITEM_RECTANGLE , commonData, mouseInfo);
    mListItem[IDX_FIBONACI  ]    = new Fibonacci ( ITEM_FIBONACI  , commonData, mouseInfo);
    mListItem[IDX_CALLOUT   ]    = new CallOut   ( ITEM_CALLOUT   , commonData, mouseInfo);
    mListItem[IDX_TRADE     ]    = new Trade     ( ITEM_TRADE     , commonData, mouseInfo);
    mListItem[IDX_ALERT     ]    = new Alert     ( ITEM_ALERT     , commonData, mouseInfo);
    mListItem[IDX_POINT     ]    = new Point     ( ITEM_POINT     , commonData, mouseInfo);
    mListItem[IDX_LABEL     ]    = new LabelText ( ITEM_LABEL     , commonData, mouseInfo);

    gpTrade = (Trade*)mListItem[IDX_TRADE];
}

Controller::~Controller()
{
    delete mListItem[IDX_TREND     ];
    delete mListItem[IDX_ZIGZAG    ];
    delete mListItem[IDX_RECTANGLE ];
    delete mListItem[IDX_FIBONACI  ];
    delete mListItem[IDX_CALLOUT   ];
    delete mListItem[IDX_TRADE ];
    delete mListItem[IDX_ALERT     ];
    delete mListItem[IDX_POINT     ];
    delete mListItem[IDX_LABEL     ];
}

void Controller::setFinishedJobCB(FinishedJob cb)
{
    mFinishedJobCb = cb;
}

void Controller::finishedJob()
{
    CHECK_NOT_ACTIVE_RETURN
    pMouseInfo.setText("");
    mListItem[mActive].finishedDeactivate();
    mActive = IDX_NONE;
}

int Controller::findItemIdByKey(const int key)
{
    if (key == 'W') return IDX_TRADE     ;
    if (key == 'R') return IDX_RECTANGLE ;
    if (key == 'T') return IDX_TREND     ;
    if (key == 'F') return IDX_FIBONACI  ;
    if (key == 'G') return IDX_LABEL     ;
    if (key == 'Z') return IDX_ZIGZAG    ;
    if (key == 'X') return IDX_ALERT     ;
    if (key == 'C') return IDX_CALLOUT   ;
    if (key == 'S') return IDX_POINT     ;
    return IDX_NONE;
}

int Controller::findItemIdByName(const string& name)
{
    if (name == ITEM_TREND     ) return IDX_TREND     ;
    if (name == ITEM_ZIGZAG    ) return IDX_ZIGZAG    ;
    if (name == ITEM_RECTANGLE ) return IDX_RECTANGLE ;
    if (name == ITEM_FIBONACI  ) return IDX_FIBONACI  ;
    if (name == ITEM_CALLOUT   ) return IDX_CALLOUT   ;
    if (name == ITEM_TRADE     ) return IDX_TRADE     ;
    if (name == ITEM_ALERT     ) return IDX_ALERT     ;
    if (name == ITEM_POINT     ) return IDX_POINT     ;
    if (name == ITEM_LABEL     ) return IDX_LABEL     ;
    return IDX_NONE;
}

void Controller::handleKeyEvent(const long &key)
{
    // PrintFormat("handleKeyEvent %c %d", key, key);
    // S1: handle functional Key
    bool bFunctionKey = true;
    switch ((int)key)
    {
    case 27: // Esc
        finishedJob();
        unSelectAll();
        break;
    // Number Line
    case '1':
        if (mbActiveErase) EraseAll();
        break;
    case '2':
        if (mbActiveErase) EraseThisTF();
        break;
    case '3':
        if (mbActiveErase) EraseLowerTF();
        break;
    case '4':
        if (mbActiveErase) EraseBgOverlap();
        break;
    // QWERT Line
    case 'Y':
        ((Trade*)mListItem[IDX_TRADE]).showHistory(true);
        break;
    case 'U':
        ((Trade*)mListItem[IDX_TRADE]).showHistory(false);
        break;
    case 'H':
        SetChartFree(true);
        break;
    case 'J':
        SetChartFree(false);
        break;
    case 'V':
        syncSelectedItem();
        break;
    case 'B':
        syncDeleteSelectedItem();
        break;
    case 'Q':
        ChartSetSymbolPeriod(ChartID(), ChartSymbol(), lowerTF());
        SetChartFree(false);
        break;
    case 'P': // Using AHK to combine 'Shift+Q'='P'
        ChartSetSymbolPeriod(ChartID(), ChartSymbol(), higherTF());
        SetChartFree(false);
        break;
    case 188: // ','
        scaleChart(false);
        break;
    case 190: // '.'
        scaleChart(true);
        break;
    case 'L':
        restoreBacktestingTrade();
        break;
    default:
        bFunctionKey = false;
        break;
    }
    if (mActive == IDX_NONE) {
        if (key == 'E') {
            mbActiveErase = true;
            pMouseInfo.setText("Erase: 1-All | 2-ThisTF | 3-LowerTF | 4-BgOverlap");
        }
        else {
            mbActiveErase = false;
            pMouseInfo.setText("");
        }
    }
    else {
        // there is some tool is active
        if (key >= '1' && key <= '9')
        {
            mListItem[mActive].changeActiveType((int)key-'1');
        }
        else if (key == '0')
        {
            mListItem[mActive].changeActiveType(9);
        }
    }
    if (bFunctionKey == true) return;

    // S2: Active drawing tool
    int activeTarget = findItemIdByKey((int)key);
    if (activeTarget == IDX_NONE)
    {
        return;
    }
    if (activeTarget == mActive)
    {
        mListItem[mActive].changeActiveType();
        return;
    }
    CHECK_ACTIVE_RETURN
    unSelectAll();
    mActive = activeTarget;
    mListItem[mActive].startActivate(mFinishedJobCb);
}

void Controller::handleIdEventOnly(const int id)
{
    CHECK_NOT_ACTIVE_RETURN

    switch (id)
    {
    case CHARTEVENT_CLICK:
        mListItem[mActive].onMouseClick();
        break;

    case CHARTEVENT_MOUSE_MOVE:
        mListItem[mActive].onMouseMove();
        break;
    }
}

void Controller::handleSparamEvent(const int id, const string& sparam)
{
    CHECK_ACTIVE_RETURN

    string sparamItems[];
    int k=StringSplit(sparam,'_',sparamItems);
    if (k != 3)
    {
        return;
    }
    int receiverItem = findItemIdByName(sparamItems[0]);
    if (receiverItem == IDX_NONE)
    {
        return;
    }

    string itemId = sparamItems[0] + "_" + sparamItems[1];
    mListItem[receiverItem].touchItem(itemId);
    switch (id)
    {
    case CHARTEVENT_OBJECT_DELETE:
        if (StringFind(sparam, "_c") == -1) return;
        mListItem[receiverItem].onItemDeleted(itemId, sparam);
        gContextMenu.clearContextMenu();
        break;
    case CHARTEVENT_OBJECT_DRAG:
        if (StringFind(sparam, "_c") == -1) return;
        mListItem[receiverItem].onItemDrag(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CHANGE:
        if (StringFind(sparam, "_c") == -1) return;
        mListItem[receiverItem].onItemChange(itemId, sparam);
        break;
    case CHARTEVENT_OBJECT_CLICK:
        mListItem[receiverItem].onItemClick(itemId, sparam);
        break;
    case CHART_EVENT_SELECT_CONTEXTMENU:
        mListItem[receiverItem].onUserRequest(itemId, sparam);
        break;
    }
}

void Controller::handleOntick()
{
    ((Alert*)mListItem[IDX_ALERT]).checkAlert();
    ((Trade*)mListItem[IDX_TRADE]).scanLiveTrade();
}