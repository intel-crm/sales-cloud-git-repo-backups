@isTest(seeAllData=false)
public class Core_MDF_ActivitySegmentMappingTest {
    
    @TestSetup
    static void setUpData(){
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        List<User> usrList = new List<User>();
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        usr.LastName = 'SysAdmUser';
        usrList.add(usr);
        
        Database.insert(usrList);
        
        System.runAs(usr){
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet rmfacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(ccfaccntmngr);
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation','Bypass_ShareActivityWithUsers','Bypass_Activity_ApprovalProcess','Bypass_ShareActivityWithAccNodeGroup','ShareActivityWithInternalUsers_Bypass'}, true, false));
            Database.insert(transactions);
            
            List<Account> masterAccountList = new List<Account>();
            List<Account> accountList = new List<Account>();
            List<Account> toBeUpdated = new List<Account>();
            List<Campaign> campaignList = new List<Campaign>();
            List<PartnerMarketingBudget> budgetList= new List<PartnerMarketingBudget>();
            List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
            
            List<ChannelProgram> channelProg = new List<ChannelProgram>();
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            channelProg.add(cp);
            Database.insert(channelProg);
            
            Account Masteracc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Masteracc.BillingCity = 'Test City';         
            Masteracc.BillingCountryCode= 'IND';
            Masteracc.BillingCountry = 'IND';
            Masteracc.BillingStateCode = 'MH'; 
            Masteracc.BillingState = 'MH';
            Masteracc.BillingStreet= 'Test Street';
            Masteracc.Core_Geo__c= 'APJ';
            insert Masteracc;
            
            Account ccfAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account CCF', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, Masteracc.Id, false);
            accountList.add(ccfAccount);
            
            database.insert(accountList);
            // Updating Accounts 
            Masteracc.isPartner = true;
            ccfAccount.isPartner = true;
            toBeUpdated.add(Masteracc);
            toBeUpdated.add(ccfAccount);
            Database.update(toBeUpdated);
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
            PartnerMarketingBudget budgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, ccfAccount.Id, cp.Id, 5000000, System.today(),System.today().addDays(110), false);
            budgetCCF.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            budgetList.add(budgetCCF);
            Database.insert(budgetList);
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            
            PartnerFundAllocation pfaCCF = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation CCF',budgetCCF,ccfAccount,200000.0,false);
            pfaList.add(pfaCCF);
            Database.insert(pfaList);
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        'CMP only',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today(),
                                                                        System.today().addDays(200), 20000, 'Unite',ccfAccount.Id,'2-in-1', false);
            
            camp.Core_MDF_Activity_Category_Type__c = 'Digital 2025->Web Content';
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
            campaignList.add(camp);
            
            database.insert(campaignList);
            
            // Creating activities using utility class
            PartnerFundRequest pfrCCF = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                              string.valueof(ccfAccount.id),pfaCCF,budgetCCF,'INDIA','Small Business',
                                                                                              'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                              'Radio','Draft',false);
            pfrCCF.Title = 'Activity CCF';
            pfrCCF.Core_MDF_Activity_Description__c = 'indiaActivity';
            pfrCCF.Core_MDF_Start_Date__c = system.today();
            pfrCCF.Core_MDF_End_Date__c = system.today();
            pfrCCF.RequestedAmount = 10000;
            pfrCCF.Amount = 10000;
            pfrCCF.Status = 'Approved';
            pfrCCF.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfrCCF.Core_MDF_Reimbursement_Rate_txt__c='50%';
            pfrCCF.Core_MDF_Fund_Request_Status__c='Planned';
            pfrCCF.Core_MDF_ActivityCategory__c = 'Broadcast';
            pfrCCF.Core_MDF_Activity_Types__c = 'Podcast';
            
            testPartnerFundRequestRecordList.add(pfrCCF);
            database.insert(testPartnerFundRequestRecordList);
            
            Core_MDF_Activity_Segment_Mapping__c asm = new Core_MDF_Activity_Segment_Mapping__c();
            asm.Core_MDF_Segment_Name_nm__c = 'Chipsets';
            asm.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = 1;
            asm.Core_MDF_SPIF_Notes_internal_only_txt__c = 'Test';
            asm.Core_MDF_Minimum_Forecast_Volume_nbr__c = 1;
            asm.Core_MDF_Estimated_Share_of_SPIF_amt__c = 1;
            asm.Core_MDF_Maximum_Bundled_Volume_nbr__c = 1;
            asm.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = 1;
            asm.Core_MDF_SPIF_Notes_txt__c = 'Test';
            asm.Core_MDF_Active_Ind__c = true;
            asm.Core_MDF_Partner_Fund_Request_id__c = pfrCCF.Id;
            insert asm;
            
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            // Creating Bank
            Core_MDF_Bank__c ccfBank = Core_MDF_CCP_TestDataUtility.createBank(Masteracc.id,'Core_MDF_Client_CoMarketing_Fund',false,'9966467890');
            bankList.add(ccfBank);
            
