/**************************************************************************************
Apex Class Name:  Core_PartnerLeadHandler
Version     : 1.0 
Created Date: 06 August 2019
Function    : methods to handle Lead Trigger functions related to partner
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             06/08/2019              Original Version 
* Sougata Sarkar             12/16/2021              OPID Redesign
*************************************************************************************/
public without sharing class Core_PartnerLeadHandler { 
    
    // Fetching "Custom Setting" containing details to trigger switch on/off
    public static Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    //Fetch the lead partner recordtype id
    public static String partnerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
    
    //Setup from email address
    public static String fromEmailAddress = System.Label.Core_SetFromEmailAddress;
    
    //Public group name suffix
    public static String empPublicGroupNameSuffix = 'LeadsOfEmployees';
    public static String adminPublicGroupNameSuffix = 'Leads';
    
    //Ruby team final variables
    public static final String SYMB_SEMICOLON = ';';
    public static final string PSG_LEAD = 'PSG';
    
    //Added by Kavyashree HR (Infosys Team) on 7/21/2020 for the US700424, to avoid recursive call
    Public static Boolean isRecursive=false;
    Public static Boolean isRecursiveGroupCreation=false;
    Public static Boolean isRecursiveOwnerUpdate=false;
    public static Boolean isLeadShared = false;
    public static Boolean isLeadCheckforOPIDStamping = false;
    
    /*
* Method name  : generatePartnerKey
* Description  : Method to create partner key using partner mda id and program segment
* Return Type  : String
* Parameter    : String part1, String part2
*/
    public static String generatePartnerKey(String part1, String part2){
        String groupName = 'PMP_'+part1+'_'+part2.replace(' ', '_');
        return groupName.left(40);
    }
    
    /*
* Method name  : generateNextTimeSlotOfEmail
* Description  : Method to generate next timeslot of individual email notification
* Return Type  : DateTime
* Parameter    : no parameter
*/
    public static DateTime generateNextTimeSlotOfEmail(){
        DateTime CurrentDateTime = System.now();
        DateTime finalDateTime = null;
        if(CurrentDateTime.minute() < 15){
            CurrentDateTime = CurrentDateTime.addMinutes(15 - CurrentDateTime.minute());
            finalDateTime = dateTime.newInstance(CurrentDateTime.year(), CurrentDateTime.month(), CurrentDateTime.day(), CurrentDateTime.hour(), CurrentDateTime.minute(), 00);
        }else if(CurrentDateTime.minute() < 30){
            CurrentDateTime = CurrentDateTime.addMinutes(30 - CurrentDateTime.minute());
            finalDateTime = dateTime.newInstance(CurrentDateTime.year(), CurrentDateTime.month(), CurrentDateTime.day(), CurrentDateTime.hour(), CurrentDateTime.minute(), 00);
        }else if(CurrentDateTime.minute() < 45){
            CurrentDateTime = CurrentDateTime.addMinutes(45 - CurrentDateTime.minute());
            finalDateTime = dateTime.newInstance(CurrentDateTime.year(), CurrentDateTime.month(), CurrentDateTime.day(), CurrentDateTime.hour(), CurrentDateTime.minute(), 00);
        }else if(CurrentDateTime.minute() <= 59){
            CurrentDateTime = CurrentDateTime.addHours(1);
            finalDateTime = dateTime.newInstance(CurrentDateTime.year(), CurrentDateTime.month(), CurrentDateTime.day(), CurrentDateTime.hour(), 00, 00);
        }
        return finalDateTime;
    }
    
    @InvocableMethod(Label='Call Individual Email Batch')
    public static void callIndividualEmailBatch(List<List<Lead>> leads){
        
        Database.executeBatch(new Core_PartnerLead_IndividualEmail_Batch(leads[0]));
    }
    
    /*
* Method name  : populateSegmentMpiInPartnerLeads
* Description  : Method to populate MPI id and partner segment in Lead
* Return Type  : void
* Parameter    : List<Lead> newLeads, Boolean isInsert
*/
public static void populateSegmentMpiInPartnerLeads(List<Lead> newLeads, Boolean isInsert){
    List<Lead> finalLeadList = new List<Lead>();
    Map<String,List<Lead>> marketingProfileLeadsMap = new Map<String,List<Lead>>();
    Map<String,List<Lead>> partnerNameLeadsMap = new Map<String,List<Lead>>();
    Map<String, PMP_Company__c> marketingProfileMap = new Map<String, PMP_Company__c>();

    // Temporary workaround for ProcessLeadsCtx compilation issue
    SWS_LeadWrappers.ProcessLeadsCtx procCtx = new SWS_LeadWrappers.ProcessLeadsCtx();
    procCtx.finalLeadList = finalLeadList;
    procCtx.marketingProfileLeadsMap = marketingProfileLeadsMap;
    procCtx.partnerNameLeadsMap = partnerNameLeadsMap;
    processLeads(newLeads, procCtx);
    // rebind local vars in case maps were reassigned in ctx
    finalLeadList = procCtx.finalLeadList;
    marketingProfileLeadsMap = procCtx.marketingProfileLeadsMap;
    partnerNameLeadsMap = procCtx.partnerNameLeadsMap;

    if(!partnerNameLeadsMap.isEmpty()){
        processPartnerNameLeads(partnerNameLeadsMap);
    }
    
    if(!marketingProfileLeadsMap.isEmpty()){
        processMarketingProfileLeads(marketingProfileLeadsMap, marketingProfileMap);
    }
    
    if(!isInsert && !finalLeadList.isEmpty()){
        populateGroupsToRoutePartnerLead(finalLeadList);
    }
  }

    // Parameter-bag to reduce parameter list for processLeads
    // Moved to SWS_LeadWrappers.ProcessLeadsCtx

    private static void processLeads (List<Lead> newLeads, SWS_LeadWrappers.ProcessLeadsCtx ctx){
        for(Lead led : newLeads){
            if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c <> null){
                ctx.marketingProfileLeadsMap = generateGroupsNLeadsMap(led, led.PMP_MDA_BizOrg_Id__c, ctx.marketingProfileLeadsMap);
                ctx.finalLeadList.add(led);
            }else if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c == null && led.Core_Partner_Name__c <> null){
                ctx.partnerNameLeadsMap = generateGroupsNLeadsMap(led, led.Core_Partner_Name__c.toLowerCase(), ctx.partnerNameLeadsMap);
                ctx.finalLeadList.add(led);
            }else if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c == null && led.Core_Partner_Name__c == null){
                assignLeadSharingError(led, system.label.Core_No_PartnerId_PartnerName);
            }
        }
    }

    private static void processPartnerNameLeads(Map<String,List<Lead>> partnerNameLeadsMap){
        Map<String,Core_Partner_Queue_Mapping__c> partnerNameNQueueMap = new Map<String,Core_Partner_Queue_Mapping__c>();
        Map<String,Set<Lead>> OPIDLeadSetMap = new Map<String,Set<Lead>>();
        Map<String, String> OPIDPartnerNameFromQueueMapping = new Map<String, String>();
        Set<String> availableOPIDFromOPIDMPIJunction = new Set<String>();
        Set<Lead> tempSet;
        String partnerRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c.getRecordTypeInfosByName().get(Label.Core_Partner_Queue_Mapping_RecordTypeId).getRecordTypeId();

        List<Core_Partner_Queue_Mapping__c> partnerQueueMappingList = [select Id, Core_Partner_Name__c, PMP_MDA_BizOrg_Id__c from Core_Partner_Queue_Mapping__c where Core_Partner_Name__c IN: partnerNameLeadsMap.keySet() AND Core_Active__c = true AND RecordTypeId=: partnerRecTypeId];
        for(Core_Partner_Queue_Mapping__c pqm : partnerQueueMappingList){
            if(pqm.PMP_MDA_BizOrg_Id__c <> null){
                tempSet = OPIDLeadSetMap.containsKey(pqm.PMP_MDA_BizOrg_Id__c) ? OPIDLeadSetMap.get(pqm.PMP_MDA_BizOrg_Id__c) : new Set<Lead>();
                tempSet.addAll(partnerNameLeadsMap.get(pqm.Core_Partner_Name__c.toLowerCase()));
                OPIDLeadSetMap.put(pqm.PMP_MDA_BizOrg_Id__c, tempSet);
                OPIDPartnerNameFromQueueMapping.put(pqm.PMP_MDA_BizOrg_Id__c, pqm.Core_Partner_Name__c.toLowerCase());
            }
            partnerNameNQueueMap.put(pqm.Core_Partner_Name__c.toLowerCase(),pqm);
        }
        
        // Build ctx for assignMPIToLeads to reduce parameter list
        SWS_LeadWrappers.AssignMpiCtx assignCtx = new SWS_LeadWrappers.AssignMpiCtx();
        assignCtx.opidLeadSetMap = OPIDLeadSetMap;
        assignCtx.opidPartnerNameFromQueueMapping = OPIDPartnerNameFromQueueMapping;
        assignCtx.partnerNameLeadsMap = partnerNameLeadsMap;
        assignCtx.partnerNameQueueMap = partnerNameNQueueMap;
        assignCtx.availableOpidFromMpiJunction = availableOPIDFromOPIDMPIJunction;
        assignMPIToLeads(assignCtx);
    }

    private static void processMarketingProfileLeads(Map<String, List<Lead>> marketingProfileLeadsMap, Map<String, PMP_Company__c> marketingProfileMap) {
        Set<String> mpiIdSet = new Set<String>();
        List<PMP_OPID_MPI_Rel__c> OMRList = fetchActiveMPIRelationships(marketingProfileLeadsMap.keySet());

        updateLeadsWithMPI(OMRList, marketingProfileLeadsMap, mpiIdSet);

        if (OMRList.isEmpty()) {
            populateMarketingProfileMap(marketingProfileMap, marketingProfileLeadsMap.keySet());
        }

        updateLeadsWithoutMPI(mpiIdSet, marketingProfileLeadsMap, marketingProfileMap);
    }

    private static List<PMP_OPID_MPI_Rel__c> fetchActiveMPIRelationships(Set<String> marketingProfileIds) {
        return [SELECT Id, PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c, PMP_Marketing_Profile_Id__r.Name,Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, Is_Active__c FROM PMP_OPID_MPI_Rel__c WHERE Core_Marketing_Profile_Id__c IN :marketingProfileIds AND PMP_One_Partner_ID__c != null AND Is_Active__c = true ];
    }

    private static void updateLeadsWithMPI(List<PMP_OPID_MPI_Rel__c> OMRList, Map<String, List<Lead>> marketingProfileLeadsMap, Set<String> mpiIdSet) {
        for (PMP_OPID_MPI_Rel__c omr : OMRList) {
            mpiIdSet.add(omr.Core_Marketing_Profile_Id__c);
            List<Lead> leadsToUpdate = marketingProfileLeadsMap.get(omr.Core_Marketing_Profile_Id__c);
            if (leadsToUpdate != null) {
                for (Lead led : leadsToUpdate) {
                    led.Core_MPI_Id__c = omr.PMP_Marketing_Profile_Id__c;
                    led.Core_Partner_Name__c = omr.PMP_Marketing_Profile_Id__r.Name;
                    led.Core_Storefront_Name__c = omr.PMP_Marketing_Profile_Id__r.Name;
                }
            }
        }
    }

    private static void populateMarketingProfileMap(Map<String, PMP_Company__c> marketingProfileMap, Set<String> marketingProfileIds) {
        List<PMP_Company__c> marketingProfileList = [ SELECT Id, Name, PMP_Marketing_Profile_Id__c FROM PMP_Company__c WHERE PMP_Marketing_Profile_Id__c IN :marketingProfileIds];
        for (PMP_Company__c profile : marketingProfileList) {
            marketingProfileMap.put(profile.PMP_Marketing_Profile_Id__c, profile);
        }
    }

    private static void updateLeadsWithoutMPI(
        Set<String> mpiIdSet,
        Map<String, List<Lead>> marketingProfileLeadsMap,
        Map<String, PMP_Company__c> marketingProfileMap
    ) {
        for (String mpiId : marketingProfileLeadsMap.keySet()) {
            if (!mpiIdSet.contains(mpiId)) {
                updateLeadsForMpiId(mpiId, marketingProfileLeadsMap, marketingProfileMap);
            }
        }
    }

    private static void updateLeadsForMpiId(String mpiId, Map<String, List<Lead>> marketingProfileLeadsMap, Map<String, PMP_Company__c> marketingProfileMap) 
    {
        List<Lead> leadsToUpdate = marketingProfileLeadsMap.get(mpiId);
        if (leadsToUpdate == null) { return; }

        for (Lead led : leadsToUpdate) {
            if (marketingProfileMap.containsKey(led.PMP_MDA_BizOrg_Id__c)) {
                PMP_Company__c profile = marketingProfileMap.get(led.PMP_MDA_BizOrg_Id__c);
                led.Core_MPI_Id__c = profile.Id;
                led.Core_Partner_Name__c = profile.Name;
                led.Core_Storefront_Name__c = profile.Name;
            }
            assignLeadSharingError(led, System.Label.Core_NoMPIRecords);
        }
    }


    // Parameter-bag and refactor to reduce parameter list and fix naming
    // Moved to SWS_LeadWrappers.AssignMpiCtx

    private static void assignMPIToLeads(SWS_LeadWrappers.AssignMpiCtx ctx) {
        List<PMP_OPID_MPI_Rel__c> OMRList = fetchActiveOPIDMPIRelationships(ctx.opidLeadSetMap.keySet());

        updateLeadsWithMPI(OMRList, ctx.opidLeadSetMap, ctx.availableOpidFromMpiJunction);

        assignErrorsForLeadsMissingMPI(ctx.opidPartnerNameFromQueueMapping, ctx.availableOpidFromMpiJunction, ctx.partnerNameLeadsMap);

        assignErrorsForQueueMapIssues(ctx.partnerNameLeadsMap, ctx.partnerNameQueueMap);
    }

    private static List<PMP_OPID_MPI_Rel__c> fetchActiveOPIDMPIRelationships(Set<String> OPIDs) {
        return [
            SELECT Id, PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.Name, PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c,Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, Is_Active__c FROM PMP_OPID_MPI_Rel__c WHERE PMP_One_Partner_ID__c IN :OPIDs AND PMP_Marketing_Profile_Id__c != null AND Is_Active__c = true
        ];
    }

    private static void updateLeadsWithMPI(List<PMP_OPID_MPI_Rel__c> OMRList, Map<String, Set<Lead>> opidLeadSetMap, Set<String> availableOpidSet) {
        for (PMP_OPID_MPI_Rel__c omr : OMRList) {
            Set<Lead> leads = opidLeadSetMap.get(omr.PMP_One_Partner_ID__c);
            if (leads != null) {
                for (Lead led : leads) {
                    led.Core_MPI_Id__c = omr.PMP_Marketing_Profile_Id__c;
                    led.Core_Storefront_Name__c = omr.PMP_Marketing_Profile_Id__r.Name;
                }
                availableOpidSet.add(omr.PMP_One_Partner_ID__c);
            }
        }
    }

    private static void assignErrorsForLeadsMissingMPI(Map<String, String> opidPartnerNameFromQueueMapping, Set<String> availableOpidSet, Map<String, List<Lead>> partnerNameLeadsMap
    ) {
        for (String opid : opidPartnerNameFromQueueMapping.keySet()) {
            if (!availableOpidSet.contains(opid)) {
                String partnerName = opidPartnerNameFromQueueMapping.get(opid);
                List<Lead> leads = partnerNameLeadsMap.get(partnerName);
                if (leads != null) {
                    for (Lead led : leads) {
                        assignLeadSharingError(led, System.Label.Core_NoMPIRecords);
                    }
                }
            }
        }
    }

    private static void assignErrorsForQueueMapIssues(Map<String, List<Lead>> partnerNameLeadsMap, Map<String, Core_Partner_Queue_Mapping__c> partnerNameQueueMap
    ) {
        for (String partnerName : partnerNameLeadsMap.keySet()) {
            List<Lead> leads = partnerNameLeadsMap.get(partnerName);
            if (leads == null) { continue; }

            if (!partnerNameQueueMap.containsKey(partnerName)) {
                assignErrorToLeads(leads, System.Label.Core_NoQueueMap);
                continue;
            }

            if (partnerNameQueueMap.get(partnerName).PMP_MDA_BizOrg_Id__c == null) {
                assignErrorToLeads(leads, System.Label.Core_No_PartnerId_In_Queue);
            }
        }
    }

    private static void assignErrorToLeads(List<Lead> leads, String errorMsg) {
        for (Lead led : leads) {
            assignLeadSharingError(led, errorMsg);
        }
    }


    private static void assignLeadSharingError(Lead led, String errorLabel){
        led.Core_Lead_Sharing_Error__c = errorLabel;
        led.Core_Reprocess_Lead_Sharing__c = false;
    }

    
    /*
* Method name  : partnerLeadRoutingToGroup
* Description  : Method to update correct public group on lead
* Return Type  : void
* Parameter    : List<Lead> newLeads, Boolean isInsert
*/
public static void populateGroupsToRoutePartnerLead(List<Lead> newLeads){
    if(isRecursiveGroupCreation){ return; }

    isRecursiveGroupCreation = true;
    Map<String,List<Lead>> allMPILeadsMap = new Map<String,List<Lead>>();
    Map<String,List<Lead>> offeringRelatedMPILeadsMap = new Map<String,List<Lead>>();
    List<Lead> finalLeadList = new List<Lead>();
    
    SWS_LeadWrappers.GroupLeadsCtx glCtx = new SWS_LeadWrappers.GroupLeadsCtx();
    glCtx.allMpiLeadsMap = allMPILeadsMap;
    glCtx.offeringRelatedMpiLeadsMap = offeringRelatedMPILeadsMap;
    glCtx.finalLeadList = finalLeadList;
    groupLeadsByCriteria(newLeads, glCtx);
    allMPILeadsMap = glCtx.allMpiLeadsMap;
    offeringRelatedMPILeadsMap = glCtx.offeringRelatedMpiLeadsMap;
    finalLeadList = glCtx.finalLeadList;
    
    if(allMPILeadsMap.isEmpty()) { return; }

    Map<String,List<String>> OPIDLeadSegmentMap;
    Map<String,List<String>> OPIDLeadGroupNameMap;
    Map<String,String> OPIDLeadGroupIdsMap;
    
    List<PMP_OPID_MPI_Rel__c> OMRList = getActiveOpmRels(allMPILeadsMap.keyset());
    OPIDLeadSegmentMap = createLeadSegmentMap(OMRList, allMPILeadsMap /*, offeringRelatedMPILeadsMap*/);
    
    if(OPIDLeadSegmentMap.isEmpty()) { return; }
    
    OPIDLeadGroupNameMap = buildLeadGroupNames(OPIDLeadSegmentMap);
    Set<String> groupNames = collectAllGroupNames(OPIDLeadGroupNameMap);
    Map<String,Group> groupsMap = ensureAllGroupsExist(groupNames);
    cleanupOldRelationships(finalLeadList);
    createNewLeadOpidRelationships(OPIDLeadGroupNameMap, groupsMap);
}


    // Parameter-bag for grouping criteria
    // Moved to SWS_LeadWrappers.GroupLeadsCtx

    private static void groupLeadsByCriteria(List<Lead> leads, SWS_LeadWrappers.GroupLeadsCtx ctx){
        for(Lead led : leads){                
            if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c <> null && !led.Core_Is_Lead_Shared__c && led.Core_Lead_Sharing_Error__c == null){
                ctx.finalLeadList.add(led);
                ctx.allMpiLeadsMap = generateGroupsNLeadsMap(led, led.Core_MPI_Id__c, ctx.allMpiLeadsMap);
            }
        }
    }

    private static List<PMP_OPID_MPI_Rel__c> getActiveOpmRels(Set<String> mpiIds){
        return [
            select id, PMP_Marketing_Profile_Id__c, Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c, Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c IN: mpiIds AND PMP_One_Partner_ID__c <> null AND Is_Active__c = true
        ];
    }

    private static Map<String,List<String>> createLeadSegmentMap(List<PMP_OPID_MPI_Rel__c> OMRList, Map<String,List<Lead>> allMPILeadsMap
        /*,
        Map<String,List<Lead>> offeringRelatedMPILeadsMap*/
    ){
        Map<String,List<String>> OPIDLeadSegmentMap = new Map<String,List<String>>();
        for(PMP_OPID_MPI_Rel__c OMR : OMRList){
            /*if(offeringRelatedMPILeadsMap.containsKey(OMR.PMP_Marketing_Profile_Id__c)){
                for(Lead led : offeringRelatedMPILeadsMap.get(OMR.PMP_Marketing_Profile_Id__c)){
                    if(OMR.PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c.contains(led.PMP_MktProfile_BizSegment__c)){
                        OPIDLeadSegmentMap.put(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id, led.PMP_MktProfile_BizSegment__c.split(SYMB_SEMICOLON));
                    }
                }
            }*/
            for(Lead led : allMPILeadsMap.get(OMR.PMP_Marketing_Profile_Id__c)){
                if(!OPIDLeadSegmentMap.containsKey(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id)){
                    OPIDLeadSegmentMap.put(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id, null);
                }
            }
        }
        return OPIDLeadSegmentMap;
    }

    private static Map<String,List<String>> buildLeadGroupNames(Map<String,List<String>> OPIDLeadSegmentMap){
        Map<String,List<String>> OPIDLeadGroupNameMap = new Map<String,List<String>>();
        List<String> tempList;
        for(String opidLead : OPIDLeadSegmentMap.keyset()){
            tempList = new List<String>();
            tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],adminPublicGroupNameSuffix));
            tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],empPublicGroupNameSuffix));
            String groupName = 'PMP_'+opidLead.split(SYMB_SEMICOLON)[0];
            tempList.add(groupName);
            /*for(String segment : OPIDLeadSegmentMap.get(opidLead)){
                if(OPIDLeadGroupNameMap.containsKey(opidLead)){
                    tempList = OPIDLeadGroupNameMap.get(opidLead);
                }
                tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],segment));
                OPIDLeadGroupNameMap.put(opidLead, tempList);
            }*/
            OPIDLeadGroupNameMap.put(opidLead, tempList);
        }
        return OPIDLeadGroupNameMap;
    }

    private static Set<String> collectAllGroupNames(Map<String,List<String>> opidLeadGroupNameMap){
        Set<String> groupNames = new Set<String>();
        for(String opidLead : opidLeadGroupNameMap.keyset()){
            groupNames.addAll(opidLeadGroupNameMap.get(opidLead));
        }
        return groupNames;
    }

    private static Map<String,Group> ensureAllGroupsExist(Set<String> groupNames){
        List<Group> groupList = [select Id, Name from Group where Name IN: groupNames];
        Map<String,Group> groupsMap = new Map<String,Group>();
        List<Group> unavailableGroupList = new List<Group>();
        for(Group gr : groupList){
            groupsMap.put(gr.Name, gr);
        }
        for(String grName : groupNames){
            if(!groupsMap.containskey(grName)){
                Group grp = new Group();
                grp.Name = grName;
                grp.Type = 'Regular';
                unavailableGroupList.add(grp);
            }
        }
        insert unavailableGroupList;
        for(Group grp : unavailableGroupList){
            groupsMap.put(grp.Name, grp);
        }
        return groupsMap;
    }

    private static void cleanupOldRelationships(List<Lead> finalLeadList){
        if(finalLeadList.isEmpty()) { return; }
        List<Core_OPID_Lead_Relationship__c> oldOLRList = [select Id, Core_Lead_Name__c, Core_OPID_Name__c from Core_OPID_Lead_Relationship__c where Core_Lead_Name__c IN: finalLeadList];
        if(!oldOLRList.isEmpty()){
            delete oldOLRList;
        }
    }

    private static void createNewLeadOpidRelationships(
        Map<String,List<String>> OPIDLeadGroupNameMap,
        Map<String,Group> groupsMap
    ){
        List<Core_OPID_Lead_Relationship__c> finalOLRList = new List<Core_OPID_Lead_Relationship__c>();
        for(String opidLead : OPIDLeadGroupNameMap.keyset()){
            String tempGroupIds = '';
            for(String grName : OPIDLeadGroupNameMap.get(opidLead)){
                if(groupsMap.containsKey(grName)){
                    tempGroupIds = tempGroupIds + groupsMap.get(grName).Id + SYMB_SEMICOLON;
                }
            }
            if(tempGroupIds <> ''){
                Core_OPID_Lead_Relationship__c tempOLR = new Core_OPID_Lead_Relationship__c();
                tempOLR.Core_Lead_Name__c = opidLead.split(SYMB_SEMICOLON)[1];
                tempOLR.Core_OPID_Name__c = opidLead.split(SYMB_SEMICOLON)[0];
                tempOLR.Core_Public_Group_Ids__c = tempGroupIds.removeEnd(SYMB_SEMICOLON);
                finalOLRList.add(tempOLR);
            }
        }
        insert finalOLRList;
    }

    
	public static void partnerLeadOwnerUpdate(List<Lead> newLeads) {
		if (isRecursiveOwnerUpdate) { return; }

		List<Lead> partnerLeads = filterPartnerLeads(newLeads);
		if (partnerLeads.isEmpty()) { return; }

		isRecursiveOwnerUpdate = true;

		Map<String, Integer> leadOPIDCountMap = getLeadOPIDCounts(partnerLeads);
		List<Lead> leadsToUpdate = getUpdatedOwnerLeads(partnerLeads, leadOPIDCountMap);

		if (!leadsToUpdate.isEmpty()) {
			try {
				update leadsToUpdate;
			} catch (Exception e) {
                // Minimal consistent exception logging (preserve no-throw behavior)
                Core_Exceptions__c excep = new Core_Exceptions__c(
                Core_Exception__c = 'Failure : ########### - ' + e.getStackTraceString() + ' Cause' + e.getMessage(),
                Core_Class_Name__c ='Core_PartnerLeadHandler',
                Core_Method_Name__c ='partnerLeadOwnerUpdate',
                Core_IPS_Object_Name__c = 'Lead'
            );
            insert excep;
			}
		}
	}
	private static List<Lead> filterPartnerLeads(List<Lead> leads) {
		List<Lead> filtered = new List<Lead>();
		for (Lead led : leads) {
			if (led.RecordTypeId == partnerRecTypeId) {
				filtered.add(led);
			}
		}
		return filtered;
	}

	private static Map<String, Integer> getLeadOPIDCounts(List<Lead> partnerLeads) {
		Map<String, Integer> result = new Map<String, Integer>();
		List<Id> leadIds = new List<Id>();

		for (Lead led : partnerLeads) {
			leadIds.add(led.Id);
		}

		List<AggregateResult> aggs = [SELECT Core_Lead_Name__c, COUNT(Core_OPID_Name__c) OPIDCount FROM Core_OPID_Lead_Relationship__c WHERE Core_Lead_Name__c IN :leadIds GROUP BY Core_Lead_Name__c];

		for (AggregateResult ar : aggs) {
			result.put(
				String.valueOf(ar.get('Core_Lead_Name__c')),
				Integer.valueOf(ar.get('OPIDCount'))
			);
		}

		return result;
	}

	private static List<Lead> getUpdatedOwnerLeads(List<Lead> partnerLeads, Map<String, Integer> leadOPIDCountMap) {
		List<Lead> updates = new List<Lead>();

		for (Lead led : partnerLeads) {
			Boolean hasOPID = leadOPIDCountMap.containsKey(led.Id);
			Boolean opidCountPositive = hasOPID && leadOPIDCountMap.get(led.Id) > 0;

			if (!hasOPID &&
				led.OwnerId == System.Label.Core_Partner_Global_Queue_Id) {

				updates.add(new Lead(
					Id = led.Id,
					OwnerId = System.Label.Core_Partner_Invalid_Queue_Id
				));

			} else if (opidCountPositive &&
					   led.Core_MPI_Id__c != null &&
					   led.Core_Lead_Sharing_Error__c == null &&
					   (led.OwnerId == System.Label.Core_Partner_Global_Queue_Id ||
						led.OwnerId == System.Label.Core_Partner_Invalid_Queue_Id)) {

				updates.add(new Lead(
					Id = led.Id,
					OwnerId = System.Label.Core_Salesforce_System_User_Id
				));
			}
		}

		return updates;
	}

    
    /*
* Method name  : reRoutePartnerLead
* Description  : Helper method to re share the leads to public groups.
* Return Type  : void
* Parameter    : List<Lead> newLeads
*/
    public static void reRoutePartnerLead(List<Lead> newLeads){
        
        if(!isLeadShared){
            List<Lead> invalidLeads = new List<Lead>();
            for(Lead led : newLeads){
                if(led.RecordTypeId == partnerRecTypeId && led.Core_Reprocess_Lead_Sharing__c && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c == null && led.Core_Partner_Name__c == null){
                    led.Core_Reprocess_Lead_Sharing__c.addError(system.label.Core_No_PartnerId_PartnerName);
                }else if(led.RecordTypeId == partnerRecTypeId && led.Core_Reprocess_Lead_Sharing__c && !led.Core_Is_Lead_Shared__c){
                    invalidLeads.add(led);
                }else if(led.RecordTypeId == partnerRecTypeId && led.Core_Reprocess_Lead_Sharing__c && led.Core_Is_Lead_Shared__c){
                    led.Core_Reprocess_Lead_Sharing__c.addError(system.label.Core_Lead_Already_Shared);
                }
            }
            if(!invalidLeads.isEmpty()){
                populateSegmentMpiInPartnerLeads(invalidLeads, false);
            }
        }
    }
    
    /*
* Method name  : generateGroupsNLeadsMap
* Description  : Helper method to prepare a map which is combination of group name and list of lead.
* Return Type  : Map<String,List<Lead>>
* Parameter    : Lead led, String partnerKey, Map<String,List<Lead>> groupsNLeadsMap
*/
    public static Map<String,List<Lead>> generateGroupsNLeadsMap(Lead led, String partnerKey, Map<String,List<Lead>> groupsNLeadsMap){
        List<Lead> leadList;
        if(groupsNLeadsMap.containsKey(partnerKey)){
            leadList = groupsNLeadsMap.get(partnerKey);
        }else{
            leadList = new List<Lead>();
        }
        leadList.add(led);
        groupsNLeadsMap.put(partnerKey, leadList);
        return groupsNLeadsMap;
    }
    
    /*
* Method name  : shareLeadRecord
* Description  : Method to share lead record with public group
* Return Type  : void
* Parameter    : List<Lead> leadList
*/
public static void shareLeadRecord(List<Lead> leadList){
    if(isLeadShared) return;
    try {
        isLeadShared = true;
        List<Lead> finalLeadList = filterEligibleLeads(leadList);
        if (finalLeadList.isEmpty()) { return; }

        Map<String, Lead> finalLeadMap = new Map<String, Lead>();
        Map<String, Lead> finalLeadPLCLMap = new Map<String, Lead>();
        Map<String, List<String>> finalGroupsNLeadsMap = new Map<String, List<String>>();

        // Prepare auxiliary data
        Map<Id, Core_Partner_Queue_Mapping__c> newQueueMap = getPartnerQueueMap();
        SWS_LeadWrappers.ProcessOlrCtx olrCtx = new SWS_LeadWrappers.ProcessOlrCtx();
        olrCtx.newQueueMap = newQueueMap;
        olrCtx.finalLeadMap = finalLeadMap;
        olrCtx.finalLeadPlclMap = finalLeadPLCLMap;
        olrCtx.finalGroupsNLeadsMap = finalGroupsNLeadsMap;
        processOPIDLeadRelationships(finalLeadList, olrCtx);

        if (!finalLeadMap.isEmpty()) {
            if (!finalLeadPLCLMap.isEmpty()) {
                finalLeadMap.putAll(finalLeadPLCLMap);
            }
            update finalLeadMap.values();
        }

        insertLeadShares(finalGroupsNLeadsMap, finalLeadMap);
    } catch(Exception e){
        for(Lead led : leadList){
            led.addError('Error in lead share, please contact system admin with this error details: ' + e.getStackTraceString());
        }
    }
}

    private static List<Lead> filterEligibleLeads(List<Lead> leadList) {
        List<Lead> eligibleLeads = new List<Lead>();
        for(Lead led : leadList){
            if(!led.Core_Is_Lead_Shared__c && led.Core_MPI_Id__c != null && led.Core_Lead_Sharing_Error__c == null){
                eligibleLeads.add(led);
            }
        }
        return eligibleLeads;
    }

    private static Map<Id, Core_Partner_Queue_Mapping__c> getPartnerQueueMap() {
        String partnerRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c
            .getRecordTypeInfosByName().get(Label.Core_Dispositioned_for_PLCL).getRecordTypeId();

        List<Core_Partner_Queue_Mapping__c> newQueueList = [SELECT Id, PMP_MDA_BizOrg_Id__c, Core_Storefront_Id__c, Core_Disposition_as_PLCL__c,Name, Core_Storefront_Name__c FROM Core_Partner_Queue_Mapping__c WHERE RecordTypeId = :partnerRecTypeId ];

        Map<Id, Core_Partner_Queue_Mapping__c> newQueueMap = new Map<Id, Core_Partner_Queue_Mapping__c>();
        for(Core_Partner_Queue_Mapping__c partnerQueue : newQueueList){
            newQueueMap.put((Id)partnerQueue.PMP_MDA_BizOrg_Id__c, partnerQueue);
        }
        return newQueueMap;
    }

    // Parameter-bag for OLR processing
    // Moved to SWS_LeadWrappers.ProcessOlrCtx

    private static void processOPIDLeadRelationships(List<Lead> finalLeadList, SWS_LeadWrappers.ProcessOlrCtx ctx
    ) {
        List<Core_OPID_Lead_Relationship__c> OLRList = [SELECT Id, Core_Lead_Name__c, Core_OPID_Name__c, Core_OPID_Name__r.Id, Core_Public_Group_Ids__c FROM Core_OPID_Lead_Relationship__c WHERE Core_Lead_Name__c IN :finalLeadList];

        for(Core_OPID_Lead_Relationship__c olr : OLRList){
            processGroupsForLead(olr, ctx.finalGroupsNLeadsMap);

            Lead tempLead = new Lead();
            tempLead.Id = olr.Core_Lead_Name__c;
            tempLead.Core_Is_Lead_Shared__c = true;
            tempLead.Core_Reprocess_Lead_Sharing__c = false;
            tempLead.Core_Lead_Sharing_Error__c = null;

            if(ctx.newQueueMap.containsKey(olr.Core_OPID_Name__c) &&
            ctx.newQueueMap.get(olr.Core_OPID_Name__c).Core_Disposition_as_PLCL__c == true) {     
                tempLead.Core_Lead_Status__c = Label.Core_Disposition_as_PLCL_Status;
                ctx.finalLeadPlclMap.put(olr.Core_Lead_Name__c, tempLead);
            }
            ctx.finalLeadMap.put(olr.Core_Lead_Name__c, tempLead);
        }
    }

    private static void processGroupsForLead(Core_OPID_Lead_Relationship__c olr, Map<String, List<String>> finalGroupsNLeadsMap) 
    {
        for(String grId : olr.Core_Public_Group_Ids__c.split(SYMB_SEMICOLON)){
            List<String> tempLeads = finalGroupsNLeadsMap.containsKey(grId)
                ? finalGroupsNLeadsMap.get(grId)
                : new List<String>();
            tempLeads.add(olr.Core_Lead_Name__c);
            finalGroupsNLeadsMap.put(grId, tempLeads);
        }
    }

    private static void insertLeadShares(Map<String, List<String>> finalGroupsNLeadsMap, Map<String, Lead> finalLeadMap) 
    {
        if(finalGroupsNLeadsMap.isEmpty()) { return; }

        Map<String, String> grIdNameMap = buildGroupSuffixMap(finalGroupsNLeadsMap.keySet());

        List<LeadShare> finalLeadShrList = buildLeadShares(finalGroupsNLeadsMap, finalLeadMap, grIdNameMap);

        if(!finalLeadShrList.isEmpty()){
            insert finalLeadShrList;
        }
    }

    private static Map<String, String> buildGroupSuffixMap(Set<String> groupIds) {
        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Id IN :groupIds];
        Map<String, String> grIdNameMap = new Map<String, String>();

        for (Group gr : groupList) {
            List<String> splitName = gr.Name.split('_');
            String groupSuffix = (splitName.size() > 2)
                ? splitName[2]
                : (splitName.size() > 1 ? splitName[1] : splitName[0]);
            grIdNameMap.put(gr.Id, groupSuffix);
        }    
        return grIdNameMap;
    }

    private static List<LeadShare> buildLeadShares(
        Map<String, List<String>> finalGroupsNLeadsMap,
        Map<String, Lead> finalLeadMap,
        Map<String, String> grIdNameMap
    ) {
        List<LeadShare> leadShares = new List<LeadShare>();

        for (String grpId : finalGroupsNLeadsMap.keySet()) {
            for (String ledId : finalGroupsNLeadsMap.get(grpId)) {
                LeadShare leadShr = new LeadShare();
                leadShr.LeadId = ledId;
                leadShr.UserOrGroupId = grpId;

                if (grIdNameMap.get(grpId) == empPublicGroupNameSuffix
                    || finalLeadMap.get(ledId).Core_Lead_Status__c == Label.Core_Disposition_as_PLCL_Status) {
                    leadShr.LeadAccessLevel = 'Read';
                } else {
                    leadShr.LeadAccessLevel = 'Edit';
                }
                leadShares.add(leadShr);
            }
        }

        return leadShares;
    }
    
    /*
* Method name  : prepareGroupWiseEmail
* Description  : Method to prepare group wise email.
* Return Type  : List<Messaging.SingleEmailMessage>
* Parameter    : String groupName, List<String> userIdList, List<Lead> leadList, OrgWideEmailAddress owea, List<Messaging.SingleEmailMessage> emailList
*/
    // Parameter-bag for simple email prepare to reduce parameter list
    // Moved to SWS_LeadWrappers.PrepareEmailCtx
    public static List<Messaging.SingleEmailMessage> prepareGroupWiseEmail(SWS_LeadWrappers.PrepareEmailCtx ctx){
        List<String> userIdList = new List<String>();
        userIdList.add(ctx.userId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(userIdList);
        if(ctx.isReminder){
            mail.setSubject('Your Leads: Don’t Forget');
        }else{
            mail.setSubject('New Leads For You');
        }
        mail.setHtmlBody(prepareHtmlBody(ctx.leadList,ctx.isReminder));
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        ctx.emailList.add(mail);
        return ctx.emailList;
    }
    
    /*
* Method name  : prepareHtmlBody
* Description  : Method to prepare html body
* Return Type  : String
* Parameter    : List<Lead> leadList
*/
	public static String prepareHtmlBody(List<Lead> leadList, Boolean isReminder) {
    String logoUrl = System.Label.Core_Intel_Logo_Id + '&oid=' + UserInfo.getOrganizationId();
    String intelLeadHelp = System.Label.Core_PartnerLead_Help;
    Integer currYear = Date.today().year();
    String baseUrl = System.Label.Core_Partner_Community;
    String listViewUrl = baseUrl + '/s/?Lead-filterId=' + System.Label.Core_My_Lead_Listview_Id;
    String fontStyle = 'font-family:intel clear;';
    String borderStyle = 'style="border: 1px solid #d3d3d3;padding-left:50px;padding-top:5px;padding-bottom:5px;font-size: 14px;"';
    String emailBody = '<html><body>';

    if (isReminder) {
        emailBody += buildReminderHeader(logoUrl, fontStyle);
        emailBody += buildReminderIntro(baseUrl, fontStyle, borderStyle);

        Map<Integer, List<Lead>> reminderDayWiseLeadsMap = buildReminderMap(leadList);
        List<Integer> daysList = new List<Integer>(reminderDayWiseLeadsMap.keySet());
        daysList.sort();

        for (Integer days : daysList) {
            emailBody += '<tr><td ' + borderStyle + '><p><strong>Leads over ' + days + ' days past due</strong></p>';
            emailBody = prepareDisplayableLeads(new SWS_LeadWrappers.DisplayLeadsCtx(baseUrl, listViewUrl, reminderDayWiseLeadsMap.get(days), isReminder), emailBody);
        }
        emailBody += buildReminderFooter(listViewUrl, intelLeadHelp, borderStyle);
    } else {
        emailBody += buildNewLeadsHeader(logoUrl, fontStyle);
        emailBody += buildNewLeadsIntro(baseUrl, fontStyle, borderStyle);
        emailBody += '<tr><td ' + borderStyle + '><p><strong>You have ' + leadList.size() + ' new leads:</strong></p>';
        emailBody = prepareDisplayableLeads(new SWS_LeadWrappers.DisplayLeadsCtx(baseUrl, listViewUrl, leadList, isReminder), emailBody);
        emailBody += buildReviewFooter(listViewUrl, intelLeadHelp, borderStyle);
    }
    emailBody += buildCommonFooter(borderStyle, currYear);

    emailBody += '</td></tr></tbody></table></body></html>';
    return emailBody;
}

// Helper for adding leads to reminder map based on date field
/* Moved to SWS_LeadWrappers.ReminderParams */
    
private static void addLeadToReminderMap(Map<Integer, List<Lead>> leadMap, SWS_LeadWrappers.ReminderParams p){
    if (p.reminderDate == Date.today()) {
        Integer days = p.leadCreationDate.daysBetween(p.reminderDate);
        List<Lead> leads = leadMap.containsKey(days) ? leadMap.get(days) : new List<Lead>();
        leads.add(p.led);
        leadMap.put(days, leads);
    }
}

private static Map<Integer, List<Lead>> buildReminderMap(List<Lead> leadList) {
    Map<Integer, List<Lead>> reminderDayWiseLeadsMap = new Map<Integer, List<Lead>>();
    for (Lead led : leadList) {
        Date leadCreationDate = Date.newInstance(led.CreatedDate.year(), led.CreatedDate.month(), led.CreatedDate.day());
        addLeadToReminderMap(reminderDayWiseLeadsMap, new SWS_LeadWrappers.ReminderParams(leadCreationDate, led.Core_1st_Reminder__c, led));
        addLeadToReminderMap(reminderDayWiseLeadsMap, new SWS_LeadWrappers.ReminderParams(leadCreationDate, led.Core_2nd_Reminder__c, led));
        addLeadToReminderMap(reminderDayWiseLeadsMap, new SWS_LeadWrappers.ReminderParams(leadCreationDate, led.Core_3rd_Reminder__c, led));
        addLeadToReminderMap(reminderDayWiseLeadsMap, new SWS_LeadWrappers.ReminderParams(leadCreationDate, led.Core_4th_Reminder__c, led));
    }
    return reminderDayWiseLeadsMap;
}

private static String buildReminderHeader(String logoUrl, String fontStyle) {
    return '<table style="background-color: #0071c5;' + fontStyle + '" width="75%"><tbody><tr><td style="padding-left: 50px; border: none;"><div style="color: white;"><h1>YOUR LEADS ARE WAITING</h1></div></td><td style="border: none; padding-right: 20px;" align="right"><img src="' + logoUrl + '" /></td></tr></tbody></table>';
}

private static String buildReminderIntro(String baseUrl, String fontStyle, String borderStyle) {
    return '<table style="border-collapse: collapse;' + fontStyle + '" width="75%"><tbody><tr><td ' + borderStyle + '><p>Hello</p><p>Just a friendly reminder&mdash;but an important one&mdash;Intel has generated leads for you that require your attention.</p><p>If you have already reviewed your leads, thank you! Please <a href="' + baseUrl + '">log in and accept or reject your leads </a>to help us ensure the continued quality of these leads</p><p>If you have <u>not</u> reviewed your leads, please take immediate action by <a href="' + baseUrl + '">logging into your partner portal.</a>Timely follow up with leads is a key factor in determining success.</p><p>Thank you for your partnership!</p><p>Intel® Partner Alliance</p><p><strong>YOUR LEADS</strong></p></td></tr>';
}

private static String buildReminderFooter(String listViewUrl, String intelLeadHelp, String borderStyle) {
    return '<tr><td ' + borderStyle + '><p><a href="' + listViewUrl + '"><b><span style="font-size: 14px">Click here to disposition your leads</span></b></a><br/>Can\'t access the link above?<br/><a href="' + intelLeadHelp + '">View Help for processing Intel leads</a></p></td></tr>';
}

private static String buildNewLeadsHeader(String logoUrl, String fontStyle) {
    return '<table style="background-color: #0071c5;' + fontStyle + '" width="75%"><tbody><tr><td style="padding-left: 50px; border: none;"><div style="color: white;"><h1>YOU HAVE NEW LEADS!</h1></div></td><td style="border: none; padding-right: 20px;" align="right"><img src="' + logoUrl + '" /></td></tr></tbody></table>';
}

private static String buildNewLeadsIntro(String baseUrl, String fontStyle, String borderStyle) {
    return '<table style="border-collapse: collapse;' + fontStyle + '" width="75%"><tbody><tr><td ' + borderStyle + '><p>Hello</p><p><strong>Great news!  Intel has generated New leads</strong> for you. To act on them and help ensure the quality of leads we send you, please promptly <a href="' + baseUrl + '">log in and accept or reject them.</a> To see the full information about these leads, please login and download the Standard Leads Report.</p><p>Thank you for your partnership!</p><p>Intel® Partner Alliance</p><p><strong>YOUR LEADS</strong></p></td></tr>';
}

private static String buildReviewFooter(String listViewUrl, String intelLeadHelp, String borderStyle) {
    return '<tr><td ' + borderStyle + '><p><a href="' + listViewUrl + '"><b><span style="font-size: 14px">Click here to review your Leads</span></b></a><br/>Can\'t access the link above?<br/><a href="' + intelLeadHelp + '">View Help for processing Intel leads</a></p></td></tr>';
}

private static String buildCommonFooter(String borderStyle, Integer currYear) {
    return '<tr><td ' + borderStyle + '><p>Questions? Contact Intel® Partner Alliance Support:<br /> <span style="color: #0071c5;">programs@intel.com</span></p></td></tr>'
        + '<tr><td ' + borderStyle + '><p><strong>Note</strong> : <span style="color: #ff0000;">' + System.Label.Core_Do_Not_Reply_Note + '</span></p></td></tr>'
        + '<tr><td style="border: 1px solid #d3d3d3;"><p style="text-align: center;font-size: 10px;">This message was sent to you as an important business communication related to your current relationship with Intel Corporation</br>&copy; ' + currYear + ' Intel Corporation<br /> Intel Corporation, 2200 Mission College Blvd., M/S RNB4-145, Santa Clara, CA 95054 USA.</br> <a href="http://www.intel.com">www.intel.com</a></br><a href="http://www.intel.com/privacy">Privacy</a> | <a href="http://www.intel.com/cookies">Cookies</a></p>';
}


    /*
* Method name  : prepareDisplayableLeads
* Description  : Method to prepare list of leads which can be displayed in the email
* Return Type  : String
* Parameter    : List<Lead> leadList, Integer noOfLeads, String emailBody
*/
	// Moved to SWS_LeadWrappers.DisplayLeadsCtx
	public static String prepareDisplayableLeads(SWS_LeadWrappers.DisplayLeadsCtx ctx, String emailBody) {
		Integer noOfLeads = getDisplayLeadCount(ctx.isReminder);
		Integer remainingLeadCount = ctx.leadList.size() - noOfLeads;

		for (Integer i = 0; i < Math.min(noOfLeads, ctx.leadList.size()); i++) {
			Lead lead = ctx.leadList[i];
			emailBody += formatLeadEntry(lead, ctx.baseUrl, ctx.isReminder);
		}

		emailBody += formatRemainingLeadNote(remainingLeadCount, ctx.listViewUrl);
		return emailBody;
	}

	private static Integer getDisplayLeadCount(Boolean isReminder) {
		return isReminder 
			? Integer.valueOf(System.Label.Core_ReminderEmailDisplayLeadCount)
			: Integer.valueOf(System.Label.Core_SummaryEmailDisplayLeadCount);
	}

	private static String formatLeadEntry(Lead lead, String baseUrl, Boolean isReminder) {
		String leadHtml = '<p>';
		
		if (lead.FirstName != null || lead.LastName != null) {
			leadHtml += '<strong>Lead Name</strong> : <span style="color: #339966;">';
			if (lead.FirstName != null) {leadHtml += lead.FirstName;}
			if (lead.LastName != null) {leadHtml += ' ' + lead.LastName; }
			leadHtml += '</span><br/>';
		}

		if (lead.Company != null) {
			leadHtml += '<strong>Company</strong> : <span style="color: #339966;">' + lead.Company + '</span><br/>';
		}

		if (lead.Country != null) {
			leadHtml += '<strong>Country</strong> : <span style="color: #339966;">' + lead.Country + '</span><br/>';
		}

		if (!isReminder) {
			if (lead.Core_Lead_Source_Pkt__c != null) {
				leadHtml += '<span style="color: #339966;">' + lead.Core_Lead_Source_Pkt__c + '</span><br/>';
			}
			if (lead.Core_Lead_PMP_Action__c != null) {
				leadHtml += '<span style="color: #339966;">' + lead.Core_Lead_PMP_Action__c + '</span><br/>';
			}
		}

		String leadLink = baseUrl + '/' + lead.Id;
		leadHtml += '<strong>Link</strong> : <a href="' + leadLink + '">' + leadLink + '</a><br/>';

		return leadHtml;
	}

	private static String formatRemainingLeadNote(Integer remainingCount, String listViewUrl) {
		if (remainingCount <= 0) {
			return '<br/></p></td></tr>';
		}

		String suffix = remainingCount == 1 ? ' Other' : ' Others';
		return '<br/><strong><a href="' + listViewUrl + '">'
			 + '<span style="color: #339966;font-size:20px;">Plus ' + remainingCount + suffix
			 + '</span></a></strong><br/></p></td></tr>';
	}
    
    /*
* Method name  : stampFieldOnRejectLead
* Description  : Method to stamp field once a lead is rejected
* Return Type  : void
* Parameter    : List<Lead> newLead, Map<Id,Lead> oldLeadMap
*/
	public static void stampFieldOnRejectLead(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap) {
		for (Lead newLead : newLeadList) {
			Lead oldLead = oldLeadMap.get(newLead.Id);

			if (!shouldStampFields(newLead, oldLead)) {
				continue;
			}

			stampBasedOnStatusAndStage(newLead, oldLead);
		}
	}

	private static Boolean shouldStampFields(Lead newLead, Lead oldLead) {
		return newLead.RecordTypeId == partnerRecTypeId && newLead.Core_Lead_State__c == 'Terminated' && oldLead.Core_Lead_State__c != 'Terminated' && oldLead.Core_Lead_Status__c != 'Qualified' && oldLead.Status != 'PQL';
	}

	private static void stampBasedOnStatusAndStage(Lead newLead, Lead oldLead) {
		String oldStatus = oldLead.Core_Lead_Status__c;
		String oldStage = oldLead.Status;

		DateTime now = System.now();

		if (oldStatus == 'New' && oldStage == 'PRL') {
			newLead.Core_PRL_Exit_Dt__c = now;
			newLead.Core_Partner_Lead_Owner__c = UserInfo.getUserId();
		}

		if (oldStatus == 'Accepted' && oldStage == 'PAL') {
			newLead.Core_PAL_Exit_Dt__c = now;
		}

		if (oldStatus == 'Contacted' && oldStage == 'PAL') {
			newLead.Core_PAL_Exit_Dt__c = now;
			newLead.Core_Exit_Date_Contacted_Dt__c = now;
		}
	}

    
    /*
* Method name  : sendEmailNotification
* Description  : Method to Send New Email Notification to public group Users
* Return Type  : Void
* Parameter    : List<Lead> leadList
*/
public static void sendEmailNotification(List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst, Map<Id, Lead> leadMap, EmailTemplate EmailTemp) {
    Map<String, List<String>> finalGroupsNLeadsMap = buildFinalGroupsNLeadsMap(LeadOPIDSlst);

    Map<String, List<Lead>> tempGroupWiseLeadMap = buildTempGroupWiseLeadMap(finalGroupsNLeadsMap, leadMap);

    Map<String, List<Lead>> groupWiseLeadMap = filterGroupWiseLeadMap(tempGroupWiseLeadMap);

    List<GroupMember> gmList = fetchGroupMembers(tempGroupWiseLeadMap.keySet());

    Map<Id, User> userIdMap = fetchUsersWithEmailLimits(gmList);

    Map<String, List<String>> userWiseGroupMap = buildUserWiseGroupMap(gmList, userIdMap);

    Map<String, Set<Lead>> userWiseLeadMap = buildUserWiseLeadMap(userWiseGroupMap, groupWiseLeadMap);

    List<Messaging.SingleEmailMessage> emailList = prepareEmails(userWiseLeadMap, userIdMap, EmailTemp);

    sendEmailsAndLog(emailList, userIdMap, EmailTemp);
}

private static Map<String, List<String>> buildFinalGroupsNLeadsMap(List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst) {
    Map<String, List<String>> Leadmap = new Map<String, List<String>>();
    for(Core_OPID_Lead_Relationship__c olr : LeadOPIDSlst){
        for(String groupId : olr.Core_Public_Group_Ids__c.split(SYMB_SEMICOLON)){
            if(!Leadmap.containsKey(olr.Core_Lead_Name__c)){
                Leadmap.put(olr.Core_Lead_Name__c, new List<String>());
            }
            Leadmap.get(olr.Core_Lead_Name__c).add(groupId);
        }
    }
    return Leadmap;
}

private static Map<String, List<Lead>> buildTempGroupWiseLeadMap(Map<String, List<String>> finalGroupsNLeadsMap, Map<Id, Lead> leadMap) {
    Map<String, List<Lead>> Storemap = new Map<String, List<Lead>>();
    for(String leadId : finalGroupsNLeadsMap.keySet()){
        List<String> publicGroupIds = finalGroupsNLeadsMap.get(leadId);
        for(String groupId : publicGroupIds){
            Storemap = generateGroupsNLeadsMap(leadMap.get(leadId), groupId, Storemap);
        }
    }
    return Storemap;
}

private static Map<String, List<Lead>> filterGroupWiseLeadMap(Map<String, List<Lead>> tempGroupWiseLeadMap) {
    Map<String, List<Lead>> filteredMap = new Map<String, List<Lead>>();
    Map<Id, Group> groupsMap = new Map<Id, Group>(
        [SELECT Id, DeveloperName FROM Group WHERE Id IN :tempGroupWiseLeadMap.keySet() AND Type = 'Regular']
    );
    for(String grId : tempGroupWiseLeadMap.keySet()){
        if(groupsMap.containsKey(grId)) {
            List<String> parts = groupsMap.get(grId).DeveloperName.split('_');
            if(parts.size() >= 3 && parts[2] != empPublicGroupNameSuffix) {
                filteredMap.put(grId, tempGroupWiseLeadMap.get(grId));
            }
        }
    }
    return filteredMap;
}

private static List<GroupMember> fetchGroupMembers(Set<String> groupIds) {
    return [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN :groupIds];
}

private static Map<Id, User> fetchUsersWithEmailLimits(List<GroupMember> gmList) {
    List<String> userIds = new List<String>();
    for(GroupMember gm : gmList){
        userIds.add(gm.UserOrGroupId);
    }
    Integer emailLimit = Integer.valueOf(System.Label.Core_Partner_Lead_Email_Limit);
    return new Map<Id, User>(
        [SELECT Id, Core_Lead_Field_Update_Date__c, Core_Email_Trigger_Date__c, Core_Email_Count__c FROM User WHERE Id IN :userIds AND ((Core_Email_Trigger_Date__c = NULL AND Core_Email_Count__c = NULL) OR Core_Email_Trigger_Date__c != TODAY OR (Core_Email_Trigger_Date__c = TODAY AND Core_Email_Count__c < :emailLimit))] );
}

private static Map<String, List<String>> buildUserWiseGroupMap(List<GroupMember> gmList, Map<Id, User> userIdMap) {
    Map<String, List<String>> userWiseGroupMap = new Map<String, List<String>>();
    for(GroupMember gm : gmList){
        if(userIdMap.containsKey(gm.UserOrGroupId)){
            if(!userWiseGroupMap.containsKey(gm.UserOrGroupId)){
                userWiseGroupMap.put(gm.UserOrGroupId, new List<String>());
            }
            userWiseGroupMap.get(gm.UserOrGroupId).add(gm.GroupId);
        }
    }
    return userWiseGroupMap;
}

private static Map<String, Set<Lead>> buildUserWiseLeadMap(Map<String, List<String>> userWiseGroupMap, Map<String, List<Lead>> groupWiseLeadMap) {
    Map<String, Set<Lead>> userWiseLeadMap = new Map<String, Set<Lead>>();
    for(String userId : userWiseGroupMap.keySet()){
        Set<Lead> leadSet = new Set<Lead>();
        for(String groupId : userWiseGroupMap.get(userId)){
            if(groupWiseLeadMap.containsKey(groupId)){
                leadSet.addAll(groupWiseLeadMap.get(groupId));
            }
        }
        userWiseLeadMap.put(userId, leadSet);
    }
    return userWiseLeadMap;
}

private static List<Messaging.SingleEmailMessage> prepareEmails(Map<String, Set<Lead>> userWiseLeadMap, Map<Id, User> userIdMap, EmailTemplate emailTemp) {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    Integer emailLimit = Integer.valueOf(System.Label.Core_Partner_Lead_Email_Limit);

    for(String userId : userWiseLeadMap.keySet()){
        User user = userIdMap.get(userId);
        Integer count = calculateEmailCount(user, userWiseLeadMap.get(userId).size(), emailLimit);
        updateUserEmailTracking(user, count);

        List<Lead> leadList = new List<Lead>();
        leadList.addAll(userWiseLeadMap.get(userId));

        for(Integer i = 0; i < count; i++){
            SWS_LeadWrappers.PrepareTemplEmailCtx pctx = new SWS_LeadWrappers.PrepareTemplEmailCtx();
            pctx.userId = userId;
            pctx.leadId = leadList[i].Id;
            pctx.emailTemplateId = emailTemp.Id;
            pctx.emailList = emailList;
            emailList = prepareGroupWiseEmail(pctx);
        }
    }
    return emailList;
}

private static Integer calculateEmailCount(User user, Integer leadSize, Integer emailLimit) {
    Integer count = 0;
    if(user.Core_Email_Trigger_Date__c == null || user.Core_Email_Trigger_Date__c != Date.today()){
        count = (leadSize > emailLimit) ? emailLimit : leadSize;
    } else if(user.Core_Email_Trigger_Date__c == Date.today()){
        Integer remaining = Integer.valueOf(emailLimit - (user.Core_Email_Count__c == null ? 0 : user.Core_Email_Count__c));
        count = (leadSize > remaining) ? remaining : leadSize;
    }
    return count;
}

private static void updateUserEmailTracking(User user, Integer count) {
    if(user.Core_Email_Trigger_Date__c == null || user.Core_Email_Trigger_Date__c != Date.today()){
        user.Core_Email_Trigger_Date__c = Date.today();
        user.Core_Email_Count__c = count;
    } else {
        user.Core_Email_Count__c = (user.Core_Email_Count__c == null ? 0 : user.Core_Email_Count__c) + count;
    }
    user.Core_Lead_Field_Update_Date__c = System.now();
}

private static void sendEmailsAndLog(List<Messaging.SingleEmailMessage> emailList, Map<Id, User> userIdMap, EmailTemplate emailTemp) {
    if(emailList.isEmpty()) { return; }

    try {
        update userIdMap.values();

        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailList, false);

        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>();
        Map<String, PRM_EmailLog__c> targetIdLog = new Map<String, PRM_EmailLog__c>();

        for(Messaging.SingleEmailMessage mail : emailList){
            PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
            emailLog.PRM_EmailContent__c = mail.getHtmlBody();
            emailLog.PRM_EmailDeliverabilityStatus__c = true;
            emailLog.Email_Template_ID__c = emailTemp.Id;
            emailLog.Email_Template_Name__c = emailTemp.Name;
            emailLog.PRM_Subject__c = mail.getSubject();
            emailLog.PRM_Timestamp__c = DateTime.now();
            emailLog.PRM_User__c = mail.getToAddresses()[0];
            emailLog.PRM_Email_API_Response__c = 'Mail sent successfully !!';
            emailLogList.add(emailLog);
            targetIdLog.put(emailLog.PRM_User__c, emailLog);
        }

        for(Messaging.SendEmailResult result : resultList){
            if(!result.isSuccess()){
                for(Messaging.SendEmailError error : result.getErrors()){
                    String targetId = error.getTargetObjectId();
                    if(targetId != null && targetIdLog.containsKey(targetId)){
                        PRM_EmailLog__c log = targetIdLog.get(targetId);
                        log.PRM_EmailDeliverabilityStatus__c = false;
                        log.PRM_Email_API_Response__c = error.getMessage();
                    }
                }
            }
        }
        insert emailLogList;
    } catch(Exception e) {
        Core_Exceptions__c excep = new Core_Exceptions__c(
            Core_Exception__c = 'Failure : ########### - ' + e.getStackTraceString() + ' Cause' + e.getMessage(),
            Core_Class_Name__c ='Core_PartnerLeadHandler',
            Core_Method_Name__c ='sendEmailNotification',
            Core_IPS_Object_Name__c = 'Lead'
        );
        insert excep;
    }
}
    
    // Moved to SWS_LeadWrappers.PrepareTemplEmailCtx
    public static List<Messaging.SingleEmailMessage> prepareGroupWiseEmail(SWS_LeadWrappers.PrepareTemplEmailCtx ctx){
        List<String> userIdList = new List<String>();
        userIdList.add(ctx.userId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(userIdList);
        mail.setTemplateId(ctx.emailTemplateId);
        mail.setTargetObjectId(ctx.leadId); 
        mail.setSaveAsActivity(false); 
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        ctx.emailList.add(mail);
        return ctx.emailList;
    }
    
	public static void StampOPIDsonLead(List<Lead> leadList){
    if(isLeadCheckforOPIDStamping) { return; }
    isLeadCheckforOPIDStamping = true;

    List<Lead> finalLeadList = filterLeadsToStamp(leadList);
    if(finalLeadList.isEmpty()) { return; }

    List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst = fetchLeadOPIDRelationships(finalLeadList);

    Map<Id, Lead> finalLeadMap = buildLeadOPIDMap(finalLeadList, LeadOPIDSlst);
    
    if(!finalLeadMap.isEmpty()){
        update finalLeadMap.values();
    }
}

private static List<Lead> filterLeadsToStamp(List<Lead> leadList) {
    List<Lead> filteredLeads = new List<Lead>();
    for(Lead led : leadList){
        if(led.Core_Is_Lead_Shared__c  && led.RecordTypeId == partnerRecTypeId  && led.OwnerId == label.Core_Salesforce_System_User_Id && led.Core_Partner_Lead_Owner__c == null){
            filteredLeads.add(led);
        }
    }
    return filteredLeads;
}

private static List<Core_OPID_Lead_Relationship__c> fetchLeadOPIDRelationships(List<Lead> leads) {
    return [SELECT Id, Core_Lead_Name__c, Core_Public_Group_Ids__c, Core_OPID_Name__c  FROM Core_OPID_Lead_Relationship__c WHERE Core_Lead_Name__c IN :leads ];
}

private static Map<Id, Lead> buildLeadOPIDMap(List<Lead> filteredLeads, List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst) {
    Map<Id, Lead> leadMap = new Map<Id, Lead>();

    // Group OPIDs by Lead Id for efficient lookup
    Map<Id, List<String>> leadIdToOPIDList = new Map<Id, List<String>>();
    for(Core_OPID_Lead_Relationship__c olr : LeadOPIDSlst){
        if(!leadIdToOPIDList.containsKey(olr.Core_Lead_Name__c)){
            leadIdToOPIDList.put(olr.Core_Lead_Name__c, new List<String>());
        }
        leadIdToOPIDList.get(olr.Core_Lead_Name__c).add(olr.Core_OPID_Name__c);
    }

    // Build Lead records with concatenated OPIDs
    for(Lead l : filteredLeads){
        List<String> opidList = leadIdToOPIDList.containsKey(l.Id) ? leadIdToOPIDList.get(l.Id) : new List<String>();
        String commaSeparatedOPIDs = String.join(opidList, ',');
        Lead tempLead = new Lead(Id = l.Id, Core_One_Partner_Id__c = String.valueOf(commaSeparatedOPIDs));
        leadMap.put(l.Id, tempLead);
    }

    return leadMap;
}

    
public static void sendLeadEmailNotifications(List<Account> opidList, Boolean isReminder, List<String> partnerSegmentList) {
    List<String> groupNameList = buildGroupNameList(opidList, partnerSegmentList);
    if(groupNameList.isEmpty()) { return; }

    List<Group> groupList = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN :groupNameList];
    if(groupList.isEmpty()) { return; }

    Map<String, List<GroupMember>> groupWiseGroupMemberMap = buildGroupWiseGroupMemberMap(groupList);
    List<Id> groupListId = new List<Id>();
    for(Group gp : groupList){
        groupListId.add(gp.Id);
    }

    List<LeadShare> leadShareList = fetchLeadShares(groupListId, isReminder);

    Map<String, List<LeadShare>> groupWiseLeadsMap = buildGroupWiseLeadsMap(leadShareList);

    Map<String, List<LeadShare>> userWiseLeadShareMap = buildUserWiseLeadShareMap(groupWiseGroupMemberMap, groupWiseLeadsMap);

    handleRubyTeamChanges(groupWiseLeadsMap);

    Map<Id, Lead> leadIdMap = fetchLeadsFromLeadShares(leadShareList);

    Map<String, List<Lead>> userWiseLeadsMap = mapUserToLeads(userWiseLeadShareMap, leadIdMap);

    sendEmailsWithLogging(userWiseLeadsMap, isReminder);
}

    private static List<String> buildGroupNameList(List<Account> opidList, List<String> partnerSegmentList) {
        List<String> groupNameList = new List<String>();
        for(Account acc : opidList){
            groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(acc.Id, adminPublicGroupNameSuffix));
            for(String segment : partnerSegmentList){
                groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(acc.Id, segment));
            }
        }
        return groupNameList;
    }

    private static Map<String, List<GroupMember>> buildGroupWiseGroupMemberMap(List<Group> groupList) {
        List<Id> groupListId = new List<Id>();
        for(Group gp : groupList){
            groupListId.add(gp.Id);
        }
        List<GroupMember> gmList = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE GroupId IN :groupListId];
        Map<String, List<GroupMember>> Storemap = new Map<String, List<GroupMember>>();
        for(GroupMember gm : gmList){
            if(String.valueOf(gm.UserOrGroupId).startsWith('005')){
                if(!Storemap.containsKey(gm.GroupId)){
                    Storemap.put(gm.GroupId, new List<GroupMember>());
                }
                Storemap.get(gm.GroupId).add(gm);
            }
        }
        return Storemap;
    }

    private static List<LeadShare> fetchLeadShares(List<Id> groupListId, Boolean isReminder) {
        Date today = Date.today();
        String leadStatus = 'New';
        String leadStatusPLCL = Label.Core_Disposition_as_PLCL_Status;
        String leadStage = 'Rejected';
        String leadState = 'Terminated';

        if(!isReminder){
            return [SELECT Id, UserOrGroupId, LeadId, Lead.Status, Lead.Core_Lead_Status__c, Lead.Core_Lead_State__c, Lead.Core_Partner_Lead_Owner__c FROM LeadShare WHERE UserOrGroupId IN :groupListId AND Lead.CreatedDate = :today AND Lead.Core_Lead_Status__c != :leadStatusPLCL];
        } else {
            return [SELECT Id, UserOrGroupId, LeadId, Lead.Status, Lead.Core_Lead_Status__c, Lead.Core_Lead_State__c, Lead.Core_Partner_Lead_Owner__c FROM LeadShare  WHERE UserOrGroupId IN :groupListId AND (Lead.Core_1st_Reminder__c = :today OR Lead.Core_2nd_Reminder__c = :today OR Lead.Core_3rd_Reminder__c = :today OR Lead.Core_4th_Reminder__c = :today) AND Lead.Core_Lead_Status__c = :leadStatus AND Lead.Status != :leadStage AND Lead.Core_Lead_State__c != :leadState];
        }
    }

    private static Map<String, List<LeadShare>> buildGroupWiseLeadsMap(List<LeadShare> leadShareList) {
        Map<String, List<LeadShare>> Storemap = new Map<String, List<LeadShare>>();
        for(LeadShare ledShare : leadShareList){
            if(!Storemap.containsKey(ledShare.UserOrGroupId)){
                Storemap.put(ledShare.UserOrGroupId, new List<LeadShare>());
            }
            Storemap.get(ledShare.UserOrGroupId).add(ledShare);
        }
        return Storemap;
    }

    private static Map<String, List<LeadShare>> buildUserWiseLeadShareMap(Map<String, List<GroupMember>> groupWiseGroupMemberMap, Map<String, List<LeadShare>> groupWiseLeadsMap) {
        Map<String, List<LeadShare>> Storemap = new Map<String, List<LeadShare>>();
        for(String grId : groupWiseGroupMemberMap.keySet()){
            if(groupWiseLeadsMap.containsKey(grId)){
                for(GroupMember gm : groupWiseGroupMemberMap.get(grId)){
                    if(!Storemap.containsKey(gm.UserOrGroupId)){
                        Storemap.put(gm.UserOrGroupId, new List<LeadShare>());
                    }
                    Storemap.get(gm.UserOrGroupId).addAll(groupWiseLeadsMap.get(grId));
                }
            }
        }
        return Storemap;
    }

    private static void handleRubyTeamChanges(Map<String, List<LeadShare>> groupWiseLeadsMap) {
        if(groupWiseLeadsMap.isEmpty()) { return; }

        Set<String> userIdSet = fetchUserIdsFromGroupMembers(groupWiseLeadsMap.keySet());
        if(userIdSet.isEmpty()) { return; }

        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Intel_Account).getRecordTypeId();

        Set<Id> opidAccSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();

        SWS_LeadWrappers.PopulateAccountSetsCtx p = new SWS_LeadWrappers.PopulateAccountSetsCtx();
        p.userIdSet = userIdSet;
        p.intelAccRecTypeId = intelAccRecTypeId;
        p.opidAccSet = opidAccSet;
        p.accIdSet = accIdSet;
        populateAccountSets(p);

        enrichAccountSetFromGroupMembers(opidAccSet, accIdSet);

        if(!accIdSet.isEmpty()){
            PRM_SendNotificationMessages.upsertMsgLogRecs(new List<Id>(accIdSet), System.label.PRM_Msgcd_NewLead);
        }
    }

    private static Set<String> fetchUserIdsFromGroupMembers(Set<String> groupIds){
        Set<String> userIdSet = new Set<String>();
        for(GroupMember gm : [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIds]){
            if(gm.UserOrGroupId != null){
                userIdSet.add(gm.UserOrGroupId);
            }
        }
        return userIdSet;
    }

    // Moved to SWS_LeadWrappers.PopulateAccountSetsCtx
    private static void populateAccountSets(SWS_LeadWrappers.PopulateAccountSetsCtx ctx){
        for(User us : [SELECT Id, Name, AccountId, Core_IPA_One_Partner_Id__c FROM User WHERE Id IN :ctx.userIdSet AND Account.RecordTypeId = :ctx.intelAccRecTypeId AND Account.Core_Intel_Partner_Alliance_PartnerGroup__c = true]){
            if(us.Core_IPA_One_Partner_Id__c != null){
                ctx.opidAccSet.add(us.Core_IPA_One_Partner_Id__c);
            } else if(us.AccountId != null && us.Core_IPA_One_Partner_Id__c == null && !ctx.accIdSet.contains(us.AccountId)){
                ctx.accIdSet.add(us.AccountId);
            }
        }
    }

    private static void enrichAccountSetFromGroupMembers(Set<Id> opidAccSet, Set<Id> accIdSet){
        if(opidAccSet.isEmpty()) { return; }

        for(Core_Account_Group_Member__c cagm : [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c IN :opidAccSet AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true AND Core_Inactive_Ind__c = false]){
            if(!accIdSet.contains(cagm.Core_Intel_Account_Id__c)){
                accIdSet.add(cagm.Core_Intel_Account_Id__c);
            }
        }
    }

    private static Map<Id, Lead> fetchLeadsFromLeadShares(List<LeadShare> leadShareList) {
        Set<Id> LeadIds = new Set<Id>();
        for(LeadShare ledShare : leadShareList){
            LeadIds.add(ledShare.LeadId);
        }
        List<Lead> leadList = [SELECT Id, Country, FirstName, LastName, Core_Is_Lead_Shared__c, Company, Core_Lead_Source_Pkt__c, Core_Lead_PMP_Action__c,OwnerId, Core_PSG_Lead__c, Core_1st_Reminder__c, Core_2nd_Reminder__c, Core_3rd_Reminder__c, Core_4th_Reminder__c, CreatedDate FROM Lead WHERE Id IN :LeadIds];
        Map<Id, Lead> LeadIdMap = new Map<Id, Lead>();
        for(Lead ld : leadList){
            LeadIdMap.put(ld.Id, ld);
        }
        return LeadIdMap;
    }

    private static Map<String, List<Lead>> mapUserToLeads(Map<String, List<LeadShare>> userWiseLeadShareMap, Map<Id, Lead> LeadIdMap) {
        Map<String, List<Lead>> userWiseLeadsMap = new Map<String, List<Lead>>();
        for(String userId : userWiseLeadShareMap.keySet()){
            List<LeadShare> leadShares = userWiseLeadShareMap.get(userId);
            List<Lead> leads = new List<Lead>();
            for(LeadShare ls : leadShares){
                if(LeadIdMap.containsKey(ls.LeadId)) {
                    leads.add(LeadIdMap.get(ls.LeadId));
                }
            }
            userWiseLeadsMap.put(userId, leads);
        }
        return userWiseLeadsMap;
    }

    private static void sendEmailsWithLogging(Map<String, List<Lead>> userWiseLeadsMap, Boolean isReminder) {
        try {
            List<Messaging.SingleEmailMessage> emailList = sendLeadSummaryEmail(new List<Messaging.SingleEmailMessage>(), userWiseLeadsMap, isReminder);

            if (!emailList.isEmpty()) {
                List<PRM_EmailLog__c> emailLogList = buildEmailLogList(emailList);
                Map<String, PRM_EmailLog__c> targetIdLog = mapEmailLogsByUser(emailLogList);

                List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(emailList, false);

                updateEmailLogsWithErrors(resultList, targetIdLog);

                insert emailLogList;
            }
        } catch(Exception e) {
            insert buildExceptionLog(e);
        }
    }

    private static List<PRM_EmailLog__c> buildEmailLogList(List<Messaging.SingleEmailMessage> emailList) {
        List<PRM_EmailLog__c> emailLogs = new List<PRM_EmailLog__c>();
        for (Messaging.SingleEmailMessage mail : emailList) {
            PRM_EmailLog__c emailLog = new PRM_EmailLog__c();
            emailLog.PRM_EmailContent__c = mail.getHtmlBody();
            emailLog.PRM_EmailDeliverabilityStatus__c = true;
            emailLog.PRM_Subject__c = mail.getSubject();
            emailLog.PRM_Timestamp__c = DateTime.now();
            emailLog.PRM_User__c = mail.getToAddresses()[0];
            emailLog.PRM_Email_API_Response__c = 'Mail sent successfully !!';
            emailLogs.add(emailLog);
        }
        return emailLogs;
    }

    private static Map<String, PRM_EmailLog__c> mapEmailLogsByUser(List<PRM_EmailLog__c> emailLogList) {
        Map<String, PRM_EmailLog__c> targetIdLog = new Map<String, PRM_EmailLog__c>();
        for (PRM_EmailLog__c log : emailLogList) {
            targetIdLog.put(log.PRM_User__c, log);
        }
        return targetIdLog;
    }

    private static void updateEmailLogsWithErrors(List<Messaging.SendEmailResult> resultList, Map<String, PRM_EmailLog__c> targetIdLog) {
        for (Messaging.SendEmailResult result : resultList) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    String targetId = error.getTargetObjectId();
                    if (targetId != null && targetIdLog.containsKey(targetId)) {
                        PRM_EmailLog__c log = targetIdLog.get(targetId);
                        log.PRM_EmailDeliverabilityStatus__c = false;
                        log.PRM_Email_API_Response__c = error.getMessage();
                    }
                }
            }
        }
    }

    private static Core_Exceptions__c buildExceptionLog(Exception e) {
        Core_Exceptions__c excep = new Core_Exceptions__c();
        excep.Core_Class_Name__c = 'Core_PartnerLeadHandler';
        excep.Core_Method_Name__c = 'sendNotificationEmails';
        excep.Core_Exception__c = e.getStackTraceString() + ';' + e.getCause() + ';' + e.getMessage();
        excep.Core_IPS_Object_Name__c = 'Lead';
        excep.Core_Login_User_Id__c = UserInfo.getUserId();
        return excep;
    }


    public static List<Messaging.SingleEmailMessage> sendLeadSummaryEmail(List<Messaging.SingleEmailMessage> emailList, 
              Map<String, List<Lead>> userWiseLeadMap, boolean isReminder){
                                                                              
                 List<Lead> listOfLead;
                  for(String userId : userWiseLeadMap.keyset()){
                    if(isReminder || (!isReminder && userWiseLeadMap.get(userId).size() >= Integer.valueOf(System.Label.Core_SummaryEmailMinLeadCount))){
                            listOfLead = new List<Lead>();
                            listOfLead.addAll(userWiseLeadMap.get(userId));
                            SWS_LeadWrappers.PrepareEmailCtx pec = new SWS_LeadWrappers.PrepareEmailCtx();
                            pec.isReminder = isReminder;
                            pec.userId = userId;
                            pec.leadList = listOfLead;
                            pec.emailList = emailList;
                            emailList = Core_PartnerLeadHandler.prepareGroupWiseEmail(pec);
                                         }
                                      }
                              return emailList;
                                                                              
                          }
    
}