/****************************************************************************************************************************************
* Class Name        : Core_MDF_ECMCreationServerController
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       19/06/2019         Server Controller Class for creating Exception Case Mappings (ECM) from Case Screen
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ECMCreationServerController {

    public static String claimRecordId = '';
    public static String channelProgramRecordId = '';
    public static String corpAccountRecordId = '';
    /****************************************************************************************************** 
    Class Name:         ExceptionWrapper
    @parameters:        N/A
    Description:        Wrapper which will hold return values of the Exception Record and some boolean flags
    Added By:           SB Accenture - 19-06-2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public class ExceptionWrapper{
        @AuraEnabled
        public Boolean isECMAlreadyCreated = false;
        @AuraEnabled
        public Boolean isChecked = false;
        @AuraEnabled
        public Core_MDF_Exception__c exceptionRecord = new Core_MDF_Exception__c();
        @AuraEnabled
        public String ecmRecordId = '';
        @AuraEnabled
        public String claimId = '';
        @AuraEnabled
        public String channelProgramId = '';
        @AuraEnabled
        public String exceptionRecordLink = '';
        @AuraEnabled
        public String corpAccountId = '';
    }
  
    /****************************************************************************************************** 
    Method Name:        fetchExceptionRecords
    @return  :          List<ExceptionWrapper> which will hold the values of all the Exception records and the Boolean Flags.
    @parameters:        caseRecordId - Record Id of the Case
    Description:        This method will fetch all the Exception Records which can be matched with the Case on some specific parameters like Account, Program, Category Type etc.
    Added By:           SB Accenture - 18/06/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static List<ExceptionWrapper> fetchExceptionRecords(String caseRecordId) {
        List<ExceptionWrapper> exceptionWrapperList = new List<ExceptionWrapper>();
        Map<Id,Core_MDF_Exception__c> exceptionMap;
        Map<Id,Id> exceptionIdECMIdMap = new Map<Id,Id>();
        //Fetch all the Exceptions
        try {
            if(String.isNotBlank(caseRecordId)){
                exceptionMap = fetchExceptions(caseRecordId);
            }
            if(exceptionMap != NULL){
                for(Core_MDF_Exception_Case_Mapping__c ecm : [SELECT Id, Core_MDF_Case_id__c, Core_MDF_Exception_id__c
                                                              FROM Core_MDF_Exception_Case_Mapping__c
                                                              WHERE Core_MDF_Case_id__c = :caseRecordId // AND
                                                                    //Core_MDF_Exception_id__c IN :exceptionMap.keySet()
                                                             ]){
                    if(exceptionMap.keySet().contains(ecm.Core_MDF_Exception_id__c)){
                        exceptionIdECMIdMap.put(ecm.Core_MDF_Exception_id__c, ecm.Id);
                    }                    
                }
                //Creating the Exception Wrapper list
                for(Core_MDF_Exception__c excptRecord : exceptionMap.values()){
                    ExceptionWrapper ew = new ExceptionWrapper();
                    ew.exceptionRecord = excptRecord;
                    ew.claimId = claimRecordId;
                    ew.channelProgramId = channelProgramRecordId;
                    ew.corpAccountId = corpAccountRecordId;
                    ew.exceptionRecordLink = '/' + excptRecord.Id;
                    if(exceptionIdECMIdMap.get(excptRecord.Id) != NULL){
                        ew.isECMAlreadyCreated = true;
                        ew.isChecked = true;
                        ew.ecmRecordId = exceptionIdECMIdMap.get(excptRecord.Id);
                    }
                    else{
                        ew.isECMAlreadyCreated = false;
                    }
                    exceptionWrapperList.add(ew);                
                }
                return exceptionWrapperList;
            }
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return NULL;}
    return NULL;
  }
  
    /****************************************************************************************************** 
    Method Name:        saveECMRecordsCtrl
    @return  :          Boolean which will hold if the ECM record creation is a success.
    @parameters:        caseRecordId - Record Id of the Case,
                        listToSaveString - List of ExceptionWrapper passed from the Lightning component
    Description:        This method will save the ECM records passed from the Lightning Component.
    Added By:           SB Accenture - 18/06/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    @AuraEnabled
    public static Boolean saveECMRecordsCtrl(String caseRecordId, String listToSaveString) {
        //List of Exception Case Mapping to be inserted
        List<Core_MDF_Exception_Case_Mapping__c> ecmList = new List<Core_MDF_Exception_Case_Mapping__c>();
        List<Core_MDF_Exception_Case_Mapping__c> ecmListToBeDeleted = new List<Core_MDF_Exception_Case_Mapping__c>();
        List<Core_MDF_Exception_Case_Mapping__Share> ecmShareList = new List<Core_MDF_Exception_Case_Mapping__Share>();
        try{
            Case caseRecord = [SELECT Id, Core_MDF_Claim_ID__c, Account.Core_MDF_CoMarketing_Ultimate_Account__c, Account.Core_MDF_Channel_Program__r.Name
                               FROM Case
                               WHERE Id = :caseRecordId LIMIT 1];
            for(ExceptionWrapper ew : (List<ExceptionWrapper>)JSON.deserialize(listToSaveString, List<ExceptionWrapper>.class)){
                if(ew.isECMAlreadyCreated && !String.isNotBlank(ew.ecmRecordId)){
                    //Creation of Exception Case Mapping Record
                    Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c(Core_MDF_Case_id__c = caseRecordId, 
                                                                                                    Core_MDF_Exception_id__c = ew.exceptionRecord.Id);
                    //Populate the Claim
                    if(String.isNotBlank(ew.claimId)){
                        ecm.Core_MDF_Claim_id__c = ew.claimId;
                    }
                    //Populate the Program
                    if(String.isNotBlank(ew.exceptionRecord.Core_MDF_Program_nm__c)){
                        ecm.Core_MDF_Program_txt__c = ew.exceptionRecord.Core_MDF_Program_nm__c;
                    }
                    //Add Exception Case Mapping Record to the List
                    ecmList.add(ecm);
                }
            }

            List<ExceptionWrapper> ewList = (List<ExceptionWrapper>)JSON.deserialize(listToSaveString, List<ExceptionWrapper>.class);
            String accountId = ewList[0].corpAccountId;
            String cpId = ewList[0].channelProgramId;

            //Insert Exception Case Mapping Record List
            if(ecmList.size() > 0){
                insert ecmList;
            }
            
            Core_MDF_Partner_Group_Mapping__c pgmRecord = [SELECT Id, Core_MDF_Account__c, Core_MDF_Type_of_Access__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c,
                                                           	     Core_MDF_Region_cd__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c
                                                           WHERE Core_MDF_Account__c = :accountId AND
                                                                 Core_MDF_Type_of_Access__c = 'Internal' AND 
                                                                 Core_MDF_Channel_Program__c = :cpId AND
                                                                 Core_MDF_Group_Id__c != NULL AND 
                                                                 Core_MDF_Region_cd__c = NULL
                                                           LIMIT 1];
            if(pgmRecord != NULL){
                for(Core_MDF_Exception_Case_Mapping__c ecm : ecmList){
                    //SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM Core_MDF_Exception_Case_Mapping__Share
                    //Core_MDF_Exception_Case_Mapping__Share ecmShare = new Core_MDF_Exception_Case_Mapping__Share(ParentId = ecm.Id, UserOrGroupId = pgmRecord.Core_MDF_Group_Id__c, AccessLevel = 'Read', RowCause = 'Manual');
                    ecmShareList.add(new Core_MDF_Exception_Case_Mapping__Share(ParentId = ecm.Id, UserOrGroupId = pgmRecord.Core_MDF_Group_Id__c, AccessLevel = 'Read', RowCause = 'Manual'));
                }
                if(ecmShareList.size() > 0){ insert ecmShareList; }
            }
        }
        catch (Exception e){Core_MDF_CCP_UtilityClass.logError(e);return false;}
        return true;
    }
  
    /****************************************************************************************************** 
    Method Name:        fetchExceptions
    @return  :          Map<Id,Core_MDF_Exception__c> -> This will hold all the matched Exceptions.
    @parameters:        caseRecordId - Record Id of the Case,
    Description:        This method will fetch the Exception records by tallying the Account, Program, Category Type of the Case
    Added By:           SB Accenture - 18/06/2019
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
  public static Map<Id,Core_MDF_Exception__c> fetchExceptions(String caseRecordId){
        //Map of all the Channel Program and Bank Program from the "Bank Program Entitlement Mapping" metadata
        Map<String,String> channelProgramBankProgramMap = new Map<String,String>();
        String programName = '';
        Map<Id,Core_MDF_Exception__c> exceptionMap = new Map<Id,Core_MDF_Exception__c>();
        //Fetch Case Fields
        if(caseRecordId != NULL){
            Case caseRecord = [SELECT Id, Core_MDF_Activity_Start_Date__c, Core_MDF_Activity_End_Date__c, Core_MDF_Activity_Category__c, 
                                      Core_MDF_Activity_Type__c, AccountId, Account.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                      Account.Core_MDF_Channel_Program__c, Account.Core_MDF_Channel_Program__r.Name, Core_MDF_Claim_ID__c
                               FROM Case
                               WHERE Id = :caseRecordId LIMIT 1];
            System.debug('caseRecord: ' + caseRecord);
            if(caseRecord != NULL){
                //Populate the Claim
                if(caseRecord.Core_MDF_Claim_ID__c != NULL){
                    claimRecordId = caseRecord.Core_MDF_Claim_ID__c;
                }
                //Populate the Channel Program Id
                if(caseRecord.Account.Core_MDF_Channel_Program__c != NULL){
                    channelProgramRecordId = caseRecord.Account.Core_MDF_Channel_Program__c;
                }
                if(caseRecord.Account.Core_MDF_CoMarketing_Ultimate_Account__c != NULL){
                    corpAccountRecordId = caseRecord.Account.Core_MDF_CoMarketing_Ultimate_Account__c;
                }
                //Fetch Metadata to map the Programs
                Core_MDF_BankProgram_Entitlement_Mapping__mdt bpem = [SELECT Core_MDF_Bank_Program_Name__c, Core_MDF_Channel_Program__c
                                                                      FROM Core_MDF_BankProgram_Entitlement_Mapping__mdt
                                                                      WHERE Core_MDF_Channel_Program__c = :caseRecord.Account.Core_MDF_Channel_Program__r.Name LIMIT 1];
                System.debug('Line#196: ');
                if(bpem.Core_MDF_Channel_Program__c != NULL){
                    programName = bpem.Core_MDF_Bank_Program_Name__c;                
                    
                    String activityCategoryType = caseRecord.Core_MDF_Activity_Category__c + '->' + caseRecord.Core_MDF_Activity_Type__c;
                    //Fetch Exception
                    if(String.isNotBlank(activityCategoryType) && 
                       caseRecord.Core_MDF_Activity_Start_Date__c != NULL && 
                       caseRecord.Core_MDF_Activity_End_Date__c != NULL){
                        
                        for(Core_MDF_Exception__c exceptionRecord : [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c, 
                                                                            Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, 
                                                                            Core_MDF_Account_id__c, Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c,
                                                                            Core_MDF_Exception_Reason_nm__c
                                                                     FROM Core_MDF_Exception__c
                                                                     WHERE Core_MDF_Exception_Status_nm__c = :Label.Core_MDF_Exception_Approved_Status AND
                                                                           Core_MDF_Exception_Start_Date_dt__c <= :caseRecord.Core_MDF_Activity_Start_Date__c AND 
                                                                           Core_MDF_Exception_End_Date_dt__c >= :caseRecord.Core_MDF_Activity_End_Date__c AND
                                                                           Core_MDF_Program_nm__c = :programName AND 
                                                                           (Core_MDF_Account_id__c = :corpAccountRecordId OR Core_MDF_Select_All_Accounts_ind__c = true)
                                                                     ORDER BY Core_MDF_Name_of_Exception_nm__c]){
                            if(exceptionRecord.Core_MDF_Activity_Cate_and_Type_nm__c.containsIgnoreCase(activityCategoryType)){
                                exceptionMap.put(exceptionRecord.Id,exceptionRecord);
                            }
                        }
                        if(exceptionMap.size() > 0){
                            return exceptionMap;
                        }
                    }
                }
            }
        }
        return NULL;
    }
}