/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExceptionAccountsController
* Created Date      : 9th May 2019
* Modification Log
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       9th May 2019         Controller class for Add Accounts button on Exception.
*****************************************************************************************************************************************/
public with sharing class Core_MDF_ExceptionAccountsController {
    
    /***************************************************************************************************** 
    Method Name:        getIntelAccountRecords
    @return  :          ExceptionWrapper
    @parameters:        recordId - Exception Record Id
    Description:        Whenever an Exception record is created, the Accounts need to be associated with it.
    Added By:           Accenture - SB - 9th May 2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    @AuraEnabled
    public static ExceptionWrapper getIntelAccountRecords(Id recordId) {
        
        ExceptionWrapper exceptWrapper = new ExceptionWrapper();
        Map<Id, String> accountsMap = new Map<Id, String>();
        Map<Id, String> selectedAccountsMap = new Map<Id, String>();
        
        try {
            //Map of all the Channel Program API Name and its Label from the "Bank Program Entitlement Mapping" metadata
            Map<String,String> channelProgramMap = new Map<String,String>();
            //Get the Exception Program details
            if (recordId != null){
                List<Core_MDF_Exception__c> exceptionList = [SELECT Core_MDF_Program_nm__c, Core_MDF_Exception_Status_nm__c,
                                                                    Core_MDF_Company_Name_txt__c
                                                             FROM Core_MDF_Exception__c
                                                             WHERE Id =: recordId LIMIT 1];
                
                // Storing the status value In Order to reduce query during Save 
                exceptWrapper.statusStr = exceptionList[0].Core_MDF_Exception_Status_nm__c;
                //Avoid using Soql / Sosl queries without filters and limits
                /*for(Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem : ([SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c, 
                                                                                  Core_MDF_Entitlement_Name__c
                                                                           FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt LIMIT 5000])){
                    channelProgramMap.put(bpem.Core_MDF_Bank_Program_Name__c, bpem.Core_MDF_Channel_Program__c);                    
                }*/
                for(Core_MDF_ChannelProgram__mdt bpem : ([SELECT Label,Core_MDF_Bank_Program_Value__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000])){
                    channelProgramMap.put(bpem.Core_MDF_Bank_Program_Value__c, bpem.Label);                    
                }
                //Avoid Deeply Nested IF Statements
                //if(exceptionList != NULL && exceptionList.size() > 0){                
                    //Fetch the Channel Program Ids with the help of the ChannelProgram name
                    List<ChannelProgram> cpList = [SELECT Id, Name
                                                FROM ChannelProgram
                                                WHERE Name =: channelProgramMap.get(exceptionList[0].Core_MDF_Program_nm__c)
                                                ORDER BY CreatedDate];
                    
                    Set<Id> accountsIdSet =  new Set<Id>();
                    if(cpList != NULL && cpList.size() > 0){
                        //Get all the Intel Accounts related to the all the accounts related to the Exception's Program
                        for(Account allActs : [SELECT Id, Name, Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_CoMarketing_Ultimate_Account__r.Name
                                               FROM Account
                                               WHERE Core_MDF_CoMarketingActive__c = false AND 
                                                     Core_MDF_Channel_Program__c = :cpList[0].Id AND
                                                     Core_MDF_CoMarketing_Ultimate_Account__c != NULL]){
                            accountsIdSet.add(allActs.Core_MDF_CoMarketing_Ultimate_Account__c);
                        }
                        for(Account accCorp : [SELECT Id, Name
                                              FROM Account
                                              WHERE Id IN :accountsIdSet AND
                                                    Core_MDF_CoMarketingActive__c = true]){
                            if(!accountsMap.containsKey(accCorp.Id)){
                                accountsMap.put(accCorp.Id, accCorp.Name);
                            }
                        }
                        exceptWrapper.accountsMap = accountsMap;
                        
                        //Populate the Selected Accounts from Exception Account Mapping Records
                        for(Core_MDF_Exception_Account_Mapping__c eamRecord : [SELECT Id, Core_MDF_Exception_id__c, Core_MDF_Account_id__c, Core_MDF_Account_id__r.Name
                                                                               FROM Core_MDF_Exception_Account_Mapping__c
                                                                               WHERE Core_MDF_Exception_id__c = :recordId AND
                                                                                     Core_MDF_Account_id__c != NULL]){
                            if(!selectedAccountsMap.containsKey(eamRecord.Core_MDF_Account_id__c)){
                                selectedAccountsMap.put(eamRecord.Core_MDF_Account_id__c, eamRecord.Core_MDF_Account_id__r.Name);
                            }
                        }
                        exceptWrapper.selectedAccountsMap = selectedAccountsMap;
                    }
                //}
            }
        } catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;}
        return exceptWrapper;
    }
    /***************************************************************************************************** 
    Method Name:        saveExceptionAccountMappingRecords
    @return  :          Boolean
    @parameters:        recordId - Exception Record Id, accountIdList - List of Account Ids selected
    Description:        Whenever the Accounts are associated with the Exception Record, add it to the Exception Account Mapping records.
    Added By:           Accenture - SB - 9th May 2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    @AuraEnabled
    public static ExceptionErrorsWrapper saveExceptionAccountMappingRecords(Id recordId, List<String> accountIdList, String exceptionStatus, Boolean addAccountCheck, String strSelectedAccountNames)
    {
        ExceptionErrorsWrapper exceptErrorWrapper = new ExceptionErrorsWrapper();
        //Boolean isSuccess = false;
        List<Core_MDF_Exception_Account_Mapping__c> eamList = new List<Core_MDF_Exception_Account_Mapping__c>();
        try {
            //Exceptions which are in Denied and Cancelled
            if((Label.Core_MDF_Exception_Status).containsIgnoreCase(exceptionStatus)){
                exceptErrorWrapper.exceptionStatusError = Label.Core_MDF_Exception_Status_Error;
                exceptErrorWrapper.isSuccess = false;
                return exceptErrorWrapper;
            }
            //Roles which has access for the Exceptions
            String exceptionUserpermissionSet = Label.Core_MDF_Exception_User_Permission_Set;
            List<String> exceptionUserpermissionSetList = exceptionUserpermissionSet.split(',');
            List<PermissionSetAssignment> pSetList = [SELECT PermissionSet.Name 
                                                  FROM PermissionSetAssignment 
                                                  WHERE AssigneeId =: UserInfo.getUserId() AND 
                                                  PermissionSet.Name IN : exceptionUserpermissionSetList];
            //If Current user has permission set assigned
            //Avoid Deeply Nested IF Statements
            //if(pSetList.size() > 0){
                //If the Status is Pending Review or Approved and the User is Not Reviewer 
                if(pSetList.size() > 0 && (('Pending Review').equalsIgnoreCase(exceptionStatus) && addAccountCheck)|| ('Approved').equalsIgnoreCase(exceptionStatus)){
                    for(PermissionSetAssignment pSet : pSetList){
                        if(!((Label.Core_MDF_Exception_Reviewer_Permission_Set).containsIgnoreCase(pSet.PermissionSet.Name))){
                            exceptErrorWrapper.exceptionStatusError = Label.Core_MDF_Exception_Status_Error;
                            exceptErrorWrapper.isSuccess = false;
                            return exceptErrorWrapper;
                        }
                    }      
                }
            //}
            else{
                exceptErrorWrapper.exceptionStatusError = Label.Core_MDF_CloneAccessError;
                exceptErrorWrapper.isSuccess = false;
                return exceptErrorWrapper;
            }
            //Populate the Existing Exception Account Mapping Records which have to be Deleted
            List<Core_MDF_Exception_Account_Mapping__c> eamListToBeDeleted = [SELECT Id, Core_MDF_Exception_id__c, Core_MDF_Account_id__c, Core_MDF_Account_id__r.Name
                                                                              FROM Core_MDF_Exception_Account_Mapping__c
                                                                              WHERE Core_MDF_Exception_id__c = :recordId AND
                                                                                    Core_MDF_Account_id__c != NULL];
            
            List<Core_MDF_Exception__Share> exptShare = [SELECT Id, ParentId, RowCause 
                                                         FROM Core_MDF_Exception__Share
                                                         WHERE ParentId =: recordId and RowCause = 'Manual'];
            //system.debug('expt Share--->'+exptShare);
            //Check the EAM Records , delete the exisiting and add newly selected
            if(accountIdList.size() > 0 && recordId != null){                
                if(eamListToBeDeleted != NULL && eamListToBeDeleted.size() > 0){
                    SaveExceptionHelperClass sehClass = new SaveExceptionHelperClass();
                    sehClass.deleteExceptionShareRecords(exptShare, eamListToBeDeleted);
                    //Database.delete(eamListToBeDeleted);
                }
                //Create the New Exception Account Mapping Records and add it to the eamList
                for(String accountIdStr : accountIdList){
                    Core_MDF_Exception_Account_Mapping__c eamRecord = new Core_MDF_Exception_Account_Mapping__c();
                    eamRecord.Core_MDF_Exception_id__c = recordId;
                    eamRecord.Core_MDF_Account_id__c = accountIdStr;
                    eamList.add(eamRecord);
                }
                //Insert the New Exception Account Mapping Records
                if(eamList.size() > 0){
                    Database.insert(eamList);
                    //Update the Company Name field for the Exception Record
                    // Core_MDF_Exception__c eamRec = new Core_MDF_Exception__c(Id = recordId);//, Core_MDF_Company_Name_txt__c = strSelectedAccountNames);
                    // if(('Draft').equalsIgnoreCase(exceptionStatus)){
                    //     eamRec.Core_MDF_Exception_Status_nm__c = 'Pending Review';
                    //     update eamRec;
                    // }
                }
                //Update the Company Name field for the Exception Record
                if(eamList.size() > 0 && ('Draft').equalsIgnoreCase(exceptionStatus)){
                    Core_MDF_Exception__c eamRec = new Core_MDF_Exception__c(Id = recordId);//, Core_MDF_Company_Name_txt__c = strSelectedAccountNames);
                    eamRec.Core_MDF_Exception_Status_nm__c = 'Pending Review';
                    update eamRec;
                }
                exceptErrorWrapper.isSuccess = true;
                exceptErrorWrapper.exceptionStatusError = '';
            }
        } catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e); exceptErrorWrapper.isSuccess = false; exceptErrorWrapper.exceptionStatusError =Label.Core_MDF_Exception_Server_Error;}
        
        return exceptErrorWrapper;
    }
    
    /***************************************************************************************************** 
    Method Name:        ExceptionWrapper
    @return  :          Map<Id, String> , Map<Id, String> and String
    @parameters:        recordId - Exception Record Id
    Description:        Whenever the Accounts are associated with the Exception Record, add it to the Exception Account Mapping records.
    Added By:           Accenture - SB - 9th May 2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public class ExceptionWrapper{
        @AuraEnabled
        public Map<Id, String> accountsMap = new Map<Id, String>();
        @AuraEnabled
        public Map<Id, String> selectedAccountsMap = new Map<Id, String>();
        @AuraEnabled
        public String statusStr = '';
    }
    /***************************************************************************************************** 
    Method Name:        ExceptionErrorsWrapper
    @return  :          String, Boolean
    @parameters:        recordId - Exception Record Id
    Description:        Whenever the Accounts are associated with the Exception Record, add it to the Exception Account Mapping records.
    Added By:           Accenture - SB - 9th May 2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
    public class ExceptionErrorsWrapper{
        @AuraEnabled
        public String exceptionStatusError = '';
        @AuraEnabled
        public Boolean isSuccess = false;
    }

    /****************************************************************************************************************************************
    * Class Name        : SaveExceptionHelperClass
    * Created Date      : 20th May 2019
    * Modification Log
    * Developer            Date                 Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Accenture - SB       20th May 2019        To delete Exception share records and EAM records
    *****************************************************************************************************************************************/
    public without sharing class SaveExceptionHelperClass{
    /***************************************************************************************************** 
    Method Name:        deleteExceptionShareRecords
    @return  :          
    @parameters:        List of ExceptionShare and Exception Account Mapping records
    Description:        Delete Exception share records and EAM records
    Added By:           Accenture - SB - 20th May 2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/
        public void deleteExceptionShareRecords(List<Core_MDF_Exception__Share> exptShare, List<Core_MDF_Exception_Account_Mapping__c> eamListToBeDeleted){
            if(exptShare != NULL && exptShare.size() > 0){
                Database.delete(exptShare);
            }
            Database.delete(eamListToBeDeleted);
        }
    }
}