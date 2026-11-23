global class PRM_ErrorMonitor_Batch implements Database.Batchable<sObject> {
     //TWC729-6800 EOL activities--Start 
     Private static final string STATUS_REP = 'Reprocessed';
     Private static final string STATUS_NEW = 'New';
     Private static final string STATUS_FAILED = 'Failed';
     Private static final string INTEGRATION_TYPE_FAILURE = 'OPID Inbound Failure';
     Private static final string INTEGRATION_TYPE_MISSING = 'OPID Not Received';
     Private static final string INTEGRATION_TYPE_BATCH_FAILURE = 'Batch Failure'; //TWC729-6800 EOL activities--End
     public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing
     global static Database.QueryLocator start(Database.BatchableContext context){
         //TWC729-6800 EOL activities--Start
         /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
         Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId();
         String query = 'SELECT Id, Name, PRM_Account_Id__c, PRM_Account_Number__c, PRM_Grouping_Method_Nm__c, PRM_Recommendation_Status_Nm__c,'+ 
             'PRM_Recommendation_Type_Nm__c, PRM_One_Partner_Id__c,Error_Description__c, CreatedDate FROM PRM_Value_Exchange_Recommendation__c '+
             'WHERE (PRM_Recommendation_Status_Nm__c = \'OPID In Process\' OR PRM_Recommendation_Status_Nm__c = \'Waiting for CIM response\')'+
             'AND PRM_Recommendation_Type_Nm__c = \'OPID\' AND RecordTypeId =: opidRecommendationRecordType AND CreatedDate <= TODAY ';    
         return Database.getQueryLocator(query);
         }//TWC729-6800 EOL activities--End
         else {*/String query ='SELECT Id FROM PRM_Value_Exchange_Recommendation__c where Id = null';
               return Database.getQueryLocator(query); //added for TWC729-6800 EOL activities
              //}
     } 
     
     global void execute(Database.BatchableContext context, List<PRM_Value_Exchange_Recommendation__c> scope){
         
         
         /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
         PRM_ErrorMonitor_Utility.checkInboundRecord(scope); //TWC729-6800 EOL activitie
         }*/
     }    
     
     global void finish(Database.BatchableContext BC){
         //TWC729-6800 EOL activities--Start
         /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
         Map<Id,Monitor_Log__c> updateLogs = new Map<Id,Monitor_Log__c>();
         
         List<Monitor_Log__c> logRec = [SELECT id,Account_ID__c, Error_Message__c, Integration_Type__c, OPID_Recommendation__c,One_Partner_Inbound_Message__c,Status__c,CreatedDate from Monitor_Log__c where Status__c ='Failed' and (Integration_Type__c ='Opid Not Received' or Integration_Type__c ='Opid Inbound Failure') ];
         Set<Id> accountIdsOfLogs = new Set<Id>();
         //Set<Id> jobId = new Set<Id>();
         
         if(logRec != Null && logRec.size()>0){
             for(Monitor_Log__c logR : logRec){
                 accountIdsOfLogs.add(logR.Account_ID__c);
             } 
         }
         
         Map<id,Core_OnePartner_Inbound_Message__c> inboundMap = new Map<id,Core_OnePartner_Inbound_Message__c>() ;
         for(Core_OnePartner_Inbound_Message__c listOfInboundMsg : [Select id,Core_Status__c,Core_CIM_ID__c,Core_OnePartnerID__c,Core_SalesCloud_AccountID__c,Core_PrimeID__c,Core_PAG_Grouping_Method__c,Core_Prime_Account_Name__c,Core_OnePartner_Account_Name__c, Error_Description__c, CreatedDate, Core_Effective_End_Date_Time__c, Core_Effective_Start_Date_Time__c from Core_OnePartner_Inbound_Message__c where Core_SalesCloud_AccountID__c IN :accountIdsOfLogs order by CreatedDate desc ]){
             if(!inboundMap.keyset().contains(listOfInboundMsg.Core_SalesCloud_AccountID__c)){
                 inboundMap.put(listOfInboundMsg.Core_SalesCloud_AccountID__c,listOfInboundMsg);
             }
         }       
         
             if(logRec.size()>0 && logRec != NULL){
                 for(Monitor_Log__c rec : logRec){
                     //Modified the code and combined deeply nested if conditions for solving annual health issues
                     if (!inboundMap.isEmpty() && inboundMap.containsKey(rec.Account_ID__c)) {
                         if (String.isNotBlank(inboundMap.get(rec.Account_ID__c).Error_Description__c)) {
                             rec.Status__c = STATUS_FAILED;
                             rec.Integration_Type__c = INTEGRATION_TYPE_FAILURE;
                             rec.One_Partner_Inbound_Message__c = inboundMap.get(rec.Account_ID__c).Id;
                             rec.Error_Message__c = rec.Error_Message__c + inboundMap.get(rec.Account_ID__c).Error_Description__c;
                         } else {
                             rec.Status__c = STATUS_REP;
                             rec.One_Partner_Inbound_Message__c = inboundMap.get(rec.Account_ID__c).Id;
                             rec.Error_Message__c = '';
                         }
                         updateLogs.put(rec.Account_ID__c, rec);
                     }      
                 }                          
             }
         //System.debug('UPDATE -->'+updateLogs);
         try{
             if(updateLogs != NULL && updateLogs.size()>0){
                 update updateLogs.values();
             }    
         }catch(DmlException e) {
             //System.debug('Exception: ' + e.getMessage());
         }
         }*///TWC729-6800 EOL activities--End
     }
 }