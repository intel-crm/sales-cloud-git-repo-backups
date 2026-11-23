/******************************************************************************************************************************
Apex Class Name  : PRM_CSA_Utility_Test
Version       : 1.0 
Created Date  : 10 Dec 2018
Created By    : Anupam Agarwal
Function      : Test Class for PRM_CSA_Utility Class
*******************************************************************************************************************************/
@istest
public class PRM_CSA_Utility_Test {
    static testmethod void testduplicateRecordCheck(){
        Test.startTest();
            Account newAccount = new Account();//Account
            newAccount.Name='John Rick';
            newAccount.BillingCity='City';
            newAccount.BillingStreet='Street';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code';
            
            
            insert newAccount;
            
            Contact cont = new Contact();  //Contact
            
            cont.AccountId=newAccount.Id;
            cont.lastName='Grill';
            cont.FirstName='Adam';
            cont.email='AdamGrill@rediff.com';
            cont.Core_Job_Function__c='Branch Manager';
            cont.Core_eRPM_Language_Code__c='Eng';
            insert cont;
            
            PRM_Partner_Subscription__c ps = new PRM_Partner_Subscription__c();
            ps.name = 'Newsletter - ITP';
            ps.PRM_Subscription_Cd__c = 'Gold';
            ps.PRM_Subscription_Type_Nm__c = 'Newsletters - Distributor for Intel Technology Provider';
            insert ps;
            
            PRM_ContactSubscriptionAssociation__c csa = new PRM_ContactSubscriptionAssociation__c();
            csa.PRM_Contact_Id__c = cont.id;
            csa.PRM_Partner_Subscription_Id__c = ps.id;
            csa.PRM_Status_Nm__c = 'Active';
            insert csa;
        try
        {    
            PRM_ContactSubscriptionAssociation__c csa1 = new PRM_ContactSubscriptionAssociation__c();
            csa1.PRM_Contact_Id__c = cont.id;
            csa1.PRM_Partner_Subscription_Id__c = ps.id;
            csa1.PRM_Status_Nm__c = 'Active';
            insert csa1;
        }
        catch(Exception e)
        {
            System.debug('Error Occured');
        }
    Test.stopTest();
        System.assertEquals(csa.PRM_Status_Nm__c,'Active','Value does not match');
    }  
}