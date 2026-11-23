/**************************************************************************************
Apex Class Name:  Core_Opportunity_Clone_Controller_Test
Version     : 1.0 
Created Date: 3/28/16
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              3/28/16                Initial Revision
*************************************************************************************/
@isTest
public class Core_Opportunity_Clone_Controller_Test {

    final static String END_CUSTOMER_TEXT = 'End Customer';
    
    static Account                            accountForClone;
    static Account                            accountInactive;
    static List<Product2>                     lstProducts;
    static Opportunity                        opportunityInactive;
    static Opportunity                        opportunityToClone;
    static List<Opportunity>                  listOppty  = new List<Opportunity>();
    static List<Core_Opportunity_Features__c> lstOpportunityFeature;
    static List<OpportunityTeamMember>        lstOppTeamMember;
    static User                               inactiveUser;

    static ApexPages.StandardController stdController;

    static void setupTestData()
    {
        // A C C O U N T S
        
        accountForClone = Core_Test_Utility.createAccount(1)[0];
        accountForClone.Core_CIM_ID__c = '123456';
        accountForClone.Core_Military_Aerospace_and_Government__c=false;    
        insert accountForClone;

        accountInactive = Core_Test_Utility.createAccount(2)[1];
        insert accountInactive;
        

        // P R O D U C T S
        lstProducts = Core_Test_Utility.createProduct(20);
        for (Product2 prod : lstProducts) {
            prod.IsActive = true;
        }
        insert lstProducts;
        System.debug('#11 lstProducts: ' + lstProducts);


        // P R I C E B O O K        
        // Creating a list of Pricebookentry and inserting it
        List<PriceBookEntry> lstPriceBookEntry = Core_Test_Utility.createPriceBookEntry(20, lstProducts, Test.getStandardPricebookId());
        insert lstPriceBookEntry;
        

        // O P P O R T U N I T Y
        opportunityToClone = Core_Test_Utility.createOpportunity(1)[0];
        opportunityToClone.AccountId = accountForClone.Id;
        
        insert opportunityToClone;
        
        listOppty = Core_Test_Utility.createOpportunity(2);
        listOppty[0].CloseDate =  system.today().addDays(-2);
        listOppty[0].AccountId = accountForClone.Id;
        listOppty[0].StageName='Win';
        listOppty[0].Core_Military_Aerospace_Govmt_End_Use__c='No';
        listOppty[1].CloseDate =  system.today();
        listOppty[1].StageName = 'Design Win';
        listOppty[1].AccountId = accountForClone.Id;
        insert listOppty;
        System.debug('#### Oppty testing - '+listOppty);

        
        // O P P O R T U N I T Y   L I N E   I T E M
        List<OpportunityLineItem> lstOpportunityLineItem = Core_Test_Utility.createOpportunityLineItems(20, lstPriceBookEntry, opportunityToClone);
        insert lstOpportunityLineItem;
   

        // O P P O R T U N I T Y   P A R T N E R
        List<Core_Opportunity_Partner__c> lstOpportunityPartner = Core_Test_Utility.createOpportunityPartners(10, opportunityToClone);
        for (Core_Opportunity_Partner__c partner : lstOpportunityPartner) {
            partner.Core_Partner_Role__c =  END_CUSTOMER_TEXT;
        }        
        insert lstOpportunityPartner;


        // O P P O R T U N I T Y   T E A M 
        lstOppTeamMember = [SELECT Id, Name, TeamMemberRole, Core_Team_Member_Geo__c, OpportunityAccessLevel
                            FROM OpportunityTeamMember
                            WHERE OpportunityId = :opportunityToClone.Id];

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
        
        stdController = new ApexPages.StandardController(opportunityToClone);
        Core_Opportunity_Clone_Controller oppCloneController = new Core_Opportunity_Clone_Controller(stdController);
        oppCloneController.continueClone();
        
        Test.stopTest();        
    }


    // Exercise the UI
    static testMethod void opp_clone_controller_test_2()
    {
        setupTestData();
        
        Test.startTest();        

        stdController = new ApexPages.StandardController(opportunityToClone);
        Core_Opportunity_Clone_Controller oppCloneController = new Core_Opportunity_Clone_Controller(stdController);
        oppCloneController.cancelClone();
        oppCloneController.toggleDisplay();
 
        Core_Opportunity_Clone_Controller.TeamMemberSelectionWrapper tmsWrapper = new Core_Opportunity_Clone_Controller.TeamMemberSelectionWrapper(NULL);
        Boolean tmsReadonly = tmsWrapper.readOnly;        
        String  tmsGeo      = tmsWrapper.core_Team_Member_Geo;
        String  tmsLevel    = tmsWrapper.opportunityAccessLevel;
        String  tmsRole     = tmsWrapper.teamMemberRole;
        String  tmsName     = tmsWrapper.Name;

        tmsWrapper  = new Core_Opportunity_Clone_Controller.TeamMemberSelectionWrapper(lstOppTeamMember[0]);
        tmsReadonly = tmsWrapper.readOnly;        
        tmsGeo      = tmsWrapper.core_Team_Member_Geo;
        tmsLevel    = tmsWrapper.opportunityAccessLevel;
        tmsRole     = tmsWrapper.teamMemberRole;
        tmsName     = tmsWrapper.Name;
                        
        Test.stopTest();        
    }
    
    static testMethod void opp_clone_controller_test_3()
    {
        setupTestData();
        
        Test.startTest();        
        
        stdController = new ApexPages.StandardController(listOppty[0]);
        Core_Opportunity_Clone_Controller oppCloneController = new Core_Opportunity_Clone_Controller(stdController);
        oppCloneController.continueClone();
        
        Test.stopTest();        
    }
    
    static testMethod void opp_clone_controller_test_4()
    {
        setupTestData();
        
        Test.startTest();        
        
        stdController = new ApexPages.StandardController(listOppty[1]);
        Core_Opportunity_Clone_Controller oppCloneController = new Core_Opportunity_Clone_Controller(stdController);
        oppCloneController.continueClone();
        
        Test.stopTest();        
    }
}