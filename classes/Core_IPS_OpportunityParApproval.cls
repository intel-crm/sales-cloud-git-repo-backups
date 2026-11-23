/***************************************************************************************************
* Apex Class Name : Core_IPS_OpportunityParApproval
* Test Class Name : Core_IPS_OpportunityPAR_Controller_Test
* Description :  This is to create dynamic approval process by creating a group an submit an approavl process through group.                                                    
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Farooq                  08/09/2020                This is to create dynamic approval process by creating a group
                                                    an submit an approavl process through group.
* Farooq 							  /10/2024				 Modified the approval prcess as part of ATHR (TWC745-6578)
****************************************************************************************************/
public without sharing class Core_IPS_OpportunityParApproval implements Queueable{
    private List<Core_IPS_Opppar_SuppOrgAdmin__c> newList;
    private List<Core_IPS_Product_Organization_Admin__c> newProductList;
    private Map<Id, Core_IPS_Product_Organization_Admin__c> oldMap;
    private String operation;
    private static String GROUPMEMBER = 'GroupMember';
    private static String APPROVAL_CALL = 'Approval';
    private Map<Id, Group>  oppGroupMap = new Map<Id, Group>();
    /*Method: Core_IPS_OpportunityParApproval
    This method is the constructor for group Member creation
    */
    public Core_IPS_OpportunityParApproval(String operation, List<Core_IPS_Opppar_SuppOrgAdmin__c> newList) {
        this.newList = newList;
        this.operation = operation;
    }
    /*Method: Core_IPS_OpportunityParApproval
    This method is the constructor for group Member creation
    */
    public Core_IPS_OpportunityParApproval(String operation, List<Core_IPS_Product_Organization_Admin__c> newProductList, Map<Id, Core_IPS_Product_Organization_Admin__c> oldMap) {
        this.newProductList = (newProductList.size()>0) ? newProductList : new List<Core_IPS_Product_Organization_Admin__c>();
        this.operation = operation;
        this.oldMap = oldMap;
    }
    /*Method: Core_IPS_OpportunityParApproval
    This method is the constructor for Approval Process  creation
    */
    public Core_IPS_OpportunityParApproval(String operation, Map<Id, Group>  oppGroupMap) {
        this.oppGroupMap = oppGroupMap;
        this.operation = operation;
    }
    public void execute(QueueableContext context) {
        if(Operation == GROUPMEMBER) {
            Map<Id,List<Id>> opportunity2AdminMap = new Map<Id,List<Id>>();
            if(newList != Null) {
                opportunity2AdminMap = createOpportunity2AdminMap(newList);
            }
            if(newProductList != Null) {
                opportunity2AdminMap = createSupportOrgAdmin2AdminMap(newProductList, oldMap);
            }
            Map<Id, List<GroupMember>> opportunity2GroupMemberList =  new Map<Id, List<GroupMember>>();
            oppGroupMap = createOpportunityGroupList(opportunity2AdminMap);
            List<GroupMember> GMList = new List<GroupMember>(); 
            for(Id singleKey: opportunity2AdminMap.keySet()) {
                for(Id adminId :opportunity2AdminMap.get(singleKey)) {
                    GroupMember GM = new GroupMember();
                    /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
                    if (Schema.sObjectType.GroupMember.fields.GroupId.isCreateable() && oppGroupMap.get(singleKey) != null) {
                        GM.GroupId = oppGroupMap.get(singleKey).Id;
                    }
                    if (Schema.sObjectType.GroupMember.fields.UserOrGroupId.isCreateable()) {
                        GM.UserOrGroupId =adminId;
                    }
                    GMList.add(GM);
                    opportunity2GroupMemberList.put(singleKey, GMList);
                }
            }
            List<GroupMember> newGroupMemberList = new List<GroupMember>();
            for(List<GroupMember> groupMemberList : opportunity2GroupMemberList.values()) {
                newGroupMemberList.addAll(groupMemberList);
            }
            if(newGroupMemberList.size() >0){
                insert newGroupMemberList;
            }
            if(Test.isRunningTest()){
                System.runAs(new User(Id=userInfo.getUserId())){
                    approval(oppGroupMap); 
                }
            }else{
                System.enqueueJob(new Core_IPS_OpportunityParApproval(APPROVAL_CALL, oppGroupMap));
            }
        }
        
        if(Operation == APPROVAL_CALL) {
            approval(oppGroupMap);            
        }
    }
    /*

    */
    public static void approval(Map<Id,Group> oppGroupMap){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for(Id opportunityId: oppGroupMap.keySet()) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(opportunityId);
            req1.setNextApproverIds(new List<Id>{oppGroupMap.get(opportunityId).Id});
            requests.add(req1);
        }
        List<Approval.ProcessResult> result = Approval.process(requests); 
    }

    /*
    */
    public Map<Id,List<Id>> createSupportOrgAdmin2AdminMap(List<Core_IPS_Product_Organization_Admin__c> newList, Map<Id, Core_IPS_Product_Organization_Admin__c> oldMap) {
        final Map<Id,List<Id>> supportAdminUserIdMap = new Map<Id,List<Id>>();
        for(Core_IPS_Product_Organization_Admin__c  orgAdmin: newList){
            if((orgAdmin.Core_IPS_Supported_Org_Admin__c!=null && oldMap!= null) && oldMap.get(orgAdmin.Id).Core_IPS_Supported_Org_Admin__c != orgAdmin.Core_IPS_Supported_Org_Admin__c){
                if(supportAdminUserIdMap.get(orgAdmin.Core_IPS_Supported_Org_Admin__c)!=null){
                    supportAdminUserIdMap.get(orgAdmin.Core_IPS_Supported_Org_Admin__c).add(orgAdmin.Core_Admin__c);         
                }else{
                    supportAdminUserIdMap.put(orgAdmin.Core_IPS_Supported_Org_Admin__c, new List<Id>{orgAdmin.Core_Admin__c});
                }  
            }
        }
        return supportAdminUserIdMap;
    }
    /*
    */
    public Map<Id,List<Id>> createOpportunity2AdminMap(List<Core_IPS_Opppar_SuppOrgAdmin__c> newList) {
        final Map<Id,List<Id>> opp2AdminMap = new Map<Id,List<Id>>();
        for(Core_IPS_Opppar_SuppOrgAdmin__c  orgAdmin: newList) {
            if(orgAdmin.Core_IPS_Opportunity_Par__c != null) {
                if(opp2AdminMap.get(orgAdmin.Core_IPS_Opportunity_Par__c) == null) {
                    opp2AdminMap.put(orgAdmin.Core_IPS_Opportunity_Par__c, new List<Id>{orgAdmin.Core_IPS_Org_Admin_Id__c});
                } 
                else {
                    opp2AdminMap.get(orgAdmin.Core_IPS_Opportunity_Par__c).add(orgAdmin.Core_IPS_Org_Admin_Id__c);         
                }  
            }
        }
        return opp2AdminMap;
    }
     /*
    */
    public Map<Id, Group> createOpportunityGroupList(Map<Id, List<Id>> adminUserIdMap) {
        final Map<Id, Group> oppGroupMap = new Map<Id, Group>();
        
        for(Id opportunityId: adminUserIdMap.keySet()) {
            final Group objGroup = new Group();
            objGroup.Name = 'Opp PAR ApprovalQueue'+Crypto.getRandomInteger(); 
            objGroup.Type='Queue';
            oppGroupMap.put(opportunityId, objGroup);
        }
        Database.insert(oppGroupMap.values());
        return oppGroupMap;
    }
}