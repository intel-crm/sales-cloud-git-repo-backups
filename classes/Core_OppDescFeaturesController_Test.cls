/**************************************************************************************
Apex Class Name:  Core_OpportunityDescriptiveFeature
Version     : 1.0 
Created Date: 24 OCT 2014
Function    : Test Class for the Core_OpportunityDescriptiveFeature
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/24/2014              Original Version
*************************************************************************************/
@
isTest
public class Core_OppDescFeaturesController_Test {

    //Declare/Initialize the Variables
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List < Opportunity > lstOpportunity = new List < Opportunity > ();
    public static List < Core_Feature__c > lstFeature = new List < Core_Feature__c > {};
    public static List < Core_Feature_Header__c > lstFeatureHeader = new List < Core_Feature_Header__c > {};
    public static List < Core_Feature_Set__c > lstFeatureSet = new List < Core_Feature_Set__c > {};
    public static List < Core_Opportunity_Features__c > lstOpportunityFeature = new List < Core_Opportunity_Features__c > {};
    public static List < Core_Opportunity_Facts__c > lstOpportunityFacts = new List < Core_Opportunity_Facts__c > {};

    /*
     * Method name  : testOpportunityDescriptiveFeature
     * Description  : test method to cover Core_OpportunityDescriptiveFeature class
     * Return Type  : VOID
     * Parameter    : NONE
     */
    static testMethod void testOpportunityDescriptiveFeature() {

        Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate.name = 'OpportunityFactsUpdate';
        OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert';
        OpportunityFactsUpdate.Core_Active__c = TRUE;
        OpportunityFactsUpdate.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';

        Core_Trigger_Executions__c OpportunityFactsUpdate1 = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate1.name = 'featureSetBeforeHandler';
        OpportunityFactsUpdate1.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate1.Core_Trigger_Events__c = 'After insert';
        OpportunityFactsUpdate1.Core_Active__c = TRUE;
        OpportunityFactsUpdate1.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate1.Core_Class_Name__c = 'Test Class';

        Core_Trigger_Executions__c OpportunityFactsUpdate2 = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate2.name = 'featureBeforeHandler';
        OpportunityFactsUpdate2.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate2.Core_Trigger_Events__c = 'After insert';
        OpportunityFactsUpdate2.Core_Active__c = TRUE;
        OpportunityFactsUpdate2.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate2.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(OpportunityFactsUpdate);
        lstTriggerExecution.add(OpportunityFactsUpdate1);
        lstTriggerExecution.add(OpportunityFactsUpdate2);

        insert lstTriggerExecution;

        // Construct the Opportunity instances
        lstOpportunity = Core_Test_Utility.Core_Opportunity(6);

        // Insert the intialized Opportunity 
        Database.SaveResult[] lstSaveResultCS = Database.insert(lstOpportunity, false);

        //Iterate through the loop
        Integer iRowNo = 0;

        // Construct the Feature instances
        lstFeature = Core_Test_Utility.CreateFeature(5);

        for (Core_Feature__c coreFeature: lstFeature) {
            coreFeature.Core_Feature_Value__c = 'value' + iRowNo;
            if (iRowNo == 1) {
                coreFeature.Core_Feature_Type__c = 'Graphics';
                coreFeature.Core_Multi_Select__c = TRUE;
            }
            if (iRowNo > 1) {
                coreFeature.Core_Feature_Type__c = 'Innovation Engine';
                coreFeature.Core_Multi_Select__c = TRUE;
            }
            iRowNo++;
        }

        // Insert the intialized Feature
        Database.SaveResult[] lstFeatureResults = Database.insert(lstFeature, false);

        //Print the value
        System.Debug('---------**' + lstFeature[0] + lstFeature[1] + lstFeatureResults);

        // Construct the Feature Header instances
        lstFeatureHeader = Core_Test_Utility.CreateFeatureHeader(5);

        //Iterate through the loop
        iRowNo = 0;

        for (Core_Feature_Header__c coreFeature: lstFeatureHeader) {
            if (iRowNo == 1) {
                coreFeature.Core_Header_Type__c = System.Label.Core_IntelPlatform;
            }
            if (iRowNo == 3) {
                coreFeature.Core_Header_Type__c = 'Type2';
            }
            iRowNo++;
        }

        // Insert the intialized Feature Header 
        Database.SaveResult[] lstFeatureHeaderResults = Database.insert(lstFeatureHeader, false);

        //Print the value
        System.Debug('---------**' + lstFeatureHeader[0] + lstFeatureHeader[1]);

        // Construct the Feature Set instances
        lstFeatureSet = Core_Test_Utility.CreateFeatureSet(5);

        //Iterate through the loop
        iRowNo = 0;

        for (Core_Feature_Set__c sobjFeatureSet: lstFeatureSet) {
            sobjFeatureSet.Core_Feature__c = lstFeature[iRowNo].Id;
            sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[iRowNo].Id;
            iRowNo++;
        }

        // Insert the intialized Feature Set
        Database.SaveResult[] lstFeatureSetResults = Database.insert(lstFeatureSet, false);

        //Print the value
        System.Debug('---------**' + lstFeatureSet[0] + lstFeatureSet[1]);

        // Construct the Feature Set instances
        lstOpportunityFeature = Core_Test_Utility.CreateOpportunityFeature(4);

        //Iterate through the loop
        iRowNo = 0;
        for (Core_Opportunity_Features__c sobjFeatureSet: lstOpportunityFeature) {
            sobjFeatureSet.Core_Feature_Set__c = lstFeatureSet[iRowNo].Id;
            sobjFeatureSet.Core_Opportunity__c = lstOpportunity[0].Id;
            iRowNo++;
        }

        // Insert the intialized Feature Set
        Database.SaveResult[] lstOppFeatureResults = Database.insert(lstOpportunityFeature, false);

        //Print the value
        System.Debug('---------**' + lstOpportunityFeature[0] + lstOpportunityFeature[1]);

        PageReference pageRef = Page.Core_OppDescriptiveFeatures;
        Test.setCurrentPage(pageRef);

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(lstOpportunityFeature[0]);
        ApexPages.currentPage().getParameters().put('Id', lstOpportunityFeature[0].id);

        Core_OppDescriptiveFeaturesController controllerCoreOppDescFeature = new Core_OppDescriptiveFeaturesController(sc);
        controllerCoreOppDescFeature.saveUpdatedRecord();
        controllerCoreOppDescFeature.ReturntoOpp();

        Core_OppDescriptiveFeaturesController controllerCoreOppDescFeature1 = new Core_OppDescriptiveFeaturesController(sc);
        controllerCoreOppDescFeature1.saveUpdatedRecord();

        List < Core_Opportunity_Features__c > lstOppportunityFeature = [Select Core_Feature_Name__c, Core_Feature_Type__c from Core_Opportunity_Features__c];

        System.AssertEquals(lstOppportunityFeature[0].Core_Feature_Type__c, 'Entry SPP (US$)');
        System.AssertEquals(lstOppportunityFeature[0].Core_Feature_Name__c, 'value0');

    }
}