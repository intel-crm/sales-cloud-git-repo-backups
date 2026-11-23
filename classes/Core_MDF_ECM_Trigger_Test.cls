/****************************************************************************************************************************************
* Class Name        : Core_MDF_ECM_Trigger_Test
* Created Date      : 25-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Shiva       25/06/2019         Test class for Core_MDF_Exception_Case_Mapping Trigger
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_ECM_Trigger_Test {
    
    @TestSetUp
    static void createECMRecord(){
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(true);
        List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Core_MDF_Bypass_PFC_Trigger');
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        System.runAs(usr){
            
            
        	
            
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            //Create DCF Channel Program
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
            
            //Create Intel Account
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account accCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test CCF Account', ccfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account accDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test DCF Account', dcfCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
            //Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
            PermissionSet submitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            User exptSubmitter = Core_MDF_CCP_TestDataUtility.createUser(false);
            //exptSubmitter.profileId = ccpCoreAccessProfile.Id;
            exptSubmitter.LastName = 'Exception Submitter';
            insert exptSubmitter;
            
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = submitterPS.Id, AssigneeId = exptSubmitter.Id);
            Database.insert(psa);
            
            //Create CCF Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            Database.insert(ccfgrp);
            
            //Create DCF Group
            Group dcfgrp = new Group();
            dcfgrp.Name = 'Core CCP DCF Internal';
            dcfgrp.DeveloperName = 'Core_CCP_DCF_Internal';
            Database.insert(dcfgrp);
            
            //Put User in the group
            GroupMember grpMemdcf = new GroupMember();
            grpMemdcf .UserOrGroupId = exptSubmitter.Id;
            grpMemdcf.GroupId = dcfgrp.Id;
            Insert grpMemdcf ;
            
            //Put User in the group
            GroupMember grpMemccf = new GroupMember();
            grpMemccf .UserOrGroupId = exptSubmitter.Id;
            grpMemccf.GroupId = ccfgrp.Id;
            Insert grpMemccf ;
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = acc1.Id;
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_Region_cd__c = 'APJ';
            iupgm.Core_MDF_User_id__c = exptSubmitter.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            insert iupgm;
            
            //Create PGM
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = acc1.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_Internal';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c dcfPgm = new Core_MDF_Partner_Group_Mapping__c();
            dcfPgm.Core_MDF_Account__c = acc2.Id;
            dcfPgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_Internal';
            dcfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            dcfPgm.Core_MDF_Group_Id__c = dcfgrp.Id;
            dcfPgm.Core_MDF_Channel_Program__c = dcfCp.Id;
            dcfPgm.Core_MDF_Source_Txt__c = 'Test';
            Database.insert(dcfPgm);
            
            AccountShare accshare = new AccountShare();
            accshare.AccountId = acc1.Id;
            accshare.UserOrGroupId = exptSubmitter.Id;
            accshare.RowCause = 'Manual';
            accshare.AccountAccessLevel = 'Read';
            accshare.OpportunityAccessLevel = 'None';
            accshare.CaseAccessLevel = 'None';
            Database.insert(accshare);
            //Create Exception
            Core_MDF_Exception__c expt = new Core_MDF_Exception__c();
            System.runAs(exptSubmitter){
                expt.Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account';
                expt.Core_MDF_Issue_Description_dsc__c = 'Test Description';
                expt.Core_MDF_Comments_txt__c = 'Test Comments';
                expt.Core_MDF_Exception_Start_Date_dt__c = System.today();
                expt.Core_MDF_Exception_End_Date_dt__c = System.today() + 5;
                expt.Core_MDF_Exception_Reason_nm__c = 'Branding Exception from Activity Catalog';
                expt.Core_MDF_Program_nm__c = 'Core_MDF_Client_CoMarketing_Fund';
                expt.Core_MDF_Activity_Cate_and_Type_nm__c = 'Broadcast->Podcast';
                expt.Core_MDF_Total_Dollar_Impact_amt__c = 100;
                expt.Core_MDF_Country_Region_nm__c = 'India';
                expt.Core_MDF_Account_id__c = acc1.Id;
                expt.Core_MDF_Select_All_Accounts_ind__c = false;
                //expt.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
                insert expt;
            }
            //adding bypass feature to bypass access validation
			
            //Create Bank
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            //Create Budget
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',
                                                                                      Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      accCCF.Id,ccfCp.Id,10000,
                                                                                      System.today() -20,System.today().addDays(40), 
                                                                                      false);
            budget.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert budget;
            
            //Create Allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,accCCF,10000,true);
            
            //Create Campaign
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today(), System.today().addDays(15), 
                                                                        10000, 'Always Connected PC', accCCF.Id,'Desktop', true); 
            //camp.Core_MDF_Reimbursement_Rate__c = '25%';
            update camp;
            
            Test.startTest();
            //Create Activity
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(accCCF.id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i5 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today();
            pfr.Core_MDF_End_Date__c  = system.today() + 5;
            pfr.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            
            insert pfr;
            
            
            
            //Create Claim
            PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                                 Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                                 System.today(), System.today(), 122, 
                                                                                 System.today(), bank.Id, false);
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Type_Txt__c = 'Claim';
            newClaim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 10;
            newClaim.Core_MDF_Requested_Reimbursement_Amt__c = 15;
            //newClaim.Core_MDF_Reimbursement_Percent__c = '50%';
            newClaim.Core_MDF_Taxes_Local__c = 12;
            newClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
            insert newClaim;
            
            //Create case of Audit record type
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            cs.Status = 'New';
            cs.recordTypeId = caseAuditRecType;
            cs.Core_MDF_Activity_Category__c = 'Broadcast';
            cs.Core_MDF_Activity_Start_Date__c = System.today();
            cs.Core_MDF_Activity_End_Date__c = System.today() + 5;
            cs.Core_MDF_Claim_ID__c = newClaim.Id;
            cs.Core_MDF_Activity_Type__c = 'Podcast';
            cs.AccountId  = accCCF.Id;
            insert cs;
            Test.stopTest();
            
            //Create ECM
            Core_MDF_Exception_Case_Mapping__c ecm = new Core_MDF_Exception_Case_Mapping__c();
            ecm.Core_MDF_Case_id__c = cs.Id;
            ecm.Core_MDF_Exception_id__c = expt.Id;
            ecm.Core_MDF_Claim_id__c = newClaim.Id;
            ecm.Core_MDF_Program_txt__c = expt.Core_MDF_Program_nm__c;
            insert ecm;
            
            
        }
    }
    
    @isTest
    static void ecmDelete(){
        test.startTest();
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                      Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                      Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account' LIMIT 1];
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Broadcast' LIMIT 1];
        cs.status = 'Closed';
        update cs;
        
        
        
        Core_MDF_Exception_Case_Mapping__c ecm = [SELECT Id 
                                                  FROM Core_MDF_Exception_Case_Mapping__c 
                                                  WHERE Core_MDF_Case_id__c =:cs.Id  
                                                  AND Core_MDF_Exception_id__c=:expt.Id];
        
        
        try{
            Database.delete(ecm.id);
        }
        catch(Exception e){
            System.assert(e != null);
        }
        test.stopTest();
    }
    /****************************************************************************************************************************************
    Method Name:                                   testROSharing
    Description:                                   Check the Geo based sharing for RO
    Added By:                                      Accenture – NZ  4/19/2020
    Modified By:                  Date:            Changes: 
    Accenture – NZ           NZ  4/19/2020      Created.
    *****************************************************************************************************************************************    
    @isTest static void testROSharing(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1'];
        //User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        test.startTest();
        
        Core_MDF_Exception__c expt = [SELECT Id, Name, Core_MDF_Exception_Start_Date_dt__c, Core_MDF_Exception_End_Date_dt__c,
                                      Core_MDF_Program_nm__c, Core_MDF_Activity_Cate_and_Type_nm__c, Core_MDF_Account_id__c,
                                      Core_MDF_Select_All_Accounts_ind__c, Core_MDF_Name_of_Exception_nm__c, Core_MDF_Exception_Reason_nm__c
                                      FROM Core_MDF_Exception__c 
                                      WHERE Core_MDF_Name_of_Exception_nm__c = 'Test Exception Single Account' LIMIT 1];
        
        Case cs = [SELECT Id, AccountId, Account.Core_MDF_Channel_Program__r.Name
                   FROM Case 
                   WHERE Core_MDF_Activity_Category__c = 'Broadcast' LIMIT 1];
        
          Core_MDF_Exception_Case_Mapping__c ecm = [SELECT Id 
                                                  FROM Core_MDF_Exception_Case_Mapping__c 
                                                  WHERE Core_MDF_Case_id__c =:cs.Id  
                                                  AND Core_MDF_Exception_id__c=:expt.Id];
     	
        Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                  	 From Core_MDF_ProgramGeoGroupMap__mdt
                                                  	 WHERE Core_MDF_Region__c = :'APJ'
                                                     AND Core_MDF_Program__c = : 'Client Co-Marketing Fund'];
                
        Boolean isAPJShared = false;
        test.stopTest();
       
        try{
         List<Core_MDF_Exception_Case_Mapping__Share> ecmShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                       FROM Core_MDF_Exception_Case_Mapping__Share 
                                                       WHERE parentId = :ecm.Id];
            
        for(Core_MDF_Exception_Case_Mapping__Share shareRec : ecmShareList)
        {
            System.debug('NZ-->shareRec.UserOrGroup.Name: '+shareRec.UserOrGroup.Name);
            System.debug('NZ-->metaRec.Core_MDF_Group_Name__c: '+metaRec.Core_MDF_Group_Name__c);
            if(shareRec.UserOrGroup.Name.equals(metaRec.Core_MDF_Group_Name__c)){
                isAPJShared = true;
            }
        }
        if(!isAPJShared){
            System.debug('NZ-->readOnlyShareFlag: '+isAPJShared);
            System.assert(isAPJShared);
        }
        
        }catch(Exception e){
            System.debug('Error');
        }
        
    }*/
    
}