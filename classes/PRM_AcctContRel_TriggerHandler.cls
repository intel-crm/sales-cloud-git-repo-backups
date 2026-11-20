/******************************************************************************************************************************
Apex Class Name:  PRM_AccountContactRel_Trigger
Version     : 1.0 
Created Date: 21 NOV 2018
Function    : Trigger handler for the object PRM_Account_Contact_Relationship__c

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Anupam Agarwal    06-Dec-2018          Overridden the beforeInsert(), beforeUpdate() and beforeDelete() methods 
* Teja Munagala       17-Dec-2018              Overridden the BeforeInsert(), BeforeUpdate()
* Teja Munagala       09-AUG-2019              Overridden the AfterUpdate()
* GopiKrishna       18-Oct-2021    Refactored ACR Trigger handler
******************************************************************************************************************************/

public without sharing class PRM_AcctContRel_TriggerHandler extends TriggerHandler {
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public static boolean IPAfirstRun = true;
    public static boolean firstUpdateRun = true;
    @TestVisible static Boolean executeTrigger = true;
    list<PRM_AccountChannelMembership__c> acmList;  
    
    public override void afterInsert(){
        System.debug('Calling>>>>>');
        if(executeTrigger)
        {
            if(isActive('AcctCtRel_Insert_ERPM_Integration_Trgr') && firstRun && !(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))) {
                if(Trigger.isInsert){
                    System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>)Trigger.new,  Trigger.new.getSObjectType()));
                    firstRun = false;
                }
            }       
            if(isActive('ACR_After_Insert') && PRM_AcctContRelUtility.firstRunAfterInsert){
            set<string> contids=new set<string>();
                if(Trigger.isInsert){
                    //UTKARSH - If block is to stop recurssion call insertContactEntitlement() method.
                    System.debug('PRM_AcctContRelUtility.firstRunAfterInsert-->'+PRM_AcctContRelUtility.firstRunAfterInsert);  
                    PRM_AcctContRelUtility.firstRunAfterInsert = false;
                    list<PRM_Account_Contact_Relationship__c> accid = trigger.new;
                acmList = [Select Id,PRM_Account_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Account_Id__c =: accid[0].PRM_Account_Id__c]; 
                    PRM_AcctContRelUtility.insertContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap,acmList); //Utkarsh                                  
                    /*US575709 - Start - Expose new Get Profile API in SF for secondary contact, Admin registration & Account Request flows*/
                    PRM_AGS_IdentityCreation.SendEmailVerificationAndCreateIdentityInAGS(Trigger.new);                
                    /*Finish - US575709*/
                    PRM_AcctContRelUtility.autoPopulateContactSegment(Trigger.new); 
                    for(PRM_Account_Contact_Relationship__c acr: (List<PRM_Account_Contact_Relationship__c>)Trigger.new){
                        contids.add(acr.PRM_Contact_Id__c);
                    }
                    if(contids!=null && contids.size()>0 && (!System.Isbatch() && (!System.isQueueable() || (System.isQueueable() &&  limits.getQueueableJobs() < 1  ) )) && System.Label.PRM_Tracker_Enabled=='true')
                    {
                      system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contids,false,false));                   

                    }                 
                      //PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(null,contids,null,'PRM_AcctContRel_TriggerHandler',null);
                }                
            }            
        }
    }
    
    public override void afterUpdate() {
        system.debug('ACR afterUpdate');
        if(isActive('AcctCtRel_Update_ERPM_Integration_Trgr') && firstRun && !(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))) {
            if(Trigger.isUpdate){
                System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_Account_Contact_Relationship__c>)Trigger.new,  Trigger.new.getSObjectType()));
                firstRun = false;
            }
        }        
        if(isActive('ACR_After_Update')) {
            system.debug('PRM_AcctContRelUtility.firstRunAfterUpdate-->'+PRM_AcctContRelUtility.firstRunAfterUpdate);
            system.debug('ACR afterUpdate ===> 222');
            Set<Id> SetConIdsForUnCheckSupression = new Set<Id>();
            list<PRM_Account_Contact_Relationship__c> acrlis= new list<PRM_Account_Contact_Relationship__c>();
            map<string,string> contactSourceMap=new map<string,string>();
            set<String> contids=new set<String>();
            if(trigger.Isupdate && PRM_AcctContRelUtility.firstRunAfterUpdate){
                PRM_AcctContRelUtility.firstRunAfterUpdate = false;
        
                list<PRM_Account_Contact_Relationship__c> accid = trigger.new;
                acmList = [Select Id,PRM_Account_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c,PRM_Status_Nm__c From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Account_Id__c =: accid[0].PRM_Account_Id__c];
                PRM_AcctContRelUtility.insertContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap,acmList); //TWC727-747 - Utkarsh - Passed acmlist as parameter.
                PRM_AcctContRelUtility.inactivateContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);//Utkarsh
                PRM_AcctContRelUtility.activateContactEntitlement(Trigger.new,(map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap,acmList);//Utkarsh                
                //Email to primary contact when such incative operation of ACR happen
                map<id,PRM_Account_Contact_Relationship__c> mapOldAcrs = (map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap;
                PRM_AcctContRelUtility.emailForPrimaryContact(Trigger.oldMap,Trigger.newMap); // AGATE Team method
                for(PRM_Account_Contact_Relationship__c acr : (List<PRM_Account_Contact_Relationship__c>)Trigger.new){
                    PRM_Account_Contact_Relationship__c oldAcr = mapOldAcrs.containsKey(acr.id) ? mapOldAcrs.get(acr.id) : null;
                    if(oldAcr.PRM_Suppress_Email__c != acr.PRM_Suppress_Email__c && !acr.PRM_Suppress_Email__c){
                        SetConIdsForUnCheckSupression.add(acr.PRM_Contact_Id__c);
                    }
                    if( (oldAcr.PRM_InActive_Ind__c!= acr.PRM_InActive_Ind__c && acr.PRM_InActive_Ind__c==false ) || (oldAcr.PRM_Status_Nm__c!= acr.PRM_Status_Nm__c && acr.PRM_Status_Nm__c=='Pending Action') || (oldAcr.PRM_AGS_Response_Status__c!= acr.PRM_AGS_Response_Status__c)){
                        contids.add(acr.PRM_Contact_Id__c);
                    }
                    
                }
                if(contids.size()>0 && !System.Isbatch() && System.Label.PRM_Tracker_Enabled=='true')
                  //PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(null,contids,null,'PRM_AcctContRel_TriggerHandler',null);
                    system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contids,false,false));

            }
            if(!SetConIdsForUnCheckSupression.isEmpty()){
                List<PRM_Email_Handler__c> listEmailHandler = [
                    SELECT
                        Id
                    FROM PRM_Email_Handler__c
                    WHERE PRM_Contact__c IN :SetConIdsForUnCheckSupression
                    AND PRM_Suppress_Email__c = true
                    AND PRM_Email_Handler_Status__c != 'Completed'
                ];
                if(!listEmailHandler.isEmpty()){
                    for(PRM_Email_Handler__c emailHanlder : listEmailHandler){
                        emailHanlder.PRM_Suppress_Email__c = false;
                    }
                    
                    List<Database.SaveResult> results = Database.update(listEmailHandler,false);

                    for (Database.SaveResult saveResult : results) {            
                        if (!saveResult.isSuccess()) {
                            String errorMessage = '';
                            for (Database.Error err: saveResult.getErrors()) {
                                errorMessage += err.getFields() + '\n'+ err.getMessage();                    
                            }
                            Core_Log_Entry.logEntryWithDetails('PRM_AcctContRel_TriggerHandler', 'IPA', 'PRM_AcctContRel_TriggerHandler', 'Low','DML on PRM_Email_Handler__c'+system.now() ,errorMessage, '', '', '');
                        }       
                    } 
                }

                
            }   
            if(firstUpdateRun)
            {
                System.debug('firstUpdateRun : '+firstUpdateRun);
                if(Trigger.isUpdate){
                    PRM_AGS_IdentityCreation.ReInviteBySendingEmailVerification((Map<Id,PRM_Account_Contact_Relationship__c>)Trigger.oldMap,Trigger.new);
                    firstUpdateRun = false;
                }
            }
        }
    }
    
    public override void beforeInsert(){
        if(executeTrigger)
        {
            if(isActive('Ags_Outbound_Msg') && PRM_AcctContRelUtility.firstRunBeforeInsert) { //Retrieved from Custom labels                
                if(Trigger.isInsert){
                    PRM_AcctContRelUtility.firstRunBeforeInsert = false;
                    PRM_AcctContRelUtility.duplicateRecordCheck(Trigger.new,(Map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap); //Anupam Agrawal
                    if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
                        PRM_AcctContRelUtility.updateStartandEndDates(Trigger.new,(Map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);//Tejasree
                    } 
                    PRM_AcctContRelUtility.suppressEmail(Trigger.new, null);
                    PRM_AcctContRelUtility.restrictContactAssociatedSystemAcc(Trigger.new);
                    for(PRM_Account_Contact_Relationship__c acr : (List<PRM_Account_Contact_Relationship__c>) Trigger.new){
                        if(String.isBlank(acr.PRM_Initiated_By__c)){
                            acr.PRM_Initiated_By__c = Userinfo.getUserId();
                        }
                    }
                }               
            }
            //Update PRM_Account_Contact_Relationship Status Field to Pending Action                               
            if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){//Bypass update of Status Field if contact is loaded through Bulk Process
                if(Trigger.isInsert){
                    PRM_AGS_IdentityCreation.updateAcctContRelation_StatusField(Trigger.new);
                }
            }
        }
    }
    public override void beforeUpdate() {
        system.debug('ACR beforeUpdate');
        if(isActive('Ags_Outbound_Msg') && PRM_AcctContRelUtility.firstRunBeforeUpdate) { //Retrieved from Custom labels
            system.debug('ACR beforeUpdate ===> 111'); 
            if(Trigger.isUpdate){           
                PRM_AcctContRelUtility.firstRunBeforeUpdate = false;
                PRM_AcctContRelUtility.mandatoryRelationshipCheck(Trigger.new, Trigger.old, (Map<Id, PRM_Account_Contact_Relationship__c>)Trigger.oldMap);
                PRM_AcctContRelUtility.duplicateRecordCheck(Trigger.new,(Map<id,PRM_Account_Contact_Relationship__c>)trigger.oldMap);
                PRM_AcctContRelUtility.updateStartandEndDates(Trigger.new,(Map<Id,PRM_Account_Contact_Relationship__c>)Trigger.oldMap);//Tejasree
                PRM_AcctContRelUtility.softContactCheck(Trigger.new, Trigger.old, (Map<Id, PRM_Account_Contact_Relationship__c>)Trigger.oldMap);
                PRM_AcctContRelUtility.suppressEmail(Trigger.new, (Map<Id, PRM_Account_Contact_Relationship__c>)Trigger.oldMap);

                PRM_AcctContRelUtility.updateSuppressEmail(Trigger.new,(Map<Id,PRM_Account_Contact_Relationship__c>)Trigger.oldMap);
            }
        }
    }
    
    public override void beforeDelete() {
        if(isActive('Ags_Outbound_Msg') && PRM_AcctContRelUtility.firstRunBeforeDelete) { //Retrieved from Custom labels
            if(Trigger.isUpdate){
                PRM_AcctContRelUtility.firstRunBeforeDelete=false;
                 //Commenting this method - Agate: Data Purge Stories ACR
                //PRM_AcctContRelUtility.mandatoryDeletionCheck(Trigger.old);
            }
        }
    }    
}