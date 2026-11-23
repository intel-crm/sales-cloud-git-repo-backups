/**************************************************************************************
Apex Class Name:  Core_FeatureSetHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test Class for the Core_FeatureSetHandler trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/06/2014              Original Version
*************************************************************************************/
@istest
public class Core_FeatureSetHandler_Test{

    //Declare/Initialize the Variables
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List<Opportunity> lstOpportunity = new List<Opportunity>();
    public static List<Core_Feature__c> lstFeature = new List<Core_Feature__c>{};
    public static List<Core_Feature_Header__c > lstFeatureHeader = new List<Core_Feature_Header__c >{}; 
    public static List<Core_Feature_Set__c > lstFeatureSet = new List<Core_Feature_Set__c >{};
    public static List<Core_Opportunity_Features__c> lstOpportunityFeature = new List<Core_Opportunity_Features__c >{};
    public static List<Core_Opportunity_Facts__c> lstOpportunityFacts = new List<Core_Opportunity_Facts__c>{};
    
    /*
    * Method name  : createData
    * Description  : method to Create the instances for the record
    * Return Type  : VOID
    * Parameter    : NONE
    */ 
    static void createData(){
    
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

        lstTriggerExecution.add(OpportunityFactsUpdate);
        lstTriggerExecution.add(OpportunityFactsUpdate1);
        
        insert lstTriggerExecution;
        
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
           
        lstOpportunityFacts = [Select id,Core_Entry_SPP_US__c from Core_Opportunity_Facts__c
                               where Core_Entry_SPP_US__c != null order by Core_Entry_SPP_US__c];
        
        //System.assertEquals(lstOpportunityFacts[0].Core_Entry_SPP_US__c,'value0');
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        //update lstOpportunityFeature;
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);

        //System.assertEquals(lstOpportunityFacts[0].Core_Entry_SPP_US__c,'value0');
                
        Database.DeleteResult[] lsDeletetOppFeatureResults = Database.Delete(lstOpportunityFeature, false);
        
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
        
        System.debug('----------'+lstFeature);
        
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
           
        lstOpportunityFacts = [Select id,Core_Entry_SPP_US__c from Core_Opportunity_Facts__c
                               where Core_Entry_SPP_US__c != null order by Core_Entry_SPP_US__c];
        
        //System.assertEquals(lstOpportunityFacts[0].Core_Entry_SPP_US__c,'value0');
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        //update lstOpportunityFeature;
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);

        //System.assertEquals(lstOpportunityFacts[0].Core_Entry_SPP_US__c,'value0');
                
        //Database.DeleteResult[] lsDeletetOppFeatureResults = Database.Delete(lstOpportunityFeature, false);
        
    }
}