public class sfdcGovernorLimits_Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<LimitWrapper> getGovernorLimits()
    {
        List<System.OrgLimit> limits = OrgLimits.getAll();
        List<LimitWrapper> limitWrapList = new List<LimitWrapper>();
        for (System.OrgLimit aLimit: limits) 
        {
            LimitWrapper limitWrap = new LimitWrapper();
            limitWrap.limitName = aLimit.getName();
            limitWrap.limitValue = aLimit.getLimit();
            limitWrap.usageValue = aLimit.getValue();
            if(limitWrap.limitValue <> 0)
            {
                limitWrap.percentValue = (limitWrap.usageValue/limitWrap.limitValue);
            }
            
            System.debug('Limit: ' + aLimit.getLimit());
            System.debug('Usage Value is: ' + aLimit.getValue());
            System.debug('Max Limit is: ' + aLimit.getLimit()); 
            limitWrapList.add(limitWrap);
        }
        system.debug('limitWrapList::'+limitWrapList);
        return limitWrapList;
    }
    
    public class LimitWrapper
    {
        @AuraEnabled
        public string limitName;
        @AuraEnabled
        public Decimal limitValue;
        @AuraEnabled
        public Decimal usageValue;
        @AuraEnabled
        public Decimal percentValue;
    }
}