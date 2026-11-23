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
public without sharing class PRM_EmailToPrimaryContact {
    /*
* User Story : US609347,US609346   
* Developed by : Prasant Sahu 
* @param oldACRObject
* @param newACRObject
* @param afterinsert //Active/Reactive scenario
* @param afterupdate //inactive scenario    
*/
    
    public static void sendEmailToAllPrimaryContact(Map<Id,sObject> accConRelMap, Map<Id,sObject> accConNewMap, String[] inputPartnerRole, boolean isAfterInsert, boolean isAfterDelete){
        System.debug('accConRelMap >>>>> '+accConRelMap);
        System.debug('accConNewMap >>>>> '+accConNewMap);
        System.debug('partnerRole >>>>>> '+inputPartnerRole);
        
        Boolean afterInsert = false;
        Boolean afterUpdate = false;       
        
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
        System.debug('accConNewMap >>>'+accConNewMap.size());
        if(accConNewMap != null){
            for(sObject acrSobject : accConNewMap.values()){ 
                PRM_Account_Contact_Relationship__c acr = (PRM_Account_Contact_Relationship__c) acrSobject;
                setOfAccId.add(acr.PRM_Account_Id__c);
                String role = acr.PRM_Partner_Role__c;
                System.debug('Partner Role : '+role);
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
        
        // ACRs from  PRM_Account_Contact_Relationship__c
        Map<String, List<String>> accRelatedContacts = new Map<String, List<String>>();
        Map<String, List<PRM_Account_Contact_Relationship__c>> mapOfConACR = new Map<String, List<PRM_Account_Contact_Relationship__c>>();
        List<PRM_Account_Contact_Relationship__c> acrObjects= [select PRM_Account_Id__c, PRM_Account_Id__r.name, PRM_Contact_Id__c, PRM_Partner_Role__c, PRM_Contact_Id__r.name, PRM_Contact_Id__r.email, PRM_Contact_Id__r.Core_Login_Id__c,PRM_Contact_Id__r.Core_Preferred_Language__c,PRM_Contact_Id__r.Core_Do_Not_Contact__c, PRM_Relationship_Id__r.name, PRM_InActive_Ind__c, IsDeleted, PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :setOfAccId];
        for(PRM_Account_Contact_Relationship__c acrObj : acrObjects){
            String parterRole = acrObj.PRM_Partner_Role__c;
            System.debug('Set Of partner role 1>>>> '+setOfPartnerRole);
            System.debug('Partner Role Contain 1>>> '+parterRole);
            
            if(isAfterInsert && !setOfInPtnrRole.isEmpty()){
                setOfPartnerRole = setOfInPtnrRole;
            }
            
            System.debug('Set Of partner role 2>>>> '+setOfPartnerRole);
            
            if(parterRole !=null && parterRole.contains('<br>') && isContainPartnerRole(setOfPartnerRole,parterRole.split('<br>'))){
                System.debug('Entered >>>> '+parterRole);                  
                
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
        
        
        
        //Primary Contacts who recive emails.
        Set<String> setOfPrimaryContact = new Set<String>();
        if(!mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
            for(String conId : mapOfConACR.keySet()){
                List<PRM_Account_Contact_Relationship__c> acrObjs = mapOfConACR.get(conId);
                System.debug('ACR object : '+acrObjs);
                if(acrObjs != null){
                    for(PRM_Account_Contact_Relationship__c acrObj:acrObjs){
                        if(!mapOfNewACR.containskey(conId) && acrObj != null 
                           && !acrObj.PRM_InActive_Ind__c 
                           && acrObj.PRM_Relationship_Id__r.name.touppercase() == System.Label.PRM_PRIMARY_CONTACT_RELATION.touppercase() && acrObj.PRM_Status_Nm__c !='Pending Action'){
                               setOfPrimaryContact.add(conId);
                           }
                    }
                }
            }
        }
        System.debug('Primary Contacts who recive emails : '+setOfPrimaryContact);
        
        
        
        
        /**
* Logic 1: After insert case "1st ACR for indivisual contact, email should trigger to all primary contact apart from new contact"
* Logic 2: After update case
*/
        System.debug('isAfterInsert >>>'+isAfterInsert);
        System.debug('isAfterDelete >>>'+isAfterDelete);
        
        Set<String> emailContDetails = new Set<String>();
        //Logic 1:        
        if(isAfterInsert && !mapOfNewACR.isEmpty() && !mapOfConACR.isEmpty()){
            System.debug('mapOfNewACR L1>>>>'+mapOfNewACR);
            System.debug('mapOfConACR L1>>>>'+mapOfConACR);
            afterInsert =true;
            for(String conId : mapOfNewACR.keySet()){
                System.debug('mapOfConACR conId>>>>'+mapOfConACR);
                List<PRM_Account_Contact_Relationship__c> listOfACR = mapOfConACR.get(conId);
                System.debug('listOfACR >>>>'+listOfACR);
                System.debug('listOfACR >>>>'+listOfACR.size());
                if((listOfACR != null && listOfACR.size() == 1) || mapOfNewACR.get(conId).size() > 1){
                    System.debug('Exculded ContactId from Add Notification>> '+conId);
                    emailContDetails.add(conId);
                }
            }            
        }
        
        //Logic 2:        
        if(isAfterDelete && !mapOfConACR.isEmpty()){
            System.debug('accConRelMap >>>>> '+accConRelMap.size());
            System.debug('accConNewMap >>>>> '+accConNewMap.size());            
            for(sObject acrObj : accConNewMap.values()){
                PRM_Account_Contact_Relationship__c newAcrObj = (PRM_Account_Contact_Relationship__c)acrObj;
                System.debug('newAcrObj >>>> '+newAcrObj);
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
                    System.debug('obj >>>> '+obj);
                    if(newAcrObj.PRM_InActive_Ind__c != oldAcrObj.PRM_InActive_Ind__c){
                        System.debug('newAcrObj.PRM_InActive_Ind__c >>>> '+newAcrObj.PRM_InActive_Ind__c);
                        System.debug('oldAcrObj.PRM_InActive_Ind__c >>>> '+oldAcrObj.PRM_InActive_Ind__c);
                        System.debug('listOfACR.size() >>>> '+listOfACR.size());
                        if(inactiveACRCount == listOfACR.size() && newAcrObj.PRM_InActive_Ind__c){                            
                            System.debug('Exculded ContactId from Remove Notification>> '+newAcrObj.PRM_Contact_Id__c);
                            afterUpdate = true;
                            emailContDetails.add(newAcrObj.PRM_Contact_Id__c);
                        }
                        
                        /* if(inactiveACRCount == (listOfACR.size() - 1)  && !newAcrObj.PRM_InActive_Ind__c){
System.debug('Exculded ContactId from Active Notification>> '+newAcrObj.PRM_Contact_Id__c);
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
        
        PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();        
        //EmailNotification Object prepartaion
        Set<String> emailIds = new Set<String>();
        if(setOfPrimaryContact.size() > 0 && !emailContDetails.isEmpty() && !mapOfConACR.isEmpty()){ 
            Map<String, String> mapOfMailToContactID = new Map<String, String>();
            Map<String, String> mapOfContPreferedLang = new Map<String, String>();
            String inputPtnrRole = null;
            if(isAfterInsert){
                inputPtnrRole = (new List<String>(setOfInPtnrRole))[0];
            }
            
            System.debug('>>>>>>>>>>>>>>> inputPtnrRole : '+inputPtnrRole);
            
            List<Map<String,String>> inputParameters = getInputParameters(emailContDetails, mapOfConACR,mapOfNewACR,accConNewMap,inputPtnrRole);
            System.debug('>>>>>>>>>>>>>>> inputParameters : '+inputParameters);
            for(String contId : setOfPrimaryContact){ 
                PRM_Account_Contact_Relationship__c prmACR = mapOfConACR.get(contId)[0];         
                if(!prmACR.PRM_Contact_Id__r.Core_Do_Not_Contact__c){ 
                    System.debug('Email sending process started');
                    if(afterInsert){
                        objEmailNotify.BusinessEvent = 'ACRCONTACT_ADDITION';
                    }
                    if(afterUpdate){
                        objEmailNotify.BusinessEvent = 'ACRCONTACT_DELETION';
                    } 
                    System.debug('Email ID :'+ prmACR.PRM_Contact_Id__r.email);
                    for(Map<String,String> inParamMap : inputParameters){                        
                        objEmailNotify.InputParameters = inParamMap;
                        PRM_EmailUtility.customPlaceholdersMap = new Map<String,String> {'{!AcrRoles}' => inParamMap.get('Contact_Relationship'), '{!ContactLoginId}' => inParamMap.get('Login_ID'), '{!ContactEmail}' => inParamMap.get('Email_ID')}; 
                            }  
                    
                    mapOfMailToContactID.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.email);                    
                    mapOfContPreferedLang.put(prmACR.PRM_Contact_Id__c,prmACR.PRM_Contact_Id__r.Core_Preferred_Language__c);
                    objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
                    emailIds.add(prmACR.PRM_Contact_Id__r.email);
                }
            }
            if(String.isNotBlank(objEmailNotify.BusinessEvent)){
                objEmailNotify.mailToContactID = mapOfMailToContactID;
                objEmailNotify.contactPreferdLang = mapOfContPreferedLang;
                PRM_EmailUtility.sendEmail(objEmailNotify);
            }
        }
        
    }
    
    
    private static List<Map<String,String>> getInputParameters(Set<String> emailContDetails, Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfConACR,Map<String, List<PRM_Account_Contact_Relationship__c>>  mapOfNewACR, Map<Id,sObject> newAcrObject, String linkForPartnerRole){
        List<Map<String,String>> inputParameters = new List<Map<String,String>>();
        for(String newContId : emailContDetails){
            Map<String,String> inParamMap = new Map<String,String>();            
            PRM_Account_Contact_Relationship__c newContactACR = mapOfConACR.get(newContId)[0];
            inParamMap.put('Account_ID',newContactACR.PRM_Account_Id__c);
            
            if(mapOfNewACR.containsKey(newContId)){
                inParamMap.put('Login_ID',newContactACR.PRM_Contact_Id__r.Core_Login_Id__c);
                inParamMap.put('Email_ID',newContactACR.PRM_Contact_Id__r.Email);
                inParamMap.put('Contact_Relationship',getAssociatedRelationDetails(mapOfConACR.get(newContId),newAcrObject));
                System.debug('>>>>>> newContactACR.PRM_Partner_Role__c : '+newContactACR.PRM_Partner_Role__c);
                String partnerRoleLink = (linkForPartnerRole != null && !String.isBlank(linkForPartnerRole)) ? linkForPartnerRole : getPartnerRoleFrmACR(newContactACR.PRM_Partner_Role__c)[0];
                System.debug('>>>>>> Link for partnerRole : '+partnerRoleLink);
                PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(partnerRoleLink);
                System.debug('emailSetup '+emailSetup);
                if(emailSetup != null){
                    inParamMap.put('EmailContent_Setup',emailSetup.Id);    
                }
            }
            inputParameters.add(inParamMap);
        }
        return inputParameters;
    }
    
    
    private static boolean isContainPartnerRole(Set<String> conRole, List<String> fetchedRole){
        for(String str: fetchedRole){
            if(conRole.contains(str)){
                return true;
            }
        }
        return false;
    }
    
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
        
        System.debug('After Role '+partnerRoles);
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
}