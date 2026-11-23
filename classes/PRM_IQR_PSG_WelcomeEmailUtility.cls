public class PRM_IQR_PSG_WelcomeEmailUtility {

    /*
	@InvocableMethod(label='Send Welcome Email to IQRPSG Contact' description='Sends Welcome Email to IQR PSG contacts once PSG Disti Quoting Access Entitlement is Marked completed')
    public static void sendWelcomeEmailForIQRPSG(List<Id> contactIds){
        try{
            list<PRM_EmailUtility.EmailNotification> objEmailNotifList=new list<PRM_EmailUtility.EmailNotification> ();    						  
            List<String> contEmailList=new List<String>();
            if(contactIds.size() > 0){
                List<Contact> contacts = [SELECT id,FirstName,Core_Preferred_Language__c,Email,Account.Name,Core_Email_Verification_Token__c,
                                          Core_IPA_Email_Verification_Date__c,Core_Password_Token__c
                                          FROM Contact WHERE id IN :contactIds];
				
                if(contacts.size() > 0){
                    system.debug('method invoked');
                    for(Contact cont : contacts){
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                        objEmailNotif.ChannelProgram='Intel Quote Request';        
                        objEmailNotif.EmailID= cont.Email ;
                        if(cont.Core_Preferred_Language__c!=Null){
                            objEmailNotif.Language = cont.Core_Preferred_Language__c;
                        }else{
                            objEmailNotif.Language = 'ENG';
                        }
                        Map<String,String> paramMap = new Map<String,String>();
                        paramMap.put('EV_Contact_ID',cont.Id);
                        objEmailNotif.InputParameters=paramMap;
                        objEmailNotif.BusinessEvent= 'Welcome_email_on_request_approval_New';
                        List<PRM_Language_Culture_Mapping__mdt> lngCultureMdt = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt WHERE MasterLabel = :cont.Core_Preferred_Language__c ];
                        String culture = lngCultureMdt.size() > 0 ? lngCultureMdt[0].PRM_Culture__c : 'en';
                        if(cont.Core_IPA_Email_Verification_Date__c != null){
                            PRM_EmailUtility.customPlaceholdersMap = new Map<String,String>{'{{TOOLLINK}}' => ''};
                                }
                        else if(cont.Core_Email_Verification_Token__c != null){                            
                            System.debug('Link with EvToken '+String.format(Label.PRM_EVToken, new List<Object>{culture ,cont.Core_Email_Verification_Token__c}));
                            PRM_EmailUtility.customPlaceholdersMap = new Map<String,String>{ '{{TOOLLINK}}' => String.format(Label.PRM_EVToken, new List<Object>{culture ,cont.Core_Email_Verification_Token__c})};                                                                                                                      
                                }
                        else if(cont.Core_Password_Token__c != null){
                            System.debug('Link with PwdToken '+String.format(Label.PRM_Pwd_Token, new List<Object>{culture, cont.Core_Password_Token__c}));
                            PRM_EmailUtility.customPlaceholdersMap = new Map<String,String>{ '{{TOOLLINK}}' => String.format(Label.PRM_Pwd_Token, new List<Object>{culture, cont.Core_Password_Token__c})};                                                              
                                }                       
                        //PRM_EmailUtility.sendEmail(objEmailNotif); 
                        //added as part of governor limit story:4380
                        //PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif}); 
						objEmailNotifList.add(objEmailNotif);
                        contEmailList.add(cont.Email);
                       // PRM_createAccountandRelatedRecords.linkEmailLogToContact(cont.Email);
                    }
					
                }
            }  
            if(!objEmailNotifList.isEmpty()){
                PRM_EmailUtility.sendEmail(objEmailNotifList); 
            }
            if(!contEmailList.isEmpty()){
                PRM_createAccountandRelatedRecords.linkBulkEmailLogToContact(contEmailList);
            }

        }catch(Exception exp){
            System.debug('Exception'+exp.getMessage());
        }        
    }
    */
}