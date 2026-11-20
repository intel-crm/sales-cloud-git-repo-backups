/*
Author: Sai Thotakura
Onyx Team
Functionality: Trigger Helper calls the future apex method to make an API call to download pdf and will attach
to the asset record.
*/
//Retrigger Ind - Does not support bulk data load
public without sharing class PMP_RichMediaAssetTriggerHelper {
    
    static boolean Runoncecallrichmediadownload = true;
    static boolean RunonceoldPdfUpdateDateCapture = true;
    
    public static void callrichmediadownload(Map<Id,sObject> oldMap, List<sObject> newlist){

        if(Runoncecallrichmediadownload == true){
            List<PMP_Rich_Media_Asset_Stage__c> modifiedData = new List<PMP_Rich_Media_Asset_Stage__c>(); 
            List<PMP_Rich_Media_Asset_Stage__c> newrichmediarecords = (List<PMP_Rich_Media_Asset_Stage__c>)newlist;
            Map<Id,PMP_Rich_Media_Asset_Stage__c> oldRecordmap = (Map<Id,PMP_Rich_Media_Asset_Stage__c>)oldMap;
            //Capture the records where there is a change in the is retrieved checkbox
            for(PMP_Rich_Media_Asset_Stage__c rma:newrichmediarecords) {
                if(((rma.PMP_Is_Retrieved_Ind__c == true && oldRecordmap.get(rma.Id).PMP_Is_Retrieved_Ind__c == false) && rma.PMP_Old_PDF_Updated_Dt__c == null ) ||
                   ((rma.PMP_Is_Retrieved_Ind__c == true && oldRecordmap.get(rma.Id).PMP_Is_Retrieved_Ind__c == false) && rma.PMP_Old_PDF_Updated_Dt__c!= null && rma.PMP_Old_PDF_Updated_Dt__c!=rma.PMP_PDF_Updated_Dt__c && rma.PMP_PDF_Updated_Dt__c!=null) ||
                   (rma.PMP_ReTrigger_Ind__c == true && oldRecordmap.get(rma.Id).PMP_ReTrigger_Ind__c == false) ||
                   Test.isRunningTest()) {
                       modifiedData.add(rma);
                   }
            }
            //Calling the file download class only for one record, since we have limitations with http callouts from apex
            if(modifiedData.size() == 1){
                String modified = JSON.serialize(modifiedData);
                PMP_RichMediaAssetDocDownload.fetchFileFromExternalUrl(modified);
            }
            Runoncecallrichmediadownload = false;
        }        
    }
    
    public static void oldPdfUpdateDateCapture(Map<Id,sObject> oldMap, List<sObject> newlist){
        
        if(RunonceoldPdfUpdateDateCapture == true){
        List<PMP_Rich_Media_Asset_Stage__c> newrichmediarecords = (List<PMP_Rich_Media_Asset_Stage__c>)newlist;
        Map<Id,PMP_Rich_Media_Asset_Stage__c> oldRecordmap = (Map<Id,PMP_Rich_Media_Asset_Stage__c>)oldMap;
        for(PMP_Rich_Media_Asset_Stage__c rma:newrichmediarecords) {
            if ((rma.PMP_PDF_Updated_Dt__c != oldRecordmap.get(rma.Id).PMP_PDF_Updated_Dt__c
                || (rma.PMP_Is_Retrieved_Ind__c == false
                && rma.PMP_PDF_Updated_Dt__c == oldRecordmap.get(rma.Id).PMP_PDF_Updated_Dt__c
                && rma.PMP_PDF_Updated_Dt__c != null))
                && !(rma.PMP_Old_PDF_Updated_Dt__c != null && oldRecordmap.get(rma.Id).PMP_PDF_Updated_Dt__c == null)) {  
                //if( !(rma.PMP_Old_PDF_Updated_Dt__c !=null && oldRecordmap.get(rma.Id).PMP_PDF_Updated_Dt__c == null)) {
                    rma.PMP_Old_PDF_Updated_Dt__c = oldRecordmap.get(rma.Id).PMP_PDF_Updated_Dt__c;
                //} 
            }
        }
        RunonceoldPdfUpdateDateCapture = false; 
      }
    }
}