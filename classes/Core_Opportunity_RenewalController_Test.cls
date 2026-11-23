@isTest
public class Core_Opportunity_RenewalController_Test {

    final static String END_CUSTOMER_TEXT = 'End Customer';
    
    static Account                            accountForClone;
    static Account                            accountInactive;
    static List<Product2>                     lstProducts;
    static Opportunity                        opportunityInactive;
    static Opportunity                        opportunityToClone;
    static Opportunity                        partnerOppToClone;
    static List<Opportunity>                  listOppty  = new List<Opportunity>();
    static List<Core_Opportunity_Features__c> lstOpportunityFeature;
    static List<OpportunityTeamMember>        lstOppTeamMember;
    static User                               inactiveUser;

    static ApexPages.StandardController stdController;
    public static List<Core_Trigger_Executions__c> triggExecList = new List<Core_Trigger_Executions__c>();
    
    static void setupTestData()
    {
    
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;      
        
        // A C C O U N T S
        triggExecList.add(new Core_Trigger_Executions__c(Name='opptyCloneErrorMsg', Core_Class_Name__c='Test', Core_Object__c='Test',Core_Trigger_Events__c='Test', Core_Active__c=true, Core_Description__c = 'Test'));
        insert triggExecList;
        accountForClone = Core_Test_Utility.createAccount(1)[0];
        //accountForClone.Core_CIM_ID__c = '123456';
        accountForClone.Core_Military_Aerospace_and_Government__c=true; 
        //accountForClone.Core_Sales_Groups__c = 'Americas Brazil Sales Group'; 
        accountForClone.Core_Sales_Groups__c = 'Americas ELAR Sales Group';
        
        //setting record type for bypassing validation "Core_Account_Check_OnCreate_Update"
        ID intelAccID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        accountForClone.RecordTypeId = intelAccID;
        insert accountForClone;
        
          // Create Parent Account
        Account parentAccount = UCD_ACM_Cntrlr_TestDataInitialization.createAccountByRecordType('TestParentAccount','Intel Account','UNFD_GLBL_CUST');
        parentAccount.Core_Data_Country_Nm__c = 'India';
        parentAccount.Industry = 'Agriculture';
        parentAccount.Core_Sub_Industry__c = 'Animal Production';
        parentAccount.Core_Sales_Groups__c='Americas Brazil Sales Group';
        //unitOfWork.registerNew(parentAccount);
        
        ChannelProgram channelProgram = new ChannelProgram();
        channelProgram.name = 'ChannelPartnerRecord';
        channelProgram.Core_MDF_Channel_Program_Unique_Id_nm__c= '123';
        channelProgram.PRM_inactind__c = true;
        channelProgram.PRM_programCode__c = 'test';
        insert channelProgram;

        //accountInactive = Core_Test_Utility.createAccount(2)[1];
       
        //insert accountInactive;
        

        // P R O D U C T S
        lstProducts = Core_Test_Utility.createProduct(20);
        for (Product2 prod : lstProducts) {
            prod.IsActive = true;
        }
        insert lstProducts;
        System.debug('#11 lstProducts: ' + lstProducts);


        // P R I C E B O O K     
        List<PriceBook2> lstPriceBook = Core_Test_Utility.createPriceBook(1); 
        //lstPriceBook[1].IsStandard =false;  
        insert lstPriceBook;
        // Creating a list of Pricebookentry and inserting it
        List<PriceBookEntry> lstPriceBookEntry = Core_Test_Utility.createPriceBookEntry(20, lstProducts,Test.getStandardPricebookId() );
        
        insert lstPriceBookEntry;
        

        // O P P O R T U N I T Y
        opportunityToClone = Core_Test_Utility.createOpportunity(1)[0];
        opportunityToClone.Core_Opportunity_Type__c ='Design: Secondary';
        opportunityToClone.AccountId = accountForClone.Id;
        opportunityToClone.StageName = 'Qualify';
        //opportunityToClone.PriceBook2Id = lstPriceBook[0].Id;
        opportunityToClone.Core_Channel_Opportunity_Ind__c = true;
        opportunityToClone.Core_Technical_Owner__c = UserInfo.getUserId();       
        
             /* US ---TWC4767-2116 */
         // V B S
         opportunityToClone.Core_VBS_Potential__c = false;
         opportunityToClone.Core_VBS_Status__c= null;         
         opportunityToClone.CRM_VBS_Primary_VBS_Offering_Category__c =null;
         opportunityToClone.CRM_VBS_Opp_Owner_Changed_For_VBS__c =false;
         opportunityToClone.CRM_VBS_Contract_Lifetime_in_Months__c=6;
         opportunityToClone.CRM_VBS_Contract_Start_Date__c = System.today();
         opportunityToClone.CRM_VBS_Total_Contract_Value__c =0;
         opportunityToClone.CRM_VBS_Annual_Recurring_Revenue__c =0;
        insert opportunityToClone;
        
        listOppty = Core_Test_Utility.createOpportunity(2);
        listOppty[0].CloseDate =  system.today().addDays(-2);
        listOppty[0].AccountId = accountForClone.Id;
        listOppty[0].StageName='Qualify';
        //listOppty[0].StageName='Win';
        listOppty[0].Core_Military_Aerospace_Govmt_End_Use__c='No';
        listOppty[0].CloseDate =  system.today();
        //listOppty[0].StageName = 'Design Win';
        listOppty[0].AccountId = accountForClone.Id;
        
        listOppty[1].CloseDate =  system.today().addDays(-2);
        listOppty[1].AccountId = accountForClone.Id;
        listOppty[1].StageName='Qualify';
        //listOppty[1].StageName='Win';
        listOppty[1].Core_Military_Aerospace_Govmt_End_Use__c='No';
        listOppty[1].CloseDate =  system.today();
        //listOppty[1].StageName = 'Design Win';
        listOppty[1].AccountId = accountForClone.Id;
        listOppty[1].Core_Channel_Opportunity_Ind__c=true;
        insert listOppty;
        System.debug('#### Oppty testing - '+listOppty);
        
        //partner Opportunity to clone
        partnerOppToClone = Core_Test_Utility.createOpportunity(1)[0];
        partnerOppToClone.AccountId = accountForClone.Id;
        partnerOppToClone.StageName='Qualify';
        partnerOppToClone.Core_Channel_Opportunity_Ind__c=true;
         /* US ---TWC4767-2116 */
         // V B S
         partnerOppToClone.Core_VBS_Potential__c = false;
         partnerOppToClone.Core_VBS_Status__c= null;         
         partnerOppToClone.CRM_VBS_Primary_VBS_Offering_Category__c =null;
         partnerOppToClone.CRM_VBS_Opp_Owner_Changed_For_VBS__c =false;
         partnerOppToClone.CRM_VBS_Contract_Lifetime_in_Months__c=0;
         partnerOppToClone.CRM_VBS_Contract_Start_Date__c = null;
         partnerOppToClone.CRM_VBS_Total_Contract_Value__c =0;
         partnerOppToClone.CRM_VBS_Annual_Recurring_Revenue__c =0;
       
        insert partnerOppToClone;
        
        Attachment attach=new Attachment();      
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=partnerOppToClone.id;
        insert attach;
        
        Note n = new note(parentid=partnerOppToClone.id,title='test note',body='test note contents');
        insert n;
        
        System.debug('#### Oppty testing - '+listOppty);

        
        // O P P O R T U N I T Y   L I N E   I T E M
        List<OpportunityLineItem> lstOpportunityLineItem = Core_Test_Utility.createOpportunityLineItems(20, lstPriceBookEntry, opportunityToClone);
        insert lstOpportunityLineItem;
   

        // O P P O R T U N I T Y   P A R T N E R
        List<Core_Opportunity_Partner__c> lstOpportunityPartner = Core_Test_Utility.createOpportunityPartners(10, opportunityToClone);
        for (Core_Opportunity_Partner__c partner : lstOpportunityPartner) {
            partner.Core_Partner_Role__c =  END_CUSTOMER_TEXT;
        }    
         List<Core_Opportunity_Partner__c> lstOpportunityPartner1 = Core_Test_Utility.createOpportunityPartners(10, partnerOppToClone);
        for (Core_Opportunity_Partner__c partner : lstOpportunityPartner1) {
            partner.Core_Partner_Role__c =  END_CUSTOMER_TEXT;
        }        
        insert lstOpportunityPartner;
        insert lstOpportunityPartner1;
        
        // O P P O R T U N I T Y  S O L U T I O N
        Core_Solution_Areas__c sol = new Core_Solution_Areas__c(Name = 'Solution', Core_End_Customer_Solution__c = 'Yes');
        insert sol;
        Opportunity_Solution_Area__c OppSol = new Opportunity_Solution_Area__c(Core_Solution_Areas__c = sol.Id, Core_Opportunity__c = opportunityToClone.Id);
        insert OppSol;


        // O P P O R T U N I T Y   T E A M 
        OpportunityTeamMember otm  = new OpportunityTeamMember();
        otm.TeamMemberRole         = 'Team Member (100%)';
        otm.UserId                 =  Core_Test_Utility.systemAdminUser.id;
        otm.OpportunityId          =  opportunityToClone.Id;
        otm.OpportunityAccessLevel =  'Edit';
        otm.Core_Description_of_Contribution__c = 'Testing';
        insert otm;
                                
        lstOppTeamMember = [SELECT Id, Name, TeamMemberRole, Core_Team_Member_Geo__c, OpportunityAccessLevel
                            FROM OpportunityTeamMember
                            WHERE OpportunityId = :opportunityToClone.Id];
        system.debug('AACLONE '+lstOppTeamMember);
        // O P P O R T U N I T Y   F E A T U R E S
        createOpportunityFeatures(opportunityToClone);        
    }
    

