/****************************************************************************************************************************************
* Class Name  : Core_MDF_Budget_Utility
* Version     : 1.0 
* Created Date: 10-16-2018
* Descirption : This class is in WITHOUT SHARING mode , kindly do not update
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AH      10/16/2018          Utility Class for Budget functionalities.
*****************************************************************************************************************************************/

public without sharing class Core_MDF_Budget_Utility{
    
    /**************************************************************************************************************************  
Method Name:        unlockBudget
@return  :          void
@parameters:        budgetList - Budget List
Description:        This method is used to unlock the Pending Review budget, Update the Budget and Lock it again
Added By:           Accenture - JV - 10/16/2018
Intel - SM - 07/04/2020
****************************************************************************************************************************/
    @AuraEnabled
    public static void unlockBudget(List<PartnerMarketingBudget> budgetList){
        try
        {
            Approval.UnlockResult[] unlockResultLst = Approval.unlock(budgetList, true);
            update budgetList;
            Approval.lock(budgetList, true);
        }
        catch(Exception e)
        {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;
        }
        
    }  
}