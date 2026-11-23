/****************************************************************************************************
Apex Class Name : Core_Batch_DDR_NotifyApprover_Test
Version         : 1.0 
Created Date    : 11/06/2017
Function        : This Scheduler class is used to schedule the batch apex 'Core_Batch_DDR_NotifyApprover'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajadinakaran             11/06/2017             Created
*****************************************************************************************************/
@isTest
public class Core_Batch_DDR_NotifyApprover_Test
{

    public static testmethod void NotifyApprover_Test1()
    {
        
        //Create account records
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        List<contact> LstCon = Core_Test_Utility.createContacts(5);
        for(contact con: LstCon)
        {
            con.accountid = LstAcc[0].id;
        }
        insert LstCon;
        /* 
        Id p = [select id from profile where name='Partner'].id;       
        User userRecord = new User(
        Alias = 'StdUser', 
        Email = 'newuser@disti4.com', 
        EmailEncodingKey ='UTF-8',
        LastName = 'Testing', 
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles', 
        UserName = 'newuser@disti4.com',
       
        isActive = true, profileid = P, ContactId = LstCon[0].id
        ); 
        
        insert userRecord;      
        */
        for(Account accountInstance: lstAcc)
        {
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'OR';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
        }
    
        //update account records billing location to match with the ISR mapping custom setting values
        update lstAcc;
        
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'Core_DDR_Approver_PSG_USA_Oregon', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
          
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
        
        for(Core_Design_Registration__c iDR : TestDDRlst)
        {
            iDR.Core_Approver_Grp_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon';
            iDR.Core_Partner_Account_Id__c = lstAcc[0].Id;
            iDR.Core_End_Customer_Account_Id__c = LstAcc[1].id;
        }
        
        insert TestDDRlst;
      
        Test.StartTest();

        Core_Batch_DDR_NotifyApprover objNotifyApprover = new Core_Batch_DDR_NotifyApprover();  
        Database.executeBatch(objNotifyApprover);

        Core_Batch_DDR_NotifyApprover_Scheduler.SchedulerMethod();
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrpWithoutState = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon', Core_State_Cd__c = '');
        insert locationToApproverGrpWithoutState;  
                
        for(Account accountInstance: lstAcc)
        {
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'OR';
            accountInstance.BillingCity = 'Alabama';
            accountInstance.BillingStreet = 'test';
        }

        //update account records billing location to match with the ISR mapping custom setting values
        update lstAcc;

        delete locationToApproverGrp;
        delete TestDDRlst;

        List<Core_Design_Registration__c> TestDDRlst2 = Core_DDR_Utility.createDDR(5);
        insert TestDDRlst2;
        
        for(Core_Design_Registration__c iDR : TestDDRlst2)
        {
            iDR.Core_Approver_Grp_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon';
            iDR.Core_Partner_Account_Id__c = lstAcc[0].Id;
            iDR.Core_End_Customer_Account_Id__c = LstAcc[1].id;
        }
        update TestDDRlst2;
          List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
          List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst2, products2);
        insert TestDDRProd;       
        
        Core_Batch_DDR_NotifyApprover objNotifyApprover2 = new Core_Batch_DDR_NotifyApprover();  
        Database.executeBatch(objNotifyApprover2);    
            
        Test.StopTest();
        
          
    }    
}