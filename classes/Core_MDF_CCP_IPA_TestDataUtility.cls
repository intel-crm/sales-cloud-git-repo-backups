@isTest
public class Core_MDF_CCP_IPA_TestDataUtility {
    public static Id account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
    public static Id intel_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static Id budget_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
    //public static Id budgetIPA_Account_Based_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Account_Based').getRecordTypeId();
    public static Id budgetIPA_ProposalBased_Record_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId();
    public static Id allocation_Record_Type = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id partnerFund_RecordType_IPA = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    public static Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    
    public static Id claim_RecordType_IPA = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    /* Reuse from Core_MDF_CCP_TestDataUtility
     1. createUser
     2. createPartnerUser 
     3. ChannelProgram 
    */
    
    public static Campaign createIPACampaign(String campaignName,Id accountId, Date startDate, Date endDate,String budgetType,
                                             Decimal totalCampaignCost,String country, String audience, String technology, 
                                             string status, Boolean isInsert){
        
        Campaign ipaCampaign = new Campaign(); 
        ipaCampaign.Name = campaignName;
        ipaCampaign.RecordTypeId = campaign_RecordType_IPA;
        ipaCampaign.Core_MDF_Program__c = 'Intel Partner Alliance';
        ipaCampaign.StartDate = startDate;
        ipaCampaign.EndDate = endDate;
        ipaCampaign.Core_MDF_Account__c = accountId;
        ipaCampaign.Core_MDF_Audience__c= audience; 
        ipaCampaign.Core_MDF_Total_Campaign_Cost_Amt__c = totalCampaignCost;
        ipaCampaign.Description = 'IPA Campaign Description';
        ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;
        ipaCampaign.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';                              
        //ipaCampaign.Core_MDF_Opal_Budget_Type_Txt__c = budgetType;                                        
        ipaCampaign.Core_MDF_Reimbursement_Rate__c = '100%';
        ipaCampaign.Core_MDF_Technology__c = technology;
        ipaCampaign.Core_MDF_Market__c = country;
        ipaCampaign.Status = status;
        ipaCampaign.Core_MDF_Region_cd__c = 'APJ';                                 
                                                 
        if(isInsert){
            insert ipaCampaign;            
        }
                                                 
        return ipaCampaign;
        
    }

    public static PartnerFundRequest createIPAPartnerFundRequest(String campaignId,String channelPartnerId,Date startDate,Date endDate,Boolean isInsert){
        PartnerFundRequest testPartnerFundRequest = NULL;
        testPartnerFundRequest = new PartnerFundRequest(CampaignId=campaignId,recordtypeid = Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,ChannelPartnerId = channelPartnerId,Core_MDF_ActivityCategory__c='Broadcast (Pre-2025)',
                                                                           Core_MDF_Activity_Types__c='Podcast',RequestedAmount=1234,Core_MDF_Start_Date__c=startDate,Core_MDF_End_Date__c =endDate,Title ='Test IPA',
                                                                           Core_MDF_Activity_Description__c ='Test IPA Description', Core_MDF_Activity_Classification_nm__c = 'Marketing');
        
        if(isInsert){
            insert testPartnerFundRequest;
        }
        
        return testPartnerFundRequest;
    }
    
    public static String createBenefit(Account acc){
        
        Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account pagAccount = new Account(Name='IPA PAG Account', RecordTypeId=PAG_Account_Record_Type); 
        pagAccount.Core_Unified_Global_Customer_BP_Id__c ='primeId';
        insert pagAccount;
            
        Account pagAcc = [Select id from Account where Name='IPA PAG Account' and RecordTypeId=:PAG_Account_Record_Type limit 1];
        //get the intel acct    
        Account intelAcc = [select id from Account where id=:acc.Core_MDF_Parent_Fund_Account__c];
        intelAcc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update intelAcc;
        /*intelAcc.Core_IPA_One_Partner_Id__c = pagAcc.Id;
        update intelAcc;*/
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAcc.Id,Core_Intel_Account_Id__c=intelAcc.Id);
        insert agm;
        // Highlight: Unused Local Variable 
       // Id ultimateAcctId = (acc.Core_MDF_Parent_Fund_Account__c != null ? acc.Core_MDF_Parent_Fund_Account__c : acc.Id);
        
        // Highlight: Unused Local Variable 
       // ChannelProgram cp = [Select id,Name from ChannelProgram where Name = 'Intel Partner Alliance' limit 1];    
       
        PRM_BatchCustomSetting__c bcss = new PRM_BatchCustomSetting__c();
        bcss.name= 'BatchFieldValues';
        //bcss.PRM_MP_Benefits__c='Speciality';
        bcss.PRM_PartnerRole__c='Service Provider';
        bcss.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        insert bcss;             
         
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Business Client Acceleration - MDF';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=selectBenRT;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;
                
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_InActive_Ind__c  = FALSE;
        asa.PRM_Specialty_Id__c = spec1.ID;
        asa.PRM_Account_Id__c =intelAcc.id;
        insert asa;
                
