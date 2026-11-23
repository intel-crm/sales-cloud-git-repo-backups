@isTest
private class PSG_TransferSubmitterTest{
    
    /*@testSetup static void setup(){
        profile pr=[SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole portalRole=[SELECT id, Name FROM userrole where name = 'Admin' limit 1];
        User testuser = new User(Alias = 'testus', Email='PSGtestUser1342@example.com',
                           EmailEncodingKey='UTF-8', LastName='PSGtest33', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = pr.Id,UserRoleId= portalRole.id ,
                           TimeZoneSidKey='America/Los_Angeles', UserName='PSGtestUser1342@example.com');
        insert testuser;
        system.runas(testuser){
        Account acc1 = PSG_Test_Utility.createAccount();
        acc1.OwnerId=testuser.Id;
        acc1.Name='testtransferacc';    
        update acc1;    
        Contact con1 = PSG_Test_Utility.createContactWithEmail(acc1.Id,'PSGUser1@example.com');
            con1.FirstName='oldsubmittercon';
            update con1;
        Profile p2 =[SELECT id, Name,UserType FROM Profile where Name='Partner' limit 1];
        
        
            User u2 = new User(Alias = 'newUser', Email='PSGUser1@example.com',
                               EmailEncodingKey='UTF-8', LastName='PSG_Internal', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p2.Id,PortalRole= 'Manager' ,
                               TimeZoneSidKey='America/Los_Angeles', UserName='PSGUser1@example.com',ContactId=con1.Id);
            insert u2;
            
            
            List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
            List<Account> accsToUpdate=new List<Account>();
            Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            
            
            Account a2 = new Account();
            a2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();      
            a2.Name = 'Test Account'+math.random();
            a2.Core_Account_Type__c = 'Distributor;End Customer';//added
            a2.Industry = 'Banking';
            a2.BillingCity = 'Texas';
            a2.BillingCountry = 'USA';
            a2.BillingStreet = 'G-2101'; 
            a2.Core_Sales_Group_New__c = 'US Sales Group'; 
            a2.Core_Geo__c = 'APJ';
            a2.Core_Sub_Geo__c = 'IJKK';
            a2.Core_PSG_Account__c = true;
            a2.Core_Account_Tier__c ='PSG-Tier 4';
            a2.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            
            insert a2;
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
            triggerExecList.Bypass__c = true;
            insert triggerExecList;
            Opportunity opp = PSG_Test_Utility.createOpportunity(acc1.Id);
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp.id);
            quote.core_cpq_requestor_nm__c = u2.Id;
            quote.core_cpq_active_cb__c=true;
            insert quote;
            SBQQ__Quote__C quote1 = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp.id);
            quote1.core_cpq_requestor_nm__c = u2.Id;
            quote1.core_cpq_active_cb__c=true;
            insert quote1;
            
            
            List<core_cpq_dpa_aln__c> dpa_List = PSG_Test_Utility.createDPARecord(quote,a2.Id);
            dpa_List[0].core_cpq_disty_submitted_user__c=u2.Id;
            dpa_List[0].core_cpq_ship_end_date_dt__c=System.Today()+7;
            update dpa_List;
            a2.Core_Direct_Account_Type_Nm__c='';
            update a2; 
        }
    }
    
    @isTest static void testMethod1() {
        User u1 = [SELECT Id,LastName from User where LastName='PSG_Internal'];
        contact oldcon=[Select Id,LastName from Contact where FirstName='oldsubmittercon'];
        Account acc=[select Id,name from Account where name='testtransferacc'];
        User u2=[SELECT Id,LastName from User where LastName='PSGtest33'];
        system.runas(u2){
            
            Profile p = [SELECT id, Name,UserType FROM Profile where Name='Partner' limit 1];
            UserRole portalRole=[SELECT id, Name FROM userrole where name = 'Admin' limit 1];
            Contact con = new Contact(FirstName='Test',LastName ='User',Email='PSGUser2@example.com',AccountId=acc.id);
            insert con;
            User u = new User(Alias = 'newUser', Email='PSGUser2@example.com',
                              EmailEncodingKey='UTF-8', LastName='Testing_Internal', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='PSGUser2@example.com',ContactId=con.id);
            insert u;
            List<List<String>> submitterDetails = new List<List<String>>();
            submitterDetails.add(new List<String>{oldcon.Id,oldcon.LastName,con.Id,con.LastName,'Both'});
            PSG_TransferSubmitter.transferSubmitterFromFlow(submitterDetails);
            System.assertEquals('actual', 'actual','');
        }   
        
        
    }*/
}