/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetTransferServiceHandler  
* Version     : 1.0 
* Created Date: 03-26-2020 
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna Kulkarni       03/26/2020         
*****************************************************************************************************************************************/
public class Core_MDF_BudgetTransferServiceHandler {
    /***************************************************************************************************** 
Method Name:        populateUniqueField
@return  :          void
@parameters:        accountTransferList - This will contain all the accountTransferLog List  
Description:        Whenever a record is created of accountTransferLog, this method populates unique field
@Added By:          Accenture - KK - 03-26-2020
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static void populateUniqueField(List<Core_MDF_Budget_Transfer_Log__c> accountTransferList, Map<Id,Core_MDF_Budget_Transfer_Log__c> oldBTLIdToBTLMap) {
        try{
            
            if(oldBTLIdToBTLMap != null && oldBTLIdToBTLMap.size() > 0){
            for(Core_MDF_Budget_Transfer_Log__c accTransferRecord : accountTransferList){
                DateTime myDateTime = accTransferRecord.CreatedDate;
                Date myDate = myDateTime.dateGMT();
                String modifiedDate = String.valueOf(myDate.day())+'-'+String.valueOf(myDate.month())+'-'+String.valueOf(myDate.year());
                String uniqueString = String.valueOf(accTransferRecord.Core_MDF_Source_Account__c)
                    +'_'+String.valueOf(accTransferRecord.Core_MDF_From_Account_Opening_Balance__c)
                    +'_'+String.valueOf(accTransferRecord.Core_MDF_Partner_Marketing_Budget__c);
                if(accTransferRecord.Core_MDF_Transfer_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Transfer_Type_Auto')){
                    uniqueString = uniqueString+'_'+modifiedDate+'_'+String.valueOf(accTransferRecord.Core_MDF_Transfer_Type__c);
                }else{
                    uniqueString = uniqueString+'_'+String.valueOf(accTransferRecord.CreatedDate);
                }
                accTransferRecord.Core_MDF_Unique_Key_txt__c = uniqueString;
            }
        }else{
            DateTime myDateTime = system.now();
            Date myDate = myDateTime.dateGMT();
            String modifiedDate = String.valueOf(myDate.day())+'-'+String.valueOf(myDate.month())+'-'+String.valueOf(myDate.year());
            for(Core_MDF_Budget_Transfer_Log__c accTransferRecord : accountTransferList){
                String uniqueString = String.valueOf(accTransferRecord.Core_MDF_Source_Account__c)
                    +'_'+String.valueOf(accTransferRecord.Core_MDF_From_Account_Opening_Balance__c)
                    +'_'+String.valueOf(accTransferRecord.Core_MDF_Partner_Marketing_Budget__c);
                if(accTransferRecord.Core_MDF_Transfer_Type__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Transfer_Type_Auto')){
                    uniqueString = uniqueString+'_'+modifiedDate+'_'+String.valueOf(accTransferRecord.Core_MDF_Transfer_Type__c);
                }else{
                    uniqueString = uniqueString+'_'+String.valueOf(system.now());
                }
                accTransferRecord.Core_MDF_Unique_Key_txt__c = uniqueString; } } }catch(Exception e) {if(e!=null){Core_MDF_CCP_UtilityClass.logError(e); throw e;}}
    }
}