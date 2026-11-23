/**************************************************************************************************
Apex Class Name:  Core_IPS_Interested_Party_Int_Cont_Test
Version     : 1.0
Created Date: 11 05 2015
Function    : Test Class for Core_IPS_Interested_Party_Int_Controller class. This class defines all test methods
              which provides test coverage for Searching, Adding, Removing Internal Interested Parties to the Case.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Manoj Kumar                         04/18/2017              getRecords(),callControllerForA_PositiveTest(),callControllerForNull_PositiveTest method updated
                                                              for test coverage of US61151.
* Ashutosh 			       04/27/2018             Coverage for US103988
*****************************************************************************************************/


@isTest
public class Core_IPS_Interested_Party_Int_Cont_Test{
    
    //Instance variables that are commonly used in multiple test methods
    static List<User> ListOfUser = new List<User> ();
    static Account acct;
    
    // Variables used in VF page Testing
    public static Case CaseRecord;
    
    /***************************************************************************************************
    Method Name:  getRecords
    Method Type: Test Method
    Version     : 1.0 
    Modified Date: 18 April 2017
    Description:  This method will creates all required records which are needed for Adding Internal Interested Party
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
      Manoj Kumar               04/18/2017                Modified
    ****************************************************************************************************/
    
    static void getRecords(){
    
    // Query Profiles
    Map<String,ID> profiles = new Map<String,ID>();
    List<String> SalesRepProfIds = new List<String>();
    List<String> IPAgentProfileIds = new List<String>();
    List<AccountTeamMember> atmList = new List<AccountTeamMember>();
    List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
    
    IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
    SalesRepProfIds.addall(label.Core_IPS_Sales_Rep_ProfileIds.split(','));
    
    List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator' limit 1];
    
    //Creating Custom Settings for search criteria of Accountteammembers
    List<Core_IPS_Labels__c> IpsLabels = new List<Core_IPS_Labels__c>();
        
    Core_IPS_Labels__c ipsLabelTeam = new Core_IPS_Labels__c(Name='RowCause_Team',Value__c='Team');
    Core_IPS_Labels__c ipsLabelOwner = new Core_IPS_Labels__c(Name='Rowcause_Owner',Value__c='Owner');
    Core_IPS_Labels__c ipsLabelRead = new Core_IPS_Labels__c(Name='AccessLevel_Read',Value__c='Read');
    Core_IPS_Labels__c ipsLabelEdit = new Core_IPS_Labels__c(Name='AccessLevel_Edit',Value__c='Edit');
    Core_IPS_Labels__c ipsLabelNAC_Case_RT = new Core_IPS_Labels__c(Name='Case_RT_Name_IPS_NoAssignedContact',Value__c='IPS No Assigned Contact Case');    
        
    IpsLabels.add(ipsLabelTeam);
    IpsLabels.add(ipsLabelOwner);
    IpsLabels.add(ipsLabelRead);
    IpsLabels.add(ipsLabelEdit);
    IpsLabels.add(ipsLabelNAC_Case_RT);
    Insert IpsLabels;
    
    acct = new Account();
    acct = TestUtilities.getAccountRecord();
    
    //Creating cases
    List<Case> ListOfCases = TestUtilities.getListOfCases(2);
    
    // Create Users
    ListOfUser = TestUtilities.getListOfUser(6);
    
    ListOfUser.get(0).FirstName= 'Admin Test';
    ListOfUser.get(0).LastName= 'Admin Sys Admin';
    ListOfUser.get(0).ProfileID =  ProfileList.get(0).Id;
    
    ListOfUser.get(1).FirstName= 'Agent Test';
    ListOfUser.get(1).LastName= 'Agent IPS Agent';
    ListOfUser.get(1).ProfileID =  IPAgentProfileIds.get(0);
    
    ListOfUser.get(2).FirstName= 'Sales Test';
    ListOfUser.get(2).LastName= 'Sales Rep';
    ListOfUser.get(2).ProfileID =  SalesRepProfIds.get(0);
    
    ListOfUser.get(3).FirstName= 'Rep Test';
    ListOfUser.get(3).LastName= 'Rep Sales Rep';
    ListOfUser.get(3).ProfileID =  SalesRepProfIds.get(0);
    
    ListOfUser.get(4).FirstName= 'Sales Test 2';
    ListOfUser.get(4).LastName= 'Sales Sales Rep 2';
    ListOfUser.get(4).ProfileID =  SalesRepProfIds.get(0);
    
    ListOfUser.get(5).FirstName= 'Sales Test 3';
    ListOfUser.get(5).LastName= 'Sales Sales Rep 3';
    ListOfUser.get(5).ProfileID =  SalesRepProfIds.get(0);
    
    insert ListOfUser;
    System.debug('----------------ListOfUser::'+ListOfUser);
    
    System.RunAs(ListOfUser[0]){
        insert acct;
        
        //Adding Sales Rep to AccountTeamMember
        AccountTeamMember atm = new AccountTeamMember(UserId=ListOfUser.get(2).Id,AccountId=acct.Id,TeamMemberRole ='Team Member (100%)');
        
        atmList.add(atm);
        
        insert atmList;
        
        List<AccountShare> affectedAcctShare = [select Id,CaseAccessLevel,rowcause from AccountShare where AccountId=:atm.AccountId and UserOrGroupId =:atm.UserId limit 1];
        
        //Providing Read-Only to Case for Sales Rep
        for(AccountShare actshare: affectedAcctShare){
            actshare.CaseAccessLevel = 'Read';
        }
        
        update affectedAcctShare;
        ListOfCases.get(0).OwnerId=ListOfUser.get(1).Id;
        ListOfCases.get(0).AccountId = acct.Id;
        insert ListOfCases;
    
    }
    
    System.assertEquals(ListOfUser.get(0).profileid, ProfileList.get(0).Id);
    
    System.assert(ListOfCases[0].Id != null, 'Record not created');
    
    System.runAs(ListOfUser.get(0)){
    
        CaseRecord = ListOfCases.get(0);    
        /*Ashutosh - US103988 - adding one more IP to have both internal and external party*/
        List<Core_IPS_Case_Interested_Party__c> ListOfIP = TestUtilities.getInternalInterestedParties(3);            
        
        ListOfIP[0].Case__c = CaseRecord.Id;
        ListOfIP[0].User__c = ListOfUser.get(0).Id;
        ListOfIP[0].Type__c = 'Internal';//ashutosh - US103988 - Now the records for only internal party will be displayed
        
        ListOfIP[1].Case__c = ListOfCases.get(1).Id;
        ListOfIP[1].User__c = ListOfUser.get(1).Id;
        ListOfIP[1].Type__c = 'Internal';//ashutosh - US103988 - Now the records for only internal party will be displayed
        
        /*Ashutosh - US103988 - Added another interested party*/
        ListOfIP[2].Case__c = CaseRecord.Id;
        ListOfIP[2].User__c = ListOfUser.get(2).Id;
        ListOfIP[2].Type__c = 'Internal';//ashutosh - US103988 - Now the records for only internal party will be displayed
        
        insert ListOfIP; 
    }
}        
    
