/**********************************
Class Name  : Core_PartnerLeads_Count_Batch_Test
Description : Test class for Core_PartnerLeads_Count_Batch AND Core_PartnerLeads_Count_Batch_Schedule
Method : CorePartnerLeadsCountTestMethod
*******/
@isTest
public class Core_PartnerLeads_Count_Batch_Test {
    static testmethod void CorePartnerLeadsCountTestMethod(){
        
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
        
        
        Integer i=0,n=0;
        List<Account> acctList=new List<Account>();
        List<Account> acctList1=new List<Account>();
        List<Group> groupList=new List<Group>();
        List<GroupMember> groupMemberList=new List<GroupMember>();
        List<LeadShare> leadShareList=new List<LeadShare>();
        List<Lead> leadList=new List<Lead>();
        List<Lead> leadList1=new List<Lead>();
        acctList=Core_Test_Utility.createAccount(10);
        leadList=Core_Test_Utility.createLead(10);
        for(Account acc:acctList){
            acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            acc.Core_Sales_Groups__c='PRC Sales Group';
            acctList1.add(acc);
        }
        insert acctList1;
        
        PMP_Company__c pmpObj1 = new PMP_Company__c();
        pmpObj1.PMP_Account_Id__c = acctList1[1].id;
        pmpObj1.Name = 'test';
        pmpObj1.PMP_Is_Published_Ind__c = true;
        pmpObj1.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
        insert pmpObj1;
        
        PMP_Company__c pmpObj = new PMP_Company__c();
        pmpObj.PMP_Account_Id__c = acctList1[0].id;
        pmpObj.Name = 'test';
        pmpObj.PMP_Is_Published_Ind__c = true;
        pmpObj.PMP_Published_Copy_Id__c=pmpObj1.Id;
        pmpObj.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
        insert pmpObj;
        
        
        PMP_OPID_MPI_Rel__c opidmpi = new PMP_OPID_MPI_Rel__c();
        opidmpi.PMP_One_Partner_ID__c = acctList1[0].id;
        opidmpi.PMP_Marketing_Profile_Id__c = pmpObj.id;
        
        insert opidmpi;
        
        for(Account acct:acctList1){
            Group gr=new Group(Name='PMP'+'_'+acct.Id+'_'+'Client_Computing',DeveloperName='PMP'+'_'+acct.Id+'_'+'Client_Computing');
            groupList.add(gr);
            i++;
        }
        insert groupList;
       
        for(Group grp:groupList){
            GroupMember grpMember=new GroupMember(UserOrGroupId=UserInfo.getUserId(),GroupId=grp.Id);
            groupMemberList.add(grpMember);
        }
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert groupMemberList;
        }
        
        for(Lead ld:leadList){
            ld.Status='Tele Accepted Lead';
            ld.Core_Lead_Status__c='Accepted';
            ld.Core_Partner_Lead_Owner__c=UserInfo.getUserId();
            ld.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
            ld.Core_Lead_State__c='In Pursuit';
            ld.Core_MPI_Id__c = pmpObj.id;
            leadList1.add(ld);
        }
        insert leadList1;
 
        leadList1.get(1).Core_Lead_Status__c='Contacted';
        leadList1.get(1).status='PAL';
        leadList1.get(1).Core_Lead_Contact_Estb_Dt__c = true;
        update leadList1.get(1);
        leadList1.get(1).Core_Lead_Status__c='Qualified';
        leadList1.get(1).status='PQL';
        update leadList1.get(1);
        leadList1.get(2).Core_Lead_Status__c='Contacted';
        leadList1.get(2).status='PAL';
        update leadList1.get(2);
        leadList1.get(3).Core_Lead_Status__c='Rejected';
        leadList1.get(3).status='Terminated';
        leadList1.get(3).Core_Lead_Sub_Status__c='Bad Data';
        update leadList1.get(3);
        for(Group grp:groupList){
            LeadShare leadShares=new Leadshare(LeadId=leadList1.get(n).Id,UserOrGroupId=grp.Id,LeadAccessLevel='Edit');
            leadShareList.add(leadShares);
            if(n>groupList.size()){
                break;
            }
            else{
                n++;
            }
        }
        insert leadShareList;
       
        
        Test.startTest();
        Core_PartnerLeads_Count_Batch_Schedule partnerschedule=new Core_PartnerLeads_Count_Batch_Schedule();
        String sch = '0 5 * * * ?';
        system.schedule('Test status Check', sch, partnerschedule);
        database.executebatch(new Core_PartnerLeads_Count_Batch(),10);
        List<AsyncApexJob> job = [SELECT id FROM AsyncApexJob WHERE ApexClass.Name='Core_PartnerLeads_Count_Batch'];
        System.assertEquals(job.isEmpty(),false,'Job Executed'); 
        
        Test.stopTest();      
    }
}