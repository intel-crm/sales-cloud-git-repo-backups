@isTest
public class PMP_PAG_mem_handler_Test {
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'PAG_mem_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_Acct_Grp_Mbr_TriggerHandler',
                                                                        Core_Object__c = 'Core_Account_Group_Member__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, Before Delet',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        List<Account> accList = new List<Account>();
        Account partner_acc = PMP_SearchTestDataFactory.createIntelAccount('Test PAG Account', PMP_SearchTestDataFactory.Partner_Account_Record_Type, false);
        Account intel_acc = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        // Account partner_acc1 = PMP_SearchTestDataFactory.createIntelAccount('Test PAG Account1', PMP_SearchTestDataFactory.Partner_Account_Record_Type, false);
        // Account intel_acc1 = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account1', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        accList.add(partner_acc);
        accList.add(intel_acc);
        //  accList.add(partner_acc1);
        //  accList.add(intel_acc1);
        insert accList;
        
        Core_ERPM_Engagement__c engagement = PMP_SearchTestDataFactory.createERPMEngagement('ISA', true);
        
        List<Core_Account_ERPM_Engagement__c> accEngList = new List<Core_Account_ERPM_Engagement__c>();
        accEngList.add(PMP_SearchTestDataFactory.createAccountERPMEngagement(intel_acc.Id, engagement.Id, 'ISA', false));
        //   accEngList.add(PMP_SearchTestDataFactory.createAccountERPMEngagement(intel_acc1.Id, engagement.Id, 'UNDETERMND', false));
        insert accEngList;
        
        Core_Account_ERPM_Engagement__c acctEngagement = new Core_Account_ERPM_Engagement__c();
        acctEngagement.Core_Account_Id__c = accList[1].Id;
        acctEngagement.Core_ERPM_Engagement_Id__c = engagement.Id;
        insert acctEngagement;            
        
