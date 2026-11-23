public inherited sharing class Core_MDF_UploadBulkEscalation {

    @AuraEnabled
    public static list<Core_MDF_Escalation__c> readCSVFile(Id idContentDocument){
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                escObj.Core_MDF_Escalation_Name_txt__c = csvRowData[0]; // accName
                escObj.Core_MDF_Root_Cause_nm__c = csvRowData[1];
                escObj.Core_MDF_Total_Dollar_Impact_amt__c = Decimal.valueOf(csvRowData[2]) ;
                //escObj.Core_MDF_Co_Marketing_Activity_id__c = csvRowData[3];               
                lstEscalationsToInsert.add(escObj);
            }
            
            try{    
                if(!lstEscalationsToInsert.isEmpty()) {
                    //insert lstEscalationsToInsert;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
        }
        return lstEscalationsToInsert;    
    }



    @AuraEnabled
    public static List<Core_MDF_Escalation__c> saveFile(Id idContentDocument) {
        // Decoding base64Data
        ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
       list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
        list<Core_MDF_Escalation__c> lstEscalationsToInsert = new list<Core_MDF_Escalation__c>();
        
       for(Integer i = 1; i < lstCSVLines.size(); i++){
                Core_MDF_Escalation__c escObj = new Core_MDF_Escalation__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                escObj.Core_MDF_Escalation_Name_txt__c = csvRowData[0]; // accName
                escObj.Core_MDF_Root_Cause_nm__c = csvRowData[1];
                //escObj.Core_MDF_Total_Dollar_Impact_amt__c = Decimal.valueOf(csvRowData[2]) ;
                //escObj.Core_MDF_Co_Marketing_Activity_id__c = csvRowData[3];               
                lstEscalationsToInsert.add(escObj);
            }
            
       
        // inserting file
        // ContentVersion cv = new ContentVersion();
        // cv.Title = strFileName;
        // cv.PathOnClient = '/' + strFileName;
        // cv.FirstPublishLocationId = idParent;
        // cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // cv.IsMajorVersion = true;
        //Insert cv;
        return lstEscalationsToInsert;  
    }

    // @AuraEnabled
    // public static list<contentversion> releatedFiles(Id idParent){
    //     list<id> lstConDocs = new list<id>();
    //     for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:idParent]) {
    //         lstConDocs.add(cntLink.ContentDocumentId);
    //     }
    //     if(!lstConDocs.isEmpty()) {
    //         return [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs];
    //     }
    //     else {
    //         return null;
    //     }
     
    // }
}