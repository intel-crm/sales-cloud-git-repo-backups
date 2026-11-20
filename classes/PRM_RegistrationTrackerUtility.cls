/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

/*********************************************************************************************************************
Apex Class Name  : PRM_RegistrationTrackerUtility
Version       : 1.0
Created Date  : July 2022
Function      : Utility class to track each steps of IPA registration and create an ENtry in Registration Tracker Object

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------
* Sathya                July 2022                Utility class to track each steps of IPA registration and create an ENtry in Registration Tracker Object

***********************************************************************************************************************************************************/
public with sharing class PRM_RegistrationTrackerUtility {
    public static String errMsg ='';
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh); //IPA2.0 TWC727-2914
    private static Map<string, string> stageMap = new Map<string, string>();
    public static list<Decimal> registrationSteps = new List<Decimal>{ 24.0 };
        private static map<string, PRM_Registration_Tracker__c> regTrackMap = new Map<string, PRM_Registration_Tracker__c>();
    public static map<string, string> emailRegrequetMap = new Map<string, string>();
    public static Id AdminrecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Admin_Registration')
        .getRecordTypeId();
    public static Id Account_Create_RequestRTId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Account_Create_Request')
        .getRecordTypeId();
    public static String origin = 'PRM_RegistrationTrackerUtility';
    public static String project = 'IPA';
    public static PRM_Registration_Tracker_Steps__mdt medata;    
    public static string externalState;
    
    //public static string message;
    
    /************************************************************************************************************************************
Method Name: createRegistrationTrackerQueuable 
Description: Queueable class which gets called from Prm_regreqTriggerhanler and acr trigger handle in afterinsert and after update
Return:None
**************************************************************************************************************************************/
    public class createRegistrationTrackerQueuable implements Queueable {
        list<PRM_Registration_Request__c> regreqList = new List<PRM_Registration_Request__c>();
        set<string> contrecordIds = new Set<String>();
        boolean retry, EVfirstTime;
        public createRegistrationTrackerQueuable(list<PRM_Registration_Request__c> regLi,set<string> contIds1,boolean retry1,boolean EVfirstTime1) {
            this.regreqList = regLi;
            this.contrecordIds = contIds1;
            this.retry = retry1;
            this.EVfirstTime = EVfirstTime1;
            errMsg+='From PRM_RegistrationTrackerUtility--> Value 1 in createRegistrationTrackerQueuable constructor is--'+regLi+'--v2--'+contIds1+'--v3--'+retry1+'--v4--'+EVfirstTime1+' \n';
        }
        public void execute(QueueableContext context) {
            executeMethod(regreqList, contrecordIds, retry, EVfirstTime);
        }
    }
    public static void executeMethod(list<PRM_Registration_Request__c> regreqList,set<string> contrecordIds,Boolean retry,Boolean EVfirstTime) {
        try {
             errMsg+='Value 1 in execute method is--'+regreqList+'--v2--'+contrecordIds+'--v3--'+retry+'--v4--'+EVfirstTime+' \n';
            if(regreqList != null){
                errMsg+='Line 65 \n';
                //System.debug(LoggingLevel.info,'>>>>>find me '+regreqList[0].PRM_Email_ID__c);
            }
            errMsg+='Line 68 \n ';
            createRegistrationTracker(regreqList, contrecordIds, retry, EVfirstTime);
            errMsg+='Line 70 \n';
        } catch (exception ex) {
            //system.debug('---exception ' + ex.getmessage());
            getlogentries.errorMessage = getlogentries.errorMessage != null? getlogentries.errorMessage + ';' + ex.getmessage(): ex.getmessage();
        } finally {
            if (getlogentries.errorMessage != null)
                //system.debug('---message ' + getlogentries.errorMessage);
            Core_Log_Entry.logEntryWithDetails(origin,project,'PRM_RegistrationTrackerUtility','Info','PRM_RegistrationTrackerUtility Invoked at' + system.today(),getlogentries.errorMessage,'','','');
        }
    }
    
    /************************************************************************************************************************************
Method Name: createRegistrationTracker
Description: Utility method from Queueable class which gets called from Prm_regreqTriggerhanler and acr trigger handle in afterinsert and after update
Return:None
**************************************************************************************************************************************/
    
    public static void createRegistrationTracker(list<PRM_Registration_Request__c> regList,set<String> contrecordIds,boolean retried,boolean EVfirstTime) {
        errMsg+='Line 88- method called \n';
        errMsg+='Value 1 in createRegistrationTracker method is--'+regList+'--v2--'+contrecordIds+'--v3--'+retried+'--v4--'+EVfirstTime+' \n';
        set<string> regEmailIds = new Set<string>();
        set<string> ContactIds = new Set<string>();
        set<string> regIds = new Set<string>();
        set<string> ContIds = new Set<string>();
        set<string> mailCheck = new Set<string>();
        list<RegistrationWrapper> regWrapperList = new List<RegistrationWrapper>();
        string registrationType;
        map<string, PRM_Registration_Tracker__c> emailTrackerMap = new Map<string, PRM_Registration_Tracker__c>();
        map<string, list<PRM_Registration_Tracker__c>> conRegList = new Map<string, list<PRM_Registration_Tracker__c>>();
        errMsg+='Line 99- calling getStagePicklistvalues method \n';
        getStagePicklistvalues();
        errMsg+='Line 101- after getStagePicklistvalues method called \n';
        //New Registration record is there, so it could be either Self or admin
        if (regList != null) {
            errMsg+='Line 104 regList not null--'+regList+' \n';
            //iterate trigger.new to get registration's Id and Email
            for (PRM_Registration_Request__c req : regList) {
                regIds.add(req.Id);
                errMsg+='Line 108 regIds value--'+regIds+' \n';
                if (req.recordtypeId == AdminrecordTypeId) {
                    errMsg+='Line 110 Admin record type \n';
                    ContIds.add(req.PRM_Matching_Contact__c);
                    emailRegrequetMap.put(req.PRM_Email_ID__c, req.id);
                    registrationType = 'Admin';
                } else {
                    errMsg+='Line 115 Self reg \n';
                    registrationType = 'Self';
                    regEmailIds.add(req.PRM_Email_ID__c);
                }
            }
            errMsg+='Line 120 ContIds value is--'+ContIds+'--emailRegrequetMap value is--'+emailRegrequetMap+'--registrationType--'+registrationType+'--regEmailIds--'+regEmailIds+' \n';
            if (ContIds.size() > 0)
                conRegList = getRegistrationTracker(ContIds);
            errMsg+='Line 123 conRegList--'+conRegList+' \n';
            //query to get necessary fields from new Registrations and its registration tracker records
            List<PRM_Registration_Request__c> regRList = new List<PRM_Registration_Request__c>();
            
            regRList = [SELECT id,PRM_DeDup_Criteria__c,(SELECT id,Stage__c,PRM_Registration_Type__c,PRM_Current_Step__c,PRM_Step_Number__c,PRM_Registration__c,PRM_Log_Entries__c,PRM_Email__c,PRM_Last_Milestone_DateTime__c,CreatedDate,PRM_AGD_ID_Updated__c,PRM_Account__c,PRM_contact__c FROM Registration_Trackers__r WHERE PRM_Current_Step__c != NULL AND IsActive__c = true ORDER BY PRM_Step_Number__c DESC),Sync_Profile_Response__c,recordtype.developername,PRM_Auto_Approve__c,PRM_Status__c,PRM_Salesforce_ID__c,PRM_Matching_Contact__c,PRM_Email_Verification_Criteria__c,PRM_Email_Log__c,PRM_Email_ID__c,PRM_Email_Log__r.Email_Template_Name__c FROM PRM_Registration_Request__c WHERE id IN :regIds AND PRM_Channel_Program__r.Name = :Label.PRM_Intel_Partner_Alliance];
            
            errMsg+='Line 129 regRList value is--'+regRList+' \n';
            //system.debug('---regRList ' + regRList);
            for (PRM_Registration_Request__c reg : regRList) {errMsg+='Line 131 reg -- '+reg+' \n';
                list<PRM_Registration_Tracker__c> trackerList;
                PRM_Registration_Tracker__c Tracker;
                map<string, PRM_Registration_Tracker__c> trackerMap = new Map<string, PRM_Registration_Tracker__c>();
                //Check registration Type to decide to queryon Registration or contact to get the registration trackers
                if (registrationType != null && registrationType == 'Admin') {
                    errMsg+='Line 137 \n';
                    if (conRegList != null && conRegList.containskey((reg.PRM_Email_ID__c).toLowercase())) {
                        errMsg+='Line 139 \n';
                        trackerList = conRegList.get((reg.PRM_Email_ID__c).toLowercase());
                        Tracker = trackerList[0];}
                } else {
                    errMsg+='Line 143 else \n';
                    if (reg.Registration_Trackers__r.size() > 0) {
                        errMsg+='Line 145 else if \n';
                        trackerList = reg.Registration_Trackers__r;
                        Tracker = reg.Registration_Trackers__r[0];
                    }
                }
                errMsg+='Line 150 trackerList--'+trackerList+'--Tracker--'+Tracker+' \n';
                //create instance of wrapper class
                RegistrationWrapper regWrap = new RegistrationWrapper();
                regWrap.registration = reg;
                string stpNo = '0';
                
                if (trackerList != null && trackerList.size() > 0) {
                    errMsg+='Line 157 \n';
                    for (PRM_Registration_Tracker__c trac : trackerList) {
                        errMsg+='Line 159 \n';
                        trackerMap.put(trac.Stage__c, trac);}
                    stpNo = string.valueof(Tracker.PRM_Current_Step__c);
                    regWrap.registrationTracker = Tracker != null ? Tracker : null;
                    regWrap.regtype = Tracker.PRM_Registration_Type__c;
                }
                errMsg+='Line 165 trackerMap value is--'+trackerMap+'--stpNo value is--'+stpNo+'--regWrap--'+regWrap+' \n';
                //system.debug('---trackerMap ' + trackerMap);
                if (trackerMap != null)regWrap.stageTrackerMap = trackerMap;
                
                if (registrationType != null && registrationType == 'Self') {
                   // system.debug('---Self ');
                    regWrap.Registration_Initiated = reg != null ? true : false;
                    regWrap.regType = 'Self Registration';                    
                }
        errMsg+='Line 174 regWrap--'+regWrap+' \n';
                regWrap.Registration_Submitted = (reg.recordtype.developername =='Account_Create_Request' || reg.recordtype.developername == 'Admin_Registration')? true: false;
                
                regWrap.autoapproved = reg.recordtype.developername =='Admin_Registration'? true: false;
                if (regWrap.Registration_Submitted && registrationType != null && registrationType == 'Self' && regWrap.autoapproved == false
                ) {
                    regWrap.DUP_Check_Pending = (reg.recordtype.developername =='Account_Create_Request' && reg.PRM_DeDup_Criteria__c == 'PENDING')? true: false;
                   
                }
                regWrap.stepNo = stpNo;
                        
                regWrap.Rejected = (reg.PRM_Status__c != null &&reg.PRM_Status__c == 'Rejected')? true: false;
                regWrap.Approved = (reg.PRM_Status__c != null && reg.PRM_Status__c == 'Approved')? true: false;
                errMsg+='Line 187 regWrap--'+regWrap+' \n';
                if (regWrap.Approved) {
                    errMsg+='Line 189 regWrap approved \n';
                    //errMsg+='New Request is Approved: '+regWrap.Approved+'--ID--'+reg.Id+'\n';
                    if (reg.recordtype.developername == 'Account_Create_Request' &&reg.PRM_Auto_Approve__c == true) {
                        errMsg+='Line 192 reg value is--'+reg+' \n';
                        errMsg+='Line 193--'+reg.recordtype.developername+'--val 2 is--'+reg.PRM_Auto_Approve__c+' \n';
                        regWrap.ACR_Yet_to_Assign = true;
                        regWrap.Subscription_Yet_to_Assign = true;
                    }
                    errMsg+='Line 197 regWrap--'+regWrap+' \n';
                    regWrap.Benefit_Yet_to_Assign = true;
                    regWrap.Entitlement_Yet_to_Assign = true;
                    regWrap.Welcome_Email_Yet_to_Send = true;
                    //IPA 2.0 - TWC727-2852
                    regWrap.OPID_Assigned=false;
                    regWrap.Benefit_Entitlement_Yet_to_Assign=true;
                    errMsg+='Line 204 regWrap--'+regWrap+' \n';
                }
                regWrapperList.add(regWrap);
         errMsg+='Line 207 regWrapperList--'+regWrapperList+' \n';
            }
        }
        
        else if (regList == null && contrecordIds != null) { //
           // system.debug('---contrecordIds ' + contrecordIds.size());
           errMsg+='Line 212 inside else if \n';
            ContactIds = contrecordIds;
            //Check EV for Admin
            if (ContactIds.size() > 0)
                mailCheck = checkforEVMailforAdmin(ContactIds);
            List<Contact> conList = new List<Contact>();
            
            conList = [SELECT Id,Email,Core_Enterprise_Id__c,AccountId,(SELECT id,Stage__c,PRM_Current_Step__c,PRM_Step_Number__c,PRM_Registration__c,PRM_Log_Entries__c,PRM_Email__c,PRM_Last_Milestone_DateTime__c,CreatedDate,PRM_AGD_ID_Updated__c,PRM_Registration_Type__c,PRM_Account__c,PRM_contact__c FROM Registration_Contacts__r WHERE PRM_Current_Step__c != NULL AND IsActive__c = true ORDER BY PRM_Step_Number__c DESC),(SELECT id,PRM_Source_Agent__c,PRM_AGS_Response_Status__c,PRM_Status_Nm__c,PRM_InActive_Ind__c,Createddate,PRM_Contact_Id__c FROM Account_Contact_Relationships__r) FROM Contact WHERE Id IN :ContactIds];
            errMsg+='Line 220 conList--'+conList+'--mailCheck--'+mailCheck+' \n';
            for (contact con : conList) {
                string sourceAgent;
                errMsg+='Line 223  \n';
                //create Instance of wrapper
                RegistrationWrapper regWrap = new RegistrationWrapper();
                regWrap.cont = con;
                Integer count = 0;
                map<string, PRM_Registration_Tracker__c> ContrackerMap = new Map<string, PRM_Registration_Tracker__c>();
                if (con.Account_Contact_Relationships__r.size() > 0) {
                    errMsg+='Line 230 ACR>0 -- \n';
                    PRM_Account_Contact_Relationship__c acr = con.Account_Contact_Relationships__r[0];
                    sourceAgent = acr.PRM_Source_Agent__c != null? acr.PRM_Source_Agent__c: null;
                    errMsg+='Line 233 acr is --'+acr+'--sourceAgent--'+sourceAgent+' \n';
                }
                
                if (con.Registration_Contacts__r.size() > 0) {
                    errMsg+='Line 238  \n';
                    for (PRM_Registration_Tracker__c trac : con.Registration_Contacts__r) {
                        errMsg+='Line 240 trac--'+trac+' \n';
                        ContrackerMap.put(trac.Stage__c, trac);
                        if(!'52,53'.contains(trac.Stage__c)){
                            count++;
                        }
                    }
                    errMsg+='Line 246 ContrackerMap--'+ContrackerMap+' \n';
                    errMsg+='Line 247 count is--'+count+' \n';
                    PRM_Registration_Tracker__c conTracker = con.Registration_Contacts__r[0];
                    regWrap.stepNo = string.valueof(conTracker.PRM_Current_Step__c);
                    if (ContrackerMap != null){regWrap.stageTrackerMap = ContrackerMap;}
                    regWrap.registrationTracker = conTracker != null ? conTracker : null;
                    if (retried) {
                        errMsg+='Line 253 retried \n';
                        if ((conTracker.Stage__c != '24' && conTracker.Stage__c != '25') || conTracker.Stage__c == '27') {
                            regWrap.Azure_B2B_ID_Creation_Retried = true;
                            regWrap.Azure_B2B_ID_creation_Retry_Pending = true;
                        }
                    }
                }
                errMsg+='Line 260 regWrap is--'+regWrap+' \n';
                if(count == 0){
                    errMsg+='Line 262 inside if \n';
                    regWrap.stepNo = (sourceAgent != null && sourceAgent == 'Admin Invite')? '01': (sourceAgent != null && sourceAgent == 'Partner Invite')? '02': (sourceAgent != null && sourceAgent == 'External Partner Invite')? '03': (sourceAgent != null &&sourceAgent == 'Bulk Invite')? '04': '00';
                    regWrap.cont = con;
                    regWrap.Admin_Reg_Initiated = regWrap.stepNo == '01' ? true : false;
                    regWrap.Partner_Invite_Initiated = regWrap.stepNo == '02'? true: false;
                    regWrap.External_Partner_Invite_Initiated = regWrap.stepNo == '03'? true: false;
                    regWrap.Bulk_Invite_Initiated = regWrap.stepNo == '04' ? true : false;
                }
                errMsg+='Line 270 regWrap is--'+regWrap+' \n';
                if (con.Account_Contact_Relationships__r.size() > 0) {
                    errMsg+='Line 272 \n';
                    PRM_Account_Contact_Relationship__c acr = con.Account_Contact_Relationships__r[0];
                    if(acr.PRM_Source_Agent__c != 'Self Registration'){
                        errMsg+='Line 275 \n';
                        regWrap.regtype = acr.PRM_Source_Agent__c;
                        regWrap.Azure_B2B_ID_Creation_Successful = acr.PRM_AGS_Response_Status__c =='Success'? true: false;
                        regWrap.Azure_B2B_ID_Creation_Failed = acr.PRM_AGS_Response_Status__c =='Failure'? true: false;
                        regWrap.Azure_B2B_ID_Creation_Pending = (acr.PRM_AGS_Response_Status__c =='Retry' || (string.isblank(acr.PRM_AGS_Response_Status__c) && String.isBlank(con.Core_Enterprise_Id__c)) )? true: false;
                        regWrap.Azure_B2B_ID_creation_Retry_Success = acr.PRM_AGS_Response_Status__c =='Success'? true: false;
                        regWrap.Azure_B2B_ID_creation_Retry_Failure = acr.PRM_AGS_Response_Status__c =='Failure'? true: false;

                        if (!retried){errMsg+='Line 283 \n';
                            regWrap.Azure_B2B_ID_creation_Retry_Pending = (acr.PRM_AGS_Response_Status__c =='Retry' || (string.isblank(acr.PRM_AGS_Response_Status__c) && String.isBlank(con.Core_Enterprise_Id__c)))? true: false;}

                        //if (regWrap.Azure_B2B_ID_Creation_Successful || regWrap.Azure_B2B_ID_creation_Retry_Success) {
                        if (mailCheck.size() > 0 && mailCheck.contains(con.Email)) {
                            errMsg+='Line 288 \n';
                            regWrap.Invite_Sent = true;
                            regWrap.Invite_Pending = true;                          
                        } else {
                            errMsg+='Line 292 \n';
                            regWrap.Invite_UnSent = true;
                        }

                    }
                }
                errMsg+='Line 298 regWrap is--'+regWrap+' \n';
                regWrapperList.add(regWrap);
            }
        }
        errMsg+='Line 298 regWrapperList is--'+regWrapperList+' \n';
        
        //system.debug('---regWrapperList ' + regWrapperList);
        if (regWrapperList.size() > 0){processWrapper(regWrapperList, conRegList);}
        Core_Log_Entry.logEntryWithDetails(origin,project,'PRM_RegistrationTrackerUtility','Info','PRM_RegistrationTrackerUtility - method createRegistrationTracker -  Invoked at' + system.today(),errMsg,'','','');
    }
    
    /************************************************************************************************************************************
Method Name: processWrapper
Description: Iterate teh Wrapper List and process them one by one to upsert Registration Tracker
Return:None
**************************************************************************************************************************************/
    public static void processWrapper(
        list<RegistrationWrapper> wrapList,
        map<string, list<PRM_Registration_Tracker__c>> LinkRegListMap
    ) {
        Set<String> registrationIdSet = new Set<String>();
        list<PRM_Registration_Tracker__c> UpsertRTList = new List<PRM_Registration_Tracker__c>();
        //Iterate wrapper list and process them one by one
        for (RegistrationWrapper regRTwrap : wrapList) {
            PRM_Registration_Request__c RegReq = regRTwrap.registration;
            boolean revise = false;
            string stpNumber;
            PRM_Registration_Tracker__c RegTracker = regRTwrap.registrationTracker !=
                null
                ? regRTwrap.registrationTracker
                : null;
            string wrapSeralized = JSON.serialize(regRTwrap);
            Map<String, Object> WrapperVal = (Map<String, Object>) JSON.deserializeUntyped(
                wrapSeralized
            );            
            UpsertRTList.addall(getnxtstep(regRTwrap, WrapperVal, regRTwrap.stepNo));
        }
        
        //To Link the trackers attached wtih contact to the registration once admin registration submitted
        if (LinkRegListMap != null && LinkRegListMap.size() > 0) {
            for (string keys : LinkRegListMap.keyset()) {
                for (PRM_Registration_Tracker__c rt : LinkRegListMap.get(keys)) {
                   
                    if (emailRegrequetMap != null && emailRegrequetMap.containskey((rt.PRM_Email__c).toLowerCase())) {rt.PRM_Registration__c = emailRegrequetMap.get((rt.PRM_Email__c).toLowerCase());UpsertRTList.add(rt);
                    }
                }
            }
        }

        for(PRM_Registration_Tracker__c regTracker : UpsertRTList){
                if(regTracker.PRM_Registration__c!=null){
                        registrationIdSet.add(regTracker.PRM_Registration__c);
                    }
          }


        Set<String> oldValues = new Set<String>();

        Map<String, Set<String>> reqIdStageMap = new Map<String, Set<String>>();
        for(PRM_Registration_Tracker__c regiTrack : [select PRM_Registration__c, Stage__c,(select OldValue, Parent.PRM_Registration__c  from histories where Field ='Stage__c')  from PRM_Registration_Tracker__c where PRM_Registration__c in :registrationIdSet AND IsActive__c = true]){
            if(!reqIdStageMap.isEmpty() && reqIdStageMap.containsKey(regiTrack.PRM_Registration__c)){
                reqIdStageMap.get(regiTrack.PRM_Registration__c).add(regiTrack.Stage__c);
                if(regiTrack.Histories.size()>0){reqIdStageMap.get(regiTrack.PRM_Registration__c).add(String.valueOf(regiTrack.Histories[0].OldValue));}
            }else{
                reqIdStageMap.put(regiTrack.PRM_Registration__c, new Set<String>{regiTrack.Stage__c});
                 if(regiTrack.Histories.size()>0){reqIdStageMap.get(regiTrack.PRM_Registration__c).add(String.valueOf(regiTrack.Histories[0].OldValue));}
            }
        }

        //System.debug('oldValues -->'+JSON.serialize(oldValues));

        //System.debug('reqIdStageMap -->'+JSON.serialize(reqIdStageMap));

        List<PRM_Registration_Tracker__c> finalListToUpsert = new List<PRM_Registration_Tracker__c>();
        if(UpsertRTList.size()>0){
          for(PRM_Registration_Tracker__c regTracker : UpsertRTList){
                if(!reqIdStageMap.isEmpty() && reqIdStageMap.containsKey(regTracker.PRM_Registration__c)){
                    Set<String> existingStages = reqIdStageMap.get(regTracker.PRM_Registration__c);//.contains(regTracker.Stage__c)
                    if(!existingStages.contains(regTracker.Stage__c)){finalListToUpsert.add(regTracker);}
                }else{
                    finalListToUpsert.add(regTracker);
                }
          }
        }

        //System.debug('finalListToUpsert -->'+JSON.serialize(finalListToUpsert));

        // END DINESH
        //Upsert Registration TRacker
        // Add query to check duplicates
        if (finalListToUpsert.size() > 0 && finalListToUpsert != null)
            Database.upsert(finalListToUpsert, false);
    }
    
    /************************************************************************************************************************************
Method Name: getStagePicklistvalues
Description: To get the picklist value of Stage field from registration Tracker Object
Return:None
**************************************************************************************************************************************/
    public static void getStagePicklistvalues() {
        errMsg+='Line 356- inside getStagePicklistvalues method \n';
        Schema.DescribeFieldResult fieldResult = PRM_Registration_Tracker__c.Stage__c.getDescribe();
        errMsg+='Line 358- fieldResult value is--'+fieldResult+' \n';
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        errMsg+='Line 360- ple value is--'+ple+' \n';
        for (Schema.PicklistEntry f : ple) {
            stageMap.put(f.getValue(), f.getLabel());
        }
        errMsg+='Line 364- stageMap value is--'+stageMap+' \n';
    }
    
    /************************************************************************************************************************************
Method Name: getNxtmetada
Description: To get list of next PRM_Registration_Tracker_Steps__mdt of current step
Return: list<PRM_Registration_Tracker_Steps__mdt>
**************************************************************************************************************************************/
    public static list<PRM_Registration_Tracker_Steps__mdt> getNxtmetada(
        string stepno,
        boolean autoapproved
    ) {
        list<PRM_Registration_Tracker_Steps__mdt> QuerymdtList = new List<PRM_Registration_Tracker_Steps__mdt>();
        string step = '%;' + stepno + ';%';
        //system.debug('---stepno ' + stepno + '--' + step);
        list<PRM_Registration_Tracker_Steps__mdt> mdtList = new List<PRM_Registration_Tracker_Steps__mdt>();
        string quryStr = 'select id,DeveloperName ,PRM_Revise__c,PRM_Revise_Step__c,PRM_Current_Step__c,PRM_Display_Step_No__c,PRM_Update_field__c,PRM_Registration_Type__c,Masterlabel,Label,PRM_Auto_Approved__c,Retry__c from PRM_Registration_Tracker_Steps__mdt where ';
        if (autoapproved != null && autoapproved) {
            //list<string> stepnoss = stepno.split(';');
            quryStr += ' PRM_Auto_Approved__c =true and  ';
        }
        quryStr += ' PRM_Previous_Step__c like:step  order by PRM_Current_Step__c Asc ';
        QuerymdtList = Database.query(quryStr);
        for (PRM_Registration_Tracker_Steps__mdt RT : QuerymdtList) {
            mdtList.add(RT);
        }
       // system.debug('---nextMDTList ' + mdtList.size() + '--' + mdtList);
        return mdtList;
    }
    
    /************************************************************************************************************************************
Method Name: getnxtstep
Description: Process the wrppaer one by one and create/update registration tracker if condition satisfies
Return: list<PRM_Registration_Tracker__c>
**************************************************************************************************************************************/
    
    public static list<PRM_Registration_Tracker__c> getnxtstep(
        RegistrationWrapper wrap,
        Map<String, Object> WrapperValue,
        string currentStep
    ) {
        list<PRM_Registration_Tracker__c> trackerList = new List<PRM_Registration_Tracker__c>();
        //system.debug('---currentStep ' + currentStep);
        boolean dorevise = false;
        boolean nonesatified = true;
  
  
  if (currentStep != null) {
            list<PRM_Registration_Tracker_Steps__mdt> Trackermdt = getNxtmetada(
                currentStep,
                wrap.autoapproved
            );
            if (Trackermdt.size() > 0) {
                for (PRM_Registration_Tracker_Steps__mdt track : Trackermdt) {
                    //system.debug('---developername ' + track.developername);
                    boolean stgCheck = (boolean) WrapperValue.get(track.developername);
                   // system.debug('---stagecheck ' + stgCheck);
                    if (stgCheck != null && stgCheck == true) {
                        getlogentries.errorMessage = getlogentries.errorMessage != null
                            ? getlogentries.errorMessage + ';' + track.developername
                            : track.developername;
                        if (track.PRM_Revise__c && wrap.stageTrackerMap != null && ((track.PRM_Revise_Step__c != null && wrap.stageTrackerMap.containskey(track.PRM_Revise_Step__c) || (track.Retry__c != null && wrap.stageTrackerMap.containskey(track.Retry__c))))) {
                           // system.debug('---existingRecord ');
                            PRM_Registration_Tracker__c tracker1;
                            if (track.Retry__c != null) {tracker1 = wrap.stageTrackerMap.get(track.Retry__c);}
                            if (tracker1 == null){tracker1 = wrap.stageTrackerMap.get(track.PRM_Revise_Step__c);}
                            tracker1.PRM_Step_Number__c = track.PRM_Display_Step_No__c;
                            tracker1.PRM_Current_Step__c = integer.valueof(track.PRM_Current_Step__c);
                            tracker1.Stage__c = track.PRM_Current_Step__c;
                            if (tracker1.PRM_Account__c == null && wrap.AccountId != null){tracker1.PRM_Account__c = wrap.AccountId;}
                            if (tracker1.PRM_contact__c == null && wrap.ContactId != null){tracker1.PRM_contact__c = wrap.ContactId;}
                            if (wrap.LogEntries != null){tracker1.PRM_Log_Entries__c = wrap.LogEntries;}
                            if (wrap.IntegrationLog != null) {id objectId = wrap.IntegrationLog;SobjectType val = objectId.getSobjectType();if (String.valueof(val) == 'PRM_Integration_Log__c') {tracker1.PRM_Integration_Log__c = wrap.IntegrationLog;}}
                            if (wrap.registrationTracker != null && wrap.registrationTracker.Stage__c == '32'){tracker1.PRM_Last_Milestone_DateTime__c = system.now();}
                            else{tracker1.PRM_Last_Milestone_DateTime__c = wrap.registrationTracker.createddate;}
                            if (track.PRM_Update_field__c != null){tracker1.put(track.PRM_Update_field__c, system.now());}
                            trackerList.add(tracker1);
                            nonesatified = false;
                        } else {
                            if (
                                (wrap.stageTrackerMap == null) ||
                                (wrap.stageTrackerMap != null &&
                                 !wrap.stageTrackerMap.containskey(track.PRM_Current_Step__c))
                            ) {
                                PRM_Registration_Tracker__c trackerde = createRegTrackerInstance(
                                    wrap,
                                    wrap.registration,
                                    wrap.cont != null ? wrap.cont : null,
                                    wrap.regType,
                                    track
                                );
                               // system.debug('---NewRecord');
                                //trackerde.PRM_Step_Number__c=displayno;
                                if (wrap.LogEntries != null){trackerde.PRM_Log_Entries__c = wrap.LogEntries;}
                                if (wrap.IntegrationLog != null) {id objectId = wrap.IntegrationLog;SobjectType val = objectId.getSobjectType();if (String.valueof(val) == 'PRM_Integration_Log__c') {trackerde.PRM_Integration_Log__c = wrap.IntegrationLog;}
                                }
                                if (wrap.registrationTracker != null) {
                                    trackerde.PRM_Last_Milestone_DateTime__c = wrap.registrationTracker.createddate;
                                } else {
                                    trackerde.PRM_Last_Milestone_DateTime__c = system.now();
                                }
                                if (track.PRM_Update_field__c != null)
                                    trackerde.put(track.PRM_Update_field__c, system.now());
                                trackerList.add(trackerde);
                                nonesatified = false;
                            }
                        }
                    }
                }
                
                if (nonesatified) {
                    if (stageMap != null && stageMap.containskey(currentStep)) {
                        string ctStagename = stageMap.get(currentStep);
                        string stgname = ctStagename.replace(' ', '_');
                        PRM_Registration_Tracker_Steps__mdt trackmdt = PRM_Registration_Tracker_Steps__mdt.getInstance(
                            stgname
                        );
                        //system.debug('---trackmdt ' + trackmdt);
                        if (trackmdt != null && trackmdt.PRM_Update_field__c != null) {
                            PRM_Registration_Tracker__c trackerupd = wrap.registrationTracker;
                            trackerupd.put(trackmdt.PRM_Update_field__c, system.now());
                            trackerList.add(trackerupd);
                        }
                    }
                }
                //system.debug('---nonesatified ' + nonesatified);
            }
        }
        
       // system.debug('---trackerList ' + trackerList.size() + '--' + trackerList);
        return trackerList;
    }
    
    /************************************************************************************************************************************
Method Name: getRegistrationTracker
Description: to get the list of registration trackers based on contact for admin registration
Return: map<string,list<PRM_Registration_Tracker__c>>
**************************************************************************************************************************************/
    public static map<string, list<PRM_Registration_Tracker__c>> getRegistrationTracker(
        set<String> contatIds
    ) {
        map<string, list<PRM_Registration_Tracker__c>> emailTrackerMap = new Map<string, list<PRM_Registration_Tracker__c>>();
        for (PRM_Registration_Tracker__c track : [
            SELECT
            id,
            PRM_contact__c,
            PRM_Current_Step__c,
            PRM_Step_Number__c,
            PRM_Registration__c,
            PRM_Log_Entries__c,
            PRM_Email__c,
            Stage__c,
            createddate,
            PRM_AGD_ID_Updated__c,
            PRM_Registration_Type__c,
            PRM_Account__c
            FROM PRM_Registration_Tracker__c
            WHERE PRM_contact__c IN :contatIds AND IsActive__c = true
            ORDER BY PRM_Step_Number__c DESC
        ]) {
            //system.debug('---track ' + track);
            if (emailTrackerMap.containskey((track.PRM_Email__c).toLowercase())) {
                List<PRM_Registration_Tracker__c> trList = emailTrackerMap.get(
                    (track.PRM_Email__c).toLowercase()
                );
                trList.add(track);
                emailTrackerMap.put((track.PRM_Email__c).toLowercase(), trList);
            } else {
                emailTrackerMap.put(
                    (track.PRM_Email__c).toLowercase(),
                    new List<PRM_Registration_Tracker__c>{ track }
                );
            }
        }
        return emailTrackerMap;
    }
    
    /************************************************************************************************************************************
Method Name: checkforEVMailforAdmin
Description: To check if EV mailsent for admin reg post acr activated
Return: static set<string>
**************************************************************************************************************************************/
    public static set<string> checkforEVMailforAdmin(set<string> conid) {
        map<string, datetime> acrActivatedMap = new Map<string, datetime>();
        set<string> evSenSet = new Set<string>();
        for (PRM_Account_Contact_Relationship__c acr : [
            SELECT
            Id,
            PRM_Contact_Id__r.Email,
            PRM_Contact_Id__c,
            CreatedDate,
            PRM_Activated_Date__c
            FROM PRM_Account_Contact_Relationship__c
            WHERE PRM_Contact_Id__c IN :conid AND PRM_InActive_Ind__c = FALSE
        ]) {
            if (acr.PRM_Activated_Date__c != null) {
                acrActivatedMap.put(acr.PRM_Contact_Id__r.Email,acr.PRM_Activated_Date__c);
            } else {
                acrActivatedMap.put(acr.PRM_Contact_Id__r.Email, acr.createddate);
            }
        }
        
        //system.debug('---acrActivatedMap ' + acrActivatedMap);
        list<PRM_EmailLog__c> elList = new List<PRM_EmailLog__c>(
            [
                SELECT
                id,
                Email_Template_Name__c,
                lastmodifieddate,
                createddate,
                PRM_Contact__c,
                PRM_Contact__r.Email
                FROM PRM_EmailLog__c
                WHERE
                PRM_Contact__c IN :conid
                AND (Email_Template_Name__c LIKE '%SCRRENGENRLREV%'
                     OR Email_Template_Name__c LIKE '%SCRUACCTADD%'
                     OR Email_Template_Name__c LIKE '%ADMINREG%'
                     OR Email_Template_Name__c LIKE '%CampaignInviteForBulk%')
                order by createddate desc
            ]
        );
        //system.debug('---elList ' + elList.size() + '--' + elList);
        if (elList != null && elList.size() > 0) {
            for (PRM_EmailLog__c el : elList) {
                if (!evSenSet.contains(el.PRM_Contact__r.Email) && el.createddate >= acrActivatedMap.get(el.PRM_Contact__r.Email)) {
                    evSenSet.add(el.PRM_Contact__r.Email);
                }
            }
        }
        return evSenSet;
    }
    
    /************************************************************************************************************************************
Method Name: getLogEntries
Description: To get the log entry once approved
Return: map<string,string>
**************************************************************************************************************************************/
    public static string getLogEntries(string logentry) {
        string logentryName;
        list<string> logids = logentry.split(';');
        for (Core_Log_Entry__c log : [
            SELECT id, Name, Core_Tags__c, createddate
            FROM Core_Log_Entry__c
            WHERE id IN :logids
        ]) {
           // system.debug('---logNmae ' + log.Name);
            logentryName = logentryName != null
                ? logentryName + ';' + log.Name
                : log.Name;
        }
        //system.debug('---logentryName  ' + logentryName);
        
        return logentryName;
    }
    
    public class UpdateTrackerSteps implements Queueable {
        string classname, regType;
        set<string> recordlist = new Set<string>();
        set<string> EmailValue = new Set<String>();
        string intLog;
        public UpdateTrackerSteps(
            set<string> recordList1,
            set<string> EmailValueset,
            string intLog1,
            string classname1,
            string regType1
        ) {
            this.EmailValue = EmailValueset;
            this.recordlist = recordList1;
            this.classname = classname1;
            this.regType = regType1;
            this.intLog = intLog1;
        }
        public void execute(QueueableContext context) {
           // system.debug('---UpdateTrackerSteps  ');
           // system.debug('---classname ' + classname);
            //System.debug('-- email value -->'+this.EmailValue);
            Set<String> emailsIdsSet = new Set<String>();
            for(Contact contact : [select email from contact where id in :this.EmailValue]){
                emailsIdsSet.add(contact.email);
            }
            list<RegistrationWrapper> WrapperList = new List<RegistrationWrapper>();
            //set<string> keyIds = new Set<string>();
            //set<string> eptykeyIds = new Set<string>();
            try {
                //Getting called from API
                if (recordList != null && recordList.size() > 0) {
                    system.debug('---intLog ' + intLog);
                    WrapperList = getregistrationWithTrackers(
                        recordList,
                        classname,
                        regType,
                        intLog
                    );
                } else if (classname == 'PRM_EntitlementUtility') {
                    set<string> regIds = new Set<string>();
                    Map<String,PRM_Registration_Request__c> regReqListMap = new Map<String,PRM_Registration_Request__c>();
                    
                    for(PRM_Registration_Request__c regReq : [SELECT id,PRM_DeDup_Criteria__c,Sync_Profile_Response__c,recordtype.developername,PRM_Auto_Approve__c,PRM_Status__c,PRM_Salesforce_ID__c,PRM_Matching_Contact__c,PRM_Email_Log__c,PRM_Email_ID__c,PRM_Email_Log__r.Email_Template_Name__c FROM PRM_Registration_Request__c WHERE PRM_Email_ID__c IN :emailsIdsSet AND PRM_Channel_Program__r.Name = :Label.PRM_Intel_Partner_Alliance order by lastmodifiedDate desc]){ // AND recordtype.Developername = 'Admin_Registration'
                        if(!regReqListMap.containsKey(regReq.PRM_Email_ID__c)){regReqListMap.put(regReq.PRM_Email_ID__c, regReq);}
                    }
                    
                    for (PRM_Registration_Request__c reg : regReqListMap.values()) {
                        regIds.add(reg.id);
                    }
                    //system.debug('---regIds ' + regIds);
                    if (regIds != null)
                        WrapperList = getregistrationWithTrackers(
                            regIds,
                            classname,
                            regType,
                            intLog
                        );
                }else if(classname =='PRM_SendInviteEmail_Batch'){
                    WrapperList = checkInviteEmail(this.EmailValue);
                }//IPA2.0 TWC727-2852 starts here 
		else if(classname=='PRM_ProcessInboundOPIDRecords'){
                    set<string> regIds = new Set<string>();
                    
                    for(PRM_Registration_Request__c regReq : [SELECT id,PRM_DeDup_Criteria__c,Sync_Profile_Response__c,recordtype.developername,PRM_Auto_Approve__c,PRM_Status__c,PRM_Salesforce_ID__c,PRM_Matching_Contact__c,PRM_Email_Log__c,PRM_Email_ID__c,PRM_Email_Log__r.Email_Template_Name__c FROM PRM_Registration_Request__c WHERE PRM_Salesforce_ID__c IN: this.EmailValue  AND PRM_Channel_Program__r.Name = :Label.PRM_Intel_Partner_Alliance order by lastmodifiedDate desc]){ 
                        regIds.add(regReq.id);
                    }
                    system.debug('---regIds ' + regIds);
                    if (!regIds.isEmpty()){
                        WrapperList = getregistrationWithTrackers(
                            regIds,
                            classname,
                            regType,
                            intLog
                        );
                    }
                }//IPA2.0 TWC727-2852 ends here
		else {
                    getregWithTrackersforGetProfileAPI(EmailValue, intLog, classname);
                }
                //system.debug('---WrapperList ' + WrapperList);
                if (WrapperList.size() > 0){processWrapper(WrapperList, null);}
            } catch (Exception ex) {getlogentries.errorMessage = getlogentries.errorMessage != null? getlogentries.errorMessage + ';' + ex.getmessage(): ex.getmessage();
            } finally {
                if (getlogentries.errorMessage != null)
                    system.debug('---message ' + getlogentries.errorMessage);
                Core_Log_Entry.logEntryWithDetails(
                    origin,
                    project,
                    'PRM_RegistrationTrackerUtility',
                    'Info',
                    'PRM_RegistrationTrackerUtility Invoked at' + system.today(),
                    getlogentries.errorMessage,
                    '',
                    '',
                    ''
                );
            }
        }
    }
    public static void getregWithTrackersforGetProfileAPI(
        set<string> emailid,
        string intelog,
        string classname
    ) {
        list<PRM_Registration_Tracker__c> trackerList = new List<PRM_Registration_Tracker__c>();
        string regType;
        list<PRM_Registration_Request__c> reqList = new List<PRM_Registration_Request__c>();
        datetime lastmilestoneDate;
        getStagePicklistvalues();
        boolean createNewRecord = true;
        PRM_Registration_Request__c registration;
        Contact cont;
        map<string, PRM_Registration_Tracker__c> trackerMap = new Map<string, PRM_Registration_Tracker__c>();
        
        reqList = [
            SELECT
            id,
            (
                SELECT
                id,
                Stage__c,
                PRM_Current_Step__c,
                PRM_Step_Number__c,
                PRM_Registration__c,
                PRM_Log_Entries__c,
                PRM_Email__c,
                PRM_Last_Milestone_DateTime__c,
                PRM_Registration_Type__c,
                CreatedDate,
                PRM_AGD_ID_Updated__c,
                PRM_Account__c,
                PRM_contact__c
                FROM Registration_Trackers__r
                WHERE PRM_Current_Step__c != NULL AND IsActive__c = true
                ORDER BY PRM_Step_Number__c DESC
            ),
            Sync_Profile_Response__c,
            recordtype.developername,
            PRM_Auto_Approve__c,
            PRM_Status__c,
            PRM_Salesforce_ID__c,
            PRM_Matching_Contact__c,
            PRM_Email_Verification_Criteria__c,
            PRM_Email_Log__c,
            PRM_Email_ID__c,
            PRM_Email_Log__r.Email_Template_Name__c
            FROM PRM_Registration_Request__c
            WHERE
            PRM_Email_ID__c IN :emailid
            AND PRM_Status__c = 'New'
            AND PRM_Channel_Program__r.Name = :Label.PRM_Intel_Partner_Alliance
            ORDER BY createddate DESC
            LIMIT 1
        ];        
        PRM_Registration_Tracker_Steps__mdt mdt;
        if (Test.isRunningTest()) {
            mdt = medata;
        } else {
            mdt = [
                SELECT
                PRM_Current_Step__c,
                PRM_Display_Step_No__c,
                PRM_Revise__c,
                PRM_Update_field__c,
                PRM_Classname__c,
                Retry__c
                FROM PRM_Registration_Tracker_Steps__mdt
                WHERE PRM_Classname__c = :classname
                LIMIT 1
            ];
        }
        system.debug('---mdt ' + mdt);
        if (reqList.size() > 0) {
            for (PRM_Registration_Request__c reg : reqList) {
                registration = reg;
                
                if (reg.Registration_Trackers__r.size() > 0) {
                    for (
                        PRM_Registration_Tracker__c tracker : reg.Registration_Trackers__r
                    ) {
                        regType = tracker.PRM_Registration_Type__c;
                        if (lastmilestoneDate == null)
                            lastmilestoneDate = tracker.createddate;
                        trackerMap.put(tracker.Stage__c, tracker);
                    }
                   // system.debug('---trackerMap ' + trackerMap);
                    if (
                        mdt != null && 
                        (mdt.PRM_Current_Step__c   == '6' && reg.recordtype.Name == 'Account Create Request' || mdt.PRM_Current_Step__c != '6') &&
                        trackerMap != null &&
                        trackerMap.containskey(mdt.PRM_Current_Step__c)
                    ) {
                        PRM_Registration_Tracker__c tracker = trackerMap.get(
                            mdt.PRM_Current_Step__c
                        );
                        if (intelog != null) {id objectId = intelog;SobjectType val = objectId.getSobjectType();if (String.valueof(val) == 'PRM_Integration_Log__c') {tracker.PRM_Integration_Log__c = intelog;}
                        }
                        if (mdt.PRM_Update_field__c != null)
                            tracker.put(mdt.PRM_Update_field__c, system.now());
                        trackerList.add(tracker);
                        createNewRecord = false;
                    }
                }
            }
        } else {
            List<Contact> conList = new List<Contact>();
            
            conList = [
                SELECT
                Id,
                Email,
                Core_Enterprise_Id__c,
                AccountId,
                (
                    SELECT
                    id,
                    PRM_Registration_Type__c,
                    Stage__c,
                    PRM_Current_Step__c,
                    PRM_Step_Number__c,
                    PRM_Registration__c,
                    PRM_Log_Entries__c,
                    PRM_Email__c,
                    PRM_Last_Milestone_DateTime__c,
                    CreatedDate,
                    PRM_AGD_ID_Updated__c,
                    PRM_Account__c,
                    PRM_contact__c
                    FROM Registration_Contacts__r
                    WHERE PRM_Current_Step__c != NULL /*and createdDate = today*/ AND IsActive__c = true
                    ORDER BY PRM_Step_Number__c DESC
                ),(
                    SELECT 
                        id,
                        PRM_Source_Agent__c,
                        PRM_AGS_Response_Status__c,
                        PRM_Status_Nm__c,
                        PRM_InActive_Ind__c,
                        Createddate,
                        PRM_Contact_Id__c 
                    FROM Account_Contact_Relationships__r
                )
                FROM Contact
                WHERE email IN :emailid 
            ];
            for (contact con : conList) {
                cont = con;
                if (con.Registration_Contacts__r.size() > 0) {
                    for (
                        PRM_Registration_Tracker__c tracker : con.Registration_Contacts__r
                    ) {
                        if (lastmilestoneDate == null)
                            lastmilestoneDate = tracker.createddate;
                        regType = tracker.PRM_Registration_Type__c;
                        trackerMap.put(tracker.Stage__c, tracker);
                    }
                    //system.debug('---trackerMap ' + trackerMap);
                   // system.debug('---trackerMap ' + mdt.PRM_Current_Step__c);
                    if (
                        mdt != null &&
                        trackerMap != null &&
                        trackerMap.containskey(mdt.PRM_Current_Step__c)
                    ) {
                        PRM_Registration_Tracker__c tracker = trackerMap.get(
                            mdt.PRM_Current_Step__c
                        );
                        if (intelog != null) {id objectId = intelog;SobjectType val = objectId.getSobjectType();if (String.valueof(val) == 'PRM_Integration_Log__c') {tracker.PRM_Integration_Log__c = intelog;}
                        }
                        //system.debug('---updatefield ' + mdt.PRM_Update_field__c);
                        if (mdt.PRM_Update_field__c != null)
                            tracker.put(mdt.PRM_Update_field__c, system.now());
                        trackerList.add(tracker);
                        createNewRecord = false;
                    }
                }else if(con.Account_Contact_Relationships__r.size()>0 && String.isBlank(regType)){
                    regType = con.Account_Contact_Relationships__r[0].PRM_Source_Agent__c;
                }
            }
        }
        
        if (createNewRecord) {
           // system.debug('---registration ' + registration);
           // system.debug('---cont ' + cont);
            PRM_Registration_Tracker__c trackerde = createRegTrackerInstance(
                null,
                registration,
                cont,
                regType,
                mdt
            );
           // system.debug('---elsePart');
            
            if (intelog != null){trackerde.PRM_Integration_Log__c = intelog;}
                trackerde.PRM_Email__c = new List<string>(emailid)[0];
            if (lastmilestoneDate != null){trackerde.PRM_Last_Milestone_DateTime__c = lastmilestoneDate;}
            trackerList.add(trackerde);
            
            //create entry for EV Completed
            if (classname == 'PRM_Account_Contact_Profiles' && (trackerMap != null || (!trackerMap.containskey('5') && !trackerMap.containskey('49')))) {
              PRM_Registration_Tracker__c trackerev = createRegTrackerInstance(
                null,
                registration,
                cont,
                regType,
                null
              );
              if (lastmilestoneDate != null)
                
              if (regType != 'Self Registration') {                
                trackerev.PRM_Last_Milestone_DateTime__c = lastmilestoneDate;trackerev.PRM_Step_Number__c = 4;trackerev.PRM_Current_Step__c = 49;trackerev.Stage__c = '49';         trackerev.PRM_Email__c = trackerde.PRM_Email__c;   
            trackerList.add(trackerev);}              
              //System.debug('trackerev -->'+trackerev);              
            }
        }
        
       // system.debug('---trackerList ' + trackerList);
        // Add query to check duplicates
        if (trackerList.size() > 0){Database.upsert(trackerList, false);}
    }
    
    public static list<RegistrationWrapper> getregistrationWithTrackers(
        set<string> regids,
        string classname,
        string regType,
        string intelog
    ) {
    
    errMsg+='getregistrationWithTrackers called: \n ';
    
        list<PRM_Registration_Request__c> reqList = new List<PRM_Registration_Request__c>();
        //map<string, datetime> mailsapprovedTimeMap = new Map<string, datetime>();
        list<RegistrationWrapper> WrapList = new List<RegistrationWrapper>();
        //map<string, string> LogEntryMap = new Map<string, string>();
        map<string, boolean> ACRcheckMap = new Map<string, boolean>();
        map<string, boolean> SubcheckMap = new Map<string, boolean>();
        //map<string, boolean> BenefitcheckMap = new Map<string, boolean>();
        map<string, boolean> EntitlementcheckMap = new Map<string, boolean>();
        map<string, boolean> batchEntitlementcheckMap = new Map<string, boolean>();//IPA2.0 TWC727-2852
        Map<String,Boolean> opidAssignedCheckMap = new Map<String,Boolean>();//IPA 2.0 TWC727-2852
        map<string, boolean> WelcomeMailcheckMap = new Map<string, boolean>();
        map<string, string> AccountEmailMap = new Map<string, string>();
        map<string, integer> benefitCount = new Map<string, integer>();
        map<string, string> emailAccountMap = new Map<string, string>();
        map<string, string> emailContactMap = new Map<string, string>();
        map<string, list<PRM_Registration_Tracker__c>> emailtrackmapp = new Map<string, list<PRM_Registration_Tracker__c>>();
        list<PRM_Registration_Request__c> updateRegReqList = new List<PRM_Registration_Request__c>();
        set<String> emails = new Set<String>();
        string logentriesName;
        set<string> AccountIds = new Set<string>();
        set<string> opidAccountIds= new Set<string>(); //IPA2.0 TWC727-2852
        getStagePicklistvalues();
       // system.debug('---classname ' + classname);
        //system.debug('---intelog ' + intelog);
        Map<String, PRM_Registration_Request__c> mapEmailToRegTracker = new Map<String, PRM_Registration_Request__c>();
        if (regids != null && regids.size() > 0) {
            
            reqList = [
                SELECT
                id,
                PRM_DeDup_Criteria__c,
                (
                    SELECT
                    id,
                    Stage__c,
                    PRM_Current_Step__c,
                    PRM_Step_Number__c,
                    PRM_Registration__c,
                    PRM_Registration_Type__c,
                    PRM_Log_Entries__c,
                    PRM_Email__c,
                    PRM_Last_Milestone_DateTime__c,
                    CreatedDate,
                    PRM_AGD_ID_Updated__c,
                    PRM_Account__c,
                    PRM_contact__c
                    FROM Registration_Trackers__r
                    WHERE PRM_Current_Step__c != NULL AND IsActive__c = true
                    ORDER BY PRM_Step_Number__c DESC
                ),
                Sync_Profile_Response__c,
                recordtype.developername,
                PRM_Auto_Approve__c,
                PRM_Status__c,
                PRM_Salesforce_ID__c,
                PRM_Salesforce_ID__r.Core_IPA_One_Partner_Id__c,//IPA2.0 TWC727-2852
                PRM_Salesforce_ID__r.Core_IPA_Badge_Tier__c,
                PRM_Matching_Contact__c,
                PRM_Email_Verification_Criteria__c,
                PRM_Email_Log__c,
                PRM_Email_ID__c,
                PRM_Email_Log__r.Email_Template_Name__c,
                createdDate
                FROM PRM_Registration_Request__c
                WHERE
                id IN :regids
                AND PRM_Channel_Program__r.Name = :Label.PRM_Intel_Partner_Alliance
                ORDER BY CreatedDate desc
            ];           
      errMsg+='reqList value is: '+reqList+' \n ';
           // system.debug('---reqList ' + reqList);
            for (PRM_Registration_Request__c regreq : reqList) {
                emails.add(regreq.PRM_Email_ID__c);
                if(!mapEmailToRegTracker.containsKey(regreq.PRM_Email_ID__c)){
                    mapEmailToRegTracker.put(regreq.PRM_Email_ID__c, regreq);
                }
    //IPA2.0 TWC727-2852
                if(/*ipaRefresh &&*/ regreq.PRM_Salesforce_ID__r.Core_IPA_One_Partner_Id__c!=null){
                    opidAssignedCheckMap.put(regreq.PRM_Email_ID__c,true);
                }
            }
            
            if (intelog != null)
                logentriesName = getLogEntries(intelog);
            //system.debug('---logentriesName ' + logentriesName);
        }

        
        for (contact con : [
            SELECT
            Id,
            Email,
            Core_Enterprise_Id__c,
            AccountId,
            Account.Core_IPA_One_Partner_Id__c,//IPA2.0 TWC727-2852
            External_User_State__c,
            (
                SELECT id
                FROM Account_Contact_Relationships__r
                WHERE PRM_Status_Nm__c = 'Complete' AND PRM_InActive_Ind__c = FALSE
                ORDER BY lastmodifiedDate DESC
                LIMIT 1
            ),
            (
                SELECT id
                FROM Contact_Subscription_Associations__r
                WHERE PRM_Status_Nm__c = 'Active'
                ORDER BY lastmodifiedDate DESC
                LIMIT 1
            ),
            (
                SELECT ID
                FROM Batch_Entitlements__r
                WHERE
                PRM_Status_Nm__c = 'Success'
                AND PRM_IsRemove_Ind__c = false AND createddate = LAST_N_DAYS:2 AND (PRM_Entitlement_Id__r.Name!='Employee' AND PRM_Entitlement_Id__r.Name !='Partner Admin') 
            ),//IPA2.0TWC727-2852
            (
                SELECT ID
                FROM Contact_Entitlements__r
                WHERE
                Core_Selected__c = TRUE
                AND Core_Category__c = 'Intel Partner Alliance (IPA)' AND Core_Type__c ='Entitlement' 
            ),
            (
                SELECT ID, createdDate
                FROM EmailLogs__r
                WHERE Email_Template_Name__c LIKE '%SCRREQTOAPVDNEW%' order by createdDate desc
            ),
            (
                SELECT
                id,
                Stage__c,
                PRM_Current_Step__c,
                PRM_Step_Number__c,
                PRM_Registration__c,
                PRM_Registration_Type__c,
                PRM_Log_Entries__c,
                PRM_Email__c,
                PRM_Last_Milestone_DateTime__c,
                CreatedDate,
                PRM_AGD_ID_Updated__c,
                PRM_Account__c,
                PRM_contact__c
                FROM Registration_Contacts__r
                WHERE PRM_Current_Step__c != NULL AND IsActive__c = true
                ORDER BY PRM_Step_Number__c DESC
            )
            FROM Contact
            WHERE email IN :emails
        ]) {
          
            emailAccountMap.put((con.Email).toLOwerCase(), con.AccountID);
            emailContactMap.put(con.Email, con.Id);
      errMsg+='contact value is '+con+' \n ';
            if (con.Account_Contact_Relationships__r.size() > 0){
        errMsg+='INSIDE ACR present: \n ';
        ACRcheckMap.put(con.Email, true);}
            if (con.Contact_Subscription_Associations__r.size() > 0){
        errMsg+='INSIDE CSA present: \n ';
        SubcheckMap.put(con.Email, true);}
            if (con.Contact_Entitlements__r.size() > 0){
        errMsg+='INSIDE CE present: \n ';
        EntitlementcheckMap.put(con.Email, true);}
            if (con.Batch_Entitlements__r.size() > 0){
        errMsg+='INSIDE BE present: \n ';
        batchEntitlementcheckMap.put(con.Email, true);} //IPA2.0 - TWC727-2852
            
            for(PRM_EmailLog__c emaillog: con.EmailLogs__r){
                if(mapEmailToRegTracker.containsKey(con.Email) && mapEmailToRegTracker.get(con.Email).createdDate < emaillog.createdDate){
                    WelcomeMailcheckMap.put(con.Email, true);
                }
            }
            /*if(!ipaRefresh){AccountIds.add(con.AccountId);}*/ // IPA Refresh - switch removal
            /*if(ipaRefresh){*/opidAccountIds.add(con.Account.Core_IPA_One_Partner_Id__c);//}//IPA2.0TWC727-2852
            AccountEmailMap.put(con.email, con.AccountId);
            
            if (con.Registration_Contacts__r != null && con.Registration_Contacts__r.size() > 0) {emailtrackmapp.put(con.email, con.Registration_Contacts__r);}
        }
    
    errMsg+='ACRcheckMap value is '+ACRcheckMap+' \n SubcheckMap value is: '+SubcheckMap+'\n EntitlementcheckMap: '+EntitlementcheckMap+' \n WelcomeMailcheckMap: '+WelcomeMailcheckMap+' \n emailContactMap: '+emailContactMap+' \n ';
    
        //system.debug('---ACRcheckMap ' + ACRcheckMap);
        //system.debug('---SubcheckMap ' + SubcheckMap);
       // system.debug('---EntitlementcheckMap ' + EntitlementcheckMap);
       // system.debug('---WelcomeMailcheckMap ' + WelcomeMailcheckMap);
       // system.debug('---emailContactMap ' + emailContactMap);
      
        /*if (AccountIds.size() > 0 && !ipaRefresh) {
            for (AggregateResult aggRes : [
                SELECT COUNT(ID) numApps, PRM_Account_Id__c accounid
                FROM PRM_AccountBenefitAssociation__c
                WHERE
                PRM_Status_Nm__c = 'Active'
                AND PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance'
                AND PRM_Account_Id__c IN :AccountIds
                GROUP BY PRM_Account_Id__c
            ]) {
                string accId = (string) aggRes.get('accounid');
                Integer numApps = (Integer) aggRes.get('numApps');
                benefitCount.put(accId, numApps);
            }
        }*/ // IPA Refresh - switch rmeoval
   //IPA2.0TWC727-2852 starts here
        if (opidAccountIds.size() > 0 /*&& ipaRefresh*/) {
            for (AggregateResult aggRes : [
                SELECT COUNT(ID) numApps, PRM_Account_Id__c accounid
                FROM PRM_AccountBenefitAssociation__c
                WHERE
                PRM_Status_Nm__c = 'Active'
                AND PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance'
                AND PRM_Account_Id__c IN :opidAccountIds
                GROUP BY PRM_Account_Id__c
            ]) {
                string accId = (string) aggRes.get('accounid');
                Integer numApps = (Integer) aggRes.get('numApps');
                benefitCount.put(accId, numApps);
            }
        }
	 //IPA2.0TWC727-2852
        for (PRM_Registration_Request__c reg : reqList) {
            //create instance of wrapper class
            RegistrationWrapper regWrap = new RegistrationWrapper();
            map<string, PRM_Registration_Tracker__c> trackerMap = new Map<string, PRM_Registration_Tracker__c>();
            regWrap.registration = reg;
            boolean approvalCheck = false;
            PRM_Registration_Tracker__c tracker;
            //regWrap.Approved_with_Error= (reg.recordtype.developername=='Account_Create_Request'  && reg.PRM_Status__c=='New')?true:false;
            
            list<PRM_Registration_Tracker__c> trackerll = new List<PRM_Registration_Tracker__c>();
            if (reg.Registration_Trackers__r.size() > 0) {
                trackerll = reg.Registration_Trackers__r;
            } else if (
                emailtrackmapp != null &&
                emailtrackmapp.containskey(reg.PRM_Email_ID__c)
            ) {
                trackerll = emailtrackmapp.get(reg.PRM_Email_ID__c);
            }
            Boolean isAdminRegInitiated = false;
            if (trackerll.size() > 0) {
                tracker = trackerll[0];
                regWrap.registrationTracker = tracker;
                
                for (PRM_Registration_Tracker__c trackerli : trackerll) {
                    if (
                        trackerli.PRM_Current_Step__c != null &&
                        isAdminRegInitiated == false &&
                        registrationSteps.contains(trackerli.PRM_Current_Step__c)
                    ) {
                        isAdminRegInitiated = true;
                        regType = trackerli.PRM_Registration_Type__c;
                    }
                    trackerMap.put(trackerli.Stage__c, trackerli);
                }
                regWrap.regType = tracker.PRM_Registration_Type__c;
                
                //if(stageMap.containskey(tracker.Stage__c ) && regWrap.stageName==null  )
                //regWrap.stageName=stageMap.get(tracker.Stage__c );
                regWrap.stepNo = string.valueof(tracker.PRM_Current_Step__c);
               // system.debug('---regWrap.stepNo' + regWrap.stepNo);
               // system.debug('---logentriesName ' + logentriesName);
                if (logentriesName != null)
                    regWrap.LogEntries = logentriesName;
                
                //regWrap.Rejected=((reg.recordtype.developername=='Account_Create_Request' || reg.recordtype.developername=='Admin_Registration' ) && reg.PRM_Status__c=='Rejected')?true:false;
                // regWrap.Approved=((reg.recordtype.developername=='Account_Create_Request' || reg.recordtype.developername=='Admin_Registration' ) && reg.PRM_Status__c=='Approved')?true:false;
                regWrap.autoapproved = (reg.recordtype.developername ==
                                        'Admin_Registration')
                    ? true
                    : false;
                if (classname != null && classname == 'PRM_CIMCallout') { //
                    //  - DINESH
          errMsg+='Inside PRM_CIMCallout block: \n ';
                    if (intelog != null)
                        regWrap.IntegrationLog = intelog;
                    //regWrap.Registration_Submitted=(reg.recordtype.developername=='Account_Create_Request' || regWrap.regType=='Admin Invite' )?true:false;
                    if (reg.recordtype.developername == 'Account_Create_Request') {
                        regWrap.DUP_Check_Pending = (reg.recordtype.developername == 'Account_Create_Request' && reg.PRM_DeDup_Criteria__c == 'PENDING')? true: false;
                        regWrap.DUP_Check_Success = (reg.recordtype.developername == 'Account_Create_Request' && reg.PRM_DeDup_Criteria__c != null && reg.PRM_DeDup_Criteria__c == 'SUCCESS')? true : false;
                        regWrap.DUP_Check_Failure = (reg.recordtype.developername =='Account_Create_Request' && reg.PRM_DeDup_Criteria__c != null && reg.PRM_DeDup_Criteria__c == 'FAIL')? true: false;
                        if (reg.PRM_DeDup_Criteria__c != null && reg.PRM_DeDup_Criteria__c != 'NOT PROC' && reg.PRM_DeDup_Criteria__c != 'ERROR')
                            regWrap.Waiting_for_Approval = (reg.recordtype.developername == 'Account_Create_Request' && reg.PRM_Auto_Approve__c == false && reg.PRM_Status__c == 'New')? true: false;
                        if (reg.PRM_Email_Log__c != null && reg.PRM_Email_Log__r.Email_Template_Name__c != null && reg.PRM_Email_Log__r.Email_Template_Name__c.contains('PRM_Registration_Request_Acknowledgement_Email')){regWrap.Ack_Mail_Sent = true;}else{regWrap.Ack_Mail_UnSent = true;}
                    }
                }
                regWrap.AccountId = (emailAccountMap != null &&
                                     emailAccountMap.containskey((reg.PRM_Email_ID__c).toLOwerCase()))
                    ? emailAccountMap.get((reg.PRM_Email_ID__c).toLOwerCase())
                    : null;
                regWrap.ContactId = (emailContactMap != null &&
                                     emailContactMap.containskey(reg.PRM_Email_ID__c))
                    ? emailContactMap.get(reg.PRM_Email_ID__c)
                    : null;
                if (classname != null && classname != 'PRM_CIMCallout') {
                  errMsg+='Inside not PRM_CIMCallout block: \n ';
                    /*if (classname != null && classname == 'PRM_RegReqProcessingQueueable' && !ipaRefresh ) {
                       // system.debug('reg.PRM_Salesforce_ID__r.Core_IPA_Badge_Tier__c'+reg.PRM_Salesforce_ID__r.Core_IPA_Badge_Tier__c);
             errMsg+='Inside PRM_RegReqProcessingQueueable block: \n ';
                        if (benefitCount != null && AccountEmailMap != null && AccountEmailMap.containskey(reg.PRM_Email_ID__c)) {
                            string accID = AccountEmailMap.get(reg.PRM_Email_ID__c);
                            if (benefitCount.containskey(accID) && benefitCount.get(accID) > 0) {regWrap.Benefit_Assigned = true;} else {regWrap.Benefit_Not_Assigned = true;}} else {regWrap.Benefit_Not_Assigned = true;}
                       if (((!ipaRefresh && reg.PRM_Salesforce_ID__r.Core_IPA_Badge_Tier__c=='Member') || (ipaRefresh && reg.PRM_Salesforce_ID__r.Core_IPA_Badge_Tier__c=='Partner')) && regType == 'Self' )  //IPA2.0-TWC727-2914
                        {   if (EntitlementcheckMap != null && EntitlementcheckMap.containskey(reg.PRM_Email_ID__c) && EntitlementcheckMap.get(reg.PRM_Email_ID__c)) {regWrap.Entitlement_Assigned = true;
                             errMsg+='Inside Ent Assigned: '+regWrap.Entitlement_Assigned+'\n';
                            }else {regWrap.Entitlement_Not_Assigned = true;
                                errMsg+='Inside Ent not assigned: '+regWrap.Entitlement_Not_Assigned+'\n';
                            }
                        }
                    }*/ // IPA Refresh - switch removal
                     /*else*/ if (
                        classname != null &&
                        (classname == 'PRM_CreateAccountAndRelatedRecordsAdmin' ||
                         classname == 'PRM_CreateAccountAndRelatedRecords')
                    ) {    
                        errMsg+= '**** inside PRM_CreateAccountAndRelatedRecordsAdmin/PRM_CreateAccountAndRelatedRecords logic ****\n';                 
                        regWrap.AccountId = (emailAccountMap != null && emailAccountMap.containskey(reg.PRM_Email_ID__c))? emailAccountMap.get(reg.PRM_Email_ID__c): null;
                        regWrap.ContactId = (emailContactMap != null && emailContactMap.containskey(reg.PRM_Email_ID__c))? emailContactMap.get(reg.PRM_Email_ID__c): null;
                        //system.debug('---regEmail ' + reg.PRM_Email_ID__c);
                        regWrap.ACR_Assigned = (ACRcheckMap != null && ACRcheckMap.containskey(reg.PRM_Email_ID__c))? true: false;
                        errMsg+= 'regWrap.ACR_Assigned: ' +regWrap.ACR_Assigned+'\n';
                        regWrap.ACR_Not_Assigned = regWrap.ACR_Assigned ? false : true;
                        errMsg+= 'regWrap.ACR_Not_Asigned: '+regWrap.ACR_Not_Assigned+'\n';
                        regWrap.Subscription_Added = (SubcheckMap != null && SubcheckMap.containskey(reg.PRM_Email_ID__c))? true: false;
                        errMsg+= 'Subscrition_Added: '+regWrap.Subscription_Added+'\n';
                        regWrap.Subscription_Not_Added = regWrap.Subscription_Added? false: true;
                        errMsg+='Subscritption_Not_Added: '+regWrap.Subscription_Not_Added+'\n';
                        if (logentriesName != null){regWrap.LogEntries = logentriesName;}
                    }
                    if (classname == 'PRM_EntitlementUtility') {
                        if (EntitlementcheckMap != null &&EntitlementcheckMap.containskey(reg.PRM_Email_ID__c) &&EntitlementcheckMap.get(reg.PRM_Email_ID__c)) {
                            regWrap.Entitlement_Assigned = true;
                            errMsg+='Ent Assigned: '+regWrap.Entitlement_Assigned+'\n';
                        } 
                        else {
                            regWrap.Entitlement_Not_Assigned = true;
                            errMsg+='Ent Not Assigned: '+regWrap.Entitlement_Not_Assigned+'\n';
                        }
      //IPA2.0 TWC727-2852
                        if(/*ipaRefresh &&*/ opidAssignedCheckMap !=null && opidAssignedCheckMap.containsKey(reg.PRM_Email_ID__c) && opidAssignedCheckMap.get(reg.PRM_Email_ID__c)){
                            regWrap.OPID_Assigned = true;
                            errMsg+='Inside OPID_Assigned: '+regWrap.OPID_Assigned+'\n';
                        }
                        else{ regWrap.OPID_Not_Assigned = false;
                                errMsg+='Inside OPID not assigned: '+regWrap.OPID_Not_Assigned+'\n';
                            }
                        if (/*ipaRefresh &&*/ benefitCount != null && benefitCount.containskey(reg.PRM_Salesforce_ID__r.Core_IPA_One_Partner_Id__c) && benefitCount.get(reg.PRM_Salesforce_ID__r.Core_IPA_One_Partner_Id__c) > 0) {
                            regWrap.Benefit_Assigned = true;
                            errMsg+='Inside Benefit_Assigned: '+regWrap.Benefit_Assigned+'\n';
                        } 
                        else {
                            regWrap.Benefit_Not_Assigned = true;
                            errMsg+='Inside Benefit_Not_Assigned: '+regWrap.Benefit_Not_Assigned+'\n';
                        }
                        if(/*ipaRefresh &&*/ batchEntitlementcheckMap!=null && batchEntitlementcheckMap.containskey(reg.PRM_Email_ID__c) && batchEntitlementcheckMap.get(reg.PRM_Email_ID__c)){
                             regWrap.Benefit_Entitlement_Assigned = true;
                             errMsg+='Inside Benefit based Ent assigned: '+regWrap.Benefit_Entitlement_Assigned+'\n';
                            }
                        else{
                            errMsg+='Inside Benefit based ent not asssigned: '+regWrap.Benefit_Entitlement_Not_Assigned+'\n';
                            regWrap.Benefit_Entitlement_Not_Assigned= true;
                        } 
      //IPA2.0 TWC727-2852
                    }
        //IPA2.0 starts here TWC727-2852
                    if(/*ipaRefresh &&*/ classname=='PRM_ProcessInboundOPIDRecords'){
            errMsg+= '**** inside PRM_ProcessInboundOPIDRecords ****\n';
            
                        if(opidAssignedCheckMap !=null && opidAssignedCheckMap.containsKey(reg.PRM_Email_ID__c) && opidAssignedCheckMap.get(reg.PRM_Email_ID__c)){regWrap.OPID_Assigned = true;}else{ regWrap.OPID_Not_Assigned = false;}
                    }//IPA2.0 ends here TWC727-2852
                    if (classname == 'PRM_RegistrationApprovalEmail') {
            errMsg+= '**** inside PRM_RegistrationApprovalEmail ****\n';
            
                        if (WelcomeMailcheckMap != null && WelcomeMailcheckMap.containskey(reg.PRM_Email_ID__c) && WelcomeMailcheckMap.get(reg.PRM_Email_ID__c)) {regWrap.Welcome_Email_Sent = true;
                        } else {regWrap.Welcome_Email_Unsent = true;}
                    }
                    if (regWrap.Welcome_Email_Sent != null &&regWrap.Welcome_Email_Sent == true) {
                        regWrap.User_Yet_to_login = true;reg.PRM_User_Login_History__c = true;updateRegReqList.add(reg);
                    }
                }
            }
            if (trackerMap != null)
                regWrap.stageTrackerMap = trackerMap;
            wrapList.add(regWrap);
        }
        
        if (updateRegReqList.size() > 0) {TriggerHandler.bypass('PRM_RegRequest_TriggerHandler');Database.update(updateRegReqList, false);TriggerHandler.clearbypass('PRM_RegRequest_TriggerHandler');}
        //system.debug('---WrapList ' + WrapList);
        Core_Log_Entry.logEntryWithDetails(origin,project,'PRM_RegistrationTrackerUtility','Info','PRM_RegistrationTrackerUtility Invoked at' + system.today(),errMsg,'','','');
        return WrapList;

    }
    
    @future
    public static void EnQueueTrackerUtility(
        set<string> recIds,
        set<string> emailids,
        string intlog,
        string classname,
        string regType
    ) {
        if ((Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0)) {
            if (classname == 'PRM_AcctContRel_TriggerHandler') {
                system.enqueueJob(new PRM_RegistrationTrackerUtility.createRegistrationTrackerQueuable(null,emailids,false,false));
            } else {
                System.enqueueJob(
                    new PRM_RegistrationTrackerUtility.UpdateTrackerSteps(
                        recIds,
                        emailids,
                        intlog,
                        classname,
                        regType
                    )
                );
            }
        }
    }
    
    public static PRM_Registration_Tracker__c createRegTrackerInstance(
        RegistrationWrapper wrap,
        PRM_Registration_Request__c reg,
        contact con,
        string regtype,
        PRM_Registration_Tracker_Steps__mdt mdt
    ) {
        //system.debug('---regtype ' + regtype);
        PRM_Registration_Tracker__c rt = new PRM_Registration_Tracker__c();
        if (reg != null) {
            rt.PRM_Registration__c = reg.id;
            if (reg.PRM_Salesforce_ID__c != null) {
                rt.PRM_Account__c = reg.PRM_Salesforce_ID__c;
            } else if (wrap != null && wrap.AccountId != null) {rt.PRM_Account__c = wrap.AccountId;}
            if (reg.PRM_Matching_Contact__c != null) {
                rt.PRM_contact__c = reg.PRM_Matching_Contact__c;
            } else if (wrap != null && wrap.ContactId != null) {rt.PRM_contact__c = wrap.ContactId;}
            
            rt.PRM_Email__c = reg.PRM_Email_ID__c;
        }
        if (con != null) {
            rt.PRM_contact__c = con.Id;
            rt.PRM_Email__c = con.Email;
            rt.PRM_Account__c = con.AccountId;
            rt.PRM_Email__c = con.Email;
        }
        if (regtype != null)
            rt.PRM_Registration_Type__c = regtype;
        if (mdt != null) {
            rt.PRM_Step_Number__c = mdt.PRM_Display_Step_No__c;
            rt.PRM_Current_Step__c = integer.valueof(mdt.PRM_Current_Step__c);
            rt.Stage__c = mdt.PRM_Current_Step__c;
        }
        return rt;
    }
    
    public static void CheckUserLoginHistory(
        List<PRM_Registration_Request__c> regList
    ) {
        Map<string, PRM_Registration_Request__c> emailRegMap = new Map<string, PRM_Registration_Request__c>();
        Map<string, datetime> loggedUsrMap = new Map<string, datetime>();
        Map<string, string> UserMap = new Map<string, string>();
        Map<string, PRM_Registration_Tracker__c> emailTrackerMap = new Map<string, PRM_Registration_Tracker__c>();
        list<sobject> upsertObjects = new List<sobject>();
        for (PRM_Registration_Request__c reg : regList) {
            emailRegMap.put(reg.PRM_Email_ID__c, reg);
            if (reg.Registration_Trackers__r.size() > 0) {
                for (PRM_Registration_Tracker__c rt : reg.Registration_Trackers__r) {
                    if (rt.Stage__c == '23' || rt.Stage__c == '52' || rt.Stage__c == '53')
                        emailTrackerMap.put(reg.PRM_Email_ID__c, rt);
                }
            }
        }
        for (user usr : [
            SELECT id, Email
            FROM user
            WHERE email IN :emailRegMap.keyset()
        ]) {
            UserMap.put(usr.id, usr.email);
        }
       // system.debug('---UserMap ' + UserMap);
        string logcdn = '%' + label.PRM_Partner_Portal + '%';
        for (LoginHistory history : [
            SELECT ID, LoginTime, LoginUrl, userid
            FROM LoginHistory
            WHERE LoginUrl LIKE :logcdn AND userid IN :UserMap.keyset()
            ORDER By LoginTime Desc
        ]) {
            if (UserMap.containskey(history.userid)) {
                string emailid = UserMap.get(history.userid);
                if(!loggedUsrMap.containsKey(emailid)){
                    loggedUsrMap.put(emailid, history.LoginTime);
                }
            }
        }
       // system.debug('---loggedUsrMap' + loggedUsrMap);
        
        List<PRM_Registration_Request__c> requestObjList = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Tracker__c> trackerObjList = new List<PRM_Registration_Tracker__c>();
        if (loggedUsrMap != null) {
            for (string st : loggedUsrMap.keyset()) {
                if (emailTrackerMap != null && emailTrackerMap.containskey(st) && emailRegMap.get(st).createdDate <= loggedUsrMap.get(st)) {
                    PRM_Registration_Tracker__c rt = emailTrackerMap.get(st);
                    rt.PRM_User_Loggedin_Time__c = loggedUsrMap.get(st);
                    rt.Stage__c = '22';
                    rt.PRM_Last_Milestone_DateTime__c = loggedUsrMap.get(st);
                    trackerObjList.add(rt);
                    if (emailRegMap.containskey(st)) {
                        PRM_Registration_Request__c regreq = emailRegMap.get(st);
                        regreq.PRM_User_Login_History__c = false;
                        requestObjList.add(regreq);
                    }
                }
            }
        }
        
        upsertObjects.addAll(requestObjList);
        upsertObjects.addAll(trackerObjList);
        


       // system.debug('---upsertObjects ' + upsertObjects);
        // Add query to check duplicates
        if (upsertObjects.size() > 0){Database.upsert(upsertObjects, false);}
    }
    @AuraEnabled
    public static RegistrationWrapper getTrackers(Id regid) {
        RegistrationWrapper wrap = new RegistrationWrapper();

        
        // get email id for registration
        PRM_Registration_Request__c regRequest = [ SELECT PRM_Email_ID__c,Account_ID__c,PRM_Matching_Contact__r.id,PRM_Matching_Contact__r.External_User_State__c, createddate FROM PRM_Registration_Request__c WHERE id = :regid LIMIT 1];
        DateTime createddate = regRequest.createddate-1;
        string wrapSeralized = JSON.serialize(wrap);
        Map<String, Object> WrapperVal = (Map<String, Object>) JSON.deserializeUntyped( wrapSeralized );
        boolean admin;        
        PRM_Registration_Tracker__c regTracker = new PRM_Registration_Tracker__c();
        set<String> existingMilestones = new Set<String>();
        Map<String,PRM_Registration_Tracker__c> missingRegTrackMap = new Map<String,PRM_Registration_Tracker__c>();
        externalState=regRequest.PRM_Matching_Contact__r.External_User_State__c;
        for (PRM_Registration_Tracker__c track : [ SELECT id,PRM_Current_Step__c,PRM_Step_Number__c,PRM_Registration__c,PRM_Log_Entries__c,PRM_Integration_Log__r.PRM_Record_ID__c,PRM_Email__c,toLabel(Stage__c),createddate,PRM_AGD_ID_Updated__c,PRM_Registration_Type__c,PRM_Account__c,PRM_contact__c,PRM_contact__r.External_User_State__c,PRM_Registration__r.PRM_Auto_Approve__c,PRM_Registration__r.recordtype.Name FROM PRM_Registration_Tracker__c WHERE (PRM_Registration__c = :regid OR PRM_Integration_Log__r.PRM_Record_ID__c = :regRequest.PRM_Email_ID__c) ORDER BY PRM_Step_Number__c ASC]) {            //createdDate >=:createddate and
            if(track.PRM_Registration__c==null && track.Stage__c!=null){
                missingRegTrackMap.put(track.Stage__c, track);
                //missingRegIds.add(track);
            }else if(regid == track.PRM_Registration__c && track.Stage__c!=null){
                existingMilestones.add(track.Stage__c);
            }
            //added dinesh
            
            if(track.PRM_Registration__c!=null && track.Stage__c!=null){// && track.PRM_Registration_Type__c !=null
                regTracker = track;

            }            
            string stagename1;
            if(track.Stage__c!=null && track.PRM_Registration__c!= null &&  track.PRM_Registration__c == regid){
                stagename1 = (track.Stage__c).Replace(' ', '_');
                //System.debug('Stage Name -->' + stagename1);
                WrapperVal.put(stagename1, true);
                if (track.PRM_Registration__r.PRM_Auto_Approve__c){WrapperVal.put('autoapproved', true);}
                admin = track.PRM_Registration__r.recordtype.Name == 'Admin Registration'? true: false;
            }
              //new codee... guest redemption complete-lata
            
        }
        List<PRM_Registration_Tracker__c> updateList = new List<PRM_Registration_Tracker__c>();
        //System.debug('externalState1475'+ externalState);
        //System.debug('missingRegTrackMap'+ JSON.serialize(missingRegTrackMap));
        //System.debug('existingMilestones'+ JSON.serialize(existingMilestones));
        for(PRM_Registration_Tracker__c rtr : missingRegTrackMap.values()){
             if(!existingMilestones.contains(rtr.Stage__c) && regTracker!=null){
                // PRM_Registration_Tracker__c rtrecord = new PRM_Registration_Tracker__c();              
                // rtrecord.Id = rtr.Id;
                if(regTracker.PRM_Registration__c!=null){
                    rtr.PRM_Registration__c = regTracker.PRM_Registration__c;
                }
                if(String.isBlank(rtr.PRM_Registration_Type__c)){
                    rtr.PRM_Registration_Type__c = regTracker.PRM_Registration_Type__c!=null?regTracker.PRM_Registration_Type__c:null;
                }
                updateList.add(rtr);
             }
        }

        //added dinesh
        //System.debug('updateList -->'+JSON.serialize(updateList));
        if(updateList.size()>0){
            for(PRM_Registration_Tracker__c rt : updateList){
                if(rt.Stage__c!=null){WrapperVal.put((rt.Stage__c).Replace(' ', '_'),true);}
            }
            update updateList;
        }
        
        if (WrapperVal != null) {
            WrapperVal.put('admin', admin);
            if (WrapperVal.get('Registration_Initiated') == true || WrapperVal.get('Admin_Reg_Initiated') == true || WrapperVal.get('Partner_Invite_Initiated') == true || WrapperVal.get('External_Partner_Invite_Initiated') == true || WrapperVal.get('Bulk_Invite_Initiated') == true) {
                    WrapperVal.put('regInitiated', false);
            } else {
                WrapperVal.put('regInitiated', true);
            }
            
            //system.debug('---regInitiated ' + WrapperVal.get('regInitiated'));
            if (WrapperVal.containskey('autoapproved') && WrapperVal.get('autoapproved') == true && !WrapperVal.containskey('Waiting_for_Approval') ) {
                WrapperVal.put('manulApproval', true);
            } else {
                WrapperVal.put('manulApproval', false);
            }

            if ( WrapperVal.containskey('autoapproved') && WrapperVal.get('autoapproved') == true && !WrapperVal.containskey('Approved')) {
                WrapperVal.put('dupcheck', true);
            } else {
                WrapperVal.put('dupcheck', false);
            }
            if ( WrapperVal.get('Registration_Initiated') != true && (WrapperVal.get('Azure_B2B_ID_Creation_Successful') == true && WrapperVal.get('Azure_B2B_ID_creation_Retry_Success') == true) && (WrapperVal.get('Admin_Reg_Initiated') == true || WrapperVal.get('Partner_Invite_Initiated') == true || WrapperVal.get('External_Partner_Invite_Initiated') == true || WrapperVal.get('Bulk_Invite_Initiated') == true)) {
                WrapperVal.put('agsid', true);
            } else {
                WrapperVal.put('agsid', false);
            }
            
            if ( (WrapperVal.get('Subscription_Added') == true || WrapperVal.get('Subscription_Not_Added') == true)) {
                WrapperVal.put('Subscription_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Subscription_Yet_to_Assign', true);
            }
            if ( WrapperVal.get('ACR_Assigned') == true || WrapperVal.get('ACR_Not_Assigned') == true) {
                WrapperVal.put('ACR_Yet_to_Assign', false);
            } else {
                WrapperVal.put('ACR_Yet_to_Assign', true);
            }
            
            if ( WrapperVal.get('Benefit_Assigned') == true || WrapperVal.get('Benefit_Not_Assigned') == true) {
                WrapperVal.put('Benefit_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Benefit_Yet_to_Assign', true);
            }
            if (WrapperVal.get('Entitlement_Assigned') == true || WrapperVal.get('Entitlement_Not_Assigned') == true) {
                WrapperVal.put('Entitlement_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Entitlement_Yet_to_Assign', true);
            }
            //IPA2.0 NJ
            if (WrapperVal.get('Benefit_Entitlement_Assigned') == true || WrapperVal.get('Benefit_Entitlement_Not_Assigned')==true) {
                WrapperVal.put('Benefit_Entitlement_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Benefit_Entitlement_Yet_to_Assign', true);
            }
            //IPA 2.0
            if (WrapperVal.get('OPID_Assigned') == true) {
                WrapperVal.put('OPID_Assigned', true);
            } else {
                WrapperVal.put('OPID_Assigned', false);
            }
            
            if ( WrapperVal.get('Welcome_Email_Sent') == true || WrapperVal.get('Welcome_Email_Unsent') == true) {
                WrapperVal.put('Welcome_Email_Yet_to_Send', false);
            } else {
                WrapperVal.put('Welcome_Email_Yet_to_Send', true);
            }
              //new codee... guest redemption complete-lata
            if ( WrapperVal.get('Welcome_Email_Sent') == true && externalState=='Accepted'){
                WrapperVal.put('Guest_redemption_complete', true);
                if(!existingMilestones.contains('Guest redemption complete') ){
                    PRM_Registration_Tracker__c rt = new PRM_Registration_Tracker__c();
                    rt.PRM_Email__c = regRequest.PRM_Email_ID__c;
                    rt.PRM_contact__c = regRequest.PRM_Matching_Contact__r.id;
                    rt.PRM_Registration__c = regid;
                    rt.Stage__c = externalState=='Accepted'? '52':'53';
                    rt.PRM_Account__c =  regRequest.Account_ID__c;
                    rt.PRM_Current_Step__c=rt.Stage__c=='52'?52.0:53.0;
                    rt.PRM_Step_Number__c =14.0;
                    updateList.add(rt);
                }
               
            } 
           
           // system.debug('externalState'+externalState);
            system.debug(
                '---Guest_redemption_complete    ' +
                WrapperVal.get('Guest_redemption_complete')
            );
            system.debug(
                '---User Logged into Partner Portal    ' +
                WrapperVal.get('User Logged into Partner Portal')
            );
            if ( WrapperVal.containskey('User_Logged_into_Partner_Portal') != null && WrapperVal.containskey('User_Logged_into_Partner_Portal') == true) {
                WrapperVal.put('User_Yet_to_login', false);
            } else {
                WrapperVal.put('User_Yet_to_login', true);
            }
            if ( WrapperVal.get('Ack_Mail_Sent') != true && WrapperVal.get('Ack_Mail_UnSent') != true) {
                WrapperVal.put('ackmail', true);
            } else {
                WrapperVal.put('ackmail', false);
            }
            
            //System.debug(WrapperVal.get('Guest_redemption_complete'));
            
            if (WrapperVal.get('Guest_redemption_complete') == true) {
                WrapperVal.put('Guest_redemption_complete', true);
            } else{
                WrapperVal.put('Guest_redemption_pending', true);
            }
            
           // system.debug('---WrapperVal' + WrapperVal);
            wrap = (RegistrationWrapper) JSON.deserialize(
                JSON.serialize(WrapperVal),
                RegistrationWrapper.class
            );
        }
    
    errMsg+='End of getTracker method WrapperVal value is: '+WrapperVal+'\n';
    errMsg+='End of getTracker method wrap value is: '+wrap+'\n';
    
        // iterate over false value to see if any records are already created
        if(!updateList.isEmpty()){
            database.upsert(updateList);
        }
    
    Core_Log_Entry.logEntryWithDetails(origin,project,'PRM_RegistrationTrackerUtility','Info','PRM_RegistrationTrackerUtility getTracker method for: ' +regid ,errMsg,'','','');
    
       // system.debug('---wrap ' + wrap);
        return wrap;
    }
    /*******************************************************************************************************
Method Name: RegistrationWrapper
Description: Wrapper class to hold the ouptut of each Step
Return:None
********************************************************************************************************/
    
    public class RegistrationWrapper {
        public PRM_Registration_Request__c registration { get; set; }
        public Contact cont { get; set; }
        public PRM_Registration_Tracker__c registrationTracker { get; set; }
        public string regType { get; set; }
        public string stageName { get; set; }
        public string stepNo { get; set; }
        public string IntegrationLog { get; set; }
        public string previousStepNo { get; set; }
        public string AccountId { get; set; }
        public string ContactId { get; set; }
        @AuraEnabled
        public boolean Admin_Reg_Initiated { get; set; }
        @AuraEnabled
        public boolean GetProfile { get; set; }
        @AuraEnabled
        public boolean SBC_Callout_Made { get; set; }
        @AuraEnabled
        public boolean DUP_Check_Pending { get; set; }
        @AuraEnabled
        public boolean DUP_Check_Success { get; set; }
        @AuraEnabled
        public boolean DUP_Check_Failure { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_Creation_Successful { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_Creation_Failed { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_Creation_Pending { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_Creation_Retried { get; set; }
        @AuraEnabled
        public boolean EV_Sent { get; set; }
        @AuraEnabled
        public boolean EV_UnSent { get; set; }
        @AuraEnabled
        public boolean EV_Pending { get; set; }
        @AuraEnabled
        public boolean EV_Completed { get; set; }
        @AuraEnabled
        public boolean Entitlement_Yet_to_Assign { get; set; }
        @AuraEnabled
        public boolean Welcome_Email_Yet_to_Send { get; set; }
        @AuraEnabled
        public boolean Login_Mail_Sent { get; set; }
        @AuraEnabled
        public boolean Login_Mail_UnSent { get; set; }
        @AuraEnabled
        public boolean Registration_Initiated { get; set; }
        @AuraEnabled
        public boolean Registration_Submitted { get; set; }
        @AuraEnabled
        public boolean Waiting_for_Approval { get; set; }
        @AuraEnabled
        public boolean Approved { get; set; }
        public boolean Approved_with_Error { get; set; }
        public string LogEntries { get; set; }
        @AuraEnabled
        public boolean Rejected { get; set; }
        public boolean sameAPICall { get; set; }
        @AuraEnabled
        public boolean ACR_Assigned { get; set; }
        @AuraEnabled
        public boolean Benefit_Assigned { get; set; }
        @AuraEnabled
        public boolean Entitlement_Assigned { get; set; }
        @AuraEnabled
        public boolean Subscription_Added { get; set; }
        @AuraEnabled
        public boolean ACR_Not_Assigned { get; set; }
        @AuraEnabled
        public boolean Benefit_Not_Assigned { get; set; }
        @AuraEnabled
        public boolean Entitlement_Not_Assigned { get; set; }
        @AuraEnabled
	//IPA2.0 - TWC727-2852
        public boolean Benefit_Entitlement_Assigned { get; set; }
        @AuraEnabled
        public boolean Benefit_Entitlement_Not_Assigned	 { get; set; }
        @AuraEnabled
        public boolean Benefit_Entitlement_Yet_to_Assign { get; set; }
        @AuraEnabled
        public boolean Subscription_Not_Added { get; set; }
        @AuraEnabled
        public boolean Welcome_Email_Sent { get; set; }
        @AuraEnabled
        public boolean Welcome_Email_Unsent { get; set; }
        @AuraEnabled
        public boolean User_Logged_into_Partner_Portal { get; set; }
        @AuraEnabled
        public boolean User_Yet_to_login { get; set; }
        public string FieldToUpdate { get; set; }
        @AuraEnabled
        public boolean ACR_Yet_to_Assign { get; set; }
        @AuraEnabled
        public boolean Subscription_Yet_to_Assign { get; set; }
        @AuraEnabled
        public boolean Benefit_Yet_to_Assign { get; set; }
        public Map<string, PRM_Registration_Tracker__c> stageTrackerMap {get;set;}
        public string classname { get; set; }
        @AuraEnabled
        public boolean autoapproved { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_creation_Retry_Pending { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_creation_Retry_Success { get; set; }
        @AuraEnabled
        public boolean Azure_B2B_ID_creation_Retry_Failure { get; set; }
        @AuraEnabled
        public boolean Partner_Invite_Initiated { get; set; }
        @AuraEnabled
        public boolean External_Partner_Invite_Initiated { get; set; }
        @AuraEnabled
        public boolean Bulk_Invite_Initiated { get; set; }
        @AuraEnabled
        public boolean regInitiated { get; set; }
        @AuraEnabled
        public boolean Invite_UnSent { get; set; }
        @AuraEnabled
        public boolean Invite_Sent { get; set; }
        @AuraEnabled
        public boolean Invite_Pending { get; set; }
        @AuraEnabled
        public boolean Invite_Completed { get; set; }
        @AuraEnabled
        public boolean Ack_Mail_Sent { get; set; }
        @AuraEnabled
        public boolean Ack_Mail_UnSent { get; set; }
        @AuraEnabled
        public boolean dupcheck { get; set; }
        @AuraEnabled
        public boolean manulApproval { get; set; }
        @AuraEnabled
        public boolean agsid { get; set; }
        @AuraEnabled
        public boolean admin { get; set; }
        @AuraEnabled
        public boolean ackmail { get; set; }
        @AuraEnabled
        public boolean Guest_redemption_complete { get; set; }
        @AuraEnabled
        public boolean Guest_redemption_pending { get; set; }
        // IPA 2.0
        @AuraEnabled
        public boolean OPID_Assigned { get; set; }
        @AuraEnabled
        public boolean OPID_Not_Assigned { get; set; }
        
    }
    public static PRM_Registration_Tracker_Steps__mdt getmetadatafortestclass( String classname) {
        return [ SELECT PRM_Current_Step__c, PRM_Display_Step_No__c,PRM_Revise__c,PRM_Update_field__c,PRM_Classname__c,Retry__c FROM PRM_Registration_Tracker_Steps__mdt WHERE PRM_Classname__c = :classname LIMIT 1];
    }    

    /*
    check if invite emails sent this method is writtent to run from invite email batch
    * */
    public static list<RegistrationWrapper> checkInviteEmail(set<String> contrecordIds){        
           list<RegistrationWrapper> regWrapperList = new List<RegistrationWrapper>();
           set<string> mailCheck = new Set<string>();
            //Check EV for Admin
            if (contrecordIds.size() > 0)
                mailCheck = checkforEVMailforAdmin(contrecordIds);
            List<Contact> conList = new List<Contact>();
            
            conList = [SELECT Id,Email,Core_Enterprise_Id__c,AccountId,(SELECT id,Stage__c,PRM_Current_Step__c,PRM_Step_Number__c,PRM_Registration__c,PRM_Log_Entries__c,PRM_Email__c,PRM_Last_Milestone_DateTime__c,CreatedDate,PRM_AGD_ID_Updated__c,PRM_Registration_Type__c,PRM_Account__c,PRM_contact__c FROM Registration_Contacts__r WHERE PRM_Current_Step__c != NULL AND IsActive__c = true ORDER BY PRM_Step_Number__c DESC),(SELECT id,PRM_Source_Agent__c,PRM_AGS_Response_Status__c,PRM_Status_Nm__c,PRM_InActive_Ind__c,Createddate,PRM_Contact_Id__c FROM Account_Contact_Relationships__r) FROM Contact WHERE Id IN :contrecordIds];
            
            for (contact con : conList) {
                string sourceAgent;
                //create Instance of wrapper
                RegistrationWrapper regWrap = new RegistrationWrapper();
                regWrap.cont = con;
                map<string, PRM_Registration_Tracker__c> ContrackerMap = new Map<string, PRM_Registration_Tracker__c>();
                if (con.Account_Contact_Relationships__r.size() > 0) {
                    PRM_Account_Contact_Relationship__c acr = con.Account_Contact_Relationships__r[0];
                    sourceAgent = acr.PRM_Source_Agent__c != null? acr.PRM_Source_Agent__c: null;
                }
                if (con.Registration_Contacts__r.size() > 0) {
                    for (PRM_Registration_Tracker__c trac : con.Registration_Contacts__r) {
                        ContrackerMap.put(trac.Stage__c, trac);
                    }
                    PRM_Registration_Tracker__c conTracker = con.Registration_Contacts__r[0];
                    system.debug('---conTracker ' + conTracker);
                    regWrap.stepNo = string.valueof(conTracker.PRM_Current_Step__c);
                    if (ContrackerMap != null){regWrap.stageTrackerMap = ContrackerMap;}
                    regWrap.registrationTracker = conTracker != null ? conTracker : null;                    
                }
                if (con.Account_Contact_Relationships__r.size() > 0) {
                    PRM_Account_Contact_Relationship__c acr = con.Account_Contact_Relationships__r[0];
                    regWrap.regtype = acr.PRM_Source_Agent__c;                    
                    if ( acr.PRM_Source_Agent__c != 'Self Registration'  && ( acr.PRM_AGS_Response_Status__c =='Success'|| String.isNotBlank(con.Core_Enterprise_Id__c) )) {
                        if (mailCheck.size() > 0 && mailCheck.contains(con.Email)) {
                            regWrap.Invite_Sent = true;                                     
                        } else {
                            regWrap.Invite_UnSent = true;
                        }
                    }
                }
                regWrapperList.add(regWrap);
            }
        return regWrapperList;
    }

}