     static testMethod void callControllerForNull_PositiveTest(){   
        getRecords();
        // VF Page Testing
        Test.startTest();
        System.runas(ListOfUser.get(1)){
            
            PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',acct.Id);
            Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();
            CoreIPSIPController.searchText = '';
            PageReference pageRef1 = CoreIPSIPController.doSearch();
            System.assertEquals(null,pageRef1);
            
            if(CoreIPSIPController.IPRecordSet !=null && CoreIPSIPController.IPRecordSet.size() > 0)
            {
                 CoreIPSIPController.IPRecordSet[0].isSelected = True;
                 PageReference pageRef2 = CoreIPSIPController.AddSelectedContacts();
                 System.assertEquals(null,pageRef2);
            }
        }        
        Test.stopTest();
    }  
    
    
    /***************************************************************************************************
    Method Name:  callControllerForA_PositiveTest
    Method Type: Test Method
    Version     : 1.0 
    Modified Date: 18 April 2017
    Description:  This method will search for SalesRep and add them to Intermal Interested party
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
      Manoj Kumar               04/18/2017                Modified
    ****************************************************************************************************/
    
    static testMethod void callControllerForA_PositiveTest(){  
    
        getRecords();
        Test.startTest();
        System.runas(ListOfUser.get(1)){
            PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',CaseRecord.Id);
            
            //Search SalesRep who is part of Case Account's AccountTeam
            Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();        
            CoreIPSIPController.searchText = 'Rep';
            
            System.runAs(ListOfUser.get(2)){
                PageReference pageRef1 = CoreIPSIPController.doSearch();
                System.assertEquals(null,pageRef1);
                
                PageReference pageRef2 = CoreIPSIPController.simpleSort();
                System.assertEquals(null,pageRef1);
                
                if(CoreIPSIPController.IPRecordSet !=null && CoreIPSIPController.IPRecordSet.size() > 0)
                {
                     CoreIPSIPController.IPRecordSet[0].isSelected = True;
                     
                     //Adding SalesRep to Internal Interested Party
                     PageReference pageRef3 = CoreIPSIPController.AddSelectedContacts();
                     System.assertEquals(null,pageRef2);
                }
                
                //Search for Admin who is part of Case Account's AccountTeam
                CoreIPSIPController.searchText = 'Admin';
                PageReference pageRef4 = CoreIPSIPController.doSearch();
                
                CoreIPSIPController.searchText = '';
                PageReference pageRef5 = CoreIPSIPController.doSearch();
            }
        }
        Test.stopTest();
    }
    
    
    static testMethod void callControllerForSales_PositiveTest(){   
        getRecords();
        // VF Page Testing
        Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',CaseRecord.Id);
        
        Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();
        CoreIPSIPController.sortHeader = new Core_SortedGrid_ColumnHeader('LastName');
        CoreIPSIPController.searchText = 'Sales';
        PageReference pageRef1 = CoreIPSIPController.doSearch();
        System.assertEquals(null,pageRef1);
        
        System.runAs(ListOfUser.get(0)){
            if(CoreIPSIPController.IPRecordSet !=null && CoreIPSIPController.IPRecordSet.size() > 0)
            {
                CoreIPSIPController.IPRecordSet[0].isSelected = True;
                PageReference pageRef2 = CoreIPSIPController.AddSelectedContacts();
                System.assertEquals(null,pageRef2);
                PageReference pageRef3 =CoreIPSIPController.Finished();
                System.assertEquals('/'+CaseRecord.Id,pageRef3.getUrl());
            }
        }
        Test.stopTest();
    }

