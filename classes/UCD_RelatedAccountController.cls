public with sharing class UCD_RelatedAccountController {

    @AuraEnabled(cacheable=true)
    public static AccountDetailsWrap fetchRelatedAccounts(Id accountChangeReviewId) {
        //try {
                List<Account> accounts = new List<Account>();
                AccountDetailsWrap accountDetailsWrap = new AccountDetailsWrap();

                String accountChangeReviewQuery = 'SELECT Id, New_Unified_ID__c FROM UCD_Account_Change_Review__c WHERE Id = \'' + accountChangeReviewId + '\'';
                UCD_Account_Change_Review__c acrRecord = Database.query(accountChangeReviewQuery);
                
                String accountQuery = 'SELECT Id, Name, Core_Data_Simplified_Account_Nm__c, Core_Business_Party_Id__c, Core_Customer_Aggregation_Type__c, Parent.Name FROM Account WHERE Core_Business_Party_Id__c = \'' + acrRecord.New_Unified_ID__c + '\'';

                if(Account.SObjectType.getDescribe().isAccessible()) {  
                    accounts = Database.query(accountQuery);
                }

                if(!accounts.isEmpty()) {
                    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
                    List<AccountDetail> accountDetails = new List<AccountDetail>();

                    for(Account accountRecord : accounts) {
                        AccountDetail accountInfo = new AccountDetail();
                        List<FieldDetail> fieldDetails = new List<FieldDetail>();
                        
                        accountInfo.accId = accountRecord.Id;
                        accountInfo.accName = accountRecord.Name;
                        
                        FieldDetail fieldDetail1 = new FieldDetail(fieldMap.get('Core_Data_Simplified_Account_Nm__c').getDescribe().getLabel(), accountRecord.Core_Data_Simplified_Account_Nm__c);
                        FieldDetail fieldDetail2 = new FieldDetail(fieldMap.get('Core_Business_Party_Id__c').getDescribe().getLabel(), accountRecord.Core_Business_Party_Id__c);
                        FieldDetail fieldDetail3 = new FieldDetail(fieldMap.get('Core_Customer_Aggregation_Type__c').getDescribe().getLabel(), accountRecord.Core_Customer_Aggregation_Type__c);
                        FieldDetail fieldDetail4 = new FieldDetail('Parent Name', accountRecord.Parent.Name);
                        
                        fieldDetails.add(fieldDetail1);    
                        fieldDetails.add(fieldDetail2);
                        fieldDetails.add(fieldDetail3);
                        fieldDetails.add(fieldDetail4);

                        accountInfo.fieldDetails = fieldDetails;
                        accountDetails.add(accountInfo);
                    }

                    accountDetailsWrap.accountDetails = accountDetails;
                    accountDetailsWrap.count = accounts.size();
                }

            return accountDetailsWrap;

        //} catch (Exception e) {
            //todo handle exception 
        //    throw new AuraHandledException(e.getMessage());
        //}
    }

    
    public class AccountDetailsWrap {
        @AuraEnabled public List<AccountDetail> accountDetails{get;set;}
        @AuraEnabled public Integer count{get;set;}
    }  

    public class AccountDetail {
        @AuraEnabled public List<FieldDetail> fieldDetails{get;set;}
        @AuraEnabled public string accId{get;set;}
        @AuraEnabled public string accName{get;set;}
    }

    public class FieldDetail {
        @AuraEnabled public string fieldLabel{get;set;}
        @AuraEnabled public string fieldValue{get;set;}
        
        public FieldDetail(string label, string value) {
            this.fieldLabel = label;
            if(value != null) {
                this.fieldValue = value;
            } else {
                this.fieldValue = ''; 
            }
        }
    }
}