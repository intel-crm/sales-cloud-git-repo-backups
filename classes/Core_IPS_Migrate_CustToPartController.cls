public without sharing class Core_IPS_Migrate_CustToPartController {
    public Id contactId=null;
    public Id accountId=null;
    public Id CustUserId=null;
    public Id PartnerUserId=null;
    public Id groupIdByRoleId=null;
    public Id groupIdByPartnerRoleId=null;
    public List<User> userlst=null;
    public transient List<Core_Contact_Entitlement__c> contactEntList{get;set;}
    public transient List<Core_IPS_Sobject_Share_Record__c>  sobjRecdList{get;set;}
    public transient List<Core_IPS_Case_Interested_Party__c> interestedPartiesList{get;set;}
    public transient List<Core_IPS_Project__c> projOwnerList{get;set;}
    public transient List<Core_IPS_Project_Member__c>  projMemList{get;set;}
    public String sharingStatus='commit';
       
    public Core_IPS_Migrate_CustToPartController(ApexPages.StandardController controller) {
        contactId=controller.getId();
        onLoadShowRecords('Show');
    }
    // Fetching sharing records and saving to the custom Object.
    public void fetchCustomerRecords(){
        if(sobjRecdList==null)
             sobjRecdList=new List<Core_IPS_Sobject_Share_Record__c>();
        getPartnerUserId();
        if(PartnerUserId!=null){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Contact is already a Partner.'));
           return;
        }
        getCustomerUserId();
        if(CustUserId==null){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'This Contact is not enable as customer.'));
           return;
        }
        DeletePreviousRecords();
        getContactRelatedRecords();
        getUserRoleWorkerByAccount();
        getCaseShareRecords();
        getAssetShareRecords();
        getProjectShareRecords();
        updateEntAndUserRecord();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Records are successfully Commited.'));
       // onLoadShowRecords('Hide');
        CustUserId=null;
    }
    // Showing All records After change done
    public void onLoadShowRecords(String MessageVisible){
        getPartnerUserId();
        if(PartnerUserId!=null && MessageVisible =='Show'){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Contact is a Partner '));
        }
        getCustomerUserId();
        if(CustUserId!=null && MessageVisible =='Show'){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Contact is a Customer '));
        }
        FetchcontactInfoSobjectRecords();
        getEntitlement();
        FetchAllSobjectRecords();
        getInterestedPartiesList();
        getProjectOwner();
        getProjectMember();
        CustUserId=null;
        PartnerUserId=null;
    }   
    // Getting Customer Information
    public void getCustomerUserId(){
        Id CustRoleId=null;
        userlst=[SELECT id,username,name,userroleid,contactid,profileid,Accountid,email,isactive from user where contactid=:contactId and profile.Name='IPS External Customer' ];
        if(userlst.size()>0){
            CustUserId=userlst[0].id;
            CustRoleId=userlst[0].userroleid;
            getCustomerGroupInfoByRole(CustRoleId);
         }
    }
    // Getting Customer Groupid with based on the role
    public void getCustomerGroupInfoByRole(Id CustRoleId ){
          groupIdByRoleId=[SELECT Id, Name,RelatedId,Type FROM Group where relatedid =:CustRoleId and Type='Role' limit 1].id;
    }
    // Getting All the entitlement 
    public void getEntitlement(){
        contactEntList=[SELECT Id,Name,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.name,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_Update_Reason__c FROM Core_Contact_Entitlement__c where Core_Contact_Id__c =:contactId];
    }
    // Getting Account userrole based on the account
    public void getUserRoleWorkerByAccount(){
        accountId=[select accountid from Contact where id=:contactId].accountId;
        List<UserRole> userRoleLst=[Select id,PortalAccountId,PortalRole,PortalType from userrole where PortalAccountId=:accountId and PortalRole='Worker' and PortalType ='Partner'];
        if(userRoleLst.size()>0)
             groupIdByPartnerRoleId=[SELECT Id, Name,RelatedId,Type FROM Group where relatedid =:userRoleLst[0].id and Type='Role' limit 1].id;
      
    }
    // Getting Contact related information to the Sobject share records.
    public  Void getContactRelatedRecords(){
        sobjRecdList=new List<Core_IPS_Sobject_Share_Record__c>();
        Core_IPS_Sobject_Share_Record__c sobjrec=new Core_IPS_Sobject_Share_Record__c();
        sobjrec.Name=contactId;
        sobjrec.Core_IPS_Contact_Id__c=contactId;
        sobjrec.Core_IPS_Customer_User_Id__c=CustUserId;
        sobjrec.Core_IPS_Sobject_Type__c='CustomerUserinfo';
        sobjrec.Core_IPS_Status__c='Commit';
        sobjRecdList.add(sobjrec); 
        if(sobjRecdList.size()>0){
            insert sobjRecdList;
        }
    }
    // Getting Case share based on the customer user id and rolebasedgroup id
    public  Void getCaseShareRecords(){
          sobjRecdList=new List<Core_IPS_Sobject_Share_Record__c>();
          List<Id> tempCaseIds=new List<Id>();
          for(Caseshare cs:[select id,caseid from caseshare where UserOrGroupId =:groupIdByPartnerRoleId and RowCause='Manual']){
              tempCaseIds.add(cs.caseid);
          }
          List<CaseShare> caseShareRecordList=[SELECT CaseAccessLevel, CaseId, Id, RowCause, UserOrGroupId FROM CaseShare where (UserOrGroupId =:CustUserId Or (UserOrGroupId =:groupIdByRoleId and caseId Not in :tempCaseIds)) and RowCause='Manual'];
          for(CaseShare csShare: caseShareRecordList){
                Core_IPS_Sobject_Share_Record__c sobjrec=new Core_IPS_Sobject_Share_Record__c();
                sobjrec.Name=csShare.id;
                sobjrec.Core_IPS_Contact_Id__c=contactId;
                sobjrec.Core_IPS_Customer_User_Id__c=CustUserId;
                sobjrec.Core_IPS_Sobject_Type__c='CaseShare';
                sobjrec.Core_IPS_RowCause__c=csShare.RowCause;
                sobjrec.Core_IPS_SobjectAccessLevel__c=csShare.CaseAccessLevel;
                sobjrec.Core_IPS_SobjectId__c=csShare.CaseId;
                sobjrec.Core_IPS_Status__c='Commit';
                sobjrec.Core_IPS_UserOrGroupId__c=csShare.UserOrGroupId;
                sobjRecdList.add(sobjrec); 
          }
          if(sobjRecdList.size()>0){
                insert sobjRecdList;
          }
          
    }
    // Getting Asset share based on the customer user id and rolebasedgroup id
    public  Void getAssetShareRecords(){
         sobjRecdList=new List<Core_IPS_Sobject_Share_Record__c>();
         List<Id> tempAssetIds=new List<Id>();
          for(AssetShare partnerAssetShare:[select id,assetid from AssetShare where UserOrGroupId =:groupIdByPartnerRoleId and RowCause='Manual']){
              tempAssetIds.add(partnerAssetShare.assetid);
          }
         List<AssetShare> assetShareRecords=[SELECT AssetAccessLevel,AssetId,Id,RowCause,UserOrGroupId FROM AssetShare where (UserOrGroupId =:CustUserId Or (UserOrGroupId =:groupIdByRoleId and AssetId not in :tempAssetIds)) and RowCause='Manual' ];
         for(AssetShare astShare: assetShareRecords){
                Core_IPS_Sobject_Share_Record__c sobjrec=new Core_IPS_Sobject_Share_Record__c();
                sobjrec.Name=astShare.id;
                sobjrec.Core_IPS_Contact_Id__c=contactId;
                sobjrec.Core_IPS_Customer_User_Id__c=CustUserId;
                sobjrec.Core_IPS_Sobject_Type__c='AssetShare';
                sobjrec.Core_IPS_RowCause__c=astShare.RowCause;
                sobjrec.Core_IPS_SobjectAccessLevel__c=astShare.AssetAccessLevel;
                sobjrec.Core_IPS_SobjectId__c=astShare.AssetId;
                sobjrec.Core_IPS_Status__c='Commit';
                sobjrec.Core_IPS_UserOrGroupId__c=astShare.UserOrGroupId;
                sobjRecdList.add(sobjrec); 
          }
          if(sobjRecdList.size()>0){
                insert sobjRecdList;
          }
    }
    // Getting Project share based on the customer user id and rolebasedgroup id
    public  Void getProjectShareRecords(){
         sobjRecdList=new List<Core_IPS_Sobject_Share_Record__c>();
       
         List<Id> tempProjIds=new List<Id>();
          for(Core_IPS_Project__Share partnerprojShare:[select id from Core_IPS_Project__Share where UserOrGroupId =:groupIdByPartnerRoleId and RowCause='Manual']){
              tempProjIds.add(partnerprojShare.ParentId);
          }
         List<Core_IPS_Project__Share> projShareRecords=[SELECT AccessLevel,Id,IsDeleted,LastModifiedById,LastModifiedDate,ParentId,RowCause,UserOrGroupId FROM Core_IPS_Project__Share where (UserOrGroupId =:CustUserId Or (UserOrGroupId =:groupIdByRoleId and ParentId not in:tempProjIds)) and RowCause='Manual' ];
         for(Core_IPS_Project__Share projShare: projShareRecords){
                Core_IPS_Sobject_Share_Record__c sobjrec=new Core_IPS_Sobject_Share_Record__c();
                sobjrec.Name=projShare.id;
                sobjrec.Core_IPS_Contact_Id__c=contactId;
                sobjrec.Core_IPS_Customer_User_Id__c=CustUserId;
                sobjrec.Core_IPS_Sobject_Type__c='ProjectShare';
                sobjrec.Core_IPS_RowCause__c=projShare.RowCause;
                sobjrec.Core_IPS_SobjectAccessLevel__c=projShare.AccessLevel;
                sobjrec.Core_IPS_SobjectId__c=projShare.ParentId;
                sobjrec.Core_IPS_Status__c='Commit';
                sobjrec.Core_IPS_UserOrGroupId__c=projShare.UserOrGroupId;
                sobjRecdList.add(sobjrec); 
          }
          if(sobjRecdList.size()>0){
                insert sobjRecdList;
          }
    
    }
    // Getting Interested Parties based on the customer user id
    public void getInterestedPartiesList(){
        interestedPartiesList=[Select Id, Name, Case__c, Active__c, Agent_Name__c, Contact__c, First_Name__c, Last_Name__c, User__c FROM Core_IPS_Case_Interested_Party__c where User__c IN (:CustUserId,:PartnerUserId) AND User__c !=null  ];
    }
    // Getting Project Owner based on the customer user id
    public void getProjectOwner(){
        projOwnerList =[select id, name,ownerid,Core_Status__c  from Core_IPS_Project__c where ownerid IN (:CustUserId,:PartnerUserId) AND ownerid!=null ];
        
    }
    // Getting Project Member
    public void getProjectMember(){
        projMemList =[SELECT Core_IPS_Contact_Account__c,Core_IPS_Contact__c,Core_IPS_Project__c,Core_Selective_Member__c,Core_Status__c,Core_User__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,SystemModstamp FROM Core_IPS_Project_Member__c where Core_User__c IN (:CustUserId,:PartnerUserId) AND Core_User__c !=null];
    }
    // Saving All sharing records 
    public void DeletePreviousRecords(){
            // Deleting the previous gathered records related to this contact
            sobjRecdList=[select id from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId];
            if(sobjRecdList.size()>0 && CustUserId !=null){
                Delete sobjRecdList;
            // Inserting newly Gathered Records
            //    insert sobjRecdList;
            }
    }
    //Update Entitlement and User Records
    public void updateEntAndUserRecord(){
       // getCustomerUserId();
        disableIPSCustomerEntitlement();
        //Enabling Account as a partner if not alraedy there 
        List<Contact> lstContact=[select id,accountid from contact where id=:contactId];
        if(lstContact.size()>0){
            List<Account> lstAccount=[select id,IsPartner from account where id=:lstContact[0].accountid and IsPartner =false];
            if(lstAccount.size()>0){
                lstAccount[0].IsPartner =true;
                update lstAccount;
            }
        }
    }
    // Removing Customer IPS Entitlement
    public void  disableIPSCustomerEntitlement(){
        List<Core_Contact_Entitlement__c> conEnt=[SELECT Id,Name,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.name,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_Update_Reason__c FROM Core_Contact_Entitlement__c where Core_Contact_Id__c =:contactId and Core_Entitlement_Id__c=:Label.Core_Entitlement_IPS_Id];
        if(conEnt.size()>0){
            conEnt[0].Core_Status__c='Pending';
            conEnt[0].Core_Selected__c=false;
            conEnt[0].Core_Data_Loaded__c=true;
            update conEnt;
        }
        if(CustUserId!=null){
            updateUser(CustUserId);
            SendMailToAGS();
            CustUserId=null;
        }
    }
    // Updating Partner user related records
    public void updateShareForPartner(){
     //   getEntitlement();
        getPartnerUserId();
        if(PartnerUserId==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Waiting to enable contact as Partner'));
            onLoadShowRecords('Hide'); 
            return;
        }
        FetchcontactInfoSobjectRecords();
        try{
            addContactRelatedRecords();
            addAssetShareForPartner();
            addCaseShareForPartner();
            addProjShareForPartner();
            addInterestedPartiesList();
            updateProjectMember();
            updateProjectOwner();
            if(sharingStatus=='Complete')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Sharing is already applied to Partner'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Sharing records are successfully added to Partner'));
            onLoadShowRecords('Hide'); 
           }catch(Exception ex){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Check Your Permission: '+ex)); 
           }
          
    }
    
    // Getting Partner details
    public void getPartnerUserId(){
        Id PartRoleId=null;
        userlst=[SELECT id,username,name,userroleid,contactid,profileid,Accountid,email,isactive from user where contactid=:contactId and profile.Name='Partner' ];
        if(userlst.size()>0){
            PartnerUserId=userlst[0].id;
            PartRoleId=userlst[0].userroleid;
            getPartnerGroupInfoByRole(PartRoleId);
         }
    }
    // Getting Partner Groupid with based on the role
    public void getPartnerGroupInfoByRole(Id PartRoleId ){
          groupIdByRoleId=[SELECT Id, Name,RelatedId,Type FROM Group where relatedid =:PartRoleId and Type='Role' limit 1].id;
    }
    public void FetchcontactInfoSobjectRecords(){
        sobjRecdList= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Sobject_Type__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId limit 1];
        if(sobjRecdList.size()>0){
              CustUserId =sobjRecdList[0].Core_IPS_Customer_User_Id__c;
              sharingStatus=sobjRecdList[0].Core_IPS_Status__c;
        }
    }
    // Getting All Data based on the contacts from custom object
    public  Void FetchAllSobjectRecords(){
          sobjRecdList= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Sobject_Type__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId limit 500];
          Integer countRecords=[Select Id from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId].size();
          if(countRecords>500)
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, '500 records is showing, there are more records: '+countRecords));
          if(sobjRecdList !=null && sobjRecdList.size()>0 && [select id from user where id=:sobjRecdList[0].Core_IPS_Customer_User_Id__c and isActive=true].size()>0)
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.InFo, 'Note: After \"Commit\" User is not disabled please deactivate user manually and follow further steps.'));
   
    }
    // Getting Contact related information to the Sobject share records.
    public  Void addContactRelatedRecords(){
          List<Core_IPS_Sobject_Share_Record__c > sobjShareRecords= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Sobject_Type__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId and Core_IPS_Status__c!='Complete' and Core_IPS_Sobject_Type__c ='CustomerUserinfo'];
          for(Core_IPS_Sobject_Share_Record__c sobjShareRec: sobjShareRecords){
                sobjShareRec.Partner_User_Id__c =PartnerUserId;
                sobjShareRec.Core_IPS_Status__c='Complete';
          }
          if(sobjShareRecords.size()>0){
            update sobjShareRecords;
          }
    }
    // Adding Asset share to the partner user and updating custom object record to complete
    public  Void addAssetShareForPartner(){
          List<Core_IPS_Sobject_Share_Record__c > sobjShareRecords= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Sobject_Type__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId and Core_IPS_Status__c!='Complete' and Core_IPS_Sobject_Type__c ='AssetShare'];
          List<AssetShare> astList=new List<AssetShare>();
          for(Core_IPS_Sobject_Share_Record__c sobjShareRec: sobjShareRecords){
                AssetShare astRec= new AssetShare();
                astRec.RowCause=sobjShareRec.Core_IPS_RowCause__c;
                astRec.AssetAccessLevel=sobjShareRec.Core_IPS_SobjectAccessLevel__c;
                astRec.AssetId=sobjShareRec.Core_IPS_SobjectId__c;
                if((sobjShareRec.Core_IPS_UserOrGroupId__c).startsWith('005'))
                    astRec.UserOrGroupId=PartnerUserId;
                else
                    astRec.UserOrGroupId=groupIdByRoleId;
                sobjShareRec.Partner_User_Id__c =PartnerUserId;
                sobjShareRec.Core_IPS_Status__c='Complete';
                astList.add(astRec);
          }
          if(astList.size()>0)
              insert astList;
          if(sobjShareRecords.size()>0)
              update sobjShareRecords;
    }
    // Adding case share to the partner user and updating custom object record to complete 
    public Void addCaseShareForPartner(){
          List<Core_IPS_Sobject_Share_Record__c > sobjShareRecords= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId and Core_IPS_Status__c!='Complete' and Core_IPS_Sobject_Type__c ='CaseShare'];
          List<CaseShare> csList=new List<CaseShare>();
          for(Core_IPS_Sobject_Share_Record__c sobjShareRec: sobjShareRecords){
                CaseShare csRec= new CaseShare();
                csRec.RowCause=sobjShareRec.Core_IPS_RowCause__c;
                csRec.caseAccessLevel=sobjShareRec.Core_IPS_SobjectAccessLevel__c;
                csRec.CaseId=sobjShareRec.Core_IPS_SobjectId__c;
                if((sobjShareRec.Core_IPS_UserOrGroupId__c).startsWith('005'))
                    csRec.UserOrGroupId=PartnerUserId;
                else
                    csRec.UserOrGroupId=groupIdByRoleId;   
                sobjShareRec.Partner_User_Id__c =PartnerUserId;
                sobjShareRec.Core_IPS_Status__c='Complete';
                csList.add(csRec);
          }
          if(csList.size()>0)
              insert csList;
          if(sobjShareRecords.size()>0)
              update sobjShareRecords;
    }
    // Adding Project share to the partner user and updating custom object record to complete
    public  Void addProjShareForPartner(){
          List<Core_IPS_Sobject_Share_Record__c > sobjShareRecords= [Select Id,name,Core_IPS_Contact_Id__c,Core_IPS_Customer_User_Id__c,Partner_User_Id__c,Core_IPS_RowCause__c,Core_IPS_SobjectAccessLevel__c,Core_IPS_SobjectId__c,Core_IPS_Status__c,Core_IPS_UserOrGroupId__c from Core_IPS_Sobject_Share_Record__c where Core_IPS_Contact_Id__c=:contactId and Core_IPS_Status__c!='Complete' and Core_IPS_Sobject_Type__c ='ProjectShare'];
          List<Core_IPS_Project__Share> projShareList=new List<Core_IPS_Project__Share>();
          for(Core_IPS_Sobject_Share_Record__c sobjShareRec: sobjShareRecords){
                Core_IPS_Project__Share projShareRec= new Core_IPS_Project__Share();
                projShareRec.RowCause=sobjShareRec.Core_IPS_RowCause__c;
                projShareRec.AccessLevel=sobjShareRec.Core_IPS_SobjectAccessLevel__c;
                projShareRec.ParentId=sobjShareRec.Core_IPS_SobjectId__c;
                if((sobjShareRec.Core_IPS_UserOrGroupId__c).startsWith('005'))
                    projShareRec.UserOrGroupId=PartnerUserId;
                else
                    projShareRec.UserOrGroupId=groupIdByRoleId;   
                sobjShareRec.Partner_User_Id__c =PartnerUserId;
                sobjShareRec.Core_IPS_Status__c='Complete';
                projShareList.add(projShareRec);
          }
          if(projShareList.size()>0)
              insert projShareList;
          if(sobjShareRecords.size()>0)
              update sobjShareRecords;
    }
    // Adding Interested Parties to the partner user
    public void addInterestedPartiesList(){
         interestedPartiesList=[Select Id, Name, Case__c, Active__c, Agent_Name__c, Contact__c, First_Name__c, Last_Name__c, User__c FROM Core_IPS_Case_Interested_Party__c where User__c=:CustUserId AND User__c !=null];
         for(Core_IPS_Case_Interested_Party__c  csIntParty: interestedPartiesList){
             csIntParty.User__c =PartnerUserId;
             csIntParty.Active__c=true;
         }
         if(interestedPartiesList.size()>0)
             update interestedPartiesList;
    }
    // Updating Project owner with partner user
    public void updateProjectOwner(){
        projOwnerList =[select id, name,ownerid,Core_Status__c from Core_IPS_Project__c where ownerid=:CustUserId AND ownerid!=null];
        for(Core_IPS_Project__c projRec:projOwnerList ){
            projRec.ownerid=PartnerUserId;
        }
        if(projOwnerList.size()>0)
             update projOwnerList;
    }
    // Updating Project Member user with partner user
    public void updateProjectMember(){
        projMemList =[SELECT Core_IPS_Contact_Account__c,Core_IPS_Contact__c,Core_IPS_Project__c,Core_Status__c,Core_User__c,Id,Name FROM Core_IPS_Project_Member__c where Core_User__c =:CustUserId AND Core_User__c !=null];
        for(Core_IPS_Project_Member__c projmemRec:projMemList ){
            projmemRec.Core_User__c=PartnerUserId;
            projmemRec.Core_Status__c='Active';
        }
        if(projMemList.size()>0)
             update projMemList;
    }
    public void SendMailToAGS(){
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            // Step 1: Create a new Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //  EmailTemplate emailTemplate = [Select id,Subject, HtmlValue, Body from EmailTemplate where name =: Label.Core_IPS_SSLC_Case_Create_Template];
            // Step 2: Set list of people who should get the email
            List<String> sendTo = new List<String>();
            sendTo.add(Userinfo.getUserEmail());
            mail.setToAddresses(sendTo);
            // Step 3:Optional
            List<String> ccTo = new List<String>();
            ccTo.add(system.label.Core_IPS_EMailIdsForAGS);
            mail.setCcAddresses(ccTo);
            //mail.setTemplateId(emailTemplate.id);
            String emailSubject= 'Customer to Partner Conversion';
            String htmlBody = 'Contact id : '+contactId+' is getting migrated from customer to partner';
            // Step 4. Set email contents - you can use variables!
            mail.setSubject(emailSubject);
            mail.setHtmlBody(htmlBody );
            // Step 5. Add your email to the master list
            mails.add(mail);
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails);
    }
    @future
    public static void updateUser(Id CustUserId){
        // Getting Customer User And updating.
        User PartnerUser=null;
        List<user> usr=[select id, username, contactid,email, FederationIdentifier, FirstName,LastName, Alias, TimeZoneSidKey,userroleid, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Core_Login_Id__c, CommunityNickname, IsPortalEnabled, IsActive from user where IsPortalEnabled =true and id=:CustUserId];
        try{
            if(usr.size()>0){
               // usr[0].username='_'+usr[0].username;
                usr[0].FederationIdentifier=(!String.IsBlank(usr[0].FederationIdentifier)) ?'_'+usr[0].FederationIdentifier:null;
                usr[0].Core_Login_Id__c=(!String.IsBlank(usr[0].Core_Login_Id__c)) ?'_'+usr[0].Core_Login_Id__c:null;
                usr[0].CommunityNickname=(!String.IsBlank(usr[0].CommunityNickname)) ?'_'+usr[0].CommunityNickname:null; 
                usr[0].IsPortalEnabled=false;
                usr[0].IsActive=false;
                update usr; 
           }
        }catch(Exception ex){
                usr[0].CommunityNickname=(!String.IsBlank(usr[0].CommunityNickname)) ?'_'+usr[0].CommunityNickname:null; 
                usr[0].IsPortalEnabled=false;
                usr[0].IsActive=false;
                update usr;
        }
     }
    //Creating Partner records 
    public PageReference createPartner(){
          User PartnerUser=null;
          FetchcontactInfoSobjectRecords();
          system.debug('CustUserId:: '+CustUserId);
          List<user> usr=[select id, username, contactid,email, FederationIdentifier, FirstName,LastName, Alias, TimeZoneSidKey,userroleid, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, Core_Login_Id__c, CommunityNickname, IsPortalEnabled, IsActive from user where id=:CustUserId and IsActive =false];
          system.debug('Customer user:: '+usr);
          List<user> usr2=[select id from user where contactid=:contactId];
          system.debug('Customer user2:: '+usr2);
          if(usr.size()>0 && usr2.size()==0 ){
                PartnerUser = new User();
               // PartnerUser = usr[0];
                PartnerUser.username=(usr[0].username!=null?usr[0].username.substring(1):null);
                PartnerUser.FederationIdentifier=(usr[0].FederationIdentifier!=null?usr[0].FederationIdentifier.substring(1):null);
                PartnerUser.Core_Login_Id__c=(usr[0].Core_Login_Id__c!=null?usr[0].Core_Login_Id__c.substring(1):null);
                PartnerUser.FederationIdentifier=(usr[0].FederationIdentifier!=null?usr[0].FederationIdentifier.substring(1):null);
               // Required fields are missing: [LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey]:
                PartnerUser.firstname=usr[0].firstname;
                PartnerUser.lastname=usr[0].lastname;
                PartnerUser.Email=usr[0].Email;
                PartnerUser.Alias=usr[0].Alias;
               // PartnerUser.contactId=contactId;
                PartnerUser.TimeZoneSidKey=usr[0].TimeZoneSidKey;
                PartnerUser.LocaleSidKey=usr[0].LocaleSidKey;
                PartnerUser.EmailEncodingKey=usr[0].EmailEncodingKey;
                PartnerUser.LanguageLocaleKey=usr[0].LanguageLocaleKey;
                PartnerUser.profileid=System.Label.Core_Partner_Profile_Id;
               // PartnerUser.userroleid=usr[0].userroleid;
               // Set the DML options
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail = false;
                Database.SaveResult sr=Database.insert(PartnerUser,dlo); 
        	    system.debug('inserted user:: '+sr);
              /*  PermissionSet  pset=[select id,label from PermissionSet where Label = 'IPS Permission Set' limit 1]; //IPS Permission Set  //'DDR Permission Set'
                PermissionSetAssignment permisionSetRec=new PermissionSetAssignment();
                permisionSetRec.AssigneeId = PartnerUser.id;
                permisionSetRec.PermissionSetId = pset.id;
                insert permisionSetRec; */
         }
         return new Pagereference('/'+contactId);
     }  
  
}