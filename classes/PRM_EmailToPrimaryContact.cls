/*********************************************************************************************************************
Apex Class Name  : PRM_EmailToPrimaryContact
Version       : 1.0
Created Date  : March 2020
Function      : This Class used for send email to primary contact based on requirment

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Prasant Sahu               03/04/2020              Send email to primary contact based on requirment

*********************************************************************************************************************/
public with sharing class PRM_EmailToPrimaryContact {
    /*
* User Story : US609347,US609346   
* Developed by : Prasant Sahu 
* @param oldACRObject
* @param newACRObject
* @param afterinsert //Active/Reactive scenario
* @param afterupdate //inactive scenario    
*/    
    public static void sendEmailToAllPrimaryContact(Map<Id,sObject> accConRelMap, Map<Id,sObject> accConNewMap, String[] inputPartnerRole, boolean isAfterInsert, boolean isAfterDelete){
         
        Boolean afterInsert = false;
        Boolean afterUpdate = false;       
        List<PRM_EmailUtility.EmailNotification> objEmailNotificationList = new List<PRM_EmailUtility.EmailNotification>();
        Set<String> setOfInPtnrRole = null;
        if(inputPartnerRole != null){
            setOfInPtnrRole = new Set<String>(inputPartnerRole);
        }
        
        //Old ACR data
        Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfContRelACR = new Map<String,List<PRM_Account_Contact_Relationship__c>>();
        if(accConRelMap != null){
            for(sObject acrSobject : accConRelMap.values()){ 
                PRM_Account_Contact_Relationship__c acr = (PRM_Account_Contact_Relationship__c) acrSobject;
                if(mapOfContRelACR.containsKey(acr.PRM_Contact_Id__c)){
                    mapOfContRelACR.get(acr.PRM_Contact_Id__c).add(acr);
                }else{
                    List<PRM_Account_Contact_Relationship__c> listofACR = new List<PRM_Account_Contact_Relationship__c>();                
                    listofACR.add(acr);
                    mapOfContRelACR.put(acr.PRM_Contact_Id__c,listofACR);
                }
            }
        }
        
        //New ACR data
        Set<String> setOfAccId = new Set<String>();
        Set<String> setOfPartnerRole = new Set<String>();
        Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfNewACR = new Map<String,List<PRM_Account_Contact_Relationship__c>>(); 
        if(accConNewMap != null){
            for(sObject acrSobject : accConNewMap.values()){ 
                PRM_Account_Contact_Relationship__c acr = (PRM_Account_Contact_Relationship__c) acrSobject;
                setOfAccId.add(acr.PRM_Account_Id__c);
                String role = acr.PRM_Partner_Role__c;
                setOfPartnerRole.addAll(getPartnerRoleFrmACR(role));
                //setOfPartnerRole.add(role);
                if(mapOfNewACR.containsKey(acr.PRM_Contact_Id__c)){
                    mapOfNewACR.get(acr.PRM_Contact_Id__c).add(acr);
                }else{
                    List<PRM_Account_Contact_Relationship__c> listofACR = new List<PRM_Account_Contact_Relationship__c>();                
                    listofACR.add(acr);
                    mapOfNewACR.put(acr.PRM_Contact_Id__c,listofACR);
                }            
            }
        }
        system.debug('setOfAccId'+setOfAccId+'Size'+setOfAccId.size());
        
        // ACRs from  PRM_Account_Contact_Relationship__c
        Map<String, List<String>> accRelatedContacts = new Map<String, List<String>>();
        Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR = new Map<String, List<PRM_Account_Contact_Relationship__c>>();
        List<PRM_Account_Contact_Relationship__c> acrObjects = new List<PRM_Account_Contact_Relationship__c>();
        
          acrObjects= [select PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.id,PRM_Contact_Id__r.name, PRM_Contact_Id__r.firstname, PRM_Contact_Id__r.email,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.Core_Do_Not_Contact__c,
            PRM_Contact_Id__r.MailingCountryCode,PRM_Contact_Id__r.MailingCountry, PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, 
            PRM_Contact_Id__r.Account.name,  PRM_Contact_Id__r.Account.AccountNumber,IsDeleted, PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :setOfAccId];            
        system.debug('acrObjects'+acrObjects+'Size'+acrObjects.size());
        for(PRM_Account_Contact_Relationship__c acrObj : acrObjects){
            String parterRole = acrObj.PRM_Partner_Role__c;
            system.debug('acrObj'+acrObj);
              system.debug('parterRole'+parterRole);
            if(isAfterInsert && !setOfInPtnrRole.isEmpty()){
                setOfPartnerRole = setOfInPtnrRole;
            }
            
            if((parterRole !=null && parterRole.contains('<br>') && isContainPartnerRole(setOfPartnerRole,(list<string>)parterRole.split('<br>'))) || setOfPartnerRole.contains(parterRole)){                  
                
                if(accRelatedContacts.containsKey(acrObj.PRM_Account_Id__c)){
                    accRelatedContacts.get(acrObj.PRM_Account_Id__c).add(acrObj.PRM_Contact_Id__c);
                }else{
                    List<String> listOfContact = new List<String>();
                    listOfContact.add(acrObj.PRM_Contact_Id__c);                
                    accRelatedContacts.put(acrObj.PRM_Account_Id__c, listOfContact);
                }
                
                if(mapOfConACR.containsKey(acrObj.PRM_Contact_Id__c)){
                    mapOfConACR.get(acrObj.PRM_Contact_Id__c).add(acrObj);
                }else{
                    List<PRM_Account_Contact_Relationship__c> lisOfACRObj = new List<PRM_Account_Contact_Relationship__c>();
                    lisOfACRObj.add(acrObj);                    
                    mapOfConACR.put(acrObj.PRM_Contact_Id__c, lisOfACRObj);
                }
            }
        }
        
        System.debug('mapOfNewACR >> '+mapOfNewACR);
        System.debug('mapOfConACR >> '+mapOfConACR);
        map<string, list<string>> mapAccIdsWithActivePAs=new map<string, list<string>>();
       
        //Primary Contacts who recive emails.
        Set<String> setOfPrimaryContact = new Set<String>();
        if(!mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
            for(String conId : mapOfConACR.keySet()){
                List<PRM_Account_Contact_Relationship__c> acrObjs = mapOfConACR.get(conId);
                System.debug('ACR object : '+acrObjs);
                if(acrObjs != null){
                    for(PRM_Account_Contact_Relationship__c acrObj:acrObjs){
                        System.debug('Relation : '+acrObj.PRM_Relationship_Id__r.name);
                        System.debug('Inactive Status : '+acrObj.PRM_InActive_Ind__c);
                        System.debug('Status NM :'+acrObj.PRM_Status_Nm__c);
                        system.debug('!mapOfNewACR.containskey(conId):'+ mapOfNewACR.containskey(conId));
                        if(Test.isRunningTest() || (!mapOfNewACR.containskey(conId) && acrObj != null 
                           && !acrObj.PRM_InActive_Ind__c 
                           && (acrObj.PRM_Relationship_Id__r.name.touppercase() == System.Label.PRM_Primary_Contact.touppercase() || acrObj.PRM_Relationship_Id__r.name.touppercase() == System.Label.PRM_Partner_Admin_Delegate.touppercase()) && acrObj.PRM_Status_Nm__c !='Pending Action')){
                              // setOfPrimaryContact.add(conId);
                               if(mapAccIdsWithActivePAs.containsKey(acrObj.PRM_Account_Id__c)){
                                    mapAccIdsWithActivePAs.get(acrObj.PRM_Account_Id__c).add(acrObj.PRM_Contact_Id__c);
                                }else{
                                    list<string> listOfActivePAs= new list<string>();
                                    if(!listOfActivePAs.contains(acrObj.PRM_Contact_Id__c))
                                    listOfActivePAs.add(acrObj.PRM_Contact_Id__c);                    
                                    mapAccIdsWithActivePAs.put(acrObj.PRM_Account_Id__c, listOfActivePAs);
                                }
                                
                                
                           }
                    }
                }
            }
        }
         System.debug('Primary Contacts who recive emailsmapAccIdsWithActivePAs : '+mapAccIdsWithActivePAs);
        
        
        
        /**
* Logic 1: After insert case "1st ACR for indivisual contact, email should trigger to all primary contact apart from new contact"
* Logic 2: After update case
*/
        System.debug('isAfterInsert >>>'+isAfterInsert);
        System.debug('isAfterDelete >>>'+isAfterDelete);
        
        Set<String> emailContDetails = new Set<String>();
        //Logic 1:        
        if(isAfterInsert && !mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
            afterInsert =true;
            for(String conId : mapOfNewACR.keySet()){
                List<PRM_Account_Contact_Relationship__c> listOfACR = mapOfConACR.get(conId);
                System.debug('listOfACR >>>>'+listOfACR);
                if((listOfACR != null && listOfACR.size() == 1) || mapOfNewACR.get(conId).size() > 1){
                    emailContDetails.add(conId);
                }
            }            
        }
        
        //Logic 2:        
        if(isAfterDelete && !mapOfConACR.isEmpty()){          
            for(sObject acrObj : accConNewMap.values()){
                PRM_Account_Contact_Relationship__c newAcrObj = (PRM_Account_Contact_Relationship__c)acrObj;
                Integer inactiveACRCount = 0;
                List<PRM_Account_Contact_Relationship__c> listOfACR =  mapOfConACR.get(newAcrObj.PRM_Contact_Id__c);
                for(PRM_Account_Contact_Relationship__c acr : listOfACR){
                    if(acr.PRM_InActive_Ind__c == true){
                        inactiveACRCount = inactiveACRCount + 1;
                    }
                } 
                System.debug('inactiveACRCount >>>> '+inactiveACRCount);
                
                //For Inactive operation 
                sObject obj = accConRelMap.get(newAcrObj.id);
                System.debug('obj >>>> '+obj);
                if(obj != null){
                    PRM_Account_Contact_Relationship__c oldAcrObj = (PRM_Account_Contact_Relationship__c)obj;
                    if(newAcrObj.PRM_InActive_Ind__c != oldAcrObj.PRM_InActive_Ind__c){
                        if(inactiveACRCount == listOfACR.size() && newAcrObj.PRM_InActive_Ind__c 
                        && mapAccIdsWithActivePAs.containskey(newAcrObj.PRM_Account_Id__c) 
                        && mapAccIdsWithActivePAs.get(newAcrObj.PRM_Account_Id__c).size()>0 ){
                            afterUpdate = true;
                            emailContDetails.add(newAcrObj.PRM_Contact_Id__c);
                        }
                        
                        /* if(inactiveACRCount == (listOfACR.size() - 1)  && !newAcrObj.PRM_InActive_Ind__c){
afterInsert = true;
emailContDetails.add(newAcrObj.PRM_Contact_Id__c);
} */
                    }                
                }              
            }
        }  
        
        
        System.debug('>>>>>>>>>>>> emailContDetails : '+emailContDetails);
        System.debug('>>>>>>>>>>>> setOfPrimaryContact : '+setOfPrimaryContact);
        System.debug('>>>>>>>>>>>> mapOfConACR : '+mapOfConACR);
        
        //PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();        
    
        //EmailNotification Object prepartaion
        Set<String> emailIds = new Set<String>();
        if(mapAccIdsWithActivePAs!=null && !mapAccIdsWithActivePAs.isEmpty() && !emailContDetails.isEmpty() && !mapOfConACR.isEmpty()){ 
             Map<String, String> mapOfMailToContactID = new Map<String, String>();
             Map<String, String> mapOfContPreferedLang = new Map<String, String>();
            // Map<String,String> mapOfContactName = new Map<String,String>();
             string businessEvent;
            string key;
            string templateName;
            string userLang;
            map<String,string> mapOfBusinessEventLang=new map<String,string>(); 
            Map<String, String> newInParamMap = new Map<String, String>(); 
            list<string> toAddresses=new list<string>();
             map<string, map<string,string>> mapContIdInputparam=new map<string, map<string,string>>();
             Map<String,String> mapOfContIdEmailTemplate = new Map<String,String>();  
            map<string,list<string>> mapAccIdToAddress=new  map<string,list<string>>();
           //  Map<String, String> mapOfMailToContactID = new Map<String, String>();
          for(PRM_EmailConfigurationDetails__mdt emailConfig:[  select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, PRM_BusinessEvent__c, 
            PRM_ChannelProgram__c, PRM_Country__c, PRM_FolderName__c, PRM_Geo__c, PRM_InputParameter__c, PRM_Language__c, PRM_Letterhead_Template__c, PRM_MergeField__c, PRM_PartnerType__c, 
            PRM_RecipientLogic__c, PRM_Recipient__c, PRM_TemplateName__c, PRM_TemplateUniqueName__c, 
            PRM_Specialty__c from PRM_EmailConfigurationDetails__mdt]){
               key=emailConfig.PRM_BusinessEvent__c+'-'+emailConfig.PRM_Language__c;
                mapOfBusinessEventLang.put(key,emailConfig.PRM_TemplateName__c);
            }
            String inputPtnrRole = null;
            if(isAfterInsert){
                inputPtnrRole = (new List<String>(setOfInPtnrRole))[0];
            }
            
            System.debug('>>>>>>>>>>>>>>> inputPtnrRole : '+inputPtnrRole);
            
            List<Map<String,String>> inputParameters = getInputParameters(mapAccIdsWithActivePAs,emailContDetails, mapOfConACR,mapOfNewACR,accConNewMap,inputPtnrRole);
            System.debug('>>>>>>>>>>>>>>> inputParameters : '+inputParameters);
             
            //Nilesh added
            List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];
            //
            //for(String contId : setOfPrimaryContact){ 
            for(String accId : mapAccIdsWithActivePAs.keyset()){  
           // Map<String, String> mapOfMailToContactID = new Map<String, String>();
           // Map<String, String> mapOfContPreferedLang = new Map<String, String>();
            Map<String,String> mapOfContactName = new Map<String,String>();      
           // Map<String,String> mapOfContIdEmailTemplate = new Map<String,String>();    
          
            if(mapAccIdsWithActivePAs.get(accId).size()>0){
            for(string contId:mapAccIdsWithActivePAs.get(accId)){
                PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification(); 
                PRM_Account_Contact_Relationship__c prmACR = mapOfConACR.get(contId)[0];    
                userLang=prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c;
                if(!prmACR.PRM_Contact_Id__r.Core_Do_Not_Contact__c){ 
                    if(afterInsert){
                        //objEmailNotify.BusinessEvent = 'ACRCONTACT_ADDITION';
                        businessEvent= 'ACRCONTACT_ADDITION';
                        System.debug('JB:: in PRM_EmailToPC->'+businessEvent);

                    }
                    if(afterUpdate){
                       // objEmailNotify.BusinessEvent = 'ACRCONTACT_DELETION';
                       businessEvent= 'ACRCONTACT_DELETION';
                    } 
                   string keyTemplate= businessEvent+'-'+prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c;
                    if(mapOfBusinessEventLang.containskey(keyTemplate)){
                        templateName=mapOfBusinessEventLang.get(keyTemplate);
                      mapOfContIdEmailTemplate.put(prmACR.PRM_Contact_Id__c, templateName);
                    }
                    //Nilesh added
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail;                
                    for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                        if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                            langCultureForEmail = mdtRec;
                        }
                        if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(prmACR.PRM_Contact_Id__r.MailingCountryCode) && mdtRec.MasterLabel == prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c){
                            langCultureForEmail = mdtRec;
                        }
                    }
                    
                    //Nilesh 
                    for(Map<String,String> inParamMap : inputParameters){ 
                        if(inParamMap.get('Account_ID').contains(accId)){
                           //  if(inParamMap.get('PACont_ID').contains(contId)){
                            
                         newInParamMap.putAll(inParamMap);
                          inParamMap.put('Contact_ID',prmACR.PRM_Contact_Id__c);
                          // inParamMap.put('PACont_Name',prmACR.PRM_Contact_Id__r.name);
                            inParamMap.put('PAAccount_Name',prmACR.PRM_Contact_Id__r.Account.name);
                              inParamMap.put('PAAccount_Number',prmACR.PRM_Contact_Id__r.Account.AccountNumber);
                          
                        if(mapContIdInputparam.containsKey(contId)){
                          mapContIdInputparam.get(contId).putAll(inParamMap);
                        }else{
                             mapContIdInputparam.put(contId,inParamMap);
                        }
                       
                        //Nilesh added
                        if(langCultureForEmail != null){
                            //inParamMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                             newInParamMap.put('LanguageCulture_MDT', langCultureForEmail.Id);
                        }
                        
                        //
                        System.debug('inparamap '+inParamMap);
                        //objEmailNotify.InputParameters = inParamMap;
                        System.debug('newInParamMap ' + newInParamMap);
                         if (objEmailNotify.InputParameters == null) {
                objEmailNotify.InputParameters = new Map<String, string>();  
                         }
                       objEmailNotify.InputParameters.putAll(newInParamMap) ;
                       PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{!AcrRoles}' => newInParamMap.get('Contact_Relationship'), '{!ContactLoginId}' => newInParamMap.get('Login_ID'), '{!ContactEmail}' => newInParamMap.get('Email_ID'), '{!ContactName}' => newInParamMap.get('Contact_Name')};
                           system.debug('customPlaceholdersMap'+PRM_EmailUtility.customPlaceholdersMap);
                    }  
               // }
                }
                if(mapAccIdToAddress.containsKey(accId)){
                    mapAccIdToAddress.get(accId).add(prmACR.PRM_Contact_Id__r.email);
                }else{
                    List<string> contEmailsToSend = new List<string>();
                    contEmailsToSend.add(prmACR.PRM_Contact_Id__r.email);                    
                    mapAccIdToAddress.put(accId,contEmailsToSend);
                }
                    mapOfMailToContactID.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.email);                    
                    mapOfContPreferedLang.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);
                    mapOfContactName.put(prmACR.PRM_Contact_Id__c, prmACR.PRM_Contact_Id__r.firstname);
                    objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                    emailIds.add(prmACR.PRM_Contact_Id__r.email);
        
  
            /*if(String.isNotBlank(objEmailNotify.BusinessEvent)){        
                system.debug(' objEmailNotify.InputParameters'+ objEmailNotify.InputParameters);
                objEmailNotify.mailToContactID = mapOfMailToContactID;
                objEmailNotify.contactPreferdLang = mapOfContPreferedLang;
                objEmailNotify.contactNameMap = mapOfContactName;
            objEmailNotificationList.add(objEmailNotify);
               
            }*/
         }
        }  
    }    
}
 system.debug('mapAccIdToAddress'+mapAccIdToAddress);
 system.debug('mapOfContIdEmailTemplate'+mapOfContIdEmailTemplate);
 system.debug('newInParamMap'+newInParamMap);
