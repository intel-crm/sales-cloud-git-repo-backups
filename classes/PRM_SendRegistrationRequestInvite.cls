public class PRM_SendRegistrationRequestInvite {
    /*
    @AuraEnabled
    public static String sendInviteEmail(String regRequestID){
        String statusMsg = '';
        try{
            if(String.isNotBlank(regRequestID)){
                Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
                List<PRM_Registration_Request__c> regRequestList = [Select Id, PRM_Email_ID__c, PRM_Preferred_Language__c, recordTypeId, PRM_Contact_Country__c from PRM_Registration_Request__c where id = :regRequestID];
                if(!regRequestList.isEmpty() && regRequestList[0].recordTypeId == emailVerificationRT){
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail; 
                    List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];   //Added by Teja as per PMD Scan from Line 217
                    for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                        if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                            langCultureForEmail = mdtRec;
                        }
                        if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequestList[0].PRM_Contact_Country__c) && mdtRec.MasterLabel == regRequestList[0].PRM_Preferred_Language__c){
                            langCultureForEmail = mdtRec;
                        }
                    }
                    
                    PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                    objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;                 
                    objEmailNotif.EmailID= regRequestList[0].PRM_Email_ID__c ;
                    objEmailNotif.Language = regRequestList[0].PRM_Preferred_Language__c ;
                    Map<String,String> paramMap = new Map<String,String>();
                    paramMap.put('Registration_Request_ID',regRequestList[0].id);                
                    if(langCultureForEmail != null){
                        paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                    }
                    objEmailNotif.InputParameters=paramMap;                                                      
                    objEmailNotif.BusinessEvent=System.label.PRM_Resend_Registration_Request_Invite;   
                    //PRM_EmailUtility.sendEmail(objEmailNotif);
                    //added as part of governor limit story:4380
                    PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif}); 
                    statusMsg = 'SUCCESS';
                    system.debug('mail sent for new User!!!');
                }
                       
            }
        }catch(Exception e){
            statusMsg = 'FAILED';
        }
        
        return statusMsg;
    }
    */
    
}