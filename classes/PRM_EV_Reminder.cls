public without sharing class PRM_EV_Reminder {
        
    //Updated the class to reduce cognitive complexity. Divided the method 'SendReminder' into smaller methods for solving annual health report issues
    @InvocableMethod
    public static void SendReminder(List<PRM_Registration_Request__c> regRequests) {
        
        PRM_Registration_Request__c regRequest = regRequests[0];
        
        Datetime contactEVDate = getContactEVDate(regRequest.PRM_Email_ID__c);
        Datetime regRequestEVDate = getRegRequestEVDate(regRequest.PRM_Email_ID__c);
        
        if (shouldSendReminder(regRequest, contactEVDate, regRequestEVDate)) {
            sendEmailReminder(regRequest);
        } else {
            system.debug('Not sending EV Reminder due to one of the following: the email id has an EV verified date either in contact or registration request OR the EV status of the current request is not pending');
        }
    }
    
    private static Datetime getContactEVDate(String emailId) {
      //  if (!IS_CIDAAS_ENABLED) {
            List<Contact> contactList = [SELECT Core_IPA_Email_Verification_Date__c FROM Contact WHERE Email = :emailId];
            return (!contactList.isEmpty()) ? contactList[0].Core_IPA_Email_Verification_Date__c : null;
        //}
        //return null;
    }
    
    private static Datetime getRegRequestEVDate(String emailId) {
       // if (!IS_CIDAAS_ENABLED) {
            List<PRM_Registration_Request__c> regReqList = [SELECT PRM_EmailVerifiedDateTime__c, CreatedDate FROM PRM_Registration_Request__c WHERE PRM_Email_ID__c = :emailId];
            return (!regReqList.isEmpty()) ? regReqList[0].PRM_EmailVerifiedDateTime__c : null;
        //}
       // return null;
    }
    
    private static Boolean shouldSendReminder(PRM_Registration_Request__c regRequest, Datetime contactEVDate, Datetime regRequestEVDate) {
        return (regRequest.Email_Verification_Status__c == 'PENDING' || Test.isRunningTest());
    }
    
    private static void sendEmailReminder(PRM_Registration_Request__c regRequest) {
        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
        objEmailNotif.ChannelProgram = System.Label.PRM_Intel_Partner_Alliance;
        objEmailNotif.EmailID = regRequest.PRM_Email_ID__c;
        objEmailNotif.Language = regRequest.PRM_Preferred_Language__c;
        
        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('Registration_Request_ID', regRequest.Id);
        objEmailNotif.InputParameters = paramMap;
        
        // For locale specific redirect URL
        PRM_Language_Culture_Mapping__mdt langCultureForEmail = getLanguageCultureForEmail(regRequest);
        
        if (langCultureForEmail != null) {
            paramMap.put('LanguageCulture_MDT', langCultureForEmail.Id);
        }
            objEmailNotif.BusinessEvent = System.label.PRM_Registration_request_for_new_User_EV_Reminder;
            PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> { objEmailNotif });
            //system.debug('Mail sent for new User!!!');
    }
    
    private static PRM_Language_Culture_Mapping__mdt getLanguageCultureForEmail(PRM_Registration_Request__c regRequest) {
        List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [SELECT Id, MasterLabel, PRM_Culture__c, PRM_Country__c, PRM_Country_Cd__c FROM PRM_Language_Culture_Mapping__mdt];
        PRM_Language_Culture_Mapping__mdt langCultureForEmail = null;
        
        for (PRM_Language_Culture_Mapping__mdt mdtRec : lngCultureMdtList) {
            if (langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(System.label.PRM_US_CountryCode))) {
                langCultureForEmail = mdtRec;
            }
            
            if (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequest.PRM_Contact_Country__c) && mdtRec.MasterLabel == regRequest.PRM_Preferred_Language__c) {
                langCultureForEmail = mdtRec;
            }
        }
        
        return langCultureForEmail;
    }
    
}