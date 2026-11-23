/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountUser_Controller 
* Version     : 1.0 
* Created Date: 05-08-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna         05/08/2019                    This class hold the Utility methods for the Delete PNUM Scenario     
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AccountUser_Controller {
    
/***************************************************************************************************** 
Method Name:        isAccountUserEligibleForDelete
@return  :          Boolean
@parameters:        accountUserId
Description:        This is a Method to check whether the Delete action is eligible on a PNUM Record
Added By:           Accenture - Krishna - 05/08/2019
******************************************************************************************************/   
    
    @AuraEnabled
    public static Boolean isAccountUserEligibleForDelete(Id accountUserId){        
            boolean hasDeleteAccess = false;
        	hasDeleteAccess = FeatureManagement.checkPermission(Label.Core_MDF_Permission_to_Delete_Account_User);
        	if(hasDeleteAccess == false){
                hasDeleteAccess = Core_MDF_checkSObjectCRUDPermission.checkSObjectDeletePermission('Core_MDF_Partner_Node_User_Mapping__c');           
            }
        	return hasDeleteAccess;
    }
    
    /***************************************************************************************************** 
Method Name:        deleteAccountUser
@return  :          Boolean
@parameters:        accountUserIdList
Description:        This is a Method to be used to Delete a list of account users
Added By:           Accenture - Krishna - 05/08/2019
******************************************************************************************************/    
    @AuraEnabled
    public static boolean deleteAccountUsers(List<Id> accountUserIdList){
        Boolean success = true;
        try{
            List<Core_MDF_Partner_Node_User_Mapping__c> accountUserList = [SELECT Id FROM Core_MDF_Partner_Node_User_Mapping__c where Id IN :accountUserIdList];
            if(accountUserList != null && accountUserList.size() > 0){
                Database.delete(accountUserList);
            }                       
            return success;
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e; //throw new AuraHandledException(''+e.getMessage());
        }
    }
}