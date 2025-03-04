/*
 * Idea:
 * - BUY Trader
 * - Daily following
*/

#define APP_TAG "EA_Perry"

#resource "PerrythePlatypusBG.bmp"

bool gReadyStage = false;

int OnInit() {
    ChartSetInteger(0, CHART_SHOW_GRID, false);
    ChartSetInteger(0, CHART_SHOW_PERIOD_SEP, true);
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
    ChartSetInteger(0, CHART_SHOW_BID_LINE, true);
    ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
    initProfileApprearence();
    return INIT_SUCCEEDED;
}

void OnTick() {
    // if (gReadyStage == false) return; TODO
}

bool initEA() {
    // TODO
    // Bật BOT - Kiểm tra thông tin các lệnh hiện hành
    // Nếu lệnh này dính từ đêm qua -> Yêu cầu người xử lý -> return false + thong bao loi
    // Nếu lệnh mới vào - Do bật tắt bot -> Nạp dữ liệu vào RAM -> return true
    return false;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    if (id == CHARTEVENT_OBJECT_CLICK) handleClick(sparam);
}

/// @brief Apprearence and Action
string objBackGround    = APP_TAG + "AvatarBG";
string objBtnStart      = APP_TAG + "BtnStart";
void initProfileApprearence() {
    ObjectCreate(0,objBackGround,OBJ_BITMAP_LABEL,0,0,0);
    ObjectSetInteger(0,objBackGround,OBJPROP_CORNER,CORNER_LEFT_LOWER);
    ObjectSetInteger(0,objBackGround,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
    ObjectSetInteger(0,objBackGround,OBJPROP_XDISTANCE,0);
    ObjectSetInteger(0,objBackGround,OBJPROP_YDISTANCE,0);
    ObjectSetString(0,objBackGround,OBJPROP_BMPFILE,0,"::PerrythePlatypusBG.bmp");
}

void handleClick(string sparam)
{
    if (sparam == objBtnStart) {
        if (initEA() == false) {
            // Thông báo lỗi
            return;
        }
        gReadyStage = true;
    }
    // else if () {}
}