            Database.insert(bankList);
            bankList[0].Core_MDF_Bank_Status__c = 'Active';
            Database.update(bankList);
            
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            //Creating Account Bank Mapping
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ccfAccount.Id,ccfBank.Id,false);
            abmList.add(abm1);
            Database.insert(abmList);
            
            List<PartnerFundClaim> pfcList=new List<PartnerFundClaim>();
            PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfrCCF.Id,System.today(),System.today(),2000,System.today(),ccfBank.Id,false);
            pfc.Core_MDF_Country_Location_nm__c ='INDIA';
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Criteria_Hold_Ind__c=true;
            pfc.Core_MDF_Member_Manual_Hold_Ind__c=true;
            pfc.Core_MDF_Intel_Manual_Hold_Ind__c=true;
            pfc.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            pfc.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            pfcList.add(pfc);
            
            test.startTest();
            database.insert(pfcList);
            
            Product2 prod = new Product2();
            prod.Name = 'Intel® B360 Chipset';
            prod.Core_Product_Type__c = 'Chipsets';
            prod.Core_Product_Family__c = 'Consumer Chipsets';
            Database.insert(prod);
            
            //Account Product Mapping
            Core_MDF_Account_Product_Mapping__c apm = new Core_MDF_Account_Product_Mapping__c();
            apm.Core_MDF_Account__c = Masteracc.Id;
            apm.Core_MDF_Active_ind__c = true;
            apm.Core_MDF_Program_Account_Map__c = 'Client CoMarketing Fund';
            apm.Core_MDF_Product__c = prod.Id;
            Database.insert(apm);
            
            Core_MDF_Segment_Product_Mapping__c spm1 = new Core_MDF_Segment_Product_Mapping__c();
            spm1.Core_MDF_Product_id__c = prod.Id;
            spm1.Core_MDF_Activity_Segment_Mapping_id__c = asm.Id;
            spm1.Core_MDF_Active_Ind__c = true; 
            insert spm1;
                
            test.stopTest();
        }
        
    }
    
    @isTest
    static void testgetProductMappingForSegment(){
        
        Account acc = [Select Id From Account where Name = 'Test Account CCF'LIMIT 1];
        PartnerFundRequest pfr = [Select Id, Title from PartnerFundRequest where title = 'Activity CCF' LIMIT 1];
        Account Masteracc = [Select Id From Account where Name = 'Test Account 1'LIMIT 1];
        Core_MDF_Activity_Segment_Mapping__c asm = [Select Id from Core_MDF_Activity_Segment_Mapping__c where Core_MDF_Segment_Name_nm__c = 'Chipsets' LIMIT 1];
        Product2 prod=[Select Id,Name,Core_Product_Family__c from Product2 where Name='Intel® B360 Chipset'];
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        test.startTest();
        List<Product2> res1=new List<Product2>();
        System.runAs(user){
            Core_MDF_ActivitySegmentMapping.getLabelValueMap();
            String ultimateAccId = Core_MDF_ActivitySegmentMapping.getUltimateAccountId(acc.Id);
            res1=Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Chipsets', ultimateAccId, 'Client CoMarketing Fund');
            Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Chipsets');
        }
        test.stopTest();
        Assert.areEqual('Intel® B360 Chipset', res1[0].Name);
    }
    
    @isTest
    static void testgetSegmentValues(){
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        test.startTest();
        System.runAs(user){
            Core_MDF_ActivitySegmentMapping.getSegmentValues(); 
        }
        Assert.isTrue(user !=  null);
        test.stopTest();
    }
    

    
    @isTest
    static void testreturnSegments(){
       User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
       Core_MDF_ActivitySegmentMapping.SegmentWrapper seg= new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
       PartnerFundRequest pfr = [Select Id, Title from PartnerFundRequest where title = 'Activity CCF' LIMIT 1];
       test.startTest();
       System.runAs(user){
         seg=Core_MDF_ActivitySegmentMapping.returnSegments(pfr.Id);
         Core_MDF_ActivitySegmentMapping.getFieldsToDisplay('Client CoMarketing Fund', 'Podcast');
       }
       test.stopTest();
       List<Core_MDF_Segment_Product_Mapping__c> segmentList=seg.productList;
       Assert.areEqual('Intel® B360 Chipset', segmentList[0].Core_MDF_Product_Name_txt__c);
      
    }
    
    @isTest
    static void testgetProductMappingForAccount(){
       Account acc = [Select Id From Account where Name = 'Test Account CCF'LIMIT 1];
       User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
       List<Product2> res=new List<Product2>();
       test.startTest();
       System.runAs(user){
        res=Core_MDF_ActivitySegmentMapping.getProductMappingForAccount(acc.Id,'Client CoMarketing Fund');
       } 
       test.stopTest();
       Assert.areEqual('Intel® B360 Chipset', res[0].Name);
      }
    
    
    @isTest
    static void testcreateUpdateSegmentAndProductMappingRecords(){
        PartnerFundRequest pfr = [Select Id, Title from PartnerFundRequest where title = 'Activity CCF' LIMIT 1];
        Core_MDF_Activity_Segment_Mapping__c asm = [Select Id from Core_MDF_Activity_Segment_Mapping__c where Core_MDF_Segment_Name_nm__c = 'Chipsets' LIMIT 1];
        Core_MDF_ActivitySegmentMapping.SegmentWrapper wrapper = new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
        Product2 prod=[Select Id,Name from Product2 where Name='Intel® B360 Chipset'];
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        test.startTest();
        String segmentString2 = '[{"Core_MDF_Segment_Name_nm":"Chipsets","segmentId":"'+asm.Id+'","productIdSet":["'+prod.Id+'"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333","Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":"22", "Core_MDF_Maximum_Cost_of_Bundle_nbr":"222","Core_MDF_Maximum_Bundled_Volume_nbr":"55","Core_MDF_Minimum_Forecast_Volume_nbr__c":"1", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c":"23","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_amt":"11"}]';   
         System.runAs(user){
             wrapper=Core_MDF_ActivitySegmentMapping.getSegmentForActivity(pfr.Id);
             Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,segmentString2);
         }
        test.stopTest();
        List<Core_MDF_Segment_Product_Mapping__c> segmentList=wrapper.productList;
        Assert.areEqual('Intel® B360 Chipset', segmentList[0].Core_MDF_Product_Name_txt__c);
       
    }
    
   /*  @isTest
    static void tesgetRecordTypeLabelByName(){
     User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        String recTypeLabel;
        test.startTest();
        System.runAs(user){
         recTypeLabel = Core_MDF_ActivitySegmentMapping.getRecordTypeLabelByName('Core_MDF_Client_CoMarketing_Fund');
         }
        test.stopTest();
        Assert.areEqual('Client',recTypeLabel);
    }*/
    
    
    @isTest
    static void testgetSegmentForClaims(){
        PartnerFundClaim claim = [Select Id, Title from PartnerFundClaim where Title = 'Test Claim' LIMIT 1 ];
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        Core_MDF_ActivitySegmentMapping.SegmentWrapper wrapper = new Core_MDF_ActivitySegmentMapping.SegmentWrapper();
        test.startTest();
         System.runAs(user){
            wrapper=Core_MDF_ActivitySegmentMapping.getSegmentForClaims(claim.Id);
            
         }
        test.stopTest();
        List<Core_MDF_Activity_Segment_Mapping__c> segmentList=wrapper.segmentList;
        Assert.areEqual('Chipsets', segmentList[0].Core_MDF_Segment_Name_nm__c );
    }
    
    /*@isTest
    static void testgetProductMappingForSegment2(){
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        test.startTest();
         System.runAs(user){
        Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Processors');
        }
        test.stopTest();
    }*/
    
    @isTest
    static void testgetcreateUpdateSegmentAndProductMappingRecords2(){
        PartnerFundRequest pfr = [Select Id, Title from PartnerFundRequest where title = 'Activity CCF' LIMIT 1];
        User user = [SELECT Id,email FROM User WHERE email = 'ccfaccntmngr@example.com' limit 1];
        Product2 prod=[Select Id,Name from Product2 where Name='Intel® B360 Chipset'];
        List<Product2> productList = new List<Product2>();
        String recTypeLabel;
        test.startTest();
        String segmentString = '[{"Core_MDF_Segment_Name_nm":"Chipsets","productIdSet":["'+prod.Id+'"],"Core_MDF_Minimum_Forecast_Volume_nbr":"333", "Core_MDF_Maximum_Cost_of_Bundle_nbr":"222","Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr":"22","Core_MDF_Maximum_Bundled_Volume_nbr":"55","Core_MDF_Minimum_Forecast_Volume_nbr__c":"1", "Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c":"23","Core_MDF_SPIF_Notes_internal_only_txt":"333","Core_MDF_Estimated_Share_of_SPIF_amt":"11"}]';
         System.runAs(user){
            productList=Core_MDF_ActivitySegmentMapping.getProductMappingForSegment('Processors');
            Core_MDF_ActivitySegmentMapping.createUpdateSegmentAndProductMappingRecords(pfr.Id,segmentString);
            recTypeLabel = Core_MDF_ActivitySegmentMapping.getRecordTypeLabelByName('Core_MDF_Client_CoMarketing_Fund');
         }
        test.stopTest();
        Assert.areEqual('Client',recTypeLabel);
    }
    
    

}