public class UCD_StateMappingBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    //Id inactiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
    Map<String,Core_ACM_Control_Execution__c> mapFunctionalityMdmAddressSwitch = Core_ACM_Control_Execution__c.getAll(); 
    Map<String, Map<String,String>> stateNameAndCodeByCountry = new Map<String, Map<String,String>>();
    String pending=System.Label.UCD_ACM_Status_Pending;
    String completed=System.Label.UCD_ACM_Status_Completed;
    public UCD_StateMappingBatch() {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Core_Reltio_Address_Status__c,Name,RecordTypeId,
        Core_MDM_Location_State_Nm__c,Core_MDM_Secondary_State_Cd__c,Core_Unified_Customer_Address__CountryCode__s,
        Core_Customer_Aggregation_Type__c,Core_Unified_Customer_Address__Street__s,Core_Unified_Customer_Address__City__s,
        Core_Unified_Customer_Address__PostalCode__s
        FROM Account WHERE Core_Reltio_Address_Status__c = :pending AND (RecordTypeId=:UCD_ACM_ConstantUtil.acctRTIntel OR RecordTypeId=:UCD_ACM_ConstantUtil.acctRTInactive)]);
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        Map<Id,Account> accMapForStateUpdate = new Map<Id,Account>();
        try{           
            if(accounts.size()>0){            
                if(stateNameAndCodeByCountry.isEmpty()) {
                    stateNameAndCodeByCountry = UCD_ACM_Utils.getGlobalPickList();
                }
                for (Account account : accounts) {
                    if((account.RecordTypeId == UCD_ACM_ConstantUtil.acctRTIntel || account.RecordTypeId == UCD_ACM_ConstantUtil.acctRTInactive)) {
                        String mdmStateCode=(account.Core_Customer_Aggregation_Type__c=='UNFD_GLBL_CUST' ||account.Core_Customer_Aggregation_Type__c=='UNFD_INTRMD_CUST')? account.Core_MDM_Location_State_Nm__c:((account.Core_Customer_Aggregation_Type__c == 'UNFD_CTRY_CUST' || account.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST') ? account.Core_MDM_Secondary_State_Cd__c:null);  
                        if(String.isNotBlank(mdmStateCode) && mdmStateCode.contains('_') && String.isNotBlank(account.Core_Unified_Customer_Address__CountryCode__s) && stateNameAndCodeByCountry.get(String.valueOf(account.Core_Unified_Customer_Address__CountryCode__s))?.get(String.valueOf(mdmStateCode.split('_')[1])) != null) {
                            account.Core_Unified_Customer_Address__StateCode__s = mdmStateCode.split('_')[1];  
                        }
                        else{
                            account.Core_Unified_Customer_Address__StateCode__s=null;
                        }
                        if (mapFunctionalityMdmAddressSwitch.containsKey('MapReltioAddressToPrimaryAddress') && mapFunctionalityMdmAddressSwitch.get('MapReltioAddressToPrimaryAddress').IsActive__c) {
                            setPrimaryAddress(account);
                        }
                        account.Core_Reltio_Address_Status__c = completed;
                        accMapForStateUpdate.put(account.Id,account);
                    }
                    UCD_ACM_Logger.information('UCD_StateMappingBatch','execute','account: ' + account.Id + ' STATE: ' + account.Core_MDM_Location_State_Nm__c + ' /' + account.Core_MDM_Secondary_State_Cd__c + ' COUNTRY : ' + account.Core_Unified_Customer_Address__CountryCode__s,null);
                }       
                Database.update(accMapForStateUpdate.values(),false);     
            }
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_StateMappingBatch','Execute','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+'AccountIds: '+ accMapForStateUpdate.keySet(),NULL);
        }finally{
            UCD_ACM_Logger.setLogDetails(); 
        }
    }

    public void finish(Database.BatchableContext BC) {
           
    }

    private void setPrimaryAddress(Account account){
        account.BillingStreet=account.Core_Unified_Customer_Address__Street__s;
        account.BillingCity=account.Core_Unified_Customer_Address__City__s;
        account.BillingStateCode=account.Core_Unified_Customer_Address__StateCode__s;
        account.BillingPostalCode=account.Core_Unified_Customer_Address__PostalCode__s;
        account.BillingCountryCode=account.Core_Unified_Customer_Address__CountryCode__s;
    }
}