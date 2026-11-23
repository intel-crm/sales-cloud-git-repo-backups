@isTest
public without sharing class Sales_ContractStatusUpdate {
    /*private static final string FAILED = 'Failed';
    private static final string RENEWAL_FAILED = 'Renewal Failed';
    private static final string COMPLETED = 'Completed';
    private static final string RENEWAL_COMPLETED = 'Renewal Completed';
    private static final string QUEUED  ='Queued';
    private static final string INPROGRESS ='In Progress';
    private static final string IN_PROGRESS = 'InProgress';
    @AuraEnabled
    public static String updateStatus(Id RecordId){
        String record=RecordId+'::RenewContract';
        List<Contract> conList=new List<Contract>();
        List<SBQQ__RecordJob__c> recordjobList=new List<SBQQ__RecordJob__c>();
        SBQQ__RecordJob__c recordjob= new SBQQ__RecordJob__c();
        recordjobList =[select id,SBQQ__RecordId__c,  SBQQ__JobDetails__c, SBQQ__JobStatus__c from SBQQ__RecordJob__c where SBQQ__RecordId__c = : record order by LastModifiedDate desc limit 1];
        if(recordjobList.size()>0){
            recordjob=recordjobList[0];
        }
        String Status='';
        for(Contract con:[Select id,Contract_Status__c,Sales_Comments__c,SBQQ__RenewalQuoted__c from Contract where id=:RecordId]){
            if(con.SBQQ__RenewalQuoted__c==true && recordjob.SBQQ__JobStatus__c==COMPLETED && con.Contract_Status__c==RENEWAL_COMPLETED && recordjob!=null){
                Status='Renewal already completed';  
            }
            else if(con.SBQQ__RenewalQuoted__c==true){
                if(recordjob!=null && recordjob.SBQQ__JobStatus__c==FAILED ){
                    con.Contract_Status__c=RENEWAL_FAILED;
                    con.Sales_Comments__c=recordjob.SBQQ__JobDetails__c;
                    con.SBQQ__RenewalQuoted__c=false;
                }
                else if(recordjob!=null && recordjob.SBQQ__JobStatus__c==COMPLETED ){
                    con.Contract_Status__c=RENEWAL_COMPLETED;
                    con.Sales_Comments__c='';
                }
                else if(recordjob!=null && (recordjob.SBQQ__JobStatus__c==QUEUED || recordjob.SBQQ__JobStatus__c==INPROGRESS)){
                    con.Contract_Status__c=IN_PROGRESS;
                    con.Sales_Comments__c='';
                }
                else if(recordjob==null || recordjob.SBQQ__JobStatus__c==''){
                    con.Contract_Status__c=IN_PROGRESS;
                    con.Sales_Comments__c='';
                }
                Status=con.Contract_Status__c;
                conList.add(con);
            }
            else if(con.SBQQ__RenewalQuoted__c==false){
                Status='Renewal False';
            }
        }
        try{	
            if(conList.size()>0){
                update conList;
            }
        }catch (DmlException ex) {	
            throw new AurahandledException('' + ex.getDmlMessage(0));
        }
        catch (Exception ex) {	
            throw new AurahandledException('' + ex.getMessage());
        }
        return Status;        
    }*/
}