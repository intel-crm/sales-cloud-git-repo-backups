/********************************************************************************************************************
Apex Class Name:  Core_IPS_Case_Attachments_Handler_test
Version     : 1.0 
Created Date: 04 10 2017
Function    : Test class for Core_IPS_Case_Attachments_Handler
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                              14/12/2017               Added new method for attachment related case comments
* Ajay                                2/15/2018                as per US96026
* Ranjini 							8/27/2019				   Added new method for attachment - updateCase

*******************************************************************************************************************/

public class Core_IPS_Case_Attachments_Dispatcher{
    public static void beforeMethod(List<Core_IPS_Case_Attachments__c> oldList, List<Core_IPS_Case_Attachments__c> newList, 
                            Map<Id,Core_IPS_Case_Attachments__c> oldMap,Map<Id,Core_IPS_Case_Attachments__c> newMap){
         if(trigger.isInsert){
            //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler
            Core_IPS_Case_Attachments_Handler.updateFUBIfBlank(newList);
            
            
         }
         if(trigger.isUpdate && ((System.label.Core_IPS_Profiles_WithoutTriggerExec.contains(String.valueOf(userInfo.getProfileId()).substring(0,15)) && Core_Trigger_Executions__c.getValues('IsDMUser_En_forCommTrigExec').Core_Active__c) || !System.label.Core_IPS_Profiles_WithoutTriggerExec.contains(String.valueOf(userInfo.getProfileId()).substring(0,15)))){
             //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler
             Core_IPS_CasePromotion_Handler.executeBackendRoutingfromIPSCaseAttachmentTrigger(oldList, newList, oldMap, newMap);  //IPS Backend CasePpromotion
             Core_IPS_Case_Attachments_Handler.validateAttachmentfromdeleting(newList,oldMap);
            
             
         }
         if(trigger.isDelete){
             //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler
             Core_IPS_Case_Attachments_Handler.validateAttachmentfromdeleting(oldList,oldMap);
             
             // Added by sumukh for updation of attachment case comments 
              if(Core_Trigger_Executions__c.getValues('UpdateCaseCommentForAttach').Core_Active__c){  
              Core_IPS_Case_Attachments_Handler.deleteAttachmentCaseComment(oldList); 
              }
              Core_IPS_Case_Attachments_Handler.sendCaseAttachment(oldList);
              
    }  
  }  
    public static void afterMethod(List<Core_IPS_Case_Attachments__c> oldList, List<Core_IPS_Case_Attachments__c> newList, 
                            Map<Id,Core_IPS_Case_Attachments__c> oldMap,Map<Id,Core_IPS_Case_Attachments__c> newMap){
         if(trigger.isInsert){
             //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler
            Core_IPS_CasePromotion_Handler.executeBackendRoutingfromIPSCaseAttachmentTrigger(oldList, newList, oldMap, newMap);  //IPS Backend CasePpromotion
            if(Core_Trigger_Executions__c.getValues('InsertCaseCommentForAttach').Core_Active__c){
                Core_IPS_Case_Attachments_Handler.insertCaseComment(newlist,newMap,oldMap); // for inserting comment when attachment is made.
            }
            Core_IPS_Case_Attachments_Handler.updateCase(trigger.new);
            //Added for B2B implementation;US97707;17/5/2018 by Aparna
            Core_IPS_Case_Attachments_Handler.upadtevaluesB2B(newMap);
            //end
         }
         if(trigger.isUpdate){
             //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler
            if( Core_Trigger_Executions__c.getValues('InsertCaseCommentForAttach').Core_Active__c){
                Core_IPS_Case_Attachments_Handler.insertCaseComment(newlist,newMap,oldMap);
            }
            // Added by sumukh for updation of attachment case comments 
            if(Core_Trigger_Executions__c.getValues('UpdateCaseComntDscptnForAttach').Core_Active__c){
            Core_IPS_Case_Attachments_Handler.updateAttachmentCaseComment(newList, oldMap);
            }
            //to generate case attachment outbound when upload status is set to completed, added by Chandra.
            List<Core_IPS_Case_Attachments__c> attachments = new List<Core_IPS_Case_Attachments__c>();
            for(Integer i=0; i < newList.size(); i++){
                if((oldList[i].Core_IPS_BES_Promote_Status__c == '' || oldList[i].Core_IPS_BES_Promote_Status__c == null ) && (newList[i].Core_IPS_BES_Promote_Status__c == '' || newList[i].Core_IPS_BES_Promote_Status__c == null)){
                    attachments.add(newList[i]);
                }
            }
            if(!attachments.isEmpty()){
            	Core_IPS_Case_Attachments_Handler.sendCaseAttachment(attachments);     
            }
             //end
             //Manual Promotion of attachments to backend system - Chandra
            List<Core_IPS_Case_Attachments__c> attachmentsToSend = new List<Core_IPS_Case_Attachments__c>();
            for(Core_IPS_Case_Attachments__c att : newList){
                if(oldMap.get(att.Id).Core_IPS_BES_Promote_Status__c!= att.Core_IPS_BES_Promote_Status__c && att.Core_IPS_BES_Promote_Status__c == 'In Progress'){
                     attachmentsToSend.add(att);
                }
            }
            if(!attachmentsToSend.isEmpty()){
                Core_IPS_Case_Attachments_Handler.sendCaseAttachment(attachmentsToSend);
            }
             //End Manual promotion 
         }
         if(trigger.isDelete){
             //use Core_IPS_Case_Attachments_Handler class for your business logic for IPS specific code, others can use their own handler        
         }
    }
}