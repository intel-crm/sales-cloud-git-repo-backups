/****************************************************************************************************
Apex Class Name : Sales_CreateLogRecords
Version         : 1.0 
Created Date    : 18/May/2021
Function        : generic method to create log records for DML
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jasmine                     18/May/2021               Created
*/
public class Sales_CreateLogRecords {
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'Sales';
    public static void createLogRecords(List<Database.SaveResult> saveResultList, List<SObject> sObjectList,String ORIGIN){
        Integer index = 0;
        for(Database.SaveResult result: saveResultList){
            if(!result.isSuccess()){
                Id sId;
                string sObjectType = '';
                string tags = '';
                for(Database.Error err: result.getErrors()){
                    sId = sObjectList[index].Id;
                    if(sId != null){
                        sObjectType = sId.getSObjectType().getDescribe().getName();
                    }
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(), err.getMessage(), sId, sObjectType, '');
                }
            }   
            index++;
        }   
    }
}