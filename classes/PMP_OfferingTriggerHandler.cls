/**************************************************************************************
Apex Class Name : PMP_OfferingTriggerHandler
Version     : 1.0 
Created Date: 26th March, 2019
Description : Trigger handler for PMP_Offering_Trigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  26/03/2019               Original Version
*************************************************************************************/

public class PMP_OfferingTriggerHandler extends TriggerHandler{
    
    public override void afterUpdate(){
          //Creation of published partner offering - Added by Shahrukh
          Map<Id, PMP_Partner_Offering__c> oldMap = (Map<Id, PMP_Partner_Offering__c>) Trigger.oldMap;
          
          boolean triggerFlag = isActive('PMP_Offering_Insert_Update');
          boolean PublishedOfferingFlag = isActive('PMP_PublishOffering');
          
          if(triggerFlag){
          
              if(PublishedOfferingFlag){
                 PMP_OfferingTriggerHelper.clonePublishedOffering(trigger.new,oldMap);
              }
          
          }
          
          
         //End of published offering creation  
        for(PMP_Partner_Offering__c newOffering : (List<PMP_Partner_Offering__c>) trigger.new){
            if(newOffering.PMP_Company_Id__c!=oldMap.get(newOffering.Id).PMP_Company_Id__c || newOffering.OwnerId != oldMap.get(newOffering.Id).OwnerId){
                   
                 
               PMP_Offering_Sharing.sharePartnerOfferingRecords(Trigger.old, Trigger.new);
            }
            
        }
         
    }
    //Commented By Gireesh K causing excpetion, donot uncomment
    
     public override void afterInsert(){

         PMP_Offering_Sharing.sharePartnerOfferingRecords(Trigger.old, Trigger.new); 
       
    }
    
	// Sandhya 
   public override void beforeUpdate(){
      Map<Id, PMP_Partner_Offering__c> oldMap = (Map<Id, PMP_Partner_Offering__c>) Trigger.oldMap;

        
       PMP_OfferingTriggerHelper.isNotifiedToTrue(trigger.new,oldMap);

       // PMP_OfferingTriggerHelper.futurePublishOffering(trigger.new,oldMap);
    }
}