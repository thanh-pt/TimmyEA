#include "CLIMBER SHOPEE.mqh"

MtHandler mtHandler;

int OnInit() {
    return mtHandler.OnInit();
}

void OnTick() {
    mtHandler.OnTick();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    mtHandler.OnChartEvent(id, lparam, dparam, sparam);
}
