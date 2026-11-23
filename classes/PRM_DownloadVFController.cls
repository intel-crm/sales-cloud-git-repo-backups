public without sharing class PRM_DownloadVFController {

    

    public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>> salesWrapperVF{get;set;}
    public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> trainingWrapperVF{get;set;}
    public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> opidtrainingWrapperVF{get;set;}
    public boolean isExport{get; set;}
    public string dataType{get; set;}
    public string contentTypeVar{get; set;}
    public PRM_DownloadVFController(){
        isExport = false;
        Map<String, String> paramMap = ApexPages.currentPage().getParameters();
        dataType = paramMap.get('dataType');
        if(dataType == 'salesData' ){
            salesWrapperVF = fetchSalesWrapperVF(paramMap);
        }/*else if(dataType == 'trainingsData') {
            trainingWrapperVF = fetchTrainingWrapperVF(paramMap);
        }else if(dataType == 'opidTrainingsData'){
            opidtrainingWrapperVF = fetchOPIDTrainingWrapperVF(paramMap);
        }*/
    }

    public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>> fetchSalesWrapperVF(Map<String, String> paramMap){
        Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>> finalMap = new Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>>();
        try{
            List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> lst  =new List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>();
            contentTypeVar = 'text/html';
            lst = PRM_External_Objects_Data.getExtSalesDetails1(
                paramMap.containsKey('invoiceNumber')?paramMap.get('invoiceNumber'):null,null,null,null,0,
                paramMap.containsKey('startDate')?paramMap.get('startDate'):null,
                paramMap.containsKey('endDate')?paramMap.get('endDate'):null,true,null
            ).wrap;
            System.debug('>>>>'+lst.size());
            if(lst.isEmpty()){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else if(lst.size() > Integer.valueOf(Label.PRM_DashboardDownloadLimit)){
                System.debug('inside wanted'+lst.size());
                //user usr= [Select Contact.AccountId from user where id = :userinfo.getuserid()];
                //database.executeBatch(new CreateFileAndAttachToRecord(lst,'report', usr.contact.accountId!= null? usr.contact.accountId : '001o000000O6LEdAAN'), 200);
                isExport = true;
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
                System.debug('>>>>finalMap'+finalMap.keySet());
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Info,system.label.PRM_Download_confirm_message));   
                
            }else{
                contentTypeVar = 'application/vnd.ms-excel#report.xls';
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
            }
            System.debug('>>>>'+finalMap.keySet());
        }catch (Exception ex) {
            System.debug(LoggingLevel.info,'>>> ex.getMessage()'+ ex.getMessage());
            if(ex.getMessage().contains('Apex CPU time limit exceeded')){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, ex.getMessage()));   
            }
        }
        
        return finalMap;
    }

    /*public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> fetchTrainingWrapperVF(Map<String, String> paramMap){
        Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> finalMap = new Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>>();
        try{
            List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lst  =new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
            contentTypeVar = 'text/html';
            lst = PRM_External_Objects_Data.getExternalTrainingDetails(
                0,0,0,
                paramMap.containsKey('startDate')?paramMap.get('startDate'):null,
                paramMap.containsKey('endDate')?paramMap.get('endDate'):null
            ).wrapTraining;
            System.debug('>>>>'+lst.size());
            if(lst.isEmpty()){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else if(lst.size() > Integer.valueOf(Label.PRM_DashboardDownloadLimit)){
                System.debug('inside wanted'+lst.size());
                //user usr= [Select Contact.AccountId from user where id = :userinfo.getuserid()];
                //database.executeBatch(new CreateFileAndAttachToRecord(lst,'report', usr.contact.accountId!= null? usr.contact.accountId : '001o000000O6LEdAAN'), 200);
                isExport = true;
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Info,system.label.PRM_Download_confirm_message));   
                
            }else{
                contentTypeVar = 'application/vnd.ms-excel#report.xls';
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
            }
            System.debug('>>>>'+finalMap.keySet());
        }catch (Exception ex) {
            System.debug(LoggingLevel.info,'>>> ex.getMessage()'+ ex.getMessage());
            if(ex.getMessage().contains('Apex CPU time limit exceeded')){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, ex.getMessage()));   
            }
        }
        
        return finalMap;
    }

    public Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> fetchOPIDTrainingWrapperVF(Map<String, String> paramMap){
        Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> finalMap = new Map<Integer,List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>>();
        try{
            List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lst  =new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
            contentTypeVar = 'text/html';
            lst = PRM_External_Objects_Data.getExternalOPIDTrainingDetails1(
                paramMap.containsKey('startDate')?paramMap.get('startDate'):null,
                paramMap.containsKey('endDate')?paramMap.get('endDate'):null,0,true,true
            ).wrapopidTraining;
            System.debug('>>>>'+lst.size());
            if(lst.isEmpty()){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else if(lst.size() > Integer.valueOf(Label.PRM_DashboardDownloadLimit)){
                System.debug('inside wanted'+lst.size());
                //user usr= [Select Contact.AccountId from user where id = :userinfo.getuserid()];
                //database.executeBatch(new CreateFileAndAttachToRecord(lst,'report', usr.contact.accountId!= null? usr.contact.accountId : '001o000000O6LEdAAN'), 200);
                isExport = true;
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Info,system.label.PRM_Download_confirm_message));   
                
            }else{
                contentTypeVar = 'application/vnd.ms-excel#report.xls';
                if(lst.size() > 10000){
                    List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> lstTemp;
                    for(Integer i = 0 ; i < (lst.size() / 10000)+1 ; i++){
                        lstTemp = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
                        for(Integer j=(i*10000);(j<(i*10000)+10000) && j<lst.size() ; j++){
                            lstTemp.add(lst.get(j));
                        }
                        finalMap.put(i,lstTemp);
                    }
                }else{
                    finalMap.put(0,lst);
                }
            }
            System.debug('>>>>'+finalMap.keySet());
        }catch (Exception ex) {
            System.debug(LoggingLevel.info,'>>> ex.getMessage()'+ ex.getMessage());
            if(ex.getMessage().contains('Apex CPU time limit exceeded')){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Too Much Data to process. please add some filters'));   
            }else {
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, ex.getMessage()));   
            }
        }
        
        return finalMap;
    }*/

    public PageReference performConfirmAction() {
        // System.debug('>>>>salesWrapperVF'+salesWrapperVF.size()); 
        // System.debug('>>>>salesWrapperVF'+isExport); 
        user usr= [Select Contact.AccountId from user where id = :UserInfo.getUserId()];
        if(usr.contactId != null){
            CreateFileAndAttachToRecord batchRec;
            if(dataType == 'salesData'){
                List<String> columnsForCSV = new List<String>{
                    'account_number',
                    'invoice_number',
                    'form_factor',
                    'invoice_date',
                    'form_factor',
                    'productOrderingCode',
                    'productCodeNumber',
                    'sales_out_units',
                    'distributor_name',
                    'sales_type',
                    'Measurement_Period'
                };
                batchRec = new CreateFileAndAttachToRecord(columnsForCSV,salesWrapperVF,'SalesDetails'+Date.today()+'.xls', usr.contactId,'salesData');
            }else if(dataType == 'trainingsData'){
                List<String> columnsForCSV = new List<String>{
                    'account_number',
                    'contact_name',
                    'training_id',
                    'training_name',
                    'training_credits',
                    'training_completion_date',
                    'Measurement_Period'
                };
                batchRec = new CreateFileAndAttachToRecord(columnsForCSV,trainingWrapperVF,'TrainingDetails'+Date.today()+'.xls', usr.contactId,'trainingsData');
            }else if(dataType == 'opidTrainingsData'){
                List<String> columnsForCSV = new List<String>{
                    'account_number',
                    'contact_name',
                    'training_id',
                    'training_name',
                    'training_completion_date',
                    'training_credits',
                    'Measurement_Period'
                };
                batchRec = new CreateFileAndAttachToRecord(columnsForCSV,opidtrainingWrapperVF,'OPIDTariningDetails'+Date.today()+'.xls', usr.contactId, 'trainingsData');
            }
            database.executeBatch(batchRec, 200);
        }
        return null;
    }

}