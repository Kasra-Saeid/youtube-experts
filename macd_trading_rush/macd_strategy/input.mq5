input double rRRatioInput = 1.5; // risk to reward ratio

input double pipInValueInput = 1;
input double riskInPercentInput = 1;

input int slowEmaLength = 200;
input ENUM_MA_METHOD slowEmaMode = MODE_EMA;
input ENUM_APPLIED_PRICE slowEmaSource = PRICE_CLOSE;

input int macdFastEmaLength = 12;
input int macdSlowEmaLength = 26;
input int macdSignalSmaLength = 9;

input double sATRMultiplier = 1.7;