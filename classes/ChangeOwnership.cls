public class ChangeOwnership {
    public List<Case> caseList {Set;Get;} 
    public List<Asset> assetList {SET;Get;}
    public List<Core_IPS_Case_Interested_Party__c> intrestedPartyList {SET;Get;}
    public List<CaseComment> caseCommentList {SET;Get;} 
    public List<Core_IPS_Project__c> projectList {SET;Get;}
    public List<Core_IPS_Case_Attachments__c> caseAttachmentList {SET;Get;}
    public List<CaseShare> caseShareList {SET;Get;}
    public List<AssetShare> assetShareList {SET;Get;}
    public List<Core_IPS_Project__Share> projectShareList {SET;Get;}
    public List<Case> customerCase {SET;Get;}
    public List<Case> partnerCase {SET;Get;}
    public group group1 {SET;Get;}
    public id terminatedUser{Set;Get;}
    public id targetUser{Set;Get;}
   /* public ChangeOwnership(){
    group group1 = [SELECT Id FROM Group WHERE Name = 'TestCommunity'];  
        
    }*/
    public static id changeOwner(){
 /*  List<Case> caseList=new List<Case>();
        caseList=[SELECT AccountId,AssetId,CaseNumber,ClosedDate,ContactEmail,Core_CaseType__c,Core_Case_Co_Owner__c,Core_IPS_Case_Owner_Email__c,Core_IPS_Case_Owner_Name__c,Core_IPS_Case__c,Core_IPS_Comment__c,Core_IPS_CreatedBy_User__c,Core_IPS_File_Attachment_Flag__c,Core_IPS_GEC_Case__c,Core_IPS_Product__c,Core_IPS_Project_Case__c,Core_IPS_Supported_Product__c,Core_Issue_Description__c,Core_Product_Type__c,Core_Request_Case_Close__c,Description,Id,IsClosed,Origin,OwnerId,Priority,ProductId,RecordTypeId,Status,Subject,Type FROM Case WHERE OwnerId = :terminatedUser OR CreatedById= :terminatedUser ];
        System.debug('Case List :  '+caseList); 
        
     List<Asset> assetList=new List<Asset>();
        assetList=[SELECT AccountId,ContactId,Core_IPS_Project_Name__c,Core_Project_Asset_Status__c,Core_Supported_Product__c,Core_Support_Org_Name__c,Description,Id,Name,OwnerId,Price,Product2Id,ProductCode,PurchaseDate,Quantity,RecordTypeId,Status FROM Asset WHERE OwnerId = :terminatedUser Or CreatedById= : terminatedUser ];
        System.debug('Asset List :  '+assetList);
        
     List<Core_IPS_Case_Interested_Party__c> intrestedPartyList = new List<Core_IPS_Case_Interested_Party__c>();
      intrestedPartyList=[SELECT Active__c,Agent_Name__c,Case__c,Contact__c,Core_IPS_Account_Name__c,CreatedById,Email__c,First_Name__c,Id,IsDeleted,Last_Name__c,Name,RecordTypeId,Test__c,Type__c,User__c FROM Core_IPS_Case_Interested_Party__c WHERE CreatedById =:terminatedUser ]; 
   //   intrestedPartyList=[SELECT Active__c,Agent_Name__c,Case__c,Contact__c,Core_IPS_Account_Name__c,CreatedById,Email__c,First_Name__c,Id,IsDeleted,Last_Name__c,Name,RecordTypeId,Test__c,Type__c,User__c FROM Core_IPS_Case_Interested_Party__c WHERE ((CreatedById =:terminatedUser) OR (OwnerId =:terminatedUser)) ]; 
      System.debug('Interested Party List : '+intrestedPartyList); 
      
     List<CaseComment> caseCommentList = new List<CaseComment>();
        caseCommentList = [SELECT CommentBody,CreatedById,CreatedDate,Id,IsDeleted,IsPublished,LastModifiedById,LastModifiedDate,ParentId FROM CaseComment WHERE CreatedById = : terminatedUser];  
        System.debug('Case CommentList :  '+caseCommentList);
        
     List<Core_IPS_Project__c> projectList = new List<Core_IPS_Project__c>();
        projectList =[SELECT Core_IPS_GroupId__c,Core_IPS_Group_Name__c,Core_IPS_Legacy_Collab_Team_ID__c,Core_IPS_ProjectGroupID__c,Core_IPS_Project_ID__c,Core_IPS_Unique_Project_Number__c,Core_MPNDA__c,Core_Number_of_Accounts__c,Core_Number_of_Opportunities__c,Core_Number_of_Products__c,Core_Number_of_Users__c,Core_Project_Description__c,Core_Status__c,CreatedById,Id,IsDeleted,Name,OwnerId,RecordTypeId FROM Core_IPS_Project__c WHERE OwnerId = :terminatedUser];
        System.debug('Project List : '+projectList);
        
     List<Core_IPS_Case_Attachments__c> caseAttachmentList = new List<Core_IPS_Case_Attachments__c>();
        caseAttachmentList=[SELECT Core_Case__c,Core_Category__c,Core_FileSizeInBytes__c,Core_FileUploadedBy__c,Core_File_Description__c,Core_File_GUID__c,Core_File_Hyperlink__c,Core_File_Name__c,Core_File_Size__c,Core_File_URL__c,Core_IPS_File_Upload__c,Core_Is_Migrated__c,Core_Last_Status_Updated_At__c,Core_Promote_Status__c,Core_Type__c,Core_Upload_idsid__c,Core_Upload_Status__c,Core_Upload_UserId__c,CreatedById,CreatedDate,Id,IsDeleted,Name FROM Core_IPS_Case_Attachments__c WHERE CreatedById = :terminatedUser];
        System.debug('Case Attachment List : '+caseAttachmentList);
        
     List<CaseShare> caseShareList = new List<CaseShare>();
        caseShareList = [SELECT CaseAccessLevel,CaseId,Id,IsDeleted,LastModifiedById,LastModifiedDate,RowCause,UserOrGroupId FROM CaseShare WHERE UserOrGroupId = :terminatedUser]; 
        System.debug('Case Share List : '+caseShareList);
        
     List<AssetShare> assetShareList = new List<AssetShare>();
        assetShareList = [SELECT AssetAccessLevel,AssetId,Id,IsDeleted,LastModifiedById,LastModifiedDate,RowCause,UserOrGroupId FROM AssetShare WHERE UserOrGroupId = :terminatedUser];
        System.debug('Asset Share List : '+assetShareList);
        
     List<Core_IPS_Project__Share> projectShareList =new List<Core_IPS_Project__Share>();
        projectShareList =[SELECT AccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,ParentId,RowCause,UserOrGroupId FROM Core_IPS_Project__Share WHERE UserOrGroupId = :terminatedUser];
        System.debug('Project Share List : '+projectShareList);
        
       /*  List<GroupMember> GMlist = new List<GroupMember>();    
            GroupMember GM = new GroupMember();
            GM.GroupId = '00G3F000000Qhka';
            GM.UserOrGroupId = '0053F000000Qxjd';
            GM.UserOrGroupId = '0053F000000R1ET';
            GMList.add(GM);
        insert GMList; 
    }*/
    //  group group1= new group();  
        id group1 = [SELECT Id FROM Group WHERE Name = 'TestCommunity'].Id;
      // Id user = [SELECT Id,name FROM User WHERE id = : UserInfo.getUserid() LIMIT 1].Id;
        Id user = [SELECT Id,name FROM User WHERE id =  '0053F000000Qxjd' LIMIT 1].Id;
        System.debug('User : '+user);
        GroupMember gm = new GroupMember(GroupId = group1 ,UserOrGroupId = user);
      
        insert gm;
        System.debug('gp member inserted'+group1);
        ChangeOwnership.changeOwnerGroup(group1);
        return group1;
    }
     @future
      public static void changeOwnerGroup(string group1){ 
     // List<Case> customerCase =new List<Case>(); 
      System.debug('start'+group1);   
      case customerCase =[SELECT Id,OwnerId,CreatedById FROM Case where Id = '5003F000000rD8J'];
      //List<Case> partnerCase =new List<Case>();  
      case partnerCase= [SELECT Id,OwnerId,CreatedById FROM Case where Id = '5003F000000rHb0'];
      System.debug('before method');       
     // id gpId= ChangeOwnership.changeOwner();  
      System.debug('after method');       
      customerCase.OwnerId =group1;//[SELECT Id FROM Group WHERE Name = 'TestCommunity'].Id;
      System.debug('gp id assigned');      
      update customerCase;
      System.debug('updated caseowner');      
     // System.debug('Cust---'+customerCase.OwnerId+ '   Part-- '+partnerCase.OwnerId);
        
    }
}