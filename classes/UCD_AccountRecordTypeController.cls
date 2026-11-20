public with sharing class UCD_AccountRecordTypeController {
    
    @AuraEnabled
    public static List<AccountRecordTypeWrapper> fetchAccountRecordTypes() {
        
        try{
            Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
            String rejectedAccount = 'Rejected_Account';
            List<AccountRecordTypeWrapper> accRecTypeWrapList = new List<AccountRecordTypeWrapper>();
            Id defaultRecordType;
            String sbrRecordValue = 'Intel_SBR';
            Boolean sbrAccess = FeatureManagement.checkPermission('SBR_Profile_Access');
                
            List<Id> recordTypeIdList = new List<Id>();
	    Schema.DescribeSObjectResult accDescribe = Account.SObjectType.getDescribe();
	    Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = accDescribe.getRecordTypeInfosByName();
            for(RecordTypeInfo info: recordTypeInfoMap.values()) {
                if(info.isAvailable() && !(info.isMaster()) && (Info.getDeveloperName() != rejectedAccount)) {
                    recordTypeIdList.add(info.getRecordTypeId());
                } 
                
                if(info.isDefaultRecordTypeMapping() && !sbrAccess) {
                    defaultRecordType = info.getRecordTypeId();
                }
                
            }
            if(sbrAccess) {
                accRecTypeWrapList.add(new AccountRecordTypeWrapper('1', 'New Account', sbrRecordValue, 'Any new accounts will go through the request process', true));
            }  
            
            if(!recordTypeIdList.isEmpty()) {

                if (Schema.sObjectType.RecordType.fields.Name.isAccessible() && 
                    Schema.sObjectType.RecordType.fields.DeveloperName.isAccessible() &&
                    Schema.sObjectType.RecordType.fields.Description.isAccessible()){

                    for(RecordType recType :  [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Account' AND Id IN : recordTypeIdList ORDER BY Name ASC]){
                        if (recType.Id == defaultRecordType && accRecTypeWrapList.isEmpty()) {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, true));
                        }
                        else if(recType.Id == defaultRecordType) {
                            accRecTypeWrapList.add(0, new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, true));
                        } 
                        else {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, false));
                        }
                    }  
                } 
            }
            
            return accRecTypeWrapList;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_AccountRecordTypeController','fetchAccountRecordTypes','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
            throw new AuraHandledException(ex.getMessage());
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    public class AccountRecordTypeWrapper {
        @AuraEnabled public string recordTypeId{get;set;}
        @AuraEnabled public string recordTypeName{get;set;}
        @AuraEnabled public Boolean checked{get;set;}
        @AuraEnabled public string recordTypeValue{get;set;}
        @AuraEnabled public string description{get;set;}
        
        public AccountRecordTypeWrapper(string recordTypeId, string recordTypeName, string recordTypeValue, string description, Boolean checked) {
            this.recordTypeId = recordTypeId;
            this.recordTypeName = recordTypeName;
            this.checked = checked;
            this.recordTypeValue = recordTypeValue;
            this.description = description;
        }
    }
}