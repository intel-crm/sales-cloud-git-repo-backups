/****************************************************************************************************************************************
* Class Name  : PMP_ScheduleTaxonomyUpload 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     04/11/2019                    US329999 - Scheduler to read the Static Resources received from PIM
* ****************************************************************************************************************************************/
global with sharing class PMP_ScheduleTaxonomyUpload implements Schedulable {
    
    Map<String,Decimal> processOrderByName = new Map<String,Decimal>();
    Set<String> uniqueTaxonomyStaticResourceNames = new Set<String>();
    Date todaysdate ;
    Date yesterdayDate ;
    List<String> staticResoucesToBeProcessed = new List<String>();
    Map<Integer,String> orderedStaticResMap = new Map<Integer,String>();
    List<Integer> staticResOrderIndicator = new List<Integer>();
    List<StaticResource> taxonomyStaticResources = new  List<StaticResource>();
    
    //For Testing purpose
    //Use below command in Anonymous Window
    //PMP_ScheduleTaxonomyUpload testschedule = new PMP_ScheduleTaxonomyUpload();
    //System.schedule('PMP_ScheduleTaxonomyUpload', '0 37 * * * ?', testschedule);
    //*******
    
    //Execute method invokes the Queueable Apex to Process the taxonomy files
    global void execute(SchedulableContext sc) {
        
        staticResOrderIndicator = new List<Integer>();
        staticResoucesToBeProcessed = new List<String>();
        todaysdate = Date.today();
        yesterdayDate = Date.today() - 1;
    
        for(PMP_Taxonomy_Static_Resource_Exec_Order__mdt StaticResourceExecOrd :[Select Static_Resource_Name__c,Execution_Order__c 
                                                                                 from PMP_Taxonomy_Static_Resource_Exec_Order__mdt where Static_Resource_Name__c != null ])
        {
            //Assign the values to map of Static resource name and order
            processOrderByName.put(StaticResourceExecOrd.Static_Resource_Name__c,StaticResourceExecOrd.Execution_Order__c);
            uniqueTaxonomyStaticResourceNames.add(StaticResourceExecOrd.Static_Resource_Name__c);
        }
        System.debug('processOrderByName-->'+processOrderByName);
        System.debug('uniqueTaxonomyStaticResourceNames-->'+uniqueTaxonomyStaticResourceNames);
        //Based on the Scheduler scheduled for today if there are any static resources updated
        // those will be executed to convert into salesforce taxonomy records
        
        if(Test.isRunningTest()) {
            uniqueTaxonomyStaticResourceNames = new Set<String>{'Hierarchy_English'};
             
            	taxonomyStaticResources = [SELECT Id,Name,SystemModStamp FROM StaticResource where Name in :uniqueTaxonomyStaticResourceNames];
            
        }
        else {
               
               		taxonomyStaticResources  = [SELECT Id,Name,SystemModStamp FROM StaticResource where Name in :uniqueTaxonomyStaticResourceNames and 
                                        (DAY_ONLY(SystemModStamp) = :todaysdate or DAY_ONLY(SystemModStamp) = :yesterdayDate)];
                  
               //taxonomyStaticResources  = [SELECT Id,Name,SystemModStamp FROM StaticResource where Name in :uniqueTaxonomyStaticResourceNames LIMIT 3];
                }
        for(StaticResource stat : taxonomyStaticResources) {
            orderedStaticResMap.put(Integer.valueOf(processOrderByName.get(stat.Name)),stat.Name);
            staticResOrderIndicator.add(Integer.valueOf(processOrderByName.get(stat.Name)));
        }

        System.debug('orderedStaticResMap-->'+orderedStaticResMap);
        System.debug('staticResOrderIndicator-->'+staticResOrderIndicator);

        if(!orderedStaticResMap.keySet().isEmpty()) { 
                     
            // Sort the Static resources order in order to pass in the same execution order to execute method
            staticResOrderIndicator.sort();
            
            
            for(Integer i=0;i<staticResOrderIndicator.size();i++) {
                staticResoucesToBeProcessed.add(orderedStaticResMap.get(staticResOrderIndicator[i]));
            }  
            
            system.debug('###staticResoucesToBeProcessed:->'+staticResoucesToBeProcessed); 
            //Adding this class as a job on the queue
            System.enqueueJob(new PMP_TaxonomyUploadQueueable(staticResoucesToBeProcessed)); 
        }                               
    }   
    
}