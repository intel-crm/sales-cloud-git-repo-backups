/****************************************************************************************************************************************
* Class Name  : PMP_CheckIfDuplicateOffering 
* Version     : 1.0 
* Created Date: 09-24-2019
* Modification Log :
*
* Developer                           Date                          Description
* -------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team - Manasa                 09-24-2019                    Created for checking if the offering name is duplicate or not
****************************************************************************************************************************************************************/
public without sharing class PMP_CheckIfDuplicateOffering {
    /*************************************************************************** 
* Method Name : isDuplicateOffering
* Description : Method to identify duplicate Offerings
*              -1 for duplicate offering within same partner company
*               0 for duplicate offering across the partner exchange
*               1 for non duplicte offering
******************************************************************************/
    public static integer isDuplicateOffering(string strOfferingName, string offeringId, string companyId)
    {
        system.debug('offeringId: ' + offeringId);
        system.debug('companyId: ' + companyId);
        system.debug('strOfferingName : '+ strOfferingName);
        
        Integer totalCount = [Select count() from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = :strOfferingName
                              and PMP_Working_Copy_Id__c = null and Id != :offeringId]; 
        system.debug('totalCount====>'+totalCount);
        if(totalCount > 0)
        {
            Integer companyCount = [Select count() from PMP_Partner_Offering__c where PMP_Partner_Offering_Nm__c = :strOfferingName
                                    and PMP_Working_Copy_Id__c = null and PMP_Company_Id__c = :companyId and Id != :offeringId];
            system.debug('companyCount====>'+companyCount);
            if(companyCount > 0){
                return -1;
            }
            else{
                return 0;
            }
            
        }
        else {
            return 1;
        }   
        
    }

}