public with sharing class Core_MDF_RecoveryFilters {
    public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static string Ext_UserType=Core_MDF_CCP_ConstantClass.Ext_UserType;
    @AuraEnabled(cacheable=true)
    public static List<ProgramOptions>  getProgramIdToNameMap (){
        List<ProgramOptions> progOpt = new List<ProgramOptions>();
        for(ChannelProgram cp : [SELECT Core_MDF_Technical_Program_Name__c,name from ChannelProgram WITH SECURITY_ENFORCED order by name asc LIMIT 100]){
            
            ProgramOptions progOptions = new ProgramOptions();
            progOptions.progname = cp.name;
            progOptions.progApiName = cp.Core_MDF_Technical_Program_Name__c;
            if(UserInfo.getUserType() == Ext_UserType){
                progOptions.isExternal = true;
            }
            else{
                progOptions.isExternal = false;
            }
            progOpt.add(progOptions);
        
        }
        return progOpt;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AccountOptions>  getAccountIdToNameMap (String program){
        List<AccountOptions> accOpt = new List<AccountOptions>();
        if(UserInfo.getUserType() == Ext_UserType){
            accOpt =Core_MDF_RecoveryClaimReportViewCtrl.getAccountIdToNameMapForExternal(program);
        }
        else{
            
           
            if(Programs_For_Node_Account.contains(program)){
                for(Account acc:[select Id,Name from Account where RecordType.DeveloperName ='Core_MDF_Co_Marketing' and Core_MDF_Channel_Program__r.name=: program and Core_MDF_CoMarketing_Ultimate_Account__c!='' and Core_MDF_Active_Ind__c=true WITH SECURITY_ENFORCED order by Name asc]){
                    AccountOptions accOptions = new AccountOptions();
                    accOptions.accountName = acc.Name;
                    accOptions.accountId = acc.Id;
                    accOptions.isExternal = false;
                    accOpt.add(accOptions);
            	}	
            }
            else{
            //return [select Core_MDF_Account_id__c,Core_MDF_Account_id__r.name from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_Channel_Program_id__r.name=: program and Core_MDF_Account_id__r.Core_MDF_CoMarketingActive__c =true];
            for(Account acc: [select Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.name from Account where RecordType.DeveloperName ='Core_MDF_Co_Marketing' and Core_MDF_Channel_Program__r.name=: program and Core_MDF_CoMarketing_Ultimate_Account__c != '' WITH SECURITY_ENFORCED order by Core_MDF_CoMarketing_Ultimate_Account__r.name asc]){
                AccountOptions accOptions = new AccountOptions();
                accOptions.accountName = acc.Core_MDF_CoMarketing_Ultimate_Account__r.name;
                accOptions.accountId = acc.Core_MDF_CoMarketing_Ultimate_Account__c;
                accOptions.isExternal = false;
                accOpt.add(accOptions);
            } 
            }
        }
        
        return accOpt;
    }
    
    @AuraEnabled
    public static boolean scheduleRecoveryBatch(RecoveryBatchParams wrapper){
        boolean result = false;
        try{
            
            if(wrapper!=null && wrapper.account!='' && FeatureManagement.checkPermission('Core_MDF_Recovery_Run')){
                Core_MDF_Recovery_Batch obj = new Core_MDF_Recovery_Batch(wrapper.program,wrapper.budgetType,wrapper.quarter,wrapper.account);
                Id jobId = Database.executeBatch(obj);
                result = jobId!=null ? true:false;
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;
    }
    
    public class AccountOptions {
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public Id accountId { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    } 
    
    public class ProgramOptions {
        @AuraEnabled public String progname { get; set; }
        @AuraEnabled public String progApiName { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    }
    
    public class RecoveryBatchParams {
        @AuraEnabled public String program { get; set; }
        @AuraEnabled public String account { get; set; } 
        @AuraEnabled public String quarter { get; set; } 
        @AuraEnabled public String budgetType { get; set; } 
    } 
    
}