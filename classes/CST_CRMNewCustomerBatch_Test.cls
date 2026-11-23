@isTest
public class CST_CRMNewCustomerBatch_Test {
    @TestSetup static void testSetup() {
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='System Administrator'];
        
        SPM_Planning_Period__c pp = new SPM_Planning_Period__c();
        pp.Active__c = true;
        pp.Planning_Period__c = '';
        insert pp;
        
        SPM_Regional_Customer__c regionalView = new SPM_Regional_Customer__c();
        regionalView.Core_Region__c ='United States';
        regionalView.Core_Planning_Period__c = pp.Id;
        regionalView.Stage__c = 'GM';
        insert regionalView;
        
        User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user';
        us1.Email = 'testuser1@intel.com';
        us1.Username = 'testinguser1@inteltest.com';
        us1.Alias = 'testu1';
        us1.CommunityNickname = 'test.userqwert1';
        us1.TimeZoneSidKey = 'America/Los_Angeles';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = pro.Id;
        us1.LanguageLocaleKey = 'en_US';
        insert us1;
        
        User us2 = new User();
        us2.FirstName = 'test2';
        us2.LastName = 'user';
        us2.Email = 'testuser2@intel.com';
        us2.Username = 'testinguser2@inteltest.com';
        us2.Alias = 'testu2';
        us2.TimeZoneSidKey = 'America/Los_Angeles';
        us2.LocaleSidKey = 'en_US';
        us2.EmailEncodingKey = 'UTF-8';
        us2.ProfileId = pro.Id;
        us2.LanguageLocaleKey = 'en_US';
        insert us2;
        
        Id userId = [SELECT Id from User where Email='testuser1@intel.com' limit 1][0].Id;
        
        system.runAs(us1){
            PermissionSet superadmin = [SELECT Id, Name FROM PermissionSet where Name = 'Sales_CRM_CST_Super_Admin'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = superadmin.Id, AssigneeId = userId);
            insert psa;
        }
        Core_CRM_Labels__c cust1 = new Core_CRM_Labels__c();
        cust1.name = 'CST_CRMAccounUpdateBatchSize';
        cust1.value__c = '200';
        insert cust1;
        
        SPM_Regional_Customer__c rc = new SPM_Regional_Customer__c();
        rc.Core_Region__c = 'EMEA';
        rc.Stage__c = 'DR';
        insert rc;
        
        Id rcId = [select id from SPM_Regional_Customer__c limit 1][0].Id;
        
        SPM_Customer_Detail__c cd = new SPM_Customer_Detail__c();
        cd.Coverage__c='Intel Covered';
        cd.Core_Regional_Customer_Id__c = rcId;
        cd.SPM_Customer_Name__c='TestCST';
        insert cd;
        
        SPM_Customer_Detail__c cd2 = new SPM_Customer_Detail__c();
        cd2.Coverage__c='Intel Covered';
        cd2.Core_Regional_Customer_Id__c = rcId;
        cd2.SPM_Customer_Name__c='TestCST2';
        insert cd2;
        
        SPM_Customer_Detail__c cd3 = new SPM_Customer_Detail__c();
        cd3.Coverage__c='Intel Covered';
        cd3.Core_Regional_Customer_Id__c = rcId;
        cd3.SPM_Customer_Name__c='TestCST3';
        insert cd3;
        
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        
        SPM_Customer_Category__c cc = new SPM_Customer_Category__c();
        cc.Customer_Detail__c = cstId;
        cc.Coverage__c = 'Intel Covered';
        insert cc;
        
        Id AccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        Account a = new Account(Name = 'TestAccount', BillingStreet = '123 Fake St', RecordTypeId = AccountRecTypeId,
                                BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a;
        }
        Account a1 = new Account(Name = 'TestAccount1', BillingStreet = '123 Fake St', RecordTypeId = AccountRecTypeId,
                                 BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                 BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a1;
        }
        Account a2 = new Account(Name = 'TestAccount2', BillingStreet = '123 Fake St', RecordTypeId = AccountRecTypeId,
                                 BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                 BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a2;
        }
        
