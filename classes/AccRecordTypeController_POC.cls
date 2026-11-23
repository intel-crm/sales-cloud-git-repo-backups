public with sharing class AccRecordTypeController_POC {
    
    @AuraEnabled
    public static List<AccountRecordTypeWrapper> fetchAccountRecordTypes() {

            try {
                List<AccountRecordTypeWrapper> accRecTypeWrapList = new List<AccountRecordTypeWrapper>();
                List<Id> recordTypeIdList = new List<Id>();
                for(RecordTypeInfo info: Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && !(info.isMaster())) {
                        recordTypeIdList.add(info.getRecordTypeId());
                    }
                }

                if(!recordTypeIdList.isEmpty()) {
                    for(RecordType recType :  [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Account' AND Id IN : recordTypeIdList]){
                        if(accRecTypeWrapList.isEmpty()) {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, true));
                        } else {
                            accRecTypeWrapList.add(new AccountRecordTypeWrapper(recType.Id, recType.Name, recType.DeveloperName, recType.Description, false));
                        }
                    }
                }

                return accRecTypeWrapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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