/*******************************************************************************************************************************************************************************************************
* Class Name  : PMP_SendUpdateRequiredOffEmailsBatch
* Description : Stores the logic for sending the email for Update Required offering email scenarios.
* Version     : 1.0 
* Created Date: 3-June-2022
* Modification Log :
* Created By  : Sandhya Dayananda
********************************************************************************************************************************************************************************************************/
@isTest
public with sharing class PMP_SendUpdateRequiredOffEmailsBatch{} /*implements Database.Batchable<sObject>,schedulable{
//IPA2.0 Offering Changes
    public static string updateRequiredStatus = PMP_StaticConstants_Offering.Update_Required;
          
        public Database.QueryLocator start(Database.BatchableContext BC){
            String query = 'Select Id, Name,PMP_Partner_Offering_End_Dt__c,PMP_Workflow_One_Week_Trigger_Dt__c,PMP_Workflow_Three_Day_Trigger_Dt__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c from PMP_Partner_Offering__c where PMP_Partner_Offering_Lifecycle_Status_Nm__c = :updateRequiredStatus AND PMP_Intel_Admin_Id__c!=null';
            return Database.getQueryLocator(query);
        } 

        public void execute(Database.BatchableContext BC, List<PMP_Partner_Offering__c> scope)
        { 
            Boolean isReminderSent = False;
            Set<String> offeringIdSet = new Set<String>();
            map<string,string> tempNameDevloperNameMap = new map<string,string>();
            List<PRM_EmailLog__c> emailLogList =[select id,PRM_Subject__c,Email_Template_Name__c,PMP_Partner_Offering__c from PRM_EmailLog__c where PMP_Partner_Offering__c = : scope[0].id ];
            List<EmailTemplate> tempList = [SELECT Id,Name,DeveloperName FROM EmailTemplate WHERE DeveloperName ='PMP_OfferingUpdateRequiredFirstNotify'];
           
            for(EmailTemplate temp :tempList){
                tempNameDevloperNameMap.put(temp.name,temp.DeveloperName);
                system.debug('tempNameDevloperNameMap at 25---'+tempNameDevloperNameMap);
            }
            for(PRM_EmailLog__c emailLog : emailLogList){
                //offeringIdSet.add(emailLog.PMP_Partner_Offering__c);
                system.debug('emailLog---'+emailLog);
                if(!tempNameDevloperNameMap.isempty()){
                    if(tempNameDevloperNameMap.containskey(emailLog.Email_Template_Name__c) && tempNameDevloperNameMap.get(emailLog.Email_Template_Name__c) == 'PMP_OfferingUpdateRequiredFirstNotify' && emailLog.PMP_Partner_Offering__c==scope[0].id){
                        system.debug('tempNameDevloperNameMap at 31--'+tempNameDevloperNameMap);
                        isReminderSent  = True;
                    }
                    
                }
                
            }
            List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper> offeringList = new List<PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper>();
            PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper off = new PMP_SendEmailAlertsForOfferings.SendEmailRequestWrapper();

            if(scope!= null && !scope.isempty()){
                DateTime dT = System.now().date();  
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                String formattedDate=dT.format('yyyy-MM-dd');
                System.debug('*****formattedDate******* 26 ' + formattedDate);
                System.debug('*****PMP_Workflow_Three_Day_Trigger_Dt__c******* 27 ' + scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c);
                System.debug('*****PMP_Workflow_One_Week_Trigger_Dt__c******* 28 ' + scope[0].PMP_Workflow_One_Week_Trigger_Dt__c);
                   if(((scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c!=null && scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c==Date.valueOf(formattedDate)) || (scope[0].PMP_Workflow_One_Week_Trigger_Dt__c!=null && scope[0].PMP_Workflow_One_Week_Trigger_Dt__c==Date.valueOf(formattedDate))) && !isReminderSent){
                    System.debug('#24---'+scope[0].PMP_Workflow_Three_Day_Trigger_Dt__c);
                    off.templateName='PMP_OfferingUpdateRequiredFirstNotify';
                    off.offeringId= scope[0].id;
                    offeringList.add(off);
                   }
                   if(scope[0].PMP_Workflow_One_Week_Trigger_Dt__c!=null && scope[0].PMP_Workflow_One_Week_Trigger_Dt__c==formattedDate){
                    System.debug('#30---'+scope[0].PMP_Workflow_One_Week_Trigger_Dt__c);
                    off.templateName='PMP_OfferingUpdateRequiredFirstNotify';
                    off.offeringId= scope[0].id;
                    offeringList.add(off);
                   }
               
               if(!offeringList.isempty() && offeringList.size() > 0){
                    PMP_SendEmailAlertsForOfferings.sendOfferingEmailNotifications(offeringList);
                }
            }
        }

        public void finish(Database.BatchableContext BC){

        }
        public void execute(SchedulableContext SC) {
        
            PMP_SendUpdateRequiredOffEmailsBatch batch = new PMP_SendUpdateRequiredOffEmailsBatch();
            Database.executeBatch(batch,1);    
        }
    
   
}*/