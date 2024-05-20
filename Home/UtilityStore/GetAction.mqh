string getTFString()
{
    string result = "";
    int period = ChartPeriod();
    if (period < PERIOD_H1)
    {
        result = "m";
        result += IntegerToString(period);
        return result;
    }
    if (period < PERIOD_D1)
    {
        result = "h";
        result += IntegerToString(period/PERIOD_H1);
        return result;
    }
    if (period < PERIOD_W1)
    {
        result = "d";
        return result;
    }
    if (period < PERIOD_MN1)
    {
        result = "w";
        return result;
    }
    result = "mn";
    return result;
}

void getCenterPos(const datetime& time1, const datetime& time2, double price1, double price2, datetime& outTime, double& outPrice)
{
    int x1,y1,x2,y2;
    int window = 0;
    ChartTimePriceToXY(ChartID(), window, time1, price1, x1, y1);
    ChartTimePriceToXY(ChartID(), window, time2, price2, x2, y2);
    x1 = (x1+x2)/2;
    y1 = (y1+y2)/2;
    ChartXYToTimePrice(ChartID(), x1, y1, window, outTime, outPrice);
    outPrice = (price1+price2)/2;
}

datetime getCenterTime(const datetime& time1, const datetime& time2)
{
    datetime centerTime;
    double price;
    double priceInp = ChartGetDouble(ChartID(),CHART_FIXED_MAX);
    getCenterPos(time1, time2, priceInp, priceInp, centerTime, price);
    return centerTime;
}

string getItemUnderMouse(int posX, int posY)
{
    for(int i=ObjectsTotal() - 1 ;  i >= 0 ;  i--)
    {
        string objName = ObjectName(i);
        if (ObjectGet(objName, OBJPROP_SELECTED) == false) continue;
        if (ObjectGet(objName, OBJPROP_SELECTABLE) == false) continue;
        if (StringFind(objName, TAG_CTRL) == -1) continue;

        int objType = ObjectType(objName);

        if (objType == OBJ_TREND || objType == OBJ_RECTANGLE)
        {
            int x1, y1, x2, y2;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME2), ObjectGet(objName, OBJPROP_PRICE2), x2, y2);

            int offset = 10;
            if (x1 > x2)
            {
                int temp = x1;
                x1 = x2;
                x2 = temp;
            }
            if (posX < (x1 - offset) || posX > (x2 + offset))
            {
                continue;
            }
            if (y1 > y2)
            {
                int temp = y1;
                y1 = y2;
                y2 = temp;
            }
            if (posY >= (y1 - offset) && posY < (y2 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_ARROW || objType == OBJ_TEXT)
        {
            int x1, y1;
            ChartTimePriceToXY(0, 0, (datetime)ObjectGet(objName, OBJPROP_TIME1), ObjectGet(objName, OBJPROP_PRICE1), x1, y1);

            int offset = 10;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
        if (objType == OBJ_LABEL)
        {
            int x1 = (int)ObjectGet(objName, OBJPROP_XDISTANCE);
            int y1 = (int)ObjectGet(objName, OBJPROP_YDISTANCE);

            int offset = 20;
            if (posX < (x1 - offset) || posX > (x1 + offset))
            {
                continue;
            }
            if (posY >= (y1 - offset) && posY < (y1 + offset))
            {
                return objName;
            }
            continue;
        }
    }
    return "";
}


int getObjectTimeId(string objId)
{
    int startP = StringFind(objId, "#");
    if (startP < 0) return hashString(objId);
    int endP = StringFind(objId, "_", startP);
    if (endP < 0) return hashString(objId);
    string timeIdStr = StringSubstr(objId, startP+1, endP-startP-1);
    return StrToInteger(timeIdStr);
}

string getRandStr(){
    return gStrRand[rand()%(ArraySize(gStrRand))];
}

string getFullBlock(int size){
    return StringSubstr(FULL_BLOCK, 0, size);
}