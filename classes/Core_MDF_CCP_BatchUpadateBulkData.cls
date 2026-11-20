public class Core_MDF_CCP_BatchUpadateBulkData  implements Database.Batchable<sObject>, Database.Stateful{
        
        List<SObject> records = new List<SObject>();
        Set<String> successIdSet = new Set<String>();
        public String incidentno;
  
        private String objectSelected ;
        private String errorMsg='';
        private String recordId;
        public Core_MDF_CCP_BatchUpadateBulkData(List<SObject> records,String incidentno,String objectSelected){
            this.records = records;
            this.incidentno = incidentno;  
            this.objectSelected=objectSelected;
        }
        public Iterable<sObject> start(Database.BatchableContext bc){
             List<sObject> recordsToUpdate = new List<sObject>(records);
             return recordsToUpdate;
        }
        public void execute(Database.BatchableContext bc, List<sObject> scope){
            // process each batch of records
            try{
                List<Database.SaveResult> saveResult = database.update(scope, false);
                for(Database.SaveResult saveResultNew:saveResult){
                    if(!(saveResultNew.isSuccess())){
                        recordId=saveResultNew.getId();
                        errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                        
                    }else{
                         //recordId = result?.get(i)?.getId();
                        recordId=saveResultNew.getId();
                        successIdSet.add(recordId);
                    }
                }
            }catch (Exception e){
                
                Core_Log_Entry.logEntryWithDetails(Core_MDF_ExtendedDataTable_Controller.ORIGIN, Core_MDF_ExtendedDataTable_Controller.PROJECT,'',Core_MDF_ExtendedDataTable_Controller.INFOSEVERITY,'','Error Occurred while updating on BulkDataUpdate'+'Error:'+errorMsg,'', '', '');
            }
        }    
        public void finish(Database.BatchableContext bc){
            // execute any post-processing operations
            String successIds ='';
            Boolean isFirst = false;
            try{
                 
               for(String successId : successIdSet){
                   if(isFirst == false){
                       successIds += successId;
                       isFirst = true;
                   }else{
                        successIds+=','+ successId;
                   }
               }
               Core_MDF_Record_Tracking__c trackingIncidentRecord = new Core_MDF_Record_Tracking__c();
               trackingIncidentRecord.Core_MDF_Object_Name_nm__c = objectSelected;
               trackingIncidentRecord.Core_MDF_Record_Ids__c = successIds;
               trackingIncidentRecord.Core_MDF_Target_Record_Id__c = incidentno; 
               insert trackingIncidentRecord;
                
               if(errorMsg!=''){   //error while updating
                 
                   Core_MDF_ExtendedDataTable_Controller.sendEmailOnExcpetion(UserInfo.getUserEmail(),objectSelected,errorMsg); 
                   Core_Log_Entry.logEntryWithDetails(Core_MDF_ExtendedDataTable_Controller.ORIGIN, Core_MDF_ExtendedDataTable_Controller.PROJECT,'',Core_MDF_ExtendedDataTable_Controller.INFOSEVERITY,'','Error Occurred while updating on Object: '+objectSelected+'Error:'+errorMsg,'', '', '');
                }
                else{   //success 
                    errorMsg='Success:All records are updated successfully';
                    Core_MDF_ExtendedDataTable_Controller.sendEmailOnExcpetion(UserInfo.getUserEmail(),objectSelected,errorMsg);   
                }
            }
            catch(Exception e) {
              if(e!=null){  //log for email failure scenario
                  Core_Log_Entry.logEntryWithDetails(Core_MDF_ExtendedDataTable_Controller.ORIGIN, Core_MDF_ExtendedDataTable_Controller.PROJECT,'',Core_MDF_ExtendedDataTable_Controller.INFOSEVERITY,'','Error Occurred While sending email to User Email : '+ UserInfo.getUserEmail()+'while updating Object:'+objectSelected+'Error:'+ e.getMessage()+ ', Stack trace: '+e.getStackTraceString(),'', '', '');
              }
            }            
        } 
}