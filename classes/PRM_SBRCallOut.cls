/*********************************************************************************************************************
Apex Class Name  : PRM_SBRCallOut
Version          : 1.0
Created Date     : Nov 2023
Function         : Callout class for the SBR Results (Reltio API)

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Shraddha More           26 Nov 2023              Callout class to get data from the Reltio API
*********************************************************************************************************************/
public with sharing class PRM_SBRCallOut implements Queueable, Database.AllowsCallouts {
    /*PRM_Registration_Request__c instance*/
    public PRM_Registration_Request__c regReq;
    /*to check from where this call getting called*/
    public Boolean isRefresh;
    public String country;
    public String state;

    public static string LOG_ENTRY_ORIGIN ='PRM_SBRCallOut';
    public static string LOG_ENTRY_PROJECT = 'IPA';
    public static string LOG_ENTRY_SCOPE = 'Medium';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    
    /*Constructor to get the Registration Request*/
    public PRM_SBRCallOut (PRM_Registration_Request__c regReq, Boolean isRefresh, String country, String state) {
        this.regReq = regReq;
        this.isRefresh = isRefresh;
        this.country = country;
        this.state = state;
    }
    
    /*execute*/
    public void execute (QueueableContext currentContext) {
        sbrCallOut(regReq, isRefresh, country, state);
    }

/*****************************************************************************************************************
* Method Name: sbrCallOut
* Date: Nov 2023   
* Owner: Shraddha
* Description: to get list of matching accounts from sbr search
******************************************************************************************************************/
    public static void sbrCallOut (PRM_Registration_Request__c regReq, Boolean isRefresh, String country, String state) {
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetailsList  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        PRM_AdminRegistrationDuplicateDetails.ucdErrorhandlingWrapper ucdErrWrp = new PRM_AdminRegistrationDuplicateDetails.ucdErrorhandlingWrapper();       
        PRM_Registration_Request__c reqToUpdate = new PRM_Registration_Request__c();
        Set<String> regIdSet = new Set<String>();

        try {
            //SBR
            PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR csWrp = new PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR();

            //to get country and state name from code if it is getting called from trigger
            if(isRefresh) {
                csWrp.country = country;
                csWrp.state = state;
            }else{
                csWrp = PRM_AdminRegistrationDuplicateDetails.getCountryOrStateForSBR (regReq.PRM_Country__c, regReq.PRM_State_Province__c);
            }

            //create wrapper to search matching account results
            fDetailsList = PRM_AdminRegistrationDuplicateDetails.createFDetailsList (regReq.PRM_Account_Name__c, csWrp.country, csWrp.state, regReq.PRM_Account_URL__c);

            //call reltio API to get matching accounts
            if(fDetailsList != null) {
                ucdErrWrp = PRM_AdminRegistrationDuplicateDetails.searchAccountFromUCDSBR(fDetailsList);
            }
           
            if(ucdErrWrp.isError) {
                reqToUpdate.PRM_DeDup_Criteria__c = 'FAIL';
                reqToUpdate.PRM_Dup_Status__c = 'ERROR';
                reqToUpdate.PRM_CIMStatusDetails__c= ucdErrWrp.errorMessage;
            } else{
                //insert SBR search results
                insertSBRResults(ucdErrWrp.accList, isRefresh, regReq.Id);
                // reqToUpdate = insertSBRResults(ucdErrWrp.accList, isRefresh, regReq.Id);

                //set DUP Status on registration
                if(!ucdErrWrp.accList.isEmpty() && ucdErrWrp.accList!= null) {
                    reqToUpdate.PRM_Dup_Status__c = 'DUP';
                    reqToUpdate.PRM_DeDup_Criteria__c = 'SUCCESS';
                }
                else{
                    reqToUpdate.PRM_Dup_Status__c = 'NODUP';
                    reqToUpdate.PRM_DeDup_Criteria__c = 'SUCCESS';
                }
                
            }            
        }
        catch(exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'sbrCallOut' ,'' ,ex); 
            reqToUpdate.PRM_DeDup_Criteria__c = 'FAIL';
            reqToUpdate.PRM_Dup_Status__c = 'ERROR';
            reqToUpdate.PRM_CIMStatusDetails__c = ex.getMessage();
        }
        finally {
            reqToUpdate.Id = regReq.Id;
            if(reqToUpdate.Id != null && (reqToUpdate.PRM_DeDup_Criteria__c != regReq.PRM_DeDup_Criteria__c || reqToUpdate.PRM_Dup_Status__c!= regReq.PRM_Dup_Status__c)) {
                update reqToUpdate;
            }
            regIdSet.add(regReq.Id);
            list<PRM_RegistrationTrackerUtility.RegistrationWrapper> regWrpList= PRM_RegistrationTrackerUtility.getregistrationWithTrackers(regIdSet, 'PRM_CIMCallout','Self', null);    
            PRM_RegistrationTrackerUtility.processWrapper(regWrpList, null); 
        }
    }

