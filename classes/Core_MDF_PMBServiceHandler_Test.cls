/***************************************************************************************************************************************
* Class Name  : Core_MDF_PMBServiceHandler_Test
* Version     : 1.0 
* Created Date: 09-04-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-JV                    09/04/2018                    Created to test Partner Marketing Budget functionality. 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PMBServiceHandler_Test {
    //setup method to create test data
    @TestSetup static void setUpData(){

        
        
        // Creating Intel Account with utility class
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street';
        Database.insert(accRecord);   

        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,true);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accRecord.Id,true);

        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        Database.insert(usr1);
        
       
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        // Creating Intel Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        acc1.BillingCity = 'Test City';         
        acc1.BillingCountry= 'AUS';
        acc1.BillingStreet= 'Test Street';
        Database.insert(acc1);      
        
        Test.startTest();
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        Database.insert(acc);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        Database.insert(acc2);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 3', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc3.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        Database.insert(acc3);
        Test.stopTest();
        
         User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='financeManager@example.com';
        //usr2.ContactId = conRecord2.Id;
        //usr2.ProfileId = profileId;
        Database.insert(usr2);
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit1',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today()-1,System.today()-1,true);
        
    }
    // Test method tp fetch and delete the created PNUM Records
    @isTest static void createanddeletePNUMRecords(){
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            // Create a Partner Node User Mapping with the above created Account
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(15),true);
            try{
                
                PartnerMarketingBudget  pmbClonedRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(1),System.today().addDays(16),true);
                pmbClonedRecord.EndDate = System.today().addDays(15);
                Database.update(pmbClonedRecord);
                
            }catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PMBOverlapError));
            } 
            try{
                
                PartnerMarketingBudget  pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),true);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Approved';
            }catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PMBOverlapError));
            } 
        }        
    }
    
     // Test method tp fetch and delete the created PNUM Records
    @isTest static void validateDecreasedBudgetAmountOnChange(){
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        PartnerMarketingBudget  pmbRecordtobeUpdated = new PartnerMarketingBudget();
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                
                pmbRecordtobeUpdated = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc1.Id,cp.Id,123456,System.today().addDays(2),System.today().addDays(15),true);
                List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
                pmbList.add(pmbRecordtobeUpdated);
                Core_MDF_PMBServiceHandler.invokeBudgetShareRecordToGeoGroup(pmbList);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));
            } 
        }
        User financeManager = [SELECT Id,Email from User where Email='financeManager@example.com' limit 1];
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Manager'];
        insert new PermissionSetAssignment(AssigneeId = financeManager.id, PermissionSetId = ps.Id ); 
        System.runAs(financeManager){
            try{
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Approved';
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Released';
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Decrease_Budget_Amount_Amt__c  = 1234565;
                Database.update(pmbRecordtobeUpdated);
                pmbRecordtobeUpdated.Core_MDF_Budget_Status__c = 'Approved';
                Database.update(pmbRecordtobeUpdated);
            }catch(Exception e){
                String errorMessage = e.getMessage();
            }
        }
    }
    
    //Test method to check duplicate budget
    @isTest static void validateDuplicateBudgetOnCreate(){
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc = [SELECT Id from Account where Name='Test Account 1' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudget',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),System.today(),true);
                Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudget1',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),System.today(),true);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));  
            }
        }        
    }
      //Test method to check duplicate budget on update
        @isTest static void validateDuplicateBudgetOnUpdate(){
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account acc3 = [SELECT Id from Account where Name='Test Account 3' limit 1];
        ChannelProgram cp = [Select id from ChannelProgram limit 1];
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        System.runAs(usr){
            try{
                Core_MDF_CCP_TestDataUtility.createBudget('TestDupBudgetNewForEdit',RecordTypeIdPMB,acc3.Id,cp.Id,123456,System.today(),System.today(),true);
                PartnerMarketingBudget  pmbRecordtobeUpdated= [Select Id, Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='TestDupBudgetNewForEdit1' LIMIT 1];
                pmbRecordtobeUpdated.StartDate = System.today();
                pmbRecordtobeUpdated.EndDate = System.today();
                Database.update(pmbRecordtobeUpdated);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                System.assert(errorMessage.contains(System.Label.Core_MDF_PMBDuplicateError));  
            }
        }        
    }  
}