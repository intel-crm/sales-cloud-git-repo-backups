/**************************************************************************************
Apex Class Name:  Core_DescriptiveFeatureHandler_Test
Version     : 1.0 
Created Date: 06 OCT 2014
Function    : Test Class for the Core_DescriptiveFeatureHandler trigger
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/06/2014              Original Version
*************************************************************************************/
@istest
public class Core_DescriptiveFeatureHandler_Test{

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
        //lstOpportunity = Core_Test_Utility.Core_Opportunity(100);
         SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
         Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
         Account accountInstance = new Account(Name = 'TestoppAcchandle', BillingStreet = '123 Fake St',
                                              BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production',
                                              BillingPostalCode = '12345',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),RecordTypeId=recTypeId);
        
      	insert accountInstance;
       		Opportunity opportunityInstance = new Opportunity();
            opportunityInstance.CloseDate = System.Today().addDays(24);
            opportunityInstance.StageName = 'Qualify';
            opportunityInstance.Name = 'TestRE1';
            opportunityInstance.AccountId =accountInstance.id;
            opportunityInstance.Core_Product_Segment__c='Client Computing';
            opportunityInstance.Core_Consumption_Market__c = 'Education';
            opportunityInstance.Core_Product_Application__c ='Business Mobility';
            opportunityInstance.Core_Opportunity_Type__c = 'Design: Original';
            opportunityInstance.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
            opportunityInstance.Description = 'test';
            opportunityInstance.Core_IsClone__c = False;
 			lstOpportunity.add(opportunityInstance);
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
            sobjFeatureSet.Core_Opportunity__c = lstOpportunity [0].Id;
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
        
     //   System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        //update lstOpportunityFeature;
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);

     //   System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
                
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
    	List<Core_Feature__c> featureList = [SELECT Id,Core_Feature_Type__c,Core_Feature_Value__c FROM Core_Feature__c LIMIT 70];
        //lstFeature = Core_Test_Utility.CreateFeature(90);
        
        for(Core_Feature__c sobjFeature : featureList ){
            sobjFeature.Core_Multi_Select__c = false;
        }
        
        // Insert the intialized Feature
        Database.SaveResult[] lstFeatureResults = Database.update(featureList, false);
        
        List<Core_Feature_Header__c> headList=[SELECT Id,Core_Header_Name__c,Core_Header_Type__c FROM Core_Feature_Header__c];
       
        // Construct the Feature Set instances
        lstFeatureSet = Core_Test_Utility.CreateFeatureSet(70);
        
        //Iterate through the loop
        Integer iRowNo =0;
        
        for(Core_Feature_Set__c sobjFeatureSet : lstFeatureSet){       
            sobjFeatureSet.Core_Feature__c = featureList[iRowNo].Id;
            sobjFeatureSet.Core_Feature_Header__c = headList[iRowNo].Id;
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
            sobjFeatureSet.Core_Opportunity__c = lstOpportunity [0].Id;
            iRowNo++;
        }
        
        // Insert the intialized Feature Set
        Database.SaveResult[] lstOppFeatureResults = Database.insert(lstOpportunityFeature, false);
        system.debug('Test class lstOpportunityFeature'+lstOppFeatureResults);  
        lstOpportunityFacts = [select Id, Core_Entry_SPP_Us__c from Core_Opportunity_Facts__c where Core_Entry_SPP_Us__c != null
                               order by Core_Entry_SPP_Us__c];
        system.debug('OPP FACTS'+lstOpportunityFacts);
       // System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
        
        lstOpportunityFeature[0].Core_Feature_Set__c=lstFeatureSet[1].Id;
        system.debug('Test class 2 lstOpportunityFeature'+lstOpportunityFeature); //update lstOpportunityFeature; 
        Database.SaveResult[] lstOppFeatureResults1 = Database.Update(lstOpportunityFeature, false);
        system.debug('Test class 3 lstOpportunityFeature'+lstOpportunityFeature);
     //   System.assertEquals('value0', lstOpportunityFacts[0].Core_Entry_SPP_Us__c);
        Database.DeleteResult[] lsDeletetOppFeatureResults = Database.Delete(lstOpportunityFeature, false);
        system.debug('Test class 4 lsDeletetOppFeatureResults'+lsDeletetOppFeatureResults);
    }
}