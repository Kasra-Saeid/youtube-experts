input double pipInValueInput = 1;
input double riskInPercentInput = 1;


input int fastEmaLength = 10;
input ENUM_MA_METHOD fastEmaMode = MODE_SMA;
input ENUM_APPLIED_PRICE fastEmaSource = PRICE_CLOSE;

input int slowEmaLength = 200;
input ENUM_MA_METHOD slowEmaMode = MODE_SMA;
input ENUM_APPLIED_PRICE slowEmaSource = PRICE_CLOSE;

input int macdFastEmaLength = 12;
input int macdSlowEmaLength = 26;
input int macdSignalSmaLength = 9;

input double sATRMultiplier = 1.7;