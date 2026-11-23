@isTest
/**************************************************************************************
Apex Class Name : PMP_OfferingTriggerHandler
Version     : 1.0 
Created Date: 26th March, 2019
Description : Trigger handler for PMP_Offering_Trigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  26/03/2019               Original Version
Yashasvi Aggarwal           30/09/2021
*************************************************************************************/

public class PMP_OfferingTriggerHandler extends TriggerHandler{
    
//     Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
//     public static boolean isRecursiveClearCache = True; 
//     public static boolean isCloneOfferingRecursive= True; //added recursive flag by Krishna ch to fix 101 SOQL issue in prod.
    
//     public override void afterUpdate(){
//           //Creation of published partner offering - Added by Shahrukh
//           Map<Id, PMP_Partner_Offering__c> oldMap = (Map<Id, PMP_Partner_Offering__c>) Trigger.oldMap;
          
//           boolean triggerFlag = isActive('PMP_Offering_Insert_Update');
//           boolean PublishedOfferingFlag = isActive('PMP_PublishOffering');
          
//           if(triggerFlag){
//                //added recursive flag by Krishna ch to fix 101 SOQL issue in prod.
//               if(PublishedOfferingFlag && isCloneOfferingRecursive){
//                  PMP_OfferingTriggerHelper.cloneOffering(trigger.new,oldMap);
//                   isCloneOfferingRecursive = False;
//               }
          
//           }
          
          
//          //End of published offering creation  
//         Set<Id> publishedOfferingIds= new Set<Id>();//US1029844 , to collect the published offeringids to clear the cache
//         for(PMP_Partner_Offering__c newOffering : (List<PMP_Partner_Offering__c>) trigger.new){
            
//             if(newOffering.PMP_Company_Id__c!=oldMap.get(newOffering.Id).PMP_Company_Id__c || newOffering.OwnerId != oldMap.get(newOffering.Id).OwnerId){
               
//                 if((mapFunctionalityNameTriggerExecution.containsKey('PMP_OPID_MPI_OfferingSharing_Handler') && 
//            mapFunctionalityNameTriggerExecution.get('PMP_OPID_MPI_OfferingSharing_Handler').Core_Active__c)){
//                PMP_Offering_Sharing.removeOldMPIOfferingSharing(oldMap,(Map<Id, PMP_Partner_Offering__c>) Trigger.newMap);
//                PMP_Offering_Sharing.sharePartnerOfferingRecords(Trigger.old, Trigger.new);
//            }
                                
              
//             }
//             //US1029844 , to get the published copy id - start.
//             if(newOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c==PMP_StaticConstants_Offering.PUBLISHED){
//                publishedOfferingIds.add(newOffering.Id); 
//             }
//             //US1029844, to get the published copy id - end.
            
//         }
//         //US1029844, for published copy , need to clear the cache - Start
//         if(publishedOfferingIds.size()>0 && isRecursiveClearCache){
//             isRecursiveClearCache = False;//added by krishna ch as part of 101 soql fix.
//           PMP_OfferingTriggerHelper.clearPlatformCache(publishedOfferingIds);  
//         }
//         //US1029844 , for published copy , need to clear the cache - End

         
//     }
//     //Commented By Gireesh K causing excpetion, donot uncomment
    
//      public override void afterInsert(){

//          if((mapFunctionalityNameTriggerExecution.containsKey('PMP_OPID_MPI_OfferingSharing_Handler') && 
//            mapFunctionalityNameTriggerExecution.get('PMP_OPID_MPI_OfferingSharing_Handler').Core_Active__c)){
//                PMP_Offering_Sharing.sharePartnerOfferingRecords(Trigger.old, Trigger.new);
//            }
//     }
    
// 	// Sandhya 
//    public override void beforeUpdate(){
//       Map<Id, PMP_Partner_Offering__c> oldMap = (Map<Id, PMP_Partner_Offering__c>) Trigger.oldMap;

        
//        PMP_OfferingTriggerHelper.isNotifiedToTrue(trigger.new,oldMap);
//      //Added by Yashasvi Aggarwal
//        //To transfer the updated status from PMP_Partner_Offering_Lifecycle_Status_Nm__c to PMP_Partner_Offering_LifecycleStatus_Txt__c
     
//        for(PMP_Partner_Offering__c newOffering : (List<PMP_Partner_Offering__c>) trigger.new){
//            newOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c = newOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
//        }

//        // PMP_OfferingTriggerHelper.futurePublishOffering(trigger.new,oldMap);
//     }
//     //Added by Yashasvi Aggarwal
//     public override void beforeInsert(){
//        //To transfer the updated status from PMP_Partner_Offering_Lifecycle_Status_Nm__c to PMP_Partner_Offering_LifecycleStatus_Txt__c
//        for(PMP_Partner_Offering__c newOffering : (List<PMP_Partner_Offering__c>) trigger.new){
//            newOffering.PMP_Partner_Offering_LifecycleStatus_Txt__c = newOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
//        }       
//     }   
}