/**************************************************************************************************************************************************************************
    Apex Class Name     : PRM_AddContactsToGroupController 
    Version             : 1.0
    Created Date        : 13-May-2020
    
    Modification Log    :
    * Developer				User Story             Date                    Description
    * --------------------------------------------------------------------------------------------------------------------------
    * Sonali Mehetre       	 US651040			13-May-2020                Search Contacts based on certain Criteria and Create Contact Group contact Association Records.  
     
***************************************************************************************************************************************************************************/

public without sharing class PRM_AddContactsToGroupController {
  public static List<PRM_Contact_Group_Contact_Association__c> lstOfExistCGCARec = new List<PRM_Contact_Group_Contact_Association__c>();
  public static set<String> setOfContactIds = new set<String>();
  public static set<String> setOfExistContactIds = new set<String>();
    
    //Method to Search Contact based on input Criteria from UI like Email,Login Id and Salesforce Id and Account associated to contact should be IPA.
    @AuraEnabled
    public static List<ContactWrapper> fetchContactsData(String contactEmail,string currentContactGrId){
        List<PRM_Account_Contact_Relationship__c> lstOfACR = new List<PRM_Account_Contact_Relationship__c>();        
        List<String> lstOfcontactEmail = contactEmail.split(';');  
        List<ContactWrapper> lstOfContactWrapper = new List<ContactWrapper>();
        
        Try{
            lstOfExistCGCARec = [Select Id,Name,PRM_Contact_Id__c,PRM_Contact_Group_Id__c,PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Group_Id__c =:currentContactGrId AND PRM_InActive_Ind__c = false];
            if(lstOfExistCGCARec != null && !lstOfExistCGCARec.isEmpty()){
                for(PRM_Contact_Group_Contact_Association__c existRec : lstOfExistCGCARec){
                    setOfContactIds.add(existRec.PRM_Contact_Id__c);
                }
            }                     
            
                lstOfACR = [Select Id,Name,PRM_Account_Id__c,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
                                 PRM_Contact_Id__c, PRM_Contact_Id__r.Name,PRM_InActive_Ind__c,PRM_Contact_Id__r.Email, PRM_Contact_Id__r.FirstName,
                                 PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Phone,toLabel(PRM_Contact_Id__r.Core_IPA_PartnerRole__c),
                                 PRM_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c from 
                                 PRM_Account_Contact_Relationship__c where PRM_InActive_Ind__c  = False AND PRM_Contact_Id__c NOT IN : setOfContactIds
                                 AND PRM_Contact_Id__r.Account.Core_Intel_Partner_Alliance_PartnerGroup__c =:True AND (PRM_Contact_Id__r.Email IN :lstOfcontactEmail
                                 /*OR PRM_Contact_Id__r.Core_Login_Id__c IN :lstOfcontactEmail*/ OR PRM_Contact_Id__c IN :lstOfcontactEmail)];
           
            if(lstOfACR != null && !lstOfACR.isEmpty()){
                for(PRM_Account_Contact_Relationship__c cntRec : lstOfACR){
                    ContactWrapper cntdata = new ContactWrapper();
                    cntdata.id = cntRec.PRM_Contact_Id__c;
                    cntdata.contactName = cntRec.PRM_Contact_Id__r.Name;
                    cntdata.contactFirstName = cntRec.PRM_Contact_Id__r.FirstName;
                    cntdata.contactLastName = cntRec.PRM_Contact_Id__r.LastName;
                    cntdata.contactPartnerRole = cntRec.PRM_Contact_Id__r.Core_IPA_PartnerRole__c;
                    cntdata.contactEmail = cntRec.PRM_Contact_Id__r.Email;
                    cntdata.contactPhone = cntRec.PRM_Contact_Id__r.Phone;
                    
                    if(!setOfExistContactIds.contains(cntRec.PRM_Contact_Id__c)){
                        setOfExistContactIds.add(cntRec.PRM_Contact_Id__c);
                        lstOfContactWrapper.add(cntdata);
                    }                
            	}
            } 

        }
        catch(DmlException e) {
            //System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        return lstOfContactWrapper;
    }
    
    //Method To Insert Contact Group Contact Association Records for Selected contacts from UI and current Group Id.
    @AuraEnabled
    public static String insertContactGrContAssRecords(List<Object> lstOfSelContacts,string currentContactGrId){
        List<ContactWrapper> lstOfcontWrapData = (List<ContactWrapper>)JSON.deserialize(JSON.serialize(lstOfSelContacts), List<ContactWrapper>.class);
        List<PRM_Contact_Group_Contact_Association__c> lstOfContGrContAss = new List<PRM_Contact_Group_Contact_Association__c>();  

        Database.upsertResult[] successRecList;
        //Integer successCount = 0;
        //Integer failureCount = 0;
        String result;
        
        Try{
            if(lstOfcontWrapData != null && !lstOfcontWrapData.isEmpty()){
                lstOfContGrContAss = getListOfContGrContAss(lstOfcontWrapData, currentContactGrId);
            }

            if(lstOfContGrContAss != null && !lstOfContGrContAss.isEmpty()){
                successRecList = Database.upsert(lstOfContGrContAss,false);
            }
            if(successRecList<>null && !successRecList.isEmpty()){
              result = getResult(successRecList);
            }
        }catch(DmlException e) {
            //System.debug('The following exception has occurred: ' + e.getMessage());
        } 
        return result;        
    }
    public static List<PRM_Contact_Group_Contact_Association__c> getListOfContGrContAss( List<ContactWrapper> lstOfcontWrapData, string currentContactGrId){
        List<PRM_Contact_Group_Contact_Association__c> lstOfContGrContAss = new List<PRM_Contact_Group_Contact_Association__c>();  
        for(ContactWrapper conRec : lstOfcontWrapData){
            setOfContactIds.add(conRec.id);
        }
        //Exist CGCA Inactive Records 
        	List<PRM_Contact_Group_Contact_Association__c> lstOfExistContGrAssRec = [Select Id,PRM_Contact_Id__c,PRM_Contact_Group_Id__c,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c from PRM_Contact_Group_Contact_Association__c where PRM_Contact_Group_Id__c =:currentContactGrId AND PRM_Contact_Id__c IN :setOfContactIds AND PRM_InActive_Ind__c = True];
            if(lstOfExistContGrAssRec != null && !lstOfExistContGrAssRec.isEmpty()){
                for(PRM_Contact_Group_Contact_Association__c existRec : lstOfExistContGrAssRec){                   
                    existRec.PRM_InActive_Ind__c = false;
                    existRec.PRM_Start_Date_Dt__c = System.today();  
                    setOfExistContactIds.add(existRec.PRM_Contact_Id__c);
					lstOfContGrContAss.add(existRec);
                }
            }
        for(ContactWrapper rec : lstOfcontWrapData){
            PRM_Contact_Group_Contact_Association__c contactGrAssoObj = new PRM_Contact_Group_Contact_Association__c();
            contactGrAssoObj.PRM_Contact_Id__c = rec.id;
            contactGrAssoObj.PRM_Contact_Group_Id__c = currentContactGrId;
            contactGrAssoObj.PRM_Start_Date_Dt__c = System.today();
            if(!setOfExistContactIds.contains(contactGrAssoObj.PRM_Contact_Id__c)){ 
                lstOfContGrContAss.add(contactGrAssoObj);   
            }                     
        }      
        return lstOfContGrContAss;	
    }
    public static String getResult(Database.upsertResult[] successRecList){
        
        Integer successCount = 0;
        Integer failureCount = 0;

        for(Database.upsertResult successrec:successRecList)
            {
                if(successrec.isSuccess())
                {                                             
                    successCount++;
                }else{                       
                    for(Database.Error err : successrec.getErrors()) {                                    
                        failureCount++;  
                    }
                }
            }
         return (successCount > 0) ? 'Success' : 'Failed';
    }
     public with sharing class ContactWrapper {
         @auraEnabled public string id {get;set;}
         @auraEnabled public string contactName {get;set;}
         @auraEnabled public string contactFirstName {get;set;}
         @auraEnabled public string contactLastName {get;set;}
         @auraEnabled public string contactPartnerRole {get;set;}
         @auraEnabled public string contactEmail {get;set;}
         @auraEnabled public string contactPhone {get;set;}
    }
}