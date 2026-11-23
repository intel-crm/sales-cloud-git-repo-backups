@isTest(SeeAllData=false)
public without sharing class Test_SH {    
    @isTest static void testSchedulerMethod()
    {  
        User IUPGMUser = [Select id, Name, ProfileId from user where id =: userInfo.getUserId()];
        System.runAs(IUPGMUser){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            //iupgm1.Core_MDF_Account_id__c = ipaUltimateAccount.Id;
            iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c = IUPGMUser.Id;
            iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader';
            iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm1.Core_MDF_All_Accounts_cd__c = 'yes';
            //iupgm1.Core_MDF_Budget_Type_nm__c = budgetType;
            //iupgm1.Core_MDF_is_User_Active_ind__c = true;
            iupgm1.Core_MDF_Active_Ind__c = true;
            iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c = false;
            insert iupgm1;
        }
    }
}