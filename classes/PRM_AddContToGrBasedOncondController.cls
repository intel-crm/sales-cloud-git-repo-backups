/**************************************************************************************************************************************************************************
Apex Class Name     : PRM_AddContToGrBasedOncondController 
Version             : 1.0
Created Date        : 01-June-2020

Modification Log    :
* Developer				User Story             Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre       	 US651043			01-June-2020               dispaly contacts related to Tier benefits/Specialty and Create Contact Group contact Association Records.  

***************************************************************************************************************************************************************************/

public without sharing class PRM_AddContToGrBasedOncondController {
    
    public static List <FatchValueWrapper> objWrapper = new List < FatchValueWrapper > ();
    public static set<String> setOfContactIds = new set<String>();
    public static set<String> setOfAccIds = new set<String>();
    
    @AuraEnabled(cacheable=true)
    public static List <FatchValueWrapper> fetchContactGroups() {    
        List<PRM_Contact_Group__c> lstofcontactGrNames = new List<PRM_Contact_Group__c>(); 
        List<PRM_Message_Contact_Group_Association__c> lstOfMCGARec = new List<PRM_Message_Contact_Group_Association__c>();
        set<String> setOfContGrIdAssoToMsg = new set<String>();
        
        //Collect contact Gr Ids which are associated with Message
        lstOfMCGARec = [Select Id,Name,PRM_Contact_Group_Id__c,PRM_Message_Id__c from PRM_Message_Contact_Group_Association__c];
        if(lstOfMCGARec != null && !lstOfMCGARec.isEmpty()){	
            for(PRM_Message_Contact_Group_Association__c MCGARec : lstOfMCGARec){
                setOfContGrIdAssoToMsg.add(MCGARec.PRM_Contact_Group_Id__c);
            }
        }
        
        //Return Contact Gr which are not associated to any Message
        lstofcontactGrNames = [Select Id,Name from PRM_Contact_Group__c where Id Not IN :setOfContGrIdAssoToMsg];
        if(lstofcontactGrNames != null && !lstofcontactGrNames.isEmpty()){				
            for (PRM_Contact_Group__c contGr: lstofcontactGrNames) {
                FatchValueWrapper oFatchValueWrapper = new FatchValueWrapper();
                oFatchValueWrapper.slabel = contGr.Name;
                oFatchValueWrapper.svalue = contGr.Id;
                objWrapper.add(oFatchValueWrapper); 
            } 			
        }        
        return objWrapper; 
    }
    
    @AuraEnabled
    public static List <PRM_Account_Contact_Relationship__c> fetchContacts(Id currentRecId, String currentContactGrId) {
        List<PRM_Account_Contact_Relationship__c> finallstOfContact = new List<PRM_Account_Contact_Relationship__c>();   
        List<PRM_Account_Specialty_Association__c> lstOfAsa = new List<PRM_Account_Specialty_Association__c>();	
        set<String> setOfASAPartnerRoles = new set<String>();        
        //String query ='';
        
        Try{         
            if(currentRecId != null || currentRecId != ''){
                lstOfAsa = [Select Id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_InActive_Ind__c = false AND PRM_Specialty_Id__c = :currentRecId];
            }            
            if(lstOfAsa != null && !lstOfAsa.isEmpty()){
                for(PRM_Account_Specialty_Association__c asaRec : lstOfAsa){
                    setOfAccIds.add(asaRec.PRM_Account_Id__c);
                    setOfASAPartnerRoles.add(asaRec.PRM_Partner_Role__c);
                }
            }
            if(setOfAccIds != null && !setOfAccIds.isEmpty()){
                finallstOfContact = getMapOfExistContIdAndContRec(setOfAccIds,setOfASAPartnerRoles,currentContactGrId); 
            }             
        }
        catch(DmlException e) {
            //System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return finallstOfContact;
    }
    public static  List<PRM_Account_Contact_Relationship__c> getMapOfExistContIdAndContRec(set<String> setOfAccIds, set<String> setOfASAPartnerRoles ,String currentContactGrId){
        set<String> setOfInactiveContactIds = new set<String>();
        set<String> setOfActiveContactIds = new set<String>(); 
        Map<String,PRM_Account_Contact_Relationship__c> mapOfExistInactiveContIdAndContRec = new Map<String,PRM_Account_Contact_Relationship__c>();
        Map<String,PRM_Account_Contact_Relationship__c> mapOfExistActiveContIdAndContRec = new Map<String,PRM_Account_Contact_Relationship__c>(); 
        List<PRM_Contact_Group_Contact_Association__c> lstOfExistCGCARec = new List<PRM_Contact_Group_Contact_Association__c>();        
        
        //Check if record is already exist to avoid duplicate record
            lstOfExistCGCARec = [Select Id,Name,PRM_Contact_Id__c,PRM_Contact_Id__r.AccountId, PRM_Contact_Group_Id__c,PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Group_Id__c =:currentContactGrId AND PRM_Contact_Id__r.AccountId IN: setOfAccIds];
            if(lstOfExistCGCARec != null && !lstOfExistCGCARec.isEmpty()){
                for(PRM_Contact_Group_Contact_Association__c existRec : lstOfExistCGCARec){
                    if(existRec.PRM_InActive_Ind__c == true){                        
                        setOfInactiveContactIds.add(existRec.PRM_Contact_Id__c);//for Existing inactive CGCA records.
                    }else{
                        setOfActiveContactIds.add(existRec.PRM_Contact_Id__c);//for Existing Active CGCA records.
                    }                                      
                }
            }
                //Create Map for Existing Inactive CGCA records.
        if(setOfInactiveContactIds != null && !setOfInactiveContactIds.isEmpty()){
            for(PRM_Account_Contact_Relationship__c contRec : [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c  = False AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true AND PRM_Contact_Id__c IN:setOfInactiveContactIds]){
                mapOfExistInactiveContIdAndContRec.put(contRec.PRM_Contact_Id__c,contRec);
            }
        }
        //Create Map for Existing Active CGCA records.
        if(setOfActiveContactIds != null && !setOfActiveContactIds.isEmpty()){
            for(PRM_Account_Contact_Relationship__c contRec : [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Contact_Id__c, PRM_Contact_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c  = False AND PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true AND PRM_Contact_Id__c IN:setOfActiveContactIds]){
                mapOfExistActiveContIdAndContRec.put(contRec.PRM_Contact_Id__c,contRec);
            }
        }
        return getFinalListOfContact(mapOfExistInactiveContIdAndContRec, mapOfExistActiveContIdAndContRec, setOfASAPartnerRoles );
    }
    public static  List<PRM_Account_Contact_Relationship__c> getFinalListOfContact( Map<String,PRM_Account_Contact_Relationship__c> mapOfExistInactiveContIdAndContRec, Map<String,PRM_Account_Contact_Relationship__c> mapOfExistActiveContIdAndContRec, set<String> setOfASAPartnerRoles ){
        List<PRM_Account_Contact_Relationship__c> finallstOfContact = new List<PRM_Account_Contact_Relationship__c>();    
        Map<String,PRM_Account_Contact_Relationship__c> mapOfcontIdAndContRec = new Map<String,PRM_Account_Contact_Relationship__c>();
        List<PRM_Account_Contact_Relationship__c> lstOfACR =  [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
                    PRM_Contact_Id__c, PRM_Contact_Id__r.Name,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Partner_Role__c,
                    PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c =false AND 
                    PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c =true AND PRM_Account_Id__c IN :setOfAccIds AND 
                    PRM_Contact_Id__r.Core_IPA_PartnerRole__c IN :setOfASAPartnerRoles];
                        
            if(lstOfACR != null && !lstOfACR.isEmpty()){
                for(PRM_Account_Contact_Relationship__c newCont : lstOfACR){
                    if(mapOfExistActiveContIdAndContRec != null && !mapOfExistActiveContIdAndContRec.isEmpty()){
                        if(!mapOfExistActiveContIdAndContRec.containsKey(newCont.PRM_Contact_Id__c) && !mapOfcontIdAndContRec.containsKey(newCont.PRM_Contact_Id__c)){
                            mapOfcontIdAndContRec.put(newCont.PRM_Contact_Id__c,newCont);
                            finallstOfContact.add(newCont);
                        }
                    }else{
                        if(!mapOfcontIdAndContRec.containsKey(newCont.PRM_Contact_Id__c)){
                            mapOfcontIdAndContRec.put(newCont.PRM_Contact_Id__c,newCont);
                            finallstOfContact.add(newCont); 
                        }                          
                    }                    
                }
            }
            if(mapOfExistInactiveContIdAndContRec != null && !mapOfExistInactiveContIdAndContRec.isEmpty()){
               finallstOfContact.addAll(getFinalListOfContacts(mapOfExistInactiveContIdAndContRec, mapOfcontIdAndContRec));
            }
            return finallstOfContact;
    }
    public static  List<PRM_Account_Contact_Relationship__c> getFinalListOfContacts(Map<String,PRM_Account_Contact_Relationship__c> mapOfExistInactiveContIdAndContRec, Map<String,PRM_Account_Contact_Relationship__c> mapOfcontIdAndContRec){
        List<PRM_Account_Contact_Relationship__c> finallstOfContact = new List<PRM_Account_Contact_Relationship__c>(); 
         for(String contId : mapOfExistInactiveContIdAndContRec.keySet()){  
            if(mapOfcontIdAndContRec != null && !mapOfcontIdAndContRec.isEmpty()){
                if(!mapOfcontIdAndContRec.containsKey(contId)){
                    finallstOfContact.add(mapOfExistInactiveContIdAndContRec.get(contId));
                }
            }else{
                finallstOfContact.add(mapOfExistInactiveContIdAndContRec.get(contId));
            }                    
        }
        return finallstOfContact;
    }
    
    //Method To Insert Contact Group Contact Association Records for Selected contacts from UI and selected Group Id.
    @AuraEnabled
    public static String insertContactGrContAssRecords(List<Object> lstOfSelContacts,string currentContactGrId){
        List<PRM_Account_Contact_Relationship__c> lstOfContacts = (List<PRM_Account_Contact_Relationship__c>)JSON.deserialize(JSON.serialize(lstOfSelContacts), List<PRM_Account_Contact_Relationship__c>.class);
        List<PRM_Contact_Group_Contact_Association__c> lstOfContGrContAss = new List<PRM_Contact_Group_Contact_Association__c>();  
        //set<PRM_Contact_Group_Contact_Association__c> setOfExistContGrContAss = new set<PRM_Contact_Group_Contact_Association__c>();    
        //set<PRM_Contact_Group_Contact_Association__c> setOfNewContGrContAss = new set<PRM_Contact_Group_Contact_Association__c>();    
        Database.upsertResult[] successRecList;
        //Integer successCount = 0;
        //Integer failureCount = 0;
        String result;
        
        Try{
            if(lstOfContacts != null && !lstOfContacts.isEmpty()){
                lstOfContGrContAss = getListOfContGrContAss(lstOfContacts,currentContactGrId);
            }
            if(lstOfContGrContAss != null && !lstOfContGrContAss.isEmpty()){
                successRecList = Database.upsert(lstOfContGrContAss,false);
            }
            if(successRecList<>null && !successRecList.isEmpty()){
              result = PRM_AddContactsToGroupController.getResult(successRecList);
            }
        }catch(DmlException e) {
            //System.debug('The following exception has occurred: ' + e.getMessage());
        } 
        return result;        
    }
    public static List<PRM_Contact_Group_Contact_Association__c> getListOfContGrContAss( List<PRM_Account_Contact_Relationship__c> lstOfContacts, string currentContactGrId){
        List<PRM_Contact_Group_Contact_Association__c> lstOfContGrContAss = new List<PRM_Contact_Group_Contact_Association__c>();  
         List<PRM_Contact_Group_Contact_Association__c> lstOfExistContGrAssRec = new List<PRM_Contact_Group_Contact_Association__c>();
       
        set<String> setOfExistContactIds = new set<String>();
        for(PRM_Account_Contact_Relationship__c conRec : lstOfContacts){
            setOfContactIds.add(conRec.PRM_Contact_Id__c);
        }
       //Exist CGCA Inactive Records 
            lstOfExistContGrAssRec = [Select Id,PRM_Contact_Id__c,PRM_Contact_Group_Id__c,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Group_Id__c =:currentContactGrId AND PRM_Contact_Id__c IN :setOfContactIds AND PRM_InActive_Ind__c = True];
            if(lstOfExistContGrAssRec != null && !lstOfExistContGrAssRec.isEmpty()){
                for(PRM_Contact_Group_Contact_Association__c existRec : lstOfExistContGrAssRec){                   
                    existRec.PRM_InActive_Ind__c = false;
                    existRec.PRM_Start_Date_Dt__c = System.today();  
                    setOfExistContactIds.add(existRec.PRM_Contact_Id__c);
                    lstOfContGrContAss.add(existRec);
                }
            }
            
            if(lstOfContacts != null && !lstOfContacts.isEmpty()){
                for(PRM_Account_Contact_Relationship__c rec : lstOfContacts){
                    PRM_Contact_Group_Contact_Association__c contactGrAssoObj = new PRM_Contact_Group_Contact_Association__c();
                    contactGrAssoObj.PRM_Contact_Id__c = rec.PRM_Contact_Id__c;
                    contactGrAssoObj.PRM_Contact_Group_Id__c = currentContactGrId;
                    contactGrAssoObj.PRM_Start_Date_Dt__c = System.today();
                    if(!setOfExistContactIds.contains(contactGrAssoObj.PRM_Contact_Id__c)){
                        lstOfContGrContAss.add(contactGrAssoObj);   
                    }                     
                }     
        }
        return lstOfContGrContAss;	
    }
    // wrapper class 
    public with sharing class FatchValueWrapper {
        @auraEnabled public string slabel {get;set;}
        @auraEnabled public string svalue {get;set;}
    }
    
}