/**************************************************************************************************
Apex Class Name: Core_IPS_Add_IntelSupportTeam_Test 
Version     : 1.0
Created Date: 19 04 2018
Function    : Test Class and code coverage for Core_IPS_Add_IntelSupportTeam_Controller
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi Singhal                        20/04/2018            Created for US102838
*****************************************************************************************************/
@isTest
public class Core_IPS_Add_IntelSupportTeam_Test {
    
    static List<User> ListOfUser = new List<User> ();
    static Account acct;
    static List<Core_IPS_Project__c> ListOfIpsProjects_Test;
    static Core_IPS_Intel_Support_Team__c ist;
    /***************************************************************************************************
Method Name:  getRecords
Method Type: Test Method
Version     : 1.0 
Description:  This method will creates records which are needed for Adding Intel Support Team
Scenario Type:  Positive
Modification Log :
*Developer                   Date                   Description
*----------------------------------------------------------------------------                 
Aayushi               23/04/2018                Created
****************************************************************************************************/
    static void getRecords(){
        
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> SalesRepProfIds = new List<String>();
        List<String> IPAgentProfileIds = new List<String>();
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        
        IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
        SalesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator' limit 1];
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(5);
        
        ListOfUser.get(0).FirstName= 'Admin Test';
        ListOfUser.get(0).LastName= 'Admin Sys Admin';
        ListOfUser.get(0).ProfileID =  ProfileList.get(0).Id;
        ListOfUser.get(1).FirstName= 'Sales Test';
        ListOfUser.get(1).LastName= 'Sales Rep';
        ListOfUser.get(1).ProfileID =  SalesRepProfIds.get(0);
        ListOfUser.get(2).FirstName= 'Agent Test1';
        ListOfUser.get(2).LastName= 'Agent IPS Agent1';
        ListOfUser.get(2).ProfileID =  IPAgentProfileIds.get(0);
        ListOfUser.get(3).FirstName= 'Agent Test2';
        ListOfUser.get(3).LastName= 'Agent IPS Agent2';
        ListOfUser.get(3).ProfileID =  IPAgentProfileIds.get(0);
        ListOfUser.get(4).FirstName= 'Sales Test1';
        ListOfUser.get(4).LastName= 'Sales Rep1';
        ListOfUser.get(4).ProfileID =  SalesRepProfIds.get(0);
        insert ListOfUser;
        
        System.assert(ListOfUser[0].Id!=null,'Record Not Created');
        System.assert(ListOfUser[1].Id!=null,'Record Not Created');
        Core_IPS_Labels__c ipsLabelTeam = new Core_IPS_Labels__c(Name='RowCause_Team',Value__c='Team');
        Core_IPS_Labels__c ipsLabelOwner = new Core_IPS_Labels__c(Name='Rowcause_Owner',Value__c='Owner');
        Core_IPS_Labels__c ipsLabelRead = new Core_IPS_Labels__c(Name='AccessLevel_Read',Value__c='Read');
        Core_IPS_Labels__c ipsLabelEdit = new Core_IPS_Labels__c(Name='AccessLevel_Edit',Value__c='Edit');
        Core_IPS_Labels__c ipsLabelActive= new Core_IPS_Labels__c(Name='CoreStatus_Active',Value__c='Active');
        //Creating Custom Settings for search criteria of Accountteammembers
        List<Core_IPS_Labels__c> IpsLabels = new List<Core_IPS_Labels__c>();
        IpsLabels.add(ipsLabelTeam);
        IpsLabels.add(ipsLabelOwner);
        IpsLabels.add(ipsLabelRead);
        IpsLabels.add(ipsLabelEdit);
        IpsLabels.add(ipsLabelActive);
         //Create Custom Setting - Trigger Executions
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = 'internalProjectGroup';
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='Core_IPS_Core_Question_Handler';
            TriggerExecution.Core_Description__c = 'This method takes a list of Core_IPS_Question__c records whose status field is changed and then update the child object Core_Assigned_Environment_Variables__c record status field value accordingly as per parent object status value.';
            TriggerExecution.Core_Object__c = 'Core_IPS_Question__c';
            TriggerExecution.Core_Trigger_Events__c = 'After Update';
            
        ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
        acct = new Account();
        acct = TestUtilities.getAccountRecord();
        System.runAs(ListOfUser.get(0)){
            insert ListOfIpsProjects_Test;
            insert acct;
            insert IpsLabels;
            insert TriggerExecution; 
            System.assert(TriggerExecution.id != null);
            //Adding Sales Rep to AccountTeamMember
            AccountTeamMember atm = new AccountTeamMember(UserId=ListOfUser.get(1).Id,AccountId=acct.Id,TeamMemberRole ='Team Member (100%)');
            
            atmList.add(atm);
            
            insert atmList;
            
            List<AccountShare> affectedAcctShare = [select Id,CaseAccessLevel,rowcause,AccountId from AccountShare where AccountId=:atm.AccountId and UserOrGroupId =:atm.UserId limit 1];
            
            //Providing Read-Only to Case for Sales Rep
            for(AccountShare actshare: affectedAcctShare){
                actshare.CaseAccessLevel = 'Edit';
            }
            
            update affectedAcctShare;
            System.debug('affectedAcctShare-->'+affectedAcctShare);
            System.assert(acct.Id!=null,'Record Not Created');
            System.assert(ListOfIpsProjects_Test[0].Id!=null,'Record Not Created');
        }
        
        Core_IPS_Account__c projAcc = new Core_IPS_Account__c();
        projAcc.Core_Account__c = acct.Id;
        projAcc.Core_IPS_Project__c = ListOfIpsProjects_Test[0].Id;
        projAcc.Core_Status__c='Active';
        ist=new Core_IPS_Intel_Support_Team__c();
        ist.Core_IPS_Project__c=ListOfIpsProjects_Test[0].Id;
        ist.Core_IPS_User__c=ListOfUser.get(2).Id;
        ist.Status__c='Active';
        System.runAs(ListOfUser.get(0)){
            insert projAcc;
        }
        System.assert(projAcc.Id!=null,'Record Not Created');
        
    }
    
