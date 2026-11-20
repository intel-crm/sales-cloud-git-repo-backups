/**************************************************************************************
Apex Class Name:  Core_OpportunityDescriptiveFeature
Version     : 1.0 
Created Date: 24 OCT 2014
Function    : Test Class for the Core_OpportunityDescriptiveFeature
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Srikant Joshi             10/24/2014              Original Version
* Laxmana Lenka             05/10/2018              US103701: Updated as the test class was failing for Sales group and platform restricted field value.
*************************************************************************************/
@isTest
public class Core_OppDescFeaturesController_Test {

    //Declare/Initialize the Variables
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List < Opportunity > lstOpportunity = new List < Opportunity > ();
    public static List < Account > lstAccount = new List < Account > ();
    public static List < Core_Feature__c > lstFeature = new List < Core_Feature__c > {};
    public static List < Core_Feature_Header__c > lstFeatureHeader = new List < Core_Feature_Header__c > {};
    public static List < Core_Feature_Set__c > lstFeatureSet = new List < Core_Feature_Set__c > {};
    public static List < Core_Opportunity_Features__c > lstOpportunityFeature = new List < Core_Opportunity_Features__c > {};
    public static List < Core_Opportunity_Facts__c > lstOpportunityFacts = new List < Core_Opportunity_Facts__c > {};
	public static List < Product2 > lstProducts = new List < Product2 > {}; 
    public static List < PricebookEntry > lstPricebook = new List < PricebookEntry > {}; 
    public static List < OpportunityLineItem > lstOppLineItem = new List < OpportunityLineItem > {};
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
        //START - US103701, Added Sales group added to account, as opportuntiy can not be created for accounts
        Id masterRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        lstAccount = Core_Test_Utility.Core_Account(6);
        for (Account acc: lstAccount) {
            acc.RecordTypeId=masterRecordTypeId;
            acc.Core_Sub_Industry__c='Accommodation';
            acc.Industry='Accommodation and Food Services';
            acc.BillingCity='Seoul';
            acc.BillingCountry='KOR';
            acc.BillingStreet='KOR';
            acc.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
        }
        //END - US103701, Added Sales group added to account, as opportuntiy can not be created for accounts
        
        Database.SaveResult[] lstSaveResultAcc = Database.insert(lstAccount, false);        
        
        Integer iRowNo = 0;         
        lstOpportunity = Core_Test_Utility.Core_Opportunity(6);
        
        
        //START - US103701, Added platform value as it is a restricted picklist 
        for (Opportunity opp: lstOpportunity) {
            opp.AccountId = lstAccount[iRowNo].Id;
            opp.Core_Intel_Platform__c = 'ALDER LAKE';          
            iRowNo++;
        }
        //END - US103701, Added platform value as it is a restricted picklist 
        lstOpportunity[0].AccountId = lstAccount[0].Id;
        Database.SaveResult[] lstSaveResultCS = Database.insert(lstOpportunity, false);
        

        //Iterate through the loop
        iRowNo = 0;
        // Construct the Feature instances
        lstFeature = Core_Test_Utility.CreateFeature(5);

        //START - US103701, added multiple featuere type with same features and multi select/single select, to test the required scenario
        for (Core_Feature__c coreFeature: lstFeature) {
                       
            coreFeature.Core_Feature_BU__c='CCG';
            if (iRowNo == 0) {
                coreFeature.Core_Feature_Type__c = 'Google-Android';
                coreFeature.Core_Multi_Select__c = TRUE;
                coreFeature.Core_Feature_Value__c ='Google-Android';                
            }
            if (iRowNo == 1) {
                coreFeature.Core_Feature_Type__c = 'Google-Android2';
                coreFeature.Core_Multi_Select__c = False;
                coreFeature.Core_Feature_Value__c ='Google-Android2';

            }
            if (iRowNo == 2) {
                coreFeature.Core_Feature_Type__c = 'Google-Android';
                coreFeature.Core_Multi_Select__c = TRUE;
                coreFeature.Core_Feature_Value__c = 'Google';
            }
            if (iRowNo == 3) {
                coreFeature.Core_Feature_Type__c = 'Consumer Sales system';
                coreFeature.Core_Multi_Select__c = False;
                coreFeature.Core_Feature_Value__c = 'Sales';
            }
            if (iRowNo > 3) {
                coreFeature.Core_Feature_Type__c = 'Google Chrome';
                coreFeature.Core_Multi_Select__c = False;
                coreFeature.Core_Feature_Value__c = 'Value'+iRowNo; 
            }
            iRowNo++;
        }
        //END - US103701, added multiple featuere type with same features and multi select/single select, to test the required scenario.
        
        // Insert the intialized Feature
        Database.SaveResult[] lstFeatureResults = Database.insert(lstFeature, false);
        //Print the value
      
        // Construct the Feature Header instances
        lstFeatureHeader = Core_Test_Utility.CreateFeatureHeader(5);
        //Iterate through the loop
        iRowNo = 0;
        