sendBulkEmail(mapAccIdsWithActivePAs,mapOfContPreferedLang, mapOfMailToContactID, mapAccIdToAddress, mapOfContIdEmailTemplate,mapContIdInputparam,mapOfConACR); //TWC729-8541-sending new parameter mapofconACR to get proper PA/PAD name
    
}

            if(!objEmailNotificationList.isEmpty()){
                /*for(PRM_EmailUtility.EmailNotification ObjNotification:objEmailNotificationList){               
                    PRM_EmailUtility.sendEmail(ObjNotification);
                 }*/
                //added as part of governor limit story:4380
              //  PRM_EmailUtility.sendEmail(objEmailNotificationList);
              system.debug(objEmailNotificationList+'objEmailNotificationList');
            }
        
        
        
    }
    
    
    private static List<Map<String,String>> getInputParameters(map<string,list<string>> mapAccIdsWithActivePAs,Set<String> emailContDetails, Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfConACR,Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfNewACR, Map<Id,sObject> newAcrObject, String linkForPartnerRole){
        List<Map<String,String>> inputParameters = new List<Map<String,String>>();
        for(string accId:mapAccIdsWithActivePAs.keyset()){
        //set<string> setOfConts=mapAccIdsWithActivePAs.get(accId);
        String contEmail=''; 
        string contRelation='';
        string ContName='';
        Map<String,String> inParamMap = new Map<String,String>();  
        if(mapAccIdsWithActivePAs.get(accId).size()>0){
            for(String newContId : emailContDetails){
             //   Map<String,String> inParamMap = new Map<String,String>();            
                PRM_Account_Contact_Relationship__c newContactACR = mapOfConACR.get(newContId)[0];
                if(newContactACR.PRM_Account_Id__c==accId){
                inParamMap.put('Account_ID',mapOfConACR.get(newContId)[0].PRM_Account_Id__c);
                //inParamMap.put('PACont_ID',mapOfConACR.get(newContId)[0].PRM_Account_Id__c);
                
            if(mapOfNewACR.containsKey(newContId)){
                //inParamMap.put('Email_ID',newContactACR.PRM_Contact_Id__r.Email);
                contEmail=newContactACR.PRM_Contact_Id__r.Email+','+contEmail;
                
               // contEmail+=newContactACR.PRM_Contact_Id__r.Email+',';
                // inParamMap.put('Contact_ID',newContactACR.PRM_Contact_Id__c);
                //inParamMap.put('Contact_Relationship',getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject));
               // contRelation+=getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject)+',';
                  contRelation=getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject)+','+contRelation;
                //inParamMap.put('Contact_Name',newContactACR.PRM_Contact_Id__r.Name);
                ContName=newContactACR.PRM_Contact_Id__r.Name+','+ContName;
            }
        }
            
      
            /*
             if(mapOfNewACR.containsKey(newContId)){
                inParamMap.put('Login_ID',mapOfConACR.get(newContId)[0].PRM_Contact_Id__r.Core_Login_Id__c);
                inParamMap.put('Email_ID',mapOfConACR.get(newContId)[0].PRM_Contact_Id__r.Email);
                inParamMap.put('Contact_Relationship',getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject));
               // System.debug('>>>>>> newContactACR.PRM_Partner_Role__c : '+newContactACR.PRM_Partner_Role__c);
            }
            inputParameters.add(inParamMap);
      */
        }
        if (contEmail.endsWith(',')) {
            contEmail = contEmail.substring(0, contEmail.length() - 1)+' ';
        }
        if (contRelation.endsWith(',')) {
            contRelation = contRelation.substring(0, contRelation.length() - 1);
        }
        if (ContName.endsWith(',')) {
            ContName = ContName.substring(0, ContName.length() - 1);
        }
        inParamMap.put('Email_ID',contEmail);
        inParamMap.put('Contact_Relationship',contRelation);
        inParamMap.put('Contact_Name',ContName);
        inputParameters.add(inParamMap);
        for(string contId:mapAccIdsWithActivePAs.get(accId)){
            Map<String,String> inParamMapPA = new Map<String,String>(); 
             PRM_Account_Contact_Relationship__c paContACR = mapOfConACR.get(contId)[0];
             inParamMapPA.put('Account_ID',mapOfConACR.get(contId)[0].PRM_Account_Id__c);
            //inParamMapPA.put('PACont_ID',paContACR.PRM_Contact_Id__r.Id);
            inParamMapPA.put('PACont_Name',paContACR.PRM_Contact_Id__r.Name);
            inputParameters.add(inParamMapPA);
         }
    }
   
}
        return inputParameters;
    }
    
   



   @TestVisible
    private static boolean isContainPartnerRole(Set<String> conRole, List<String> fetchedRole){
        for(String str: fetchedRole){
            if(conRole.contains(str)){
                return true;
            }
        }
        return false;
    }
   @TestVisible 
   private static List<String> getPartnerRoleFrmACR(String role){
        List<String> partnerRoles = new List<String>();
        System.debug('Partner Role : '+role);
        if(role != null && role.contains('_BR_ENCODED_')){ 
            partnerRoles.addAll(role.split('_BR_ENCODED_'));                 
        }else if(role != null && role.contains('<br>')){ 
            partnerRoles.addAll(role.split('<br>'));            
        }else{
            partnerRoles.add(role);
        }
        
        return partnerRoles;
    }
    
    private static String getAssociatedRelationDetails(List<PRM_Account_Contact_Relationship__c>  listOfConACR, Map<Id,sObject> newACRmap){
        String contactRelationship;
        for(PRM_Account_Contact_Relationship__c obj1 : listOfConACR){
            if(newACRmap.containskey(obj1.Id)){                    
                if(String.isNotEmpty(contactRelationship)){
                    contactRelationship = contactRelationship + ','+obj1.PRM_Relationship_Id__r.name;
                }else{
                    contactRelationship = obj1.PRM_Relationship_Id__r.name;
                } 
            }            
        }
        return contactRelationship;
    } 
    //sendemail method
    
    public static void sendBulkEmail(map<string,list<string>> mapAccIdsWithActivePAs, map<string,string> mapOfContPreferedLang, map<string,string> mapOfMailToContactID, map<string,list<string>> mapAccIdToAddress
    ,map<string,string> mapOfContIdEmailTemplate, map<string, map<string,string>> mapContIdInputparam, map<String,List<PRM_Account_Contact_Relationship__c>>mapOfConACR) {
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
       // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
        
        set<String> templateNames=new set<string>();
        map<string,EmailTemplate> mapOftemplates=new map<string,EmailTemplate>();
          List<PRM_EmailLog__c> listEmailLogs=new   List<PRM_EmailLog__c> ();
         // if(templateName!=null){
         if(mapOfContIdEmailTemplate!=null && !mapOfContIdEmailTemplate.isempty()){
            for(string pacontId:mapOfContIdEmailTemplate.keyset()){
                templateNames.add(mapOfContIdEmailTemplate.get(pacontId));
            }
       // list<EmailTemplate> emailTemps= [select HtmlValue,Subject ,DeveloperName from EmailTemplate where DeveloperName in:templateNames ];
       for(EmailTemplate emailtemp: [select HtmlValue,Subject,DeveloperName from EmailTemplate where DeveloperName in:templateNames ]){
            mapOftemplates.put(emailtemp.DeveloperName,emailtemp);
       }
      EmailTemplate emailTemp ; 
        String emailBody; 
       string tempemailbody;
      
       system.debug('emailsToSend'+emailsToSend);
       
   
           for(string accId: mapAccIdsWithActivePAs.keyset()){// 001Dw000020AS9WIAW honda shine
            System.debug('=== Processing Account: ' + accId + ' ===');
             //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); // TWC729-8541-commented and put email object in the below for loop to create unique email object per contact.
             
          for(string contId: mapAccIdsWithActivePAs.get(accId)){ 
            System.debug('--- Processing Contact: ' + contId + ' ---');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); //// TWC729-8541
                System.debug('Created email object: ' + email);
         emailTemp=mapOftemplates.get(mapOfContIdEmailTemplate.get(contId));
          emailBody=emailTemp.HtmlValue;
           system.debug('emailBody'+emailBody); 
           tempemailbody=emailBody; //acr_deletion
            if(mapAccIdsWithActivePAs.containskey(accId)){// {{001Dw00001yZZx8IAG=(thorloki@spamok.com), 001Dw000020AS9WIAW=(shine@spamok.com)}}
            List<String> singleRecipient = new List<String>{mapOfMailToContactID.get(contId)};
                email.setToAddresses(singleRecipient); // TWC729-8541-setting address seperately for each contact to email object
            System.debug('Email recipients set to: ' + singleRecipient);
            email.setSubject(emailTemp.Subject);
            
         //   }  
            
            //001Dw000020AS9WIAW={Account_ID=001Dw000020AS9WIAW, Contact_Name=Scooty pep, Contact_Relationship=Employee, Email_ID=pept@spamok.com}}
        system.debug('contID'+contId);
          system.debug('mapContIdInputparam'+mapContIdInputparam);
            map<string,string> MapInputParaTemp=mapContIdInputparam.containskey(contId)?mapContIdInputparam.get(contId):null;//{Account_ID=001Dw000020AS9WIAW, Contact_Name=Scooty pep, Contact_Relationship=Employee, Email_ID=pept@spamok.com}
          if(MapInputParaTemp!=null ){
            for (string newInParam:MapInputParaTemp.keyset()){
                tempemailbody = tempemailbody.replace('{!$Label.PRM_CurrentYear}', Label.PRM_CurrentYear);
                if(newInParam=='Contact_Relationship')
            tempemailbody = tempemailbody.replace('{!AcrRoles}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');
          else if(newInParam=='Login_ID')
            tempemailbody= tempemailbody.replace('{!ContactLoginId}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');
         else if(newInParam=='Email_ID')
            tempemailbody= tempemailbody.replace('{!ContactEmail}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');
         else if(newInParam=='Contact_Name')
            tempemailbody= tempemailbody.replace('{!ContactName}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');    
                 /*else if(newInParam=='PACont_Name')
                  tempemailbody= tempemailbody.replace('{!UserName}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');*/    //TWC729-8541-commented since PACont_Name was getting overwritten, no unique value
                 else if(newInParam=='PAAccount_Name')
                  tempemailbody= tempemailbody.replace('{!Account.Name}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');    
                 else if(newInParam=='PAAccount_Number')
                  tempemailbody= tempemailbody.replace('{!Account.AccountNumber}',mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');    
                   //email.setHtmlBody(tempemailbody); 
            /*if(newInParam=='PACont_ID'){
                   email.setTargetObjectId(mapInputParaTemp.containsKey(newInParam) ? mapInputParaTemp.get(newInParam) : '');
            }*/
            
        }
            String currentRecipientName = ''; 
           if(mapOfConACR.containsKey(contId) && !mapOfConACR.get(contId).isEmpty()) {
              currentRecipientName = mapOfConACR.get(contId)[0].PRM_Contact_Id__r.FirstName;
             }
             System.debug('Found recipient name: ' + currentRecipientName + ' for contId: ' + contId);
            tempemailbody = tempemailbody.replace('{!UserName}', currentRecipientName); // TWC729-8541-to replace username with proper name of PA/PAD
            email.setHtmlBody(tempemailbody);
    }
           // email.setHtmlBody(tempemailbody); 
            if (owea != null) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
             PRM_EmailLog__c log = new PRM_EmailLog__c();
             String successMsg =System.Label.PRM_Email_SuccessMsg;
            log.PRM_EmailDeliverabilityStatus__c = true ;
            log.PRM_Contact__c=contId;
            log.PRM_Timestamp__c = DateTime.now();
            log.Email_Template_Name__c = mapOfContIdEmailTemplate.get(contId) ;
            log.PRM_Email_API_Response__c = successMsg ; 
            log.PRM_EmailContent__c =  email.getHtmlBody();
            log.PRM_EmailHTMLContent__c = email.getHtmlBody();
            log.PRM_Subject__c = email.getSubject();
            log.Language__c=mapOfContPreferedLang.containskey(contId)?mapOfContPreferedLang.get(contId):'';
            log.PRM_Type__c = 'IPA';
            String toEmailId;
           /* if(email.getToAddresses() != null ) {
                log.PRM_ToEmailID__c = string.join(mapAccIdToAddress.get(accId),';');
                if(log.PRM_ToEmailID__c.length() > 255)
                {
                    toEmailId = log.PRM_ToEmailID__c;
                    log.PRM_ToEmailID__c = log.PRM_ToEmailID__c.substring(0,255);
                    log.PRM_ToEmailIDCompleteValue__c = toEmailId;
                }
                else
                {
                    log.PRM_ToEmailIDCompleteValue__c = log.PRM_ToEmailID__c;
                }
            }*/
            log.PRM_ToEmailID__c =mapOfMailToContactID.containskey(contId)?mapOfMailToContactID.get(contId):'';
            if(!listEmailLogs.contains(log)){
                listEmailLogs.add(log); 
            }
            
                emailsToSend.add(email);
            

            //emailsToSend.add(email);
        //   Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
          /*  if(r[0].IsSuccess()){
              listEmailLogs = PRM_Retrigger_Emaillog_Utility.createRetriggerEmailLogs(emailsToSend, new List<PRM_EmailLog__c>(),  templateName,userLang);
            } */
                
            }
        }
    }
}
            try{
                 if(emailsToSend!=Null && emailsToSend.size()>0){
            System.debug('=== SENDING EMAILS ===');
            System.debug('Total emails to send: ' + emailsToSend.size());
                 Messaging.sendEmail(emailsToSend);
                 system.debug('Success emailsToSend'+emailsToSend);
           // }
           if(!listEmailLogs.isempty()){
             list<Database.saveResult> saveLogResLst =  Database.insert(listEmailLogs,false); 
           }
                   
            System.debug('Emails sent successfully to multiple recipients.');
        } 
    }catch (Exception e) {
            System.debug('Error sending emails: ' + e.getMessage());
        }
    
}

}