        Account a3 = new Account(Name = 'TestAccount3', BillingStreet = '123 Fake St', RecordTypeId = AccountRecTypeId,
                                 BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                 BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a3;
        }
        Account a4 = new Account(Name = 'TestAccount4', BillingStreet = '123 Fake St', RecordTypeId = AccountRecTypeId,
                                 BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                 BillingPostalCode = '12345', Core_Sales_Groups__c='Americas US Sales Group');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert a4;
        }
        Id sfAcctId = [select id from Account where Name='TestAccount' limit 1][0].Id;
        
        SPM_Account_Detail__c ad = new SPM_Account_Detail__c();
        ad.Coverage_Type__c='Intel Covered';
        ad.DR__c = userId;
        ad.VP__c = userId;
        ad.GM__c = userId;
        ad.SPM_Customer_ID__c =cstId;
        ad.SF_Account__c=sfAcctId;
        insert ad;
        Id sfAcctId1 = [select id from Account where Name='TestAccount1' limit 1][0].Id;    
        Id cst2Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c where SPM_Customer_Name__c='TestCST2' limit 1][0].Id;   
        
        
        SPM_Account_Detail__c ad1 = new SPM_Account_Detail__c();
        ad1.Coverage_Type__c='Intel Covered';
        ad1.DR__c = userId;
        ad1.VP__c = userId;
        ad1.GM__c = userId;
        ad1.SPM_Customer_ID__c =cst2Id;
        ad1.SF_Account__c=sfAcctId1;
        insert ad1;
        
        Id sfAcctId3 = [select id from Account where Name='TestAccount3' limit 1][0].Id; 
        Id cst3Id = [select id,SPM_Customer_Name__c from SPM_Customer_Detail__c where SPM_Customer_Name__c='TestCST3' limit 1][0].Id; 
        
        SPM_Account_Detail__c ad3 = new SPM_Account_Detail__c();
        ad3.Coverage_Type__c='Intel Covered';
        ad3.DR__c = userId;
        ad3.VP__c = userId;
        ad3.GM__c = userId;
        ad3.SPM_Customer_ID__c =cst3Id;
        ad3.SF_Account__c=sfAcctId3;
        insert ad3;
        
    }
    
    
    @isTest static void updateAccountWithCustomerTest(){ 
        User userRec = [SELECT Id,Email from User where Email='testuser1@intel.com' limit 1][0];
        Id cstId = [select id from SPM_Customer_Detail__c limit 1][0].Id;
        CST_CRMNewCustomerBatch_Test.customMetadata  = (List<CST_New_Customer_Account_Sync__mdt>) JSON.deserialize( '[{"New_Customer_Value__c ":"Distributors (IA)","Active__c":"true","Account_Value__c":"Distributors (IA)"},{"New_Customer_Value__c ":"Reseller - Named Billing Accounts","Active__c":"true","Account_Value__c":"Reseller - Named Billing Accounts"},{"New_Customer_Value__c ":"Solution Enabler (SI, ISV, CSP, MSP)","Active__c":"true","Account_Value__c":"Solution Enabler (SI, ISV, CSP, MSP)"},{"New_Customer_Value__c ":"Reseller - Retailers","Active__c":"true","Account_Value__c":"Reseller - Retailers"},{"New_Customer_Value__c ":"Reseller - Branded Disti","Active__c":"true","Account_Value__c":"Reseller - Branded Disti"},{"New_Customer_Value__c ":"End Customer","Active__c":"true","Account_Value__c":"End Customer"},{"New_Customer_Value__c ":"Device Builder - Regional OxM","Active__c":"true","Account_Value__c":"Device Builder - Regional OxM"},{"New_Customer_Value__c ":"Hyperscaler (AWS, Azure, GCP)","Active__c":"true","Account_Value__c":"Hyperscaler (AWS, Azure, GCP)"},{"New_Customer_Value__c ":"Device Builder - MNC","Active__c":"true","Account_Value__c":"Device Builder - MNC"}]', List<CST_New_Customer_Account_Sync__mdt>.class);
        
        System.runAs(userRec){
            List<SPM_Planning_Period__c> planningRecord = [Select Id,Name,Active__c,Planning_Period__c  FROM SPM_Planning_Period__c WHERE Active__c=true ORDER BY CreatedDate DESC LIMIT 1];
            String planningPeriod =  planningRecord[0].Planning_Period__c;   
            
            Id sfAcc = [select id from Account where Name='TestAccount1' limit 1][0].Id; 
            Id sfAcc2 = [select id from Account where Name='TestAccount2' limit 1][0].Id;    
            Id sfAcc3 = [select id from Account where Name='TestAccount3' limit 1][0].Id; 
            Id sfAcc4 = [select id from Account where Name='TestAccount4' limit 1][0].Id;
            
            SPM_New_Accounts__c newCustomerRec = new SPM_New_Accounts__c();
            newCustomerRec.Account_Name__c = 'Test New Customer 1';
            newCustomerRec.New_Account_Owner__c = userRec.Id;
            newCustomerRec.New_Sales_Group__c = 'Americas Canada Sales Group';
            newCustomerRec.SF_Account__c = sfAcc;
            newCustomerRec.GM_Feedback__c = 'Approved';  
            newCustomerRec.Customer_category__c='Device Builder - MNC';
            newCustomerRec.CRM_CST_Is_Active_Planning_Period__c =planningPeriod;
            newCustomerRec.Coverage__c = 'Intel Covered';
            insert newCustomerRec;
            
            SPM_New_Accounts__c newCustomerRec2 = new SPM_New_Accounts__c();
            newCustomerRec2.Account_Name__c = 'Test New Customer 2';
            newCustomerRec2.New_Account_Owner__c = userRec.Id;
            newCustomerRec2.New_Sales_Group__c = 'Americas Brazil Sales Group';
            newCustomerRec2.SF_Account__c = sfAcc;
            newCustomerRec2.GM_Feedback__c = 'Approved'; 
            newCustomerRec2.Customer_category__c='Distributors (IA)';
            newCustomerRec2.CRM_CST_Is_Active_Planning_Period__c =planningPeriod;
            insert newCustomerRec2;
            
            List<SPM_New_Accounts__c> newCustomerList = new List<SPM_New_Accounts__c>();
            for(Integer i=0;i<=10;i++){
                SPM_New_Accounts__c newCustomer= new SPM_New_Accounts__c();
                newCustomer.Account_Name__c = 'Test New Customer 2';
                newCustomer.New_Account_Owner__c = userRec.Id;
                newCustomer.New_Sales_Group__c = 'Americas Canada Sales Group';
                newCustomer.SF_Account__c = sfAcc2;
                newCustomer.GM_Feedback__c = 'Approved';
                newCustomer.CRM_CST_Is_Active_Planning_Period__c = planningPeriod;
                newCustomer.Customer_category__c='Reseller - Retailers';
                newCustomerList.add(newCustomer);  
            }
            for(Integer i=0;i<=10;i++){
                SPM_New_Accounts__c newCustomer3= new SPM_New_Accounts__c();
                newCustomer3.Account_Name__c = 'Test New Customer 2';
                newCustomer3.New_Account_Owner__c = userRec.Id;
                newCustomer3.New_Sales_Group__c = 'Americas Canada Sales Group';
                newCustomer3.SF_Account__c = sfAcc4;
                newCustomer3.GM_Feedback__c = 'Approved';
                newCustomer3.CRM_CST_Is_Active_Planning_Period__c = planningPeriod;
                newCustomer3.Customer_category__c='End Customer';
                newCustomerList.add(newCustomer3);  
            }
            insert newCustomerList;
            
            //Id jobId = Database.executeBatch(new CST_CRMNewCustomerBatch());
            CST_CRMNewCustomerBatch.executeCRMCustomerBatch();
        }
        
    }
    @testVisible static List<CST_New_Customer_Account_Sync__mdt> customMetadata { 
        get {
            if ( customMetadata == null )
                customMetadata = [ SELECT New_Customer_Value__c,Active__c,Account_Value__c FROM CST_New_Customer_Account_Sync__mdt ]; 
            system.debug('Custom metadata is:'+customMetadata);
            return customMetadata;
        } set; }
}