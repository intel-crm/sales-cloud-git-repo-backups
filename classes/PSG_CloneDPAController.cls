/****************************************************************************************************
Apex Class Name : PSG_CloneDPAController
Created Date    : 6/4/2021 
Function        : Apex Controller for Cloning DPA and ALN
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ---------------------------------------------------------------------------------------------------                
* Pooja                      6/4/2021                   Created
*****************************************************************************************************/

public without sharing class PSG_CloneDPAController {
    /************************************************************************************************************
    *Method Name : doClone
    *Created Date: 6/4/2021
    *Author: Pooja
    *Description : Helper class to clone Dpa/Aln and its children sObjects based on the action performed.
    ************************************************************************************************************/
    @AuraEnabled
    public static GlobalVariables doClone (String sObjectId,String action) 
    {        
        sObjectId=String.escapeSingleQuotes(sObjectId);
        action=String.escapeSingleQuotes(action);
        GlobalVariables globalVar = new GlobalVariables();
        List<core_cpq_dpa_aln__c> originalDpaAln;
        List<core_cpq_dpa_aln__c> originalDpaAlnForValidation;
        core_cpq_dpa_aln__c clonedDpaAln;
        List<Database.SaveResult> results= new List<Database.SaveResult>();
        String query;
        String errorMsg = '';
        Id DPARecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
        Id DPALinesRecordTypeId = Schema.SObjectType.core_cpq_dpa_aln_line__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA_Lines').getRecordTypeId();
        Id ALNRecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
        Id ALNLinesRecordTypeId = Schema.SObjectType.core_cpq_dpa_aln_line__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN_Lines').getRecordTypeId();
        List<core_cpq_dpa_aln_line__c> DPALineList = new List<core_cpq_dpa_aln_line__c>();
        Boolean allowClone = true;      
        originalDpaAlnForValidation = [SELECT Id,core_cpq_record_type_identifier__c,core_cpq_change_flag__c,core_cpq_active_quote__c,core_cpq_ship_end_date_dt__c,core_cpq_active_quote__r.core_cpq_active_cb__c from core_cpq_dpa_aln__c WHERE Id=:sObjectId];
        if(!originalDpaAlnForValidation.isEmpty() && originalDpaAlnForValidation[0].core_cpq_active_quote__c != null){
            if((originalDpaAlnForValidation[0].core_cpq_change_flag__c!='H' && !(originalDpaAlnForValidation[0].core_cpq_change_flag__c == 'E' && originalDpaAlnForValidation[0].core_cpq_ship_end_date_dt__c== System.today())) && !originalDpaAlnForValidation[0].core_cpq_active_quote__r.core_cpq_active_cb__c){
                if(action =='Replace'){
                    errorMsg = 'ALN cannot be replaced for an inactive quote';  
                }else{
                    errorMsg = originalDpaAlnForValidation[0].core_cpq_record_type_identifier__c +' cannot be cloned for an inactive quote';  
                }
                allowClone = false;
            }    
        }
        
        if(allowClone){ 
            try {
                // Query Dpa_Aln 
                query = String.format(
                       'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
                        new String[] {
                            String.join(
                                new List<String>(
                                   core_cpq_dpa_aln__c.SObjectType.getDescribe().fields.getMap().keySet()
                                ),
                               ','
                            ),
                            String.valueOf(core_cpq_dpa_aln__c.SObjectType),
                            sObjectId
                        }
                );
                //Query and gets results
                originalDpaAln = Database.query(query);
                // Clone the original object. Here you can change anything without affecting the original sObject
                clonedDpaAln = originalDpaAln[0].clone(false, true, false, false);
                if(originalDpaAln[0].core_cpq_record_type_identifier__c == 'DPA'){
                   clonedDpaAln.RecordTypeId = DPARecordTypeId;
                   clonedDpaAln.core_cpq_change_flag__c='N';
                    
                }else if(originalDpaAln[0].core_cpq_record_type_identifier__c == 'ALN'){
                   clonedDpaAln.RecordTypeId = ALNRecordTypeId;
                   clonedDpaAln.core_cpq_change_flag__c='N';
                }
                clonedDpaAln.core_cpq_status_txt__c = 'New';
                clonedDpaAln.OwnerId = userInfo.getUserId();
                clonedDpaAln.core_cpq_replace_aln_txt__c = '';

                if(action =='Replace'){
                   clonedDpaAln.core_cpq_change_flag__c = 'R';
                    clonedDpaAln.core_cpq_replace_aln_txt__c = originalDpaAln[0].core_cpq_dpa_aln_no_nbr__c ;
                }
                for(String fieldName : (Label.PSG_DPAFieldsNull).split(':')){
                    clonedDpaAln.put(fieldName,null);
                }
                
                Database.insert(clonedDpaAln);
                update originalDpaAln[0];
                system.debug('clonedDpaAln'+clonedDpaAln.Name+'cis'+clonedDpaAln.core_cpq_cis__c);
               
            } 
            catch (Exception error) 
            {
               //Create Error Log when an Exception Occurs
               Pricing_Tender_Utility.logError(error);
               globalVar.messageResult = JSON.serialize(error.getMessage());
               globalVar.dpaId = null;
               globalVar.isSuccess = false;
               return globalVar;
            }
               
            // Query DPA_ALN Lines 
            query = String.format(
                'SELECT {0} FROM {1} WHERE core_cpq_cis_no_nbr__c = \'\'{2}\'\' AND core_cpq_dollar_change_flag__c = False',
                new String[] {
                       String.join(
                            new List<String>(
                               core_cpq_dpa_aln_line__c.SObjectType.getDescribe().fields.getMap().keySet()
                            ),
                           ','
                        ),
                        String.valueOf(core_cpq_dpa_aln_line__c.SObjectType),
                        sObjectId
                }
            ); 
                
            try {
                   // Query and clone the children. Here you can change anything without affecting the original sObject
                    for(core_cpq_dpa_aln_line__c originalDpaAlnLines:(List<core_cpq_dpa_aln_line__c>)Database.query(query))
                    {
                        core_cpq_dpa_aln_line__c newDPALine = originalDpaAlnLines.clone(false,true); // deep clone
                        newDPALine.core_cpq_cis_no_nbr__c = clonedDpaAln.Id; //set clonedDpaAln ref
                        if(originalDpaAln[0].core_cpq_record_type_identifier__c == 'DPA'){
                              clonedDpaAln.RecordTypeId= DPALinesRecordTypeId;
                              globalVar.IsDPAALN='DPA';
                        }else if(originalDpaAln[0].core_cpq_record_type_identifier__c == 'ALN'){
                              clonedDpaAln.RecordTypeId = ALNLinesRecordTypeId;
                              globalVar.IsDPAALN='ALN';
                        }
                        for(String fieldName : (Label.PSG_DPALinesFieldsNull).split(':')){
                           newDPALine.put(fieldName,null);
                        }
                        DPALineList.add(newDPALine);
                    }
                    if(!DPALineList.isEmpty())
                    {
                        results=Database.insert(DPALineList,false); 
                    }
                for (Integer i = 0; i < results.size(); i++) {
            		Database.SaveResult sr = results[i];
                    if (!sr.isSuccess()) {
                        String msg = PSG_QuotewithopptyInactive_Batch.getErrorAsString(sr.getErrors());
                        globalVar.isDPALineCloneSuccess=true;
                        globalVar.failedItems.add(new FailedCloneItem(DPALineList[i].core_cpq_quote_line_disty__c,DPALineList[i].core_cpq_quoteline_type__c,msg));    
                    }
                }
                if(!globalVar.failedItems.isEmpty()){
                    PSG_Utility.createCoreLogEntry('PSG_CloneDPAController','doClone',clonedDpaAln.core_cpq_record_type_identifier__c+' Lines Cloning Failed for '+originalDpaAln[0].core_cpq_record_type_identifier__c +'id - '+originalDpaAln[0].id,'Original'+originalDpaAln[0].core_cpq_record_type_identifier__c +'- '+originalDpaAln[0].Name +' Cloned '+clonedDpaAln.core_cpq_record_type_identifier__c+' id - '+clonedDpaAln.id+' Failed DPA Lines- '+globalVar.failedItems,'DPA/ALN Lines','Low',clonedDpaAln.id);
                                           
                }
                
                
            }  
            catch(Exception error) {
               //Create Error Log when an Exception Occurs
               Pricing_Tender_Utility.logError(error);
               globalVar.messageResult = JSON.serialize(error.getMessage());
               globalVar.dpaId = null;
               globalVar.isSuccess = false;
               return globalVar;
            } 
            if(action =='Replace'){
                globalVar.messageResult =   'Replaced ALN successfully';
            }else{
                globalVar.messageResult =  clonedDpaAln.core_cpq_record_type_identifier__c + ' ' + Label.PSG_DPA_Clone_Success_Message;
            }
            globalVar.isSuccess = true;
            globalVar.dpaId = clonedDpaAln.Id; 
        }else{//added
            if(String.isNotBlank(errorMsg)){
                globalVar.messageResult = errorMsg;
            }else{
                globalVar.messageResult = Label.PSG_No_Access_Error_Message;
            }
            globalVar.isSuccess = false;
            globalVar.dpaId = null;
        }
        return globalVar;
    }
   
    public class GlobalVariables 
    {
        @AuraEnabled public String messageResult {get;set;}
        @AuraEnabled public Id dpaId {get;set;}
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public List<PSG_CloneDPAController.FailedCloneItem> failedItems { get; set; }
        @AuraEnabled public Boolean isDPALineCloneSuccess {get;set;}
        @AuraEnabled public String IsDPAALN {get;set;}
        
        public GlobalVariables() {
            this.failedItems = new List<PSG_CloneDPAController.FailedCloneItem>();
        }
    } 
    
     public class FailedCloneItem {
        @AuraEnabled public String QLNumber { get; set; }
        @AuraEnabled public String QLType { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
         
         public FailedCloneItem(){}

        public FailedCloneItem(String QLNumber, String QLType, String errorMessage) {
            this.QLNumber = QLNumber;
            this.QLType = QLType;
            this.errorMessage = errorMessage;
        }
    }
}