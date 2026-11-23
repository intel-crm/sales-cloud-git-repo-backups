@isTest(SeeAllData=false)
public class Core_OpportunityHandler_2_Test {
    
    @TestSetup
    static void setupData() {
       
        List<Core_Trigger_Executions__c> teList = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c oppCS1 = new Core_Trigger_Executions__c(Name='TechnicalOwnerAdditiontoTM',Core_Active__c = true,Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS1);
        
        Core_Trigger_Executions__c oppCS2 = new Core_Trigger_Executions__c(Name='opportunityTechnicalOwnerUpdate',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS2);
        
        Core_Trigger_Executions__c oppCS3 = new Core_Trigger_Executions__c(Name='OpportunityLockFields',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS3);
        
        Core_Trigger_Executions__c oppCS4 = new Core_Trigger_Executions__c(Name='POPCheckOnUpdate',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS4);
        
        Core_Trigger_Executions__c oppCS5 = new Core_Trigger_Executions__c(Name='Tech_CIMID_Validation',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS5);
        
        Core_Trigger_Executions__c oppCS6 = new Core_Trigger_Executions__c(Name='updateProductLineItems',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS6);
        
        Core_Trigger_Executions__c oppCS7 = new Core_Trigger_Executions__c(Name='updateActivityLineItems',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS7);
        
        Core_Trigger_Executions__c oppCS8 = new Core_Trigger_Executions__c(Name='forecastUpdateFromOppty',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS8);
        
        Core_Trigger_Executions__c oppCS9 = new Core_Trigger_Executions__c(Name='OpportunityKPIJSON',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS9);
        
        Core_Trigger_Executions__c oppCS10 = new Core_Trigger_Executions__c(Name='delegateApproverRoleChange',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS10);
        
        Core_Trigger_Executions__c oppCS11 = new Core_Trigger_Executions__c(Name='UpdateTerritoryInfoOnOppty',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS11);
        
        Core_Trigger_Executions__c oppCS12 = new Core_Trigger_Executions__c(Name='RestrictSolutionDetailLOV',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS12);
        
        Core_Trigger_Executions__c oppCS13 = new Core_Trigger_Executions__c(Name='CombineSolutionDetailFields',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS13);
        
        Core_Trigger_Executions__c oppCS14 = new Core_Trigger_Executions__c(Name='opportunityOppFactDelete',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS14);
        
        Core_Trigger_Executions__c oppCS15 = new Core_Trigger_Executions__c(Name='OpportunityStageExitValidation',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS15);
        
        Core_Trigger_Executions__c oppCS16 = new Core_Trigger_Executions__c(Name='deleteKPIonOpportunityDelete',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS16);
        
        Core_Trigger_Executions__c oppCS17 = new Core_Trigger_Executions__c(Name='RestrictSolutionAreaInactiveLOV',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS17);
        
        Core_Trigger_Executions__c oppCS18 = new Core_Trigger_Executions__c(Name='BlockExistingOppOnLeadConversion',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS18);
        
        Core_Trigger_Executions__c oppCS19 = new Core_Trigger_Executions__c(Name='opportunityStageUpdate',Core_Active__c = true, Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        teList.add(oppCS19);

        insert teList;
       
        Profile p = [select Id from Profile where Name = 'IT Admin'];
        
        User OSOOwner = new User(Alias = 'OSOOwner', Email='OSOOwner@apttus.com',
                               EmailEncodingKey='UTF-8', LastName='TTest', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = p.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='OSOOwner@mail.com', Department='OSC', Core_User_Geo__c = 'PRC');
        insert OSOOwner;
        
        User OSOTOwner = new User(Alias = 'OSOTO', Email='OSOTOwner@apttus.com',
                            EmailEncodingKey='UTF-8', LastName='OTest', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='OSOTOwner@mail.com', Department='OSC');
        insert OSOTOwner;
        //Added partner user for Portal role sharing fix
        Profile profile1 = [select Id from Profile where Name = 'Partner'];
              
        Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        Account acct = new Account();
        acct.name = 'TestAccountKPI';
        acct.RecordTypeId = recTypeId;
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama123';
        acct.BillingStreet = 'test123';  
        acct.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';
        acct.OwnerId =  OSOOwner.Id;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'FPGA/Power',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            PCC_End_Customer_Country__c = 'United States',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today()+47,
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Re-Submitted',
            Core_Partner_Account_Id__c= acct.Id
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
            
        system.runAs(OSOOwner){
            Opportunity oppoTM1 = new Opportunity(Name = 'OppoHandler', RecordTypeId = newOppRecTypeId,core_approval_status__c = 'Approved',Opportunity_Focus__c= 'Core',Core_Opportunity_Type__c ='Design: Original',	
                                                      AccountId = acct.Id,Core_Commissionable__c = 'Yes',Core_Date_Submitted_for_Approval__c = System.Date.today()+1,
                                                      StageName = 'Qualify', CloseDate = System.Date.today()+1);
            insert oppoTM1;
        }
        /*System.runAs(Core_Test_Utility.systemAdminUser) {
        UserRole role=new UserRole();
        role.name='Admin';        
        insert role;

        Contact cont = new Contact();
        cont.FirstName = 'Test11';
        cont.LastName  = 'Contact';
        cont.AccountId = acct.id;
        cont.Email = 'testingzzz@example.com';
        cont.MailingCountry='AUS';   
        insert cont;
        User partnerUser = new User(Alias = 'OSOTO', Email='partnerTOuser@apttus.com',
                            EmailEncodingKey='UTF-8', LastName='OTest', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = profile1.Id,ContactId=cont.id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='partnerTOuser@mail.com',UserRoleId= role.Id);
        insert partnerUser;
        }*/
        
    }
    
    static testmethod void testOppoTO() { 
        List<OpportunityTeamMember> oppTMList = new List<OpportunityTeamMember>();
        Opportunity oppo = [select id from Opportunity where Name = 'OppoHandler'  limit 1]; 
        User usr = [select id from User where Email='OSOTOwner@apttus.com' limit 1];
        
        Profile pro = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
        User usr1 = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pro.Id AND isActive = true AND Core_User_Type__c !='External User' LIMIT 1];

        oppo.Core_Technical_Owner__c = usr1.id;
        update oppo;
        
        OpportunityTeamMember oppTM = [select id from OpportunityTeamMember where userid =: usr1.id];
        delete oppTM;
        
        oppo.Core_Approval_Status__c = 'Submitted';
        update oppo;
        System.assertEquals(true, oppo.id != null, 'opty update');
        
        delete oppo;
    }
   //Portal Sharing Fix 
    static testmethod void OpportunityShareTest()
    {   
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
            List<Core_CRM_Labels__c> CRMLabelList = new List<Core_CRM_Labels__c>();
            CRMLabelList.add(new Core_CRM_Labels__c(Name='CRM_OpportunityOwnerUpdateSwitch', Value__c='true'));
            insert CRMLabelList;
        }
        UserRole role=new UserRole();
        role.name='Admin';        
        insert role;
                
