public without sharing class Core_MDF_BulkEscalation {

    @InvocableMethod
    public static List<ContentDocumentLink> getDocDetails(List<Core_MDF_Escalation_Batch__c> batchId){
        List<ContentDocumentLink> docList =  [SELECT Id,ContentDocument.Id FROM ContentDocumentLink WHERE LinkedEntityId =: batchId[0].Id];
        Id recordTypeId;
       
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        // getting File Data based on document id 
        ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:docList[0].ContentDocument.Id];
        // split the file data
        list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
        switch on batchId[0].Core_MDF_Escalation_Type__c{
            when 'Claim Case Review Result'{
            recordTypeId= '0121J000000o5cVQAQ';
            lstEscalationsToInsert = readCsvforClaimReviewCaseEscalation(lstCSVLines,recordTypeId,'Claim Case Review Result');
               }
            when 'Budget'{
                recordTypeId= '0121J000000o5cUQAQ';
            lstEscalationsToInsert = readCsvforBudgetEscalation(lstCSVLines,recordTypeId,'Budget');
                }
            when 'Late Claim'{
                recordTypeId= '0121J000000o5cWQAQ';
            lstEscalationsToInsert = readCsvforLateClaimEscalation(lstCSVLines,recordTypeId,'Late Claim');
                }
        }
        try{    
                if(!lstEscalationsToInsert.isEmpty()) {
                    insert lstEscalationsToInsert;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        
        return docList;
    }
    
    public static List<Core_MDF_Escalation__c> readCsvforClaimReviewCaseEscalation(List<String> lstCSVLines,Id recordTypeId,string type){
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                escObj.RecordTypeId = recordTypeId;//Claim Case Review Result   
                escObj.Core_MDF_Escalation_Name_txt__c = csvRowData[0]; // accName
                escObj.Core_MDF_Root_Cause_nm__c = csvRowData[1];
                escObj.Core_MDF_Total_Dollar_Impact_amt__c = Decimal.valueOf(csvRowData[2]) ;
                escObj.Core_MDF_Issue_Description_txt__c = csvRowData[3];
                escObj.Core_MDF_Case_ID_Number_id__c = csvRowData[4];
                escObj.Core_MDF_Claim_Number_id__c = csvRowData[5];
                escObj.Core_MDF_Program_txt__c = csvRowData[6];
                lstEscalationsToInsert.add(escObj);
            }
        return lstEscalationsToInsert;
    }
    
    public static List<Core_MDF_Escalation__c> readCsvforLateClaimEscalation(List<String> lstCSVLines,Id recordTypeId,string type){
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                escObj.RecordTypeId = recordTypeId;//Claim Case Review Result   
                escObj.Core_MDF_Escalation_Name_txt__c = csvRowData[0]; // accName
                escObj.Core_MDF_Root_Cause_nm__c = csvRowData[1];
                escObj.Core_MDF_Total_Dollar_Impact_amt__c = Decimal.valueOf(csvRowData[2]) ;
                escObj.Core_MDF_Issue_Description_txt__c = csvRowData[3];
                escObj.Core_MDF_Co_Marketing_Activity_id__c = csvRowData[4];
                escObj.Core_MDF_Claim_Number_id__c = csvRowData[5];
                escObj.Core_MDF_Program_txt__c = csvRowData[6];
            lstEscalationsToInsert.add(escObj);
            }
        return lstEscalationsToInsert;
    }
    
    public static List<Core_MDF_Escalation__c> readCsvforBudgetEscalation(List<String> lstCSVLines,Id recordTypeId,string type){
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                escObj.RecordTypeId = recordTypeId;//Claim Case Review Result   
                escObj.Core_MDF_Escalation_Name_txt__c = csvRowData[0]; // accName
                escObj.Core_MDF_Root_Cause_nm__c = csvRowData[1];
                escObj.Core_MDF_Total_Dollar_Impact_amt__c = Decimal.valueOf(csvRowData[2]) ;
                escObj.Core_MDF_Issue_Description_txt__c = csvRowData[3];
                escObj.Core_MDF_Budget_ID_Number_id__c = csvRowData[4];
                escObj.Core_MDF_Program_txt__c = csvRowData[5];
                lstEscalationsToInsert.add(escObj);
            }
        return lstEscalationsToInsert;
    }

    
    
}