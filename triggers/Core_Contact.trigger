/******************************************************************************************************************************
Apex Class Name:  Core_Contact
Version     : 1.0 
Created Date: 02 NOV 2015
Function    : Trigger for the object Contact
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Venu Karumuru             11/02/2015              Added Method UpdateJobFunction() that updates Job Function based on the value in Job Function Code
* Venu Karumuru             11/02/2015              Added Method UpdateJobFunctionCode() that updates Job Function Code based on the value in Job Function
* Popcornapps               06/05/2017              Added delete trigger handler to take care of entitlement during contact merge
* Narayani Perachi          04/03/2019              Added code to call Core_MDF_UserGroupMappingAutomation on Insert and Update of contact if the Audience list contains CCP Audience
* Narayani Perachi          03/21/2019              Created Core_MDF_CCP_ContactHandler class to handle the logic to select CCP Contacts for processing 
* Pratiksha Mahajan         26/07/2019              Added Method UpdateMembershipFlag() invoke at Contact Update
* Silambarasan Munusamy     18-09-2019              Moved Job Function & Job Function Code Updates from Trigger.IsAfter to Trigger.IsBefore - Consolidated 2 methods into 1 method. 
We would be changing the contact trigger to new trigger framework after WW42.3 (IPA) - This is a tempory fix 
* Praveena Yegurla          30/03/2021              Added custom settings logic - To Methods UpdateMembershipFlag() & UpdateExternalUserLanguage() 
* Praveena Yegurla          16/04/2021              Entitlement Status Detail record creation on error in ERPM-inbound-blackbox functionality moved to Inbound trigger
* Subhadeep Sadhu           11/08/2021              Added Method sendEmailOnEvCompletion() to notify Admin user on Contact's email verification.
*******************************************************************************************************************************/
trigger Core_Contact on Contact(after insert, after update, before update, after delete, before insert) {
    
    public static String ipaRefresh =  System.label.PRM_ipaRefresh;//IPA2.0 - TWC727-2793   
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    public static boolean isAlreadyUpdated= false;
    if (!mapFunctionalityNameTriggerExecution.isEmpty()) {
        
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            for(Contact cont: Trigger.new){
                system.debug('OwnerId Before ==>'+cont.OwnerId);
                system.debug('Intel Support Owner Before ==>'+cont.Core_IPS_Intel_Support_Owner__c);
                system.debug('New Values ==>'+Trigger.new);
                system.debug('Old Values ==>'+Trigger.oldMap);
            }
            System.debug('Inside Before');
            //Core_ContactHandler.SetPreferredLangAndCountryCode(Trigger.New);
            //Swicth logic - TODO :: REVISIT :: This is Temp Code to fix the SOQL LIMIT
            //system.debug('mapFunctionalityNameTriggerExecution.containsKey() ::' + mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode'));
            //system.debug('mapFunctionalityNameTriggerExecution.get().Core_Active__c   ::' + mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c);
            if (mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode') && mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c) {
                system.debug('***Trigger.isBefore***-New Logic UpdateJobFunctionAndCode---');                
                Core_ContactHandler.UpdateJobFunctionNameAndCode(Trigger.oldMap, Trigger.New);
                //Below UpdateJobFunctionCode method has been consolidated into UpdateJobFunction method. - Silam 
                //Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);  
               }
            if(ipaRefresh !='TRUE'){//IPA2.0 - TWC727-2793  
            	Core_ContactHandler.trackCommunityChanges(Trigger.oldMap, Trigger.New); 
            }
        }
        
        if(Trigger.isBefore && Trigger.isInsert)
        {
            if(mapFunctionalityNameTriggerExecution.containsKey('Contact_Insert_IPA_Integration_Trigger') &&
                mapFunctionalityNameTriggerExecution.get('Contact_Insert_IPA_Integration_Trigger').Core_Active__c) {
                    //PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnCreate(Trigger.new);
                //System.enqueueJob(new PRM_SalesCloudContactIntStatus_Handler((List<Contact>)Trigger.new, (Map<Id,Contact>)Trigger.oldMap, true));
                }
          
        }
        
        if (Trigger.isAfter) {
            for(Contact cont: Trigger.new){
                system.debug('OwnerId After ==>'+cont.OwnerId);
                system.debug('Intel Support Owner After ==>'+cont.Core_IPS_Intel_Support_Owner__c);
            }
            if (Trigger.isInsert) {
                if (mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode') && !mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c) {
                    system.debug('***Trigger.isAfter*** Trigger.isInsert *****-New Logic UpdateJobFunctionAndCode---');
                    if (mapFunctionalityNameTriggerExecution.containsKey('contactJobFunction') && mapFunctionalityNameTriggerExecution.get('contactJobFunction').Core_Active__c) {
                        //Core_ContactHandler.UpdateJobFunction(Trigger.oldMap, Trigger.newMap);
                        //Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);
                    }
                }
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Insert') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Insert').Core_Active__c) { 
                    system.debug('eRPM_Int_Status_Pending_Insert');
                    Core_ContactHandler.SeteRPMIntStatusToPendingOnContactCreate(Trigger.new);
                }            
                // Ruby                
            } 
            else if (Trigger.isUpdate) {
                if (mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode') && !mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c) {
                    system.debug('***Trigger.isAfter*** Trigger.isInsert *****-New Logic UpdateJobFunctionAndCode---');
                    if (mapFunctionalityNameTriggerExecution.containsKey('contactJobFunction') && mapFunctionalityNameTriggerExecution.get('contactJobFunction').Core_Active__c) {
                        //Core_ContactHandler.UpdateJobFunction(Trigger.oldMap, Trigger.newMap);
                        //Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);
                    }
                }
                //[START : Below are IPS related methods.]
                //Contact_Handler.InactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //Contact_Handler.ReactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //  US209289 --start--checking contact condition before calling method  --- by-- vamsi--- orion-- Nov-15-2018 
                Set<ID> contIdSet=New Set<ID>();Set<string> contIds=New Set<string>();
                //TWC1811-36 As part of CIDAAS functionality Draco commented Identity attributes EOL on Contact
               // Set<string> contrecordIds=New Set<string>();
               // Set<ID> cIdSet=New Set<ID>();//TWC1811-88(Draco Change) -- Notify Requester after contacts complete the Email Verification. 
                for(Contact contactRec: Trigger.new){
                    if((Trigger.oldMap.get(contactRec.id).Core_IPS_Email_Opt_Out__c <> contactRec.Core_IPS_Email_Opt_Out__c )||(Trigger.oldMap.get(contactRec.id).Core_IPS_Active__c <> contactRec.Core_IPS_Active__c )){
                        contIds.add(contactRec.id);
                    }
                    
                    //TWC1811-36 As part of CIDAAS functionality Draco commented Identity attributes EOL on Contact
                   /* //TWC1811-88(Draco Change)---Start
                    //if((Trigger.oldMap.get(contactRec.id).Core_IPA_Email_Verification_Date__c != contactRec.Core_IPA_Email_Verification_Date__c) && contactRec.Core_IPA_Email_Verification_Date__c != null){
                    if(Trigger.oldMap.get(contactRec.id).Core_IPA_Email_Verification_Date__c == null && contactRec.Core_IPA_Email_Verification_Date__c != null){
                        cIdSet.add(contactRec.Id);
                        contIds.add(contactRec.Id);
                        contrecordIds.add(contactRec.Id);
                    }
                    //TWC1811-88(Draco Change)---End
                    */
                }
                if(contIdSet.size()>0){
                    Contact_Handler.InactivateInterestedParties(contIdSet);
                }
                //  US209289 --End--- vamsi--- orion-- Nov-15-2018 
                
                /* TWC1811-36 As part of CIDAAS, Draco commented Identity attributes EOL on Contact(EV Notification funtionality)
                 *  which has identity attributes like Email Verification Date, Email Verification Token & Password Token
                //TWC1811-88(Draco Change)----Start
                if(cIdSet.size()>0 && cIdSet!=null){
                    Core_internalUserNotificationOnEV.sendEmailOnEvCompletion(New List<Id>(cIdSet));
                   system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contrecordIds,false,true));                   

                }
                //TWC1811-88(Draco Change)---End
                */
                
                Contact_Handler.InactivateProjectMembers(Trigger.new);
                //[END]
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') &&
                   mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c) {
                       Core_ContactHandler.SeteRPMIntStatusToPendingOnContactUpdate(Trigger.new, Trigger.oldMap);
                   }
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c
                   && mapFunctionalityNameTriggerExecution.containsKey('AGS_Int_Status_Pending') && mapFunctionalityNameTriggerExecution.get('AGS_Int_Status_Pending').Core_Active__c) {
                       // Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(Trigger.new);
                       system.debug('Re publish contact');
                       Core_ContactHandler.SeteRPMAGSIntStatusToPendingOnRepublish(Trigger.new, Trigger.oldMap);
                   }
            }
        }
        
        //Executes after update and calls Core_Contact_EmailChange_Handler class only if Email field is changed
        if(Trigger.isAfter && Trigger.isUpdate){
            if(mapFunctionalityNameTriggerExecution.containsKey('ContactEmailChangeUpdate') && mapFunctionalityNameTriggerExecution.get('ContactEmailChangeUpdate').Core_Active__c){
                
                // creating map of updated contact
                Map<ID,Boolean> updatedContactEmail=new Map<ID,Boolean>();
                for(integer i = 0; i < trigger.new.size(); i++){
                    Contact objNewCon = Trigger.new[i];
                    Contact objOldCon = Trigger.old[i];
                    
                    System.debug('objNewCon 100-->'+objNewCon);
                    System.debug('objNewCon 101-->'+objOldCon);

                    
                    //Logic for checking email domain update
                    if(objNewCon.Email != objOldCon.Email){
                        List<String> oldEmaildomain=(objOldCon.Email).split('@',2);
                        List<String> newEmaildomain=(objNewCon.Email).split('@',2);
                        Boolean updateEntitlement=false;
                        if(oldEmaildomain[1]!=newEmaildomain[1]){
                            updateEntitlement=true;
                            //  system.debug('parent fields :: '+objNewCon.owner.email+' , '+ objNewCon.Core_IPS_Intel_Support_Owner__r.email+','+objNewCon.ownerid+','+objNewCon.Core_IPS_Intel_Support_Owner__c+','+ objNewCon.account.ownerID);
                            updatedContactEmail.put(objNewCon.id,updateEntitlement);
                        }else if(oldEmaildomain[0]!=newEmaildomain[0]){
                            updateEntitlement=false;
                            updatedContactEmail.put(objNewCon.id,updateEntitlement);
                        }
                    }
                }
                
                System.debug('==updatedContactEmail.size()===>'+updatedContactEmail.size());
                if(updatedContactEmail.size()>0){
                    Core_Contact_EmailChange_Handler.UpdateEntitlementStatus(updatedContactEmail,Trigger.oldMap);
                }
                
            }
            //Executes after update and calls Core_Contact_AccountChange_Handler class only if Account changed on contact.
            if(mapFunctionalityNameTriggerExecution.containsKey('ContactAccountChangeUpdate') && mapFunctionalityNameTriggerExecution.get('ContactAccountChangeUpdate').Core_Active__c){
                List<Contact> lstAccUpdatedContacts = new List<Contact>();
                for(integer i = 0; i < trigger.new.size(); i++){
                    Contact objNewCon = Trigger.new[i];
                    Contact objOldCon = Trigger.old[i];
                    system.debug(' >>>>>>>>>>>>>>>>>> changeAccount objNewCon.AccountId '+objNewCon.AccountId);
                    system.debug(' >>>>>>>>>>>>>>>>>> changeAccount objOldCon.AccountId '+objOldCon.AccountId);
                    
                    // Change Account
                    if(objNewCon.AccountId != objOldCon.AccountId){
                        lstAccUpdatedContacts.add(objNewCon);
                    }
                    System.debug(' >>>>>>>>>>>>>>>>>> changeAccount lstAccUpdatedContacts '+lstAccUpdatedContacts);
                    System.debug('After Account Validate Update Assets '+lstAccUpdatedContacts.size()+'Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT : '+Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT);
                    
                }
                if(lstAccUpdatedContacts.size()>0 && Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT == false){
                    Core_Contact_AccountChange_Handler.updateAssets(lstAccUpdatedContacts);
                    //eRPM trigger logic - atb
                    //Updating erpm and AGS status to pending 
                    Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(lstAccUpdatedContacts, null, true);
                }
            }
        }
        // Contact Merge Contact entitlement Update.
        if(Trigger.isAfter && Trigger.isDelete){
            if (mapFunctionalityNameTriggerExecution.containsKey('MergeContactEntitlements') && mapFunctionalityNameTriggerExecution.get('MergeContactEntitlements').Core_Active__c) {
                Core_MergeContactHandler.validateUniqueEntitlement();
            }
        }
    }    
    if(Trigger.isAfter && Trigger.isUpdate) {
        // ERPM Outbound Message for Entitlement     
        System.debug('generateErpmOutboundMessage before');
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(Trigger.new, Trigger.OldMap);
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(Trigger.new, Trigger.OldMap);
        //Added by Draco related to A&E changes.....Changes In-progress
        Core_Entitlement_Outbound_Integrations.publishAGSMessage(Trigger.new, Trigger.OldMap);
        if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger))){
            Core_Entitlement_Outbound_Integrations.publishERPMMessage(Trigger.new, Trigger.OldMap);
        }
        if(System.Label.PRM_Tracker_Enabled=='true'){
            Core_ContactHandler.checkExternalUserState(Trigger.newMap, Trigger.oldMap);
        }
   }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        Core_ContactEntitlementValidation.validateContactEnglishOnlyFields(Trigger.new, Trigger.OldMap);
        
        if(!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('ContactAccountChangeUpdate') && mapFunctionalityNameTriggerExecution.get('ContactAccountChangeUpdate').Core_Active__c){
            System.debug('Validate account change ');
            
            // Code for Validating Target Account
            List<Contact> lstAccUpdatedContacts = new List<Contact>();
            for(integer i = 0; i < trigger.new.size(); i++){
                Contact objNewCon = Trigger.new[i];
                Contact objOldCon = Trigger.old[i];
                if(objNewCon.AccountId != objOldCon.AccountId){
                    lstAccUpdatedContacts.add(objNewCon);
                }
            } 
            System.debug('lstAccUpdatedContacts.size():  '+lstAccUpdatedContacts.size());
            if(lstAccUpdatedContacts.size()>0 && Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT == false){
                Core_Contact_AccountChange_Handler.validateTargetAccount(lstAccUpdatedContacts);
            }
        }
        //Added by team Quest
        if(mapFunctionalityNameTriggerExecution.containsKey('Contact_Update_IPA_Integration_Trigger') &&
                mapFunctionalityNameTriggerExecution.get('Contact_Update_IPA_Integration_Trigger').Core_Active__c) {
                    PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnUpdate(Trigger.new, Trigger.oldMap);
                //System.enqueueJob(new PRM_SalesCloudContactIntStatus_Handler((List<Contact>)Trigger.new, (Map<Id,Contact>)Trigger.oldMap, false));
                }
    }
    
    //Pooja
    if ( Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {                    
        if (!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('intStatusLastUpdate') && mapFunctionalityNameTriggerExecution.get('intStatusLastUpdate').Core_Active__c) {
            Core_Contact_AccountChange_Handler.UpdateintStatusLastUpdate(Trigger.new, Trigger.OldMap);
            //  Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);
        }   
    }
    
    //Added by Narayani Perachi as part of UserGroupMapping Automation - CCP Release WW11.3 2019
    //Created class Core_MDF_CCP_ContactHandler - CCP Release WW13.6 2019
    if(Trigger.isAfter)
    {
        if(mapFunctionalityNameTriggerExecution.containskey('userGroupMappingIndicator') && mapFunctionalityNameTriggerExecution.get('userGroupMappingIndicator').Core_Active__c)    
        {
            Core_MDF_CCP_ContactHandler.determineContactsToBeProcessed(Trigger.new,Trigger.oldmap,Trigger.isInsert, Trigger.isUpdate);
        }
    }
    
    //Pratiksha
    //Praveena addded custom Setting logic  
    if(Trigger.isAfter && Trigger.isUpdate){
           /* if (mapFunctionalityNameTriggerExecution.containsKey('UpdateMembershipFlagInd') && mapFunctionalityNameTriggerExecution.get('UpdateMembershipFlagInd').Core_Active__c) 
            Core_ContactHandler.UpdateMembershipFlag(Trigger.oldMap, Trigger.newMap);
        system.debug('UpdateUsersLanguage before'+Limits.getQueries());*/
        if (mapFunctionalityNameTriggerExecution.containsKey('UpdateExternalUserLanguageInd') && mapFunctionalityNameTriggerExecution.get('UpdateExternalUserLanguageInd').Core_Active__c) 
            Core_ContactHandler.UpdateExternalUserLanguage(Trigger.oldMap, Trigger.newMap);
        system.debug('UpdateUsersLanguage after'+Limits.getQueries());
        
        Trigger_Execution__mdt executionEntries = [select Active__c, Inactive_for_Profile__c, Inactive_for_User__c
                                                   from Trigger_Execution__mdt where DeveloperName ='Update_ACR_on_Soft_Contact'];
        //Trigger_Execution__mdt loc = Trigger_Execution__mdt.getInstance('Update_ACR_on_Soft_Contact');
        if(executionEntries.Active__c && !isAlreadyUpdated){
            isAlreadyUpdated = true;
            Core_ContactHandler.updateSoftContactIndicator(Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        Trigger_Execution__mdt updateParCom = Trigger_Execution__mdt.getInstance('Assign_Community_Entitlements');
        if(ipaRefresh !='TRUE' && updateParCom.Active__c && Core_ContactHandler.isCommunityUpdated==false){//IPA2.0 - TWC727-2793  
            Core_ContactHandler.isCommunityUpdated = true;
           Core_ContactHandler.assignPartnerCommunityContactEntitlements(Trigger.oldMap,Trigger.new);

        }
    }
    //system.debug('Inside Contact SOQL Limit Account ==>'+Limits.getQueries()+';;'+Limits.getLimitQueries());
    //system.debug('Inside Contact SOQL Limit DML Limit Account ==>'+Limits.getDMLStatements()+';;'+Limits.getLimitDMLStatements()); 
    // ************Below functionality shifted to inbound trigger so commented - Praveena ***************// 
    //AGAM
  /* if(Trigger.isAfter && Trigger.isUpdate){
      ID id;
      For(Contact ConList:Trigger.new){
          id=conList.id;
      }
      If(id!=NULL){
       List<A_E_Integration_Status_Detail__c> StatusDetailID=[Select id from A_E_Integration_Status_Detail__c where A_E_Contact_Id__c=:id];
       Core_ContactHandler.insertRecordInIntegrationStatusDetail(Trigger.new,Trigger.oldMap,StatusDetailID);
      }
   } */
  
  
}