    /***************************************************************************************************
Method Name:  testMethod_positive
Method Type: Test Method
Version     : 1.0 
Created Date: 23 April 2018
Description:  Testing with search Intel Support Team Members and adding them to Project
Scenario Type:  Positive
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Aayushi              23/04/2018                Created
****************************************************************************************************/ 
    static testmethod void testMethodController(){
        getRecords();
         System.runAs(ListOfUser.get(0)){
            insert ist;
        }
        PageReference pageRef = Page.Core_IPS_Add_IntelSupportTeam;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('projectId', ListOfIpsProjects_Test[0].id);
        Core_IPS_Add_IntelSupportTeam_Controller istController=new Core_IPS_Add_IntelSupportTeam_Controller();
        istController.doSearch();			//when there is empty searchText
        istcontroller.searchText='testing';		//no user record
        istController.doSearch();
        istcontroller.searchText='s';
        istController.doSearch();			//on providing some searchText value
        if(istController.ISTRecordSet !=null && istController.ISTRecordSet.size() > 0){
            istController.ISTRecordSet[0].isSelected = True;  
            istController.AddSelectedContacts();
        }
        System.runAs(ListOfUser.get(1)){
         if(istController.ISTRecordSet !=null && istController.ISTRecordSet.size() > 0){
            istController.ISTRecordSet[0].isSelected = True;  
            istController.AddSelectedContacts();
        }   
        }
       
        PageReference pageRef1 = istController.Finished();
    }
    
    static testmethod void testMethod1(){
     getRecords();
      System.runAs(ListOfUser.get(0)){
            insert ist;
        }   
	 ist.Status__c='Inactive';
     update ist;
     ist.Status__c='Active';
     update ist;
     delete ist;
    }
    
    static testmethod void testMethod2(){
     getRecords();
      String listGroupMemberStr;
     System.runAs(ListOfUser.get(0)){
     // Insert group
        Group grp = new Group();
        grp.Name = 'Test group';
        insert grp;
        List<GroupMember> grpMemList=new List<GroupMember>();
        GroupMember grpMem= new GroupMember();
        grpMem.GroupId = grp.Id;
        grpMem.UserorGroupId = ListOfUser.get(1).Id;
        grpMemList.add(grpMem);
        insert grpMemList;
        listGroupMemberStr = JSON.serialize(grpMemList);
        Core_IPS_IntelSupportTeam_Handler.delGroupMember(listGroupMemberStr);
     }
    }
    
}