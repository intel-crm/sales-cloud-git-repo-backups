public class PRM_RegistrationTrackerUtility_New {
    private static Map<string, string> stageMap = new Map<string, string>();
    private static map<string, PRM_Registration_Tracker__c> regTrackMap = new Map<string, PRM_Registration_Tracker__c>();
    public static map<string, string> emailRegrequetMap = new Map<string, string>();
    public static Id AdminrecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Admin_Registration').getRecordTypeId();
    public static Id Account_Create_RequestRTId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get('Account_Create_Request').getRecordTypeId();
    public static String origin = 'PRM_RegistrationTrackerUtility_New';
    public static String project = 'IPA';
    public static PRM_Registration_Tracker_Steps_New__mdt RTmetadata;
    public static boolean newacc=false;
    public static Boolean IS_CIDAAS_ENABLED = !Test.isRunningTest()? Boolean.valueof(Label.PRM_CiDaaS_Enabled):true; //As Per CiDaaS Change
/************************************************************************************************************************************
Method Name: createRegistrationTrackerQueuable 
Description: Queueable class which gets called from Prm_regreqTriggerhanler and acr trigger handle in afterinsert and after update
Return:None
**************************************************************************************************************************************/
    public class createRegistrationTrackerQueuable implements Queueable {
        list<PRM_Registration_Request__c> regreqList = new List<PRM_Registration_Request__c>();
        String maxStepAchieved;
        public createRegistrationTrackerQueuable(list<PRM_Registration_Request__c> regLi) {
            this.regreqList = regLi;
            
        }
        public void execute(QueueableContext context) {
            executeMethod(regreqList);
        }
    }
    public static void executeMethod(list<PRM_Registration_Request__c> regreqList) {
        try {
            createRegistrationTrackerNew(regreqList);
        } catch (exception ex) {
            system.debug('---exception ' + ex.getmessage());
            getlogentries.errorMessage = getlogentries.errorMessage != null? getlogentries.errorMessage + ';' + ex.getmessage(): ex.getmessage();
        } finally {
            if (getlogentries.errorMessage != null)
                system.debug('---message ' + getlogentries.errorMessage);
            Core_Log_Entry.logEntryWithDetails(origin,project,'PRM_RegistrationTrackerUtility','Medium','PRM_RegistrationTrackerUtility Invoked at' + system.today(),getlogentries.errorMessage,'','','');
        }
    }
    public static String createRegistrationTrackerNew(list<PRM_Registration_Request__c> regList){
        set<string> regEmailIds = new Set<string>();
        set<string> ContactIds = new Set<string>();
        set<string> regIds = new Set<string>();
        set<string> ContIds = new Set<string>();
        string registrationType;
        String ScenarioReg;
        string milestones;
        //New Registration record is there, so it could be either Self or admin    //based on reg req  we r returning the scenario:    
            //iterate trigger.new to get registration's Id and Email
            for (PRM_Registration_Request__c req : regList) {
                regIds.add(req.Id);
                if (req.recordtypeId == AdminrecordTypeId) {                   
                    registrationType = 'Admin';
                } 
                else  {
                    String MatchingContact=req.PRM_Matching_Contact__c;
                    String ExistingAccountID=req.PRM_Salesforce_ID__c;
                    registrationType = 'Self';//once self u shld identify the scenario?after that create milestones based on the metadata--
                    regEmailIds.add(req.PRM_Email_ID__c);
                    if(IS_CIDAAS_ENABLED){
                        if(String.isBlank(MatchingContact) && String.isBlank(ExistingAccountID)){
                            ScenarioReg='New User New Account';
                        }
                        else if(String.isBlank(MatchingContact) && !String.isBlank(ExistingAccountID)){
                            ScenarioReg='New User Existing Account';
                        }
                        else if(!String.isBlank(MatchingContact) && !String.isBlank(ExistingAccountID)){
                            ScenarioReg='Existing User Existing Account';
                        }
                    }
                }
            }
        
        list<PRM_Registration_Tracker_Steps_New__mdt> QuerymdtList = new List<PRM_Registration_Tracker_Steps_New__mdt>();
       //Map of scenario against the milestones list
        Map<String,String> mapOfScenarioToMilestonelist = new Map<String,String>();
        list<String> stepnos=new list<String>();
        list<PRM_Registration_Tracker_Steps_New__mdt> mdtList = new List<PRM_Registration_Tracker_Steps_New__mdt>();
        //getallmethod
        QuerymdtList = [select id,IS_CIDAAS_ENABLED__c,Step_Number_to_add_milestone__c,Scenario_Name__c from PRM_Registration_Tracker_Steps_New__mdt];              
        //Map<String, PRM_Registration_Tracker_Steps_New__mdt> QuerymdtList = PRM_Registration_Tracker_Steps_New__mdt.getAll();
        for(PRM_Registration_Tracker_Steps_New__mdt mdlst:QuerymdtList){
            if(ScenarioReg==mdlst.Scenario_Name__c){
               mapOfScenarioToMilestonelist.put(mdlst.Scenario_Name__c,mdlst.Step_Number_to_add_milestone__c);           
              milestones=mapOfScenarioToMilestonelist.get(mdlst.Scenario_Name__c);
            }
        }
        return milestones;
        
    }
    //method shld take input param as a number(step number) from PRM_Registration_Tracker_Steps_New__mdt.Step_Number_to_add_milestone__c 
   @AuraEnabled
    public static RegistrationWrapperr getMilestones(Id regid){       
        list<PRM_Registration_Request__c> regRequest = [SELECT PRM_Email_ID__c,PRM_Salesforce_ID__c,PRM_Matching_Contact__c FROM PRM_Registration_Request__c where id=:regid];
        String stepnumbs=createRegistrationTrackerNew(regRequest);
        RegistrationWrapperr wrap = new RegistrationWrapperr();
        string wrapSeralized = JSON.serialize(wrap);
        Map<String, Object> WrapperVal = (Map<String, Object>) JSON.deserializeUntyped(wrapSeralized);
        WrapperVal.put(stepnumbs,true);
        List<PRM_Registration_Tracker__c> updateList = new List<PRM_Registration_Tracker__c>();
        /*for(PRM_Registration_Tracker__c rtr : missingRegTrackMap.values()){
             if(!existingMilestones.contains(rtr.Stage__c)){
            rtr.PRM_Registration__c = regReqId;
            updateList.add(rtr);
             }
        }
        if(updateList.size()>0){update updateList;}*/
        
        if (WrapperVal != null) {            
            if (
                WrapperVal.get('Registration_Initiated') == true ||
                WrapperVal.get('Admin_Reg_Initiated') == true ||
                WrapperVal.get('Partner_Invite_Initiated') == true ||
                WrapperVal.get('External_Partner_Invite_Initiated') == true 
               // || WrapperVal.get('Bulk_Invite_Initiated') == true && triggerclassflag==true
            ) {
                WrapperVal.put('Registration_Initiated', true);
            } else {
                WrapperVal.put('Registration_Initiated', false);
            }            
            system.debug('---regInitiated ' + WrapperVal.get('regInitiated'));
            if (
                WrapperVal.containskey('autoapproved') &&
                WrapperVal.get('autoapproved') == true &&
                !WrapperVal.containskey('Waiting_for_Approval') //&& approvalclassflag==true
            ) {
                WrapperVal.put('Approved', true);
            } else {
                WrapperVal.put('Rejected', true);
            }
            if (
                WrapperVal.containskey('autoapproved') &&
                WrapperVal.get('autoapproved') == true &&
                !WrapperVal.containskey('Approved')
            ) {
                WrapperVal.put('dupcheck', true);
            } else {
                WrapperVal.put('dupcheck', false);
            }
            if (
                WrapperVal.get('Registration_Initiated') != true &&
                (WrapperVal.get('Azure_B2B_ID_Creation_Successful') == true &&
                 WrapperVal.get('Azure_B2B_ID_creation_Retry_Success') == true) &&
                (WrapperVal.get('Admin_Reg_Initiated') == true ||
                 WrapperVal.get('Partner_Invite_Initiated') == true ||
                 WrapperVal.get('External_Partner_Invite_Initiated') == true ||
                 WrapperVal.get('Bulk_Invite_Initiated') == true)
            ) {
                WrapperVal.put('agsid', true);
            } else {
                WrapperVal.put('agsid', false);
            }
            
            if (
                (WrapperVal.get('Subscription_Added') == true ||
                 WrapperVal.get('Subscription_Not_Added') == true)
            ) {
                WrapperVal.put('Subscription_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Subscription_Yet_to_Assign', true);
            }
            if (
                WrapperVal.get('ACR_Assigned') == true ||
                WrapperVal.get('ACR_Not_Assigned') == true
            ) {
                WrapperVal.put('ACR_Yet_to_Assign', false);
            } else {
                WrapperVal.put('ACR_Yet_to_Assign', true);
            }
            
            if (
                WrapperVal.get('Benefit_Assigned') == true ||
                WrapperVal.get('Benefit_Not_Assigned') == true
            ) {
                WrapperVal.put('Benefit_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Benefit_Yet_to_Assign', true);
            }
            if (
                WrapperVal.get('Entitlement_Assigned') == true ||
                WrapperVal.get('Entitlement_Not_Assigned') == true
            ) {
                WrapperVal.put('Entitlement_Yet_to_Assign', false);
            } else {
                WrapperVal.put('Entitlement_Yet_to_Assign', true);
            }
            
            if (
                WrapperVal.get('Welcome_Email_Sent') == true ||
                WrapperVal.get('Welcome_Email_Unsent') == true
            ) {
                WrapperVal.put('Welcome_Email_Yet_to_Send', false);
            } else {
                WrapperVal.put('Welcome_Email_Yet_to_Send', true);
            }
            system.debug(
                '---User Logged into Partner Portal    ' +
                WrapperVal.get('User Logged into Partner Portal')
            );
            if (
                WrapperVal.containskey('User_Logged_into_Partner_Portal') != null &&
                WrapperVal.containskey('User_Logged_into_Partner_Portal') == true
            ) {
                WrapperVal.put('User_Yet_to_login', false);
            } else {
                WrapperVal.put('User_Yet_to_login', true);
            }
            if (
                WrapperVal.get('Ack_Mail_Sent') != true &&
                WrapperVal.get('Ack_Mail_UnSent') != true
            ) {
                WrapperVal.put('ackmail', true);
            } else {
                WrapperVal.put('ackmail', false);
            }
            
            System.debug(WrapperVal.get('Guest_redemption_complete'));
            
            if (WrapperVal.get('Guest_redemption_complete') == true) {
                WrapperVal.put('Guest_redemption_complete', true);
            } else{
                WrapperVal.put('Guest_redemption_pending', true);
            }            
            system.debug('---WrapperVal' + WrapperVal);
            wrap = (RegistrationWrapperr) JSON.deserialize(
                JSON.serialize(WrapperVal),
                RegistrationWrapperr.class
            );
        }
        // iterate over false value to see if any records are already created
        
        system.debug('---wrap ' + wrap);
        return wrap;
    }  

    public static map<String,String> getMilestones(){
        list<PRM_Registration_Tracker_Steps_New__mdt> QuerymdtList = new List<PRM_Registration_Tracker_Steps_New__mdt>();
       //Map of scenario against the milestones list
        Map<String,String> mapOfScenarioToMilestonelist = new Map<String,String>();
        list<String> stepnos=new list<String>();
        list<PRM_Registration_Tracker_Steps_New__mdt> mdtList = new List<PRM_Registration_Tracker_Steps_New__mdt>();
        //getallmethod
        QuerymdtList = [select id,IS_CIDAAS_ENABLED__c,Step_Number_to_add_milestone__c,Scenario_Name__c from PRM_Registration_Tracker_Steps_New__mdt];              
        for(PRM_Registration_Tracker_Steps_New__mdt mdlst:QuerymdtList){
               mapOfScenarioToMilestonelist.put(mdlst.Scenario_Name__c,mdlst.Step_Number_to_add_milestone__c);
                stepnos = mapOfScenarioToMilestonelist.values();            
        }        
        return mapOfScenarioToMilestonelist;        
    }
/***********************************************************************************************************************************
Method Name: getStagePicklistvalues
Description: To get the picklist value of Stage field from registration Tracker Object
Return:None
**************************************************************************************************************************************/
    public static void getStagePicklistvalues() {
        Schema.DescribeFieldResult fieldResult = PRM_Registration_Tracker__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple) {
            stageMap.put(f.getValue(), f.getLabel());
        }
    }
/*Method Name: RegistrationWrapper
Description: Wrapper class to hold the ouptut of each Step
Return:None
********************************************************************************************************/   
    public class RegistrationWrapperr {
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
        public Map<string, PRM_Registration_Tracker__c> stageTrackerMap {
            get;
            set;
        }
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
    }
}