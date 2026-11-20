public with sharing class Product_DeactivationAndLogEntry implements Database.Batchable<sObject>, Database.Stateful {
    
    public string ipaasLoadId;
    public string salesStr = Product_Staging_StaticConstants.sales;
    public Integer runCount = 0;
    public Integer totalRecordCount=0;
    public boolean stopExecution = false;
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    public Product_DeactivationAndLogEntry(string ipaasId){
        this.ipaasLoadId = ipaasId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryStr;
        
        if((mapFunctionalityNameTriggerExecution.containsKey('ExecuteProduct_DeactivationAndLogEntry') && mapFunctionalityNameTriggerExecution.get('ExecuteProduct_DeactivationAndLogEntry').Core_Active__c) || test.isRunningTest()){
            queryStr = 'SELECT Id,Name, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Status__c,Core_Product_Name_EPM_ID__c,IsActive,Core_iPaaS_Load_ID__c,Core_Unique_ID__c FROM Product2 WHERE Core_iPaaS_Load_ID__c != :ipaasLoadId  AND Core_Product_Org__c =: salesStr AND IsActive = true';
        } else {
            queryStr = '';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> deactivationPrdLst){
        try{
            
            List<Product2> deactivatedProdList = new List<Product2>();
            List<Product_Log_Entry__c> prodLogEntriesList = new List<Product_Log_Entry__c>();
            
            runCount++;
            //System.debug(runCount);
            if(Label.limitProductDeactivationSize == 'true'){
                stopExecution = (deactivationPrdLst.size() > Integer.valueOf(label.UCD_Product_Deactivation_Threshold) || runCount > 1);
                totalRecordCount += deactivationPrdLst.size();
            }
            
            if (!deactivationPrdLst.isEmpty() && !stopExecution) {
                for(Product2 prd : deactivationPrdLst){
                    prd.IsActive = false;
                    deactivatedProdList.add(prd);
                    prodLogEntriesList.add(new Product_Log_Entry__c(Message__c=prd.Core_Product_Name_EPM_ID__c+'_'+'loadIdDeactivation',Method_Name__c='Product_DeactivationAndLogEntry execute',Class_Name__c='Product_DeactivationAndLogEntry',Ipaas_LoadId__c=ipaasLoadId,EPM_Id__c=prd.Core_Product_Name_EPM_ID__c,Logging_Type__c='Load_Id_Deactivation',Product_Name__c=prd.Name,Unique_ID__c=prd.Core_Unique_ID__c));
                    
                }
            }
            
            //update Product2 with IsActive__c = false
            Database.update(deactivatedProdList, false); //capture log entry and check size zero on log Entry
            /*if(prodLogEntriesList.size()>0){
                Database.update(deactivatedProdList, false); //capture log entry and check size zero on log Entry
                for (Product2 deactivatedProd : deactivatedProdList) {
                    prodLogEntriesList.add(new Product_Log_Entry__c(Message__c=deactivatedProd.Core_Product_Name_EPM_ID__c+'_'+'loadIdDeactivation',Method_Name__c='Product_DeactivationAndLogEntry execute',Class_Name__c='Product_DeactivationAndLogEntry',Ipaas_LoadId__c=deactivatedProd.Core_iPaaS_Load_ID__c,EPM_Id__c=deactivatedProd.Core_Product_Name_EPM_ID__c,Logging_Type__c='Load_Id_Deactivation',Product_Name__c=deactivatedProd.Name,When__c=System.Now()));
                }*/
                if(!prodLogEntriesList.isEmpty()){
                    insert prodLogEntriesList;
                }
            //}
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasLoadId,'Product_DeactivationAndLogEntry',null,null);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        //notify user on records failed for upsertion
        
        if((mapFunctionalityNameTriggerExecution.containsKey('AllowproductDeativationEmail') && mapFunctionalityNameTriggerExecution.get('AllowproductDeativationEmail').Core_Active__c && stopExecution) || test.isRunningTest()) {
            Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
            String[] toAddresses  = Label.ProductSupportEmail.split(';');
            mail.setToAddresses(toAddresses);
            mail.setSubject('Product Integration: Product Deactivation was not processed for  '+totalRecordCount+' Records');
            String body = 'Hi,<br><br>';
            body += 'This is to notify that Product deactivation job Product_DeactivationAndLogEntry class has failed to execute. <br>';
            body += '<b> Total Records submitted for Deactivation - ' + totalRecordCount + '</b>, <br>';
            body += 'For IpaasLoadId - ' + ipaasLoadId+'.';
            mail.setHtmlBody(body);
            mail.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage []{mail},false);
        }
        
        
        Database.executeBatch(new Product_CreateLogEntriesBatch(ipaasLoadId),2000);
    }
}