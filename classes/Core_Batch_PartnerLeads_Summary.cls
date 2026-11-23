global class Core_Batch_PartnerLeads_Summary implements Database.Batchable<sObject>, Database.Stateful{
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
        String query = 'Select id from PMP_Company__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PMP_Company__c> scope){
        Set<String> generatedLeadIds = new Set<String>();
        Set<String> acceptedLeadIds =  new Set<String>();
        Set<String> contactedLeadIds = new Set<String>();
        Set<String> qualifiedLeadIds = new Set<String>();
        Set<String> inPursuitLeadIds = new Set<String>();
        Set<String> rjectedLeadIds = new Set<String>();
        Set<id> mpiIds = new Set<id>();
        Set<id> accIdSet = new Set<id>();
        Set<id> grpIdSet = new Set<id>();
        List<String> groupNameList = new List<String>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        Set<Id> userIds=new Set<Id>();
        List<Id> userIdsList=new List<Id>();
        List<Group> groupList = new List<Group>();
        List<GroupMember> grpMember = new List<GroupMember>();
        
        //Logic Starts
        for(PMP_Company__c mpi : scope){
            mpiIds.add(mpi.id);
        }
        
        //get all the leads for the storefront.
        if(mpiIds.size()>0){
            List<lead> leadList = [Select id,Core_MPI_Id__c,Core_Lead_Status__c,Status from Lead where RecordType.Name='Partner lead' and Core_MPI_Id__c =:mpiIds];
            
            //calculate the number of leads of diiferent statuses based on storefront level.
            if(leadList.size()>0){
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
                List<PMP_OPID_MPI_Rel__c> opmp = [select id,PMP_One_Partner_ID__c from PMP_OPID_MPI_Rel__c where PMP_Marketing_Profile_Id__c in:scope ];
                if(opmp.size()>0){
                    for(PMP_OPID_MPI_Rel__c opmpObj : opmp){
                            accIdSet.add(opmpObj.PMP_One_Partner_ID__c);
                    }
                }
                
                //Based on the OPIDs segments, get the public groups names excluding Leads of Employees.
                if(accIdSet.size()>0){
                    for(Id accId : accIdSet){
                        groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(accId, adminPublicGroupNameSuffix));
                        for(String segment : partnerSegmentList){
                            groupNameList.add(Core_PartnerLeadHandler.generatePartnerKey(accId, segment));
                        }
                    }
                }
                
                // query the actual groups.
                if(!groupNameList.isEmpty()){
                    groupList = [select id, Name, developerName from Group where developerName IN: groupNameList];
                }
                
                /*List<Core_OPID_Lead_Relationship__c> oplr =[select id,Core_OPID_Name__c,Core_Public_Group_Ids__c  from Core_OPID_Lead_Relationship__c where Core_OPID_Name__c in:accIdSet];
                for(Core_OPID_Lead_Relationship__c c: oplr){
                    grpIdSet.add(c.Core_Public_Group_Ids__c);
                }*/
                
                //get the groupmembers from the groups.
                if(groupList .size()>0){
                    grpMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN:groupList];
                }
                
                //get the userIDs from the groupmembers.
                if(grpMember.size()>0){
                    for(GroupMember m: grpMember){
                        if(((String)m.UserOrGroupId).startsWith(userType))
                        {
                            userIds.add(m.UserOrGroupId);
                        }
                    }
                }
                
                //adding to a list as toAddress accepts a list.
                userIdsList.addAll(userIds);
                
                //send email when userlist is not empty.
                if(userIdsList.size()>0){
                    Core_PartnerLead_Monthly_Email.sendEmailToUser(userIdsList,generatedLeadIds,acceptedLeadIds,contactedLeadIds,qualifiedLeadIds,rjectedLeadIds);
                }
            }//if(leadList.size()>0)
        }//end of if(mpiIds.size()>0)
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}