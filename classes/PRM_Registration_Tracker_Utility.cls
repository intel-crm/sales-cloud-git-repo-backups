/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-04-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PRM_Registration_Tracker_Utility {

   

    String adminRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
    .get('Admin_Registration').getRecordTypeId();
    String selfRecordTypeId = Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName()
    .get('Account_Create_Request').getRecordTypeId();


    public class upsertTrackerSteps implements Queueable{
         List<PRM_Registration_Request__c> regReqList;
    Set<String> setOfEmailIds;    
    PRM_Integration_Log__c intLog;
        String className;
        public upsertTrackerSteps(List<PRM_Registration_Request__c> reqList, Set<String> emailIdSet, String className , PRM_Integration_Log__c log){
            this.regReqList = reqList;
            this.setOfEmailIds = emailIdSet;
            this.className = className;
            this.intLog = log;
            System.debug(' -->'+className);
        }
        public void execute(QueueableContext qc){
            System.debug('Class Name =>'+className);
            // if(className=='PRM_Account_Contact_Profiles'){
            //     System.debug('You are inside execute');
                createTrackerRecords(regReqList, setOfEmailIds,className, intLog);
            // }
        }
    }
     
    public static void createTrackerRecords(List<PRM_Registration_Request__c > listOfReg, set<String> emailIdsLst, String ApexClaasName, PRM_Integration_Log__c log){
        // get all emails ids
        Set<String> emailIds = new Set<String>();
        Map<String, PRM_Registration_Request__c> emailRegReqMap = new Map<String, PRM_Registration_Request__c>();
        if(listOfReg!=null){
            for(PRM_Registration_Request__c request : listOfReg){
                emailRegReqMap.put(request.PRM_Email_ID__c, request);
                emailIds.add(request.PRM_Email_ID__c);
            }
        }else{
            emailIds.addAll(emailIdsLst);
        }    
        // if(!emailRegReqMap.isEmpty()){emailIds.addAll(new List<String>{emailRegReqMap.keySet()});}
        //get registration tracker records for those ids
        Map<String, List<PRM_Registration_Tracker__c> > trackerMap = new Map<String, List<PRM_Registration_Tracker__c>>();
        for(PRM_Registration_Tracker__c tracker : [select Id, Name, PRM_Email__c, PRM_Account__c, PRM_AGD_ID_Updated__c, PRM_CIM_CallOut_for_Dup_Check__c, PRM_contact__c, 
        PRM_Current_Step__c, PRM_Attempted_for_IPA__c, PRM_Integration_Log__c, PRM_Last_Milestone_DateTime__c, PRM_Log_Entries__c, 
        PRM_Registration__c, PRM_Registration_Type__c, PRM_SBC_Callout_Time__c, Stage__c, PRM_Step_Number__c, PRM_Time_Difference__c, PRM_User_Loggedin_Time__c, 
        Registration_Type__c from PRM_Registration_Tracker__c where PRM_Email__c in :emailIds order by PRM_Email__c]){
            if(!trackerMap.isEmpty() && trackerMap.containsKey(tracker.PRM_Email__c)){
                trackerMap.get(tracker.PRM_Email__c).add(tracker);
            }else{
                trackerMap.put(tracker.PRM_Email__c, new List<PRM_Registration_Tracker__c>{tracker});
            }
        }
        // new Request
        Set<String> newEmailId = new Set<String>();
        for(String email : emailIds){
            if(!trackerMap.containsKey(email)){
                newEmailId.add(email);
            }
        }
        //create new registration tracker records
        if(newEmailId.size()>0){
            createNewTrackerRecords(newEmailId, emailRegReqMap,log);
        }
        // update existing tracker records
        if(!trackerMap.isEmpty()){
            updatTrackerRecords(trackerMap);
        }
        

    }

    public static void createNewTrackerRecords(Set<String> newEmailIds, Map<String, PRM_Registration_Request__c> emailRegReqMap, PRM_Integration_Log__c log){
        // get All metadata records
        Map<String, PRM_RegistrationTracker__mdt> trackerMdt = PRM_RegistrationTracker__mdt.getAll();
        // create Registration Tracker records with inactive status and activate only get profile api
        List<PRM_Registration_Tracker__c> trackerRecordsToInsert = new List<PRM_Registration_Tracker__c>();
        PRM_Registration_Tracker__c tracker;
        for(String mileStoneName :trackerMdt.keySet()){
             for(String email : newEmailIds){
            tracker = new PRM_Registration_Tracker__c();
            tracker.PRM_Milestone_Name__c = mileStoneName.replace('_',' ');
            tracker.PRM_Milestone_Active__c = mileStoneName=='GetProfile_API_Called'?true: false;
            tracker.PRM_Email__c = email;
            tracker.PRM_Integration_Log__c = tracker.PRM_Milestone_Active__c && log!=null?log.Id:null;
            tracker.PRM_Last_Milestone_DateTime__c = tracker.PRM_Milestone_Active__c?System.now():null;
            tracker.PRM_Registration__c = !emailRegReqMap.isEmpty() && emailRegReqMap.containsKey(email)?emailRegReqMap.get(email).Id:null;
            tracker.PRM_Record_Stage__c = tracker.PRM_Milestone_Active__c?'Assigned':'Yet To Assign';
            trackerRecordsToInsert.add(tracker);
             }
        }

        if(trackerRecordsToInsert.size()>0){Database.insert(trackerRecordsToInsert, false);}
    }

    public static void updatTrackerRecords(Map<String, List<PRM_Registration_Tracker__c> > trackerMap){
        // check non-processed records [inactive records]
        Map<String, Set<String>> emailIdMilestoneName = new Map<String, Set<String>>();
        Map<String, Map<String,PRM_Registration_Tracker__c>> inactiveRecords =  new Map<String, Map<String,PRM_Registration_Tracker__c>>();
        List<PRM_Registration_Tracker__c> trackerlist = new List<PRM_Registration_Tracker__c>();
        for(List<PRM_Registration_Tracker__c> trackers : trackerMap.values()){
            trackerlist.addAll(trackers);
        }
        for(PRM_Registration_Tracker__c trackerRecord : trackerlist){
            if(!trackerRecord.PRM_Milestone_Active__c || trackerRecord.PRM_Record_Stage__c=='Yet_to_Assign'){
                if(inactiveRecords.containsKey(trackerRecord.PRM_Email__c)){
                    inactiveRecords.get(trackerRecord.PRM_Email__c).put(trackerRecord.PRM_Milestone_Name__c.replace(' ','_'),trackerRecord);
                }else{
                    inactiveRecords.put(trackerRecord.PRM_Email__c, new Map<String,PRM_Registration_Tracker__c>{trackerRecord.PRM_Milestone_Name__c.replace(' ','_')=>trackerRecord});
                }
                // if(emailIdMilestoneName.containsKey(trackerRecord.PRM_Email__c)){
                //     emailIdMilestoneName.get(trackerRecord.PRM_Email__c).add(trackerRecord.PRM_Milestone_Name__c.replace(' ','_'));
                // }else{
                //     emailIdMilestoneName.put(trackerRecord.PRM_Email__c, new Set<String>{trackerRecord.PRM_Milestone_Name__c.replace(' ','_')});
                // }
            }
        }
        
        List<Contact> contactAndRelatedRecrds = new List<Contact>();
        Map<String, Id> accountsMap = new Map<String,Id>();
        List<PRM_Registration_Tracker__c> trackerRecordsToUpdate =  new List<PRM_Registration_Tracker__c>();
        // Contact, ACR 
        for(Contact ct : [SELECT Id,Email,Core_Enterprise_Id__c,AccountId,(SELECT id,PRM_Source_Agent__c,PRM_AGS_Response_Status__c,PRM_Status_Nm__c,PRM_InActive_Ind__c,Createddate,PRM_Contact_Id__c FROM Account_Contact_Relationships__r) FROM Contact WHERE email IN :inactiveRecords.keySet()]){
            accountsMap.put(ct.Email,ct.AccountId);
            if(ct.Account_Contact_Relationships__r.size()>0){

            }
        }
        //Account query
        if(!accountsMap.isEmpty()){
        for (AggregateResult aggRes : [SELECT COUNT(ID) numApps, PRM_Account_Id__c accounid FROM PRM_AccountBenefitAssociation__c WHERE PRM_Status_Nm__c = 'Active' AND PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name = 'Intel Partner Alliance' AND PRM_Account_Id__c IN :accountsMap.values() GROUP BY PRM_Account_Id__c]) {
                string accId = (string) aggRes.get('accounid');
                Integer numApps = (Integer) aggRes.get('numApps');
                //benefitCount.put(accId, numApps);
      }
    }


      
    }
    /*
    public static void getTrackerRecords(){
        System.debug('');
    }
    */
}