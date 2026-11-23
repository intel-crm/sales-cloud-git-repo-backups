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
    
    public static Boolean isLeadShared = false;
    
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
    
    public static void populateSegmentMpiInPartnerLeads(List<Lead> newLeads, Boolean isInsert){
        List<Lead> finalLeadList = new List<Lead>();
        Map<String,List<Lead>> marketingProfileLeadsMap = new Map<String,List<Lead>>();
        Map<String,List<Lead>> partnernameLeadsMap = new Map<String,List<Lead>>();
        Map<String,List<Lead>> offeringIdLeadsMap = new Map<String,List<Lead>>();
        for(Lead led : newLeads){
            if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c <> null){
                marketingProfileLeadsMap = generateGroupsNLeadsMap(led, led.PMP_MDA_BizOrg_Id__c, marketingProfileLeadsMap);
                if(led.PMP_Offering_Id__c <> null){
                    offeringIdLeadsMap = generateGroupsNLeadsMap(led, led.PMP_Offering_Id__c, offeringIdLeadsMap);
                }
                finalLeadList.add(led);
            }else if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c == null && led.Core_Partner_Name__c <> null){
                partnernameLeadsMap = generateGroupsNLeadsMap(led, led.Core_Partner_Name__c.toLowerCase(), partnernameLeadsMap);
                finalLeadList.add(led);
            }else if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c == null && !led.Core_Is_Lead_Shared__c && led.PMP_MDA_BizOrg_Id__c == null && led.Core_Partner_Name__c == null){
                led.Core_Lead_Sharing_Error__c = system.label.Core_No_PartnerId_PartnerName;
                led.Core_Reprocess_Lead_Sharing__c = false;
            }
        }
        
        if(!partnernameLeadsMap.isEmpty()){
            Map<String,Core_Partner_Queue_Mapping__c> partnerNameNQueueMap = new Map<String,Core_Partner_Queue_Mapping__c>();
            Map<String,Set<Lead>> OPIDLeadSetMap = new Map<String,Set<Lead>>();
            Set<Lead> tempSet;
            List<Core_Partner_Queue_Mapping__c> partnerQueueMappingList = [select Id, Core_Partner_Name__c, PMP_MDA_BizOrg_Id__c from Core_Partner_Queue_Mapping__c where Core_Partner_Name__c IN: partnernameLeadsMap.keySet()];
            for(Core_Partner_Queue_Mapping__c pqm : partnerQueueMappingList){
                if(pqm.PMP_MDA_BizOrg_Id__c <> null){
                    if(OPIDLeadSetMap.containsKey(pqm.PMP_MDA_BizOrg_Id__c)){
                        tempSet = OPIDLeadSetMap.get(pqm.PMP_MDA_BizOrg_Id__c);
                    }else{
                        tempSet = new Set<Lead>();
                    }
                    tempSet.addAll(partnernameLeadsMap.get(pqm.Core_Partner_Name__c.toLowerCase()));
                    OPIDLeadSetMap.put(pqm.PMP_MDA_BizOrg_Id__c, tempSet);
                }
                partnerNameNQueueMap.put(pqm.Core_Partner_Name__c.toLowerCase(),pqm);
            }
            
            List<PMP_OPID_MPI_Rel__c> OMRList = [select id, PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c, Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c IN: OPIDLeadSetMap.keyset() AND PMP_Marketing_Profile_Id__c <> null AND Is_Active__c = true];
            for(PMP_OPID_MPI_Rel__c omr : OMRList){
                for(Lead led : OPIDLeadSetMap.get(omr.PMP_One_Partner_ID__c)){
                    led.Core_MPI_Id__c = omr.PMP_Marketing_Profile_Id__c;
                    if(omr.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c <> null){
                        led.PMP_MktProfile_BizSegment__c = omr.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c;
                    }else{
                        led.Core_Lead_Sharing_Error__c = system.label.Core_No_PartnerSegment;
                        led.Core_Reprocess_Lead_Sharing__c = false;
                    }
                }
            }
            
            for(String partnerName : partnernameLeadsMap.keyset()){
                if(partnerNameNQueueMap.containskey(partnerName) && partnerNameNQueueMap.get(partnerName).PMP_MDA_BizOrg_Id__c == null){
                    for(Lead led : partnernameLeadsMap.get(partnerName)){
                        led.Core_Lead_Sharing_Error__c = system.label.Core_No_PartnerId_In_Queue;
                        led.Core_Reprocess_Lead_Sharing__c = false;
                    }
                }else if(!partnerNameNQueueMap.containskey(partnerName)){
                    for(Lead led : partnernameLeadsMap.get(partnerName)){
                        led.Core_Lead_Sharing_Error__c = system.label.Core_NoQueueMap;
                        led.Core_Reprocess_Lead_Sharing__c = false;
                    }
                }
            }
        }
        
        if(!marketingProfileLeadsMap.isEmpty()){
            if(!offeringIdLeadsMap.isEmpty()){
                List<PMP_Partner_Offering__c> offeringList = [select Id, PMP_Offering_Id__c, ToLabel(PMP_Business_Segment_Nm__c) from PMP_Partner_Offering__c where PMP_Offering_Id__c IN: offeringIdLeadsMap.keyset()];
                for(PMP_Partner_Offering__c offering : offeringList){
                    if(offering.PMP_Business_Segment_Nm__c <> null){
                        for(Lead led : offeringIdLeadsMap.get(offering.PMP_Offering_Id__c)){
                            led.PMP_MktProfile_BizSegment__c = offering.PMP_Business_Segment_Nm__c;
                            led.Core_Is_Segment_Available_In_Offering__c = true;
                        }
                    }
                }
            }
            
            Set<String> mpiIdSet = new Set<String>();
            List<PMP_OPID_MPI_Rel__c> OMRList = [select id, PMP_Marketing_Profile_Id__c, PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c, Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, Is_Active__c from PMP_OPID_MPI_Rel__c where Core_Marketing_Profile_Id__c IN: marketingProfileLeadsMap.keyset() AND PMP_One_Partner_ID__c <> null AND Is_Active__c = true];
            for(PMP_OPID_MPI_Rel__c omr : OMRList){
                mpiIdSet.add(omr.Core_Marketing_Profile_Id__c);
                for(Lead led : marketingProfileLeadsMap.get(omr.Core_Marketing_Profile_Id__c)){
                    led.Core_MPI_Id__c = omr.PMP_Marketing_Profile_Id__c;
                    if(led.PMP_MktProfile_BizSegment__c == null && omr.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c <> null){
                        led.PMP_MktProfile_BizSegment__c = omr.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c;
                    }else if(led.PMP_MktProfile_BizSegment__c == null && omr.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c == null){
                        led.Core_Lead_Sharing_Error__c = system.label.Core_No_PartnerSegment;
                        led.Core_Reprocess_Lead_Sharing__c = false;
                    }
                }
            }
            for(String mpiId : marketingProfileLeadsMap.keyset()){
                if(!mpiIdSet.contains(mpiId)){
                    for(Lead led : marketingProfileLeadsMap.get(mpiId)){
                        led.Core_Lead_Sharing_Error__c = system.label.Core_MDA_NotLinked;
                        led.Core_Reprocess_Lead_Sharing__c = false;
                    }
                }
            }
        }
        
        if(!isInsert && !finalLeadList.isEmpty()){
            populateGroupsToRoutePartnerLead(finalLeadList);
        }
    }
    
    /*
* Method name  : partnerLeadRoutingToGroup
* Description  : Method to update correct public group on lead
* Return Type  : void
* Parameter    : List<Lead> newLeads, Boolean isInsert
*/
    public static void populateGroupsToRoutePartnerLead(List<Lead> newLeads){
        Map<String,List<Lead>> allMPILeadsMap = new Map<String,List<Lead>>();
        Map<String,List<Lead>> offeringRelatedMPILeadsMap = new Map<String,List<Lead>>();
        List<Lead> finalLeadList = new List<Lead>();
        //Grouping leads as per partner id and partner name
        for(Lead led : newLeads){
            if(led.RecordTypeId == partnerRecTypeId && led.Core_MPI_Id__c <> null && !led.Core_Is_Lead_Shared__c){
                finalLeadList.add(led);
                allMPILeadsMap = generateGroupsNLeadsMap(led, led.Core_MPI_Id__c, allMPILeadsMap);
                if(led.Core_Is_Segment_Available_In_Offering__c){
                    offeringRelatedMPILeadsMap = generateGroupsNLeadsMap(led, led.Core_MPI_Id__c, offeringRelatedMPILeadsMap);
                }
            }
        }
        
        if(!allMPILeadsMap.isEmpty()){
            Map<String,List<String>> OPIDLeadSegmentMap = new Map<String,List<String>>();
            Map<String,List<String>> OPIDLeadGroupNameMap = new Map<String,List<String>>();
            Map<String,String> OPIDLeadGroupIdsMap = new Map<String,String>();
            List<String> tempList;
            List<PMP_OPID_MPI_Rel__c> OMRList = [select id, PMP_Marketing_Profile_Id__c, Core_Marketing_Profile_Id__c, PMP_One_Partner_ID__c, PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c, Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c IN: allMPILeadsMap.keyset() AND PMP_One_Partner_ID__c <> null AND PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c <> null AND Is_Active__c = true];
            for(PMP_OPID_MPI_Rel__c OMR : OMRList){
                if(offeringRelatedMPILeadsMap.containsKey(OMR.PMP_Marketing_Profile_Id__c)){
                    for(Lead led : offeringRelatedMPILeadsMap.get(OMR.PMP_Marketing_Profile_Id__c)){
                        if(OMR.PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c.contains(led.PMP_MktProfile_BizSegment__c)){
                            OPIDLeadSegmentMap.put(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id, led.PMP_MktProfile_BizSegment__c.split(SYMB_SEMICOLON));
                        }
                    }
                }
                for(Lead led : allMPILeadsMap.get(OMR.PMP_Marketing_Profile_Id__c)){
                    if(!OPIDLeadSegmentMap.containsKey(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id)){
                        OPIDLeadSegmentMap.put(OMR.PMP_One_Partner_ID__c + SYMB_SEMICOLON + led.Id, OMR.PMP_One_Partner_ID__r.Core_IPA_Partner_Segment__c.split(SYMB_SEMICOLON));
                    }
                }
            }
            if(!OPIDLeadSegmentMap.isEmpty()){
                Set<String> groupNames = new Set<String>();
                for(String opidLead : OPIDLeadSegmentMap.keyset()){
                    tempList = new List<String>();
                    tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],adminPublicGroupNameSuffix));
                    tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],empPublicGroupNameSuffix));
                    OPIDLeadGroupNameMap.put(opidLead, tempList);
                    for(String segment : OPIDLeadSegmentMap.get(opidLead)){
                        if(OPIDLeadGroupNameMap.containsKey(opidLead)){
                            tempList = OPIDLeadGroupNameMap.get(opidLead);
                        }
                        tempList.add(generatePartnerKey(opidLead.split(SYMB_SEMICOLON)[0],segment));
                        OPIDLeadGroupNameMap.put(opidLead, tempList);
                    }
                    groupNames.addAll(OPIDLeadGroupNameMap.get(opidLead));
                }
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
                
                if(!finalLeadList.isEmpty()){
                    List<Core_OPID_Lead_Relationship__c> oldOLRList = [select Id, Core_Lead_Name__c, Core_OPID_Name__c from Core_OPID_Lead_Relationship__c where Core_Lead_Name__c IN: finalLeadList];
                    if(!oldOLRList.isEmpty()){
                        delete oldOLRList;
                    }
                }
                
                List<Core_OPID_Lead_Relationship__c> finalOLRList = new List<Core_OPID_Lead_Relationship__c>();
                Core_OPID_Lead_Relationship__c tempOLR;
                String tempGroupIds;
                for(String opidLead : OPIDLeadGroupNameMap.keyset()){
                    tempGroupIds = '';
                    for(String grName : OPIDLeadGroupNameMap.get(opidLead)){
                        if(groupsMap.containsKey(grName)){
                            tempGroupIds = tempGroupIds + groupsMap.get(grName).Id + SYMB_SEMICOLON;
                        }
                    }
                    if(tempGroupIds <> ''){
                        tempOLR = new Core_OPID_Lead_Relationship__c();
                        tempOLR.Core_Lead_Name__c = opidLead.split(SYMB_SEMICOLON)[1];
                        tempOLR.Core_OPID_Name__c = opidLead.split(SYMB_SEMICOLON)[0];
                        tempOLR.Core_Public_Group_Ids__c = tempGroupIds.removeEnd(SYMB_SEMICOLON);
                        finalOLRList.add(tempOLR);
                    }
                }
                insert finalOLRList;
            }
        }
    }
    
    public static void partnerLeadOwnerUpdate(List<Lead> newLeads){
        List<Lead> allLeads = new List<Lead>();
        Lead leadObj;
        Map<String, Integer> leadOPIDCountMap = new Map<String, Integer>();
        List<AggregateResult> OLRList = [select Core_Lead_Name__c, count(Core_OPID_Name__c)OPIDCount from Core_OPID_Lead_Relationship__c group by Core_Lead_Name__c];
        for(AggregateResult olr : OLRList){
            leadOPIDCountMap.put(String.valueOf(olr.get('Core_Lead_Name__c')), Integer.valueOf(olr.get('OPIDCount')));
        }
        /**********************Update Owner Id**********************/
        for(Lead led : newLeads){
            if(!leadOPIDCountMap.containsKey(led.Id) && led.Core_MPI_Id__c <> null && led.RecordTypeId == partnerRecTypeId && led.OwnerId == System.Label.Core_Partner_Global_Queue_Id){
                leadObj = new Lead();
                leadObj.Id = led.Id;
                leadObj.OwnerId = System.Label.Core_Partner_Invalid_Queue_Id;
                allLeads.add(leadObj);
            }else if(leadOPIDCountMap.containsKey(led.Id) && leadOPIDCountMap.get(led.Id) > 0 && led.Core_MPI_Id__c <> null && led.RecordTypeId == partnerRecTypeId && (led.OwnerId == System.Label.Core_Partner_Global_Queue_Id || led.OwnerId == System.Label.Core_Partner_Invalid_Queue_Id)){
                leadObj = new Lead();
                leadObj.Id = led.Id;
                leadObj.OwnerId = System.Label.Core_Salesforce_System_User_Id;
                allLeads.add(leadObj);
            }
        }
        try{
            update allLeads;
        }catch(Exception e){
            system.debug('Error on updating lead owner '+e.getMessage());
        }
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
        try{
            isLeadShared = true;
            List<Lead> finalLeadList = new List<Lead>();
            for(Lead led : leadList){
                if(!led.Core_Is_Lead_Shared__c && led.Core_MPI_Id__c <> null){
                    finalLeadList.add(led);
                }
            }
            if(!finalLeadList.isEmpty()){
                Map<String,Lead> finalLeadMap = new Map<String,Lead>();
                Map<String,List<String>> finalGroupsNLeadsMap = new Map<String,List<String>>();
                List<String> tempLeads;
                Lead tempLead;
                List<Core_OPID_Lead_Relationship__c> OLRList = [select Id, Core_Lead_Name__c, Core_OPID_Name__c, Core_Public_Group_Ids__c from Core_OPID_Lead_Relationship__c where Core_Lead_Name__c IN: finalLeadList];
                for(Core_OPID_Lead_Relationship__c olr : OLRList){
                    for(String grId : olr.Core_Public_Group_Ids__c.split(SYMB_SEMICOLON)){
                        if(finalGroupsNLeadsMap.containsKey(grId)){
                            tempLeads = finalGroupsNLeadsMap.get(grId);
                        }else{
                            tempLeads = new List<String>();
                        }
                        tempLeads.add(olr.Core_Lead_Name__c);
                        finalGroupsNLeadsMap.put(grId, tempLeads);
                    }
                    tempLead = new Lead();
                    tempLead.Id = olr.Core_Lead_Name__c;
                    tempLead.Core_Is_Lead_Shared__c = true;
                    tempLead.Core_Reprocess_Lead_Sharing__c = false;
                    tempLead.Core_Lead_Sharing_Error__c = null;
                    finalLeadMap.put(olr.Core_Lead_Name__c, tempLead);
                }
                if(!finalLeadMap.isEmpty()){
                    update finalLeadMap.values();
                }
                
                List<LeadShare> finalLeadShrList = new List<LeadShare>();
                LeadShare leadShr;
                if(!finalGroupsNLeadsMap.isEmpty()){
                    List<Group> groupList = [select Id, Name from Group where Id IN: finalGroupsNLeadsMap.keyset()];
                    Map<String, String> grIdNameMap = new Map<String, String>();
                    for(Group gr : groupList){
                        grIdNameMap.put(gr.Id, gr.Name.split('_')[2]);
                    }
                    for(String grpId : finalGroupsNLeadsMap.keyset()){
                        for(String ledId : finalGroupsNLeadsMap.get(grpId)){
                            leadShr  = new LeadShare();
                            leadShr.LeadId = ledId;
                            leadShr.UserOrGroupId = grpId;
                            if(grIdNameMap.get(grpId) == empPublicGroupNameSuffix){
                                leadShr.LeadAccessLevel = 'Read';
                            }else{
                                leadShr.LeadAccessLevel = 'Edit';
                            }
                            finalLeadShrList.add(leadShr);
                        }
                    }
                    if(!finalLeadShrList.isEmpty()){
                        insert finalLeadShrList;
                    }
                }
            }
        }catch(Exception e){
            for(Lead led : leadList){
                led.addError('Error in lead share, please contact system admin with this error details: '+e.getStackTraceString());
            }
        }
    }
    
    /*
* Method name  : sendNotificationEmails
* Description  : Method to filter psg and non psg leads and send notification email
* Return Type  : void
* Parameter    : List<Lead> leadList, Boolean isReminder
*/
    public static void sendNotificationEmails(List<Lead> leadList, Boolean isReminder){
        List<Lead> allLeads = new List<Lead>();
        
        for(Lead led : leadList){
            if(led.Core_Is_Lead_Shared__c){
                allLeads.add(led);
            }
        }
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList = sendLeadSummary(emailList,allLeads,isReminder);
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }
    }
    
    /*
* Method name  : sendLeadSummary
* Description  : Method to send lead summary and reminder lead summary
* Return Type  : List<Messaging.SingleEmailMessage>
* Parameter    : List<Messaging.SingleEmailMessage> emailList, List<Lead> leadList, boolean isReminder, Boolean isPsg
*/
    //Added Ruby team logic in this method to send Notification Messages to Account contacts - Bharath: US651055
    public static List<Messaging.SingleEmailMessage> sendLeadSummary(List<Messaging.SingleEmailMessage> emailList, List<Lead> leadList, boolean isReminder){
        Map<String,List<Lead>> groupWiseLeadMap = new Map<String,List<Lead>>();
        Map<String,List<Lead>> tempGroupWiseLeadMap = new Map<String,List<Lead>>();
        Set<String> groupIdSet = new Set<String>();
        Set<String> userIdSet = new Set<String>();
        List<Id> accIdList = new List<Id>();
        Set<Id> opidAccSet = new Set<Id>();
        Map<String,List<String>> finalGroupsNLeadsMap = new Map<String,List<String>>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>(leadList);
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.PRM_Intel_Account).getRecordTypeId();
        
        List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst=[Select id,Core_Lead_Name__c, Core_Public_Group_Ids__c, Core_OPID_Name__c from Core_OPID_Lead_Relationship__c  Where Core_Lead_Name__c IN :leadList];
        for(Core_OPID_Lead_Relationship__c olr : LeadOPIDSlst){
            for(String Str : olr.Core_Public_Group_Ids__c.split(SYMB_SEMICOLON)){
                groupIdSet.add(Str);
                if(finalGroupsNLeadsMap.containsKey(olr.Core_Lead_Name__c)){
                    finalGroupsNLeadsMap.get(olr.Core_Lead_Name__c).add(Str);
                }
                else{
                    finalGroupsNLeadsMap.put(olr.Core_Lead_Name__c,new List<String>{Str});
                }
            }
        }
        System.debug('OPIDMAP'+finalGroupsNLeadsMap);
        
        /* Ruby Team Changes Start */
        if(groupIdSet.size() > 0){
            //Query on Group Member to fetch the User Id
            for(GroupMember gm:[Select Id,GroupId, UserOrGroupId from GroupMember where GroupId IN :groupIdSet]){
                if(gm.UserOrGroupId != null){
                    userIdSet.add(gm.UserOrGroupId);
                }
            }
            
            if(userIdSet.size() > 0){
                for(User us:[Select Id,Name,AccountId,Core_IPA_One_Partner_Id__c from User where Id IN :userIdSet AND Account.RecordTypeId = :intelAccRecTypeId AND Account.Core_Intel_Partner_Alliance_PartnerGroup__c = true]){
                    if(us.Core_IPA_One_Partner_Id__c != null){
                        opidAccSet.add(us.Core_IPA_One_Partner_Id__c);
                    }
                    else if(us.AccountId != null && us.Core_IPA_One_Partner_Id__c == null && !accIdList.contains(us.AccountId)){
                        accIdList.add(us.AccountId);
                    }
                }
                if(opidAccSet.size() > 0){
                    for (Core_Account_Group_Member__c cagm:[Select Id,Name,Core_Partner_Account_Id__c, Core_Intel_Account_Id__c From Core_Account_Group_Member__c Where Core_Partner_Account_Id__c = :opidAccSet AND Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Inactive_Ind__c = false]){
                        if(!accIdList.contains(cagm.Core_Intel_Account_Id__c)){
                            accIdList.add(cagm.Core_Intel_Account_Id__c);
                        }
                    }
                }
            }
            if(!accIdList.isEmpty() && accIdList.size() > 0){
                PRM_SendNotificationMessages.upsertMsgLogRecs(accIdList,System.label.PRM_Msgcd_NewLead); //Invoking Ruby team apex class to send Notification Messages
            }
        }
        /* Ruby Team changes End */
        
        for( String led : finalGroupsNLeadsMap.keySet()){
            List<String> PublicGroupIds = finalGroupsNLeadsMap.get(led);
            system.debug('***PublicGroupIds'+PublicGroupIds);
            
            for(String Gid : PublicGroupIds){
                tempGroupWiseLeadMap = generateGroupsNLeadsMap(leadMap.get(led),Gid,tempGroupWiseLeadMap);
            }
        }
        
        //filter out the leadsOfEmployees public group to not send any email notifications
        Map<Id,Group> groupsMap = new Map<Id,Group>([select Id, developerName from Group where Id IN: tempGroupWiseLeadMap.keyset() AND Type =: 'Regular']);
        for(String grId : tempGroupWiseLeadMap.keyset()){
            if(groupsMap.containskey(grId)){
                if(groupsMap.get(grId).developerName.split('_').size() >= 3 && groupsMap.get(grId).developerName.split('_')[2] <> empPublicGroupNameSuffix){
                    groupWiseLeadMap.put(grId,tempGroupWiseLeadMap.get(grId));
                }
            }else{
                groupWiseLeadMap.put(grId,tempGroupWiseLeadMap.get(grId));
            }
        }
        
        List<GroupMember> gmList = [Select Id, UserOrGroupId,GroupId From GroupMember where GroupId IN: groupWiseLeadMap.keyset()];
        List<String> tempIdList = new List<String>();
        for(GroupMember gm : gmList){
            tempIdList.add(gm.UserOrGroupId);
        }
        Map<Id,User> userIdmap = new Map<Id,User>([select Id from User where Id IN: tempIdList]);
        Map<String,List<String>> userWiseGroupMap = new Map<String,List<String>>();
        for(GroupMember gm : gmList){
            if(userIdmap.containskey(gm.UserOrGroupId)){
                if(userWiseGroupMap.containsKey(gm.UserOrGroupId)){
                    tempIdList = userWiseGroupMap.get(gm.UserOrGroupId);
                }else{
                    tempIdList = new List<String>();
                }
                tempIdList.add(gm.GroupId);
                userWiseGroupMap.put(gm.UserOrGroupId,tempIdList);
            }
        }
        
        Map<String,Set<Lead>> userWiseLeadMap = new Map<String,Set<Lead>>();
        Set<Lead> tempLeadSet = new Set<Lead>();
        for(String userId : userWiseGroupMap.keyset()){
            tempLeadSet = new Set<Lead>();
            for(String groupId : userWiseGroupMap.get(userId)){
                tempLeadSet.addAll(groupWiseLeadMap.get(groupId));
            }
            userWiseLeadMap.put(userId,tempLeadSet);
        }
        
        List<Lead> listOfLead;
        for(String userId : userWiseLeadMap.keyset()){
            if(isReminder || (!isReminder && userWiseLeadMap.get(userId).size() >= Integer.valueOf(System.Label.Core_SummaryEmailMinLeadCount))){
                listOfLead = new List<Lead>();
                listOfLead.addAll(userWiseLeadMap.get(userId));
                emailList = prepareGroupWiseEmail(isReminder, userId, listOfLead, emailList);
            }
        }
        return emailList;
    }
    
    /*
* Method name  : prepareGroupWiseEmail
* Description  : Method to prepare group wise email.
* Return Type  : List<Messaging.SingleEmailMessage>
* Parameter    : String groupName, List<String> userIdList, List<Lead> leadList, OrgWideEmailAddress owea, List<Messaging.SingleEmailMessage> emailList
*/
    public static List<Messaging.SingleEmailMessage> prepareGroupWiseEmail(Boolean isReminder, String userId, List<Lead> leadList, List<Messaging.SingleEmailMessage> emailList){
        List<String> userIdList = new List<String>();
        userIdList.add(userId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(userIdList);
        if(isReminder){
            mail.setSubject('Your Leads: Don’t Forget');
        }else{
            mail.setSubject('New Leads For You');
        }
        mail.setHtmlBody(prepareHtmlBody(leadList,isReminder));
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        emailList.add(mail);
        return emailList;
    }
    
    /*
* Method name  : prepareHtmlBody
* Description  : Method to prepare html body
* Return Type  : String
* Parameter    : List<Lead> leadList
*/
    public static String prepareHtmlBody(List<Lead> leadList, Boolean isReminder){
        String logoUrl = System.Label.Core_Intel_Logo_Id+'&oid='+UserInfo.getOrganizationId();
        String intelLeadHelp = System.Label.Core_PartnerLead_Help;
        Integer currYear = date.today().year();
        String baseUrl = System.label.Core_Partner_Community;
        String listViewUrl = baseUrl + '/s/?Lead-filterId=' + System.label.Core_My_Lead_Listview_Id;
        String fontStyle = 'font-family:intel clear;';
        String borderStyle = 'style="border: 1px solid #d3d3d3;padding-left:50px;padding-top:5px;padding-bottom:5px;font-size: 14px;"';
        String emailBody = '<html><body>';
        if(isReminder){
            emailBody = emailBody + '<table style="background-color: #0071c5;'+fontStyle+'" width="75%"><tbody><tr><td style="padding-left: 50px; border: none;"><div style="color: white;"><h1>YOUR LEADS ARE WAITING</h1></div></td><td style="border: none; padding-right: 20px;" align="right"><img src="'+logoUrl+'" /></td></tr></tbody></table>';
            emailBody = emailBody + '<table style="border-collapse: collapse;'+fontStyle+'" width="75%"><tbody><tr><td '+borderStyle+'><p>Hello</p><p>Just a friendly reminder&mdash;but an important one&mdash;Intel has generated leads for you that require your attention.</p><p>If you have already reviewed your leads, thank you! Please <a href="'+baseUrl+'">log in and accept or reject your leads </a>to help us ensure the continued quality of these leads</p><p>If you have <u>not</u> reviewed your leads, please take immediate action by <a href="'+baseUrl+'">logging into your partner portal.</a>Timely follow up with leads is a key factor in determining success.</p><p>Thank you for your partnership!</p><p>Intel® Partner Alliance</p><p><strong>YOUR LEADS</strong></p></td></tr>';
            Map<Integer,List<Lead>> reminderDayWiseLeadsMap = new Map<Integer,List<Lead>>();
            List<Lead> leads = new List<Lead>();
            Date leadCreationDate;
            for(Lead led : leadList){
                leadCreationDate = date.newinstance(led.CreatedDate.year(), led.CreatedDate.month(), led.CreatedDate.day());
                if(reminderDayWiseLeadsMap.containsKey(leadCreationDate.daysBetween(led.Core_1st_Reminder__c)) && led.Core_1st_Reminder__c == date.today()){
                    leads = reminderDayWiseLeadsMap.get(leadCreationDate.daysBetween(led.Core_1st_Reminder__c));
                }else if(reminderDayWiseLeadsMap.containsKey(leadCreationDate.daysBetween(led.Core_2nd_Reminder__c)) && led.Core_2nd_Reminder__c == date.today()){
                    leads = reminderDayWiseLeadsMap.get(leadCreationDate.daysBetween(led.Core_2nd_Reminder__c));
                }else if(reminderDayWiseLeadsMap.containsKey(leadCreationDate.daysBetween(led.Core_3rd_Reminder__c)) && led.Core_3rd_Reminder__c == date.today()){
                    leads = reminderDayWiseLeadsMap.get(leadCreationDate.daysBetween(led.Core_3rd_Reminder__c));
                }else if(reminderDayWiseLeadsMap.containsKey(leadCreationDate.daysBetween(led.Core_4th_Reminder__c)) && led.Core_4th_Reminder__c == date.today()){
                    leads = reminderDayWiseLeadsMap.get(leadCreationDate.daysBetween(led.Core_4th_Reminder__c));
                }else{
                    leads = new List<Lead>();
                }
                leads.add(led);
                if(led.Core_1st_Reminder__c == date.today()){
                    reminderDayWiseLeadsMap.put(leadCreationDate.daysBetween(led.Core_1st_Reminder__c),leads);
                }
                if(led.Core_2nd_Reminder__c == date.today()){
                    reminderDayWiseLeadsMap.put(leadCreationDate.daysBetween(led.Core_2nd_Reminder__c),leads);
                }
                if(led.Core_3rd_Reminder__c == date.today()){
                    reminderDayWiseLeadsMap.put(leadCreationDate.daysBetween(led.Core_3rd_Reminder__c),leads);
                }
                if(led.Core_4th_Reminder__c == date.today()){
                    reminderDayWiseLeadsMap.put(leadCreationDate.daysBetween(led.Core_4th_Reminder__c),leads);
                }
            }
            List<Integer> daysList = new List<Integer>(reminderDayWiseLeadsMap.keyset());
            daysList.sort();
            for(Integer days : daysList){
                emailBody = emailBody + '<tr><td '+borderStyle+'><p><strong>Leads over '+days+' days past due</strong></p>';
                emailBody = prepareDisplayableLeads(baseUrl,listViewUrl,reminderDayWiseLeadsMap.get(days),emailBody,isReminder);
            }
            emailBody = emailBody + '<tr><td '+borderStyle+'><p><a href="'+listViewUrl+'"><b><span style="font-size: 14px">Click here to disposition your leads</span></b></a><br/>Can\'t access the link above?<br/><a href="'+intelLeadHelp+'">View Help for processing Intel leads</a></p></td></tr>';
        }else{
            emailBody = emailBody + '<table style="background-color: #0071c5;'+fontStyle+'" width="75%"><tbody><tr><td style="padding-left: 50px; border: none;"><div style="color: white;"><h1>YOU HAVE NEW LEADS!</h1></div></td><td style="border: none; padding-right: 20px;" align="right"><img src="'+logoUrl+'" /></td></tr></tbody></table>';
            emailBody = emailBody + '<table style="border-collapse: collapse;'+fontStyle+'" width="75%"><tbody><tr><td '+borderStyle+'><p>Hello</p><p><strong>Great news!  Intel has generated New leads</strong> for you. To act on them and help ensure the quality of leads we send you, please promptly <a href="'+baseUrl+'">log in and accept or reject them.</a> To see the full information about these leads, please login and download the Standard Leads Report.</p><p>Thank you for your partnership!</p><p>Intel® Partner Alliance</p><p><strong>YOUR LEADS</strong></p></td></tr>';
            emailBody = emailBody + '<tr><td '+borderStyle+'><p><strong>You have '+leadList.size()+' new leads:</strong></p>';
            emailBody = prepareDisplayableLeads(baseUrl,listViewUrl,leadList,emailBody,isReminder);
            emailBody = emailBody + '<tr><td '+borderStyle+'><p><a href="'+listViewUrl+'"><b><span style="font-size: 14px">Click here to review your Leads</span></b></a><br/>Can\'t access the link above?<br/><a href="'+intelLeadHelp+'">View Help for processing Intel leads</a></p></td></tr>';
        }
        //emailBody = emailBody + '<tr><td '+borderStyle+'><p><a href="'+listViewUrl+'">Review Leads</a><br/>Can\'t access the link above?<br/><a href="'+intelLeadHelp+'">View Help for processing Intel leads</a></p></td></tr>';
        emailBody = emailBody + '<tr><td '+borderStyle+'><p>Questions? Contact Intel® Partner Alliance Support:<br /> <span style="color: #0071c5;">programs@intel.com</span></p></td></tr>';
        emailBody = emailBody + '<tr><td '+borderStyle+'><p><strong>Note</strong> : <span style="color: #ff0000;">'+System.Label.Core_Do_Not_Reply_Note+'</span></p></td></tr>';
        emailBody = emailBody + '<tr><td style="border: 1px solid #d3d3d3;"><p style="text-align: center;font-size: 10px;">This message was sent to you as an important business communication related to your current relationship with Intel Corporation</br>&copy; '+currYear+' Intel Corporation<br /> Intel Corporation, 2200 Mission College Blvd., M/S RNB4-145, Santa Clara, CA 95054 USA.</br> <a href="http://www.intel.com">www.intel.com</a></br><a href="http://www.intel.com/privacy">Privacy</a> | <a href="http://www.intel.com/cookies">Cookies</a></p>';
        emailBody = emailBody + '</td></tr></tbody></table></body></html>';
        return emailBody;
    }
    
    /*
* Method name  : prepareDisplayableLeads
* Description  : Method to prepare list of leads which can be displayed in the email
* Return Type  : String
* Parameter    : List<Lead> leadList, Integer noOfLeads, String emailBody
*/
    public static String prepareDisplayableLeads(String baseUrl, String listViewUrl, List<Lead> leadList, String emailBody, Boolean isReminder){
        Integer noOfLeads = 0;
        if(isReminder){
            noOfLeads = Integer.valueOf(System.Label.Core_ReminderEmailDisplayLeadCount);
        }else{
            noOfLeads = Integer.valueOf(System.Label.Core_SummaryEmailDisplayLeadCount);
        }
        Integer remainingLeadCount = leadList.size() - noOfLeads;
        for(Integer i=0; i<leadList.size(); i++){
            if(i > noOfLeads-1){
                i = leadList.size();
            }else{
                if(leadList[i].FirstName <> null){
                    emailBody = emailBody + '<p><strong>Lead Name</strong> : <span style="color: #339966;">'+leadList[i].FirstName;
                }
                if(leadList[i].LastName <> null){
                    emailBody = emailBody + ' ' + leadList[i].LastName +'</span> <br/>';
                }
                if(leadList[i].Company <> null){
                    emailBody = emailBody + '<strong>Company</strong> : <span style="color: #339966;">'+leadList[i].Company+'</span> <br/>';
                }
                 if(leadList[i].Country <> null){
                    emailBody = emailBody + '<strong>Country</strong> : <span style="color: #339966;">'+leadList[i].Country+'</span> <br/>';
                }
                if(!isReminder){
                    if(leadList[i].Core_Lead_Source_Pkt__c <> null){
                        emailBody = emailBody + '<span style="color: #339966;">'+leadList[i].Core_Lead_Source_Pkt__c+'</span><br/>';
                        }       
                    if(leadList[i].Core_Lead_PMP_Action__c <> null){        
                        emailBody = emailBody + '<span style="color: #339966;">'+leadList[i].Core_Lead_PMP_Action__c+'</span><br/>';
                    }
                }
                emailBody = emailBody + '<strong>Link</strong> : <a href="'+baseUrl+'/'+leadList[i].Id+'">'+baseUrl+'/'+leadList[i].Id+'</a><br/>';
            }
        }
        if(remainingLeadCount > 0){
            String otherString;
            if(remainingLeadCount == 1){
                otherString = ' Other';
            }else{
                otherString = ' Others';
            }
            emailBody = emailBody + '<br/><strong><a href="'+listViewUrl+'"><span style="color: #339966;font-size:20px;">Plus '+remainingLeadCount+otherString+'</span></a></strong><br/></p></td></tr>';
        }else{
            emailBody = emailBody + '<br/></p></td></tr>';
        }
        return emailBody;
    }
    
    /*
* Method name  : stampFieldOnRejectLead
* Description  : Method to stamp field once a lead is rejected
* Return Type  : void
* Parameter    : List<Lead> newLead, Map<Id,Lead> oldLeadMap
*/
    public static void stampFieldOnRejectLead(List<Lead> newLead, Map<Id,Lead> oldLeadMap){
        
        for(Lead led : newLead){
            if(led.RecordTypeId == partnerRecTypeId && led.Core_Lead_State__c == 'Terminated' && oldLeadMap.get(led.Id).Core_Lead_State__c <> 'Terminated' && oldLeadMap.get(led.Id).Core_Lead_Status__c <> 'Qualified' && oldLeadMap.get(led.Id).Status <> 'PQL'){
                //When status New and stage PRL
                if(oldLeadMap.get(led.Id).Core_Lead_Status__c == 'New' && oldLeadMap.get(led.Id).Status == 'PRL'){
                    led.Core_PRL_Exit_Dt__c = system.now();
                    led.Core_Partner_Lead_Owner__c = UserInfo.getUserId();
                }
                //When status Accepted and stage PAL
                if(oldLeadMap.get(led.Id).Core_Lead_Status__c == 'Accepted' && oldLeadMap.get(led.Id).Status == 'PAL'){
                    led.Core_PAL_Exit_Dt__c = system.now();
                }
                //When status Contacted and stage PAL
                if(oldLeadMap.get(led.Id).Core_Lead_Status__c == 'Contacted' && oldLeadMap.get(led.Id).Status == 'PAL'){
                    led.Core_PAL_Exit_Dt__c = system.now();
                    led.Core_Exit_Date_Contacted_Dt__c = system.now();
                }
            }
        }
    }
    
    /*
* Method name  : OfferingDetailsforPartnerLead
* Description  : Method to fetch the Offering related field values based on Offering Id
* Return Type  : Void
* Parameter    : List<Lead> leadList
*/
    Public static void OfferingDetailsforPartnerLead(List<Lead> leadList){
        List<Lead> OfferingLeadList = new List<Lead>();
        for(Lead l : leadList){
            if(l.PMP_Offering_Id__c !=null  && l.RecordTypeId == partnerRecTypeId ){
                OfferingLeadList.add(l) ; 
            }
        }
        if(OfferingLeadList.size() > 0){
            OfferingDetails(OfferingLeadList);
        }
    }
    
    /*
* Method name  : OfferingDetails
* Description  : Method to fetch the Offering related field values based on Offering Id
* Return Type  : Void
* Parameter    : List<Lead> leadList
*/
    Public static void OfferingDetails(List<Lead> Leadlist){
        List<String> Industry;
        List<String> SubIndustry;
        List<String> Category;
        List<String> Application;
        List<String> OfferingIds = new List<String>();
        List<Id> PartnerOfferingIds = new List<Id>();
        Map<String,PMP_Partner_Offering__c> OfferingLeadMap= new Map<String,PMP_Partner_Offering__c>();
        
        for(Lead l : Leadlist){
            OfferingIds.add(l.PMP_Offering_Id__c);
            //OfferingLeadMap.put(l.PMP_Offering_Id__c,l.Id);
        }
        
        // To Fetch the Offering Catregory,Industry,Sub Industry
        List<PMP_Partner_Offering__c> PartnerOfferingList=[Select id,PMP_Offering_Id__c from PMP_Partner_Offering__c where PMP_Offering_Id__c In :OfferingIds];
        for(PMP_Partner_Offering__c PartnerOffer : PartnerOfferingList){
            PartnerOfferingIds.add(PartnerOffer.id);
            OfferingLeadMap.put(PartnerOffer.PMP_Offering_Id__c,PartnerOffer);
        }
        
        // Deriving the Offering Url
        if(OfferingLeadMap.size() > 0){
            for(Lead lst:Leadlist){
                if(OfferingLeadMap.containskey(lst.PMP_Offering_Id__c)){    
                    lst.PMP_OfferingURL_For_Internal__c=Url.getSalesforceBaseUrl().toExternalForm() + '/' +OfferingLeadMap.get(lst.PMP_Offering_Id__c).id;  
                }
            }
        }
        
        
        List<PMP_Partner_Offering_Category__c> getOfferCaregories = new List<PMP_Partner_Offering_Category__c>();
        getOfferCaregories=[Select id,Name,PMP_Category_Id__c,PMP_Ancestor_Category_Cd__c, PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,
                            PMP_Category_Id__r.Name,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c In : PartnerOfferingIds];
        
        system.debug('getOfferCaregories'+getOfferCaregories);
        
        For(Lead L : Leadlist)  {
            Industry= new List<String>();
            SubIndustry= new List<String>();
            Category= new List<String>();
            Application= new List<String>();
            for(PMP_Partner_Offering_Category__c off : getOfferCaregories ){   
                system.debug('Anchestor'+Off.Name+ ' '+ off.PMP_Ancestor_Category_Cd__c);
                //Fetching the Sub Category
                if(l.PMP_Offering_Id__c == off.PMP_Offering_Id__r.PMP_Offering_Id__c && off.PMP_Ancestor_Category_Cd__c != null && off.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 &&
                   off.PMP_Ancestor_Category_Cd__c.contains('NPP_01_TYPE')){
                       if(off.PMP_Category_Id__r.Name != null){
                           Category.add(off.PMP_Category_Id__r.Name);
                       }
                   }
                // Fetch the category
                else if(l.PMP_Offering_Id__c == off.PMP_Offering_Id__r.PMP_Offering_Id__c && off.PMP_Ancestor_Category_Cd__c != null && off.PMP_Ancestor_Category_Cd__c.countMatches('|')==0 &&
                        off.PMP_Ancestor_Category_Cd__c.contains('NPP_01_TYPE')){
                            if(off.PMP_Category_Id__r.Name != null){
                                Category.add(off.PMP_Category_Id__r.Name);
                            }
                        }
                // Fetch the Industry
                else if(l.PMP_Offering_Id__c == off.PMP_Offering_Id__r.PMP_Offering_Id__c && off.PMP_Ancestor_Category_Cd__c != null && off.PMP_Ancestor_Category_Cd__c.countMatches('|')==0 &&
                        off.PMP_Ancestor_Category_Cd__c.contains('NPP_01_Industry')){
                            if(off.PMP_Category_Id__r.Name != null){
                                Industry.add(off.PMP_Category_Id__r.Name);
                            }
                        }
                // Sub Industry
                else if(l.PMP_Offering_Id__c == off.PMP_Offering_Id__r.PMP_Offering_Id__c && off.PMP_Ancestor_Category_Cd__c != null && off.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 &&
                        off.PMP_Ancestor_Category_Cd__c.contains('NPP_01_Industry')){
                            if(off.PMP_Category_Id__r.Name != null){
                                SubIndustry.add(off.PMP_Category_Id__r.Name);
                                
                            }
                        }
                else if(l.PMP_Offering_Id__c == off.PMP_Offering_Id__r.PMP_Offering_Id__c && off.PMP_Ancestor_Category_Cd__c != null && off.PMP_Ancestor_Category_Cd__c.countMatches('|')==0 &&
                        off.PMP_Ancestor_Category_Cd__c.contains('NPP_01_APP')){
                            if(off.PMP_Category_Id__r.Name != null){
                                Application.add(off.PMP_Category_Id__r.Name);
                                
                            }
                        }
                
                string allIndustries = string.join(Industry,',');
                string allSubIndustries = string.join(SubIndustry,',');
                String Categerymerge=string.join(Category,',');
                String AllApplications=string.join(Application,',');
                
                l.PMP_Offering_MarketIndustry__c=allIndustries;
                l.PMP_Offering_MarketSubIndustry__c=allSubIndustries;
                l.PMP_Offering_Category__c=Categerymerge;
                l.PMP_Offering_MarketApplication__c=AllApplications;
                
                
            }
            
        }
        
        // To fetch the Fature Tag and Offering Name
        List<PMP_Partner_Offering__c> offering = [SELECT Id, Name, PMP_Partner_Offering_Nm__c, 
                                                  PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Offering_Id__c
                                                  FROM PMP_Partner_Offering__c WHERE Id  In: PartnerOfferingIds];
        Map<String,PMP_Partner_Offering__c> OfferTagMap= new Map<String,PMP_Partner_Offering__c>();
        
        for(PMP_Partner_Offering__c Poff : offering){
            OfferTagMap.put(Poff.PMP_Offering_Id__c,Poff);
        }
        List<String> OfferTagList;
        
        OfferTagList= new List<String>();
        for(Lead l : Leadlist){
            if(offering.size()>0){
                if(l.PMP_Offering_Id__c !=null && OfferTagMap.containskey(l.PMP_Offering_Id__c)){
                    if(OfferTagMap.get(l.PMP_Offering_Id__c).PMP_Offering_Id__c == l.PMP_Offering_Id__c){
                        l.PMP_Partner_Offering_Nm__c=OfferTagMap.get(l.PMP_Offering_Id__c).PMP_Partner_Offering_Nm__c;
                        //Added by Kavyashree HR(Infosys Pegasus Team) for the US700424
                        l.Core_Partner_Offering__c = OfferTagMap.get(l.PMP_Offering_Id__c).Id;
                    }
                }
            }
        }
        
        
        /// Region and Sub region
        
        List<PMP_Partner_Offering_Specification__c> OfferSpec=[select id,Name,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Offering_Id__c,PMP_Ancestor_Specification_Cd__c,PMP_Specification_Id__r.Name
                                                               from PMP_Partner_Offering_Specification__c where 
                                                               PMP_Offering_Id__c In : PartnerOfferingIds AND PMP_Specification_Id__r.PMP_Active_Ind__c = true 
                                                               ORDER BY PMP_Specification_Id__r.PMP_Partner_Product_Display_Sequence_Nbr__c]; 
        
        
        List<String> Region;
        List<String> SubRegion;
        for(Lead le: Leadlist){
            Region = new List<String>();
            SubRegion = new List<String>();
            for(PMP_Partner_Offering_Specification__c Offsp : OfferSpec){
                
                if(le.PMP_Offering_Id__c == Offsp.PMP_Offering_Id__r.PMP_Offering_Id__c && Offsp.PMP_Ancestor_Specification_Cd__c != null && Offsp.PMP_Ancestor_Specification_Cd__c.countMatches('|')==0 &&
                   Offsp.PMP_Ancestor_Specification_Cd__c.contains('NPP_GeographicCoverage')){
                       if(Offsp.PMP_Specification_Id__r.Name != null){
                           Region.add(Offsp.PMP_Specification_Id__r.Name);
                           
                       }
                   }
                else if(le.PMP_Offering_Id__c == Offsp.PMP_Offering_Id__r.PMP_Offering_Id__c && Offsp.PMP_Ancestor_Specification_Cd__c != null && Offsp.PMP_Ancestor_Specification_Cd__c.countMatches('|')==1 &&
                        Offsp.PMP_Ancestor_Specification_Cd__c.contains('NPP_GeographicCoverage')){
                            if(Offsp.PMP_Specification_Id__r.Name != null){
                                SubRegion.add(Offsp.PMP_Specification_Id__r.Name);
                                
                            }
                        }
            }
            string allRegions = string.join(Region,',');
            string allSubRegions = string.join(SubRegion,',');
            le.PMP_Offering_Region__c=allRegions;
            le.PMP_Offering_SubRegion__c=allSubRegions;
            
            
        }
        //Added by Kavyashree HR (Infosys Team) on 7/21/2020 for the US700424,to avoid recursive call
        isRecursive = true;
    }
    
    /*
* Method name  : NewPartnerLeadNotification
* Description  : Method to Send New Email Notification to public group Users
* Return Type  : Void
* Parameter    : List<Lead> leadList
*/
    Public static void NewPartnerLeadNotification(List<Lead> leadList){
        List<Lead> NotifyOwnerGroups = new List<Lead>();
        Map<String,List<String>> finalGroupsNLeadsMap = new Map<String,List<String>>();
        List<String> LeadIds = new List<String>();
        for(Lead l : leadList){
            if(l.RecordTypeId == partnerRecTypeId){
                NotifyOwnerGroups.add(l) ; 
              //  LeadIds.add(l.id);
            }
        }
        System.debug('NotifyOwnerGroups'+NotifyOwnerGroups);
        if(NotifyOwnerGroups.size() > 0){
            sendEmailNotification(NotifyOwnerGroups);
            
        }
    }
    
    /*
* Method name  : sendEmailNotification
* Description  : Method to Send New Email Notification to public group Users
* Return Type  : Void
* Parameter    : List<Lead> leadList
*/
    public static void sendEmailNotification(List<Lead> NotifyOwnerGroups){
        System.debug('****I am Inside');
        Map<String,List<String>> finalGroupsNLeadsMap = new Map<String,List<String>>();
        Map<String,List<String>> finalGroupsNLeadsMap1 = new Map<String,List<String>>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>(NotifyOwnerGroups);
        List<Core_OPID_Lead_Relationship__c> LeadOPIDSlst=[Select id,Core_Lead_Name__c, Core_Public_Group_Ids__c, Core_OPID_Name__c from Core_OPID_Lead_Relationship__c  Where Core_Lead_Name__c IN :NotifyOwnerGroups];
        system.debug('OPIDS'+LeadOPIDSlst);
        for(Core_OPID_Lead_Relationship__c olr : LeadOPIDSlst){
            for(String Str : olr.Core_Public_Group_Ids__c.split(SYMB_SEMICOLON)){
                if(finalGroupsNLeadsMap.containsKey(olr.Core_Lead_Name__c)){
                    finalGroupsNLeadsMap.get(olr.Core_Lead_Name__c).add(Str);
                }
                else{
                    finalGroupsNLeadsMap.put(olr.Core_Lead_Name__c,new List<String>{Str});
                }
            }
        }
        System.debug('OPIDMAP'+finalGroupsNLeadsMap);
      
        Map<String,List<Lead>> tempGroupWiseLeadMap = new Map<String,List<Lead>>();
        for( String led : finalGroupsNLeadsMap.keySet()){
            List<String> PublicGroupIds = finalGroupsNLeadsMap.get(led);
            system.debug('***PublicGroupIds'+PublicGroupIds);
            
            for(String Gid : PublicGroupIds){
                tempGroupWiseLeadMap = generateGroupsNLeadsMap(leadMap.get(led),Gid,tempGroupWiseLeadMap);
            }
        }
 
        
        
        Map<String,List<Lead>> groupWiseLeadMap = new Map<String,List<Lead>>();
        
        system.debug('*****tempGroupWiseLeadMap'+tempGroupWiseLeadMap);
        
        //filter out the leadsOfEmployees public group to not send any individual email notifications
        Map<Id,Group> groupsMap = new Map<Id,Group>([select Id, developerName from Group where Id IN: tempGroupWiseLeadMap.keyset() AND Type =: 'Regular']);
        for(String grId : tempGroupWiseLeadMap.keyset()){
            if(groupsMap.containskey(grId) && groupsMap.get(grId).developerName.split('_').size() >= 3 && groupsMap.get(grId).developerName.split('_')[2] <> empPublicGroupNameSuffix){
                groupWiseLeadMap.put(grId,tempGroupWiseLeadMap.get(grId));
            }
        }
        
        List<GroupMember> gmList = [Select Id, UserOrGroupId,GroupId From GroupMember where GroupId IN: tempGroupWiseLeadMap.keyset()];
        List<String> tempIdList = new List<String>();
        for(GroupMember gm : gmList){
            tempIdList.add(gm.UserOrGroupId);
        }
        
        Integer emailLimit = Integer.valueOf(System.Label.Core_Partner_Lead_Email_Limit);
        Map<Id,User> userIdmap = new Map<Id,User>([select Id, Core_Email_Trigger_Date__c, Core_Email_Count__c from User where Id IN: tempIdList AND ((Core_Email_Trigger_Date__c = null AND Core_Email_Count__c = null) OR Core_Email_Trigger_Date__c <> today OR (Core_Email_Trigger_Date__c = today AND Core_Email_Count__c <: emailLimit))]);
        Map<String,List<String>> userWiseGroupMap = new Map<String,List<String>>();
        for(GroupMember gm : gmList){
            if(userIdmap.containskey(gm.UserOrGroupId)){
                if(userWiseGroupMap.containsKey(gm.UserOrGroupId)){
                    tempIdList = userWiseGroupMap.get(gm.UserOrGroupId);
                }else{
                    tempIdList = new List<String>();
                }
                tempIdList.add(gm.GroupId);
                userWiseGroupMap.put(gm.UserOrGroupId,tempIdList);
            }
        }
        
        Map<String,Set<Lead>> userWiseLeadMap = new Map<String,Set<Lead>>();
        Set<Lead> tempLeadSet = new Set<Lead>();
        for(String userId : userWiseGroupMap.keyset()){
            tempLeadSet = new Set<Lead>();
            for(String groupId : userWiseGroupMap.get(userId)){
                if(groupWiseLeadMap.get(groupId) != null){
                    tempLeadSet.addAll(groupWiseLeadMap.get(groupId));
                }
            }
            userWiseLeadMap.put(userId,tempLeadSet);
        }
        system.debug('userWiseLeadMap'+userWiseLeadMap);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Integer count;
        List<Lead> listOfLead;
        for(String userId : userWiseLeadMap.keyset()){
            count = 0;
            if(userIdmap.get(userId).Core_Email_Trigger_Date__c == null || userIdmap.get(userId).Core_Email_Trigger_Date__c <> date.today()){
                userIdmap.get(userId).Core_Email_Trigger_Date__c = date.today();
                if(userWiseLeadMap.get(userId).size() > emailLimit){
                    count = emailLimit;
                }else{
                    count = userWiseLeadMap.get(userId).size();
                }
                userIdmap.get(userId).Core_Email_Count__c = count;
            }else if(userIdmap.get(userId).Core_Email_Trigger_Date__c == date.today()){
                if(userWiseLeadMap.get(userId).size() > (emailLimit - Integer.valueOf(userIdmap.get(userId).Core_Email_Count__c))){
                    count = emailLimit - Integer.valueOf(userIdmap.get(userId).Core_Email_Count__c);
                }else{
                    count = userWiseLeadMap.get(userId).size();
                }
                userIdmap.get(userId).Core_Email_Count__c = userIdmap.get(userId).Core_Email_Count__c + count;
            }
            listOfLead = new List<Lead>();
            listOfLead.addAll(userWiseLeadMap.get(userId));
            for(Integer i=0; i<count; i++){
                emailList = prepareGroupWiseEmail(userId, listOfLead[i].id, emailList);
            }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
            update userIdmap.values();
        }
    }
    
    public static List<Messaging.SingleEmailMessage> prepareGroupWiseEmail(String userId, Id leadId, List<Messaging.SingleEmailMessage> emailList){
        system.debug('*** Inside Email ');
        ID EmailTemplate;
        EmailTemplate = [Select Id,Name From EmailTemplate Where Name ='New Lead Partner'][0].id;
        List<String> userIdList = new List<String>();
        userIdList.add(userId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(userIdList);
        mail.setTemplateId(EmailTemplate);
        mail.setTargetObjectId(leadId); 
        mail.setSaveAsActivity(false); 
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setOrgWideEmailAddressId(fromEmailAddress);
        emailList.add(mail);
        return emailList;
    }
}