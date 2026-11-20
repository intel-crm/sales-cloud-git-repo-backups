/******************************************************************************************************************************
Apex Class Name:  PRM_Bulk_DataLoad_Utility
Version     : 1.0 
Created Date: 01 OCT 2021
Function    : Utility Class for Bulk Upload Capability  

Modification Log :
* Developer                     Date                Description
* ----------------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/10/2021           Utility Class for Bulk Upload Capability
****************************************************************************************************************************************/
public class PRM_Bulk_DataLoad_Utility {

    public static String operationUpdate = 'Update';
    public static String operationInsert = 'Insert';
    public static String statusComplete = 'Complete';
    public static String statusApproved = 'Approved';
    public static String statusPendingAction = 'Pending Action';
    public static String strDeactivatedAccount ='DeactivatedAccount';
    public static String strSystemAccount = 'SystemAccount';
    public static String strNoActiveACM = 'NoActiveACM';
    public static String strEmployee = 'Employee';
    public static String strInactiveAcc = 'Inactive Account';
    
  /*
   * To check if Contact is already existing for provided emailId and then assigning Update and Insert Operation Accodingly      
   *Adding Contact is already in Pending Action custom validation
   *Adding Contact is already IPA custom validation
   *Adding Incorrect Account Id for existing contact validation
   *Adding default comments to Bulk Record
  */    
    public static void checkContactExistance(List<PRM_Bulk_Data_Upload__c>bulkUploadList,String uniqueBatchId){        
        Map<String,PRM_Bulk_Data_Upload__c> inputMap = new Map<String,PRM_Bulk_Data_Upload__c>();
        //Boolean existingConNoPartnerRole = false;
        Set<Id> accountIdSet = new Set<Id>();  
        Set<Id> accntForDefaultRealation = new Set<Id>();
        Boolean hasPartnerAdmin = false;
        Map<Id,PRM_Bulk_Data_Upload__c> primaryConatactMap = new Map<Id,PRM_Bulk_Data_Upload__c>();                      
        for(PRM_Bulk_Data_Upload__c dataList:bulkUploadList){
            if(!String.isBlank(dataList.PRM_ContactEmail__c)){
                dataList.PRM_ContactEmail__c = dataList.PRM_ContactEmail__c.toLowerCase();
            }
            if(String.isBlank(dataList.PRM_ContactEmail__c) || String.isBlank(dataList.PRM_AccountId__c)
                || String.isBlank(dataList.PRM_First_Name__c) || String.isBlank(dataList.PRM_Last_Name__c)
            ){
                dataList.addError(System.Label.PRM_BulkMissingMandatoryFields);
            }else if(!inputMap.containsKey(dataList.PRM_ContactEmail__c)){
                inputMap.put(dataList.PRM_ContactEmail__c,dataList);
            }else {
                dataList.addError(System.Label.PRM_Bulk_DuplicateEmail);
            } 
            if((!hasPartnerAdmin && (datalist.PRM_Partner_Relationship__c == NULL || (datalist.PRM_Partner_Relationship__c !=null && !(datalist.PRM_Partner_Relationship__c.contains('Partner Admin')))))){            
                accntForDefaultRealation.add(dataList.PRM_AccountId__c);
            }
            if(accntForDefaultRealation != NULL && accntForDefaultRealation.contains(dataList.PRM_AccountId__c) && ( datalist.PRM_Partner_Relationship__c !=null && datalist.PRM_Partner_Relationship__c.contains('Partner Admin'))){
                accntForDefaultRealation.remove(dataList.PRM_AccountId__c);
                hasPartnerAdmin = true;
            }
            if(!primaryConatactMap.containsKey(dataList.PRM_AccountId__c)){
            primaryConatactMap.put(dataList.PRM_AccountId__c,dataList);   
            }    
          
        }

        if(accntForDefaultRealation.size()>0){
        for(PRM_Account_Contact_Relationship__c pcr : [Select id,PRM_Account_Id__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accntForDefaultRealation and PRM_InActive_Ind__c = false and PRM_Status_Nm__c = 'Complete']){
            accntForDefaultRealation.remove(pcr.PRM_Account_Id__c);          
        }
        if(accntForDefaultRealation.size()>0){
        for(id acntId : accntForDefaultRealation){
            PRM_Bulk_Data_Upload__c bNew = primaryConatactMap.get(acntid);
            bNew.PRM_Partner_Relationship__c = 'Employee;Partner Admin';
             }
            }
        }
      
        //To check if bulk data object is already existing for the provided emailIds
        for(PRM_Bulk_Data_Upload__c bulkDatas : [Select PRM_ContactEmail__c, PRM_Status__c from PRM_Bulk_Data_Upload__c where PRM_Status__c = 'New' AND PRM_ContactEmail__c IN : inputMap.keySet()]){
            if(inputMap.containsKey(bulkDatas.PRM_ContactEmail__c)){
               inputMap.get(bulkDatas.PRM_ContactEmail__c).addError(System.Label.PRM_BulkRecordExistsError);
                inputMap.remove(bulkDatas.PRM_ContactEmail__c);
            }
        }
    //To check if Contact is already existing for provided emailId and then assigning Update and Insert Operation Accodingly
        for(Contact con : [SELECT Id,Email,AccountId,Core_IPA_PartnerRole__c,Core_Preferred_Language__c,Core_IPA_Contact_Segment__c,Contact_ID__c,(SELECT PRM_Status_Nm__c, PRM_Contact_Id__c,PRM_InActive_Ind__c, PRM_Relationship_Id__r.Name FROM Account_Contact_Relationships__r) FROM Contact Where Email IN:inputMap.keySet()]){

            PRM_Bulk_Data_Upload__c bulkUploadObject = inputMap.get(con.Email);
            List<PRM_Account_Contact_Relationship__c> contactAcrs = con.Account_Contact_Relationships__r;
            bulkUploadObject.PRM_OperationType__c = operationUpdate;//Assigning Update operationtype for existing contacts.
            bulkUploadObject.PRM_Contact_Id__c = con.Contact_ID__c;
            bulkUploadObject.PRM_Preferred_Language__c = con.Core_Preferred_Language__c;

            List<String> conInputRelationships = new List<String>();
            
            if(con.Core_IPA_PartnerRole__c != null){
               bulkUploadObject.PRM_IPA_Partner_Role__c = con.Core_IPA_PartnerRole__c; 
            }
            
            
            if(bulkUploadObject.PRM_Partner_Relationship__c != null){
                if((bulkUploadObject.PRM_Partner_Relationship__c).contains(';')){
                    conInputRelationships = bulkUploadObject.PRM_Partner_Relationship__c.split(';');
                }else{
                    conInputRelationships.add(bulkUploadObject.PRM_Partner_Relationship__c);
                }                 
                if(!conInputRelationships.contains('Employee')){
                    conInputRelationships.add('Employee');
                }
            }
            else{
                for(PRM_Account_Contact_Relationship__c acr: contactAcrs ){
                    conInputRelationships.add(acr.PRM_Relationship_Id__r.Name);
                }
            }
            
            boolean ACRNonIPA = false;
            boolean isPendingAction = false;
            
            if(conInputRelationships.size() <= contactAcrs.size()){
                for(PRM_Account_Contact_Relationship__c acr : con.Account_Contact_Relationships__r){
                    if(conInputRelationships != null && conInputRelationships.contains(acr.PRM_Relationship_Id__r.Name)){
                        if(acr.PRM_Status_Nm__c == statusPendingAction && acr.PRM_InActive_Ind__c == false ){
                            isPendingAction = true;
                            continue;
                        }
                        else if(acr.PRM_InActive_Ind__c == true){
                            ACRNonIPA = true;
                        }                     
                    }
                    else{
                        ACRNonIPA = true;
                        break;
                    }
                } 
            }
            else{
                ACRNonIPA = true;
            }
            if(contactAcrs.isEmpty() && !ACRNonIPA){
                ACRNonIPA = true;
            }

            if(ACRNonIPA && !isPendingAction ){
                if(bulkUploadObject.PRM_AccountId__c == con.AccountId || inputMap.get(con.Email).PRM_AccountId__c == null){
                    bulkUploadObject.PRM_AccountId__c =con.AccountId;
                    accountIdSet.add(con.AccountId);
                }
                else{
                    //Account given is different from that in Salesforce;
                    bulkUploadObject.addError(System.Label.PRM_IncorrectAccountIDError);
                }
            }
            else if(!ACRNonIPA && !isPendingAction){
                //Adding Contact is already IPA custom validation
                bulkUploadObject.addError(System.Label.PRM_IPAContactError);
            }
            else if(!ACRNonIPA && isPendingAction){
                bulkUploadObject.addError(System.Label.PRM_ContactPendingStatusError);//Adding Contact is already in Pending Action custom validation
            }
            else if(ACRNonIPA && isPendingAction){
                ACRNonIPA = true;
            }
                
        }
        for(PRM_Bulk_Data_Upload__c dataList:bulkUploadList){
            if(dataList.PRM_OperationType__c != operationUpdate){
                dataList.PRM_OperationType__c = operationInsert;//Assigning Insert operationtype for existing contacts.
                dataList.PRM_Preferred_Language__c = dataList.PRM_Preferred_Language__c != null ? dataList.PRM_Preferred_Language__c : 'ENG';
                accountIdSet.add(dataList.PRM_AccountId__c);
            }

            //Adding Comment to Record
            String defaultComment ='Created/Updated through Bulk Data Upload by'+' '+UserInfo.getName()+' '+ 'on'+' '+system.now();
            dataList.PRM_Comments__c=dataList.PRM_Comments__c!=null?dataList.PRM_Comments__c+'-\n'+defaultComment:defaultComment;
       if(dataList.PRM_BatchID__c == null || String.isBlank(dataList.PRM_BatchID__c)){
                dataList.PRM_BatchID__c = uniqueBatchId;// Adding batch Id
            }
            //Giving Partner Relationship to all records if nothing is provided
            if(dataList.PRM_Partner_Relationship__c == null || String.isBlank(dataList.PRM_Partner_Relationship__c) || String.isEmpty(dataList.PRM_Partner_Relationship__c)){
                dataList.PRM_Partner_Relationship__c = 'Employee';
            }
        }
    
        if(accountIdSet.size()>0 && inputMap.size()>0 ){
            checkForActiveACM(accountIdSet, inputMap);//Calling CheckForActiveACM Method for new Record Addition
        }
    }
    /*
     * Checking for Deactivated/Inactive ACM Accounts/System Account and throwing Custom validations
     * Assigning oldest partner role of Account to the new Contact
    */
    public static void checkForActiveACM(Set<Id> accountIdSet, Map<String,PRM_Bulk_Data_Upload__c> inputMap){  
        Map<Id,list<String>> activeACMMap = new Map<Id,list<String>>();
        Map<Id,String> accountTypes = new Map<Id,String>();
        List<Id> sysaccs = new List<Id>();
        //retrieving all System Accounts
        for( Core_Intel_System_Accounts__mdt listsystemacc : [select AccountId__c from Core_Intel_System_Accounts__mdt]){
            sysaccs.add(listsystemacc.AccountId__c);
        }
        
        for(Account acc :[Select Id, Core_Account_Record_Type__c, Core_Deactivated__c, Core_Export_Compliance_Block__c ,(Select Id,PRM_Partner_Role__c,PRM_Account_Id__c,PRM_Status_Nm__c, CreatedDate from Channel_Memberships1__r order by CreatedDate) from Account Where Id in :accountIdSet]){
            List<PRM_AccountChannelMembership__c> accountACM = acc.Channel_Memberships1__r;
            if(acc.Core_Account_Record_Type__c == strInactiveAcc || acc.Core_Deactivated__c == true || acc.Core_Export_Compliance_Block__c == true){
                accountTypes.put(acc.Id, strDeactivatedAccount);//adding Deactivated account to map
            }
            else if(sysaccs.contains(acc.id)){
                accountTypes.put(acc.Id, strSystemAccount);//adding system account to map
            }
            else{
                boolean activeAcm = false;
                List<String> allActivePartnerRoles = new List<String>();
                for(PRM_AccountChannelMembership__c acms : accountACM){
                    if(acms.PRM_Status_Nm__c == statusApproved){
                        allActivePartnerRoles.add(acms.PRM_Partner_Role__c);
                        activeAcm = true;
                    }
                }
                if(activeAcm == false){
                    accountTypes.put(acc.Id, strNoActiveACM); //adding inactive ACM accounts to map
                }else {
                    activeACMMap.put(acc.id,allActivePartnerRoles);
                } 
            }                
        } 
        for(PRM_Bulk_Data_Upload__c inputList :inputMap.values()){            
            if(!activeACMMap.isEmpty() && activeACMMap.containsKey(inputList.PRM_AccountId__c)){
                if(inputList.PRM_IPA_Partner_Role__c == null){
                    inputList.PRM_IPA_Partner_Role__c = activeACMMap.get(inputList.PRM_AccountId__c) != null ? activeACMMap.get(inputList.PRM_AccountId__c)[0] : null;
                }
            }
            if(!accountTypes.isEmpty()){
                if(accountTypes.containsKey(inputList.PRM_AccountId__c) && accountTypes.get(inputList.PRM_AccountId__c) == strDeactivatedAccount){
                  inputList.addError(System.Label.PRM_DeactivatedAccountError);//throwing custom validation for Deactivated Accounts    
                }
                else if(accountTypes.containsKey(inputList.PRM_AccountId__c) && accountTypes.get(inputList.PRM_AccountId__c) == strNoActiveACM){
                    inputList.addError(System.Label.PRM_NoActiveACMError);//throwing custom validation for Inactive ACM Accounts   
                }
                else if(accountTypes.containsKey(inputList.PRM_AccountId__c) && accountTypes.get(inputList.PRM_AccountId__c) == strSystemAccount){
                    inputList.addError(System.Label.PRM_SystemAccountError);//throwing custom validation for System Accounts 
                }
            }           
        }        
    }    
}