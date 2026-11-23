public without sharing class Core_IPS_ProductTriggerHandler{
    
    //code for submitting the Line Item for Approval when Project Status is Active. 
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: trgNew
Output Parameters: None
Transactions: After Insert
Description: 
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/
    public static void sumbittingIPSProductforApproval(List<Core_IPS_Product__c> trgNew){ 

        List<Core_IPS_Product__c> validProducts = new List<Core_IPS_Product__c>();     
	List<Core_IPS_Product__c> ipsProducts = new List<Core_IPS_Product__c>();     
        if(trgNew <> null && trgNew.size()>0){
            //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
            Map<Id, Core_IPS_Product__c> trgNewMap = new Map<Id, Core_IPS_Product__c>(trgNew);
            if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
              ipsProducts = [select id,Is_Approved__c,Core_IPS_IsAutoApprove__c,Status__c,Core_IPS_Project__r.Core_Status__c,Core_IsSubmitted_Header__c from Core_IPS_Product__c where ID IN : trgNewMap.keyset()];        
            //ipsProducts = [select id,Is_Approved__c,Core_IPS_IsAutoApprove__c,Status__c,Core_IPS_Project__r.Core_Status__c,Core_IsSubmitted_Header__c from Core_IPS_Product__c where ID IN:trgNew];        
            }
            if(ipsProducts <> null && ipsProducts.size()>0){
                for(Core_IPS_Product__c product:ipsProducts){
                    if(!product.Core_IPS_IsAutoApprove__c && !product.Is_Approved__c && (product.Status__c != 'Submitted' && product.Status__c != 'Not Approved' )  && product.Core_IsSubmitted_Header__c && (product.Core_IPS_Project__r.Core_Status__c =='Submitted Pending' || product.Core_IPS_Project__r.Core_Status__c =='Active')){
                        validProducts.add(product); 
                    }
                }
                if(validProducts <> null && validProducts.size()>0){
                    submitApprovalRequestForproductLineItem(validProducts);
                }    
            }
        }
    }


// added by Sumukh for US240170
/***************************************************************************************************
Version     : 1.0 
Created Date: 02 Jan 2019
Function    : 
Input Parameters: Product list 
Output Parameters: None
Transactions: before Insert or before Update
Description: To Check if IPS - Partner Agent is a part of project member team  
Used in     :ProductTrigger_Dispatcher 
Number of Queries Within this Method: 3
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                   02/01/2019       US-240170 : To Check if IPS - Partner Agent is a part of project member team 
 ***************************************************************************************************/
    public static void partnerAgentAsProjectMember(List<Core_IPS_Product__c> newList, Map<id,Core_IPS_Product__c> oldMap){
    List<String> projectIds = new List<String>();
    List<String> userIds = new List<String> ();  
    Set<Id> setPartUsers = new set<Id>();    
    for(Core_IPS_Product__c prodObj:newList){  
       if(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c !=null && (oldMap ==null || (oldMap != null  && prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c!=oldMap.get(prodObj.id).Core_IPS_Prod_Def_Case_Owner_ID__c))){ //made changes by sumukh for US586420 
            projectIds.add(prodObj.Core_IPS_Project__c);
            if(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c!=null && prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c.startsWith('005')){ //made changes by sumukh for US586420
            userIds.add(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c);
            }  
       }
    }
    if(userIds.size()>0){
    
    Map<Id,User> userMap = new Map<id,User> ([select id,profileId from User where id in: userIds]);    
    Map<Id,Set<String>> projectMemberMap = new Map<Id,set<String>>();    
    List<Core_IPS_Project_Member__c> membersList = new List<Core_IPS_Project_Member__c>();
    Map<String,String> userProfileMap = new Map<String,String>();
    if(projectIds.size()>0){
        if(Core_IPS_Project_Member__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
        membersList=[select id,Core_IPS_Project__c,Core_User__c,Core_User__r.profileId from Core_IPS_Project_Member__c where Core_IPS_Project__c in:projectIds and Core_Status__c ='Active'];}
            }
     for(User u: [Select id,ProfileId from User where Id IN :userIds and ProfileId = : System.Label.Core_IPS_Agent_Partner_Profile_id]){
            setPartUsers.add(u.Id);}
        
    if(membersList.size()>0){
        for(Core_IPS_Project_Member__c projMemObj:membersList){
            set<string> tempList = new set<string>();
            if(!projectMemberMap.containsKey(projMemObj.Core_IPS_Project__c)){
                tempList.add(projMemObj.Core_User__c);
                projectMemberMap.put(projMemObj.Core_IPS_Project__c,tempList);
            }else{
                tempList=projectMemberMap.get(projMemObj.Core_IPS_Project__c);
                tempList.add(projMemObj.Core_User__c);
                projectMemberMap.put(projMemObj.Core_IPS_Project__c,tempList);
            }
            userProfileMap.put(projMemObj.Core_User__c,projMemObj.Core_User__r.profileId);
        }
    }  
    
    for(Core_IPS_Product__c prodObj:newList){
        if(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c!=null && setPartUsers.Contains(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c)){ //made changes by sumukh for US586420 
            if(
                ( projectMemberMap.get(prodObj.Core_IPS_Project__c)==null || projectMemberMap.get(prodObj.Core_IPS_Project__c).size()==0) ||
                ( projectMemberMap.get(prodObj.Core_IPS_Project__c)!=null && projectMemberMap.get(prodObj.Core_IPS_Project__c).size()>0 && !projectMemberMap.get(prodObj.Core_IPS_Project__c).contains(prodObj.Core_IPS_Prod_Def_Case_Owner_ID__c))) //made changes by sumukh for US586420 
                  {                
                  prodObj.addError('Default Case Owner does not exist as a active project member');
                  }
        }               
      }
  }  
}  // end by sumukh for US240170 

