/*********************************************************************************************************************
Apex Class Name  : UCD_AccountDuplicate
Version       : 1.0
Created Date  : Sep 2020
Function      : It will show mutiple accounts under single CIM ID
*********************************************************************************************************************/
public without sharing class UCD_AccountDuplicate {
    public static final string LOG_ENTRY_ORIGIN = 'UCD_AccountDuplicate';
    public static final String LOG_ENTRY_PROJECT = 'ACM';
    public static final String LOG_ENTRY_SCOPE = 'ACM Utility';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Account';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static string LOG_ENTRY_SEVERITY;
    public static string LOG_ENTRY_Message;
    public static boolean hasError = false; 
    public static Exception exceptionObj = null;
    public static Map<String,Core_ACM_Control_Execution__c> mapFunctionalityAcmAppSwitch = Core_ACM_Control_Execution__c.getAll();


    /* This method returns list of regirons */
    @AuraEnabled
    public static  List<AggregateResult> getRegionListSort(String regValue){
       List<AggregateResult> regionData = new List<AggregateResult>();
        Id IntelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) {
            try{    
            if (Schema.sObjectType.Account.fields.Core_Geo__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Core_CIM_ID__c.isAccessible()){
                    
                        regionData = [SELECT Core_Geo__c,Core_CIM_ID__c,COUNT(Id) AccountCount FROM Account 
                        WHERE Core_CIM_ID__c != null and Core_Geo__c =:regValue and Core_Geo__c != null 
                        AND recordtypeId =:IntelRecordTypeId
                        GROUP BY Core_Geo__c, Core_CIM_ID__c 
                        HAVING COUNT(Id)>1 
                        ORDER BY COUNT(Id) DESC
                        LIMIT 10];   
                }
                Account a = new account();
                insert a;
        }
            catch(Exception ex) {
                exceptionObj = ex;
                hasError = true;
            }
            finally {
                string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
                string LOG_ENTRY_Message = 'Region list';
                //Creating a Log Entry record
                Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                    LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);                                                

            }
      }    
        return regionData;  
    }
    
    /* This method returns count of region records for Home Page comp */
    @AuraEnabled
    public static  List<AggregateResult> getRegionHome(String regValue){
        Id IntelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<AggregateResult> regionData  = new List<AggregateResult> ();
        if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) {
            try{
                if (Schema.sObjectType.Account.fields.Core_Geo__c.isAccessible() &&
                    Schema.sObjectType.Account.fields.Core_CIM_ID__c.isAccessible()){
                    regionData = [SELECT Core_Geo__c,Core_CIM_ID__c,COUNT(Id) AccountCount FROM Account 
                                                    WHERE Core_CIM_ID__c != null and Core_Geo__c =:regValue and Core_Geo__c != null 
                                                    AND recordtypeId =:IntelRecordTypeId
                                                    GROUP BY Core_Geo__c, Core_CIM_ID__c 
                                                    HAVING COUNT(Id)>1 
                                                    ORDER BY COUNT(Id) DESC
                                                    ];   
                }
        
            }catch(Exception ex) {
                exceptionObj = ex;  
                hasError = true;
            }
            finally {
                string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
                string LOG_ENTRY_Message = 'Get Region Home';
                //Creating a Log Entry record
                Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                    LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);                                                
            }
        }
        return regionData;  
    }
    
    
  /* This method returns account details against CIM id */
    @AuraEnabled
    public static List<account> getAccountsForCim(String cimId){
    List<Account> acctList = new List<Account>();
    List<Account> sortList = new List<Account>();          
    Id IntelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) { 
        try{
            if (Schema.sObjectType.Account.fields.Name.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_CIM_ID__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Account_Legal_Name__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Prime_Account_Name__c.isAccessible() && 
            Schema.sObjectType.Account.fields.OwnerId.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Geo__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Intel_Partner_Alliance_PartnerGroup__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Sales_Groups__c.isAccessible() &&
            Schema.sObjectType.Account.fields.Core_Account_Type__c.isAccessible()){

                for(Account dup:[SELECT id, name, (SELECT Id FROM contacts), Core_CIM_ID__c, Core_Account_Legal_Name__c, 
                                    Core_Prime_Account_Name__c, Owner.Name, Core_Geo__c, Core_Intel_Partner_Alliance_PartnerGroup__c, 
                                    Core_Sales_Groups__c, Core_Account_Type__c 
                                    FROM account 
                                    WHERE Core_CIM_ID__c =:cimId AND recordtypeId =:IntelRecordTypeId]){       
                    if(cimId == dup.Core_CIM_ID__c && dup.Owner.Name != 'Uncovered Account'){
                        acctList.add(dup);
                    }
                    else if(cimId == dup.Core_CIM_ID__c && dup.Owner.Name == 'Uncovered Account'){
                        sortList.add(dup);
                    }
                }
            }
            if(sortList.size()>0){
                acctList.addall(sortList);
            }       
        }catch(Exception ex) {
            exceptionObj = ex;
            hasError = true;
        }
        finally {
            string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
            string LOG_ENTRY_Message = 'Accounts for CIM';
            //Creating a Log Entry record
            Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);                                                
        }
    }
    return acctList; 
    }
        /* Export excel logic starts here */
    public class AccountWrapper{  
    @AuraEnabled  
    public string Name;  
    @AuraEnabled  
    public string Owner; 
    @AuraEnabled  
    public Boolean IPA;
    @AuraEnabled  
    public string SalesGroup;
    @AuraEnabled  
    public string CIMID;
    @AuraEnabled  
    public string AccountId;    
    public AccountWrapper(Account accountObj){  
           this.Name = accountObj.Name;  
           this.Owner = accountObj.Owner.Name;
           this.IPA = accountObj.Core_Intel_Partner_Alliance_PartnerGroup__c;
           this.SalesGroup= accountObj.Core_Sales_Groups__c;
           this.CIMID = accountObj.Core_CIM_ID__c;
           this.AccountId = accountObj.id;
        }  
    }  
    @AuraEnabled
    public static List<AccountWrapper> getAccounts(String region){ 
    String regionvalue = region;
    Id IntelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    List<AccountWrapper> accounWrapperList = new List<AccountWrapper>();
    set<string> cimID = new set<string>();
    List<AggregateResult> regionID = new List<AggregateResult>();
    if (mapFunctionalityAcmAppSwitch.containsKey('SwitchAcmApp') && mapFunctionalityAcmAppSwitch.get('SwitchAcmApp').IsActive__c) {
        try{
            if (Schema.sObjectType.Account.fields.Core_Geo__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Core_CIM_ID__c.isAccessible()){
                    regionID = [SELECT Core_Geo__c,Core_CIM_ID__c,COUNT(Id) AccountCount FROM Account 
                                                WHERE Core_CIM_ID__c != null AND Core_Geo__c =: regionvalue
                                                AND recordtypeId =:IntelRecordTypeId
                                                GROUP BY Core_Geo__c, Core_CIM_ID__c 
                                                HAVING COUNT(Id)>1 
                                                ]; 
                
                }
                for(AggregateResult reg: regionID)
                {
                    cimID.add(string.valueOf((reg.get('core_cim_id__c'))));
                }       
            
                if (Schema.sObjectType.Account.fields.Core_CIM_ID__c.isAccessible() &&
                Schema.sObjectType.Account.fields.Name.isAccessible()  &&
                Schema.sObjectType.Account.fields.Core_Intel_Partner_Alliance_PartnerGroup__c.isAccessible()  &&
                Schema.sObjectType.Account.fields.Core_Sales_Groups__c.isAccessible()  &&
                Schema.sObjectType.Account.fields.OwnerId.isAccessible()  ){
            
                    for(Account acObj : [select Core_CIM_ID__c, Name,id, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Sales_Groups__c,Owner.Name 
                                    from Account where Core_Geo__c =:regionvalue AND Core_CIM_Id__c =:cimID AND recordtypeId =:IntelRecordTypeId Limit 50000]){
                    
                                accounWrapperList.add(new AccountWrapper(acObj)); 
                    
                    }
                }
        
        }catch(Exception ex) {
                exceptionObj = ex;  
                hasError = true;
        }
        finally {
                string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
                string LOG_ENTRY_Message = 'Get Accounts for Dowload Csv';
                //Creating a Log Entry record
                Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                    LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);                                                
        }
    }         
    return accounWrapperList;  
    } 

        /* Export excel logic ends here */
}