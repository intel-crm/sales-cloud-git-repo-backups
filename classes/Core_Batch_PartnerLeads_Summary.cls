global class Core_Batch_PartnerLeads_Summary implements Database.Batchable<sObject>{
    //Public group name suffix
    public static String adminPublicGroupNameSuffix = 'Leads';
    public List<String> partnerSegmentList = new List<String>();
    global Core_Batch_PartnerLeads_Summary(){
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            partnerSegmentList.add(a.getValue());
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //get all storefront
        List<Id> idd = new List<id>();
        idd.add('a5S2i000000CcCmEAK');
        idd.add('a5S2i000000CbWREA0');
        String query = 'Select id from PMP_Company__c where id IN:idd ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PMP_Company__c> scope){
        Set<String> generatedLeadIds ;
        Set<String> acceptedLeadIds ;
        Set<String> contactedLeadIds ;
        Set<String> qualifiedLeadIds;
        Set<String> inPursuitLeadIds ;
        Set<String> rjectedLeadIds;
        Set<id> mpiIds;
        Set<id> accIdSet;
        //Set<id> grpIdSet = new Set<id>();
        List<String> groupNameList;
        String userType = Schema.SObjectType.User.getKeyPrefix();
        Set<Id> userIds;
        List<Id> userIdsList;
        List<Group> groupList;
        List<GroupMember> grpMember;
        
        //Logic Starts
        mpiIds = new Set<id>();
        for(PMP_Company__c mpi : scope){
            mpiIds.add(mpi.id);
        }
        system.debug('mpiIds->'+mpiIds);
        //get all the leads for the storefront.
        if(mpiIds.size()>0){
            for(Id mpId : mpiIds){
                List<lead> leadList = [Select id,Core_MPI_Id__c,Core_Lead_Status__c,Status,Core_Partner_Lead_Owner__c,Core_Lead_State__c from Lead where RecordType.Name='Partner lead' and Core_MPI_Id__c =:mpId];
                system.debug('leadList->'+leadList);
                //calculate the number of leads of diiferent statuses based on storefront level.
                if(leadList.size()>0){
                    generatedLeadIds = new Set<String>();
                    acceptedLeadIds=  new Set<String>();
                    contactedLeadIds =  new Set<String>();
                    qualifiedLeadIds =  new Set<String>();
                    inPursuitLeadIds =  new Set<String>();
                    rjectedLeadIds =  new Set<String>();
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
                    }
                    
                    //get the OPIDs
                    accIdSet = new Set<id>();
                    List<PMP_OPID_MPI_Rel__c> opmp = [select id,PMP_One_Partner_ID__c from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c =:mpId ];
                    if(opmp.size()>0){
                        for(PMP_OPID_MPI_Rel__c opmpObj : opmp){
                                accIdSet.add(opmpObj.PMP_One_Partner_ID__c);
                        }
                    }
                    system.debug('accIdSet->'+accIdSet);
                    //Based on the OPIDs segments, get the public groups names excluding Leads of Employees.
                    groupNameList = new List<String>();
                    if(accIdSet.size()>0){
                        for(Id accId : accIdSet){
                            groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(accId, adminPublicGroupNameSuffix));
                            for(String segment : partnerSegmentList){
                                groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(accId, segment));
                            }
                        }
                    }
                    
                    // query the actual groups.
                    groupList = new List<Group>();
                    if(!groupNameList.isEmpty()){
                        groupList = [select id, Name, developerName from Group where developerName IN: groupNameList];
                    }
                    
                    /*List<Core_OPID_Lead_Relationship__c> oplr =[select id,Core_OPID_Name__c,Core_Public_Group_Ids__c  from Core_OPID_Lead_Relationship__c where Core_OPID_Name__c in:accIdSet];
                    for(Core_OPID_Lead_Relationship__c c: oplr){
                        grpIdSet.add(c.Core_Public_Group_Ids__c);
                    }*/
                    system.debug('groupList->'+groupList);
                    //get the groupmembers from the groups.
                    grpMember = new List<GroupMember>();
                    if(groupList .size()>0){
                        grpMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN:groupList];
                    }
                    
                    //get the userIDs from the groupmembers.
                    userIds = new Set<Id>();
                    if(grpMember.size()>0){
                        for(GroupMember m: grpMember){
                            if(((String)m.UserOrGroupId).startsWith(userType))
                            {
                                userIds.add(m.UserOrGroupId);
                            }
                        }
                    }
                    system.debug('userIds-'+userIds);
                    //adding to a list as toAddress accepts a list.
                    userIdsList = new List<Id>();
                    userIdsList.addAll(userIds);
                    system.debug('userIdsList->'+userIdsList);
                    //send email when userlist is not empty.
                    if(userIdsList.size()>0 && inPursuitLeadIds.size()>0){
                        Core_PartnerLead_Monthly_Email.sendEmailToUser(userIdsList,generatedLeadIds,acceptedLeadIds,contactedLeadIds,qualifiedLeadIds,rjectedLeadIds);
                    }
                }//if(leadList.size()>0)
            }
        }//end of if(mpiIds.size()>0)
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}