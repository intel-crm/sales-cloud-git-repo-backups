@isTest(SeeAllData=false)
public class Core_MDF_GenericMetadata_Test {
	@isTest
    public static void genericmetadataMethod(){
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole1.Id;
        Database.insert(usr);
        
        System.runAs(usr){
           //Core_MDF_GenericMetadata.getMetaDataRecords('id,Core_MDF_Activity_RecordType_txt__c','Core_MDF_ClaimActAllocRecTypeMapping__mdt', 'Core_MDF_Channel_Program_txt__c = \'Client Co-Marketing Fund\' ');
           //Core_MDF_GenericMetadata.getMetaDataAllRecords('Core_MDF_ClaimActAllocRecTypeMapping__mdt', 'Core_MDF_Channel_Program_txt__c = \'Client Co-Marketing Fund\' ');
           RecordType ccfRecordType = Core_MDF_GenericMetadata.getRecordTypeId('Client','Campaign');
           List<sObject> ccpCountryMDTlist = Core_MDF_GenericMetadata.getObjectRecords('Core_MDF_CCP_Country_Geo_Mapping__mdt','Core_MDF_Code_2_Digits__c  IN (\'GB\')');
           List<sObject> ccpCountryMDTlist1 = Core_MDF_GenericMetadata.getCountryGeoMappingMdt('Core_MDF_Code_2_Digits__c  IN (\'GB\')');
           List<Core_MDF_CCP_Country_Geo_Mapping__mdt> checkCountryMDTList = [Select Id, Label, DeveloperName, MasterLabel, Core_MDF_Code_2_Digits__c, Core_MDF_Sub_Geo__c, Core_MDF_Geo__c,Core_MDF_Blocked_in_UI_ind__c from Core_MDF_CCP_Country_Geo_Mapping__mdt where Core_MDF_Code_2_Digits__c = 'GB'];
            
           List<sObject> ccpActivityTypeMDTlist = Core_MDF_GenericMetadata.getObjectRecords('CCP_Activity_Type_dependent_fields__mdt','Core_MDF_Activity_Category_Txt__c = \'Broadcast\'');
           List<sObject> ccpActivityTypeMDTlist1 = Core_MDF_GenericMetadata.getActivityTypeDependentFieldsMdt('Core_MDF_Activity_Category_Txt__c = \'Broadcast\'');
           List<CCP_Activity_Type_dependent_fields__mdt> checkActivityTypeMDTlist = [SELECT Core_MDF_Object_API_Field_Name__c, Core_MDF_Manadatory_Ind__c, Core_MDF_Program_Txt__c, Core_MDF_Activity_Type_Txt__c, Core_MDF_Activity_Category_Txt__c, Core_MDF_Activity_Subtype_Txt__c,  Core_MDF_Module__c, Core_MDF_Picklist_ind__c, Core_MDF_Is_Proposal_Based_Ind__c, Core_MDF_Is_Account_Based__c, Core_MDF_Is_Inactive_For_Activity_Ind__c, Core_MDF_Is_Inactive_For_Claim_Ind__c, Core_MDF_Sort_Order_Nbr__c, Core_MDF_Is_EOLed_Ind__c  FROM CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Activity_Category_Txt__c = 'Broadcast'];
           List<CCP_Activity_Type_dependent_fields__mdt> checkActivityTypeMDTlist1 = [SELECT Core_MDF_Object_API_Field_Name__c, Core_MDF_Manadatory_Ind__c, Core_MDF_Program_Txt__c, Core_MDF_Activity_Type_Txt__c, Core_MDF_Activity_Category_Txt__c, Core_MDF_Activity_Subtype_Txt__c,  Core_MDF_Module__c, Core_MDF_Picklist_ind__c, Core_MDF_Is_Proposal_Based_Ind__c, Core_MDF_Is_Account_Based__c, Core_MDF_Is_Inactive_For_Activity_Ind__c, Core_MDF_Is_Inactive_For_Claim_Ind__c, Core_MDF_Sort_Order_Nbr__c  FROM CCP_Activity_Type_dependent_fields__mdt where Core_MDF_Activity_Category_Txt__c = 'Broadcast'];

            
           List<sObject> ClaimActAllocRecTypeMappingMDTlist = Core_MDF_GenericMetadata.getObjectRecords('Core_MDF_ClaimActAllocRecTypeMapping__mdt','Core_MDF_Channel_Program_txt__c  = \'Client Co-Marketing Fund\'');
           List<sObject> ClaimActAllocRecTypeMappingMDTlist1 = Core_MDF_GenericMetadata.getClaimActAllocRecTypeMappingMdt('Core_MDF_Channel_Program_txt__c  = \'Client Co-Marketing Fund\'');
           List<Core_MDF_ClaimActAllocRecTypeMapping__mdt> checkClaimActAllocRecTypeMappingMDTlist = [Select id,Label,Core_MDF_Activity_RecordType_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Channel_Program_Name_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c,Core_MDF_Payment_RecordType_txt__c,Core_MDF_Channel_Program_txt__c,Core_MDF_ClaimStage_RecordType_txt__c,Core_MDF_Activity_Close_Days__c,Core_MDF_Internal_Master_Group_Name_Txt__c,Core_MDF_External_Master_Group_Name_Txt__c,Core_MDF_Region_cd__c,Core_MDF_POP_Mandatory_Ind__c,Core_MDF_Claim_Activity_Name_Swap_Ind__c,Core_MDF_isProgramBased_Ind__c,Core_MDF_Budget_Cap_RecType_DevName_Txt__c,Core_MDF_isProposalBased__c  from Core_MDF_ClaimActAllocRecTypeMapping__mdt where Core_MDF_Channel_Program_txt__c = 'Client Co-Marketing Fund'];
            
            List<Core_MDF_BudgetType_Benefit_Mapping__mdt> budgetTypeBenefitMapping = new List<Core_MDF_BudgetType_Benefit_Mapping__mdt>();
            String objectApiName = 'Core_MDF_BudgetType_Benefit_Mapping__mdt';
            List<ChannelProgram> cp= [select id,Core_MDF_Technical_Program_Name__c from ChannelProgram where Core_MDF_Technical_Program_Name__c!=null];
            List<String> programName =  new List<String>();
            for(ChannelProgram prog:cp){
                programName.add(prog.Core_MDF_Technical_Program_Name__c);
            }
            String whereClauseForBudgetType = 'Core_MDF_Program_Nm__c =\''+programName+'\' '+' AND Core_MDF_IsActive__c=true';
            budgetTypeBenefitMapping = Core_MDF_GenericMetadata.getObjectRecords(objectApiName, whereClauseForBudgetType);
            
            System.assertEquals(checkCountryMDTList, ccpCountryMDTlist,'true');
            System.assertEquals(checkActivityTypeMDTlist, ccpActivityTypeMDTlist,'true');
            System.assertEquals(checkClaimActAllocRecTypeMappingMDTlist,ClaimActAllocRecTypeMappingMDTlist,'true');
            //System.assertEquals(checkCountryMDTList, ccpCountryMDTlist1,'true');
            System.assertEquals(checkActivityTypeMDTlist1, ccpActivityTypeMDTlist1,'true');
            System.assertEquals(checkClaimActAllocRecTypeMappingMDTlist,ClaimActAllocRecTypeMappingMDTlist1,'true');
            try{
                Core_MDF_GenericMetadata.getRecordTypeId(null,null);
            }
            catch(exception e){
                System.debug(e.getMessage());
            }
        }
    }
}