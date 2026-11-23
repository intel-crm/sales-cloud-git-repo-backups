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

    /***************************************************************************************************** 
    Class Name:        paymentRunWrapperClass 
    Description:       Wrapper to check duplicates in the Payemnt Run records
    @Added By:         Accenture - RG - 30-01-2019
    Modified By:       Date:       Changes: 
    ******************************************************************************************************/ 
    public class paymentRunWrapperClass {
        public String geo;
        public DateTime paymentSchedule;
        public String programName;

        public paymentRunWrapperClass(String geo, DateTime paymentSchedule, String programName) {
            this.geo = geo;
            this.paymentSchedule = paymentSchedule;
            this.programName = programName;
        }
        public Boolean equals(Object obj) {
            if (obj instanceof paymentRunWrapperClass) {
                paymentRunWrapperClass wrapperObject = (paymentRunWrapperClass) obj;
                return ((geo == wrapperObject.geo) && (paymentSchedule == wrapperObject.paymentSchedule) && (programName == wrapperObject.programName));
            }
            return false;
        }
        public Integer hashCode() {
            Integer hashCode = 0;
            hashCode = geo != null ? (hashCode + System.hashCode(geo)) : hashCode;
            hashCode = paymentSchedule != null ? (hashCode + System.hashCode(paymentSchedule)) : hashCode;
            hashCode = programName != null ? (hashCode + System.hashCode(programName)) : hashCode;
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
    public static list <Core_MDF_Payment_Run__c> duplicateCheckOnInsert(List<Core_MDF_Payment_Run__c>paymentRunRecsToBeProcessed) {
        if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
                return duplicatePaymentRunProcess(paymentRunRecsToBeProcessed);
            }else{
                return NULL;
            }
    }

    /***************************************************************************************************** 
    Method Name:        duplicateCheckOnUpdate
    Description:        Validates the list of Payment Run Records from the hanlder and sends the list to duplicate
                        payments method - On Update
    @Added By:          Accenture - RG - 30-01-2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static list <Core_MDF_Payment_Run__c> duplicateCheckOnUpdate(List<Core_MDF_Payment_Run__c>paymentRunRecsNewList, Map<Id, Core_MDF_Payment_Run__c>paymentRunRecsOldMap) {
        List<Core_MDF_Payment_Run__c > paymentRunRecsToBeProcessed = new List<Core_MDF_Payment_Run__c>();
        if(paymentRunRecsNewList!= NULL && paymentRunRecsNewList.size() > 0){
                for (Core_MDF_Payment_Run__c paymentRunRec: paymentRunRecsNewList){
                    if ((paymentRunRec.Core_MDF_Geo_Txt__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Geo_Txt__c) ||
                        (paymentRunRec.Core_MDF_ScheduleRun_Dtm__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_ScheduleRun_Dtm__c) ||
                        (paymentRunRec.Core_MDF_Program_Id__c != paymentRunRecsOldMap.get(paymentRunRec.Id).Core_MDF_Program_Id__c)){
                          
                           paymentRunRecsToBeProcessed.add(paymentRunRec);
                        }
                }
        }
        if (paymentRunRecsToBeProcessed!= NULL && paymentRunRecsToBeProcessed.size() > 0){
                return duplicatePaymentRunProcess(paymentRunRecsToBeProcessed);
        }        
        else{
            return NULL;
        }
    }

    /***************************************************************************************************** 
    Method Name:        duplicatePaymentRunProcess
    Description:        The method that receives list of Payment Run records and checks for duplicates against
                        records present in the DB/ duplicates present in the list of Payemnt Run records
    @Added By:          Accenture - RG - 30-01-2019
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/ 
    public static list<Core_MDF_Payment_Run__c> duplicatePaymentRunProcess(List<Core_MDF_Payment_Run__c> paymentRunRecsToBeProcessed) {
        /* Sets of Fields against which Duplicates are being checked */
        Set<string> newGeoSet = new Set<string>();
        Set<dateTime> newPaymentScheduleSet = new Set<dateTime>();
        Set<string> newProgramNameSet = new Set<string>();
        
        /* Set of Wrappers : New Payment Run Records and Existing Payment Run Records */
        Set<paymentRunWrapperClass> newPaymentRunRecsWrapperSet = new Set<paymentRunWrapperClass>();
        Set<paymentRunWrapperClass> dbPaymentRunRecsWrapperSet = new Set<paymentRunWrapperClass>();
        
        /* List of duplicate Payment Run Records from the Input List */
        List<Core_MDF_Payment_Run__c> duplicatePaymentRunRecsList = new List<Core_MDF_Payment_Run__c >();
        for(Core_MDF_Payment_Run__c newPaymentRun: paymentRunRecsToBeProcessed){
                paymentRunWrapperClass iKey = new paymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c);
                if(newPaymentRunRecsWrapperSet.contains(iKey)){
                        newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheInputList);
                        duplicatePaymentRunRecsList.add(newPaymentRun);
                }else{
                        newGeoSet.add(newPaymentRun.Core_MDF_Geo_Txt__c);
                        newPaymentScheduleSet.add(newPaymentRun.Core_MDF_ScheduleRun_Dtm__c);
                        newProgramNameSet.add(newPaymentRun.Core_MDF_Program_Id__c);
                        newPaymentRunRecsWrapperSet.add(iKey);
                }
        }
        for(Core_MDF_Payment_Run__c dbPaymentRun: [SELECT Id, Core_MDF_Geo_Txt__c, Core_MDF_ScheduleRun_Dtm__c, Core_MDF_Program_Id__c from Core_MDF_Payment_Run__c
                                                    WHERE Core_MDF_Geo_Txt__c IN: newGeoSet OR
                                                          Core_MDF_ScheduleRun_Dtm__c IN: newPaymentScheduleSet OR
                                                          Core_MDF_Program_Id__c IN: newProgramNameSet
                                                   ]){
                    dbPaymentRunRecsWrapperSet.add(new paymentRunWrapperClass(dbPaymentRun.Core_MDF_Geo_Txt__c, dbPaymentRun.Core_MDF_ScheduleRun_Dtm__c, dbPaymentRun.Core_MDF_Program_Id__c));
        }
        /* List of duplicate Payment Run Records from the Database */
        for(Core_MDF_Payment_Run__c newPaymentRun: paymentRunRecsToBeProcessed) {
            paymentRunWrapperClass iKey = new paymentRunWrapperClass(newPaymentRun.Core_MDF_Geo_Txt__c, newPaymentRun.Core_MDF_ScheduleRun_Dtm__c, newPaymentRun.Core_MDF_Program_Id__c);
            if (dbPaymentRunRecsWrapperSet.contains(iKey)) {
                    newPaymentRun.addError(system.label.Core_MDF_PaymentRun_DuplicateInTheDatabase);
                    duplicatePaymentRunRecsList.add(newPaymentRun);
            }
        }
        if(duplicatePaymentRunRecsList != NULL && duplicatePaymentRunRecsList.size() > 0){
            return duplicatePaymentRunRecsList;
        }else{
            return NULL;
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

}