/*********************************************************************************************************************
Apex Class Name  : PMP_PIMTaxonomyJobSync
Version          : 1.0
Created Date     : 29/09/2021

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal        29/09/2021            This class exposes custom api to Mulesoft System to process static resource files in real time  
*********************************************************************************************************************/
// Custom API  /services/apexrest/PIMTaxonomySync/
@RestResource(urlMapping='/PIMTaxonomySync/')
global with sharing class PMP_PIMTaxonomyJobSync { 
    
    @HttpPost 
    global static String invokeTaxonomyProcessing(String modifiedFileNames){ 
        Map<String,Decimal> processOrderByName = new Map<String,Decimal>();
        Set<String> uniqueTaxonomyStaticResourceNames = new Set<String>();
        //Set<String> modifiedTaxonomyStaticResourceNames = new Set<String>();
        List<String> staticResoucesToBeProcessed = new List<String>();
        Map<Integer,String> orderedStaticResMap = new Map<Integer,String>();
        List<Integer> staticResOrderIndicator = new List<Integer>();
        List<StaticResource> taxonomyStaticResources = new  List<StaticResource>();
        // System.debug('modifiedFileNames' + modifiedFileNames);
        
        // first process the delta file then process other files received from PIM
       /* if(modifiedFileNames.contains('Delta_IPA_Products'))
        {
            PMP_ParseAllFilesJSONDelta.parseAllFilesJSONDelta('Delta_IPA_Products');
        }*/
        List<String> fileNames = modifiedFileNames.split(',');
        // System.debug('fileNames' + fileNames);
        for(String fileName: fileNames)
        {
            if(fileName!='Delta_IPA_Products')
            {
                 uniqueTaxonomyStaticResourceNames.add(fileName); 
            }
        }  
        //system.debug('uniqueTaxonomyStaticResourceNames' + uniqueTaxonomyStaticResourceNames);
        staticResOrderIndicator = new List<Integer>();
        staticResoucesToBeProcessed = new List<String>();
        if(fileNames.size()>0)
        {
            
            for(PMP_Taxonomy_Static_Resource_Exec_Order__mdt StaticResourceExecOrd :[Select Static_Resource_Name__c,Execution_Order__c 
                                                                                     from PMP_Taxonomy_Static_Resource_Exec_Order__mdt where Static_Resource_Name__c != null])
            {
                //Assign the values to map of Static resource name and order
                processOrderByName.put(StaticResourceExecOrd.Static_Resource_Name__c,StaticResourceExecOrd.Execution_Order__c);
            }
            //System.debug('processOrderByName-->'+processOrderByName);
            //System.debug('uniqueTaxonomyStaticResourceNames-->'+uniqueTaxonomyStaticResourceNames);
            // those will be executed to convert into salesforce taxonomy records
            
            if(Test.isRunningTest()) {
                uniqueTaxonomyStaticResourceNames = new Set<String>{'Hierarchy_English'};
                    
                    taxonomyStaticResources = [SELECT Id,Name,SystemModStamp FROM StaticResource where Name in :uniqueTaxonomyStaticResourceNames];
                
            }
            else {
                
                taxonomyStaticResources  = [SELECT Id,Name,SystemModStamp FROM StaticResource where Name in :uniqueTaxonomyStaticResourceNames];
            }
            if(taxonomyStaticResources.size()>0)
            {
                for(StaticResource stat : taxonomyStaticResources) {
                    orderedStaticResMap.put(Integer.valueOf(processOrderByName.get(stat.Name)),stat.Name);
                    staticResOrderIndicator.add(Integer.valueOf(processOrderByName.get(stat.Name)));
                }
            }  
            //System.debug('orderedStaticResMap-->'+orderedStaticResMap);
            //System.debug('staticResOrderIndicator-->'+staticResOrderIndicator);
            
            if(!orderedStaticResMap.keySet().isEmpty()) { 
                
                // Sort the Static resources order in order to pass in the same execution order to execute method
                staticResOrderIndicator.sort();
                
                for(Integer i=0;i<staticResOrderIndicator.size();i++) {
                    staticResoucesToBeProcessed.add(orderedStaticResMap.get(staticResOrderIndicator[i]));
                }  
                
                //system.debug('###staticResoucesToBeProcessed:->'+staticResoucesToBeProcessed); 
                if(staticResoucesToBeProcessed.size()>0)
                {
                  //Calling Taxonomy Job to load static resources
                  System.enqueueJob(new PMP_TaxonomyUploadQueueable(staticResoucesToBeProcessed));   
                }                 
            }   
        }            
        
      return fileNames.size()+' Files Successful';
    }
}