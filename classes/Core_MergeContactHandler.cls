/******************************************************************************************************************************
Apex Class Name:  Core_MergeContactHandler 
Version     : 1.0 
Created Date: 25 May 2017
Function    : validate contact entitlement duplicate on Contact Merge and removes duplicate.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan               25/05/2017              validateUniqueEntitlement() method calls and validate Contact Entitlement.
*******************************************************************************************************************************/

public class Core_MergeContactHandler {
   public static void validateUniqueEntitlement(){
        
        system.debug('Trigger.delete :: '+Trigger.isdelete);
        system.debug('Trigger.isafter :: '+Trigger.isafter);
        system.debug('Trigger.oldMap:: '+Trigger.oldMap);
        system.debug('Trigger.old:: '+Trigger.old);
       
        List<Core_Contact_Entitlement__c > tobeDeletedCE=new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c > tobeupdateCE=new List<Core_Contact_Entitlement__c>();
        Set<ID> deletedContact=Trigger.oldMap.keySet();
        List<ID> masterIds=new List<ID>();
        List<Contact> contactObjList=(List<Contact>)Trigger.old;
        for(Contact contactObj:contactObjList){
            if(contactObj.MasterRecordId!=null){
                masterIds.add(contactObj.MasterRecordId);
            }
        }
        if(masterIds.size()>0){
            List<Core_Contact_Entitlement__c > ceList2=[select Id, Name,Core_Unique_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.name,Core_Contact_Id__c,Core_Entitlement_Id__r.Core_Display_Name__c, Core_Entitlement_Id__r.Core_IsActive__c,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Contact_Id__c IN :masterIds];// AND Core_Entitlement_Id__r.Core_IsActive__c = true // Not required because we have engagment to be merged with unique.
            system.debug('ceList2 :: '+ceList2);
            
            Map<ID,Core_Contact_Entitlement__c> ceStatusMerge=new Map<Id,Core_Contact_Entitlement__c>();
            Set<ID> entitlementIDs=new Set<ID>();
            for(Core_Contact_Entitlement__c ceObject: ceList2){
                system.debug('Preparing list of entitlement');
                // Core_Unique_Id__c on the Contcat entitlement Fields using 15 digit contact and Entitlement Concatination.
                // Preparing Master Contcat Entitlement Id to set.
                if((ceObject.Core_Unique_Id__c).contains((ceObject.Core_Contact_Id__c+'').substring(0,15))){
                  entitlementIDs.add(ceObject.Core_Entitlement_Id__c);
                  ceStatusMerge.put(ceObject.Core_Entitlement_Id__c,ceObject);
                }
            }
            system.debug('entitlementIDs :: '+entitlementIDs);
            system.debug('ceStatusMerge :: '+ceStatusMerge);
            for(Core_Contact_Entitlement__c ceObject: ceList2){
                String tempUniqueId=(ceObject.Core_Contact_Id__c+'').substring(0,15)+(ceObject.Core_Entitlement_Id__c+'').substring(0,15);
                system.debug('tempUniqueId :: '+tempUniqueId);
                system.debug('ceObject.Core_Unique_Id__c :: '+ceObject.Core_Unique_Id__c);
                if(ceObject.Core_Unique_Id__c!=tempUniqueId){
                    if(entitlementIDs.contains(ceObject.Core_Entitlement_Id__c)){
                        // Entitlement is already on this contact.
                        system.debug('Matched Entitlement :: '+ceObject.Core_Entitlement_Id__c);
                        //Updating contact entitlement with any merged contact entitlement selected
                        Core_Contact_Entitlement__c ceStatusUpdate =null;
                        if(ceStatusMerge.get(ceObject.Core_Entitlement_Id__c)!=null && !ceStatusMerge.get(ceObject.Core_Entitlement_Id__c).Core_Selected__c && ceObject.Core_Selected__c && ceObject.Core_Entitlement_Id__r.Core_IsActive__c){
                            ceStatusUpdate = ceStatusMerge.get(ceObject.Core_Entitlement_Id__c);
                           // Below line will update entitlement with selected but validation rule will fire.
                            ceStatusUpdate.Core_Selected__c=ceObject.Core_Selected__c;
                            ceStatusUpdate.Core_Update_Reason__c='Contact Merge';
                            ceStatusUpdate.Core_Status__c='Pending';
                            tobeupdateCE.add(ceStatusUpdate);
                            system.debug('Contact Entitlement selection updated');
                        }
                        tobeDeletedCE.add(ceObject);
                        
                    }else{
                        // New Entitlement is from merged Contact need to modify contact id in Unique id. We have old contact id combination
                        system.debug('New Entitlement :: '+ceObject.Core_Entitlement_Id__c);
                        ceObject.Core_Unique_Id__c=tempUniqueId;
                        if(ceObject.Core_Entitlement_Id__r.Core_IsActive__c){
                            ceObject.Core_Update_Reason__c='Contact Merge';
                            ceObject.Core_Status__c='Pending';
                        }
                        tobeupdateCE.add(ceObject);
                        entitlementIDs.add(ceObject.Core_Entitlement_Id__c);
                        ceStatusMerge.put(ceObject.Core_Entitlement_Id__c,ceObject);
                     }
                }
            }
        }
        system.debug('tobeDeletedCE :: '+tobeDeletedCE);
        system.debug('tobeupdateCE:: '+tobeupdateCE);
        if(tobeupdateCE.size()>0){
            // Before Update Check for english validation on the master record if required.
            update tobeupdateCE;
        }
        if(tobeDeletedCE.size()>0){
            delete tobeDeletedCE; 
        }
        if(masterIds.size()>0){
            Core_MergeContact_Status_Update.updateIntegrationStatus(masterIds);
            
        }
    }
}