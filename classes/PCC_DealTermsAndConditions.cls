/*************************************************************************************************************************************
Apex Class Name     : PCC_DealTermsAndConditions
Version             : 1.0
Created Date        : April 2024

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Utkarsh                 April- 2024      Added a CheckPartnerTermsAndCondition method to create Legal agreement record for   partners.
********/

public with sharing Class PCC_DealTermsAndConditions
{
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_DealTermsAndConditions';
    public static final String LOG_ENTRY_PROJECT  = 'PCC Legal Agreement';
    public static final String LOG_ENTRY_SCOPE    = 'Create Legal Agreement';
    public static final String LOG_ENTRY_SCOPE_1  = 'Create Legal Agreement';
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    public static final String LOG_ENTRY_INFO     = 'info';  

    
    /*This Method is to create Legal agreement record for   partners.*/
    @AuraEnabled
    public static List<PRM_AccountLegalAgreemntAssociation__c> CheckPartnerTermsAndCondition() {
        String userId = UserInfo.getUserId();
        List<PRM_AccountLegalAgreemntAssociation__c> createPartnerLegalAgreement = new List<PRM_AccountLegalAgreemntAssociation__c>();
        PRM_AccountLegalAgreemntAssociation__c partnerLegalAgreement =  new PRM_AccountLegalAgreemntAssociation__c();
        PRM_PartnerAgreement__c partnerAgreement = [Select id, name from PRM_PartnerAgreement__c where name = 'Deal_Registration_Terms_and_Conditions'];
        User userValues =[select id,name,ContactId,Contact.FirstName,Contact.LastName,Contact.AccountId,Contact.Email,Contact.Name from user Where Id =:userId];
        List<PRM_AccountLegalAgreemntAssociation__c> dealLegalAgreement = new List<PRM_AccountLegalAgreemntAssociation__c>();
        // IPA 2.0 -TWC729-7874 
        dealLegalAgreement = [Select Id, Name, PRM_Signed_By_Email__c, PRM_Signed_By_Name__c,PRM_Partner_Agreement_Id__c From PRM_AccountLegalAgreemntAssociation__c where PRM_Signed_By_Email__c=:userValues.Contact.Email AND PRM_Partner_Agreement_Id__c =:partnerAgreement.Id];
        //dealLegalAgreement = [Select Id, Name, PRM_Contact__c,PRM_Partner_Agreement_Id__c From PRM_AccountLegalAgreemntAssociation__c where PRM_Contact__c=:userValues.ContactId AND PRM_Partner_Agreement_Id__c =:partnerAgreement.Id];
        
        system.debug('dealLegalAgreement-->'+dealLegalAgreement);
        if(dealLegalAgreement.size() == 0){
            partnerLegalAgreement.PRM_Account_Id__c = userValues.Contact.AccountId;
            partnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
            partnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
            // IPA 2.0 -TWC729-7874 
            partnerLegalAgreement.PRM_Signed_By_Email__c = userValues.Contact.Email;
            partnerLegalAgreement.PRM_Signed_By_Name__c = userValues.Contact.FirstName+' '+userValues.Contact.LastName;
            //partnerLegalAgreement.PRM_Contact__c = userValues.ContactId;
            
            createPartnerLegalAgreement.add(partnerLegalAgreement);  
        }
            try{
              insert createPartnerLegalAgreement;
            }
            catch(Exception ex){
                system.debug('createPartnerLegalAgreement-->'+ex.getMessage());
                 Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_1, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_DealTermsAndConditions.CheckPartnerTermsAndCondition' ,'' ,ex); 
            }
        // IPA 2.0 -TWC729-7874  
        return [Select Id,PRM_Account_Id__c,PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__c,PRM_Signed_By_Email__c,PRM_Signed_By_Name__c From PRM_AccountLegalAgreemntAssociation__c Where CreatedDate>=:Date.TODAY()];
        //return [Select Id,PRM_Account_Id__c,PRM_Agreement_Sign_Dt__c,PRM_Partner_Agreement_Id__c,PRM_Contact__c From PRM_AccountLegalAgreemntAssociation__c Where CreatedDate>=:Date.TODAY()];
        
    }
}