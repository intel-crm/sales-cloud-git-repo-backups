public without sharing class Sales_SubscriptionValidationUtility {
    public static List<Date> subscriptionStartDateUpdate(SBQQ__Subscription__c subscriptionList,Map<Id,Product2> prodMap){
      	List<Date> sublist = new List<Date>();
        	SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
           	Integer productexp = Integer.valueOf(prodMap.get(subs.SBQQ__Product__c).Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c);
            Date result = subs.SBQQ__SubscriptionStartDate__c.addDays(productexp);
            Integer numberOfDays = Date.daysInMonth(result.year(), result.month());
            Date lastDayOfMonth = Date.newInstance(result.year(), result.month(), numberOfDays);
            Datetime dt = datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(),lastDayOfMonth.day());
           	sublist.add(lastDayOfMonth) ;
            
            Integer maintduration = Integer.valueOf(prodMap.get(subs.SBQQ__Product__c).SBQQ__SubscriptionTerm__c);
            Date mainresult = subs.SBQQ__SubscriptionStartDate__c.addDays(maintduration);
            Integer MaintnumberOfDays = Date.daysInMonth(mainresult.year(), mainresult.month());
            Date MaintlastDayOfMonth = Date.newInstance(mainresult.year(), mainresult.month(), MaintnumberOfDays);
           	sublist.add(MaintlastDayOfMonth) ;
        	System.debug(sublist);
         return sublist;
    }
}