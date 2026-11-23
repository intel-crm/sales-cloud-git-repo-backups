global class Core_PartnerLeads_Count_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    private static String adminPublicGroupNameSuffix = 'Leads';
    private static List<String> partnerSegmentList = new List<String>();
    private static Set<String> generatedLeadIds ;
    private static Set<String> acceptedLeadIds ;
    private static Set<String> contactedLeadIds ;
    private static Set<String> qualifiedLeadIds;
    private static Set<String> inPursuitLeadIds ;
    private static Set<String> rjectedLeadIds;
    private static Set<String> dispositionedLeadIds;
    private static Map<String, List<Id>> groupUserMap =new Map<String, List<Id>>();
    private static Map<Id,List<String>> groupNameMap = new Map<Id,List<String>>();
    private Map<Id, List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>> notificationMap = new Map<Id, List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>>();

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String aggQuery = 'SELECT Core_MPI_Id__c, count(id) FROM Lead WHERE CreatedDate =THIS_YEAR  AND RecordType.Name=\'Partner lead\' AND Core_MPI_Id__c <> null  GROUP BY Core_MPI_Id__c LIMIT 2000';
        List<AggregateResult> result = Database.query(aggQuery);
        Set<Id> mpIds = new Set<Id>();
        for(AggregateResult rslt : result){
            mpIds.add( (Id) rslt.get('Core_MPI_Id__c'));
        }
        String query = 'SELECT Id from PMP_Company__c where Id IN :mpIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PMP_Company__c> scope){
        List<Id> userIdsList;
        Map<Id, List<Lead>> mpidLeadsMap = getLeadMap(scope);
        setMapValues(mpidLeadsMap.keySet());
        for(Id mpId : mpidLeadsMap.keySet()){
            List<lead> leadList = mpidLeadsMap.get(mpId);
            
            if(leadList.size()>0){
                generatedLeadIds = new Set<String>();
                acceptedLeadIds=  new Set<String>();
                contactedLeadIds =  new Set<String>();
                qualifiedLeadIds =  new Set<String>();
                inPursuitLeadIds =  new Set<String>();
                rjectedLeadIds =  new Set<String>();
                dispositionedLeadIds= new set<String>();
                setLeadIdsToRespectiveSets(leadList);
                List<String> groupList = new List<String>();
                groupList = groupNameMap.get(mpId);
                userIdsList = new List<Id>();
                for(String grp : groupList){
                    List<Id> mem = groupUserMap.get(grp) != null ? groupUserMap.get(grp) : new List<Id>() ;
                    userIdsList.addAll(mem);
                }
                
                if(userIdsList.size()>0 && inPursuitLeadIds.size()>0){
                    //Core_PartnerLead_status_Notification.sendEmailToUser(userIdsList,generatedLeadIds,acceptedLeadIds,contactedLeadIds,qualifiedLeadIds,rjectedLeadIds,dispositionedLeadIds);
                    Core_PartnerLead_status_Notification.EmailNotificationWrapper wrapper = new Core_PartnerLead_status_Notification.EmailNotificationWrapper(
                        userIdsList,generatedLeadIds,acceptedLeadIds,contactedLeadIds,qualifiedLeadIds,rjectedLeadIds,dispositionedLeadIds
                    );
                    notificationMap.put(mpId, new List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>{wrapper});
                }
            }
        }   
    }
    
    
    global void finish(Database.BatchableContext BC){
        if(!notificationMap.isEmpty() && notificationMap != null){
            Core_PartnerLead_status_Notification.sendEmailToUser(notificationMap);
        }
    }

    /************************************************************************************************************
    *Method Name : getLeadMap
    *Created Date: 03/05/2024
    *Author: Bishal Singh
    *Description : Method to create map of lead record and MPI Ids.
    ************************************************************************************************************/
    private static Map<Id, List<Lead>> getLeadMap(List<PMP_Company__c> mpids){
        Map<Id, List<Lead>> mpidLeadsMap =new Map<Id, List<Lead>>();
        Set<Id> mpId = new Set<Id>();
        
        for(PMP_Company__c mp : mpids){
            mpId.add(mp.Id);
        }
        
        List<Lead> leads = [SELECT Id,Core_MPI_Id__c,Core_Lead_Status__c,Status,Core_Partner_Lead_Owner__c,Core_Lead_State__c 
                            FROM Lead 
                            WHERE CreatedDate =THIS_YEAR AND RecordType.Name='Partner lead' AND Core_MPI_Id__c IN :mpId];
        
        for(Lead lead: leads){
            if(mpidLeadsMap.containsKey(lead.Core_MPI_Id__c)){
                mpidLeadsMap.get(lead.Core_MPI_Id__c).add(lead);
            }else{
                mpidLeadsMap.put(lead.Core_MPI_Id__c, new List<Lead> {lead});
            }
        }
        return mpidLeadsMap;
    }

    /************************************************************************************************************
    *Method Name : setLeadIdsToRespectiveSets
    *Created Date: 03/05/2024
    *Author: Bishal Singh
    *Description : Method to add lead record to the respective set based on Lead Status & Status Code.
    ************************************************************************************************************/
    private static void setLeadIdsToRespectiveSets(List<Lead> leadList){
        for(Lead ld : leadList){
            generatedLeadIds.add(ld.id);
            if(ld.Core_Partner_Lead_Owner__c <> null){
                if(ld.Core_Lead_Status__c.equalsIgnoreCase('Accepted') && ld.Status.equalsIgnoreCase('PAL')){
                    acceptedLeadIds.add(ld.id);
                }
                if(ld.Core_Lead_Status__c.equalsIgnoreCase('Contacted') && ld.Status.equalsIgnoreCase('PAL')){
                    contactedLeadIds.add(ld.id);
                }
                if(ld.Core_Lead_Status__c.equalsIgnoreCase('Qualified') && ld.Status.equalsIgnoreCase('PQL')){
                    qualifiedLeadIds.add(ld.id);
                }
                if(!ld.Status.equalsIgnoreCase('Rejected') && ld.Core_Lead_State__c.equalsIgnoreCase('In Pursuit')){
                    inPursuitLeadIds.add(ld.id);
                }
                if(ld.Status.equalsIgnoreCase('Rejected') && ld.Core_Lead_State__c.equalsIgnoreCase('Terminated')){
                    rjectedLeadIds.add(ld.id);
                }
            }
            if(ld.Core_Lead_Status__c.equalsIgnoreCase('Dispositioned for Partner Lead Pilot')){
                dispositionedLeadIds.add(ld.id);
            }
        }
    }

    /************************************************************************************************************
    *Method Name : setMapValues
    *Created Date: 03/05/2024
    *Author: Bishal Singh
    *Description : Method to create map for group and group members based on OPMP records and MPIDs.
    ************************************************************************************************************/
    private static void setMapValues(Set<Id> mpiIds){
        String userType = Schema.SObjectType.User.getKeyPrefix();
        setPartnerSegment();
        List<PMP_OPID_MPI_Rel__c> opmps = [SELECT Id,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__c 
                                           FROM PMP_OPID_MPI_Rel__c 
                                           WHERE PMP_Marketing_Profile_Id__c =:mpiIds];
        
        for(PMP_OPID_MPI_Rel__c opmp: opmps){
            if(groupNameMap.containsKey(opmp.PMP_Marketing_Profile_Id__c)){
                groupNameMap.get(opmp.PMP_Marketing_Profile_Id__c).addAll(getGroupNameList(opmp));
            }else{
                groupNameMap.put(opmp.PMP_Marketing_Profile_Id__c, getGroupNameList(opmp));
            }
        }
        
        List<String> masterGroupNameList = new List<String>();
        List<Group> groupList = new List<Group>();
        if (groupNameMap != null) {
            for (List<String> grpName : groupNameMap.values()) {
                masterGroupNameList.addAll(grpName);
            }
        }
        if(!masterGroupNameList.isEmpty()){
            groupList = [SELECT Id, Name, DeveloperName,(SELECT UserOrGroupId FROM GroupMembers) 
                         FROM Group 
                         WHERE DeveloperName IN :masterGroupNameList];
        }
        for (Group grp : groupList) {
            List<Id> userIdsList = new List<Id>();
            List<GroupMember> groupMembers = grp.GroupMembers;
            Set<Id> userIds = new Set<Id>();
            for (GroupMember gm : groupMembers) {
                if (((String)gm.UserOrGroupId).startsWith(userType)) {
                    userIds.add(gm.UserOrGroupId);
                }
            }
            userIdsList.addAll(userIds);
            groupUserMap.put(grp.DeveloperName,userIdsList);        
        }
    }
    
    /************************************************************************************************************
    *Method Name : getGroupNameList
    *Created Date: 03/05/2024
    *Author: Bishal Singh
    *Description : Method to get group name based on list of PMP_OPID_MPI_Rel__c record.
    ************************************************************************************************************/
    private static List<String> getGroupNameList(PMP_OPID_MPI_Rel__c opmp){
        List<String> groupNameList = new List<String>();
        groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(opmp.PMP_One_Partner_ID__c, adminPublicGroupNameSuffix));
        for(String segment : partnerSegmentList){
            groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(opmp.PMP_One_Partner_ID__c, segment));
        }
        return groupNameList;
    }

    /************************************************************************************************************
    *Method Name : setPartnerSegment
    *Created Date: 07/05/2024
    *Author: Bishal Singh
    *Description : Converted global construtor to private method.
    ************************************************************************************************************/
    private static void setPartnerSegment(){
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            partnerSegmentList.add(a.getValue());
        }
    }
}