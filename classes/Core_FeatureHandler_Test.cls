/**************************************************************************************
Apex Class Name:  Core_FeatureHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test Class for the Core_FeatureHandler trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/06/2014              Original Version
* Dave Hood                 09/21/2015              After Update test code added for single->multi-select
* Dave Hood                 10/16/2015              After Update test code added for feature value changes
* Dave Hood                 10/22/2015              After Update test code added for multi->single-select
*************************************************************************************/
@istest
public class Core_FeatureHandler_Test {

    //Declare/Initialize the Variables
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List<Opportunity> lstOpportunity = new List<Opportunity>();
    public static List<Core_Feature__c> lstFeature = new List<Core_Feature__c>{};
    public static List<Core_Feature_Header__c > lstFeatureHeader = new List<Core_Feature_Header__c >{}; 
    public static List<Core_Feature_Set__c > lstFeatureSet = new List<Core_Feature_Set__c >{};
    public static List<Core_Opportunity_Features__c> lstOpportunityFeature = new List<Core_Opportunity_Features__c >{};
    public static List<Core_Opportunity_Facts__c> lstOpportunityFacts = new List<Core_Opportunity_Facts__c>{};
    
    
    static void createTriggerExecutions() {
    
        Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate.Name = 'OpportunityFactsUpdate';
        OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert';
        OpportunityFactsUpdate.Core_Active__c = true;
        OpportunityFactsUpdate.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';
        
        Core_Trigger_Executions__c consistentMultiselect = new Core_Trigger_Executions__c();
        consistentMultiselect.Name = 'featureEnsureConsistentMultiselect';
        consistentMultiselect.Core_Object__c = 'Descriptive Feature';
        consistentMultiselect.Core_Trigger_Events__c = 'After insert';
        consistentMultiselect.Core_Active__c = true;
        consistentMultiselect.Core_Description__c = 'This is test description';
        consistentMultiselect.Core_Class_Name__c = 'Test Class';
        
        Core_Trigger_Executions__c singleToMultiSelect = new Core_Trigger_Executions__c();
        singleToMultiSelect.Name = 'featureCheckForSingleToMultiselect';
        singleToMultiSelect.Core_Object__c = 'Core_Feature__c';
        singleToMultiSelect.Core_Trigger_Events__c = 'after update';
        singleToMultiSelect.Core_Active__c = true;
        singleToMultiSelect.Core_Description__c = 'This is test description';
        singleToMultiSelect.Core_Class_Name__c = 'Test Class';
        
        Core_Trigger_Executions__c multiToSingleSelect = new Core_Trigger_Executions__c();
        multiToSingleSelect.Name = 'featureCheckForMultiToSingleSelect';
        multiToSingleSelect.Core_Object__c = 'Core_Feature__c';
        multiToSingleSelect.Core_Trigger_Events__c = 'after update';
        multiToSingleSelect.Core_Active__c = true;
        multiToSingleSelect.Core_Description__c = 'This is test description';
        multiToSingleSelect.Core_Class_Name__c = 'Test Class';
        
        Core_Trigger_Executions__c featureValueChange = new Core_Trigger_Executions__c();
        featureValueChange.Name = 'featureCheckForValueChange';
        featureValueChange.Core_Object__c = 'Core_Feature__c';
        featureValueChange.Core_Trigger_Events__c = 'after update';
        featureValueChange.Core_Active__c = true;
        featureValueChange.Core_Description__c = 'This is test description';
        featureValueChange.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(OpportunityFactsUpdate);
        lstTriggerExecution.add(consistentMultiselect);
        lstTriggerExecution.add(singleToMultiSelect);
        lstTriggerExecution.add(multiToSingleSelect);
        lstTriggerExecution.add(featureValueChange);
        
        insert lstTriggerExecution;
    }
    