    static testMethod void callControllerForNullCaseId_PositiveTest(){   
        getRecords();
        Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',Null);
        Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller(); 
        
        Test.stopTest();
    }  

    /***************************************************************************************************
    Method Name:  DeleteExtIPbyInternalUsr_CaseWithIpsProj
    Method Type: Test Method
    Version     : 1.0 
    Created Date: 02 Feb 2016
    Description:  Deleting Case External IP by Internal User with IPS Project
    Scenario Type:  Positive
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Ekbote       03/02/2016                 Created
    ****************************************************************************************************/
    static testMethod void removeSelectedIntrestedParty(){   
        getRecords();
        // VF Page Testing
        Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',CaseRecord.Id);
        
        Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();        
        CoreIPSIPController.searchText = '1';

        PageReference pageRef1 = CoreIPSIPController.doSearch();
        System.assertEquals(null,pageRef1);
        
        if(CoreIPSIPController.IPRecordSet !=null && CoreIPSIPController.IPRecordSet.size() > 0)
        {
             CoreIPSIPController.IPRecordSet[0].isSelected = True;
             PageReference pageRef2 = CoreIPSIPController.AddSelectedContacts();
             System.assertEquals(null,pageRef2);
             //CoreIPSIPController.LinkedInternalParties.get(0).Active__c = false; Ashutosh - US103988 - commented because now we have wrapper list in place of sobjectList
             CoreIPSIPController.linkedPartiesList.get(0).isSelected = false;//Ashutosh - US103988 - Added the line
            System.runAs(ListOfUser.get(2)){
                 PageReference pageRef3 = CoreIPSIPController.removeSelectedContacts();
                 System.assertEquals(null,pageRef3);
             }
             //CoreIPSIPController.LinkedInternalParties.get(1).Active__c = false;Ashutosh - US103988 - commented because now we have wrapper list in place of sobjectList
            CoreIPSIPController.linkedPartiesList.get(1).isSelected = false; //Ashutosh - US103988 - Added the line
            PageReference pageRef4 = CoreIPSIPController.removeSelectedContacts();
             System.assertEquals(null,pageRef4);             
        }        
        Test.stopTest();
    } 

