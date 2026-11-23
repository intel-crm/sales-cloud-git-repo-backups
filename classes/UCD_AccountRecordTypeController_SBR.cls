public with sharing class UCD_AccountRecordTypeController_SBR {

    @AuraEnabled
    public static List<AccountRecordTypeWrapper> fetchAccountRecordTypes() {

        try {
                String rejectedAccount = 'Rejected_Account';
                List<AccountRecordTypeWrapper> accRecTypeWrapList = new List<AccountRecordTypeWrapper>();
                Id defaultRecordType;
                List<Id> recordTypeIdList = new List<Id>();
                for(RecordTypeInfo info: Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && !(info.isMaster()) && (Info.getDeveloperName() != rejectedAccount)) {
                        recordTypeIdList.add(info.getRecordTypeId());
                    } 

                    if(info.isDefaultRecordTypeMapping()) {
                        defaultRecordType = info.getRecordTypeId();
                    }
                }

                if(!recordTypeIdList.isEmpty()) {
                    for(RecordType recType :  [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Account' AND Id IN : recordTypeIdList ORDER BY Name ASC]){
                        if (recType.Id == defaultRecordType && accRecTypeWrapList.isEmpty()) {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, true));
                        }
                        else if(recType.Id == defaultRecordType) {
                            accRecTypeWrapList.add(0, new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, true));
                        } else {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, false));
                        }
                    }
                }

                return accRecTypeWrapList;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_AccountService','fetchAccountRecordTypes','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
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