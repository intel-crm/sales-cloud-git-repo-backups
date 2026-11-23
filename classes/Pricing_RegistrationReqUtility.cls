public without sharing class Pricing_RegistrationReqUtility {
    public static List<ChannelProgram> iqrProgram = [SELECT Id FROM ChannelProgram WHERE PRM_ProgramCode__c='IQR'];  
    public static void autoApproveIQRRegReq(List<PRM_Registration_Request__c> newReqs, Map<Id,PRM_Registration_Request__c> oldMap){        
        if(iqrProgram.size() > 0){
            try{
                List<PRM_Registration_Request__c> iqrReqsTobeAutoApproved = new List<PRM_Registration_Request__c>();
 				//Ganesh Changes
                //Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
                //Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
                Id accCreateRequestId = PRM_Registration_Request__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
				Id emailVerificationRT = PRM_Registration_Request__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
				//Ganesh Changes End
				
                for(PRM_Registration_Request__c req : newReqs){
                    if(req.PRM_Channel_Program__c==iqrProgram[0].Id /*&& oldMap.get(req.Id).RecordTypeId!=req.RecordTypeId 
                       && oldMap.get(req.Id).RecordTypeId==emailVerificationRT*/ //Commented as part od CidaaS requirments -atb
                       && req.RecordTypeId==accCreateRequestId && !String.isEmpty(req.PRM_Salesforce_ID__c)){
                           iqrReqsTobeAutoApproved.add(req);
                       }
                }
                if(iqrReqsTobeAutoApproved.size() > 0){
                    for(PRM_Registration_Request__c iqrReq : iqrReqsTobeAutoApproved){
                        iqrReq.PRM_Legal_Agreement_Criteria__c = 'SUCCESS';
                        iqrReq.PRM_Status__c = 'Approved';
                    }
                } 
            }catch(Exception exp){/*Pricing_Tender_Utility.logError(ex);*/}
            
        }
    }
    public static void createIQRContacts(List<PRM_Registration_Request__c> newReqs, Map<Id,PRM_Registration_Request__c> oldMap){
        system.debug('inside createIQRContacts');
        //List<ChannelProgram> iqrProgram = [SELECT Id FROM ChannelProgram WHERE PRM_ProgramCode__c='IQR'];
        if(iqrProgram.size() > 0){
            List<PRM_Registration_Request__c> reqToBeConverted = new List<PRM_Registration_Request__c>();        
            Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            Map<id,Contact> duplicateContacts = new Map<Id,Contact>();
            List<Contact> existingConts = new  List<Contact>();
            Set<Id> duplicateContIds = new Set<Id>();
            
            for(PRM_Registration_Request__c req : newReqs){
                if(req.PRM_Channel_Program__c==iqrProgram[0].Id /*&& oldMap.get(req.Id).RecordTypeId!=req.RecordTypeId 
                   && oldMap.get(req.Id).RecordTypeId==emailVerificationRT*/ //Commented as part od CidaaS requirments -atb
                   && req.RecordTypeId==accCreateRequestId && req.PRM_Status__c == 'Approved' && !String.isEmpty(req.PRM_Salesforce_ID__c) ){
                       reqToBeConverted.add(req);
                       if(!String.isEmpty(req.PRM_Contact_Salesforce_Id__c)){
                           duplicateContIds.add(req.PRM_Contact_Salesforce_Id__c);
                       }
                   }
            }
            system.debug('reqToBeConverted==>'+reqToBeConverted.size());
            if(duplicateContIds.size() > 0){
                duplicateContacts = new Map<Id,Contact>([SELECT id,AccountId,Email FROM Contact WHERE Id IN :duplicateContIds]);
            }
            system.debug('duplicateContacts==>'+duplicateContacts);
            if(reqToBeConverted.size() > 0){
                List<Contact> contList = new List<Contact>();
                Map<string,string> countryMapContact = new map<string,string>();
                Map<String,PRM_Registration_Request__c> regReqEmailMap = new Map<String,PRM_Registration_Request__c>();
                Set<String> legalAgrmntValues = new Set<String>();
                Set<String> subscriptions = new Set<String>();
                Set<Id> acctIds = new Set<Id>();
                for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                    countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
                }
                for(PRM_Registration_Request__c regRequest : reqToBeConverted){ 
                    acctIds.add(regRequest.PRM_Salesforce_ID__c);
                    regReqEmailMap.put(regRequest.PRM_Email_ID__c, regRequest);
                    if(!String.isEmpty(regRequest.PRM_Legal_Agreements__c)){
                        legalAgrmntValues.addAll(regRequest.PRM_Legal_Agreements__c.split(';'));
                    }
                    if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                        subscriptions.addall(regRequest.PRM_Subscriptions__c.split(';'));                    
                    } 
                    if(String.isEmpty(regRequest.PRM_Contact_Salesforce_Id__c)){                       
                        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
                        Contact cont = new Contact();
                        //system.debug('Total queries executed before language query--->'+Limits.getQueries());
                        List<String> prefLanguageList= new List<String>();
                        Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        for( Schema.PicklistEntry pickListVal : ple){
                            prefLanguageList.add(pickListVal.getValue());
                        }     
                        //system.debug('Total queries executed after language query--->'+Limits.getQueries());
                        cont.FirstName = regRequest.PRM_First_Name__c;
                        cont.LastName = regRequest.PRM_Last_Name__c;
                        cont.Email = regRequest.PRM_Email_ID__c;
                        cont.Phone = regRequest.PRM_Person_Phone_Number__c;
                        //cont.Core_Job_Function_Code__c=regRequest.PRM_Job_Function__c;
                        cont.Core_Profession__c=regRequest.PRM_Profession__c;
                        //to convert 2 digits of country into 3 digits
                        if(regRequest.PRM_Contact_Country__c != null && regRequest.PRM_Contact_Country__c != '')
                        {
                            if (regRequest.PRM_Contact_Country__c.length() == 2){
                                cont.MailingCountry = countryMapContact.get(regRequest.PRM_Contact_Country__c);
                                cont.MailingCountryCode = countryMapContact.get(regRequest.PRM_Contact_Country__c);   
                            }else{
                                cont.MailingCountry = regRequest.PRM_Contact_Country__c;
                                cont.MailingCountryCode = regRequest.PRM_Contact_Country__c;   
                            }
                        }
                        if(regRequest.PRM_Preferred_Language__c != null && regRequest.PRM_Preferred_Language__c != '' &&
                           prefLanguageList != null && prefLanguageList.contains(regRequest.PRM_Preferred_Language__c)){
                               cont.Core_Preferred_Language__c =regRequest.PRM_Preferred_Language__c;
                               cont.Core_eRPM_Language_Code__c=regRequest.PRM_Preferred_Language__c;
                           }
                        else{
                            cont.Core_Preferred_Language__c =System.Label.PRM_ENG;
                            cont.Core_eRPM_Language_Code__c=System.Label.PRM_ENG;
                        }
                        //cont.Core_Login_Id__c= regRequest.PRM_Contact_Login_ID__c ; 
                        cont.RecordTypeId = contactRecordType;
                        cont.Core_Enterprise_Id__c=regRequest.PRM_Enterprise_ID__c;
                        cont.Core_IPA_PartnerRole__c = regRequest.PRM_Partner_Role__c ; 
                        cont.AccountId = regRequest.PRM_Salesforce_ID__c; 
                        
                        //Added by Rahul for US769465
                        if(regRequest.PRM_EmailVerifiedDateTime__c != null){
                            cont.Core_IPA_Email_Verification_Date__c =   regRequest.PRM_EmailVerifiedDateTime__c;
                        }
                        
                        if(UserInfo.getUserType()!='Standard') {
                            //system.debug('User==>'+ Label.PRM_IPARegistration_Integration_UserId+';;;'+UserInfo.getUserType());
                            cont.OwnerId = Id.valueOf(Label.PRM_IPARegistration_Integration_UserId);
                            cont.Core_IPS_Intel_Support_Owner__c = Id.valueOf(Label.PRM_IPARegistration_Integration_UserId);
                        }
                        contList.add(cont); 
                    }else if(duplicateContacts.containsKey(regRequest.PRM_Contact_Salesforce_Id__c) && 
                             duplicateContacts.get(regRequest.PRM_Contact_Salesforce_Id__c).AccountId==regRequest.PRM_Salesforce_ID__c){                    
                                 existingConts.add(duplicateContacts.get(regRequest.PRM_Contact_Salesforce_Id__c));                   
                             }                               
                }
                system.debug('existingConts==>'+existingConts);
                system.debug('contList==>'+contList.size());
                Set<Id> contactIds = new Set<Id>();               
                if(contList.size() > 0){				 
                    insert contList;
                    
                    //contList.addAll(existingConts); 
                    //Ganesh Changes               
                    /*for(Contact cont: contList){
                        contactIds.add(cont.Id);
                        PRM_CreateAccountAndRelatedRecords.linkEmailLogToContact(cont.Email);
                    }*/
                    List<String> emailList = new List<String>();
    				for(Contact cont: contList){
        				contactIds.add(cont.Id);
        				emailList.add(cont.Email); // collect emails first
    				}
    				PRM_createAccountandRelatedRecords.linkBulkEmailLogToContact(emailList);
                    //Ganesh Changes End
                }
                for(Contact cont: existingConts){
                    contactIds.add(cont.Id); 
                    contList.add(cont);
                }
                if(contList.size() > 0){
                    insertIQRLegalAgreements(contList, contactIds, regReqEmailMap, legalAgrmntValues); 
                    //do we need to create subscriptions for IQR??
                    //insertContactSubscriptions(contList, contactIds, regReqEmailMap, subscriptions);
                    //Map<Id,Account> acctMap = new Map<Id,Account>([SELECT id,Name FROM Account WHERE Id IN :acctIds]);
                    //insertEntitlesForIQRContacts(contList, contactIds, acctMap);
                    insertEntitlesForIQRContactsNew(contList, contactIds, acctIds);
                }			   
            }
        }
    }    
    
    public static void insertIQRLegalAgreements(List<Contact> contacts, Set<Id> contactIds, Map<String,PRM_Registration_Request__c>  regReqEmailMap, Set<String> legalAgrmntValues){
                system.debug('insidelegalAgrmnt==>'+legalAgrmntValues);
        if(regReqEmailMap.size() > 0 && legalAgrmntValues.size() > 0){
            List<PRM_AccountLegalAgreemntAssociation__c> accLAs = new List<PRM_AccountLegalAgreemntAssociation__c>();
            Map<String,Id> legalAgrmntMap = new Map<String,Id>();
            Map<String,Set<String>> contactLAAssocs = new Map<String,Set<String>>();
            
            for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Agreement_Cd__c from PRM_PartnerAgreement__c where PRM_Agreement_Cd__c IN : legalAgrmntValues]){
                legalAgrmntMap.put(pa.PRM_Agreement_Cd__c,pa.id);
            }
            set<String>conEmail= new set<String>();
            for(Contact con1: contacts){
                conEmail.add(con1.Email);
            }
            system.debug('legalAgrmntMap==>'+legalAgrmntMap);
            for(PRM_AccountLegalAgreemntAssociation__c legalAgrment : [SELECT id,PRM_Signed_By_Email__c, PRM_Signed_By_Name__c,PRM_Partner_Agreement_Id__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c  
                                                                       FROM PRM_AccountLegalAgreemntAssociation__c 
                                                                       WHERE PRM_Signed_By_Email__c IN :conEmail AND PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values() AND PRM_InActive_Ind__c = false]){
                                                                           if(contactLAAssocs.containsKey(legalAgrment.PRM_Signed_By_Email__c)){
                                                                               contactLAAssocs.get(legalAgrment.PRM_Signed_By_Email__c).add(legalAgrment.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c);
                                                                           }else{
                                                                               contactLAAssocs.put(legalAgrment.PRM_Signed_By_Email__c, new Set<String>{legalAgrment.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c});
                                                                           }
                                                                       }
            for(Contact cont: contacts){
                String legalAgrmnts = regReqEmailMap.containsKey(cont.Email) ? regReqEmailMap.get(cont.Email).PRM_Legal_Agreements__c : null;
                if(!String.isEmpty(legalAgrmnts)){
                    for(String legalagrmnt :  legalAgrmnts.split(';')){
                        system.debug('legalagrmnt==>'+legalagrmnt+';;;contactLAAssocs==>'+contactLAAssocs.get(cont.Id));
                        if(legalAgrmntMap.containsKey(legalagrmnt) && (!contactLAAssocs.containsKey(cont.Email) || (contactLAAssocs.containsKey(cont.Email) && !contactLAAssocs.get(cont.Email).contains(legalagrmnt)))){
                            system.debug('Creating new Association');
                            PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                            acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(legalagrmnt);
                            acntLegalAgrAssoc.PRM_Account_Id__c = cont.AccountId ;
                            acntLegalAgrAssoc.PRM_Signed_By_Email__c = cont.Email ;
                            acntLegalAgrAssoc.PRM_Signed_By_Name__c = cont.FirstName+' '+cont.LastName ;
                            acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                            accLAs.add(acntLegalAgrAssoc);
                        }
                    }
                    if(accLAs.size() > 0){
                        insert accLAs;
                    }
                }
            }  
        }
    }
    
    public static void insertEntitlesForIQRContactsNew(List<Contact> contacts, Set<id> contactIds, Set<Id> acctIds){
        
        Map<Id,List<Id>> acctIdEntitlementsMap = new Map<Id,List<Id>>();
        Set<String> entNames = new Set<String>();
        
        if(contacts.size() > 0){
            //system.debug('Insert Entitlements AcctIds===>'+acctIds);
            List<Core_Contact_Entitlement__c> contEntitlements = new List<Core_Contact_Entitlement__c>();  
            
            //Select PRM_Entitlement_Id__r.Id from PRM_VXEnttlmntMatrix__c where and Account__r.Id = '0018A00000UFOdPQAX'
            for(PRM_VXEnttlmntMatrix__c acctEntMtx : [Select PRM_Entitlement_Id__r.Id,Account__r.Id from PRM_VXEnttlmntMatrix__c 
                                                      where Account__r.Id IN : acctIds and RecordType.Name =: Label.IQREntitlement_RecordType])
            {
                if(!acctIdEntitlementsMap.isEmpty() && acctIdEntitlementsMap != null && acctIdEntitlementsMap.containsKey(acctEntMtx.Account__r.Id))
                {
                    acctIdEntitlementsMap.get(acctEntMtx.Account__r.Id).add(acctEntMtx.PRM_Entitlement_Id__r.Id);
                }
                else 
                {                    
                    acctIdEntitlementsMap.put(acctEntMtx.Account__r.Id, new List<Id>{ acctEntMtx.PRM_Entitlement_Id__r.Id });
                }                                                         
            }
            
            for(Contact cont: contacts){
                if(acctIdEntitlementsMap.containsKey(cont.AccountId))
                {
                    for(Id entId : acctIdEntitlementsMap.get(cont.AccountId)){
                        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                        ce.Core_Contact_Id__c = cont.Id;
                        ce.Core_Entitlement_Id__c = entId;                        
                        ce.Core_Selected__c = true;
                        ce.Core_Data_Loaded__c = true;
                        ce.Core_DontNotify__c = true;
                        ce.Core_From_Source__c = false;                                   
                        ce.Core_Source__c = 'IQR Registration';
                        ce.Core_Status__c = 'Pending';
                        //ce.Core_Status__c = 'Complete';
                        contEntitlements.add(ce);  
                    }
                }
            }
            
            
            system.debug('contEntitlements.size()==>'+contEntitlements.size());
            if(contEntitlements.size() > 0){
                insert contEntitlements;
            }
        }
    }
    
   /* public static void insertEntitlesForIQRContactsNew(List<Contact> contacts, Set<id> contactIds, Map<id,Account> acctMap){
        
        Map<id,String> acctIdNameMap = new Map<Id,String>();
        for(Id acctId : acctMap.keySet()){
            acctIdNameMap.put(acctId, acctMap.get(acctId).Name);
        }
        Map<String,List<String>> acctNameEntitlementsMap = new Map<String,List<String>>();
        Set<String> entNames = new Set<String>();
        
        if(contacts.size() > 0){
            //system.debug('Insert Entitlements AcctIds===>'+acctIds);
            List<Core_Contact_Entitlement__c> contEntitlements = new List<Core_Contact_Entitlement__c>();       
            
            for(Pricing_Account_Entitlements_Mapping__mdt acctEntMdt : [SELECT MasterLabel,Pricing_Entitlement_Nm__c 
                                                                        FROM  Pricing_Account_Entitlements_Mapping__mdt WHERE MasterLabel IN :acctIdNameMap.values() ]){
                                                                            List<String> entNamesLst = acctEntMdt.Pricing_Entitlement_Nm__c.split(',');
                                                                            acctNameEntitlementsMap.put(acctEntMdt.MasterLabel, acctEntMdt.Pricing_Entitlement_Nm__c.split(','));  				
                                                                            entNames.addAll(entNamesLst);                                                           
                                                                        }            
            
            Set<Id> entitlementIds = new Set<Id>();
            Map<Id,Set<Id>> acctEntlIdMap = new Map<Id,Set<Id>>();
            Map<String,Id> entNameIdMap = new Map<String,Id>();
            system.debug('entNames==>'+entNames);
            if(entNames.size() > 0){
                for(Core_Entitlement__c entmnt : [SELECT id,Name FROM Core_Entitlement__c WHERE Name IN :entNames]){
                    entNameIdMap.put(entmnt.Name, entmnt.Id);
                }                
                if(entNameIdMap.size() > 0){ 
                    for(Contact cont: contacts){
                        if(acctIdNameMap.containsKey(cont.AccountId) && acctNameEntitlementsMap.containsKey(acctIdNameMap.get(cont.AccountId))){
                            for(String entName : acctNameEntitlementsMap.get(acctIdNameMap.get(cont.AccountId))){
                                if(entNameIdMap.containsKey(entName)){
                                    Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                                    ce.Core_Contact_Id__c = cont.Id;
                                    ce.Core_Entitlement_Id__c = entNameIdMap.get(entName);                        
                                    ce.Core_Selected__c = true;
                                    ce.Core_Data_Loaded__c = true;
                                    ce.Core_DontNotify__c = true;
                                    ce.Core_From_Source__c = false;                                   
                                    ce.Core_Source__c = 'IQR Registration';
                                    ce.Core_Status__c = 'Pending';
                                    //ce.Core_Status__c = 'Complete';
                                    contEntitlements.add(ce);  
                                }
                            }
                        }                        
                    }
                    system.debug('contEntitlements.size()==>'+contEntitlements.size());
                    if(contEntitlements.size() > 0){
                        insert contEntitlements;
                    }
                }                   
            }
        }
    }*/
    
    @InvocableMethod(label='Send Welcome Email to IQR Contact' description='Sends Welcome Email to IQR contacts once IQR Entitlement is Marked completed')
    public static void sendWelcomeEmail(List<Id> contactIds){
        try{
			List<PRM_EmailUtility.EmailNotification> objEmailNotifList=  new List<PRM_EmailUtility.EmailNotification>();
			 List<String> contEmailList=new List<String>();
            if(contactIds.size() > 0){
                List<Contact> contacts = [SELECT id,FirstName,Email,Account.Name FROM Contact WHERE id IN :contactIds];
                if(contacts.size() > 0){
                    for(Contact cont : contacts){
                        PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();  
                        objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;        
                        objEmailNotif.EmailID= cont.Email ;
                        objEmailNotif.Language = 'ENG';
                        Map<String,String> paramMap = new Map<String,String>();
                        paramMap.put('EV_Contact_ID',cont.Id);
                        objEmailNotif.InputParameters=paramMap;
                        objEmailNotif.BusinessEvent= Label.Pricing_Welcome_email_on_request_approval_New;
						objEmailNotifList.add(objEmailNotif);
						contEmailList.add(cont.Email);
                        PRM_EmailUtility.customPlaceholdersMap = new Map<String,String>{'{{ACCOUNTNAME}}' => cont.Account.Name, '{{IQRTOOLLINK}}' => Label.Pricing_Tender_Portal_Link};
                          //  PRM_EmailUtility.sendEmail(objEmailNotif);  
                          //  //added as part of governor limit story:4380
						//PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});      
                        //PRM_createAccountandRelatedRecords.linkEmailLogToContact(cont.Email);
                    }
					
                }
            }
            
			if(!objEmailNotifList.isEmpty()){
					PRM_EmailUtility.sendEmail(objEmailNotifList);  
					}
			 if(!contEmailList.isEmpty()){
                PRM_createAccountandRelatedRecords.linkBulkEmailLogToContact(contEmailList);
            }
        }catch(Exception exp){/*Pricing_Tender_Utility.logError(ex);*/}        
    }//End of Insert Entitlments Method
}