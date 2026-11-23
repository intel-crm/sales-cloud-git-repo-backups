public without sharing class Core_MDF_ClmRecoveryHoldRemoveBatch implements Database.Batchable<sObject>, Database.Stateful,Core_MDF_BatchSchedulerInterface {
	public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public List<PartnerFundClaim> finalClaimList = new List<PartnerFundClaim>();
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr, string accounts)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtType = string.valueOf(parmValueMap.get('bgtType'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                string accounts = string.valueOf(parmValueMap.get('accounts'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtType,qtrYr,accounts);
            }
            else if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtTypes, string qtrYr, string accounts,string regions,string source,boolean isRecReq_RecvryDone,boolean isPreSelClaim_RecvryDone)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtTypes = string.valueOf(parmValueMap.get('bgtTypes'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                string accounts = string.valueOf(parmValueMap.get('accounts'));
                string regions = string.valueOf(parmValueMap.get('regions'));
                string source = string.valueOf(parmValueMap.get('source'));
                boolean isRecReq_RecvryDone = Boolean.valueOf(parmValueMap.get('isRecReq_RecvryDone'));
                boolean isPreSelClaim_RecvryDone = Boolean.valueOf(parmValueMap.get('isPreSelClaim_RecvryDone'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtTypes,qtrYr,accounts,regions,source,isRecReq_RecvryDone,isPreSelClaim_RecvryDone);
            }
        	else if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtType = string.valueOf(parmValueMap.get('bgtType'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtType,qtrYr);
            }
        return des_Obj;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        //Query to get the partnership score records for which the recoveries have to be done 
        String query1 = 'select id,Core_MDF_Recovery_Hold_Ind__c,Core_MDF_Program__c from PartnerFundClaim '+ 'Where Core_MDF_Recovery_Hold_Ind__c = true ';
            //'and Core_MDF_Program__c = :program ';
        String query2 = '';
        
        return Database.getQueryLocator(String.escapeSingleQuotes(query1+query2));  
    }
    
    // process each batch of records
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> PFCList) {
        list<PartnerFundClaim> clmlst = new list<PartnerFundClaim>();
        System.debug('testAMeyPFCLIST '+PFCList);
        for(PartnerFundClaim claim: PFCList){
            claim.Core_MDF_Recovery_Hold_Ind__c = false;
            clmlst.add(claim);
        }
        
        finalClaimList.addAll(clmlst);
        System.debug('testAmeyfinalClaimList '+finalClaimList);
    }
    
    
    public void finish(Database.BatchableContext bc) {
          
    }
}