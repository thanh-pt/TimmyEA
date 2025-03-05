
#include "PAL.mqh"

class IMtHandler
{
private:
    /* data */
public:
    IMtHandler(/* args */);
    ~IMtHandler();
    virtual void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
    virtual void OnTick();
    virtual int OnInit();
};

IMtHandler::IMtHandler(/* args */)
{
}

IMtHandler::~IMtHandler()
{
}

void IMtHandler::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
}

void IMtHandler::OnTick() {
}

int IMtHandler::OnInit() {
    return INIT_SUCCEEDED;
}