/***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: validProducts
Output Parameters: None
Transactions: After Insert
Description: 
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
* Ashutosh                   01/06/2018              Modified(US106482)
 ***************************************************************************************************/
    public static void submitApprovalRequestForproductLineItem(List<Core_IPS_Product__c> validProducts){
        /*Ashutosh - US106482 - Adding access flag field in query */
        List<Core_IPS_Product__c> lstprodOrgIds = new List<Core_IPS_Product__c>();
         if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
             lstprodOrgIds =[select Core_Supported_Product__r.Core_Product_Organization__c,Core_Supported_Product__r.Core_Flag_Status__c,Core_Supported_Product__r.Core_Product_Organization__r.OwnerId from Core_IPS_Product__c where id IN:validProducts];        
        }
        Set<Id> prodOrgIds = new Set<ID>();
        Set<Id> ownerIdlist= new Set<Id>();
        List<Core_IPS_Product_Organization__c> prodorgRecords = new List<Core_IPS_Product_Organization__c>();
        Map<Id,Id> orgIdswithOwnerIds = new Map<Id,Id>();
        Map<Id,List<Core_IPS_Product__c>> orgIdswithListofProductLitemIds = new Map<Id,List<Core_IPS_Product__c>>();
        Map<Id,List<Core_IPS_Product__c>> orgIdswithListofProductLitemIds1 = new Map<Id,List<Core_IPS_Product__c>>();
        Map<Id,Approval.ProcessSubmitRequest> prodOrgtoRequests = new Map<Id,Approval.ProcessSubmitRequest>();
        List<Core_IPS_Product__c> productToApproveManually = new List<Core_IPS_Product__c>();
        List<Core_IPS_Product_Organization__c> prodorgRecList = new List<Core_IPS_Product_Organization__c>();
        for(Core_IPS_Product__c productRecord : lstprodOrgIds){
            prodOrgIds.add(ProductRecord.Core_Supported_Product__r.Core_Product_Organization__c);
            OwnerIdlist.add(ProductRecord.Core_Supported_Product__r.Core_Product_Organization__r.OwnerId);
        }
        
        for(Core_IPS_Product__c cip : lstprodOrgIds){
            if(OrgIdswithListofProductLitemIds1.containsKey(cip.Core_Supported_Product__r.Core_Product_Organization__c)){
                OrgIdswithListofProductLitemIds1.get(cip.Core_Supported_Product__r.Core_Product_Organization__c).add(cip); 
            }
            else{
                List<Core_IPS_Product__c> litemRecordsList = new List<Core_IPS_Product__c>();
                LItemRecordsList.add(cip);        
                OrgIdswithListofProductLitemIds1.put(cip.Core_Supported_Product__r.Core_Product_Organization__c,LItemRecordsList); 
            }
        }
        if(Core_IPS_Product_Organization__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
        
             prodorgRecList = [Select id,OwnerId from Core_IPS_Product_Organization__c where id IN:prodOrgIds];  
        }
        for(Core_IPS_Product_Organization__c productorg: prodorgRecList){
            OrgIdswithOwnerIds.put(Productorg.id,Productorg.OwnerId);
        }
        /*Ashutosh- US106482 - grouping users in queue for support org owner
        Here first we will get the group under the queue(owner of org) and will group orgowner(queue) on the behalf of group and later
        we will get member of the group and will map owner(Queue) to group member*/
        Map<Id,Id>ownerQueueIdByGorupId = new Map<Id,Id>();
        //List<GroupMember> publicGroupIds = [SELECT userOrGroupId,groupId FROM groupmember WHERE groupId IN: OrgIdswithOwnerIds.values() AND Group.Type = 'Queue'];
        //if(GroupMember.SObjectType.getDescribe().isAccessible()){ //FLS check commented - Aditya
            for(GroupMember gm : [SELECT userOrGroupId,groupId FROM groupmember WHERE groupId IN: OrgIdswithOwnerIds.values() AND Group.Type = 'Queue']){ 
            ownerQueueIdByGorupId.put(gm.userOrGroupId,gm.GroupId);
        }
        //}
        Map<Id,Set<Id>> supportOrgAdminsByOrgOwnerId = new Map<Id,Set<Id>>();
        //List<groupmember> QueueMemberIds = [SELECT userOrGroupId,groupId FROM groupmember WHERE groupId In: ownerQueueIdByGorupId.keySet()];
        Set<Id> userIds;
        for(groupmember  gm : [SELECT userOrGroupId,groupId FROM groupmember WHERE groupId In: ownerQueueIdByGorupId.keySet()]){
            Id orgOwnerId = ownerQueueIdByGorupId.get(gm.GroupId) == null ? null : ownerQueueIdByGorupId.get(gm.GroupId);
            if(orgOwnerId != null){
                if(supportOrgAdminsByOrgOwnerId.get(orgOwnerId) == null){
                   userIds = new Set<Id>();
                   supportOrgAdminsByOrgOwnerId.put(orgOwnerId,userIds);
                }
                userIds.add(gm.userOrGroupId);
            }
        }
        /*Ashutosh- US106482 -----------------End Here---------------------*/
        
        List<Approval.ProcessResult> result =new List<Approval.ProcessResult>();
        List<Approval.ProcessSubmitRequest> requests = new LIst<Approval.ProcessSubmitRequest>();   
        for(Id prodOrgRec1 :OrgIdswithListofProductLitemIds1.keyset()){
            for(Core_IPS_Product__c productRecord : OrgIdswithListofProductLitemIds1.get(ProdOrgRec1)){
                /*Ashutosh- US106482 ----- Start ------ Checking that project record's support product's org have owner that is support org admin and is a member of
                the queue which is owner of that support org*/
                if(ProductRecord.Core_Supported_Product__r.Core_Flag_Status__c == 'PAR Hidden' 
                   && (supportOrgAdminsByOrgOwnerId.get(ProductRecord.Core_Supported_Product__r.Core_Product_Organization__r.OwnerId) != null )
                    && supportOrgAdminsByOrgOwnerId.get(ProductRecord.Core_Supported_Product__r.Core_Product_Organization__r.OwnerId).contains(UserInfo.getUserID())){
                    productToApproveManually.add(ProductRecord);    
                }
                else{
                    Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();                 
                    List<Id> approverIds2= new List<Id>();                    
                    approverIds2.add(OrgIdswithOwnerIds.get(ProdOrgRec1));
                    req2.setObjectId(ProductRecord.id);
                    req2.setNextApproverIds(approverIds2);
                    requests.add(req2);                                                                                                                             
                }
            }
        }
        result = Approval.process(requests);
        /*Ashutosh - US106482 - We will update the products which are par hidden but added by the org owner queue member*/
        if(!productToApproveManually.isEmpty()){
            for(Core_IPS_Product__c prod : productToApproveManually){
                prod.Status__c = 'Approved';
                prod.is_approved__c = true;
                prod.Core_IsSubmitted_Header__c = true;
            }
            update productToApproveManually;
        }
        
    }
    //code for Creating assets on Approval of Line Item.
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: trgNew, trgOldmap
Output Parameters: None
Transactions: After Insert
Description: 
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/
    public static void createAssetforIPSProduct(List<Core_IPS_Product__c> trgNew
                                                , Map<id,Core_IPS_Product__c> trgOldmap){
                                                    set<id> validProductIds = new set<id>();
                                                    set<id> supportProductIds = new set<id>();
                                                    set<id> projectids = new set<id>();
                                                    List<Asset> assetList = new List<Asset>();
						    List<Core_IPS_Project__c> projectdetails = new List<Core_IPS_Project__c>();
						    Map<Id,Asset> assetRecords;
                                                    for(Core_IPS_Product__c product:trgNew){
                                                        if((trgOldmap.get(product.id).is_approved__c!=product.is_approved__c && product.is_approved__c) || (product.Core_IPS_IsAutoApprove__c && product.Core_IsSubmitted_Header__c)){
                                                            projectIds.add(product.Core_IPS_Project__c);
                                                            validProductIds.add(product.id);
                                                            SupportProductIds.add(product.Core_Supported_Product__c); 
                                                        }
                                                    }
                                                    
                                                    if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
                                                    projectdetails = [select id,(select id,Core_Supported_Product__c,Core_Supported_Product__r.Core_Product_Organization__c,Core_Supported_Product__r.Core_Supported_Product_Alias__c,Core_Supported_Product__r.Core_Product__c,Core_Supported_Product__r.Core_Supported_Product_Name__c from IPS_Products__r where Id In:validProductIds) from Core_IPS_Project__c where Id IN: projectIds];
                                                    }
                                                     if(Asset.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
                                                      assetRecords = new Map<id,Asset>([select id,Name,AccountID,Core_Supported_Product__c,Core_IPS_Project__c from Asset where Core_Supported_Product__c IN:SupportProductIds]);
                                                    set<string> assetIdentifier = new  set<string>();
                                                    for(Asset recAsset:AssetRecords.values()){
                                                        assetIdentifier.add(recAsset.Core_Supported_Product__c+'##'+recAsset.Core_IPS_Project__c);
                                                    }
                                                    for(Core_IPS_Project__c project :Projectdetails){
                                                        for(Core_IPS_Product__c product:project.IPS_Products__r){
                                                            if(!assetIdentifier.contains(product.Core_Supported_Product__c+'##'+project.id)){
                                                                Asset recordAsset = new Asset();
                                                                recordAsset = new Asset();   
                                                                if (Schema.sObjectType.Asset.fields.Name.isCreateable()) {
                                                                recordAsset.Name=product.Core_Supported_Product__r.Core_Supported_Product_Name__c;
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.Core_Supported_Product__c.isCreateable()) {
                                                                recordAsset.Core_Supported_Product__c=product.Core_Supported_Product__c;
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.Core_IPS_Project__c.isCreateable()) {
                                                                recordAsset.Core_IPS_Project__c=project.id;
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.Product2Id.isCreateable()) { 
                                                                recordAsset.Product2Id=product.Core_Supported_Product__r.Core_Product__c; 
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.Core_IPS_Asset__c.isCreateable()) {
                                                                recordAsset.Core_IPS_Asset__c=true;
                                                                }

                                                                /*recordAsset.Core_Project_Asset_Status__c = 'Active';*/ //- commented by roshan for removing field on Asset dec 8th
                                                                if (Schema.sObjectType.Asset.fields.Core_Product_Organization__c.isCreateable()) {
                                                                recordAsset.Core_Product_Organization__c = product.Core_Supported_Product__r.Core_Product_Organization__c;
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.Installdate.isCreateable()) {
                                                                recordAsset.Installdate=system.today();
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.status.isCreateable()) {
                                                                recordAsset.status='Active';
                                                                }
                                                                if (Schema.sObjectType.Asset.fields.recordtypeid.isCreateable()) {
                                                                recordAsset.recordtypeid = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId(); 
                                                                }
                                                                //added by kishore on 5/9
                                                                if (Schema.sObjectType.Asset.fields.core_alias__c.isCreateable()) {
                                                                recordAsset.core_alias__c=product.Core_Supported_Product__r.Core_Supported_Product_Alias__c;
                                                                }
                                                                assetList.add(recordAsset);
                                                            }
                                                            }
                                                        }   
                                                    }
                                                    if(!assetList.isempty()){
                                                        insert assetList;
                                                          
                                                    }
                                                }
    
    //code for updating project status to Active when even one Line Item is approved.
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: ipsProdList
Output Parameters: None
Transactions: After Insert
Description: 
Used in     : 
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/
    public static void updateProjectStatus(List<core_ips_product__c> ipsProdList){
    Core_ips_project__c proj;
        if(ipsProdList!=null && ipsProdList.size()>0){
            if(Core_ips_project__c.SObjectType.getDescribe().isAccessible()){ // FLS Check already added - Aditya
                 proj=[select id,core_status__c from core_ips_project__c where id=:ipsProdList[0].core_ips_project__c];
            }
            List<core_ips_product__c> approvedProducts = new List<core_ips_product__c>();
            List<core_ips_product__c> autoApprovedProducts = new List<core_ips_product__c>();
            for(core_ips_product__c projproduct: ipsProdList){
                if(projproduct.status__c == 'Approved'){
                    ApprovedProducts.add(projproduct);
                    break;
                }
                if(projproduct.status__c == 'Auto Approve'){
                    AutoApprovedProducts.add(projproduct);
                    break;
                }
            }   
            /*modified by Aayushi 08-11-2017 US79853 to make sure that only Projects which have Submitted Pending
             * as status should become Active*/
            //   if(proj!=null && proj.core_status__c != 'Active' && (ApprovedProducts.size()>0 || AutoApprovedProducts.size()>0)){
            if(proj!=null && proj.core_status__c =='Submitted Pending' && (ApprovedProducts.size()>0 || AutoApprovedProducts.size()>0)){
                if (Schema.sObjectType.Core_ips_project__c.fields.core_status__c.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                    proj.core_status__c = 'Active';
                }
                 /*added by Aayushi 08-11-2017 US79853 to check that Status is changed 
                                                         * from Submitted Pending to Active only through code */
                                                       Core_IPS_Project_Controller.checkCodeChange=true; 
                update proj;
               
            }
        }
    }
    
    //code for updating project status to Active when even one Line Item is approved.
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: ipsProdList
Output Parameters: None
Transactions: After Insert
Description: 
Used in     : 
Number of Queries Within this Method: 3
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
* Yogesh Sharma              3/11/2017               Modified
***************************************************************************************************/
    public static void updateIsSubmittedHeader(List<core_ips_product__c> ipsProdList){
        List<core_ips_product__c> updateProductList = new List<core_ips_product__c>();
        Map<Id,Asset> getAssetBySupportedProduct = new Map<Id,Asset>();
        Map<Id,Asset> assetMap;
        Set<Id> projectIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Core_IPS_Account__c> projectAccounts;
	List<core_ips_product__c> productList = new List<core_ips_product__c>();
        
        //Get the Values From IPS Label Custom setting
        String projectStatusActive = Core_IPS_Helper_Utility.getIPSLabel('Project_Satus_Active');
        String projectStatusSubmittedPending = Core_IPS_Helper_Utility.getIPSLabel('Project_Satus_Submitted_Pending');
        String productStatusAutoApprove = Core_IPS_Helper_Utility.getIPSLabel('Product_Status_Auto_Approve');
        String productStatusApprovalRequired = Core_IPS_Helper_Utility.getIPSLabel('Product_Status_Approval_Required');
        String productStatusGeneral = Core_IPS_Helper_Utility.getIPSLabel('Product_Status_General');            //added by Aayushi US105154
    
        if(ipsProdList != null && ipsProdList.size()>0){        
            // APEX GURU - SOQL FIX 
            Map<Id, core_ips_product__c> ipsProdListMap = new Map<Id, core_ips_product__c>(ipsProdList);
            if(core_ips_product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
                productList=[select id,Is_Approved__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_Status__c,Core_IsSubmitted_Header__c,Core_Supported_Product__c,Core_Supported_Product__r.Core_Flag_Status__c,Core_IPS_IsAutoApprove__c,Status__c from core_ips_product__c where id IN : ipsProdListMap.keyset()];
             // productList=[select id,Is_Approved__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_Status__c,Core_IsSubmitted_Header__c,Core_Supported_Product__c,Core_Supported_Product__r.Core_Flag_Status__c,Core_IPS_IsAutoApprove__c,Status__c from core_ips_product__c where id IN:ipsProdList];        
            }
            if(ProductList <> null && ProductList.size()>0){
                for(core_ips_product__c productrecord : ProductList){
                    projectIds.add(Productrecord.Core_IPS_Project__c);     
                }
                if(projectIds != NULL && !projectIds.isEmpty() && Core_IPS_Account__c.SObjectType.getDescribe().isAccessible()){ //FLS check added - Aditya
                    projectAccounts = [SELECT Id,Core_Account__c,Core_IPS_Project__c,Core_Status__c FROM Core_IPS_Account__c WHERE Core_IPS_Project__c IN : projectIds];
                }
                if(projectAccounts != NULL && !projectAccounts.isEmpty()){
                    for(Core_IPS_Account__c projAccount : projectAccounts){
                        accountIds.add(projAccount.Core_Account__c);
                    }
                }
                
                if(!accountIds.isEmpty() && Asset.SObjectType.getDescribe().isAccessible() ){ //FLS Check added - Aditya
                    assetMap = new Map<Id,Asset>([SELECT Id,AccountId,Core_Supported_Product__c FROM Asset WHERE AccountId IN : accountIds]);
                }
                
                if(assetMap != NULL && !assetMap.isEmpty()){
                    for(Asset asst : assetMap.values()){
                        getAssetBySupportedProduct.put(asst.Core_Supported_Product__c,asst);
                    }    
                }
                for(core_ips_product__c productrecord: ProductList){
                    if(Productrecord != null && (Productrecord.Core_IPS_Project__r.Core_Status__c.equalsIgnoreCase(projectStatusActive) || Productrecord.Core_IPS_Project__r.Core_Status__c.equalsIgnoreCase(projectStatusSubmittedPending)) ){
                        if (Schema.sObjectType.core_ips_product__c.fields.Core_IsSubmitted_Header__c.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                            Productrecord.Core_IsSubmitted_Header__c = true;
                        }
                        // Productrecord.Status__c = 'Submitted';  
                        //modified IF and added OR condition by Aayushi US105154
                        if(Productrecord.Core_Supported_Product__r.Core_Flag_Status__c.equalsIgnoreCase(productStatusAutoApprove) || Productrecord.Core_Supported_Product__r.Core_Flag_Status__c.equalsIgnoreCase(productStatusGeneral)){
                            if (Schema.sObjectType.core_ips_product__c.fields.Core_IPS_IsAutoApprove__c.isUpdateable()) {
                            Productrecord.Core_IPS_IsAutoApprove__c = true;
                           }
                            if (Schema.sObjectType.core_ips_product__c.fields.Status__c.isUpdateable()) { /*--US1038641--06/25/2021--Haritha--FLS Check for security vulnerability--*/
                                Productrecord.Status__c = 'Auto Approve'; 
                            } 
                        }
                    }  
                    
                    //Added By Yogesh Sharma (US79808) Iteration 2
                    
                    if(Productrecord.Core_Supported_Product__r.Core_Flag_Status__c.equalsIgnoreCase(productStatusApprovalRequired)){
                        if(getAssetBySupportedProduct.containsKey(Productrecord.Core_Supported_Product__c)){
                            if(Productrecord != null && (Productrecord.Core_IPS_Project__r.Core_Status__c.equalsIgnoreCase(projectStatusActive) || Productrecord.Core_IPS_Project__r.Core_Status__c.equalsIgnoreCase(projectStatusSubmittedPending)) ){
                                if (Schema.sObjectType.core_ips_product__c.fields.Is_Approved__c.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                                    Productrecord.Is_Approved__c = true;
                                }
                            }
                            Productrecord.Core_IPS_IsAutoApprove__c = true;
                            Productrecord.Status__c = 'Auto Approve';                           
                        }
                        
                    }
                    UpdateProductList.add(Productrecord);
                }  
                if(!UpdateProductList.isEmpty()){  
                    update UpdateProductList;
                } 
            }  
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/ 
    public static void updateRecordType(List<core_ips_product__c> newList, Map<Id,core_ips_product__c> oldMap){
        if(newList <> null && newList.size()>0){
            List<core_ips_product__c> projProducts = new List<core_ips_product__c>();
            for(core_ips_product__c projProduct: newList){
                if(oldMap.get(ProjProduct.id).RecordTypeId == schema.sobjecttype.core_ips_product__c.getrecordtypeinfosbyname().get('IPS Project Product(Basic)').getRecordTypeId()  && oldMap.get(ProjProduct.id).Status__c <> ProjProduct.Status__c && ProjProduct.Status__c == 'Submitted' ){
                    ProjProduct.RecordTypeId = schema.sobjecttype.core_ips_product__c.getrecordtypeinfosbyname().get('IPS Project Product(Approval)').getRecordTypeId(); 
                }
            }           
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/ 
    public static void duplicateRecordprevention(List<Core_IPS_Product__c> newList){
    List<Core_IPS_Product__c> existingProducts = new List<Core_IPS_Product__c>();
        if(newList <> null && newList.size()>0){
            if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS Check already added - Aditya
                 existingProducts = [Select Core_IPS_Product_Name__c,Core_Supported_Product__c,Core_IPS_Project__c,Status__c from Core_IPS_Product__c where Core_IPS_Project__c =: newList[0].Core_IPS_Project__c];       
            }
            if(ExistingProducts <> null && ExistingProducts .size()>0){
                for(Core_IPS_Product__c newProjProduct: newList){
                    for(Core_IPS_Product__c existingProjProduct: ExistingProducts){
                        if(ExistingProjProduct.Status__c <> 'Not Approved'  && ExistingProjProduct.Core_Supported_Product__c == NewProjProduct.Core_Supported_Product__c)
                         {  
                              NewProjProduct.adderror('Cannot add the same Product twice');   
                         }                  
                    }
                }
            }
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
* Aayushi                    11/07/2018              Modified
***************************************************************************************************/   
    public static void preventDelete(List<Core_IPS_Product__c> oldList){
    Map<Id,Core_IPS_Product__c> projProductMap;
        //added trigger execution by Aayushi for US109046
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('PreventDelete')){
             return;
        }
        /*added by Aayushi 07-11-2017 US79852*/
        Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('CoreStatus_Draft');
        String status;
        //start added by Aayushi for US109046
        List<Id> projIdList=new List<Id>();
        List<Case> caseList=new List<Case>(); //end
        if(IpsLabels != NULL){
            status= (IpsLabels.Value__c == NULL || IpsLabels.Value__c == '')?  '' : IpsLabels.Value__c ;
        }
        if(oldList<> null && oldList.size()>0){
            if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
            projProductMap = new Map<Id,Core_IPS_Product__c>([Select id,Core_Supported_Product__c,Core_IPS_Project__r.Core_Status__c,Core_Supported_Product__r.Name from Core_IPS_Product__c where id IN: oldList]);
            }
            //start added by Aayushi for US109046
            for(Core_IPS_Product__c projProd: oldList){
                projIdList.add(projProd.Core_IPS_Project__c);    
                }
            
            if(projIdList!=null && projIdList.size()>0){
                caseList=[Select Id,Core_IPS_Supported_Product__c,Core_IPS_Project_Case__c from Case where Core_IPS_Project_Case__c In: projIdList AND Status!='Closed'];
                }//end
            for(Core_IPS_Product__c projProduct: oldList){
                //start added by Aayushi for US109046
                if(caseList!=null && caseList.size()>0){
                    for(Case case1:caseList){
                        if(case1.Core_IPS_Supported_Product__c==ProjProductMap.get(ProjProduct.id).Core_Supported_Product__c){
                            ProjProduct.adderror('Cannot delete this Project Product when all Cases on this Project Product are not Closed');    
                        }
                        else if(ProjProductMap.get(ProjProduct.id).Core_Supported_Product__c!=case1.Core_IPS_Supported_Product__c && ProjProductMap.get(ProjProduct.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                            ProjProduct.adderror('Cannot delete this Project Product when status is either Submitted or Active');
                        }
                        
                    }   
                }//end
                /*Modified by Aayushi 2-11-17 US79852*/
                //modified as part of US109046 
                if(ProjProductMap.get(ProjProduct.id).Core_IPS_Project__r.Core_Status__c <> status && !System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
                    ProjProduct.adderror('Cannot delete this Project Product when status is either Submitted or Active');
                }
            }
        }
    }
    
    /***************************************************************************************************
Version     : 1.0 
Created Date: 07 Dec 2015
Function    : 
Input Parameters: 
Output Parameters: None
Transactions: After Insert, After Update
Description: This method is used to Add IPS Enabled contacts to Project members object 
All the accounts added with All Core_member type are added to project member object
Used in     : Core_IPS_Account_Dispatcher
Number of Queries Within this Method: 2
Number of Queries in Loop: 0
Number of Queries from Called methods:1
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        12/07/2015              Created
*
***************************************************************************************************/   
    public static void InactivateAssets(List<Core_IPS_Product__c> newList, Map<Id,Core_IPS_Product__c> oldMap){
        if(newList<> null && newList.size()>0){
            List<Id> projectIds = new List<Id>();
            List<Id> suppProductIds = new List<Id>();
            for(Core_IPS_Product__c projProduct: newList){
                if(oldMap.get(ProjProduct.id).Core_IPS_Product_Status__c <> ProjProduct.Core_IPS_Product_Status__c && ProjProduct.Core_IPS_Product_Status__c == 'Inactive'){
                    ProjectIds.add(ProjProduct.Core_IPS_Project__c);
                    SuppProductIds.add(ProjProduct.Core_Supported_Product__c);
                }
            }
            if(ProjectIds <> null && ProjectIds.size()>0 && SuppProductIds <> null && SuppProductIds.size()>0){
                List<Asset> assets = new List<Asset>();
                List<Asset> assetList = [Select id, Status, UsageEndDate from Asset where Core_IPS_Project__c IN: ProjectIds and Core_Supported_Product__c IN: SuppProductIds];
                for(Asset asset: AssetList){
                    if (Schema.sObjectType.Asset.fields.Status.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                        Asset.Status = 'Inactive';
                    }
                    if (Schema.sObjectType.Asset.fields.UsageEndDate.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                        Asset.UsageEndDate = System.today();
                    }
                    Assets.add(Asset);
                }
                update Assets;
            }            
        }  
    }
    
/***************************************************************************************************
Version     : 1.0 
Created Date: 10 May 2018
UserStory    : US105268
Input Parameters: 
Output Parameters: None
Transactions: Before Insert
Description: This method is check that no Inactive Products gets added to the Project
Used in     : Core_IPS_ProductTrigger_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from Called methods:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        05/10/2018              Created US105268
*
***************************************************************************************************/   
    public static void preventAddingInactiveProduct(List<Core_IPS_Product__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventAddingInactiveProduct')) {return;}
        if(newList!=null && newList.size()>0){
            Core_IPS_Labels__c ipsLabels = Core_IPS_Labels__c.getValues('Core_IPS_InActiveProdError');
            String inActiveErrorMsg=ipsLabels.Value__c;
            for(Core_IPS_Product__c prod: newList){
                if(prod.Core_IPS_Product_Status__c!='Active'){
                 prod.addError(inActiveErrorMsg) ; 
                }
            }
        }
        
    }
    
/***************************************************************************************************
Version     : 1.0 
Created Date: 11 July 2018
UserStory    : US109046
Input Parameters: 
Output Parameters: None
Transactions: Delete
Description: This method is deletes related Assets if Project Product is deleted
Used in     : Core_IPS_ProductTrigger_Dispatcher
Number of Queries Within this Method: 
Number of Queries in Loop: 0
Number of Queries from Called methods:
Number of times called: Once for trigger execution
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi                        07/11/2018              Created US109046
*
***************************************************************************************************/ 
    public static void deleteAsset(List<Core_IPS_Product__c> oldList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('deleteAsset')) {return;} 
        if(oldList!=null && oldList.size()>0 && System.Label.Core_IPS_AdminAndSupport_ProfileId.contains(String.Valueof(UserInfo.getProfileId()).substring(0,15))){
            List<Id> projIdList=new List<Id>();
            List<Id> suppProdId=new List<Id>();
            List<Asset> assetListTobeDeleted=new List<Asset>();
         for(Core_IPS_Product__c projProd: oldList){
             projIdList.add(projProd.Core_IPS_Project__c);
             suppProdId.add(projProd.Core_Supported_Product__c);
         } 
            if(projIdList!=null && projIdList.size()>0 && suppProdId!=null && suppProdId.size()>0){
            assetListTobeDeleted=[Select Id from Asset where Core_IPS_Project__c In:projIdList AND Core_Supported_Product__c In: suppProdId];
            }
            
            if(assetListTobeDeleted!=null && assetListTobeDeleted.size()>0){
                /*US1038641 - 06/23/2021 - Yamini - CRUD Delete Check for security vulnerability --*/
                if (Asset.sObjectType.getDescribe().isDeletable()) {
                Database.delete(assetListTobeDeleted);
                }
            }
        }    
    }

/***************************************************************************************************
    Version     : 1.0 
    Created Date: 27/12/2018
    Function    : 
    Input Parameters: List
    Output Parameters: None
    Transactions: 
    Description: This method is used to add Default Case Owner on Private Project to IST          
    Used in     : Core_IPS_Project_Dispatcher
    Number of Queries Within this Method: 1 
    Number of Queries in Loop: 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi                     27/12/2018         Created - US237468
    ****************************************************************************************************/
    public static void addDefaultCaseOwnerToIST(List<Core_IPS_Product__c> newList,Map<Id,Core_IPS_Product__c> oldMap){
        
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('addDefaultCaseOwnerToIST')) {
            return;
        }
        try {
            List<Core_IPS_Product__c> prodScopeList = new List<Core_IPS_Product__c>();
            Set<Id> prodSet = new Set<Id>();
            Set<Id> ownerIDs = new Set<Id>();
            Set<ID> projSet=new Set<Id>();
            Map<Id, Set<Id>> mapActiveExistingOwnerIDs = new Map<Id, Set<Id>>();
            Map<Id, Map<Id, Core_IPS_Intel_Support_Team__c>> mapInactiveExistingOwnerIDs = new Map <Id, Map<Id, Core_IPS_Intel_Support_Team__c>>();
            List<Core_IPS_Intel_Support_Team__c> lstIST2Upsert = new List<Core_IPS_Intel_Support_Team__c>();
            Map<Id,Id> prodAndProjMap= new Map<Id,Id>();
            for(Core_IPS_Product__c prod: newList){
                if(oldMap == null|| (oldMap != null && prod.Core_IPS_Prod_Def_Case_Owner_ID__c!= oldMap.get(prod.Id).Core_IPS_Prod_Def_Case_Owner_ID__c)){ //made changes by sumukh for US586420 
                    prodSet.add(prod.Id);    
                }   
            }
            if(prodSet!=null && prodSet.size()>0){
                List<String> userTypeList = new List<String>();
                //Getting internal users for IST Members addition based on UserType
                if (String.isNotBlank(Label.UserType_Standard)) {
                    userTypeList.add(Label.UserType_Standard);
                }
                
                List<User> userList = [SELECT Id from User where UserType IN :userTypeList and isActive= true];
                Set<String> usrIdStrSet = new Set<String>();
                for(User usr : userList) {
                 usrIdStrSet.add(usr.Id);
                }
                if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
                prodScopeList=[Select Id,Core_IPS_Prod_Def_Case_Owner_ID__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_IPS_Private__c from Core_IPS_Product__c where Core_IPS_Project__r.Core_IPS_Private__c=true and Core_IPS_Prod_Def_Case_Owner_ID__c in :usrIdStrSet and Id in :prodSet]; // made changes by sumukh for US586420 
                for(Core_IPS_Product__c prod: prodScopeList){
                    ownerIDs.add(prod.Core_IPS_Prod_Def_Case_Owner_ID__c);  //made changes by sumukh for US586420  
                    projSet.add(prod.Core_IPS_Project__c);
                }
                }
                if(projSet!=null && projSet.size()>0){
                    if(Core_IPS_Intel_Support_Team__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
                    for(Core_IPS_Intel_Support_Team__c istMem: [Select Id, Core_IPS_Project__c, status__c, Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_User__c in: ownerIDs and Core_IPS_Project__c in: projSet]){
                        if (istMem.Status__c == 'Active') {
                            if (!mapActiveExistingOwnerIDs.containsKey(istMem.Core_IPS_Project__c)) {
                                mapActiveExistingOwnerIDs.put(istMem.Core_IPS_Project__c, new Set<Id>());
                            }
                            mapActiveExistingOwnerIDs.get(istMem.Core_IPS_Project__c).add(istMem.Core_IPS_User__c);
                            
                        } else {
                            //inactiveISTProjList.add(istMem);
                            if (!mapInactiveExistingOwnerIDs.containsKey(istMem.Core_IPS_Project__c)) {
                                mapInactiveExistingOwnerIDs.put(istMem.Core_IPS_Project__c, new Map <Id, Core_IPS_Intel_Support_Team__c>());
                            }
                            mapInactiveExistingOwnerIDs.get(istMem.Core_IPS_Project__c).put(istMem.Core_IPS_User__c, istMem);
                        }  
                    } }      
                }
                
                for (Core_IPS_Product__c prod : prodScopeList) {
                    if(mapActiveExistingOwnerIDs !=null && mapActiveExistingOwnerIDs.containsKey(prod.Core_IPS_Project__c) && mapActiveExistingOwnerIDs.get(prod.Core_IPS_Project__c).contains(prod.Core_IPS_Prod_Def_Case_Owner_ID__c)){ //made changes by sumukh for US586420
                        continue;
                    }
                    else if(mapInactiveExistingOwnerIDs !=null && mapInactiveExistingOwnerIDs.containsKey(prod.Core_IPS_Project__c) && mapInactiveExistingOwnerIDs.get(prod.Core_IPS_Project__c).containsKey(prod.Core_IPS_Prod_Def_Case_Owner_ID__c)) { //made changes by sumukh for US586420
                        Core_IPS_Intel_Support_Team__c istUpdateRec = mapInactiveExistingOwnerIDs.get(prod.Core_IPS_Project__c).get(prod.Core_IPS_Prod_Def_Case_Owner_ID__c);    //made changes by sumukh for US586420                                                         
                        if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Status__c.isUpdateable() || Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Status__c.isCreateable()) {/*--US1038641--06/25/2021--Haritha--FLS Check for security vulnerability--*/
                            istUpdateRec.Status__c = 'Active';
                        }
                        if(prod.Core_IPS_Prod_Def_Case_Owner_ID__c!=null && prod.Core_IPS_Prod_Def_Case_Owner_ID__c.startsWith('005')){ //made changes by sumukh for US586420
                        lstIST2Upsert.add(istUpdateRec);
                        }
                      }
                      else {
                        Core_IPS_Intel_Support_Team__c istInsertRec = new Core_IPS_Intel_Support_Team__c();
                        if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_Project__c.isUpdateable() || Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_Project__c.isCreateable()) {
                        istInsertRec.Core_IPS_Project__c = prod.Core_IPS_Project__c;
                        }
                        if (Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_User__c.isUpdateable() || Schema.sObjectType.Core_IPS_Intel_Support_Team__c.fields.Core_IPS_User__c.isCreateable()) {
                        istInsertRec.Core_IPS_User__c = prod.Core_IPS_Prod_Def_Case_Owner_ID__c; //made changes by sumukh for US586420
                        }
                        istInsertRec.Status__c = 'Active';                      
                        if(prod.Core_IPS_Prod_Def_Case_Owner_ID__c!=null && prod.Core_IPS_Prod_Def_Case_Owner_ID__c.startsWith('005')){ //made changes by sumukh for US586420
                        lstIST2Upsert.add(istInsertRec);
                        }
                    }
                }
                if(lstIST2Upsert.size()>0){ 
                    upsert lstIST2Upsert;
                }   
            }
        }catch (Exception e) {
        }
        
    }
}