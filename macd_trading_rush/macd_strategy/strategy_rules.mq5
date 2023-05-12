#include <CustomLibraries/StrategyManagement/LogicalOp/or.mqh>
#include <CustomLibraries/StrategyManagement/LogicalOp/and.mqh>
#include <CustomLibraries/StrategyManagement/LogicalOp/not.mqh>
#include <CustomLibraries/StrategyManagement/BinaryRules/firstIndicatorBelowSecond.mqh>
#include <CustomLibraries/StrategyManagement/BinaryRules/crossUp.mqh>
#include <CustomLibraries/StrategyManagement/BinaryRules/crossDown.mqh>
#include <CustomLibraries/StrategyManagement/BinaryRules/firstIndicatorAboveSecond.mqh>
#include <CustomLibraries/StrategyManagement/UnaryRules/higherThanLine.mqh>
#include <CustomLibraries/StrategyManagement/UnaryRules/lowerThanLine.mqh>
#include <CustomLibraries/StrategyManagement/UnaryRules/inAbsoluteBoundary.mqh>


bool isBuyEntryRuleValid(
      double &macd[],
      double &macdSignal[],
      double &slowMa[]) {
      
      bool result;
      
      Rule* macdCrossUp = new CrossUp(macd, macdSignal, 1, 1);
      Rule* macdBelowZero = new LowerThanLine(macd, 1, 0);
      Rule* a[] = {macdCrossUp, macdBelowZero};
      Rule* macdRule = new And(a);
      
      Rule* slowMaRule = new LowerThanLine(slowMa, 1, iClose(s, p, 1));
      
      Rule* c[] = {macdRule, slowMaRule};
      Rule* theRule = new And(c);
      
      result = theRule.isValid();
      
      delete macdCrossUp;
      delete macdBelowZero;
      delete macdRule;
      delete slowMaRule;
      delete theRule;
      
      return result;
}

bool isBuyTakeProfitRuleValid(double tp) {
   bool result;
   double highs[] = {iHigh(s, p, 1)};
   Rule* priceAboveHighsPrice = new HigherThanLine(highs, 0, tp);
   result = priceAboveHighsPrice.isValid();
   delete priceAboveHighsPrice;   
   return result;
}

bool isBuyStopLossRuleValid(double stopLoss) {
   bool result;
   double lows[] = {iLow(s, p, 1)};
   Rule* slBuyRule = new LowerThanLine(lows, 0, stopLoss);
   result = slBuyRule.isValid();
   delete slBuyRule;
   return result;
}

bool isSellEntryRuleValid(
      double &macd[],
      double &macdSignal[],
      double &slowMa[]) {
      
      bool result;
      
      Rule* macdCrossDown = new CrossDown(macd, macdSignal, 1, 1);
      Rule* macdHigherThanZero = new HigherThanLine(macd, 1, 0);
      Rule* a[] = {macdCrossDown, macdHigherThanZero};
      Rule* macdRule = new And(a);
      
      Rule* slowMaRule = new HigherThanLine(slowMa, 1, iClose(s, p, 1));
      
      Rule* c[] = {macdRule, slowMaRule};
      Rule* theRule = new And(c);
      
      result = theRule.isValid();
      
      delete macdCrossDown;
      delete macdHigherThanZero;
      delete macdRule;
      delete slowMaRule;
      delete theRule;
      
      return result;
}

bool isSellTakeProfitRuleValid(double tp) {
   bool result;
   double lows[] = {iLow(s, p, 1)};
   Rule* priceLowerThanLine = new LowerThanLine(lows, 0, tp);
   result = priceLowerThanLine.isValid();
   delete priceLowerThanLine;   
   return result;
}

bool isSellStopLossRuleValid(double stopLoss) {
   bool result;
   double highs[] = {iHigh(s, p, 1)};
   Rule* slSellRule = new HigherThanLine(highs, 0, stopLoss);
   result = slSellRule.isValid();
   delete slSellRule;
   return result;
}