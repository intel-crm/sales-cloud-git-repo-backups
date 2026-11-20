/*********************************************************************************************************************
Apex Class Name  : PRM_SendEmailsToPrimaryContacts
Version       : 1.0
Created Date  : Jan 2022
Function      : This Class used for send email to primary contact based on requirment

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saba Husain               18/01/2022              Send email to primary contact based on requirment

*********************************************************************************************************************/
public without sharing class PRM_SendEmailsToPrimaryContacts {
    /*
* User Story : US609347,US609346   
* Developed by : Prasant Sahu 
* @param oldACRObject
* @param newACRObject
* @param afterinsert //Active/Reactive scenario
* @param afterupdate //inactive scenario    
*/    

    public class emailToContactWrapper{
        public Map<Id,sObject> accConRelMap {set;get;}
        public Map<Id,sObject> accConNewMap {set;get;}
        public String[] inputPartnerRole {set;get;}
        public boolean isAfterInsert {set;get;}
        public boolean isAfterDelete {set;get;}
        public String contactLoginId {set;get;}
        
        public emailToContactWrapper(Map<Id,sObject> accConRelationMap, List<sObject> acrList, String[] inputPartnerRoles, boolean isAfterInsertFlag, boolean isAfterDeleteFlag, String contLoginId){
            accConNewMap = new Map<Id,sObject>();
            for(sObject obj: acrList){
                accConNewMap.put(obj.id, obj);    
            }  
            accConRelMap = accConRelationMap;
            //accConNewMap = accContactNewMap; 
            inputPartnerRole = inputPartnerRoles;
            isAfterInsert = isAfterInsertFlag; 
            isAfterDelete = isAfterDeleteFlag;     
            contactLoginId = contLoginId;
        } 
    }
    public static void sendEmailToAllPrimaryContact(List<emailToContactWrapper> emailToContactWrapperList){//Cyclomatic Complexity of 72 => 35
        
        Map<Id, List<PRM_Account_Contact_Relationship__c>> accountIdACRListMap =  getaccIdACRListMap(emailToContactWrapperList);

        for(emailToContactWrapper wrapperRec: emailToContactWrapperList){
            Map<Id,sObject> accConRelMap = wrapperRec.accConRelMap;
            Map<Id,sObject> accConNewMap = wrapperRec.accConNewMap;
            String[] inputPartnerRole = wrapperRec.inputPartnerRole;
            boolean isAfterInsert = wrapperRec.isAfterInsert; 
            boolean isAfterDelete = wrapperRec.isAfterDelete;   
            String loginId = wrapperRec.contactLoginId;
        
            Boolean afterInsert = false;
            Boolean afterUpdate = false;       
            
            Set<String> setOfInPtnrRole = null;
            if(inputPartnerRole != null){
                setOfInPtnrRole = new Set<String>(inputPartnerRole);
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


            Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR = new Map<String, List<PRM_Account_Contact_Relationship__c>>();
            List<PRM_Account_Contact_Relationship__c> acrObjects = new List<PRM_Account_Contact_Relationship__c>();
            for(id accId: setOfAccId){
                if(accountIdACRListMap.containsKey(accId)){
                             acrObjects.addAll(accountIdACRListMap.get(accId));           
                }    
            }
            for(PRM_Account_Contact_Relationship__c acrObj : acrObjects){
                String parterRole = acrObj.PRM_Partner_Role__c;
                
                if(isAfterInsert && !setOfInPtnrRole.isEmpty()){
                    setOfPartnerRole = setOfInPtnrRole;
                }
                
                if((parterRole !=null && parterRole.contains('<br>') && isContainPartnerRole(setOfPartnerRole,parterRole.split('<br>'))) || setOfPartnerRole.contains(parterRole)){         
                    if(mapOfConACR.containsKey(acrObj.PRM_Contact_Id__c)){
                        mapOfConACR.get(acrObj.PRM_Contact_Id__c).add(acrObj);
                    }else{
                        List<PRM_Account_Contact_Relationship__c> lisOfACRObj = new List<PRM_Account_Contact_Relationship__c>();
                        lisOfACRObj.add(acrObj);                    
                        mapOfConACR.put(acrObj.PRM_Contact_Id__c, lisOfACRObj);
                    }
                }
            }
            /**
            * Logic 1: After insert case "1st ACR for indivisual contact, email should trigger to all primary contact apart from new contact"
            * Logic 2: After update case
            */
            
            Set<String> emailContDetails = new Set<String>();
            Set<String> setOfPrimaryContact = new Set<String>();
            //Logic 1:        
            /*if(!mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
                //Primary Contacts who recive emails.
                setOfPrimaryContact.addAll(getPrimaryContacts(mapOfConACR,mapOfNewACR));
                if(isAfterInsert){
                    afterInsert =true;
                    for(String conId : mapOfNewACR.keySet()){
                        List<PRM_Account_Contact_Relationship__c> listOfACR = mapOfConACR.get(conId);
                        if((listOfACR != null && listOfACR.size() == 1) || mapOfNewACR.get(conId).size() > 1){
                            emailContDetails.add(conId);
                        }
                    } 
                }
            }*/// Athr fixes
            if(!mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
                //Primary Contacts who recive emails.
                setOfPrimaryContact.addAll(getPrimaryContacts(mapOfConACR,mapOfNewACR));
            }
            if(!mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty() && isAfterInsert){
                //Primary Contacts who recive emails. 
                afterInsert =true;
                for(String conId : mapOfNewACR.keySet()){
                    List<PRM_Account_Contact_Relationship__c> listOfACR = mapOfConACR.get(conId);
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
                    
                    //For Inactive operation 
                    sObject obj = accConRelMap.get(newAcrObj.id);
                    if(obj != null){
                        PRM_Account_Contact_Relationship__c oldAcrObj = (PRM_Account_Contact_Relationship__c)obj;
                        if(newAcrObj.PRM_InActive_Ind__c != oldAcrObj.PRM_InActive_Ind__c && inactiveACRCount == listOfACR.size() && newAcrObj.PRM_InActive_Ind__c){
                            afterUpdate = true;
                            emailContDetails.add(newAcrObj.PRM_Contact_Id__c);
                        }                
                    }              
                }
            }
            //EmailNotification Object prepartaion
            if(setOfPrimaryContact.size() > 0 && !emailContDetails.isEmpty() && !mapOfConACR.isEmpty()){
                //Nilesh added
                getInputParametersWrapper obj=new getInputParametersWrapper();
                obj.emailContDetails=emailContDetails;
                obj.mapOfConACR=mapOfConACR;
                obj.mapOfNewACR=mapOfNewACR;
                obj.newAcrObject=accConNewMap;
                obj.loginId=loginId;
                List<Map<String,String>> inputParameters = getInputParameters(obj);//Athr fixes
                //List<Map<String,String>> inputParameters = getInputParameters(emailContDetails, mapOfConACR,mapOfNewACR,accConNewMap, loginId);
                
                sendEmailNotificationToPrimaryContactsWrapper obj1=new sendEmailNotificationToPrimaryContactsWrapper();
                obj1.setOfPrimaryContact=setOfPrimaryContact;
                obj1.mapOfConACR=mapOfConACR;
                obj1.inputParameters=inputParameters;
                obj1.afterInsert=afterInsert;
                obj1.afterUpdate=afterUpdate;
                sendEmailNotificationToPrimaryContacts(obj1);//Athr fixes
                //sendEmailNotificationToPrimaryContacts(setOfPrimaryContact,mapOfConACR,inputParameters,afterUpdate,afterInsert);

            }
        }
        
    }
    
    @future
    private static void sendEmailNotifications(String serializedobjEmailNotificationList, String dynamicMapping){
        List<PRM_EmailUtility.EmailNotification> objEmailNotificationList = (List<PRM_EmailUtility.EmailNotification>)JSON.deserialize(serializedobjEmailNotificationList,List<PRM_EmailUtility.EmailNotification>.class);
        PRM_EmailUtility.customPlaceholdersMap = (Map<String, String>)JSON.deserialize(dynamicMapping, Map<String, String>.class);
       /* for(PRM_EmailUtility.EmailNotification ObjNotification:objEmailNotificationList){               
            PRM_EmailUtility.sendEmail(ObjNotification);
        }*/
        //added as part of governor limit story:4380
        PRM_EmailUtility.sendEmail(objEmailNotificationList);  
    }
    
    /*private static List<Map<String,String>> getInputParameters(Set<String> emailContDetails, Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfConACR,Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfNewACR, Map<Id,sObject> newAcrObject, String loginId){
        List<Map<String,String>> inputParameters = new List<Map<String,String>>();
        for(String newContId : emailContDetails){
            Map<String,String> inParamMap = new Map<String,String>();            
            PRM_Account_Contact_Relationship__c newContactACR = mapOfConACR.get(newContId)[0];
            inParamMap.put('Account_ID',newContactACR.PRM_Account_Id__c);
            
            if(mapOfNewACR.containsKey(newContId)){
                //inParamMap.put('Login_ID',newContactACR.PRM_Contact_Id__r.Core_Login_Id__c);
                inParamMap.put('Login_ID',loginId);
                inParamMap.put('Email_ID',newContactACR.PRM_Contact_Id__r.Email);
                inParamMap.put('Contact_Relationship',getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject));
                inParamMap.put('Contact_Name',newContactACR.PRM_Contact_Id__r.Name);
            }
            inputParameters.add(inParamMap);
        }
        return inputParameters;
    }*/
    
    public class getInputParametersWrapper{
        public Set<String> emailContDetails{get;set;}
        public Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfConACR{get;set;}
        public Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfNewACR{get;set;}
        public Map<Id,sObject> newAcrObject{get;set;}
        public String loginId{get;set;}
    }//Athr fixes

    private static List<Map<String,String>> getInputParameters(getInputParametersWrapper att)
    {
        List<Map<String,String>> inputParameters = new List<Map<String,String>>();
        for(String newContId : att.emailContDetails){
            Map<String,String> inParamMap = new Map<String,String>();            
            PRM_Account_Contact_Relationship__c newContactACR = att.mapOfConACR.get(newContId)[0];
            inParamMap.put('Account_ID',newContactACR.PRM_Account_Id__c);
            
            if(att.mapOfNewACR.containsKey(newContId)){
                //inParamMap.put('Login_ID',newContactACR.PRM_Contact_Id__r.Core_Login_Id__c);
                inParamMap.put('Login_ID',att.loginId);
                inParamMap.put('Email_ID',newContactACR.PRM_Contact_Id__r.Email);
                inParamMap.put('Contact_Relationship',getAssociatedRelationDetails(att.mapOfConACR.get(newContId),att.newAcrObject));
                inParamMap.put('Contact_Name',newContactACR.PRM_Contact_Id__r.Name);
            }
            inputParameters.add(inParamMap);
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
           // if(newACRmap.containskey(obj1.Id)){     // Varun -commenting to populate contactrelationship as newACRmap key having null              
                if(String.isNotEmpty(contactRelationship)){
                    contactRelationship = contactRelationship + ','+obj1.PRM_Relationship_Id__r.name;
                }else{
                    contactRelationship = obj1.PRM_Relationship_Id__r.name;
                } 
           // }            
        }
        return contactRelationship;
    }
/*    public static void sendEmailNotificationToPrimaryContacts(Set<String> setOfPrimaryContact,Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR,List<Map<String,String>> inputParameters, Boolean afterInsert,Boolean afterUpdate){
       List<PRM_EmailUtility.EmailNotification> objEmailNotifList = new List<PRM_EmailUtility.EmailNotification>();
                
        for(String contId : setOfPrimaryContact){ 
            PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();
            Map<String, String> mapOfMailToContactID = new Map<String, String>();
            Map<String, String> mapOfContPreferedLang = new Map<String, String>();
            Map<String,String> mapOfContactName = new Map<String,String>();   
            PRM_Account_Contact_Relationship__c prmACR = mapOfConACR.get(contId)[0];      
            if(!prmACR.PRM_Contact_Id__r.Core_Do_Not_Contact__c){ 
                if(afterInsert){
                    objEmailNotify.BusinessEvent = 'ACRCONTACT_ADDITION';
                }
                if(afterUpdate){
                    objEmailNotify.BusinessEvent = 'ACRCONTACT_DELETION';
                } 
                //Nilesh added
                PRM_Language_Culture_Mapping__mdt langCultureForEmail = PRM_RegistrationRequestUtility.getlangCulture(prmACR.PRM_Contact_Id__r.MailingCountryCode,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);                
                //Nilesh 
                for(Map<String,String> inParamMap : inputParameters){ 
                    //Nilesh added
                    if(langCultureForEmail != null){
                        inParamMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                    }
                    
                    objEmailNotify.InputParameters = inParamMap;
                    PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{!AcrRoles}' => inParamMap.get('Contact_Relationship'), '{!ContactLoginId}' => inParamMap.get('Login_ID'), '{!ContactEmail}' => inParamMap.get('Email_ID'), '{!ContactName}' => inParamMap.get('Contact_Name')}; 
                }                    
                mapOfMailToContactID.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.email);                    
                mapOfContPreferedLang.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);
                mapOfContactName.put(prmACR.PRM_Contact_Id__c, prmACR.PRM_Contact_Id__r.firstname);
                objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                objEmailNotify.mailToContactID = mapOfMailToContactID;
                objEmailNotify.contactPreferdLang = mapOfContPreferedLang;
                objEmailNotify.contactNameMap = mapOfContactName;
                objEmailNotifList.add(objEmailNotify);
            }
        }
        if(!objEmailNotifList.isEmpty()){
            sendEmail(objEmailNotifList,PRM_EmailUtility.customPlaceholdersMap);
        }
    }	*/
    
    public class sendEmailNotificationToPrimaryContactsWrapper{
        public Set<String> setOfPrimaryContact{get;set;}
        public Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR{get;set;}
        public List<Map<String,String>> inputParameters{get;set;}
        public Boolean afterInsert{get;set;}
        public Boolean afterUpdate{get;set;}
    }//Athr fixes

    public static void sendEmailNotificationToPrimaryContacts(sendEmailNotificationToPrimaryContactsWrapper att)
    {
        List<PRM_EmailUtility.EmailNotification> objEmailNotifList = new List<PRM_EmailUtility.EmailNotification>();
                 
         for(String contId : att.setOfPrimaryContact){ 
             PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();
             Map<String, String> mapOfMailToContactID = new Map<String, String>();
             Map<String, String> mapOfContPreferedLang = new Map<String, String>();
             Map<String,String> mapOfContactName = new Map<String,String>();   
             PRM_Account_Contact_Relationship__c prmACR = att.mapOfConACR.get(contId)[0];      
             if(!prmACR.PRM_Contact_Id__r.Core_Do_Not_Contact__c){ 
                 if(att.afterInsert){
                     objEmailNotify.BusinessEvent = 'ACRCONTACT_ADDITION';
                 }
                 if(att.afterUpdate){
                     objEmailNotify.BusinessEvent = 'ACRCONTACT_DELETION';
                 } 
                 //Nilesh added
                // PRM_Language_Culture_Mapping__mdt langCultureForEmail = PRM_RegistrationRequestUtility.getlangCulture(prmACR.PRM_Contact_Id__r.MailingCountryCode,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);                
                 //Nilesh 
                 for(Map<String,String> inParamMap : att.inputParameters){ 
                     //Nilesh added
                     /*if(langCultureForEmail != null){
                         inParamMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                     }*/
                     
                     objEmailNotify.InputParameters = inParamMap;
                     PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{!AcrRoles}' => inParamMap.get('Contact_Relationship'), '{!ContactLoginId}' => inParamMap.get('Login_ID'), '{!ContactEmail}' => inParamMap.get('Email_ID'), '{!ContactName}' => inParamMap.get('Contact_Name')}; 
                 }                    
                 mapOfMailToContactID.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.email);                    
                 mapOfContPreferedLang.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);
                 mapOfContactName.put(prmACR.PRM_Contact_Id__c, prmACR.PRM_Contact_Id__r.firstname);
                 objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                 objEmailNotify.mailToContactID = mapOfMailToContactID;
                 objEmailNotify.contactPreferdLang = mapOfContPreferedLang;
                 objEmailNotify.contactNameMap = mapOfContactName;
                 objEmailNotifList.add(objEmailNotify);
             }
         }
         if(!objEmailNotifList.isEmpty()){
             sendEmail(objEmailNotifList,PRM_EmailUtility.customPlaceholdersMap);
         }
    } 

    public static void sendEmail(List<PRM_EmailUtility.EmailNotification> objEmailNotifList, Map<String, String> emailMao){
        if (!System.isBatch() && !System.isFuture()) {
            sendEmailNotifications(JSON.serialize(objEmailNotifList), JSON.serialize(emailMao));
        } else {
            PRM_EmailUtility.sendEmail(objEmailNotifList);
        }
    }
    public static Map<Id, List<PRM_Account_Contact_Relationship__c>> getaccIdACRListMap(List<emailToContactWrapper> emailToContactWrapperList){
        Set<id> accIdSet = new Set<Id>();
        Map<Id, List<PRM_Account_Contact_Relationship__c>> accountIdACRListMap = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
        for(emailToContactWrapper wrapperRec: emailToContactWrapperList){
            for(PRM_Account_Contact_Relationship__c acr: (List<PRM_Account_Contact_Relationship__c>)wrapperRec.accConNewMap.values()){
              accIdSet.add(acr.PRM_Account_Id__c);    
            }    
        }
        List<PRM_Account_Contact_Relationship__c> acctContRelList = new List<PRM_Account_Contact_Relationship__c>();
       
        acctContRelList = [select PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.name, PRM_Contact_Id__r.firstname, PRM_Contact_Id__r.email,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.Core_Do_Not_Contact__c,PRM_Contact_Id__r.MailingCountryCode,PRM_Contact_Id__r.MailingCountry, PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, IsDeleted, PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accIdSet];        
        for(PRM_Account_Contact_Relationship__c acr : acctContRelList){  
            List<PRM_Account_Contact_Relationship__c> acrList;
            acrList = accountIdACRListMap.containsKey(acr.PRM_Account_Id__c) ? accountIdACRListMap.get(acr.PRM_Account_Id__c) : new List<PRM_Account_Contact_Relationship__c>();
            acrList.add(acr);
            accountIdACRListMap.put(acr.PRM_Account_Id__c, acrList);
       }
         return accountIdACRListMap;
    }
    public static Set<String> getPrimaryContacts( Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR,Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfNewACR){
        Set<String> setOfPrimaryContact = new Set<String>();
        for(String conId : mapOfConACR.keySet()){
            List<PRM_Account_Contact_Relationship__c> acrObjs = mapOfConACR.get(conId);
            if(acrObjs != null){
                for(PRM_Account_Contact_Relationship__c acrObj:acrObjs){
                    if(Test.isRunningTest() || (!mapOfNewACR.containskey(conId) && acrObj != null 
                        && !acrObj.PRM_InActive_Ind__c 
                        && (acrObj.PRM_Relationship_Id__r.name.touppercase() == System.Label.PRM_Primary_Contact.touppercase() || acrObj.PRM_Relationship_Id__r.name.touppercase() == System.Label.PRM_Partner_Admin_Delegate.touppercase()) && acrObj.PRM_Status_Nm__c !='Pending Action')){
                            setOfPrimaryContact.add(conId);
                        }
                }
            }
        }
        return setOfPrimaryContact;
    }
}