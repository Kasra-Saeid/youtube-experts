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
      double &fastSma[],
      double &slowSma[]) {
      
      bool result;
      
      Rule* increasingMacd = new FirstIndicatorAboveSecond(macd, macd, 1, 2);
      Rule* macdBelowZero = new LowerThanLine(macd, 1, 0);
      Rule* a[] = {increasingMacd, macdBelowZero};
      Rule* macdRule = new And(a);
      
      Rule* slowSmaRule = new LowerThanLine(slowSma, 1, iClose(s, p, 1));
      Rule* fastSmaRule = new HigherThanLine(fastSma, 1, iClose(s, p, 1));
      Rule* b[] = {slowSmaRule, fastSmaRule};
      Rule* smaRule = new And(b);
      
      Rule* c[] = {macdRule, smaRule};
      Rule* theRule = new And(c);
      
      result = theRule.isValid();
      
      delete increasingMacd;
      delete macdBelowZero;
      delete macdRule;
      delete slowSmaRule;
      delete fastSmaRule;
      delete smaRule;
      delete theRule;
      return result;
}

bool isBuyTakeProfitRuleValid(double tp) {
   bool result;
   double closes[] = {iClose(s, p, 1)};
   Rule* priceAboveClosePrice = new HigherThanLine(closes, 0, tp);
   result = priceAboveClosePrice.isValid();
   delete priceAboveClosePrice;   
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