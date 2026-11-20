/**
 * @description Batch class to process partner leads count and send notifications
 */
public class Core_PartnerLeads_Count_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    private static final String ADMIN_PUBLIC_GROUP_NAME_SUFFIX = 'Leads';
    private static final List<String> PARTNER_SEGMENT_LIST = new List<String>();
    private static final String USER_TYPE_PREFIX = Schema.SObjectType.User.getKeyPrefix();
    
    // Instance variables to track lead IDs
    private Set<String> generatedLeadIds;
    private Set<String> acceptedLeadIds;
    private Set<String> contactedLeadIds;
    private Set<String> qualifiedLeadIds;
    private Set<String> inPursuitLeadIds;
    private Set<String> rejectedLeadIds;
    private Set<String> dispositionedLeadIds;
    
    // Maps for group and user management
    private Map<String, List<Id>> groupUserMap = new Map<String, List<Id>>();
    private Map<Id, List<String>> groupNameMap = new Map<Id, List<String>>();
    private Map<Id, List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>> notificationMap = 
        new Map<Id, List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>>();

    /**
     * @description Constructor to initialize partner segments
     */
    public Core_PartnerLeads_Count_Batch() {
        setPartnerSegment();
    }

    /**
     * @description Start method for batch processing
     * @param batchContext Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        Set<Id> mpIds = getMpIdsFromAggregateQuery();
        String query = 'SELECT Id from PMP_Company__c where Id IN :mpIds';
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description Execute method for batch processing
     * @param batchContext Database.BatchableContext
     * @param scope List of PMP_Company__c records
     */
    public void execute(Database.BatchableContext batchContext, List<PMP_Company__c> scope){
        Map<Id, List<Lead>> mpidLeadsMap = getLeadMap(scope);
        setMapValues(mpidLeadsMap.keySet());
        
        for(Id mpId : mpidLeadsMap.keySet()){
            processLeadsForMpId(mpId, mpidLeadsMap.get(mpId));
        }   
    }
    
    /**
     * @description Finish method for batch processing
     * @param batchContext Database.BatchableContext
     */
    public void finish(Database.BatchableContext batchContext){
        if(!notificationMap.isEmpty()){
            Core_PartnerLead_status_Notification.sendEmailToUser(notificationMap);
        }
    }

    /**
     * @description Extract MP IDs from aggregate query results
     * @return Set<Id> Set of MP IDs
     */
    private Set<Id> getMpIdsFromAggregateQuery(){
        String aggQuery = 'SELECT Core_MPI_Id__c, count(id) FROM Lead WHERE CreatedDate =THIS_YEAR AND RecordType.Name=\'Partner lead\' AND Core_MPI_Id__c != null GROUP BY Core_MPI_Id__c LIMIT 2000';
        List<AggregateResult> result = Database.query(aggQuery);
        Set<Id> mpIds = new Set<Id>();
        
        for(AggregateResult rslt : result){
            mpIds.add((Id) rslt.get('Core_MPI_Id__c'));
        }
        return mpIds;
    }

    /**
     * @description Process leads for a specific MP ID
     * @param mpId The MP ID to process
     * @param leadList List of leads for the MP ID
     */
    private void processLeadsForMpId(Id mpId, List<Lead> leadList){
        if(leadList.isEmpty()) {
            return;
        }
        
        initializeLeadIdSets();
        categorizeLeads(leadList);
        
        List<Id> userIdsList = getUserIdsForMpId(mpId);
        
        if(shouldSendNotification(userIdsList)){
            createNotificationWrapper(mpId, userIdsList);
        }
    }

    /**
     * @description Initialize all lead ID sets
     */
    private void initializeLeadIdSets(){
        this.generatedLeadIds = new Set<String>();
        this.acceptedLeadIds = new Set<String>();
        this.contactedLeadIds = new Set<String>();
        this.qualifiedLeadIds = new Set<String>();
        this.inPursuitLeadIds = new Set<String>();
        this.rejectedLeadIds = new Set<String>();
        this.dispositionedLeadIds = new Set<String>();
    }

    /**
     * @description Categorize leads into different sets based on status
     * @param leadList List of leads to categorize
     */
    private void categorizeLeads(List<Lead> leadList){
        for(Lead lead : leadList){
            this.generatedLeadIds.add(lead.Id);
            
            if(lead.Core_Partner_Lead_Owner__c != null){
                categorizeLeadWithOwner(lead);
            }
            
            if(isDispositionedLead(lead)){
                this.dispositionedLeadIds.add(lead.Id);
            }
        }
    }

    /**
     * @description Get user IDs for a specific MP ID
     * @param mpId The MP ID
     * @return List<Id> List of user IDs
     */
    private List<Id> getUserIdsForMpId(Id mpId){
        List<String> groupList = this.groupNameMap.get(mpId);
        List<Id> userIdsList = new List<Id>();
        
        if(groupList != null){
            for(String grp : groupList){
                List<Id> members = this.groupUserMap.get(grp);
                if(members != null){
                    userIdsList.addAll(members);
                }
            }
        }
        return userIdsList;
    }

    /**
     * @description Check if notification should be sent
     * @param userIdsList List of user IDs
     * @return Boolean True if notification should be sent
     */
    private Boolean shouldSendNotification(List<Id> userIdsList){
        return !userIdsList.isEmpty() && !this.inPursuitLeadIds.isEmpty();
    }

    /**
     * @description Create notification wrapper for email sending
     * @param mpId The MP ID
     * @param userIdsList List of user IDs
     */
    private void createNotificationWrapper(Id mpId, List<Id> userIdsList){
        Core_PartnerLead_status_Notification.EmailNotificationWrapper wrapper = 
            new Core_PartnerLead_status_Notification.EmailNotificationWrapper(
                userIdsList, this.generatedLeadIds, this.acceptedLeadIds, this.contactedLeadIds, 
                this.qualifiedLeadIds, this.rejectedLeadIds, this.dispositionedLeadIds
            );
        this.notificationMap.put(mpId, new List<Core_PartnerLead_status_Notification.EmailNotificationWrapper>{wrapper});
    }

    /**
     * @description Method to create map of lead record and MPI Ids
     * @param mpCompanies List of PMP_Company__c records
     * @return Map<Id, List<Lead>> Map of MP ID to leads
     */
    private Map<Id, List<Lead>> getLeadMap(List<PMP_Company__c> mpCompanies){
        Set<Id> mpIds = extractMpIds(mpCompanies);
        List<Lead> leads = queryLeads(mpIds);
        return buildLeadMap(leads);
    }

    /**
     * @description Extract MP IDs from PMP_Company__c records
     * @param mpCompanies List of PMP_Company__c records
     * @return Set<Id> Set of MP IDs
     */
    private Set<Id> extractMpIds(List<PMP_Company__c> mpCompanies){
        Set<Id> mpIds = new Set<Id>();
        for(PMP_Company__c mp : mpCompanies){
            mpIds.add(mp.Id);
        }
        return mpIds;
    }

    /**
     * @description Query leads based on MP IDs
     * @param mpIds Set of MP IDs
     * @return List<Lead> List of leads
     */
    private List<Lead> queryLeads(Set<Id> mpIds){
        return [SELECT Id, Core_MPI_Id__c, Core_Lead_Status__c, Status, Core_Partner_Lead_Owner__c, Core_Lead_State__c 
                FROM Lead 
                WHERE CreatedDate = THIS_YEAR 
                AND RecordType.Name = 'Partner lead' 
                AND Core_MPI_Id__c IN :mpIds];
    }

    /**
     * @description Build map of leads grouped by MP ID
     * @param leads List of leads
     * @return Map<Id, List<Lead>> Map of MP ID to leads
     */
    private Map<Id, List<Lead>> buildLeadMap(List<Lead> leads){
        Map<Id, List<Lead>> mpidLeadsMap = new Map<Id, List<Lead>>();
        
        for(Lead lead : leads){
            if(!mpidLeadsMap.containsKey(lead.Core_MPI_Id__c)){
                mpidLeadsMap.put(lead.Core_MPI_Id__c, new List<Lead>());
            }
            mpidLeadsMap.get(lead.Core_MPI_Id__c).add(lead);
        }
        return mpidLeadsMap;
    }

    /**
     * @description Categorize leads that have an owner
     * @param lead The lead to categorize
     */
    private void categorizeLeadWithOwner(Lead lead){
        if(isAcceptedLead(lead)){
            this.acceptedLeadIds.add(lead.Id);
        }
        
        if(isContactedLead(lead)){
            this.contactedLeadIds.add(lead.Id);
        }
        
        if(isQualifiedLead(lead)){
            this.qualifiedLeadIds.add(lead.Id);
        }
        
        if(isInPursuitLead(lead)){
            this.inPursuitLeadIds.add(lead.Id);
        }
        
        if(isRejectedLead(lead)){
            this.rejectedLeadIds.add(lead.Id);
        }
    }

    /**
     * @description Check if lead is accepted
     * @param lead The lead to check
     * @return Boolean True if lead is accepted
     */
    private Boolean isAcceptedLead(Lead lead){
        return 'Accepted'.equalsIgnoreCase(lead.Core_Lead_Status__c) && 'PAL'.equalsIgnoreCase(lead.Status);
    }

    /**
     * @description Check if lead is contacted
     * @param lead The lead to check
     * @return Boolean True if lead is contacted
     */
    private Boolean isContactedLead(Lead lead){
        return 'Contacted'.equalsIgnoreCase(lead.Core_Lead_Status__c) && 'PAL'.equalsIgnoreCase(lead.Status);
    }

    /**
     * @description Check if lead is qualified
     * @param lead The lead to check
     * @return Boolean True if lead is qualified
     */
    private Boolean isQualifiedLead(Lead lead){
        return 'Qualified'.equalsIgnoreCase(lead.Core_Lead_Status__c) && 'PQL'.equalsIgnoreCase(lead.Status);
    }

    /**
     * @description Check if lead is in pursuit
     * @param lead The lead to check
     * @return Boolean True if lead is in pursuit
     */
    private Boolean isInPursuitLead(Lead lead){
        return !'Rejected'.equalsIgnoreCase(lead.Status) && 'In Pursuit'.equalsIgnoreCase(lead.Core_Lead_State__c);
    }

    /**
     * @description Check if lead is rejected
     * @param lead The lead to check
     * @return Boolean True if lead is rejected
     */
    private Boolean isRejectedLead(Lead lead){
        return 'Rejected'.equalsIgnoreCase(lead.Status) && 'Terminated'.equalsIgnoreCase(lead.Core_Lead_State__c);
    }

    /**
     * @description Check if lead is dispositioned
     * @param lead The lead to check
     * @return Boolean True if lead is dispositioned
     */
    private Boolean isDispositionedLead(Lead lead){
        return 'Dispositioned for Partner Lead Pilot'.equalsIgnoreCase(lead.Core_Lead_Status__c);
    }

    /**
     * @description Method to create map for group and group members based on OPMP records and MPIDs
     * @param mpiIds Set of MPI IDs
     */
    private void setMapValues(Set<Id> mpiIds){
        buildGroupNameMap(mpiIds);
        buildGroupUserMap();
    }

    /**
     * @description Build group name map from OPMP records
     * @param mpiIds Set of MPI IDs
     */
    private void buildGroupNameMap(Set<Id> mpiIds){
        List<PMP_OPID_MPI_Rel__c> opmps = [SELECT Id, PMP_One_Partner_ID__c, PMP_Marketing_Profile_Id__c 
                                           FROM PMP_OPID_MPI_Rel__c 
                                           WHERE PMP_Marketing_Profile_Id__c IN :mpiIds];
        
        for(PMP_OPID_MPI_Rel__c opmp : opmps){
            if(!this.groupNameMap.containsKey(opmp.PMP_Marketing_Profile_Id__c)){
                this.groupNameMap.put(opmp.PMP_Marketing_Profile_Id__c, new List<String>());
            }
            this.groupNameMap.get(opmp.PMP_Marketing_Profile_Id__c).addAll(getGroupNameList(opmp));
        }
    }

    /**
     * @description Build group user map from group records
     */
    private void buildGroupUserMap(){
        List<String> masterGroupNameList = getMasterGroupNameList();
        
        if(masterGroupNameList.isEmpty()) {
            return;
        }
        
        List<Group> groupList = [SELECT Id, Name, DeveloperName, (SELECT UserOrGroupId FROM GroupMembers) 
                                 FROM Group 
                                 WHERE DeveloperName IN :masterGroupNameList];
        
        for (Group grp : groupList) {
            List<Id> userIdsList = extractUserIdsFromGroup(grp);
            this.groupUserMap.put(grp.DeveloperName, userIdsList);        
        }
    }

    /**
     * @description Get master list of all group names
     * @return List<String> List of group names
     */
    private List<String> getMasterGroupNameList(){
        List<String> masterGroupNameList = new List<String>();
        
        for (List<String> grpName : this.groupNameMap.values()) {
            masterGroupNameList.addAll(grpName);
        }
        return masterGroupNameList;
    }

    /**
     * @description Extract user IDs from group members
     * @param grp The group to extract users from
     * @return List<Id> List of user IDs
     */
    private List<Id> extractUserIdsFromGroup(Group grp){
        Set<Id> userIds = new Set<Id>();
        
        for (GroupMember gm : grp.GroupMembers) {
            if (String.valueOf(gm.UserOrGroupId).startsWith(USER_TYPE_PREFIX)) {
                userIds.add(gm.UserOrGroupId);
            }
        }
        return new List<Id>(userIds);
    }
    
    /**
     * @description Method to get group name based on PMP_OPID_MPI_Rel__c record
     * @param opmp The OPMP record
     * @return List<String> List of group names
     */
    private List<String> getGroupNameList(PMP_OPID_MPI_Rel__c opmp){
        List<String> groupNameList = new List<String>();
        groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(opmp.PMP_One_Partner_ID__c, ADMIN_PUBLIC_GROUP_NAME_SUFFIX));
        
        for(String segment : PARTNER_SEGMENT_LIST){
            groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(opmp.PMP_One_Partner_ID__c, segment));
        }
        return groupNameList;
    }

    /**
     * @description Initialize partner segment list from picklist values
     */
    private void setPartnerSegment(){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry picklistEntry : values){
            PARTNER_SEGMENT_LIST.add(picklistEntry.getValue());
        }
    }
}