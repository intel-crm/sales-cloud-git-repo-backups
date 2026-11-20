@IsTest private class ReltioSyncAccountBusinessTypesTest { 
    
    @TestSetup
    private static void setCommonData(){
        Account reltioAccount = createAccount('TestReltioAccount');
        insert reltioAccount;
        
        Business_Types__c businessType = createBusinessType();
    }
    
    private static Account createAccount(String accountName){
        Account acc = new Account();
        acc.Name = accountName;
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.BillingCountryCode  = 'IND';
        acc.BillingCity = 'TestCity';
        acc.BillingStreet = 'TestStreet';
        acc.Core_Business_Party_Id__c = 'TestBusinessPartyId';
        return acc;
            
    }
    
    private static Business_Types__c createBusinessType(){
        Business_Types__c businessType = new Business_Types__c(Name='Direct Price Exception',Is_Active__c=true,Business_Type_Code__c='DIR_PRC_EXCPT');
        insert businessType;
        return businessType;
    }
    
    @IsTest static void testBehavior() { 
            //String accName='TestReltioAccount';
            Account account = [SELECT Id,Name FROM Account WHERE Name='TestReltioAccount' LIMIT 1];
            //String busTypeCode='DIR_PRC_EXCPT';
            Business_Types__c busType = [SELECT Id,Name FROM Business_Types__c WHERE Business_Type_Code__c='DIR_PRC_EXCPT' LIMIT 1];
            //Test.startTest();
            //insert new Account_Business_Types__c( 
               // Account__c = account.Id,
               // Business_Types__c = busType.Id
                //); 
            //Test.stopTest();
    } 
    
   
    
}