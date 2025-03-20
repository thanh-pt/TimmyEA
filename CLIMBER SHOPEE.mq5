#include "CLIMBER SHOPEE.mqh"
#property copyright "Timmy"
#property link "https://www.mql5.com/en/users/thanh01"
#property icon "T-black.ico"
#property version   "1.00"

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