    /*
    * Method name  : createData
    * Description  : method to Create the instances for the record
    * Return Type  : VOID
    * Parameter    : NONE
    */  
    static void createData(){
    
        createTriggerExecutions();
        
        // Construct the Opportunity instances
        lstOpportunity = Core_Test_Utility.Core_Opportunity(100);
        
        // Insert the intialized Opportunity 
        Database.SaveResult[] lstSaveResultCS = Database.insert(lstOpportunity, false);
        
        // Construct the Feature instances
        lstFeature = Core_Test_Utility.CreateFeature(90);
        
        // Insert the intialized Feature
        Database.SaveResult[] lstFeatureResults = Database.insert(lstFeature, false);
        
        // Construct the Feature Header instances
        lstFeatureHeader = Core_Test_Utility.CreateFeatureHeader(80);
        
        // Insert the intialized Feature Header 
        Database.SaveResult[] lstFeatureHeaderResults = Database.insert(lstFeatureHeader, false);
        
        // Construct the Feature Set instances
        lstFeatureSet = Core_Test_Utility.CreateFeatureSet(70);
        
        //Iterate through the loop
        Integer iRowNo =0;
        
        for(Core_Feature_Set__c sobjFeatureSet : lstFeatureSet){       
            sobjFeatureSet.Core_Feature__c = lstFeature[iRowNo].Id;
            sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[iRowNo].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        Database.SaveResult[] lstFeatureSetResults = Database.insert(lstFeatureSet, false);
        
        // Construct the Feature Set instances
        lstOpportunityFeature = Core_Test_Utility.CreateOpportunityFeature(60);
        
        //Iterate through the loop
        iRowNo =0;        
        for(Core_Opportunity_Features__c sobjFeatureSet : lstOpportunityFeature ){
            sobjFeatureSet.Core_Feature_Set__c = lstFeatureSet[iRowNo].Id;
            sobjFeatureSet.Core_Opportunity__c = lstOpportunity [iRowNo].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        Database.SaveResult[] lstOppFeatureResults = Database.insert(lstOpportunityFeature, false);
    }
    
    /*
    * Method name  : OpportunityfactRecordActivity
    * Description  : test method to cover Core_DescriptiveFeatureHandler trigger
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static testMethod void OpportunityfactRecordActivity(){
    
        createData();
           
        lstOpportunityFacts = [select Id, Core_Entry_SPP_Us__c from Core_Opportunity_Facts__c where Core_Entry_SPP_Us__c != null
                               order by Core_Entry_SPP_Us__c];        
      //  System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        //update lstOpportunityFeature;
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);

    //    System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
                
     //   Database.DeleteResult[] lsDeletetOppFeatureResults = Database.Delete(lstOpportunityFeature, false);
        
    }
    
    /*
    * Method name  : OpportunityfactRecordDeleteActivity
    * Description  : test method to cover Core_DescriptiveFeatureHandler trigger
    * Return Type  : VOID
    * Parameter    : NONE
    */
    static testMethod void OpportunityfactRecordDeleteActivity(){
    
        createData();
        
        lstFeature = new List<Core_Feature__c>{};
        lstFeatureHeader = new List<Core_Feature_Header__c >{}; 
        lstFeatureSet = new List<Core_Feature_Set__c >{};
        lstOpportunityFeature = new List<Core_Opportunity_Features__c >{};
        lstOpportunityFacts = new List<Core_Opportunity_Facts__c>{};
    
        lstFeature = Core_Test_Utility.CreateFeature(90);
        
        for(Core_Feature__c sobjFeature : lstFeature ){
            sobjFeature.Core_Multi_Select__c = TRUE;
        }
        
        // Insert the intialized Feature
        Database.SaveResult[] lstFeatureResults = Database.insert(lstFeature, false);
                
        // Construct the Feature Header instances
        lstFeatureHeader = Core_Test_Utility.CreateFeatureHeader(80);
        
        // Insert the intialized Feature Header 
        Database.SaveResult[] lstFeatureHeaderResults = Database.insert(lstFeatureHeader, false);
        
        // Construct the Feature Set instances
        lstFeatureSet = Core_Test_Utility.CreateFeatureSet(70);
        
        //Iterate through the loop
        Integer iRowNo =0;
        
        for(Core_Feature_Set__c sobjFeatureSet : lstFeatureSet){       
            sobjFeatureSet.Core_Feature__c = lstFeature[iRowNo].Id;
            sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[iRowNo].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        Database.SaveResult[] lstFeatureSetResults = Database.insert(lstFeatureSet, false);
        
        // Construct the Feature Set instances
        lstOpportunityFeature = Core_Test_Utility.CreateOpportunityFeature(60);
        
        //Iterate through the loop
        iRowNo =0;        
        for(Core_Opportunity_Features__c sobjFeatureSet : lstOpportunityFeature ){
            sobjFeatureSet.Core_Feature_Set__c = lstFeatureSet[iRowNo].Id;
            sobjFeatureSet.Core_Opportunity__c = lstOpportunity [iRowNo].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        Database.SaveResult[] lstOppFeatureResults = Database.insert(lstOpportunityFeature, false);
           
        lstOpportunityFacts = [select Id, Core_Entry_SPP_Us__c from Core_Opportunity_Facts__c where Core_Entry_SPP_Us__c != null
                               order by Core_Entry_SPP_Us__c];
        
     //   System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        //update lstOpportunityFeature;
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);

    //    System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
                
        //Database.DeleteResult[] lsDeletetOppFeatureResults = Database.Delete(lstOpportunityFeature, false);
        
    }
    
    /*
    * Method name  : testEnsureConsistentMultiselect
    * Description  : test method to ensure all Features of a Feature Type have the same value for multi-select
    */
    static testMethod void testEnsureConsistentMultiselect() {
    
        createTriggerExecutions();
    
        Core_Feature__c feature1 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 1',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=false);
        Core_Feature__c feature2 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 2',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=false);
        Core_Feature__c feature3 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 3',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=false);
        insert feature1;
        insert feature2;
        insert feature3;
        
        /*
        Core_Feature_Header__c featureHeader = new Core_Feature_Header__c(Core_Header_Name__c='Daves Platform',
            Core_Header_Type__c='Platform');
        insert featureHeader;
        
        // Set the Display Order to 3, 1, 2, so we can make sure the first Feature based on Display Order is kept
        Core_Feature_Set__c featureSet1 = new Core_Feature_Set__c(Core_Feature__c=feature1.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=3);
        Core_Feature_Set__c featureSet2 = new Core_Feature_Set__c(Core_Feature__c=feature2.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        Core_Feature_Set__c featureSet3 = new Core_Feature_Set__c(Core_Feature__c=feature3.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=2);
        insert featureSet1;
        insert featureSet2;
        insert featureSet3;
        
        Opportunity opp = Core_Test_Utility.Core_Opportunity(1)[0];
        insert opp;
        
        Core_Opportunity_Features__c descFeature1 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet1.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature2 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet2.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature3 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet3.Id,
            Core_Opportunity__c=opp.Id);
        insert descFeature1;
        insert descFeature2;
        insert descFeature3;
        
        Core_Opportunity_Facts__c oppFacts = [select Core_Operating_System__c from Core_Opportunity_Facts__c
                                              where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature Value 1;Feature Value 2;Feature Value 3;', oppFacts.Core_Operating_System__c);*/
        
        // Set all Features of this Feature Type to multi-select
        feature1.Core_Multi_Select__c = true;
        Core_FeatureHandler.alreadyEnsuredConsistentMultiselect = false;
        update feature1;
        
        // Make sure the other Features are set to multi-select
        feature2 = [select Core_Multi_Select__c from Core_Feature__c where Core_Feature_Value__c = 'Feature Value 2' limit 1];
        feature3 = [select Core_Multi_Select__c from Core_Feature__c where Core_Feature_Value__c = 'Feature Value 3' limit 1];
        System.assertEquals(true, feature2.Core_Multi_Select__c);
        System.assertEquals(true, feature3.Core_Multi_Select__c);
        
        // Set all Features of this Feature Type to single-select
        feature3.Core_Multi_Select__c = false;
        Core_FeatureHandler.alreadyEnsuredConsistentMultiselect = false;
        update feature3;
        
        // Make sure the other Features are set to single-select
        feature1 = [select Core_Multi_Select__c from Core_Feature__c where Core_Feature_Value__c = 'Feature Value 1' limit 1];
        feature2 = [select Core_Multi_Select__c from Core_Feature__c where Core_Feature_Value__c = 'Feature Value 2' limit 1];
        System.assertEquals(false, feature1.Core_Multi_Select__c);
        System.assertEquals(false, feature2.Core_Multi_Select__c);
    }
    
    /*
    * Method name  : testSingleToMultiselect
    * Description  : test method to ensure proper behavior when a feature changes from single to multiselect
    *                (Opportunity Facts records for that feature should have a semicolon appended)
    */
    static testMethod void testSingleToMultiselect() {
    
        createTriggerExecutions();
    
        Core_Feature__c feature = new Core_Feature__c(Core_Feature_Value__c='Feature 1',
            Core_Feature_Type__c='Chipset', Core_Multi_Select__c=false);
        insert feature;
        
        Core_Feature_Header__c featureHeader = new Core_Feature_Header__c(Core_Header_Name__c='Daves Platform',
            Core_Header_Type__c='Platform');
        insert featureHeader;
        
        Core_Feature_Set__c featureSet = new Core_Feature_Set__c(Core_Feature__c=feature.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        insert featureSet;
        
        
        Account accnt = Core_Test_Utility.createAccount(1)[0];
        accnt.Core_Sales_Groups__c = 'PRC Sales Group';
        insert accnt;
            
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.Accountid = accnt.id;
        insert opp;
        
        Core_Opportunity_Features__c descFeature = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet.Id,
            Core_Opportunity__c=opp.Id);
        insert descFeature;
        
        Core_Opportunity_Facts__c oppFacts = [select Core_Chipset__c from Core_Opportunity_Facts__c where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature 1', oppFacts.Core_Chipset__c);
        
        feature.Core_Multi_Select__c = true;
        
        Test.startTest();
        update feature;
        Test.stopTest();
        
        oppFacts = [select Core_Chipset__c from Core_Opportunity_Facts__c where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature 1;', oppFacts.Core_Chipset__c);
    }
    
    /*
    * Method name  : testMultiToSingleSelect
    * Description  : test method to ensure proper behavior when a Feature changes from multi to single-select
    *                (Opportunity Facts records for that Feature Type should be changed to just have the first
    *                value, based on Display Order, if multiple are selected)
    */
    static testMethod void testMultiToSingleSelect() {
    
        createTriggerExecutions();
    
        Core_Feature__c feature1 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 1',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=true);
        Core_Feature__c feature2 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 2',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=true);
        Core_Feature__c feature3 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 3',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=true);
        insert feature1;
        insert feature2;
        insert feature3;
        
        Core_Feature_Header__c featureHeader = new Core_Feature_Header__c(Core_Header_Name__c='Daves Platform',
            Core_Header_Type__c='Platform');
        insert featureHeader;
        
        // Set the Display Order to 3, 1, 2, so we can make sure the first Feature based on Display Order is kept
        Core_Feature_Set__c featureSet1 = new Core_Feature_Set__c(Core_Feature__c=feature1.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=3);
        Core_Feature_Set__c featureSet2 = new Core_Feature_Set__c(Core_Feature__c=feature2.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        Core_Feature_Set__c featureSet3 = new Core_Feature_Set__c(Core_Feature__c=feature3.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=2);
        insert featureSet1;
        insert featureSet2;
        insert featureSet3;
        
        Account accnt = Core_Test_Utility.createAccount(1)[0];
        accnt.Core_Sales_Groups__c = 'PRC Sales Group';
        insert accnt;
        
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.Accountid = accnt.id;
        insert opp;
        
        Core_Opportunity_Features__c descFeature1 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet1.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature2 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet2.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature3 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet3.Id,
            Core_Opportunity__c=opp.Id);
        insert descFeature1;
        insert descFeature2;
        insert descFeature3;
        
        Core_Opportunity_Facts__c oppFacts = [select Core_Operating_System__c from Core_Opportunity_Facts__c
                                              where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature Value 1;Feature Value 2;Feature Value 3;', oppFacts.Core_Operating_System__c);
        
        // Set all Features of this Feature Type to single-select
        feature1.Core_Multi_Select__c = false;
        Core_FeatureHandler.alreadyCheckedForMultiToSingleSelect = false;
        Test.startTest();
        update feature1;
        Test.stopTest();
        
        // Make sure the remaining Feature value is the second one (since it's based on Display Order)
        oppFacts = [select Core_Operating_System__c from Core_Opportunity_Facts__c
                    where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature Value 2;', oppFacts.Core_Operating_System__c);        
    }
    
    /*
    * Method name  : testFeatureValueChange
    * Description  : test method to ensure proper behavior when a feature name changes
    *                (Opportunity Facts records with that feature should have name changed as well)
    */
    static testMethod void testFeatureValueChange() {
    
        createTriggerExecutions();
    
        Core_Feature__c feature1 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 1',
            Core_Feature_Type__c='Chipset', Core_Multi_Select__c=false);
        Core_Feature__c feature2 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 2',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=true);
        Core_Feature__c feature3 = new Core_Feature__c(Core_Feature_Value__c='Feature Value 3',
            Core_Feature_Type__c='Operating System', Core_Multi_Select__c=true);
        insert feature1;
        insert feature2;
        insert feature3;
        
        Core_Feature_Header__c featureHeader = new Core_Feature_Header__c(Core_Header_Name__c='Daves Platform',
            Core_Header_Type__c='Platform');
        insert featureHeader;
        
        Core_Feature_Set__c featureSet1 = new Core_Feature_Set__c(Core_Feature__c=feature1.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        Core_Feature_Set__c featureSet2 = new Core_Feature_Set__c(Core_Feature__c=feature2.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        Core_Feature_Set__c featureSet3 = new Core_Feature_Set__c(Core_Feature__c=feature3.Id,
            Core_Feature_Header__c=featureHeader.Id, Core_Display_Order__c=1);
        insert featureSet1;
        insert featureSet2;
        insert featureSet3;
        
        Account accnt = Core_Test_Utility.createAccount(1)[0];
        accnt.Core_Sales_Groups__c = 'PRC Sales Group';
        insert accnt;
        
        Opportunity opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.Accountid = accnt.id;
        insert opp;
        
        Core_Opportunity_Features__c descFeature1 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet1.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature2 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet2.Id,
            Core_Opportunity__c=opp.Id);
        Core_Opportunity_Features__c descFeature3 = new Core_Opportunity_Features__c(Core_Feature_Set__c=featureSet3.Id,
            Core_Opportunity__c=opp.Id);
        insert descFeature1;
        insert descFeature2;
        insert descFeature3;
        
        Core_Opportunity_Facts__c oppFacts = [select Core_Chipset__c, Core_Operating_System__c from Core_Opportunity_Facts__c
                                              where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature Value 1', oppFacts.Core_Chipset__c);
        System.assertEquals('Feature Value 2;Feature Value 3;', oppFacts.Core_Operating_System__c);
        
        feature1.Core_Feature_Value__c = 'Feature Value ABC';
        feature3.Core_Feature_Value__c = 'Feature Value XYZ';
        
        List<Core_Feature__c> updatedFeatures = new List<Core_Feature__c>();
        updatedFeatures.add(feature1);
        updatedFeatures.add(feature3);
        
        Core_FeatureHandler.alreadyCheckedForValueChange = false;	// Need to reset this flag since inserts above would've set it to true already
        
        Test.startTest();
        update updatedFeatures;
        Test.stopTest();
        
        oppFacts = [select Core_Chipset__c, Core_Operating_System__c from Core_Opportunity_Facts__c
                    where Core_Opportunity_ID__c = :opp.Id limit 1];
        System.assertEquals('Feature Value ABC', oppFacts.Core_Chipset__c);
        System.assert(oppFacts.Core_Operating_System__c.contains('Feature Value XYZ;'));
    }
}