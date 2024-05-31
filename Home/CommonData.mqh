#ifndef CommonData_mqh
#define CommonData_mqh

#define SHIFT_HOLD 0x04
#define CTRL_HOLD  0x08

class CommonData
{
private:
    int      mSubwindow;
public:
    datetime mMouseTime;
    double   mMousePrice;
    int      mMouseX;
    int      mMouseY;
    bool     mShiftHold;
    bool     mCtrlHold;
    long     mChartWidth;
public:
    void updateMousePosition(const long& x, const double& y, const string &sparam)
    {
        int option = StrToInteger(sparam);
        mShiftHold = ((option & SHIFT_HOLD) != 0);
        mCtrlHold  = ((option & CTRL_HOLD) != 0);
        mMouseX = (int) x;
        mMouseY = (int) y;
        ChartXYToTimePrice(ChartID(), (int)mMouseX, (int)mMouseY, mSubwindow, mMouseTime, mMousePrice);
        if(mCtrlHold) {
            controlHold();
        }
        ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS ,mSubwindow, mChartWidth);
        ChartSetDouble(ChartID(),CHART_FIXED_POSITION, (double)mMouseX/mChartWidth*100);
    }
    void controlHold()
    {
        int shift = iBarShift(ChartSymbol(), ChartPeriod(), mMouseTime);
        if (shift <= 0) {
            return;
        }
        do
        {
            if (mMousePrice <= Low[shift]) {
                mMousePrice = Low[shift];
                break;
            }
            if (mMousePrice >= High[shift]) {
                mMousePrice = High[shift];
                break;
            }
            double bodyHigh = Open[shift];
            double bodyLow  = Close[shift];
            if (Close[shift] > Open[shift]) {
                bodyHigh = Close[shift];
                bodyLow  = Open[shift];
            }
            
            double centerPrice = (bodyLow + bodyHigh) / 2;
            
            if (mMousePrice <= centerPrice) {
                mMousePrice = bodyLow;
            }
            else {
                mMousePrice = bodyHigh;
            }

        } while (false);

        ChartTimePriceToXY(ChartID(), 0, mMouseTime, mMousePrice, mMouseX, mMouseY);
    }
};

#endif