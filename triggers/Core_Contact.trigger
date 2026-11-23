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
*******************************************************************************************************************************/
trigger Core_Contact on Contact(after insert, after update, before update, after delete, before insert) {
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if (!mapFunctionalityNameTriggerExecution.isEmpty()) {
        
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            //Populate account billing country to contact mailing country field 
            if (mapFunctionalityNameTriggerExecution.containsKey('PopulateAccBillingCountry') && mapFunctionalityNameTriggerExecution.get('PopulateAccBillingCountry').Core_Active__c) {                
                Core_ContactHandler.UCD_ACMPopulateAccountBillingCountry(Trigger.New);             
            }
             //Swicth logic - TODO :: REVISIT :: This is Temp Code to fix the SOQL LIMIT
            if (mapFunctionalityNameTriggerExecution.containsKey('UpdateJobFunctionAndCode') && mapFunctionalityNameTriggerExecution.get('UpdateJobFunctionAndCode').Core_Active__c) {
                system.debug('***Trigger.isBefore***-New Logic UpdateJobFunctionAndCode---');
                
                    Core_ContactHandler.UpdateJobFunctionNameAndCode(Trigger.oldMap, Trigger.New);
                    //Below UpdateJobFunctionCode method has been consolidated into UpdateJobFunction method. - Silam 
                    //Core_ContactHandler.UpdateJobFunctionCode(Trigger.oldMap, Trigger.newMap);
                
            }
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {                    
                
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Insert') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Insert').Core_Active__c) { 
                    system.debug('eRPM_Int_Status_Pending_Insert');
                    Core_ContactHandler.SeteRPMIntStatusToPendingOnContactCreate(Trigger.new);
                }                               
            } 
            else if (Trigger.isUpdate) {
               
                //[START : Below are IPS related methods.]
                // Contact_Handler.InactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //Contact_Handler.ReactivateInterestedParties(Trigger.new,Trigger.oldMap);
                //  US209289 --start--checking contact condition before calling method  --- by-- vamsi--- orion-- Nov-15-2018 
                Set<ID> contIdSet=New Set<ID>();
                for(Contact contactRec: Trigger.new){
                    if((Trigger.oldMap.get(contactRec.id).Core_IPS_Email_Opt_Out__c <> contactRec.Core_IPS_Email_Opt_Out__c )||(Trigger.oldMap.get(contactRec.id).Core_IPS_Active__c <> contactRec.Core_IPS_Active__c )){
                        contIdSet.add(contactRec.id);
                    }
                }
                if(contIdSet.size()>0){
                    Contact_Handler.InactivateInterestedParties(contIdSet);
                }
                //  US209289 --End--- vamsi--- orion-- Nov-15-2018 
                
                Contact_Handler.InactivateProjectMembers(Trigger.new, Trigger.oldMap);
                //[END]
                
                //eRPM trigger logic - atb
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') &&
                   mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c) {
                       System.debug('Conatct Trigger Update');
                       Core_ContactHandler.SeteRPMIntStatusToPendingOnContactUpdate(Trigger.new, Trigger.oldMap);
                   }
                if(mapFunctionalityNameTriggerExecution.containsKey('eRPM_Int_Status_Pending_Update') && mapFunctionalityNameTriggerExecution.get('eRPM_Int_Status_Pending_Update').Core_Active__c
                   && mapFunctionalityNameTriggerExecution.containsKey('AGS_Int_Status_Pending') && mapFunctionalityNameTriggerExecution.get('AGS_Int_Status_Pending').Core_Active__c) {
                       // Core_ERPM_Outbound_Integration.forceSetERPMOutboundIntegrationStatus(Trigger.new);
                       system.debug('Re publish contact');
                       Core_ContactHandler.SeteRPMAGSIntStatusToPendingOnRepublish(Trigger.new, Trigger.oldMap);
                   }
                   //Send Contact GEC information to AGS
                   if(mapFunctionalityNameTriggerExecution.containsKey('SendContactGECInfoToAGS') &&
                   mapFunctionalityNameTriggerExecution.get('SendContactGECInfoToAGS').Core_Active__c) {
                     
                        Core_SendContact_to_AGS_onGECChange.ContactGECBlock(Trigger.New,Trigger.oldMap); 
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
        if (!mapFunctionalityNameTriggerExecution.isEmpty() && mapFunctionalityNameTriggerExecution.containsKey('SendContactstoLicense') && mapFunctionalityNameTriggerExecution.get('SendContactstoLicense').Core_Active__c) {
        Core_SendContact_to_AGS_onGECChange.SendUpdatedContactsDatatoLicence(Trigger.new, Trigger.OldMap);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        // ERPM Outbound Message for Entitlement
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(Trigger.new, Trigger.OldMap);
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(Trigger.new, Trigger.OldMap);
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
    if(Trigger.isAfter && Trigger.isUpdate){
        Core_ContactHandler.UpdateMembershipFlag(Trigger.oldMap, Trigger.newMap);
    }
}