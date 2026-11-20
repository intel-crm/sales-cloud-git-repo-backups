/************************************************************************************************************************************************************************************
* Class Name  : PSS_SendEmailToContactsOnAddOrRemove 
* Version     : 1.0 
* Created Date: 08/26/2021
* Modification Log :
*
* Developer                                 Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Priyanka                                08/26/2021                      class PSS_SendEmailToContactsOnAddOrRemove to handle sending emails for Solution shared/Unshared Scenarios.
*************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest 
public without sharing class PSS_SendEmailToContactsOnAddOrRemove {	
    
    //wrapper to recieve the id and template name from process builder PSS_SendEmailToSharedContacts
    /*public class ContactAssociationWrapper {
        @InvocableVariable(label='Contact Association Id' description='Contact Association Id Captured here' required=true )
        public Id contactAssId;
        @InvocableVariable(label='Template Name' description='Template Name is Captured here' required=true)
        Public String templateName;
    }
    
    
    @InvocableMethod(label='Send Emails for Contacts' description='Sends the email to Contact of solution')
    public static void sendEmailToContacts(List<ContactAssociationWrapper> contactAssociationDetails) {
        //fetch the template name
        String templateName=contactAssociationDetails[0].templateName;//template to be used to send email
        Map<Id,Id> sharedContactWhatIdMap = new Map<Id,Id>();// map of userId,solutionId 
        Map<Id,Id> submitterWhatIdMap= new Map<Id, Id>();// map of userId,Solution
        
        List<Id> contactAssIdList= new List<Id>();// contact association id will be stored here
        //get all the contact association ids 
        for(ContactAssociationWrapper req: contactAssociationDetails){
            contactAssIdList.add(req.contactAssId);
        }
        
        List<PSS_Solution_Contact_Association__c> solutionContactsToEmail = new List<PSS_Solution_Contact_Association__c>();
        // CRUD Check
        if(Schema.sObjectType.PSS_Solution_Contact_Association__c.isAccessible()){
            //get all the shared contacts to which we need to send email.
            solutionContactsToEmail = [SELECT Id,PSS_Solution_Name__c,PSS_Solution_Name__r.PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                                       PSS_Solution_Name__r.CreatedById,PSS_Solution_Name__r.CreatedBy.IsActive,PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__c,
                                       PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__r.IsActive,
                                       PSS_Assigned_User__c,PSS_Assigned_Contact__c,PSS_Assigned_Contact__r.Name
                                       FROM PSS_Solution_Contact_Association__c
                                       WHERE Id IN:contactAssIdList AND PSS_Assigned_User__r.IsActive=true];
        }
        
       //To Popuated the sharedContactsListToProcess list of PSS_EmailTemplateController to display the
       //contact details in the vf components PSS_SolutionUnsharedSubmitter, PSS_SolutionSharedSubmitter
       PSS_EmailTemplateController.sharedContactsListToProcess=solutionContactsToEmail;

        //populate, user,whatid map for sending email.
        for(PSS_Solution_Contact_Association__c solutionContact: solutionContactsToEmail){
            //map to send email to shared contacts
            sharedContactWhatIdMap.put(solutionContact.PSS_Assigned_User__c,solutionContact.PSS_Solution_Name__c);
            Id submitterId=NULL;
            if(solutionContact.PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__c != NULL){
                if(solutionContact.PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__r.IsActive==true){
                    submitterId=solutionContact.PSS_Solution_Name__r.PSS_Solution_Submitter_UserId_Id__c;
                }
            }
            else if(solutionContact.PSS_Solution_Name__r.CreatedBy.IsActive==true){
                submitterId=solutionContact.PSS_Solution_Name__r.CreatedById;
            }
            if(submitterId!=NULL){
                submitterWhatIdMap.put(submitterId,solutionContact.PSS_Solution_Name__c);
            }
            
        }
        
        //We send the Emails to submitter/creator and shared contact when solution shared or unshared from Add Contacts button in the solution detail/create -edit page.
        //When solution is shared, we use PSS_Solution_Shared template for Contacts Email and PSS_Solution_Shared_Submitter template for Submitter email
        //Similarly, When solution is Unshared, we use PSS_Solution_Unshared template for Contacts Email and PSS_Solution_Unshared_Submitter template for Submitter email
        if(!sharedContactWhatIdMap.keySet().isEmpty()){
            //Send email to contact when solution is shared or unshared with them
            PMP_Utility.sendEmailAndLogData(templateName, sharedContactWhatIdMap);
        }
        
        if(!submitterWhatIdMap.keySet().isEmpty()){
            //send email to submitter or creator when solution shared or unshared
            //templateName we recieve here is either PSS_Soution_Shared /PSS_Solution_Unshared
           
            //if template = PSS_Soution_Shared, we have the template with the name PSS_Soution_Shared_Submitter which we use for submitter email,
            // so we are appending the _Submitter for the recieved template.
            
            // Similary ,if template = PSS_Soution_Unshared, we have the template with the name PSS_Soution_Unshared_Submitter which we use for submitter email,
            // so we are appending the _Submitter for the recieved template
            PMP_Utility.sendEmailAndLogData(templateName+'_Submitter',submitterWhatIdMap);
        }   
    }*/
    
}