        /*Core_MDF_BudgetType_Benefit_Mappings__c mdtRec = [select Core_MDF_Budget_Type__c from 
                                                           Core_MDF_BudgetType_Benefit_Mappings__c 
                                                          where Core_MDF_Partner_Benefit__c='Business Client Acceleration - MDF' Limit 1];*/
       Core_MDF_BudgetType_Benefit_Mappings__c mdtRec = new Core_MDF_BudgetType_Benefit_Mappings__c();
       mdtRec.Name = 'Test';
       mdtRec.Core_MDF_Budget_Type__c = 'Business Client Acceleration - MDF';
       insert mdtRec;
        
        return mdtRec.Core_MDF_Budget_Type__c;
    }
    
    
    public static String createBenefitforAccountBased(Account acc){
        
        Id PAG_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account pagAccount = new Account(Name='IPA PAG Account2', RecordTypeId=PAG_Account_Record_Type);           
        insert pagAccount;
            
        Account pagAcc = [Select id from Account where Name='IPA PAG Account2' and RecordTypeId=:PAG_Account_Record_Type limit 1];
        //get the intel acct    
        Account intelAcc = [select id from Account where id=:acc.Core_MDF_Parent_Fund_Account__c];
        /*intelAcc.Core_IPA_One_Partner_Id__c = pagAcc.Id;
        update intelAcc;*/
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=pagAcc.Id,Core_Intel_Account_Id__c=intelAcc.Id);
        insert agm;
        // Highlight: Unused Local Variable 
       // Id ultimateAcctId = (acc.Core_MDF_Parent_Fund_Account__c != null ? acc.Core_MDF_Parent_Fund_Account__c : acc.Id);
        
        // Highlight: Unused Local Variable
       // ChannelProgram cp = [Select id,Name from ChannelProgram where Name = 'Intel Partner Alliance' limit 1];    
       
        // Highlight: Unused Local Variable 
       // List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        
        PRM_BatchCustomSetting__c bcss = new PRM_BatchCustomSetting__c();
        bcss.name= 'BatchFieldValues';
        //bcss.PRM_MP_Benefits__c='Speciality';
        bcss.PRM_PartnerRole__c='Service Provider';
        bcss.PRM_PartnerType__c='Cloud Service Provider (CSP)';
        insert bcss;             
         
        Id selectBenRT=Schema.getGlobalDescribe().get('PRM_Specialty__c').getDescribe().getRecordTypeInfosByDeveloperName().get('PRM_Select_Benefits').getRecordTypeId();  
        PRM_Specialty__c spec1 = new PRM_Specialty__c();
        spec1.name='Scale Acceleration - MDF';
        spec1.PRM_Description_Txt__c='This is description';
        spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec1.PRM_Role_Nm__c='Service Provider';
        spec1.PRM_Tier_Nm__c='Gold';
        spec1.PRM_Start_Date_Dt__c= system.today() + 7;
        spec1.PRM_End_Date_Dt__c= spec1.PRM_Start_Date_Dt__c + 5;
        spec1.PRM_Access_Level_Nm__c='Public';
        spec1.RecordTypeId=selectBenRT;
        spec1.PRM_Inactive_Ind__c=false;
        insert spec1;        
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_InActive_Ind__c  = FALSE;
        asa.PRM_Specialty_Id__c = spec1.ID;
        asa.PRM_Account_Id__c =pagAcc.id;
        insert asa;
                
        Core_MDF_BudgetType_Benefit_Mappings__c mdtRec = [select Core_MDF_Budget_Type__c from 
                                                           Core_MDF_BudgetType_Benefit_Mappings__c 
                                                          where Core_MDF_Partner_Benefit__c='Scale Acceleration - MDF' Limit 1];
        
        return mdtRec.Core_MDF_Budget_Type__c;
    }
    
    public static PartnerFundClaim createIPAClaim(String claimName, Id claimRecordTypeId, Id requestId, Date startDate, Date endDate,Decimal amount, Id bankId, Boolean isInsert){
        
        PartnerFundClaim pfc = new PartnerFundClaim();
        pfc.RequestId = requestId;
        pfc.RecordTypeId = claimRecordTypeId;
        pfc.amount = amount;
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = amount;
        pfc.Core_MDF_Ad_Run_Start_Date__c = startDate;
        pfc.Core_MDF_Ad_Run_End_Date__c = endDate;
        pfc.Title = claimName;
        pfc.Core_MDF_Currency__c = 'USD';        
        pfc.Core_MDF_Bank__c = bankId;
        pfc.Description = 'Test';
        pfc.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
        
        if(isInsert){
            insert pfc;            
        }
        return pfc;
    }
 

}