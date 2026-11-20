@isTest
private class PartnerCenter_Redirect_Test{
    //getting the current Session
    Public static testMethod void testCurrentSession(){
        try {
            test.startTest();
            
           /* Id profileId = [select id from profile where name='Partner'].id;//getting the partner profile id
            //Creating a new Account
            Account account = new Account(Name ='RaushanTest',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',Industry='Agriculture',  BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi') ;
            insert account;
            //Creating a new Contact
            Contact contact = new Contact(FirstName = 'Raushan',LastName ='testCon',AccountId = account.Id,Email='dellco123@dell.com');
            insert contact;
            //Creating a new partner user
            User commUser = new User(alias = 'raun0', emailencodingkey='UTF-8', lastname='Rtesting', languagelocalekey='en_US',
                                     localesidkey='en_US',Email='dellco123@dell.com', profileid = profileId,IsActive =true,ContactId = contact.Id,timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            
            System.runAs(commUser){
                String sessionTypeValue = PartnerCenter_Redirect.getCurrentSession();
            }*/
            
            
            System.runAs(new user(ID = UserInfo.getUserID())){
                String sessionTypeValue = PartnerCenter_Redirect.getCurrentSession();
            }
            test.stopTest();
            
        }catch (Exception e){
            System.debug(e.getMessage());  
        }
    }
}