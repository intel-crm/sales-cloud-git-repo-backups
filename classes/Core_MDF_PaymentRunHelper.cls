/****************************************************************************************************************************************
* Class Name      : Core_MDF_PaymentRunHelper
* Version               : 1.0 
* Created Date          : 01-30-2019
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - RG     01-30-2019        Payment Run Duplicate Handler class. 
Also restricts a User from deleting/editing a payment run record if the status is not 'Scheduled'
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PaymentRunHelper{
    
    public static Core_MDF_PaymentRunAccounts.IupgmWrapper accessibleAccountwrap;
    public static List<Id> mdfRecTypeIdList = new List<Id>();
    /***************************************************************************************************** 
Class Name:        PaymentRunWrapperClass 
Description:       Wrapper to check duplicates in the Payemnt Run records
@Added By:         Accenture - RG - 30-01-2019
Modified By:       Date:       Changes: 
******************************************************************************************************/ 
    public class PaymentRunWrapperClass {
        public String geo;
        public DateTime paymentSchedule;
        public String programName;
        public String subGeo;
        public String budgetType;
        public String paymentRunForAcc;
        public String paymentNature;
        
        public PaymentRunWrapperClass(String geo, String subGeo, DateTime paymentSchedule, String programName, String budgetType, String paymentRunForAcc, String paymentNature)  {
            this.geo = geo;
            this.subGeo = subGeo;
            this.paymentSchedule = paymentSchedule;
            this.programName = programName;
            this.budgetType = budgetType;
            this.paymentRunForAcc = paymentRunForAcc;
            this.paymentNature = paymentNature;
            
        }
        public Boolean equals(Object obj) {
            if (obj instanceof PaymentRunWrapperClass) {
                PaymentRunWrapperClass wrapperObject = (PaymentRunWrapperClass) obj;
                
                return ((geo == wrapperObject.geo) && (subGeo == wrapperObject.subGeo) && (paymentSchedule == wrapperObject.paymentSchedule) && (programName == wrapperObject.programName) && (budgetType == wrapperObject.budgetType) && (paymentRunForAcc == wrapperObject.paymentRunForAcc) && (paymentNature == wrapperObject.paymentNature));
            }
            return false;
        }
        public Integer hashCode() {
            Integer hashCode = 0;
            hashCode = geo != null ? (hashCode + System.hashCode(geo)) : hashCode;
            hashCode = subGeo != null ? (hashCode + System.hashCode(subGeo)) : hashCode;
            hashCode = paymentSchedule != null ? (hashCode + System.hashCode(paymentSchedule)) : hashCode;
            hashCode = programName != null ? (hashCode + System.hashCode(programName)) : hashCode;          
            hashCode = budgetType != null ? (hashCode + System.hashCode(budgetType)) : hashCode;
            hashCode = paymentRunForAcc != null ? (hashCode + System.hashCode(paymentRunForAcc)) : hashCode;
            hashCode = paymentNature != null ? (hashcode + System.hashcode(paymentNature)) : hashcode; 
           
            return hashCode;
        }
    }
    
    /***************************************************************************************************** 
Method Name:        duplicateCheckOnInsert
Description:        Validates the list of Payment Run Records from the hanlder and sends the list to duplicate
payments method - On Insert
@Added By:          Accenture - RG - 30-01-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void duplicateCheckOnInsert(List<Core_MDF_Payment_Run__c>paymentRunRecsToBeProcessed) {
        //List of Payment run to be processed
        List<Core_MDF_Payment_Run__c> paymentRunToBeProcessed = new List<Core_MDF_Payment_Run__c>();
        if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
            duplicatePaymentRunProcess(paymentRunRecsToBeProcessed);
        }
    }
    
    /***************************************************************************************************** 
Method Name:        duplicateCheckOnUpdate
Description:        Validates the list of Payment Run Records from the hanlder and sends the list to duplicate
payments method - On Update
@Added By:          Accenture - RG - 30-01-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void duplicateCheckOnUpdate(List<Core_MDF_Payment_Run__c>paymentRunRecsNewList, Map<Id, Core_MDF_Payment_Run__c>paymentRunRecsOldMap) {
        List<Core_MDF_Payment_Run__c > paymentRunRecsToBeProcessed = new List<Core_MDF_Payment_Run__c>();
        if(paymentRunRecsNewList!= NULL && paymentRunRecsNewList.size() > 0){
            for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsNewList){
                //it is to bypass duplicate check , if straight to pending payment checkbox is checked  
                if ((paymentRunRec.Core_MDF_Geo_Txt__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Geo_Txt__c) ||
                    (paymentRunRec.Core_MDF_Subgeo_Txt__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Subgeo_Txt__c) ||
                    (paymentRunRec.Core_MDF_ScheduleRun_Dtm__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_ScheduleRun_Dtm__c) ||
                    (paymentRunRec.Core_MDF_Program_Id__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Program_Id__c) || 
                    (paymentRunRec.Core_MDF_Budget_Type_nm__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Budget_Type_nm__c) ||
                    (paymentRunRec.Core_MDF_Account_Id__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Account_Id__c) ||
                    (paymentRunRec.Core_MDF_Run_For_All_Accounts__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Run_For_All_Accounts__c) ||
                    (paymentRunRec.Core_MDF_Run_Now_Ind__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Run_Now_Ind__c) || 
                   paymentRunRec.Core_MDF_Payment_Nature_nm__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Payment_Nature_nm__c)
                {
                    paymentRunRecsToBeProcessed.add(paymentRunRec);
                }
            }
        }
        if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
            duplicatePaymentRunProcess(paymentRunRecsToBeProcessed);
        }
    }
    
    /***************************************************************************************************** 
Method Name:        duplicatePaymentRunProcess
Description:        The method that receives list of Payment Run records and checks for duplicates against
records present in the DB/ duplicates present in the list of Payemnt Run records
@Added By:          Accenture - RG - 30-01-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/ 
    public static void duplicatePaymentRunProcess(List<Core_MDF_Payment_Run__c> paymentRunRecsToBeProcessed) {
        /* Sets of Fields against which Duplicates are being checked */
        Set<string> newGeoSet = new Set<string>();
        Set<dateTime> newPaymentScheduleSet = new Set<dateTime>();
        Set<string> newProgramNameSet = new Set<string>();
        Set<string> subGeoSet = new Set<string>();
        Set<string> newBudgetTypeSet = new Set<string>();
        List<string> budgetTypeSplitList = new List<string>();
        List<string> paymentTypeSplitList = new List<string>();
        Set<string> newAccountSet = new Set<string>();
        Set<Boolean> newRunAllAccountSet = new Set<Boolean>();
        List<String> paymentRunStatusToCheckDuplicatePaymentRun = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PMTRunStatus_DuplicateErrCheck').split(';');
        
        //Map of Payment Run Field Values as the key and Payment number as the value
        Map<PaymentRunWrapperClass,Core_MDF_Payment_Run__c> paymentNbrMap = new Map<PaymentRunWrapperClass,Core_MDF_Payment_Run__c>();
        
        /* Set of Wrappers : New Payment Run Records and Existing Payment Run Records */
        Set<PaymentRunWrapperClass> newPaymentRunRecsWrapperSet = new Set<PaymentRunWrapperClass>();
        Set<PaymentRunWrapperClass> dbPaymentRunRecsWrapperSet = new Set<PaymentRunWrapperClass>();
        
        /* List of duplicate Payment Run Records from the Input List */
        List<Core_MDF_Payment_Run__c> duplicatePaymentRunRecsList = new List<Core_MDF_Payment_Run__c >();
        for(Core_MDF_Payment_Run__c newPaymentRun: paymentRunRecsToBeProcessed){
            //for loop on budget split type split
            PaymentRunWrapperClass iKey = new PaymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_Subgeo_Txt__c,newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c, newPaymentRun.Core_MDF_Budget_Type_nm__c,newPaymentRun.Core_MDF_Payment_run_for_Accounts__c,newPaymentRun.Core_MDF_Payment_Nature_nm__c);
            if(newPaymentRunRecsWrapperSet.contains(iKey)){
                newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheInputList);
            }else{
                newGeoSet.add(newPaymentRun.Core_MDF_Geo_Txt__c);
                subGeoSet.add(newPaymentRun.Core_MDF_Subgeo_Txt__c);
                newPaymentScheduleSet.add(newPaymentRun.Core_MDF_ScheduleRun_Dtm__c);
                newProgramNameSet.add(newPaymentRun.Core_MDF_Program_Id__c);
                newAccountSet.add(newPaymentRun.Core_MDF_Account_Id__c);
                newRunAllAccountSet.add(newPaymentRun.Core_MDF_Run_For_All_Accounts__c);
                if(newPaymentRun.Core_MDF_Budget_Type_nm__c != NULL){
                    budgetTypeSplitList = newPaymentRun.Core_MDF_Budget_Type_nm__c.split(';');
                    newBudgetTypeSet.addAll(budgetTypeSplitList); 
                }
                paymentTypeSplitList.add(newPaymentRun.Core_MDF_Payment_Nature_nm__c);
                newPaymentRunRecsWrapperSet.add(iKey);
            }
        }
        for(Core_MDF_Payment_Run__c dbPaymentRun: [SELECT Id,Name, Core_MDF_Payment_Nature_nm__c,Core_MDF_Geo_Txt__c, Core_MDF_ScheduleRun_Dtm__c, Core_MDF_Program_Id__c, Core_MDF_Subgeo_Txt__c, Core_MDF_Budget_Type_nm__c, Core_MDF_Account_Id__c, Core_MDF_Run_For_All_Accounts__c,Core_MDF_Payment_run_for_Accounts__c, Core_MDF_Run_Now_Ind__c from Core_MDF_Payment_Run__c
                                                   WHERE ((Core_MDF_Geo_Txt__c IN: newGeoSet AND Core_MDF_Subgeo_Txt__c IN: subGeoSet) AND
                                                          (Core_MDF_ScheduleRun_Dtm__c IN: newPaymentScheduleSet OR Core_MDF_Run_Now_Ind__c = true) AND
                                                          (Core_MDF_Program_Id__c IN: newProgramNameSet OR
                                                           Core_MDF_Budget_Type_nm__c IN: newBudgetTypeSet) AND Core_MDF_Payment_Nature_nm__c IN: paymentTypeSplitList) AND Core_MDF_Status_Txt__c IN: paymentRunStatusToCheckDuplicatePaymentRun
                                                  ]){
                                                      //check if payment run budget type is not equal to NULL: applicable for CCF/DCF/Retail programs
                                                      if(dbPaymentRun.Core_MDF_Budget_Type_nm__c != NULL){
                                                          
                                                          
                                                          
                                                          //split the Payment Run's budget type values and loop over it to get the individual Budget type value
                                                          for(String budgetTypeSplitValue : dbPaymentRun.Core_MDF_Budget_Type_nm__c.split(';')){
                                                              if(dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c!=NULL){
                                                                  
                                                                  for(String paymentForRunAccSplitValue : dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c.split(',')){
                                                                      
                                                                      dbPaymentRunRecsWrapperSet.add(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c, budgetTypeSplitValue,paymentForRunAccSplitValue,dbPaymentRun.Core_MDF_Payment_Nature_nm__c ));
                                                                      //Store the key(Scehdule datetime, Geo, Sub Geo, Program, Budget Type, Payment Run for Accounts) and the corresponding Payment Number as the Value
                                                                      paymentNbrMap.put(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c, budgetTypeSplitValue, paymentForRunAccSplitValue,dbPaymentRun.Core_MDF_Payment_Nature_nm__c), dbPaymentRun);
                                                                  }
                                                              }
                                                              else {
                                                                  dbPaymentRunRecsWrapperSet.add(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c,dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c,dbPaymentRun.Core_MDF_Program_Id__c,budgetTypeSplitValue,dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c,dbPaymentRun.Core_MDF_Payment_Nature_nm__c));
                                                                  paymentNbrMap.put(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c, budgetTypeSplitValue,dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c,dbPaymentRun.Core_MDF_Payment_Nature_nm__c),dbPaymentRun);
                                                                  
                                                              }
                                                              
                                                              
                                                          }
                                                      }
                                                      //when the Budget Type is NULL for the Payment Run record: applicable for IPA, SPCF , CCF Boost Programs
                                                      else{
                                                          
                                                          dbPaymentRunRecsWrapperSet.add(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c,dbPaymentRun.Core_MDF_Budget_Type_nm__c,dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c,dbPaymentRun.Core_MDF_Payment_Nature_nm__c));
                                                          paymentNbrMap.put(new PaymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_Subgeo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c,dbPaymentRun.Core_MDF_Budget_Type_nm__c,dbPaymentRun.Core_MDF_Payment_run_for_Accounts__c,dbPaymentRun.Core_MDF_Payment_Nature_nm__c), dbPaymentRun);
 
                                                      }
                                                  }
        /* List of duplicate Payment Run Records from the Database */
        for(Core_MDF_Payment_Run__c newPaymentRun: paymentRunRecsToBeProcessed) {
            //check if payment run budget type is not equal to NULL: applicable for CCF/DCF/Retail programs
            if(newPaymentRun.Core_MDF_Budget_Type_nm__c != NULL){
                //split the Payment Run's budget type values and loop over it to get the individual Budget type value
                for(String budgetTypeSplitValue : newPaymentRun.Core_MDF_Budget_Type_nm__c.split(';')){
                    if(newPaymentRun.Core_MDF_Payment_run_for_Accounts__c!=NULL){
                        for(String paymentRunForAccSplitValue : newPaymentRun.Core_MDF_Payment_run_for_Accounts__c.split(',')){
                            PaymentRunWrapperClass iKey = new PaymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_Subgeo_Txt__c,newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c, budgetTypeSplitValue,paymentRunForAccSplitValue,newPaymentRun.Core_MDF_Payment_Nature_nm__c);
                            if(dbPaymentRunRecsWrapperSet.contains(iKey) && paymentNbrMap.get(iKey).Id != newPaymentRun.Id)
                            {
                                newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheDatabase+' - '+paymentNbrMap.get(iKey).Name);
                            }
                        }
                    }
                    else
                    {
                        PaymentRunWrapperClass iKey = new PaymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_Subgeo_Txt__c,newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c, budgetTypeSplitValue,newPaymentRun.Core_MDF_Payment_run_for_Accounts__c,newPaymentRun.Core_MDF_Payment_Nature_nm__c); 
                        if(dbPaymentRunRecsWrapperSet.contains(iKey) && paymentNbrMap.get(iKey).Id != newPaymentRun.Id)
                        {
                            newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheDatabase+' - '+paymentNbrMap.get(iKey).Name);
                        }
                    }
                }
            }
            //when the Budget Type is NULL for the Payment Run record: applicable for IPA, SPCF , CCF Boost Programs
            else{
                PaymentRunWrapperClass iKey;

                iKey = new PaymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_Subgeo_Txt__c,newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c, newPaymentRun.Core_MDF_Budget_Type_nm__c,newPaymentRun.Core_MDF_Payment_run_for_Accounts__c,newPaymentRun.Core_MDF_Payment_Nature_nm__c);
                if (dbPaymentRunRecsWrapperSet.contains(iKey) && paymentNbrMap.get(iKey).Id != newPaymentRun.Id) {
                    newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheDatabase+' - '+paymentNbrMap.get(iKey).Name);
                }

                
                
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:         preventDeleteWhenNotInScheduledState
Description:         Method to Prevent updates on the payment Run Record if the status is not 'Scheduled'
@Added By:           Accenture - RG - 30-01-2019
Modified By:         Date:       Changes: 
******************************************************************************************************/ 
    public static void preventDeleteWhenNotInScheduledState(List<Core_MDF_Payment_Run__c>paymentRunRecsOldList) {
        for(Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsOldList){
            if(paymentRunRec.Core_MDF_Status_Txt__c!=System.Label.Core_MDF_PaymentRunStatus_Scheduled) 
            {
                paymentRunRec.addError(system.Label.Core_MDF_PaymentRun_CannotBeDeletedIntheCurrentStatus);
            }
        }
    }
    
    /***************************************************************************************************** 
Method Name:        paymentRunFieldsResetToDefault
Description:        Resets the Payment Run Status field to Scheduled and Error Details field to blank while cloning a payment run record
payments method - On Insert
@Added By:          Accenture - HA - 05-10-2020
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void paymentRunFieldsResetToDefaultOnClone(List<Core_MDF_Payment_Run__c>paymentRunRecsToBeProcessed) {
        try{
            //List of Payment run to be processed
            List<Core_MDF_Payment_Run__c> paymentRunToBeProcessed = new List<Core_MDF_Payment_Run__c>();
            if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
                for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsToBeProcessed){
                    //check if payment run record is cloned or not
                    if(paymentRunRec.isClone()){ paymentRunRec.Core_MDF_ErrorDetails_Txt__c = '';
                                                paymentRunRec.Core_MDF_Status_Txt__c = System.Label.Core_MDF_PaymentRunStatus_Scheduled;
                                               }
                }              
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    /***************************************************************************************************** 
Method Name:        populateProgramLookupOnPaymentRun
Description:        Populates Program field of lookup type from Picklist Program field before insert and before update
@Added By:          Accenture - TT - 18-01-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void populateProgramLookupOnPaymentRun(List<Core_MDF_Payment_Run__c> paymentRunRecsToBeProcessed,Map<Id, Core_MDF_Payment_Run__c>paymentRunRecsOldMap) {
        try{
            Map<String,Id> mapOfProgramId = new Map<String,Id>();
            List<Core_MDF_Payment_Run__c> paymentRunRecToUpdate = new List<Core_MDF_Payment_Run__c>();
            Set<String> setOfProg = new Set<String>();
            for(Core_MDF_Payment_Run__c paymentRun : paymentRunRecsToBeProcessed){
                if((paymentRunRecsOldMap ==null) || (paymentRun.Core_MDF_Program_Txt__c!=paymentRunRecsOldMap.get(paymentRun.Id).Core_MDF_Program_Txt__c)){
                    setOfProg.add(paymentRun.Core_MDF_Program_Txt__c);
                    paymentRunRecToUpdate.add(paymentRun);
                }
            }
            if(setOfProg!=null && setOfProg.size()>0){
                for(ChannelProgram cp :[Select id,name,Core_MDF_Technical_Program_Name__c  from ChannelProgram where Core_MDF_Technical_Program_Name__c IN:setOfProg]){//Query all channel program records
                    mapOfProgramId.put(cp.Core_MDF_Technical_Program_Name__c,cp.id); //Map ids of channel program with key as name of channel program
                }
            }
            if (!mapOfProgramId.isEmpty() && paymentRunRecToUpdate!= NULL && paymentRunRecToUpdate.size() > 0){
                for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecToUpdate){
                    //Assign Program(lookup) field value from new program picklist type field. 
                    paymentRunRec.Core_MDF_Program_Id__c=mapOfProgramId.get(paymentRunRec.Core_MDF_Program_Txt__c);//Check if program value exists in map and assign id 
                }              
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);
                           throw e;}
        
    } 
    
    /***************************************************************************************************** 
Method Name:        validateSelectedAccount
Description:        validates accounts selected on payment run before insert and before update
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/        
    public static void validateSelectedAccount(List<Core_MDF_Payment_Run__c>paymentRunRecsToBeProcessed,Map<Id,Core_MDF_Payment_Run__c>paymentRunOldMap) {
        try{
            if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
                //List of Payment run to be processed
                List<Core_MDF_Payment_Run__c> mdfPaymentRunRecords = new List<Core_MDF_Payment_Run__c>();
                //fetching mdf record type ids
                mdfRecTypeIdList.add(Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId());
                mdfRecTypeIdList.add(Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Datacenter MDF').getRecordTypeId());
                for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsToBeProcessed){
                    if(paymentRunOldMap == null 
                       || paymentRunOldMap.get(paymentRunRec.Id).Core_MDF_Account_Id__c != paymentRunRec.Core_MDF_Account_Id__c 
                       || paymentRunOldMap.get(paymentRunRec.Id).Core_MDF_Run_For_All_Accounts__c != paymentRunRec.Core_MDF_Run_For_All_Accounts__c){
                           if(!mdfRecTypeIdList.isEmpty() && mdfRecTypeIdList.contains(paymentRunRec.RecordTypeId)){
                               mdfPaymentRunRecords.add(paymentRunRec);
                           }
                       }
                }
                if(!mdfPaymentRunRecords.isEmpty()){
                    Set<Id> accountIdSet = new Set<Id>();
                    for (Core_MDF_Payment_Run__c paymentRunRec: mdfPaymentRunRecords){
                        if(paymentRunRec.Core_MDF_Account_Id__c != null){
                            accountIdSet.add(paymentRunRec.Core_MDF_Account_Id__c);
                        }                        
                    } 
                    //wrapper with IUPGM all accounts flag and account list
                    accessibleAccountwrap = Core_MDF_PaymentRunAccounts.fetchAllMappedAccounts(); 
                    Map<Id,List<String>> accIdToProgramsMap = new Map<Id,List<String>>();
                    if(accountIdSet!=null && accountIdSet.size()>0){
                        accIdToProgramsMap = Core_MDF_PaymentRunAccounts.FetchAccountProgramMapping(accountIdSet);   
                    }
                    //looping over payment run records
                    for (Core_MDF_Payment_Run__c paymentRunRec: mdfPaymentRunRecords){
                        // to check if IUPGM is available for logged in user
                        if(!accessibleAccountwrap.allAccountsAccess && (accessibleAccountwrap.selectedAccIdsInIUPGM == null || accessibleAccountwrap.selectedAccIdsInIUPGM.size()==0)){
                            Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_MDF_NO_ACCOUNT_ACCESS');
                            paymentRunRec.addError(config.Core_MDF_Value__c);
                        }                       
                        //checking if paymenr run for all accounts is selected
                        if(paymentRunRec.Core_MDF_Run_For_All_Accounts__c){
                            //checking if IUPGM is all accounts
                            if(accessibleAccountwrap.allAccountsAccess){
                                Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_ALL_ACCOUNTS_ERROR');
                                paymentRunRec.addError(config.Core_MDF_Value__c);
                            }
                        }
                        else{
                            //checking if account selected is mapped to user in IUPGM
                            if(paymentRunRec.Core_MDF_Account_Id__c != null && !accessibleAccountwrap.allAccountsAccess 
                               && !accessibleAccountwrap.selectedAccIdsInIUPGM.isEmpty() 
                               && !(accessibleAccountwrap.selectedAccIdsInIUPGM.contains(paymentRunRec.Core_MDF_Account_Id__c))){
                                   Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_SELECTED_ACCOUNT_ERROR');
                                   paymentRunRec.addError(config.Core_MDF_Value__c);                               
                               }
                            //to check selected Account is mapped to right program in PGM
                            if(!accIdToProgramsMap.isEmpty() 
                               && accIdToProgramsMap.containsKey(paymentRunRec.Core_MDF_Account_Id__c)
                               && !accIdToProgramsMap.get(paymentRunRec.Core_MDF_Account_Id__c).contains(paymentRunRec.Core_MDF_Program_Txt__c)){
                                   Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_ACCOUNT_PROGRAM_ERROR');
                                   Core_MDF_Configuration__c config2 = Core_MDF_Configuration__c.getValues('PAYMENT_RUN_ACCOUNT_PROGRAM_ERROR2');
                                   String programLabel = Core_MDF_CCP_GenericUtility.getProgramLabel(paymentRunRec.Core_MDF_Program_Txt__c);
                                  
                                    paymentRunRec.addError(config.Core_MDF_Value__c+' '+programLabel+' '+config2.Core_MDF_Value__c);
                               }
                        }
                    }     
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
    
    /***************************************************************************************************** 
Method Name:        populateSelectedAccounts
Description:        Populates Payment run for Accounts fied of text area type with comma seperated Ids of accounts before insert and before update
@Added By:          Accenture - NK - 26-09-2021
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void populateSelectedAccounts(List<Core_MDF_Payment_Run__c>paymentRunRecsToBeProcessed,Map<Id,Core_MDF_Payment_Run__c>paymentRunOldMap) {
        try{
            if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
                //List of Payment run to be processed
                List<Core_MDF_Payment_Run__c> mdfPaymentRunRecords = new List<Core_MDF_Payment_Run__c>();
                //fetching mdf record type ids
                mdfRecTypeIdList.add(Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Client MDF').getRecordTypeId());
                mdfRecTypeIdList.add(Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByName().get('Datacenter MDF').getRecordTypeId());
                for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsToBeProcessed){
                    if(paymentRunOldMap == null 
                       || paymentRunOldMap.get(paymentRunRec.Id).Core_MDF_Account_Id__c != paymentRunRec.Core_MDF_Account_Id__c 
                       || paymentRunOldMap.get(paymentRunRec.Id).Core_MDF_Run_For_All_Accounts__c != paymentRunRec.Core_MDF_Run_For_All_Accounts__c){
                           if(!mdfRecTypeIdList.isEmpty() && mdfRecTypeIdList.contains(paymentRunRec.RecordTypeId)){
                               mdfPaymentRunRecords.add(paymentRunRec);
                           }
                       }
                }
                if(!mdfPaymentRunRecords.isEmpty()){
                    //accessible account list
                    List<Id> accIdList = new List<Id>();
                    if(accessibleAccountwrap == null){
                        accessibleAccountwrap = Core_MDF_PaymentRunAccounts.fetchAllMappedAccounts(); 
                    }
                    //wrapper with IUPGM all accounts flag and account list
                    if(accessibleAccountwrap.selectedAccIdsInIUPGM != null){
                        
                        accIdList.addAll(accessibleAccountwrap.selectedAccIdsInIUPGM);
                    }
                    //looping over payment run records
                    for (Core_MDF_Payment_Run__c paymentRunRec: mdfPaymentRunRecords){
                        //checking if payment run for all accounts is selected
                        if(paymentRunRec.Core_MDF_Run_For_All_Accounts__c){
                            if(!accIdList.isEmpty()){
                                paymentRunRec.Core_MDF_Payment_run_for_Accounts__c=String.join(accIdList, ',');
                                paymentRunRec.Core_MDF_Account_Names__c=String.join(accessibleAccountwrap.selectedAccNamesInIUPGM, ', ');
                            }
                        }
                        else{
                            paymentRunRec.Core_MDF_Payment_run_for_Accounts__c = paymentRunRec.Core_MDF_Account_Id__c;
                            
                            paymentRunRec.Core_MDF_Account_Names__c = paymentRunRec.Core_MDF_Account_Id__r.Name;
                        }
                    }
                }              
            }       
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    } 
}