        List<PMP_Company__c> compList = new List<PMP_Company__c>();
        PMP_Company__c comp = PMP_SearchTestDataFactory.createCompanyInformation(intel_acc.Name, intel_acc.Id, false);
        comp.PMP_Is_Published_Ind__c = true;
        comp.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        compList.add(comp); 
        //    compList.add(PMP_SearchTestDataFactory.createCompanyInformation(intel_acc1.Name, intel_acc1.Id, false)); 
        insert compList;
        
    }
     public static Account createTestAccount() 
    {
        
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account123456789123456789123456789123456789Account1123456789123456789123456789123456789Account11234567891234567891Account 1123456789123456789';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.ShippingStreet = 'Yemen';
        acctObj.ShippingCity = 'Testing City';
        acctObj.ShippingStateCode = 'OR';
        acctObj.ShippingCountryCode = 'USA';
        acctObj.ShippingPostalCode = '12345';
        acctObj.Core_User_Defined_Phone_Number__c = '1234567890';
        acctObj.Core_User_Defined_Website__c ='www.xyz.com';
        acctObj.Core_User_Defined_Number_of_Employees__c = '1-9';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acctObj.Core_IPA_Partner_Role__c = 'Service Provider';
        acctObj.Industry = 'Agriculture';
        acctObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        test.startTest();
        insert acctObj;
        test.stopTest();
        
        return acctObj;
    }
      public static Contact createTestContact() 
    {
        
        Contact conObj = new Contact();
        Account acctObj = createTestAccount();
        //test.startTest();
        conObj.AccountId = acctObj.Id;
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.Core_Preferred_Language__c= 'ENG';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.MailingCountry='USA';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        conObj.Core_IPA_PartnerRole__c = 'Service Provider';
        //conObj.Core_ERPM_Integration_Status__c = 'Pending';
        //conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.RecordTypeId= [select Id from RecordType where sObjectType='Contact' and Name=:Label.ERPM_Intel_Contact].Id;
        
        insert conObj;
        //test.stopTest();
        // System.debug('Core_ERPM_Integration_Queue_txt__c : '+conObj.Core_ERPM_Integration_Queue_txt__c + 'Core_ERPM_Integration_Status__c : '+ conObj.Core_ERPM_Integration_Status__c);
        
        // System.debug('Contact in create testcontact' + conObj.AccountId);
        
        Core_Entitlement_Out_Int_Test.createTestContactEntitlement(conObj,1);
        return conObj;   
    }
    
    public static List<PRM_AccountChannelMembership__c> CreateAccountChannelMembership(Contact cntct, String statusVal)
    {
       
        ChannelProgram chnlprgm = CreateChannelProgram();       
        List<PRM_AccountChannelMembership__c> acmlst=new List<PRM_AccountChannelMembership__c>();
        PRM_AccountChannelMembership__c acctMembership = new PRM_AccountChannelMembership__c();
        // System.debug('Contact'+ cntct);
        // System.debug('Account ID'+cntct.AccountId);
        acctMembership.PRM_Account_Id__c = cntct.AccountId;
        acctMembership.PRM_Channel_Program_Id__c = chnlprgm.Id;
        acctMembership.PRM_Status_Nm__c = statusVal; 
        acctMembership.PRM_Status_Reason_Txt__c = 'Approved';
        //acctMembership.PRM_Channel_Program_Level_Id__c = GetChannelProgramLevel(chnlprgm.Id).Id;     
        acctMembership.PRM_Partner_Role__c = 'Service Provider';
        acmlst.add(acctMembership);
        
        insert acctMembership;
       
        System.assertNotEquals(chnlprgm.Id, null);
        //System.debug('Inside Account Channel Memebership--- Complete' + acctMembership);
        return acmlst;
        
    }
    public static ChannelProgram CreateChannelProgram()
    {
        ChannelProgram prgm = new ChannelProgram();
        prgm.Name = 'Intel Partner Alliance';
        prgm.PRM_programCode__c ='IPA';
        prgm.IsActive = true;
        prgm.PRM_inactind__c = false;
        insert prgm;
        
        return prgm;
    }
    
    
   /* @isTest
    static void Insert_Update_CAG() {
        
        Contact testConObj = createTestContact();
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Id partnerAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        //system.debug('partnerAccRecTypeId- '+partnerAccRecTypeId);
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                              Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='USA',BillingStreet='abc chowk delhi',BillingState='FL',
                                              ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True,OwnerId=UserInfo.getUserId());
    
       Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Group_New__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='USA',BillingStreet='cbc chowk delhi',
                                            ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
    
        List<Account> partnerAccts = new List<Account>();
        partnerAccts.add(partnerAccount1);
        partnerAccts.add(intelAccount1);
        insert partnerAccts;
        
        List<PRM_AccountChannelMembership__c> acctConMem = CreateAccountChannelMembership(testConObj,'Approved');
        Core_Account_Group_Member__c accGroupMem = new Core_Account_Group_Member__c();
        accGroupMem.Core_Partner_Account_Id__c = partnerAccount1.Id;
        accGroupMem.Core_Intel_Account_Id__c = testConObj.AccountId;
        accGroupMem.Core_Inactive_Ind__c = false;
        accGroupMem.Core_MDA_Ind__c = false;
        Database.insert(accGroupMem);
        // system.debug('limitQueries210:'+Limits.getQueries());
        
        // system.debug('limitQueries21:'+Limits.getQueries());
        
        Account act = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', act.PRM_IPA_Integration_Status__c);
        
        accGroupMem.Core_Inactive_Ind__c = true;
        Core_Acct_Grp_Mbr_TriggerHandler.IPAfirstRun = true;
        act.PRM_IPA_Integration_Status__c = 'Successful';
        update act;
        update accGroupMem;
        
        
        Account actUp = [SELECT Id, PRM_IPA_Integration_Status__c FROM Account WHERE Id =: testConObj.AccountId];
        System.assertEquals('Pending', actUp.PRM_IPA_Integration_Status__c);
        //system.debug('limitQueries212:'+Limits.getQueries());
        
    }*/
    
    @isTest static void onGroupMemAfterInsert_Test(){
        
        Account acct_partner = [Select Id,Name,RecordTypeId from Account where Name = 'Test PAG Account' LIMIT 1];
        Account acct_intel = [Select Id,Name,RecordTypeId from Account where Name = 'Test Intel Account' LIMIT 1];
        
        Test.startTest();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = acct_partner.Id;
        coreAccnt.Core_Intel_Account_Id__c = acct_intel.Id;
        coreAccnt.Core_MDA_Ind__c = true;
        coreAccnt.Core_Inactive_Ind__c = false;
        insert coreAccnt;
        Test.stopTest();
        
    }
    
    @isTest static void onGroupMemAfterUpdate_Test(){
        List<Account> partner_acc_list= [Select Id, Name,Core_IPA_Partner_Role__c, Core_User_Defined_Website__c,recordTypeId,Website from Account where RecordTypeId =: PMP_SearchTestDataFactory.Partner_Account_Record_Type];
        List<Account> intel_acc_list = [Select Id, Name,Core_IPA_Partner_Role__c, Core_User_Defined_Website__c,recordTypeId,Website from Account where RecordTypeId =: PMP_SearchTestDataFactory.intel_Account_Record_Type];
        //intel_acc_list[0].Core_IPA_Partner_Role__c='FPGA Designer';IPA 2.0 partner role EOL
        intel_acc_list[0].Core_IPA_Partner_Role__c='Builder';
        update intel_acc_list[0];  
        //partner_acc_list[0].Core_IPA_Partner_Role__c='FPGA Designer';IPA 2.0 partner role EOL
        partner_acc_list[0].Core_IPA_Partner_Role__c='Builder';
        update partner_acc_list[0];  
        Core_Account_Group_Member__c group_mem1 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[0].Id, intel_acc_list[0].Id, false, false, true);
        //Core_Account_Group_Member__c group_mem2 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[1].Id, intel_acc_list[1].Id, false, false, true);
        List<PMP_Company__c> comp_lst = [Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c from PMP_Company__c Where PMP_Account_Id__c IN: intel_acc_list];
        
        
        Map<Id,Core_Account_Group_Member__c> oldMap = new Map<Id,Core_Account_Group_Member__c>();
        oldMap.put(group_mem1.Id,group_mem1);
        //oldMap.put(group_mem2.Id,group_mem2);
        
        Core_Account_Group_Member__c grp1 = group_mem1;
        //Core_Account_Group_Member__c grp2 = group_mem2;
        Map<Id,Core_Account_Group_Member__c> newMap = new Map<Id,Core_Account_Group_Member__c>();
        grp1.Core_MDA_Ind__c = true;
        update grp1;
        //grp2.Core_MDA_Ind__c = true;
        //update grp2;
        grp1 = [SELECT Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId FROM Core_Account_Group_Member__c WHERE Id=:grp1.Id LIMIT 1];
        //grp2 = [SELECT Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId FROM Core_Account_Group_Member__c WHERE Id=:grp2.Id LIMIT 1];
        newMap.put(grp1.Id,grp1);
        //newMap.put(grp2.Id,grp2);
        List<Core_Account_Group_Member__c> newList = new List<Core_Account_Group_Member__c>();
        newList.add(grp1);
        //newList.add(grp2);
        
        PMP_PAG_mem_handler.onGroupMemAfterUpdate(newList, oldMap, newMap);
        List<PMP_Company__c> compList = [SELECT id from PMP_Company__c WHERE PMP_Account_Id__c=: intel_acc_list[0].Id];
        system.assert(compList.size() > 0);
    }
}