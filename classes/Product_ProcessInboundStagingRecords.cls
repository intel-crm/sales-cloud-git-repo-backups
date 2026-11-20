public with sharing class Product_ProcessInboundStagingRecords {
    
    public static String ipaasId;    
    public static Integer recordCountL1Limit = Integer.valueOf(label.Products_recordCountL1Limit);
    public static Integer recordCountL2Limit = Integer.valueOf(label.Products_recordCountL2Limit);
    public static Integer recordCountL1LimitVplch = Integer.valueOf(label.Products_recordCountL1LimitVplch);
    public static list<Core_Products_Staging__c> inbMasterList = new  list<Core_Products_Staging__c>();
    public static Map<Integer,InputWrapper> inputWrapperMap = new Map<Integer,InputWrapper>();
    public static Integer vphCount = 1;
    public static Integer IntialCount = 1;   //Intially set to 1. The count will increase on completion of each queueble job.
    public static Boolean vplchInd = false; 
    public static Set<String> opnIDs = new Set<String>();     
    public static Set<String> largeDataSetL1ids = new Set<String>();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    
    @InvocableMethod(label = 'Invoke inbound staging processing' description = 'Process the Product_Inbound_Staging Records')
    public static void processInboundStagingRecords(list<string> Ids){
        try{
            Heap_Analysis__c hp = new Heap_Analysis__c();
            hp.Class_Name__c = 'Product_ProcessInboundStagingRecords';        
            hp.Start_Time__c = system.now();        
            if(!Ids.IsEmpty() && Ids != null){
                ipaasId = Ids[0];  //This is a unique load id which we get in every payload from Mulesoft.
                hp.iPaaS_Load_ID__c =Ids[0];
                
                Boolean skipJob = skipJobBasedOnCount(ipaasId);

                if (skipJob && !Test.isRunningTest()) {
                    return;
                }

                 
                // Process L1 categories for VPH.
                processL1category();
                // When the L1 is very large for VPH, then we break it into l2's and process it. 
                processL2category(); 
                // Process VPLCH categories.
                processVplchRecords();
               
                       
                
                Integer l2Count = 0;
                
                for(Integer f :inputWrapperMap.keySet()){
                    if (inputWrapperMap.get(f).vplchInd) {
                        l2Count += inputWrapperMap.get(f).level1VplchEPMIds.size();
                    }
                }
                
                if (inputWrapperMap.size() > 0){
                    
                    System.enqueueJob(new Product_stageQueueable(IntialCount,inbMasterList,inputWrapperMap,vplchInd, ipaasId,opnIDs));
                } 
            }   
            hp.End_Time__c = system.now();    
            insert hp; 

            if (mapFunctionalityNameTriggerExecution.containsKey('AllowProductErrorNotification') && mapFunctionalityNameTriggerExecution.get('AllowProductErrorNotification').Core_Active__c) {

                List<AsyncApexJob> jobs = [SELECT Id,Status,CreatedDate,ExtendedStatus FROM AsyncApexJob WHERE ApexClass.Name ='Product_stageQueueable' and Status IN ('Failed','Holding') and CreatedDate = LAST_N_DAYS:1];
    
                if (!jobs.isEmpty() || Test.isRunningTest()) {                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] { Label.ProductSupportEmail };
                    message.subject = 'Product Integration: Product_stageQueueable job status';
                    String emailBody = '';
                    
                    for (AsyncApexJob job: jobs) {
                        if (String.isNotBlank(emailBody)) {
                            emailBody += '<br/>';
                        }
                        emailBody += 'Job Id - '+job.Id+':Status- '+job.Status+':Error- '+job.ExtendedStatus;
                    }
                    message.setHtmlBody(emailBody);
                    message.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
                }    
            }            
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasId,'Product_ProcessInboundStagingRecords',null,null);
        }
    }
    
    public static void processL1category(){
        
        for(AggregateResult inbRcrd: [select level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = :Product_Staging_StaticConstants.vphId group by level_1_epm_id__c]){
            System.debug('Inbound Records:'+inbRcrd);
            if(string.isNotBlank((string)inbRcrd.get('level_1_epm_id__c'))  ){
                // Prepring list of level 1 EPM ids to send to Queueable where count is less than limit
                if ((Integer)inbRcrd.get('cnt') < recordCountL1Limit) {
                    InputWrapper input = new InputWrapper();
                    input.atLevel2 = false;
                    input.vplchInd = false ;
                    input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                    inputWrapperMap.put(vphCount,input);
                    vphCount = vphCount + 1;
                    
                }
                // if count is greater than limit, preparing a set of level epm ids
                else {
                    largeDataSetL1ids.add((string)inbRcrd.get('level_1_epm_id__c'));
                }
            }
        } 
    }
    
    
    public static void processL2category(){
        Integer finCount = 0;
        Set<String> level2EPMIds = new Set<String>();
        String lastepmId = '';
        // Query to get all invound staging records grouped by L2 for all the L1s in the above set(count > limit)
        List<AggregateResult> arList = [select level_2_epm_id__c,level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = :Product_Staging_StaticConstants.vphId and level_1_epm_id__c in:largeDataSetL1ids  group by level_2_epm_id__c,level_1_epm_id__c  order by level_1_epm_id__c,count(Id) desc];
        
        if(!largeDataSetL1ids.isEmpty()){
            for(AggregateResult inbRcrd: arList){
                if(string.isNotBlank((string)inbRcrd.get('level_2_epm_id__c'))  ){
                    //Below logic will keep adding the l2 epm ids in a set until the sum of records count 
                    //is greater than 900 within the L1 group and send it to Queueable
                    
                    Boolean isAddedLast = finCount > recordCountL2Limit;
                    
                    if(finCount < recordCountL2Limit && (String.isBlank(lastepmId) || (string)inbRcrd.get('level_1_epm_id__c') == lastepmId || (arList.indexOf(inbRcrd) + 1 == arList.size()))){
                        level2EPMIds.add((string)inbRcrd.get('level_2_epm_id__c'));
                        finCount += (Integer)inbRcrd.get('cnt');
                    }
                    
                    
                    if (finCount > recordCountL2Limit || (arList.indexOf(inbRcrd) + 1 == arList.size()) || (String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId)){
                        if(!level2EPMIds.isEmpty()){
                            InputWrapper input = new InputWrapper();
                            input.atLevel2 = true;
                            input.vplchInd = false;
                            if(String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId){
                                if((arList.indexOf(inbRcrd) + 1 == arList.size())){
                                    input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                                }
                                else{
                                    input.level1EPMId = lastepmId;
                                }
                            }
                            else{
                                input.level1EPMId = (string)inbRcrd.get('level_1_epm_id__c');
                            }
                            input.level2EPMIds = level2EPMIds;
                            inputWrapperMap.put(vphCount,input);
                            vphCount = vphCount + 1;
                            level2EPMIds = new Set<String>();
                            finCount = 0;
                        }
                        
                        if((String.isNotBlank(lastepmId) && (string)inbRcrd.get('level_1_epm_id__c') != lastepmId) || isAddedLast){
                            level2EPMIds.add((string)inbRcrd.get('level_2_epm_id__c'));
                            finCount += (Integer)inbRcrd.get('cnt');
                        }
                        lastepmId = (string)inbRcrd.get('level_1_epm_id__c');                            
                    }
                }                    
            }
        }
    }
    
    public static void processVplchRecords(){
        Integer finCount = 0;
        Set<String> level1VplchEPMIds = new Set<String>();
        List<AggregateResult> arList = [select level_1_epm_id__c, count(id)cnt from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = :Product_Staging_StaticConstants.vplchId group by level_1_epm_id__c  order by count(Id) desc];
        
        
        for(AggregateResult inbRcrd: arList){
            if(string.isNotBlank((string)inbRcrd.get('level_1_epm_id__c'))  ){
                //if(finCount < recordCountL1LimitVplch  || arList.indexOf(inbRcrd) + 1 == arList.size()){
                if(finCount < recordCountL1LimitVplch  || arList.indexOf(inbRcrd) < arList.size()){
                    level1VplchEPMIds.add((string)inbRcrd.get('level_1_epm_id__c'));
                    finCount += (Integer)inbRcrd.get('cnt');
                }
                
                
                if (finCount > recordCountL1LimitVplch || (arList.indexOf(inbRcrd) + 1 == arList.size()) ){
                    if(!level1VplchEPMIds.isEmpty()){
                        InputWrapper input = new InputWrapper();
                        input.vplchInd = true;
                        input.level1VplchEPMIds = level1VplchEPMIds;
                        inputWrapperMap.put(vphCount,input);
                        vphCount = vphCount + 1;
                        level1VplchEPMIds = new Set<String>();
                        finCount= 0;
                    }                               
                }
            }
        }
    }

    private static Boolean skipJobBasedOnCount (String ipaasId) {
        Boolean skipJob = false;
        Integer inboundRecCount;
		List<Core_Products_Staging__c> productStagings = new List<Core_Products_Staging__c>();
		Integer oldInboundRecCount;
		Decimal dropIncreasePercentage;
			
		if (mapFunctionalityNameTriggerExecution.containsKey('CheckInboundStagingRecordCount') && mapFunctionalityNameTriggerExecution.get('CheckInboundStagingRecordCount').Core_Active__c) {
            inboundRecCount = [SELECT count() FROM Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId];
			productStagings = [SELECT Id,iPaaS_Load_ID__c,createddate from Core_Products_Staging__c order by createddate desc limit 1];
				
			if (!productStagings.isEmpty()) {
				oldInboundRecCount = [SELECT count() FROM Product_Inbound_Staging__c where iPaaS_Load_ID__c = :productStagings[0].iPaaS_Load_ID__c];
                if (oldInboundRecCount > 0) {
                    dropIncreasePercentage = ((oldInboundRecCount - inboundRecCount)*100/oldInboundRecCount);
                        
                        
                    if (dropIncreasePercentage > Integer.valueOf(Label.InboundRecordsDifferenceLimit) || Test.isRunningTest()) {                    
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = new String[] { Label.ProductSupportEmail };
                        message.subject = 'Product Integration: Product inbound staging record count is dropped by '+dropIncreasePercentage+'%';
                        String body = 'Product inbound staging record count is dropped by '+dropIncreasePercentage+'%<br/>Please check the inbound records or revisit the limit in the custom label InboundRecordsDifferenceLimit';
                        body += '<br/>Ipaas load id- '+ipaasId;
                        body += '<br/>Previous Ipaas load id- '+productStagings[0].iPaaS_Load_ID__c;
                        message.setHtmlBody(body);
                        message.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
                        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
                            
                        skipJob = true;
                    }
                }
			}				
        }
        return skipJob;
    }
    
    public class InputWrapper {        
        public String level1EPMId{get;set;}      
        public Boolean atLevel2{get;set;}        
        public Set<String> level2EPMIds{get;set;}
        public Set<String> level1VplchEPMIds{get;set;}
        public Boolean vplchInd{get;set;}  
    }
}