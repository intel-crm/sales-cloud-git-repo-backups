/****************************************************************************************************************************************
* Class Name        : Core_MDF_RMF_ScheduledNotification_Batch
* Test Class Name   : Core_MDF_RMF_SchNotification_Batch_Test
* Created Date      : 10/11/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AM       10/11/2020         Batch class to fetch activities based on criteria
*****************************************************************************************************************************************/
//Mohit -commented this batch class as it is not being used anymore - confirmed with business
global class Core_MDF_RMF_ScheduledNotification_Batch {/*implements Database.Batchable<sObject>, Database.Stateful {
    global final String pfrProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name');
    List<String> japanQuarterSet = new List<String>();
    List<String> nonJapanSet = new List<String>();   
    Set<id> japanRetailerAcctIds= new Set<Id>();
    Set<id> nonJapanRetailerAcctIds= new Set<Id>();
    Map<String,Id> pfrCloseDateMap = new Map<String,Id>();
    String geo;
    
    
    @TestVisible static String todaysMonth = String.valueOf(System.Today().Month());
    @TestVisible static String todaysDay = String.valueOf(System.Today().Day());
    global Core_MDF_RMF_ScheduledNotification_Batch(String geo){
		this.geo = geo;
        
    }    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){   
 
        String query;  
		Boolean isJapanScheduledJob= false;
        Boolean isNonJapanScheduledJob = false;
        string toDate, fromDate;
        List<String> scheduleDateList = (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RMF_Scheduler_Date')).split(',');
        japanQuarterSet = (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Japan_Quarter')).split(','); 
        nonJapanSet = (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Non_Japan_Quarter')).split(',');  
        if(todaysMonth == '1'){
            if(scheduleDateList.contains(todaysDay)){
                isJapanScheduledJob = true;
                isNonJapanScheduledJob = true;
            }
        }else{
            if(japanQuarterSet.contains(todaysMonth)){
                if(scheduleDateList.contains(todaysDay)){
                    isJapanScheduledJob = true;
                    isNonJapanScheduledJob = false;	
                }
            }if(nonJapanSet.contains(todaysMonth)){
                if(scheduleDateList.contains(todaysDay)){                	
                    isJapanScheduledJob = false;
                    isNonJapanScheduledJob = true;	
                }
            }
            
        }
        	
		if(isJapanScheduledJob){
            Date firstDayOfMonth = System.today().toStartOfMonth().addMonths(-4);
            Datetime startDateTime = datetime.newInstance(firstDayOfMonth.year(), firstDayOfMonth.month(), firstDayOfMonth.day());
            fromDate = startDateTime.format('yyyy-MM-dd');
            Date lastDayOfMonth = firstDayOfMonth.addMonths(4).addDays(-1);
            Datetime endDateTime = datetime.newInstance(lastDayOfMonth.year(), lastDayOfMonth.month(), lastDayOfMonth.day());
            toDate = endDateTime.format('yyyy-MM-dd');
        } 
       
        query = 'SELECT id, Core_MDF_Fund_Request_Status__c,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode), Core_MDF_Program__c, ChannelPartnerId, Core_MDF_End_Date__c from PartnerFundRequest '+
                'where Core_MDF_Program__c =: pfrProgram and Core_MDF_Fund_Request_Status__c = \'Planned\' and ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Geo__c=:geo '; 
                   
        
        if(isNonJapanScheduledJob && isJapanScheduledJob ){
            query += ' and ((Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode) = \'JAPAN\' and  Core_MDF_End_Date__c >= '+fromDate+' and Core_MDF_End_Date__c <= '+toDate+') or (Core_MDF_End_Date__c = LAST_QUARTER and Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode) != \'JAPAN\'))';
        }
        else if(isJapanScheduledJob){
                query += ' and Core_MDF_End_Date__c >='+fromDate+' and Core_MDF_End_Date__c <='+toDate+' and Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode) = \'JAPAN\'';
            }
        else if(isNonJapanScheduledJob){
                query += ' and Core_MDF_End_Date__c = LAST_QUARTER and Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode) != \'JAPAN\'';
            }
        else{
            query +=' LIMIT 0';
        }        
        
        return Database.getQueryLocator(query);
         
        
    } 
    global void execute(Database.BatchableContext batchableContext, List<PartnerFundRequest> pfrList){ 
        try{
            for(PartnerFundRequest pfr : pfrList){                
                if(pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode != null && (pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode).equalsIgnoreCase('JAPAN')){
                    japanRetailerAcctIds.add(pfr.ChannelPartnerId);
                    pfrCloseDateMap.put('closeDateJP',pfr.Id);
                }
                else{
                    nonJapanRetailerAcctIds.add(pfr.ChannelPartnerId);
                    pfrCloseDateMap.put('closeDateNonJP',pfr.Id);
                }
            }            
        }
        catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}         
    }       
    global void finish (Database.BatchableContext batchableContext){ 
        Core_MDF_ScheduledNotificationHandler.notifyRMFUsers(pfrCloseDateMap,japanRetailerAcctIds ,nonJapanRetailerAcctIds);  
        Core_MDF_GenericClassToSendMail.batchExecutionNotifyUser('Core_MDF_Batch_Execution_Notify_User','Core_MDF_RMF_ScheduledNotification_Batch','Core_MDF_Notify_Batch_Email_Users');
    }*/
    //added dummy method to get the code coverage for this class
    public static void getCodeCoverage(){
    }
}