    static void createOpportunityFeatures(Opportunity oppTarget)
    {
        // Construct the Feature instances
        List<Core_Feature__c> lstFeature = Core_Test_Utility.CreateFeature(90);
        
        // Insert the intialized Feature
        List<Database.SaveResult> lstFeatureResults = Database.insert(lstFeature, false);
        
        System.debug('--------'+lstFeature[0]+lstFeature[1]);
        
        // Construct the Feature Header instances
        List<Core_Feature_Header__c > lstFeatureHeader = Core_Test_Utility.CreateFeatureHeader(80);
        
        // Insert the intialized Feature Header 
        List<Database.SaveResult> lstFeatureHeaderResults = Database.insert(lstFeatureHeader, false);
                        
        System.debug('--------'+lstFeatureHeader[0]+lstFeatureHeader[1]);
        
        // Construct the Feature Set instances
        List<Core_Feature_Set__c > lstFeatureSet = Core_Test_Utility.CreateFeatureSet(70);
        
        //Iterate through the loop
        Integer iRowNo =0;
        
        for(Core_Feature_Set__c sobjFeatureSet : lstFeatureSet){       
            sobjFeatureSet.Core_Feature__c = lstFeature[iRowNo].Id;
            sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[iRowNo].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        List<Database.SaveResult> lstFeatureSetResults = Database.insert(lstFeatureSet, false);        
                        
        System.debug('--------'+lstFeatureSet[0]+lstFeatureSet[1]);
        
        // Construct the Feature Set instances
        lstOpportunityFeature = Core_Test_Utility.CreateOpportunityFeature(60);
        
        //Iterate through the loop
        iRowNo =0;        
        for(Core_Opportunity_Features__c sobjFeatureSet : lstOpportunityFeature ){
            sobjFeatureSet.Core_Feature_Set__c = lstFeatureSet[iRowNo].Id;
            sobjFeatureSet.Core_Opportunity__c = oppTarget.Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        List<Database.SaveResult> lstOppFeatureResults = Database.insert(lstOpportunityFeature, false);
        
        System.debug('--------' + lstOpportunityFeature[0] + lstOpportunityFeature[1]);
    }


    static testMethod void opp_clone_controller_test_1()
    {
        setupTestData();
        
        Test.startTest();        
        
        Core_Opportunity_RenewalController oppCloneController = new Core_Opportunity_RenewalController();
        Core_Opportunity_RenewalController.isPartner = true;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opportunityToClone);
        List<Id> renewalId = new List<Id>();
        renewalId = Core_Opportunity_RenewalController.createRenewalOpportunity(oppList);
        Core_Opportunity_RenewalController.isPartner = false;
        renewalId = Core_Opportunity_RenewalController.createRenewalOpportunity(oppList);
        Test.stopTest(); 
        Assert.areEqual(true, renewalId!=null);     
    }
    
    
        static testMethod void opp_clone_controller_test_2()
    {
        setupTestData();
        
        Test.startTest();        

        
        Core_Opportunity_RenewalController.TeamMemberSelectionWrapper tmsWrapper = new Core_Opportunity_RenewalController.TeamMemberSelectionWrapper(NULL);
        Boolean tmsReadonly = tmsWrapper.readOnly;        
        String  tmsGeo      = tmsWrapper.core_Team_Member_Geo;
        String  tmsLevel    = tmsWrapper.opportunityAccessLevel;
        String  tmsRole     = tmsWrapper.teamMemberRole;
        String  tmsName     = tmsWrapper.Name;

        tmsWrapper  = new Core_Opportunity_RenewalController.TeamMemberSelectionWrapper(lstOppTeamMember[0]);
        tmsReadonly = tmsWrapper.readOnly;        
        tmsGeo      = tmsWrapper.core_Team_Member_Geo;
        tmsLevel    = tmsWrapper.opportunityAccessLevel;
        tmsRole     = tmsWrapper.teamMemberRole;
        tmsName     = tmsWrapper.Name;
        
        Assert.areEqual(true, tmsWrapper!=null);  
        Test.stopTest(); 
                   
    }
}