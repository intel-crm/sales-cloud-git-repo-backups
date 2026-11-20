/******************************************************************************************************************************
Apex Class Name:  Core_PreventDelTrackingRecordHandler
Version     : 1.0 
Created Date: 18 March 2019
Function    : Helper class for Trigger on the Core_User_Field_Change_History__c object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandip Ghosh             18/03/2019              Initial version of the trigger handler class
*******************************************************************************************************************************/
public class Core_PreventDelTrackingRecordHandler {
    
    /*
     call before delete actions 
    */
    public static void onBeforeDelete(List<Core_User_Field_Change_History__c> oldCoreUserFieldChangeHistotyList,
                                     Map<Id, Core_User_Field_Change_History__c> oldMapCoreUserFieldChangeHistory) {
        
        handleDeleteScenario(oldCoreUserFieldChangeHistotyList,oldMapCoreUserFieldChangeHistory);
    }
    
    /*
	Call after delete actions
	*/
    public static void onAfterDelete(List<Core_User_Field_Change_History__c> oldCoreUserFieldChangeHistotyList, 
                                      Map<Id, Core_User_Field_Change_History__c> oldMapCoreUserFieldChangeHistory) {

       handleDeleteScenario(oldCoreUserFieldChangeHistotyList,oldMapCoreUserFieldChangeHistory);

    }
    
    /*
     	Deleting record
    */
    private static void handleDeleteScenario(List<Core_User_Field_Change_History__c> oldCoreUserFieldChangeHistotyList, 
                                      Map<Id, Core_User_Field_Change_History__c> oldMapCoreUserFieldChangeHistory){
                                          
        for(Core_User_Field_Change_History__c recordsToDelete:oldCoreUserFieldChangeHistotyList){
            
            	// Fetching the custom label value
                String customLabelValue = System.Label.Core_User_Field_Change_History_Record_Deletion;
                Integer strtToIntvalue = Integer.valueOf(customLabelValue.trim());
            	//Substracting today minus label value
                Date dateVal= System.today()-strtToIntvalue;
                Date dateLimit = dateVal+1;
                if(recordsToDelete.CreatedDate>=dateVal && recordsToDelete.CreatedDate<dateLimit){ 
                }else{
                    recordsToDelete.addError('System will not allow to modify log details, please contact Security Team for further assistance');
                }       
         }
    }
    
}