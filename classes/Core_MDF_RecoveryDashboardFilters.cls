public without sharing class Core_MDF_RecoveryDashboardFilters {
    public static List<Core_MDF_RecoveryFilters.AccountOptions> getAccountIdToNameMapForExternal (String program){
        List<Core_MDF_RecoveryFilters.AccountOptions> accOpt = new List<Core_MDF_RecoveryFilters.AccountOptions>();
        User u = [select Id, AccountId from user where id=:UserInfo.getUserId() limit 1];
        
        String groupName='';
        //Claim Recovery
        //If program=RMF/IPA, query for pnum instead of pgm
         //get the pgm for that acct & prog
          //if is agency then get the worksfor & return
          //if not agency ,check the comarketing active flag. If true then return 
          //if flag false the loop through again for the group where isagency false and comarketing acive true and return.
          for(Core_MDF_Partner_Group_Mapping__c pgm : [select id,Core_MDF_Account__c,Core_MDF_Account__r.Name,Core_MDF_CoMarketingActiveAccount_Id__c,
                                                             Core_MDF_Virtual_Corp_nm__c,Core_MDF_CoMarketingActiveAccount_Nm__c,
                                                            Core_MDF_Channel_Program__r.name from 
                                                            Core_MDF_Partner_Group_Mapping__c where 
                                                            Core_MDF_Type_of_Access__c ='External' and Core_MDF_Channel_Program__r.name=: program
                                                            and Core_MDF_Inactive_Ind__c = false and Core_MDF_Account__c =: u.AccountId order by Core_MDF_Account__r.Name]){
                                                                Core_MDF_RecoveryFilters.AccountOptions accOptions = new Core_MDF_RecoveryFilters.AccountOptions();
                                                                
                                                                if(pgm.Core_MDF_Virtual_Corp_nm__c != null){
                                                                    accOptions.accountName = pgm.Core_MDF_CoMarketingActiveAccount_Nm__c;
                                                                    accOptions.accountId = pgm.Core_MDF_CoMarketingActiveAccount_Id__c;
                                                                    
                                                                    accOptions.isExternal = true;
                                                                    accOpt.add(accOptions);
                                                                }
                }
        
        
                
        
        
        
        return accOpt;
        
    }
}