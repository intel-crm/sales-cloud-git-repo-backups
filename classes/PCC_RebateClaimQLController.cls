public with sharing class PCC_RebateClaimQLController {
    @AuraEnabled(cacheable=true)
    public static QLWrapper getQuoteLineItems() {
        List<Period> qtrList = [SELECT StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType = 'Custom' and Type = 'Quarter' and  StartDate <=today order by StartDate desc LIMIT 2];
         List<SBQQ__QuoteLine__c> qlLinesList = [SELECT Id, Name, Pricing_Product_Nm__c,Pricing_OEM_Name_FI__c,Pricing_Product_Nm__r.Name,SBQQ__Quote__c,SBQQ__Quote__r.Name, Pricing_Approved_Unit_Dup_Qty__c, Pricing_Quote_Line_Number__c, Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c  FROM SBQQ__QuoteLine__c WHERE Pricing_Status_Nm__c IN ('Won') AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName ='Design Win' AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c='Deal Registration' AND Pricing_Approved_End_Date_Dup_Dt__c>=:qtrList[1].StartDate order by Pricing_Approved_End_Date_Dup_Dt__c];
         List<PCC_Rebate_Claim_Line_Item__c> rebateCLIs = [SELECT Id, PCC_Quote_Line_Number__c,PCC_Quantity__c FROM  PCC_Rebate_Claim_Line_Item__c WHERE PCC_Quote_Line_Number__c IN :qlLinesList and PCC_Rebate_Claim__r.PCC_Claim_Status__c!='Claim Rejected'];
         Map<Id, Integer> remainingQuantityMap = new Map<Id, Integer>();
          Map<Id, Integer> claimedQuantityMap = new Map<Id, Integer>();
          List<SBQQ__QuoteLine__c> qlLinesNewList = new List<SBQQ__QuoteLine__c>();
         Map<Id, Integer> existingCountMap = new Map<Id, Integer>();
 
         for (PCC_Rebate_Claim_Line_Item__c rcli : rebateCLIs) {
             if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
             } 
             else {
                existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
             }
         }
         Integer maxQuantity,existingQLQuantity,remainingQuantity;
         for (SBQQ__QuoteLine__c ql : qlLinesList) {
             maxQuantity = ql.get('Pricing_Approved_Unit_Dup_Qty__c')!=null?Integer.valueOf(ql.get('Pricing_Approved_Unit_Dup_Qty__c')):0;
             existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
             remainingQuantity = maxQuantity - existingQLQuantity;
             remainingQuantityMap.put(ql.Id, remainingQuantity);
             claimedQuantityMap.put(ql.Id,existingQLQuantity);
             Date prevqtr = qtrList[1].EndDate.addDays(30);
             if(remainingQuantity>0 && qtrList[1].StartDate <=ql.Pricing_Approved_End_Date_Dup_Dt__c && qtrList[1].EndDate>=ql.Pricing_Approved_End_Date_Dup_Dt__c && Date.today()<=prevqtr){
                qlLinesNewList.add(ql);
             }
             if(remainingQuantity>0 && ql.Pricing_Approved_End_Date_Dup_Dt__c>=qtrList[0].StartDate){
                  qlLinesNewList.add(ql);
             }
         }
         QLWrapper ql = new QLWrapper();
            ql.qlList = qlLinesList;
            ql.remainingQuantity = remainingQuantityMap;
            ql.claimedQuantity=claimedQuantityMap;
            return ql;
    }
    
    public class QLWrapper {
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> qlList { get; set; }
        @AuraEnabled
        public  Map<Id, Integer> remainingQuantity { get; set; }
         @AuraEnabled
        public  Map<Id, Integer> claimedQuantity { get; set; }
    }
    public class inpWrap {
        @AuraEnabled
        public String quantity { get; set; }
        @AuraEnabled
        public String invoiceDate { get; set; }
        @AuraEnabled
        public String invoiceNumber { get; set; }
    }
    @AuraEnabled
    public static string processData(String inputMap) {
     Map<String,Object> qlitoinputMap= (Map<String,Object>)JSON.deserializeUntyped(inputMap);
     List<SBQQ__QuoteLine__c> sourceRecords = [SELECT Id, Pricing_Product_Nm__r.Name, SBQQ__Quote__r.SBQQ__Opportunity2__c, Pricing_OEM_Name_FI__c,Pricing_FI_Net_RPU_Amt__c FROM SBQQ__QuoteLine__c WHERE Id IN : qlitoinputMap.keySet()];
        List<PCC_Rebate_Claim_Line_Item__c> rliListToInsert = new List<PCC_Rebate_Claim_Line_Item__c>();
        PCC_Rebate_Claim__c rc;
        String rcId='';
        if(sourceRecords.size()>0) {
            
        rc = new PCC_Rebate_Claim__c();
        rc.PCC_Submission_Date__c = System.now();
        rc.PCC_Claim_Status__c = 'Claim Submitted';
        Database.insert(rc);
        rcId= rc.Id;
        }
        for (SBQQ__QuoteLine__c qli : sourceRecords) {
            PCC_Rebate_Claim_Line_Item__c rcli = new PCC_Rebate_Claim_Line_Item__c();
            Map<string,Object> inpw = (Map<String,Object>)qlitoinputMap.get(qli.Id);
            rcli.PCC_Rebate_Claim__c = rc.Id;
            rcli.PCC_Quote_Line_Number__c = qli.Id;
           rcli.PCC_Quantity__c = Integer.valueOf(inpw.get('quantity'));
           rcli.PCC_Invoice__c =  (String)inpw.get('invoiceNumber');
           //rcli.PCC_Invoice_Date__c = Date.parse((string)inpw.get('invoiceDate'));
            rcli.PCC_Product__c = qli.Pricing_Product_Nm__r?.Id;
            rcli.PCC_Opportunity__c = qli.SBQQ__Quote__r?.SBQQ__Opportunity2__c;
            rcli.PCC_OEM_Name__c = qli.Pricing_OEM_Name_FI__c;
            if(qli.Pricing_FI_Net_RPU_Amt__c!=null){
                rcli.PCC_Claimed_Rebate_Amount__c = qli.Pricing_FI_Net_RPU_Amt__c*Integer.valueOf(inpw.get('quantity'));
            }
            rcli.PCC_Status__c = 'Submitted';
            rliListToInsert.add(rcli);
        }
        System.debug('rliListToInsert>>'+rliListToInsert);
        if (!rliListToInsert.isEmpty()) {
            Database.insert(rliListToInsert);
        }
        return rcId;
    }
    
    @InvocableMethod(label='Get Quote Quantity' description='Returns the Quantity on QLs' category='Rebate Claim')
    public static List<QuantityResult> getQuoteQuantity(List<String> qlNum) {
         List<SBQQ__QuoteLine__c> qlLinesList = [SELECT Id, Name,Pricing_Approved_Unit_Qty__c, Pricing_Product_Nm__c,Pricing_Product_Nm__r.Name,SBQQ__Quote__c,SBQQ__Quote__r.Name, Pricing_Approved_Unit_Dup_Qty__c, Pricing_Quote_Line_Number__c, Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c  FROM SBQQ__QuoteLine__c where Pricing_Status_Nm__c IN ('Approved') and Pricing_Quote_Line_Number__c IN:qlNum];
        List<PCC_Rebate_Claim_Line_Item__c> rebateCLIs = new List<PCC_Rebate_Claim_Line_Item__c>();
        Map<Id, Integer> existingCountMap = new Map<Id, Integer>();
       
        List<QuantityResult> qlList = new List<QuantityResult>();
        if(qlLinesList.size()>0){
             rebateCLIs = [SELECT Id, PCC_Quote_Line_Number__c,PCC_Quantity__c FROM  PCC_Rebate_Claim_Line_Item__c WHERE PCC_Quote_Line_Number__c IN :qlLinesList and PCC_Rebate_Claim__r.PCC_Claim_Status__c!='Claim Rejected'];
             for (PCC_Rebate_Claim_Line_Item__c rcli : rebateCLIs) {
             if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
             } 
             else {
                existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
             }
         }
        
         
        
         Integer maxQuantity,existingQLQuantity,remainingQuantity;
         for (SBQQ__QuoteLine__c ql : qlLinesList) {
             QuantityResult qr = new QuantityResult();
             maxQuantity = ql.get('Pricing_Approved_Unit_Qty__c')!=null?Integer.valueOf(ql.get('Pricing_Approved_Unit_Qty__c')):0;
             existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
             remainingQuantity = maxQuantity - existingQLQuantity;
             qr.isQLThere=true;
              qr.ApprovedQuantity = maxQuantity;
            qr.RemainingQuantity = remainingQuantity;
            qr.ClaimedQuantity=existingQLQuantity;
            qlList.add(qr);
         }
        }
        else{
            QuantityResult qr = new QuantityResult();
            qr.isQLThere=false;
            qlList.add(qr);
        } 
            
            return qlList;
    }
    
    public class QuantityResult {
         @InvocableVariable 
       public  Boolean isQLThere ;
       @InvocableVariable 
       public  Integer RemainingQuantity ;
        @InvocableVariable
        public  Integer ClaimedQuantity ;
       @InvocableVariable
        public Integer ApprovedQuantity ;

  }
  /****************************************************************
    Method Name: getQLswithoutRebate
    Description: This method is used to get the QuoteLines without rebate.
    *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQLswithoutRebate() {
        try {
            Date currentDate =  Date.today();
            Integer currentQuarter = (currentDate.month() - 1) / 3 + 1;
            Date currentQuarterPlusOneMonth = Date.newInstance(currentDate.year(), (currentQuarter * 3) + 1, 30);
            List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c, Pricing_Approved_Unit_Dup_Qty__c 
                                                        FROM SBQQ__QuoteLine__c 
                                                        WHERE Pricing_Status_Nm__c IN ('Won') 
                                                        AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName ='Design Win' 
                                                        AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' 
                                                        AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c='Deal Registration'
                                                        AND Pricing_Approved_End_Date_Dup_Dt__c < :currentQuarterPlusOneMonth];
             List<PCC_Rebate_Claim_Line_Item__c> rcliList =[Select PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_Rebate_Claim__r.PCC_Claim_Status__c IN ('Approved','Submitted')];   
            Map<Id, Integer> remainingQuantityMap = new Map<Id, Integer>();   
            Map<Id, Integer> existingCountMap = new Map<Id, Integer>();       
            List<SBQQ__QuoteLine__c> qlsList = new List<SBQQ__QuoteLine__c>();
   
           for (PCC_Rebate_Claim_Line_Item__c rcli : rcliList) {
               if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                  existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
               } 
               else {
                  existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
               }
           }
           Integer maxQuantity,existingQLQuantity,remainingQuantity;
           for (SBQQ__QuoteLine__c ql : quoteLinesList) {
               maxQuantity = ql.get('Pricing_Approved_Unit_Dup_Qty__c')!=null?Integer.valueOf(ql.get('Pricing_Approved_Unit_Dup_Qty__c')):0;
               existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
               remainingQuantity = maxQuantity - existingQLQuantity;
               if(remainingQuantity>0){
                    qlsList.add(ql);
               }
           }
            return qlsList;
        } catch(Exception ex) {
            insert new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = ex.getMessage(), Core_Origin__c='PCC_RebateClaimController.getQLswithoutRebate', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            return new List<SBQQ__QuoteLine__c>();
        }
    }
    
}