/*****************************************************************************************************************
* Method Name: insertSBRList
* Date: 12/2023    
* Owner: Shraddha
******************************************************************************************************************/ 
    public static void insertSBRList(List<PRM_CIMSearchResults__c> SBRListToInsert) {
        List<Core_Log_Entry__c> logEntriesSBR = new List<Core_Log_Entry__c>();
        String insertError = 'Exception occurred while inserting SBR Search Results';

        for  (Database.SaveResult sr : Database.insert (SBRListToInsert, false)) {
            if  (!sr.isSuccess()) {
                // create the log entry for failed record
                logEntriesSBR.add(new Core_Log_Entry__c (Core_Message__c = insertError, Core_Origin__c = LOG_ENTRY_ORIGIN, Core_Severity__c = LOG_ENTRY_SEVERITY, Core_When__c = System.Now(), Core_Project__c = LOG_ENTRY_PROJECT, Core_sObjectId__c = sr.getId()));
            }
        }
            
        // insert a log entry for the failed record
        if (!logEntriesSBR.isEmpty() && logEntriesSBR !=null) {
            Core_Log_Entry.createLogEntries (logEntriesSBR);
        }
    }

/*****************************************************************************************************************
* Method Name: insertSBRResults
* Date: 12/2023    
* Owner: Shraddha
******************************************************************************************************************/ 
    public static void insertSBRResults(List<PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper> accWrpList, Boolean isRefresh, Id regReqId) {
        // PRM_Registration_Request__c reqToUpdate = new PRM_Registration_Request__c();
        List<PRM_CIMSearchResults__c> SBRListToInsert = new List<PRM_CIMSearchResults__c>();
        Set<Id> existingAccIds = new Set<Id>();

        if (!accWrpList.isEmpty() && accWrpList != null) {
            if (isRefresh) { 
                for (PRM_CIMSearchResults__c es : [SELECT Id, PRM_Account_Id__c, PRM_RegReq_Id__c 
                                                   FROM PRM_CIMSearchResults__c 
                                                   WHERE PRM_RegReq_Id__c =: regReqId]
                ) {
                    existingAccIds.add(es.PRM_Account_Id__c);
                } 

                for (PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper acc : accWrpList) {
                    if (!existingAccIds.contains(acc.accId)) {
                        PRM_CIMSearchResults__c sbr = new PRM_CIMSearchResults__c();
                        sbr.PRM_Account_Nm__c = acc.accName;
                        sbr.PRM_Account_Id__c = acc.accId;
                        sbr.PRM_RegReq_Id__c = regReqId;
                        sbr.PRM_Source__c = 'Reltio SBR';
                        sbr.PRM_AddressLine1_Txt__c = acc.address;
                        SBRListToInsert.add(sbr);
                    }
                }
            }
            else {
                //create instance for sbr serach results
                for (PRM_AdminRegistrationDuplicateDetails.matchingAccWrapper acc : accWrpList) {
                    PRM_CIMSearchResults__c sbr = new PRM_CIMSearchResults__c();
                    sbr.PRM_Account_Nm__c = acc.accName;
                    sbr.PRM_Account_Id__c = acc.accId;
                    sbr.PRM_RegReq_Id__c = regReqId;
                    sbr.PRM_Source__c = 'Reltio SBR';
                    sbr.PRM_AddressLine1_Txt__c = acc.address;
                    SBRListToInsert.add(sbr);
                }
                //update registration request status once we get matching account
                /*reqToUpdate.PRM_DeDup_Criteria__c = 'SUCCESS';
                reqToUpdate.PRM_Dup_Status__c = 'DUP';*/
            }
        }
        /*else {
            //update registration request status if we don't get matching account only if it is not refresh action
            reqToUpdate.PRM_DeDup_Criteria__c = 'SUCCESS';
            reqToUpdate.PRM_Dup_Status__c = 'NODUP';
        }*/

        //insert PRM_CIMSearchResults__c records 
        if (SBRListToInsert.size()>0) {
            insertSBRList(SBRListToInsert);
        }

        // return reqToUpdate;
    }

}