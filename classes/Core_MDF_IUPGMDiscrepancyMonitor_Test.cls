@isTest
public class Core_MDF_IUPGMDiscrepancyMonitor_Test {
    Public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    
    @TestSetup
    static void createTestData(){
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        System.runAs(testUser){
            //Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
	    Set<String> myset1 = new Set<String>();
	    List<String> result1 = new List<String>();
	    bypassFunctionKeys.add('Core_MDF_RemoveGrpMemberBypass');
	    myset1.addAll(bypassFunctionKeys);
	    result1.addAll(myset1);
	    List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(ipaCp);
            insert cpList;
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false); 
            ccpIntelAccount.Core_MDF_CoMarketingActive__c= true;
            ccpIntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
            if(isUnifiedIdEnabled){
                ccpIntelAccount.Core_Unified_Global_Customer_BP_Id__c = 'ABC123';
            }else{
                ccpIntelAccount.Core_Prime_Id__c = 'ABC123'; 
            }
            Database.insert(ccpIntelAccount);
            
            Group ipaGRP = new Group();
            ipaGRP.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ipaGRP.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ipaGRP);
            
           
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa9);
            
            PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSetAssignment psa15 = new PermissionSetAssignment(PermissionSetId = ipaApprPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa15);
           
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

			Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm6= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm6.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm6.RecordTypeId = IPA_RecordType;
            IPAiupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm6.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm6.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm6.Core_MDF_Budget_Type_nm__c='Account Plan';
            IPAiupgm6.Core_MDF_GeoSubGeo_Budget_Type_nm__c='EMEA->Client Specialties MDF';
            IPAiupgm6.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm6.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm6.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm6.Core_MDF_Active_Ind__c = TRUE;
            IPAiupgm6.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            IPAiupgm6.Core_MDF_Activity_Classification_nm__c ='Sales;Marketing';
            iupgmList.add(IPAiupgm6);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm7= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm7.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm7.RecordTypeId = IPA_RecordType;
            IPAiupgm7.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm7.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm7.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm7.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm7.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm7.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm7.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgmList.add(IPAiupgm7);
            
            insert iupgmList;
            
            IPAiupgm7.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
            update IPAiupgm7;
            
            Set<String> iupgmKeySet = new Set<String>();
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord: iupgmList){
                Set<String> geoSubGeoSet =  new Set<String>();
                String accProgGeoKey = '';
                if(iupgmRecord.Core_MDF_Region_Sub_Region_nm__c != null){
                    List<String> geoList = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c.split(';');
                    geoSubGeoSet.addAll(new Set<String>(geoList));
                }
                if(iupgmRecord.Core_MDF_Budget_Type_nm__c != null){ // budget type exists
                    if(iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
                        for(String geoBudgetTypeStr : iupgmRecord.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';')){
                            String geo = geoBudgetTypeStr.split('->')[0] ;                             
                            String budgetType = geoBudgetTypeStr.split('->')[1] ;
                            accProgGeoKey = iupgmRecord.Core_MDF_Account_id__c + ';' + iupgmRecord.Core_MDF_Program_nm__c + ';' + geo + ';' + budgetType; // 001g0000024cdfQQZ;Intel Partner Alliance;APJ;ProposalI
                            iupgmKeySet.add(accProgGeoKey);
                        }
                    }
                }
                else{ // without budget type keys
                    for(String geo : geoSubGeoSet){
                        accProgGeoKey = iupgmRecord.Core_MDF_Account_id__c + ';' + iupgmRecord.Core_MDF_Program_nm__c + ';' + geo;  // 001g0000024cdfQQZ;Intel Partner Alliance;APJ
                        iupgmKeySet.add(accProgGeoKey);
                    }
                } 
            }
            
             Core_MDF_Partner_Group_Mapping__c pgmRecord = [SELECT Id, Core_MDF_Account__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Group_Name__c,                               
                                                         Core_MDF_Group_id__c, Core_MDF_Region_cd__c, Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c, Core_MDF_Inactive_Ind__c                                
                                                         FROM Core_MDF_Partner_Group_Mapping__c
                                                         WHERE Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'
                                                         AND Core_MDF_Region_cd__c = 'EMEA'
                                                         AND Core_MDF_Type_Of_Access__c = 'Internal'
                                                         AND Core_MDF_Inactive_Ind__c = FALSE LIMIT 1];
            
            String pgmKey = pgmRecord.Core_MDF_Account__c + ';' +pgmRecord.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c + ';' + pgmRecord.Core_MDF_Region_cd__c +'-'+ pgmRecord.Core_MDF_Sub_Region_cd__c + ';' + pgmRecord.Core_MDF_BudgetType_nm__c;                               
                                                                    //if sub region is null, then -null has to be removed 
                                                                    if(pgmKey.contains('-null')){                               
                                                                        pgmKey = pgmKey.remove('-null');
                                                                    }
            
            Map<String, Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<String, Core_MDF_Partner_Group_Mapping__c>();
            pgmMap.put(pgmKey, pgmRecord);
            
            Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper contentWrapper = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper();
            
            List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper> contentWrapperList = new List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper>();
            
            Core_MDF_IUPGM_Discrepancy_Monitor_Batch.createContentWrapper(iupgmList, null, null);
            contentWrapperList = Core_MDF_IUPGM_Discrepancy_Monitor_Batch.createContentWrapper(iupgmList, pgmMap, iupgmKeySet);
            
            Map<String, List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper>> missingCategoryToWrapperMap = new Map<String, List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper>>();
            missingCategoryToWrapperMap.put('Missing Group Member', contentWrapperList);
        }
    }
    @isTest
    public static void testMethod1(){
        
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj=new Core_MDF_IUPGM_Discrepancy_Monitor_Batch(null,null);
        database.executebatch(obj,5);
        database.executebatch(obj);
        Id batchId = Database.executeBatch(obj);
        Test.stopTest();
        Assert.areNotEqual(batchId,null);
      }
    
    @isTest static void testDiscrepancyInstance(){
        Object obj = Core_MDF_IUPGM_Discrepancy_Monitor_Batch.generateInstance('{"fieldFilterName":"test","fieldFilterValue":"123"}','Core_MDF_IUPGM_Discrepancy_Monitor_Batch(String fieldFilterName, String fieldFilterValue)');
        Assert.areNotEqual(obj,null);
    }
    
}