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
* Subhadeep Sadhu           23/02/2022              Fix for multiple email triggered every time erpm updates the ev date
*******************************************************************************************************************************/
trigger Core_Contact on Contact(after insert, after update, before update,before delete , after delete, before insert) {
    
    //public static String ipaRefresh =  System.label.PRM_ipaRefresh;//IPA2.0 - TWC727-2793   
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    public static boolean isAlreadyUpdated= false;
    if (!mapFunctionalityNameTriggerExecution.isEmpty()) {
        
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        //Populate account billing country to contact mailing country field 
            if (mapFunctionalityNameTriggerExecution.containsKey('PopulateAccBillingCountry') && mapFunctionalityNameTriggerExecution.get('PopulateAccBillingCountry').Core_Active__c) {                
                Core_ContactHandler.ACM_SetContactAttribute(Trigger.New);             
            }
            
            //Core_ContactHandler.SetPreferredLangAndCountryCode(Trigger.New);
            //Swicth logic - TODO :: REVISIT :: This is Temp Code to fix the SOQL LIMIT
            if (mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode') && mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c) {               
                Core_ContactHandler.UpdateJobFunctionNameAndCode(Trigger.oldMap, Trigger.New);
                //Below UpdateJobFunctionCode method has been consolidated into UpdateJobFunction method. - Silam 
                //Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);                
            }
            /*if(ipaRefresh !='TRUE'){//IPA2.0 - TWC727-2793  
            Core_ContactHandler.trackCommunityChanges(Trigger.oldMap, Trigger.New);    
            }*/ // IPA Refresh - Switch removal
        }
        if(Trigger.isBefore && Trigger.isInsert)
        {
            if(mapFunctionalityNameTriggerExecution.containsKey('checkForDuplicateContact') &&
                mapFunctionalityNameTriggerExecution.get('checkForDuplicateContact').Core_Active__c){
                    Core_ContactHandler.checkForDuplicateContact(Trigger.new);
                }
            Core_ContactHandler.emptyAGSStatusOnInsert(Trigger.new);// Added by shreyash- empty AGS status while insert-unhandled exceptions
            Core_ContactHandler.countryCodeConversion(Trigger.new); // Added by rohitx.podder@intel.com - Country code coversion from two character to three character

            //commenting as part of TWC729-7704 - R4c issue to prvent outbound on creation of contact through PCR invite START
           /* if(mapFunctionalityNameTriggerExecution.containsKey('Contact_Insert_IPA_Integration_Trigger') &&
                mapFunctionalityNameTriggerExecution.get('Contact_Insert_IPA_Integration_Trigger').Core_Active__c) {
                    PRM_SalesCloudContactIntStatus_Handler.setContactIPAIntegrationStatusToPendingOnCreate(Trigger.new);
                //System.enqueueJob(new PRM_SalesCloudContactIntStatus_Handler((List<Contact>)Trigger.new, (Map<Id,Contact>)Trigger.oldMap, true));
                }*/
            //commenting as part of TWC729-7704 - R4c issue to prvent outbound on creation of contact through PCR invite END
          
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
             
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Insert') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Insert').Core_Active__c) { 
                    Core_ContactHandler.SeteRPMIntStatusToPendingOnContactCreate(Trigger.new);
                }
                
            } 
            else if (Trigger.isUpdate) {
                
                //[START : Below are IPS related methods.]
                //Contact_Handler.InactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //Contact_Handler.ReactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //  US209289 --start--checking contact condition before calling method  --- by-- vamsi--- orion-- Nov-15-2018 
       
                Set<ID> contIdSet=New Set<ID>();
         //TWC1811-36 As part of CIDAAS functionality Draco commented Identity attributes EOL on Contact
        // Set<string> contrecordIds=New Set<string>();
              //  Set<ID> cIdSet=New Set<ID>();//TWC1811-88(Draco Change) -- Notify Requester after contacts complete the Email Verification. 
                for(Contact contactRec: Trigger.new){
                    if((Trigger.oldMap.get(contactRec.id).Core_IPS_Email_Opt_Out__c <> contactRec.Core_IPS_Email_Opt_Out__c )||(Trigger.oldMap.get(contactRec.id).Core_IPS_Active__c <> contactRec.Core_IPS_Active__c )){
                        contIdSet.add(contactRec.id);
                    }
                    
                     //TWC1811-36 As part of CIDAAS functionality Draco commented Identity attributes EOL on Contact
                  /*  //TWC1811-88(Draco Change)---Start
                    //if((Trigger.oldMap.get(contactRec.id).Core_IPA_Email_Verification_Date__c != contactRec.Core_IPA_Email_Verification_Date__c) && contactRec.Core_IPA_Email_Verification_Date__c != null){
                    if(Trigger.oldMap.get(contactRec.id).Core_IPA_Email_Verification_Date__c == null && contactRec.Core_IPA_Email_Verification_Date__c != null){ //Draco fix for multiple email triggered every time erpm updates the ev date
                        cIdSet.add(contactRec.Id);
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
                //TWC1811-88(Draco Change)----Start
                if(cIdSet.size()>0 && cIdSet!=null){
                    Core_internalUserNotificationOnEV.sendEmailOnEvCompletion(New List<Id>(cIdSet));
                    if(System.Label.PRM_Tracker_Enabled=='true')
                   system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable (null,contrecordIds,false,true));                   

                }
                //TWC1811-88(Draco Change)---End
                */
                
                
                Contact_Handler.InactivateProjectMembers(Trigger.new, Trigger.oldmap);
                //[END]
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') &&
                   mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c) {
                       Core_ContactHandler.SeteRPMIntStatusToPendingOnContactUpdate(Trigger.new, Trigger.oldMap);
                   }
                //commented by Shreyash as part of TWC1811-5232 - Change to before context
               /* if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c
                   && mapFunctionalityNameTriggerExecution.containsKey('AGS_Int_Status_Pending') && mapFunctionalityNameTriggerExecution.get('AGS_Int_Status_Pending').Core_Active__c) {
                       // Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(Trigger.new);
                       Core_ContactHandler.SeteRPMAGSIntStatusToPendingOnRepublish(Trigger.new, Trigger.oldMap);
                   }*/ 
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
                    
                    //Logic for checking email domain update
                    if(objNewCon.Email != objOldCon.Email){
                        List<String> oldEmaildomain=(objOldCon.Email).split('@',2);
                        List<String> newEmaildomain=(objNewCon.Email).split('@',2);
                        Boolean updateEntitlement=false;
                        if(oldEmaildomain[1]!=newEmaildomain[1]){
                            updateEntitlement=true;
                          
                            updatedContactEmail.put(objNewCon.id,updateEntitlement);
                        }else if(oldEmaildomain[0]!=newEmaildomain[0]){
                            updateEntitlement=false;
                            updatedContactEmail.put(objNewCon.id,updateEntitlement);
                        }
                    }
                }
                
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
                    
                    // Change Account
                    if(objNewCon.AccountId != objOldCon.AccountId){
                        lstAccUpdatedContacts.add(objNewCon);
                    }
   
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
        // Changed By ankit
        //if(Trigger.isAfter && Trigger.isDelete){
        if(Trigger.isBefore && Trigger.isDelete){    
            if (mapFunctionalityNameTriggerExecution.containsKey('MergeContactEntitlements') && mapFunctionalityNameTriggerExecution.get('MergeContactEntitlements').Core_Active__c) {
                if(!Core_MergeContactHandler.isRecurssive){
                    Core_MergeContactHandler.validateToUpdDelUniqueEntitlement();
                }
            }
        }
    }    
    if(trigger.isAfter && trigger.isDelete){
        ACM_DeleteDupsOnContactMergeHandler.contactStagingRecords(trigger.oldmap.keySet());
    }
    //  if(Trigger.isAfter && Trigger.isUpdate) {
    //     if (!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('SendContactstoLicense') && mapFunctionalityNameTriggerExecution.get('SendContactstoLicense').Core_Active__c) {
    //     Core_SendContact_to_AGS_onGECChange.SendUpdatedContactsDatatoLicence(Trigger.new, Trigger.OldMap);
    //     }
    // }
    if(Trigger.isAfter && Trigger.isUpdate) {
        // ERPM Outbound Message for Entitlement     
        //Core_Entitlement_Outbound_Integrations.generateAGSeRPMOBM(Trigger.new, Trigger.OldMap);
        //Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(Trigger.new, Trigger.OldMap);
        //Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(Trigger.new, Trigger.OldMap);
        //Added by Draco related to A&E changes.....Changes In-progress
        Boolean isERPMNewDesign=false;
        if(!mapFunctionalityNameTriggerExecution.isEmpty() &&mapFunctionalityNameTriggerExecution.containsKey('ErpmApiCallProcess') && mapFunctionalityNameTriggerExecution.get('ErpmApiCallProcess').Core_Active__c){
            isERPMNewDesign=true;
        }
        Core_Entitlement_Outbound_Integrations.publishAGSMessage(Trigger.new, Trigger.OldMap);
        if(!(System.isBatch() && (PRM_Contact_Bulk_DataLoad_Utility.contactBulkLoad || PRM_Contact_Bulk_DataLoad_Utility.isAGSTrigger)) && !isERPMNewDesign){
            Core_Entitlement_Outbound_Integrations.publishERPMMessage(Trigger.new, Trigger.OldMap);
        }
        if(System.Label.PRM_Tracker_Enabled=='true'){
            Core_ContactHandler.checkExternalUserState(Trigger.newMap, Trigger.oldMap);
        }
   }
    

    if(Trigger.isBefore && Trigger.isUpdate) {
        
        Core_ContactEntitlementValidation.validateContactEnglishOnlyFields(Trigger.new, Trigger.OldMap);
        
        if(!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('ContactAccountChangeUpdate') && mapFunctionalityNameTriggerExecution.get('ContactAccountChangeUpdate').Core_Active__c){
            
            // Code for Validating Target Account
            List<Contact> lstAccUpdatedContacts = new List<Contact>();
            for(integer i = 0; i < trigger.new.size(); i++){
                Contact objNewCon = Trigger.new[i];
                Contact objOldCon = Trigger.old[i];
                if(objNewCon.AccountId != NULL && objNewCon.AccountId != objOldCon.AccountId ){
                    lstAccUpdatedContacts.add(objNewCon);
                }
            } 
            if(lstAccUpdatedContacts.size()>0 && Core_Contact_AccountChange_Handler.IS_CHANGE_ACCOUNT == false){
                Core_Contact_AccountChange_Handler.validateTargetAccount(lstAccUpdatedContacts);
            }
        }
        //Added by shreyash as part of TWC1811-5232
        if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c
                   && mapFunctionalityNameTriggerExecution.containsKey('AGS_Int_Status_Pending') && mapFunctionalityNameTriggerExecution.get('AGS_Int_Status_Pending').Core_Active__c) {
                       // Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(Trigger.new);
                       Core_ContactHandler.SeteRPMAGSIntStatusToPendingOnRepublish(Trigger.new, Trigger.oldMap);
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
    //Commented by AN - Arcade as part of unused code - WW24
    /*if(Trigger.isAfter)
    {
        if(mapFunctionalityNameTriggerExecution.containskey('userGroupMappingIndicator') && mapFunctionalityNameTriggerExecution.get('userGroupMappingIndicator').Core_Active__c)    
        {
            //Core_MDF_CCP_ContactHandler.determineContactsToBeProcessed(Trigger.new,Trigger.oldmap,Trigger.isInsert, Trigger.isUpdate);
        }
    }*/
    
    //Pratiksha
    // Praveena addded custom Setting logic
    if(Trigger.isAfter && Trigger.isUpdate){
        /*if (mapFunctionalityNameTriggerExecution.containsKey('UpdateMembershipFlagInd') && mapFunctionalityNameTriggerExecution.get('UpdateMembershipFlagInd').Core_Active__c) 
        Core_ContactHandler.UpdateMembershipFlag(Trigger.oldMap, Trigger.newMap);*/
         if (mapFunctionalityNameTriggerExecution.containsKey('UpdateExternalUserLanguageInd') && mapFunctionalityNameTriggerExecution.get('UpdateExternalUserLanguageInd').Core_Active__c) 
        Core_ContactHandler.UpdateExternalUserLanguage(Trigger.oldMap, Trigger.newMap);
        
        Trigger_Execution__mdt executionEntries = [select Active__c, Inactive_for_Profile__c, Inactive_for_User__c
                                                   from Trigger_Execution__mdt where DeveloperName ='Update_ACR_on_Soft_Contact' limit 1];
        //Trigger_Execution__mdt loc = Trigger_Execution__mdt.getInstance('Update_ACR_on_Soft_Contact');
        if(executionEntries.Active__c && !isAlreadyUpdated){
            isAlreadyUpdated = true;
            Core_ContactHandler.updateSoftContactIndicator(Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        Trigger_Execution__mdt updateParCom = Trigger_Execution__mdt.getInstance('Assign_Community_Entitlements');
        /*if(ipaRefresh !='TRUE' && updateParCom.Active__c && Core_ContactHandler.isCommunityUpdated==false){//IPA2.0 - TWC727-2793  
            Core_ContactHandler.isCommunityUpdated = true;
           Core_ContactHandler.assignPartnerCommunityContactEntitlements(Trigger.oldMap,Trigger.new);

        }*/ // IPA Refresh - switch removed
    } 
   
	if(Trigger.isAfter && Trigger.isUpdate){
        
        if (mapFunctionalityNameTriggerExecution.containsKey('MergeContactEntitlements') && mapFunctionalityNameTriggerExecution.get('MergeContactEntitlements').Core_Active__c) {
            if(!Core_MergeContactHandler.isRecurssive){
                Core_MergeContactHandler.validateToUpdDelUniqueEntitlement();
            }
        }
        
    }
  // ************Below functionality shifted to inbound trigger so commented - Praveena ***************// 
    //AGAM
/*    if(Trigger.isAfter && Trigger.isUpdate){
      ID id;
      For(Contact ConList:Trigger.new){
          id=conList.id;
      }
      If(id!=NULL){
       List<A_E_Integration_Status_Detail__c> StatusDetailID=[Select id from A_E_Integration_Status_Detail__c where A_E_Contact_Id__c=:id];
         Core_ContactHandler.insertRecordInIntegrationStatusDetail(Trigger.new,Trigger.oldMap,StatusDetailID);
      }
   }*/
}