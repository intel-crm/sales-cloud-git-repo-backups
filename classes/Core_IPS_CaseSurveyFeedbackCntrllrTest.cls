@isTest
public class Core_IPS_CaseSurveyFeedbackCntrllrTest{
 
    public static Account acct;
    public static List<User> ListOfUser = new List<User> ();
    public static Case CaseRecord;
    
    static void getRecords(){       
        // Query Profiles
        Map<String,ID> profiles = new Map<String,ID>();
        List<String> SalesRepProfIds = new List<String>();
        List<String> IPAgentProfileIds = new List<String>();
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = TestUtilities.getListOfIpsErrorCodes();
        
        IPAgentProfileIds.addall(Label.Interested_Parties_Internal_Agent_ProfileIds.split(','));
        
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
    System.AssertEquals(IpsLabels.size()>0, true);
        acct = new Account();
        acct = TestUtilities.getAccountRecord();
        
        //Creating cases
        List<Case> ListOfCases = TestUtilities.getListOfCases(1);
        
        // Create Users
        ListOfUser = TestUtilities.getListOfUser(2);
        
        ListOfUser.get(0).FirstName= 'Admin Test';
        ListOfUser.get(0).LastName= 'Admin Sys Admin';
        ListOfUser.get(0).ProfileID =  ProfileList.get(0).Id;
        
        ListOfUser.get(1).FirstName= 'Agent Test';
        ListOfUser.get(1).LastName= 'Agent IPS Agent';
        ListOfUser.get(1).ProfileID =  IPAgentProfileIds.get(0);    
        
        insert ListOfUser;
        
        System.RunAs(ListOfUser[0]){
            insert acct;        
            ListOfCases.get(0).OwnerId=ListOfUser.get(1).Id;
            ListOfCases.get(0).AccountId = acct.Id;
            insert ListOfCases;    
        }
        System.assert(ListOfCases[0].Id != null, 'Record not created');
        
        System.runAs(ListOfUser.get(0)){    
            CaseRecord = ListOfCases.get(0);     
        }
    }
    static testMethod void callControllerForSales_PositiveTest(){   
        getRecords();
        Test.startTest();
        System.runAs(ListOfUser.get(0)){
            List<Core_IPS_Response__c> surveyFeedbackList = Core_IPS_CaseSurveyFeedbackController.getSurveyFeedbackList(CaseRecord.Id);   
            System.AssertEquals(surveyFeedbackList != null ,true); 
        }
        Test.stopTest();
        
    }
        
}