        //START - US103701, added multiple platform header with multiple Header type
        for (Core_Feature_Header__c coreFeature: lstFeatureHeader) {
            if (iRowNo == 0){
                coreFeature.Core_Header_Type__c = System.Label.Core_IntelPlatform;
                coreFeature.Core_Header_Name__c='Apollo Lake D';
            }
            if (iRowNo == 1){
                coreFeature.Core_Header_Type__c = 'Intel2';
                coreFeature.Core_Header_Name__c='Apollo Lake D';
            }
            if (iRowNo == 2){
                coreFeature.Core_Header_Type__c = System.Label.Core_IntelPlatform;
                coreFeature.Core_Header_Name__c='Apollo Lake I';
            }
            if (iRowNo > 2){
                coreFeature.Core_Header_Name__c='Intel2'+iRowNo;
                coreFeature.Core_Header_Type__c = 'Type'+iRowNo;
            }
            iRowNo++;
        }
        //END - US103701, added multiple platform header with multiple Header type
        // Insert the intialized Feature Header 
        Database.SaveResult[] lstFeatureHeaderResults = Database.insert(lstFeatureHeader, false);

        //Print the value
        

        // Construct the Feature Set instances
        lstFeatureSet = Core_Test_Utility.CreateFeatureSet(5);

        //Iterate through the loop
        iRowNo = 0;
        //START - US103701, updated required header and feature while creating feature set
        for (Core_Feature_Set__c sobjFeatureSet: lstFeatureSet) {
            
            if (iRowNo >= 3) {
                sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[3].Id;
                sobjFeatureSet.Core_Feature__c = lstFeature[iRowNo].Id;
            }else if(iRowNo == 0){
            sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[0].Id;
            sobjFeatureSet.Core_Feature__c = lstFeature[0].Id;
            }else if(iRowNo == 1){
                sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[0].Id;
                sobjFeatureSet.Core_Feature__c = lstFeature[1].Id;
            }else if(iRowNo == 2){
                sobjFeatureSet.Core_Feature_Header__c = lstFeatureHeader[1].Id;
                sobjFeatureSet.Core_Feature__c = lstFeature[2].Id;
            }
            
            iRowNo++;
        }
        //END - US103701, added multiple platform header with multiple Header type
        // Insert the intialized Feature Set
        Database.SaveResult[] lstFeatureSetResults = Database.insert(lstFeatureSet, false);

        //Print the value
        

        // Construct the Feature Set instances
        lstOpportunityFeature = Core_Test_Utility.CreateOpportunityFeature(3);
        

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
        

        PageReference pageRef = Page.Core_OppDescriptiveFeatures;
        Test.setCurrentPage(pageRef);

        
         lstProducts = Core_Test_Utility.createProduct(1);
        Database.insert(lstProducts);
        lstPricebook = Core_Test_Utility.createPriceBookEntry(1,lstProducts, Test.getStandardPricebookId()); 
            Database.insert(lstPricebook);
        lstOppLineItem = Core_Test_Utility.createOpportunityLineItems(1,lstPricebook, lstOpportunity[0]);
        lstOppLineItem[0].OpportunityId = lstOpportunity[0].Id;
            Database.insert(lstOppLineItem);
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(lstOpportunityFeature[0]);
        
        ApexPages.currentPage().getParameters().put('Id', lstOpportunityFeature[0].id);
		//ApexPages.currentPage().getParameters().put('sOppProdid', lstOppLineItem[0].id);
        Core_OppDescriptiveFeaturesController controllerCoreOppDescFeature = new Core_OppDescriptiveFeaturesController(sc);
        controllerCoreOppDescFeature.sObjOpp = lstOpportunity[0];
        controllerCoreOppDescFeature.consumerSales= 'SKU';
        controllerCoreOppDescFeature.saveUpdatedRecord();
        controllerCoreOppDescFeature.ReturntoOpp();
        
        
        
        //START - US103701, calling the apex controller , page input and save, when page opened from Edit descriptive feature button.
        ApexPages.Standardcontroller sc2 = new ApexPages.Standardcontroller(lstOpportunityFeature[0]);//TWC3123-4019 changed lstOpportunity[0]
        
        //ApexPages.currentPage().getParameters().put('sOppid', lstOpportunity[0].id);
        ApexPages.currentPage().getParameters().put(System.label.Core_Opportunity_ID, lstOpportunity[0].id);
        ApexPages.currentPage().getParameters().put('sOppProdid', lstOppLineItem[0].id);//TWC3123-4019 changed lstOpportunity[0]
        Core_OppDescriptiveFeaturesController controllerCoreOppDescFeature2 = new Core_OppDescriptiveFeaturesController(sc2);
        controllerCoreOppDescFeature2.sObjOpp = lstOpportunity[0];
        controllerCoreOppDescFeature2.selectedPlatformBU='CCG';
        controllerCoreOppDescFeature2.sPlatform='Apollo Lake D';   
        controllerCoreOppDescFeature2.Core_GetFeature();
        controllerCoreOppDescFeature2.saveUpdatedRecord();
            //controllerCoreOppDescFeature2.ReturntoOpp();
        //END - US103701, calling the apex controller , page input and save, when page opened from Edit descriptive feature button.
		Core_OppDescriptiveFeaturesController controllerCoreOppDescFeature3 = new Core_OppDescriptiveFeaturesController(sc2);
        controllerCoreOppDescFeature3.sObjOpp = lstOpportunity[0];
        controllerCoreOppDescFeature3.selectedPlatformBU='CCG';
        controllerCoreOppDescFeature3.sPlatform='Apollo Lake D';
        controllerCoreOppDescFeature3.getPlatformBU();
        List<SelectOption> expectedOptions = new List<SelectOption> {
            new SelectOption('--None--', '--None--'),
            new SelectOption('CCG', 'CCG')
        };
        System.assertEquals(expectedOptions, controllerCoreOppDescFeature3.platformBULst);
    }
}