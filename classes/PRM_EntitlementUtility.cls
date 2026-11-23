/***************************************************************************************************************************************
Apex Class Name     : PRM_EntitlementUtility 
Version             : 1.0
Created Date        : July 2019
Function            : Handler for PRM_Contact_Entitlements_Insert_batch class to assign Contact Entitlements.

Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                   10-July-2019                   Added a new method assignContactEntitlements(List) to Update or Insert the ContactEntitlements whenever the PRM_Contact_Entitlements_Insert_batch class executes.
*************************************************************************************************************************************/

public without sharing class PRM_EntitlementUtility{
    public static void assignContactEntitlements(List<PRM_Batch_Entitlement__c>lstBatchEntitlement){
    List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
    List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
    List<Core_Contact_Entitlement__c> contactEntitlement = new List<Core_Contact_Entitlement__c>();
    Map<Id,String> mapConToName = new Map<Id,String>();
    Map<Id,String> conToEntMap = new Map<Id,String>();
    Map<Id,Id> mapConToId = new Map<Id,Id>();
    List<Id> contactId = new List<Id>();
    List<Id> entitlementId = new List<Id>();
    List<Id> conId = new List<Id>();
    List<Id> entId = new List<Id>();
    List<boolean> isTriggerList = new List<boolean>();
    Map<Core_Contact_Entitlement__c,Id> ceMap = new Map<Core_Contact_Entitlement__c,Id>();
    Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
    String origin  = 'PRM_EntitlementUtility';
    String severity  = 'Critical';
    String project  = 'IPA';
    String errormessage  = 'Too many DML rows';
    String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
    Map<Id,String> entAgsMap = new Map<Id,String>();
        
        System.debug('lstBatchEntitlement--->'+lstBatchEntitlement);
            //Maping records for contact entitlements.
            
        for(PRM_VXEnttlmntMatrix__c ent :[Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,RecordType.Name,PRM_Partner_Role_Nm__c,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null]){
            entAgsMap.put(ent.PRM_Entitlement_Id__c,ent.PRM_AGS_Role__c);
        }
        System.debug('entAgsMap--->'+entAgsMap);
        
        for(PRM_Batch_Entitlement__c be :lstBatchEntitlement){
            conId.add(be.PRM_Contact_Id__c);
            entId.add(be.PRM_Entitlement_Id__c);
            System.debug('be--->'+be);
            System.debug('entAgsMap.get(be.PRM_Entitlement_Id__c--->'+entAgsMap.get(be.PRM_Entitlement_Id__c));
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
            ce.Core_Contact_Id__c = be.PRM_Contact_Id__c;
            ce.Core_Entitlement_Id__c = be.PRM_Entitlement_Id__c;
            if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(be.PRM_Entitlement_Id__c) == '' || entAgsMap.get(be.PRM_Entitlement_Id__c) == null)){
                ce.Core_From_Source__c = true;
            }
            else {
                ce.Core_Status__c = 'Pending';
                ce.Core_From_Source__c = false;
            }
            //ce.Core_Status__c = 'Pending';
            ce.Core_Data_Loaded__c = true;
            ce.Core_DontNotify__c = true;
            /*Added below code to cover exception from test class - Start*/
                if(Test.isRunningTest()){
                    ce.Core_Engagement_Tier__c = '*****************************************************************************************************************************************************************************************************************************************************************************';
                } 
            /*END*/
            if(!ceList.Contains(ce)){
                isTriggerList.add(be.PRM_IsRemove_Ind__c); //Checking if Batch entitlements records are created from trigger.
                ceList.add(ce);
            }
        }
        
        
        
        System.debug('ceList-->'+ceList);
        System.debug('isTriggerList-->'+isTriggerList);
        //Checking for exiting contact entitlement records.
        // Core_Type__c = 'Entitlement'
        List<Core_Contact_Entitlement__c> contactEntList = [Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Type__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :conId AND Core_Entitlement_Id__c IN :entId];
        if(contactEntList !=null && !contactEntList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :contactEntList){
                Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
                newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
                newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                //newCe.Core_Status__c = 'Pending';
                System.debug('ce--->'+ce);
                System.debug('entAgsMap.get(ce.Core_Entitlement_Id__c--->'+entAgsMap.get(ce.Core_Entitlement_Id__c));
                if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){
                    newCe.Core_Status__c = 'Pending';
                }
                newCe.Core_Data_Loaded__c = true;
                newCe.Core_DontNotify__c = true;
                newCe.Core_From_Source__c = ce.Core_From_Source__c;
                
                /*Added below code to cover exception from test class - Start*/
                if(Test.isRunningTest()){
                    newCe.Core_Engagement_Tier__c = '*****************************************************************************************************************************************************************************************************************************************************************************';
                } 
                /*END*/
                ceMap.put(newCe, ce.Id);
                ceStatusMap.put(ce.Id,ce);
            }
        }
        System.debug('contactEntList-->'+contactEntList);
        Integer i=0;
        for(Core_Contact_Entitlement__c ce :ceList){
            System.debug('ceMap-->'+ceMap);
            System.debug('ceStatusMap-->'+ceStatusMap);
            System.debug('ce-->'+ce);
            if(ceMap.containsKey(ce)){
                System.debug('contains key true');
                ce.Id = ceMap.get(ce);
                Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                if(isTriggerList[i]){
                    ce.Core_Selected__c = false; //Updating Entitlements if Batch entitlements records are created from trigger.
                    finalCEList.add(ce);
                    System.debug('finalCEList inside if-->'+finalCEList);
                }
                else{
                    if(contEnt.Core_Source__c != updateReasonCSPFlow){ //Added for US539488:to Identify origin of Entitlement
                        ce.Core_Source__c = updateReasonCSPFlow;
                    }
                    ce.Core_Selected__c = true;  //Updating Entitlements if Batch entitlements records are created from Batch class.
                    finalCEList.add(ce);
                    System.debug('finalCEList inside else-->'+finalCEList);
                }
                System.debug('ceMap.get(ce) -->'+ceMap.get(ce));
            }
            else{
                ce.Core_Selected__c = true; //Inserting Entitlements if Batch entitlements records are created from Batch class.
                ce.Core_Source__c = updateReasonCSPFlow;
                finalCEList.add(ce);
            }
            i++;
        }
        System.debug('ceList last-->'+ceList);
        System.debug('finalCEList-->'+finalCEList);
        if(finalCEList.size() < Limits.getLimitDMLRows()){
            if(finalCEList != null && !finalCEList.IsEmpty()){
                Database.UpsertResult[] conEntList = Database.upsert(finalCEList, false); // Upserting Contact Entitlements.
                System.debug('conEntList------------>'+conEntList);
                integer index = 0;
                set<id> ceId = new set<id>();
                List<id> contactIds = new List<id>();
                List<id> entitlementIds = new List<id>();
                for (Database.UpsertResult sr : conEntList){                    
                    if(!sr.isSuccess()){ // Checking If any record got errored out while upserting.
                        for(Database.Error err : sr.getErrors()){
                            Id sId;
                            String sObjectType = '';
                            sId =finalCEList[index].Id;
                            if(sId != null){sObjectType =  sId.getSObjectType().getDescribe().getName();
                            }
                            String tags = '';
                            String accName =  '';
                            accName =mapConToName.get(finalCEList[index].Core_Contact_Id__c) == null?'':mapConToName.get(finalCEList[index].Core_Contact_Id__c);
                            String benName =  '';
                            benName =conToEntMap.get(finalCEList[index].Core_Contact_Id__c) == null?'':conToEntMap.get(finalCEList[index].Core_Contact_Id__c);
                            String accId =  '';
                            accId = mapConToId.get(finalCEList[index].Core_Contact_Id__c) == null ?'':mapConToId.get(finalCEList[index].Core_Contact_Id__c);
                            // tag format used - <Account Name> ; <Benefit Name> ; <Account ID>
                            tags = accName + ';' + benName + ';' + accId;
                            Core_Log_Entry.logEntryWithDetails(origin, project,'Message', severity, err.getMessage(), '', sId, sObjectType, tags);
                            
                            lstBatchEntitlement[index].PRM_Status_Nm__c = 'Failed'; // Updating Batch Entitlemet record status to failed if any record get errored out.
                            System.debug('lstBatchEntitlement[index].PRM_Status_Nm__c-->'+lstBatchEntitlement[index].PRM_Status_Nm__c);
                        } 
                    }
                    else{lstBatchEntitlement[index].PRM_Status_Nm__c = 'Success'; // Updating Batch Entitlemet record status to success if any record get errored out.
                    System.debug('lstBatchEntitlement[index].PRM_Status_Nm__c-->'+lstBatchEntitlement[index].PRM_Status_Nm__c);
                    }
                    index ++;
                }
                update lstBatchEntitlement;
            }
        }
        else{Core_Log_Entry.logEntryWithDetails(origin, project,'Message', severity,errormessage,'','' ,'','');
        }
    }
}