    static testMethod void removeInterestedParties(){   
        System.debug('----Inside removeInterestedParties---');
        getRecords();
        // VF Page Testing
        Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',CaseRecord.Id);
        
        Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();
        CoreIPSIPController.sortHeader = new Core_SortedGrid_ColumnHeader('LastName');
        CoreIPSIPController.searchText = 'Sales';
        PageReference pageRef1 = CoreIPSIPController.doSearch();
        
        System.debug('-----CoreIPSIPController.IPRecordSet ::'+CoreIPSIPController.IPRecordSet);
        System.runAs(ListOfUser.get(0)){
            if(CoreIPSIPController.IPRecordSet !=null && CoreIPSIPController.IPRecordSet.size() > 0)
            {
                CoreIPSIPController.IPRecordSet[0].isSelected = True;
                //Ashutosh-US103988 -CoreIPSIPController.IPRecordSet[1].isSelected = True;
                PageReference pageRef2 = CoreIPSIPController.AddSelectedContacts();
                System.assertEquals(null,pageRef2);
                PageReference pageRef3 =CoreIPSIPController.Finished();
                System.assertEquals('/'+CaseRecord.Id,pageRef3.getUrl());
                
                //CoreIPSIPController.LinkedInternalParties.get(0).Active__c = false;Ashutosh - US103988 - commented because now we have wrapper list in place of sobjectList
                CoreIPSIPController.linkedPartiesList.get(0).isSelected = false;//Ashutosh - US103988 - Added the line
                PageReference pageRef4 = CoreIPSIPController.removeSelectedContacts();
                
                /*Ashutosh - US103988 - To cover save and redirect method*/
                /*Core_IPS_Interested_Party_Int_Controller CoreIPSIPController1 = new Core_IPS_Interested_Party_Int_Controller();
                CoreIPSIPController1.IPRecordSet[1].isSelected = True;*/
                PageReference pageRef5 = CoreIPSIPController.saveAndRedirect();
                System.assertEquals('/'+CaseRecord.Id,pageRef5.getUrl());
                /*Ashutosh - US103988 - Covering catch statements*/
                 CoreIPSIPController.linkedPartiesList = null;
                 PageReference pageRef6 = CoreIPSIPController.AddSelectedContacts();
                 System.assertEquals(null,pageRef6); 
                /*****End**************/ 
            }
        }
        Test.stopTest();
    } 
    
    static testMethod void testCaseRecordtypeIDByName(){   
    	
        Id NAC_RecTypeId = Core_IPS_Interested_Party_Int_Controller.getCaseRecordtypeIDByName('IPS No Assigned Contact Case');
    
    }
    
   static testMethod void InterestedPartiesforPRivateProj(){  
    getRecords();
    List<Core_Ips_Project__c>  ListOfIpsProjects_Test = TestUtilities.getListOfIpsProjects(1);
       ListOfIpsProjects_Test[0].core_ips_private__c=true;
       insert ListOfIpsProjects_Test;
       Core_IPS_Intel_Support_Team__c ist=new Core_IPS_Intel_Support_Team__c();
       ist.Core_IPS_Project__c=ListOfIpsProjects_Test[0].Id;
       ist.Core_IPS_User__c=ListOfUser.get(3).Id;
       ist.Status__c='Active';
       insert ist;
       CaseRecord.core_ips_project_case__C = ListOfIpsProjects_Test[0].Id;
       CaseRecord.Core_IPS_Private_Project__c=true;
       update CaseRecord;
       Test.startTest();
        
        PageReference pageRef = Page.Core_IPS_Interested_Party_Internal;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',CaseRecord.Id);
        
        Core_IPS_Interested_Party_Int_Controller CoreIPSIPController = new Core_IPS_Interested_Party_Int_Controller();
        CoreIPSIPController.sortHeader = new Core_SortedGrid_ColumnHeader('LastName');
        CoreIPSIPController.searchText = 'Rep';
        PageReference pageRef1 = CoreIPSIPController.doSearch();
        PageReference pageRef2 = CoreIPSIPController.simpleSort();
        System.assertEquals(null,pageRef1);
       
       Test.stopTest();
   }
    
}