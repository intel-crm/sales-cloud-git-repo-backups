public class ER_WhiteListBlackList_Utility 
{
    public static Long startTime;
    
    public static ER_WhiteListBlackList_Model.WhitelistBlackListResult getWhiteListBlackListDomains(String programCode,String entitlementName)
    {
        ER_WhiteListBlackList_Model.WhitelistBlackListResult result = new ER_WhiteListBlackList_Model.WhitelistBlackListResult();
        
        System.debug(getAllowedDomainList(programCode));
        result.AllowedDomains = getAllowedDomainList(programCode);
        result.AcceptableDomainList = getDomainList(programCode, true,entitlementName);
        result.RestrictedDomains = getDomainList(programCode, false,entitlementName);
        result.ProjectBudgetDetails = getProjectBudgetDetails(programCode);
        result.ProgramCode = programCode;
        result.EntitlementName = entitlementName;
        result.ResponseTimeMS = responseTimeCalc();
        if(result.AcceptableDomainList.size() == 0 && result.AllowedDomains.size() == 0 && result.RestrictedDomains.size() == 0 && result.ProjectBudgetDetails.size() == 0)
        {
            if(Test.isRunningTest())
            {
                ER_WhiteListBlackList.CustomException custEx = new ER_WhiteListBlackList.CustomException();
                custEx.Message = 'No records found';
                System.debug('Error : '+custEx.Message);
                throw custEx;                
            }
            
            return generateError('No records found');
        }
       // ER_WhiteListBlackList.createLogEntry('GetWhitelistBlacklist API response log - Response Time in MS: '+result.ResponseTimeMS, null, ER_WhiteListBlackList.LOG_ENTRY_INFO,programCode );
       // Cache.Org.put('local.EnterpriseRegistrationCache.WhiteListBlackListCache',result, Integer.valueOf(Label.WhiteListBlackListCacheExpiryTime),Cache.Visibility.ALL, true);
        return result;
    }
    
    private static List<String> getAllowedDomainList(String programCode)
    {
        List<String> domainList = new List<String>();
        
        for(Core_Account_Whitelisted_Domains__c lstAccptDmn : [SELECT Name FROM Core_Account_Whitelisted_Domains__c WHERE Partner_Program__r.PRM_programCode__c  = 'IQR' and Inactive_Indicator__c = false])
        { 
            System.debug(lstAccptDmn.Name);
            if(!domainList.contains(lstAccptDmn.Name))
                domainList.add( lstAccptDmn.Name) ;
            
        }
          System.debug('List');
         System.debug(domainList);
        return domainList;
    }
    
    private static List<ER_WhiteListBlackList_Model.ProjectBudgetWrapper> getProjectBudgetDetails(String programCode)
    {
        System.debug('Entered getProjectBudgetDetails+programCode'+programCode);
        List<ER_WhiteListBlackList_Model.ProjectBudgetWrapper> priceRangeList = new List<ER_WhiteListBlackList_Model.ProjectBudgetWrapper>();
        for(BusinessValidation__c busValidation : [SELECT MaxBudget__c, MinBudget__c, Business_Types__r.Name,Country__c, Geo__c,Min_Budget_Display_Name__c,Max_Budget_Display_Name__c 
                                                   from BusinessValidation__c WHERE Business_Types__r.Name= :programCode AND RecordType.Name ='Budget'])
        { 
            ER_WhiteListBlackList_Model.ProjectBudgetWrapper record = new ER_WhiteListBlackList_Model.ProjectBudgetWrapper();
            record.ProjectSubType = busValidation.Business_Types__r.Name;
            record.Country = busValidation.Country__c;
            record.MaxBudget = busValidation.MaxBudget__c;
            record.MinBudget = busValidation.MinBudget__c;
            record.Geo = busValidation.Geo__c;
           	record.MinBudgetDisplayName=busValidation.Min_Budget_Display_Name__c;
            record.MaxBudgetDisplayName=busValidation.Max_Budget_Display_Name__c;
            priceRangeList.add(record);
        }
        
        return priceRangeList;
    }
    
    
    private static List<ER_WhiteListBlackList_Model.WhiteListedWrapper> getDomainList(String programCode,boolean isWhitelist,String entitlementName)
    {
        System.debug('Entered getDomainList');
        List<ER_WhiteListBlackList_Model.WhiteListedWrapper> domainList = new List<ER_WhiteListBlackList_Model.WhiteListedWrapper>();
        for(BusinessValidation__c wlbl : [SELECT Country__c,Domain_Name__c,Geo__c FROM BusinessValidation__c 
                                          WHERE Business_Types__r.Name =: programCode AND Iswhitelisted__c=:isWhitelist and IsActive__c = TRUE 
                                          AND  RecordType.Name ='WhiteListed Domain'])
        { 
            ER_WhiteListBlackList_Model.WhiteListedWrapper record = new ER_WhiteListBlackList_Model.WhiteListedWrapper();
            record.Domains = wlbl.Domain_Name__c;
            record.GeoList = wlbl.Geo__c;
            record.Countries = wlbl.Country__c;
            domainList.add(record);
        }
        return domainList;
    }
    
    public static ER_WhiteListBlackList_Model.WhitelistBlackListResult generateError(String errorMsg){
        ER_WhiteListBlackList_Model.WhitelistBlackListResult wlblresult = new  ER_WhiteListBlackList_Model.WhitelistBlackListResult();
        ER_WhiteListBlackList_Model.ExceptionWrapper ew = new ER_WhiteListBlackList_Model.ExceptionWrapper();
        ew.Status = 'ERROR';
        ew.StatusCode = 400;
        ew.Message = errorMsg;
        wlblresult.ExceptionDetails = ew;
        wlblresult.ResponseTimeMS = responseTimeCalc();
        return wlblresult;
    }
    
    public static ER_WhiteListBlackList_Model.WhitelistBlackListResult generateException(Exception e){
        ER_WhiteListBlackList_Model.WhitelistBlackListResult wlblresult = new  ER_WhiteListBlackList_Model.WhitelistBlackListResult();
        ER_WhiteListBlackList_Model.ExceptionWrapper ew = new ER_WhiteListBlackList_Model.ExceptionWrapper();
        ew.Status = 'ERROR';
        ew.StatusCode = 400;
        ew.Message = e.getMessage();
        system.debug('Exception Cause ==>'+e.getCause());
        wlblresult.ExceptionDetails = ew;
        wlblresult.ResponseTimeMS = responseTimeCalc();
        return wlblresult;
    } 
    
    public static Long responseTimeCalc(){
        return system.now().getTime()-startTime;
    }
}