#property copyright "Copyright 2023, KaiAlgo"
#property link      ""
#property version   "1.00"

#include <CustomLibraries/PositionManagement/positionManagement.mqh>
#include <CustomLibraries/StrategyManagement/strategyManagement.mqh>
#include <CustomLibraries/TimeManagement/timeManagement.mqh>
#include <CustomLibraries/TradeManagement/tradeManagement.mqh>


string s = _Symbol;
ENUM_TIMEFRAMES p = PERIOD_D1;

ENUM_TIMEFRAMES strategyTimeFrames[] = {p};
TimeManagement timeManagement(strategyTimeFrames);

PositionManagement* positionManagement = new PositionManagement();

StrategyManagement* strategyManagement = new StrategyManagement();

string tradeComment = "97 transparent trader";
CTrade* trade = new CTrade();
TradeManagement* tradeManagement = new TradeManagement(trade, s, tradeComment);


int macdHandle;
double macdBuffer[];
double macdSignalBuffer[];

int slowEmaHandle;
double slowEmaBuffer[];

int sATRHandle;
double sATRHigherBuffer[];
double sATRLowerBuffer[];


int OnInit()
  {
   timeManagement.initTime(s);
   
   strategyManagement.magicNumber = 000003;
   
   slowEmaHandle = iMA(s, p, slowEmaLength, 0, slowEmaMode, slowEmaSource);
   ArraySetAsSeries(slowEmaBuffer, false);
   
   macdHandle = iMACD(s, p, macdFastEmaLength, macdSlowEmaLength, macdSignalSmaLength, PRICE_CLOSE);
   ArraySetAsSeries(macdBuffer, false);
   ArraySetAsSeries(macdSignalBuffer, false);
   
   sATRHandle = iCustom(s, p, "sATR", MODE_EMA, 18, 18, sATRMultiplier);
   ArraySetAsSeries(sATRLowerBuffer, false);
   ArraySetAsSeries(sATRHigherBuffer, false);
   
   
   if (slowEmaHandle == INVALID_HANDLE) {
      Alert("Error: invalid ma handle");
      return INIT_FAILED;
   }
   
   if (macdHandle == INVALID_HANDLE) {
      Alert("Error: invalid macd handle");
      return INIT_FAILED;
   }
   
   if (sATRHandle == INVALID_HANDLE) {
      Alert("Error: invalid sATR handle");
      return INIT_FAILED;
   }
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if (slowEmaHandle != INVALID_HANDLE) IndicatorRelease(slowEmaHandle);
   if (macdHandle != INVALID_HANDLE) IndicatorRelease(macdHandle);   
   if (sATRHandle != INVALID_HANDLE) IndicatorRelease(sATRHandle);
   delete tradeManagement;
   delete positionManagement;
   delete strategyManagement;
   delete trade;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (timeManagement.isNewBar(s)) {
      if (!tradeManagement.isAutoTradeAllowed()) return;
      

      if (CopyBuffer(slowEmaHandle, 0, 0, 5, slowEmaBuffer) < 5) {
         Print("Insufficient results from slow ma");
         return;
      }

      if (CopyBuffer(macdHandle, 0, 0, 5, macdBuffer) < 5) {
         Print("Insufficient results from macd handle");
         return;
      }
      
      if (CopyBuffer(macdHandle, 1, 0, 5, macdSignalBuffer) < 5) {
         Print("Insufficient results from macd handle signal buffer");
         return;
      }
      
      if (CopyBuffer(sATRHandle, 1, 0, 3, sATRLowerBuffer) < 3) {
         Print("Insufficient results from lower sATR");
         return;
      }
     
      if (CopyBuffer(sATRHandle, 0, 0, 3, sATRHigherBuffer) < 3) {
         Print("Insufficient results from higher sATR");
         return;
      }
       
      if (positionManagement.orderTicket == 0) {
         // To check open position conditions
         
         if (isBuyEntryRuleValid(macdBuffer, macdSignalBuffer, slowEmaBuffer)) {
            // If reaches here, means buy conditions are valid
            double ep = iClose(s, p, 1);
            double sl = NormalizeDouble(sATRLowerBuffer[ArraySize(sATRLowerBuffer) - 1], _Digits);
            double orderSize = positionManagement.calculateOrderSize(ep, sl, riskInPercentInput, pipInValueInput);
            double riskInPips = positionManagement.calculateRiskInPoints(ep, sl);
            Print("ep: ", ep, " sl: ", sl, " order size: ", orderSize, " side: ", ORDER_TYPE_BUY);
            double takeProfit = ep + (riskInPips * rRRatioInput);
            ulong ticket = tradeManagement.openTrade(ORDER_TYPE_BUY, ep, sl, takeProfit, orderSize);
            positionManagement.openPosition(ep, sl, takeProfit,  ORDER_TYPE_BUY, orderSize, ticket, 0, true, 0);            
         } else if (isSellEntryRuleValid(macdBuffer, macdSignalBuffer, slowEmaBuffer)) {
            // If reaches here, means buy conditions are valid
            double ep = iClose(s, p, 1);
            double sl = NormalizeDouble(sATRHigherBuffer[ArraySize(sATRHigherBuffer) - 1], _Digits);
            double orderSize = positionManagement.calculateOrderSize(ep, sl, riskInPercentInput, pipInValueInput);
            double riskInPips = positionManagement.calculateRiskInPoints(ep, sl);
            Print("ep: ", ep, " sl: ", sl, " order size: ", orderSize, " side: ", ORDER_TYPE_SELL);
            double takeProfit = ep - (riskInPips * rRRatioInput);
            ulong ticket = tradeManagement.openTrade(ORDER_TYPE_SELL, ep, sl, takeProfit, orderSize);
            positionManagement.openPosition(ep, sl, takeProfit,  ORDER_TYPE_SELL, orderSize, ticket, 0, true, 0);            
         }
         
      } else {
         // To check take profit or stop loss conditions for both sides
         // first should divide positions into buys and sells
         // second should check if stop loss has hitted
         // third should check if take profit has hitted

         
         if (positionManagement.side == ORDER_TYPE_BUY) {
            if (isBuyStopLossRuleValid(positionManagement.stopLossPrice)) {
               positionManagement = new PositionManagement();
            } else if (isBuyTakeProfitRuleValid(positionManagement.takeProfitPrice)){
               positionManagement = new PositionManagement();
            }
         } else if (positionManagement.side == ORDER_TYPE_SELL) {
            if (isSellStopLossRuleValid(positionManagement.stopLossPrice)) {
               positionManagement = new PositionManagement();
            } else if (isSellTakeProfitRuleValid(positionManagement.takeProfitPrice)){
               positionManagement = new PositionManagement();
            }
         }         
      }
   } 
  }
//+------------------------------------------------------------------+