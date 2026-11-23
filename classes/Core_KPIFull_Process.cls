/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_KPIFull_Process
Version     : 1.0 
Created Date: 25 JAN 2021
Function    : Utility methods to handle Full Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             01/25/2021              Original Version

*****************************************************************************************************************************************************************************************************/

public class Core_KPIFull_Process implements Queueable {
    
    private List<Core_KPI_Staging__c> newRec = new List<Core_KPI_Staging__c>();
    List<Core_KPI_Staging__c> KPIAllFailure = new List<Core_KPI_Staging__c>();
    
    public Core_KPIFull_Process(List<Core_KPI_Staging__c> recordstoInsert) {
        newRec = recordstoInsert;
    }
    
	public void execute(QueueableContext queCont) {
        try{
            system.debug('newRec-'+newRec.size());
            List<Core_Oppty_KPI_New__c> oppKPIList = new List<Core_Oppty_KPI_New__c>();
            
            ////////////////////////////Governor Limits query more than 50,000 and deletion more than 10,000///////////////
            //deleteOldKPI();
            System.debug('Soql Statements Limit: ' + String.valueOf(Limits.getLimitQueryRows())); 
            List<Core_Oppty_KPI_New__c> OppKisDelList = [select id from Core_Oppty_KPI_New__c limit 49999];
            if(OppKisDelList.size()>0){
               delete OppKisDelList;
            }
        	//OppKisDelList.size()>0;
            for(Core_KPI_Staging__c ks: newRec){
                if(ks.Core_Begin_Of_File__c || ks.Core_End_Of_File__c){
                    continue;
                }
                else{
                    Core_Oppty_KPI_New__c oppKPIObj = new Core_Oppty_KPI_New__c();
                    
                    oppKPIObj.Core_KPI_Achieved__c = ks.Core_KPI_Achieved__c;
                    oppKPIObj.Core_KPI_Opportunity__c = ks.Core_Opportunity_ID__c;
                    oppKPIObj.Core_KPI_Record_Id__c = ks.Core_KPI_Record_ID__c;
                    oppKPIObj.Core_KPI_Threshold_Met__c = ks.Core_Threshold_Met__c;
                    oppKPIObj.Core_KPI_Threshold_Req__c = ks.core_kpi_threshold_req__c;
                    oppKPIObj.Core_Opp_KPI_Add_Date__c = ks.core_opp_kpi_add_date__c;
                    oppKPIObj.Core_Opp_KPI_Type__c = ks.Core_KPI_Type__c;
                    oppKPIObj.Core_Opportunity_Product_Id__c = ks.core_opp_kpi_product__c;
                    oppKPIObj.Core_Opp_KPI_Product__c = ks.core_opp_kpi_product__c;
                    oppKPIObj.Core_Batch_Time__c = ks.Core_Batch_Time__c;
                    oppKPIObj.Name = ks.Core_KPI_Name__c;
                    oppKPIList.add(oppKPIObj);        
                }
            }
            if(oppKPIList.size()>0){
                integer count = 0;
                integer i=1	;
                List<Core_KPI_Staging__c> ksListStatus = new List<Core_KPI_Staging__c>();
                Database.SaveResult[] srr = database.insert(oppKPIList,false);
                for (Database.SaveResult sr : srr) {
                    if (sr.isSuccess()) {
                        ++count;
                        Core_KPI_Staging__c kobj = new Core_KPI_Staging__c();
                        kobj.id = newRec[i].id;
                        kobj.Core_Status__c = 'Success';
                        ksListStatus.add(kobj);
                    }
                    else if (!sr.isSuccess()){
                        // DML operation failed
                        Core_KPI_Staging__c kobjFailed = new Core_KPI_Staging__c();
                        kobjFailed.id = newRec[i].id;
                        kobjFailed.Core_Status__c = 'Failure';
                        ksListStatus.add(kobjFailed);
                    }
                    i++;
                }
                system.debug('kslistupdate--'+ksListStatus);
                update ksListStatus;
                
                Core_KPI_Staging__c ksStatus = [select id,Core_Status__c from Core_KPI_Staging__c 
                                                where Core_Batch_ID__c =: newRec[0].Core_Batch_ID__c
                                                and Core_End_Of_File__c = true];
                if(ksStatus !=null){
                    if(newRec.size() == (count+2)){
                        ksStatus.Core_Status__c = 'Success';
                    }
                    else{
                        ksStatus.Core_Status__c = 'Failure';
                    }
                    update ksStatus; 
                }
            }
            else{
                for(Core_KPI_Staging__c ks: [select id,Core_Status__c from Core_KPI_Staging__c where id in: newRec]){
                    system.debug('newrec');
                    ks.Core_Status__c = 'Failure';
                    KPIAllFailure.add(ks);
                }
                update KPIAllFailure;
            }
        }
        catch(exception e){
            system.debug('**exception** -->'+ e);
            system.debug('**exception line** -->'+e.getLineNumber());
            for(Core_KPI_Staging__c ks: [select id,Core_Status__c from Core_KPI_Staging__c where id in: newRec]){
                    ks.Core_Status__c = 'Failure';
                    KPIAllFailure.add(ks);
                }
                update KPIAllFailure;
        }
    }
    /*public static void deleteOldKPI(){
        List<Core_Oppty_KPI_New__c> OppKisDelList = [select id from Core_Oppty_KPI_New__c limit 4999];
        Integer count = OppKisDelList.size();
        
        if(OppKisDelList.size()<10000){   
            delete OppKisDelList;
            //count = count-10000;
       
        }
        else{
            
        }
    }*/
}