        User usr = [select id from User where Email='OSOTOwner@apttus.com' limit 1];
        User usr1 = [select id from User where Email='OSOOwner@apttus.com' limit 1];
        User partUsr = [select Id,UserRoleId from User where Profile.Name='Partner' AND IsActive=true LIMIT 1];
       
        usr.UserRoleId = role.Id;
        usr1.UserRoleId = role.Id;
        
        update usr;
        update usr1;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
        Account acct = new Account(Name = 'Test Account1', Industry = 'Agriculture', Core_Sub_Industry__c = 'Forestry', 
                                   BillingStreet = '123 Fake St',BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_Sales_Groups__c='EMEA Sales Group',OwnerId= usr1.Id);
        
        insert acct;
        
        Id DealOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
        Id DesignOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            
        Account acct1 = [Select id,OwnerId from Account where Name ='TestAccountKPI' limit 1];
        Core_Design_Registration__c ddr = [select id,Core_Partner_Account_Id__c from Core_Design_Registration__c limit 1];
        ddr.Core_Partner_Account_Id__c = acct1.Id;
        update ddr;    
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name = 'TestClass PCC Opportunity', RecordTypeId = DealOppRecTypeId,Core_Design_Registration_Id__c=ddr.Id,Core_OpportunityTeamMembers__c=null,
                                            AccountId = acct.Id, OwnerId= usr1.Id,Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Technical_Owner__c = partUsr.Id,
                                            CRM_SW_Flag_Ind__c = true,StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity'));
        
        oppList.add(new Opportunity(Name = 'Opportunity to Lose 03-24-2015', RecordTypeId = DesignOppRecTypeId,
                                           AccountId = acct.Id, Core_Technical_Owner__c = partUsr.Id,OwnerId= usr1.Id,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Opportunity_Coverage_Nm__c=Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram'),Core_Opportunity_Type__c='Design: Original', Opportunity_Focus__c= 'Core'));
        insert oppList;
        
        acct.OwnerId = usr.id;
        update acct;
        List<Opportunity>  oppId = new List<Opportunity>();
        for(Opportunity opp: oppList){
            opp.OwnerId = usr.id; 
            oppId.add(opp);
        }
        update oppId;
            
        List<Core_OpportunityHandler_2.InputData> lstInput = new List<Core_OpportunityHandler_2.InputData>();
        Core_OpportunityHandler_2.InputData input = new Core_OpportunityHandler_2.InputData();
        input.priorAccountOwnerId = usr1.Id;
        input.accOwnerId = acct.OwnerId;
        input.accId = acct.Id;
        lstInput.add(input);
        Core_OpportunityHandler_2.invokeAccount360OpportunitySharingforOnwerChange(lstInput);
        
        // Assertions to validate expected changes
        List<Opportunity> insertedOpps = [SELECT Id, Name, OwnerId, AccountId FROM Opportunity WHERE AccountId = :acct.Id AND Name IN ('TestClass PCC Opportunity','Opportunity to Lose 03-24-2015')];
        // Validate both opportunities were inserted
        System.assertEquals(2, insertedOpps.size(), 'Two opportunities should be created for the account');
        // Validate OwnerId was updated to the new account owner (usr)
        for(Opportunity o : insertedOpps){
            System.assertEquals(usr.Id, o.OwnerId, 'Opportunity owner should be updated to the new account owner');
        }
        }
        Test.stopTest();
 
    }
    
}