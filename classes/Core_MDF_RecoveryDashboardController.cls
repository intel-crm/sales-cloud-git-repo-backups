/***************************************************************************************************
* Apex Class Name: Core_MDF_RecoveryDashboardController
* Version     : 1.0 
* Created Date: 10th August 2023
* Function    : Recoveru Dashboard screen supporting methods
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amey K     				08/10/2023              Created
****************************************************************************************************/
public with sharing  class Core_MDF_RecoveryDashboardController {//Core_MDF_RecoveryDashboardController
    public static string Ext_UserType=Core_MDF_CCP_ConstantClass.Ext_UserType;
    public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    
    
    
    /****************************************************************************************************** 
    Method Name:        getPartnershipScoreRecord
    @return  :          List<Core_MDF_Partnership_Score__c>
    @parameters:        programId, AccountId And String Qtr
    Description:        Method to return single Partnership Score Record based on the programId AccountId And Qtr Combination
    Added By:           Accenture - AK - 08/11/2023
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static List<Core_MDF_Partnership_Score__c>  getPartnershipScoreRecord (String program,String account,String quarter){
        List<Core_MDF_Partnership_Score__c> partnershipScoreRec = new List<Core_MDF_Partnership_Score__c>();
        try{
            program = String.escapeSingleQuotes(program);
            account = String.escapeSingleQuotes(account);
            quarter = String.escapeSingleQuotes(quarter);
            String strQuery = 'select Id,Core_MDF_Program_nm__c,Core_MDF_Account_Id__r.name,Core_MDF_Quarter_nm__c,Core_MDF_Channel_Program_Id__c from Core_MDF_Partnership_Score__c  where Core_MDF_Channel_Program_Id__c  =\''+program+'\' and Core_MDF_Account_Id__c = \''+account+'\' and Core_MDF_Quarter_Year_nm__c = \''+quarter+'\'';

            partnershipScoreRec = Database.query(strQuery);
            
        }catch(exception error){Core_MDF_CCP_UtilityClass.logError(error);}  
        
        Return partnershipScoreRec;
        
    }
    
    
    /****************************************************************************************************** 
    Method Name:        getQuarterOptionsMap
    @return  :          List<String>
    @parameters:        none
    Description:        Method returns the Quarter List till Previous Quarter (List Does not include current Quarter)
    Added By:           Accenture - AK - 08/11/2023
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
     @AuraEnabled
    public static List<String> getQuarterOptionsMap (){
        
        List<String> finalQuarter = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        
        Set<String> quarter = new Set<String>(finalQuarter);
       
        Date dat = System.today();
        
        //this method call gets up the current qtr based on todays date
        String currentQuarter = Core_MDF_ReverseAuditDecision.determineQuartYear(dat);
        //since it is list - direct remove method not available here so converted to set and converted batch to list because js accespt list and not set
        quarter.remove(currentQuarter);
        List<String> qtrList = new List<String>(quarter);
        return qtrList;
    }
    
    
    /****************************************************************************************************** 
    Method Name:        getAccountIdToNameMap
    @return  :          wrapper - AccountUserDataWrapper
    @parameters:        String program
    Description:        Method returns a wrapper(AccountUserDataWrapper) which includes [the wrapper (Core_MDF_RecoveryFilters.AccountOptions) + isUserExternal result] 
    					Returns list of Intel Accounts which user has Access
    Added By:           Accenture - AK - 08/11/2023
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static AccountUserDataWrapper  getAccountIdToNameMap (String program){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> UltiAccountIds = new Set<Id>();
        AccountUserDataWrapper accUserDataWrapper = new AccountUserDataWrapper();
        List<Core_MDF_RecoveryFilters.AccountOptions> accOpt = new List<Core_MDF_RecoveryFilters.AccountOptions>();
        try{
            
            if(UserInfo.getUserType() == Ext_UserType){
                accUserDataWrapper.isUserExternal = true;
                List<Core_MDF_RecoveryFilters.AccountOptions> accOptForExtUser = Core_MDF_RecoveryDashboardFilters.getAccountIdToNameMapForExternal(program);
                accUserDataWrapper.accountDetailsList = accOptForExtUser;
            }else{
                accUserDataWrapper.isUserExternal = false;
               
                for(Account acc: [select Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_CoMarketing_Ultimate_Account__r.name from Account where RecordType.DeveloperName ='Core_MDF_Co_Marketing' and Core_MDF_Channel_Program__r.name=: program and Core_MDF_CoMarketing_Ultimate_Account__c != '' WITH SECURITY_ENFORCED order by Core_MDF_CoMarketing_Ultimate_Account__r.name asc]){
                    Core_MDF_RecoveryFilters.AccountOptions accOptions = new Core_MDF_RecoveryFilters.AccountOptions();
                    accOptions.accountName = acc.Core_MDF_CoMarketing_Ultimate_Account__r.name;
                    accOptions.accountId = acc.Core_MDF_CoMarketing_Ultimate_Account__c;
                    accOptions.isExternal = false;
                    accOpt.add(accOptions);
                }
                accUserDataWrapper.accountDetailsList = accOpt;
                
            }
        }catch(exception error){Core_MDF_CCP_UtilityClass.logError(error);} 
        
        return accUserDataWrapper;
    }
    
    /****************************************************************************************************** 
    Method Name:        getProgramIdToNameMap
    @return  :          wrapper - ProgramUserDataWrapper
    @parameters:        none
    Description:        method retruns a wrapper (ProgramUserDataWrapper) which contains [a wrapper(ProgramOptions) + isUserExternal]
    					Returns list of programs based on user access
    Added By:           Accenture - AK - 08/11/2023
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    @AuraEnabled
     public static ProgramUserDataWrapper  getProgramIdToNameMap (){
        
        List<ProgramOptions> progOpt = new List<ProgramOptions>();
        
         
        ProgramUserDataWrapper PrgrmUsrDataWrapper = new ProgramUserDataWrapper();
        try{
            if(UserInfo.getUserType() == Ext_UserType){
            	PrgrmUsrDataWrapper.isUserExternal = true;
            }
            else{
            	PrgrmUsrDataWrapper.isUserExternal = false;
            }
            for(ChannelProgram cp : [SELECT Core_MDF_Technical_Program_Name__c,name,Id from ChannelProgram WITH SECURITY_ENFORCED order by name asc LIMIT 100]){
                ProgramOptions progOptions = new ProgramOptions();
                if(cp.Core_MDF_Technical_Program_Name__c != null && cp.Core_MDF_Technical_Program_Name__c != '' && cp.name !=null && cp.name != ''){
                    
                    progOptions.progname = cp.name;
                    progOptions.progApiName = cp.Core_MDF_Technical_Program_Name__c;
                    progOptions.progId = cp.Id;
                
                	progOpt.add(progOptions);
                }
                
            }
             PrgrmUsrDataWrapper.programDetailsList = progOpt;
             
        }catch(exception error){Core_MDF_CCP_UtilityClass.logError(error);}  
        
        return PrgrmUsrDataWrapper;
    }
    
    //wrapper - List<ProgramOptions> and isUserExternal
    public class ProgramUserDataWrapper {
         @AuraEnabled public List<ProgramOptions> programDetailsList { get; set; }
         @AuraEnabled public Boolean isUserExternal { get; set; } 
    }
    //wrapper - List<Core_MDF_RecoveryFilters.AccountOptions> and isUserExternal
    public class AccountUserDataWrapper {
         @AuraEnabled public List<Core_MDF_RecoveryFilters.AccountOptions> accountDetailsList { get; set; }
         @AuraEnabled public Boolean isUserExternal { get; set; } 
    }
    //wrapper - List<ProgramOptions> and isExternal
    public class ProgramOptions {
        @AuraEnabled public String progname { get; set; }
        @AuraEnabled public String progApiName { get; set; } 
        @AuraEnabled public String progId { get; set; } 
        @AuraEnabled public Boolean isExternal { get; set; } 
    }
}