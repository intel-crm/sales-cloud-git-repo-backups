global class PSG_BatchUploadFile implements Database.Batchable<String>, Database.Stateful{
    global Integer totalSize;
    global Integer currentRow = 1;
    global Integer eachSize = 30;
    global Integer startPoint;
    global Integer endPoint;
    global Boolean bypassBatch;
    global String firstLine;
    Boolean isSingleObjectLoad;
    Boolean isMultiObjectLoad;
    List<String> priceBookIdList = new List<String>();
    Map<String,String> pbMap = new Map<String,String>();
    Map<String,Set<String>> requiredFieldsMap = new Map<String,Set<String>>();
    //variables
    global Integer baseNumber = 0;
    global Integer batchSize= 0;
    global String quoteNumber;
    global Integer successCount = 0;
    global Integer totalCount = 0;
    global String objectName;
    global Id recordId;
    global List<String> lstCSVLines;
    global Map<Integer,String> rowErrorMap = new Map<Integer,String>();
    global List<String> columnHeaderNamesList = new List<String>();
    global core_cpq_bulk_upload_batch__c bulkUploadRecord = new core_cpq_bulk_upload_batch__c();
    global Set<Integer> invalidRowSet = new Set<Integer>();
    global Integer lastRowToBeProcessed = 0;
    global String originalObjectName;
    global List<Map<String,String>> csvDataMapList = new List<Map<String,String>>();
    global List<PSG_UploadFile.columnsWrapper> columnsWrapperList = new List<PSG_UploadFile.columnsWrapper>();
    //variables
    
    public PSG_BatchUploadFile(List<String> lstCSVLines,Boolean isSingleObjectLoad,Boolean isMultiObjectLoad, String objectName,Id recordId,List<String> priceBookIdList,Map<String,String> pbMap,String originalObjectName,Map<String,Set<String>> requiredFieldsMap){
        this.lstCSVLines = lstCSVLines;        
        this.isSingleObjectLoad = isSingleObjectLoad;
        this.isMultiObjectLoad = isMultiObjectLoad;
        this.objectName = objectName;
        this.recordId = recordId;
        this.priceBookIdList = priceBookIdList;
        this.pbMap = pbMap;
        this.originalObjectName = originalObjectName;
        
        this.totalSize = lstCSVLines.size();
        this.startPoint = 0;
        this.endPoint = 1;
        this.bypassBatch = false;
    }
    public Iterable<String> start(Database.BatchableContext bc){
        List<String> lstCSVLinesTemp = new List<String>(lstCSVLines);
        if(lstCSVLinesTemp.size() > 0){
            lstCSVLinesTemp.remove(0);
        }
        return lstCSVLinesTemp;
    }
    public void execute(Database.BatchableContext bc, List<String> lstCSVLinesTemp){
        SBQQ.TriggerControl.disable();//for cp-quotes bulk upload  TWC3133-841 added by ranjit
        //List<String> listToProcess = new List<String>();
        firstLine=String.escapeSingleQuotes(firstLine);
        lstCSVLinesTemp.add(0,firstLine);
        PSG_UploadFile.bulkMode = true;
        try{
            if(currentRow != 1){
                baseNumber = baseNumber + batchSize;
                PSG_UploadFile.baseNumber = baseNumber; 
            }
            currentRow = currentRow + 1;        
            PSG_UploadFile.getObjectList(lstCSVLinesTemp,isSingleObjectLoad,isMultiObjectLoad,objectName,recordId,
                                         priceBookIdList,pbMap,originalObjectName,requiredFieldsMap);
            rowErrorMap.putAll(PSG_UploadFile.rowErrorMap);
            PSG_UploadFile.rowErrorMap= new Map<Integer,String>();
            successCount = successCount + PSG_UploadFile.successCount; 
            totalCount = totalCount + PSG_UploadFile.totalCount; 
            lastRowToBeProcessed = lastRowToBeProcessed + PSG_UploadFile.lastRowToBeProcessed;   
            csvDataMapList.addAll(PSG_UploadFile.csvDataMapList);  
            invalidRowSet.addAll(PSG_UploadFile.invalidRowSet); 
            
            quoteNumber = PSG_UploadFile.quoteNumber;
            PSG_UploadFile.quoteNumber = '';
            
            columnHeaderNamesList = PSG_UploadFile.columnHeaderNamesList;
            PSG_UploadFile.columnHeaderNamesList = new List<String>();
            
            bulkUploadRecord = PSG_UploadFile.bulkUploadRecord;
            PSG_UploadFile.bulkUploadRecord = new core_cpq_bulk_upload_batch__c(); 
            
            columnsWrapperList = PSG_UploadFile.columnsWrapperList;
            PSG_UploadFile.columnsWrapperList = new List<PSG_UploadFile.columnsWrapper>();   
            
            
            startPoint = endPoint;
            if((endPoint + 30) >= totalSize){
                endPoint = totalSize;
                bypassBatch = true;
            }else{
                endPoint = endPoint + 30;
            }
        }catch(Exception e){
            PSG_Utility.logError(e);
        }
    }
    public void finish(Database.BatchableContext bc){
        SBQQ.TriggerControl.enable();//for cp-Quotes bulk upload TWC3133-841 added by ranjit
        PSG_UploadFile.sendMail(successCount,totalCount,objectName,recordId,quoteNumber,
                                lstCSVLines,rowErrorMap,columnHeaderNamesList,bulkUploadRecord,
                                invalidRowSet,lastRowToBeProcessed,originalObjectName,
                                csvDataMapList,columnsWrapperList);
    }
}