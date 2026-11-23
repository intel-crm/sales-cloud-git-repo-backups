public class test_ins_recovery_amt {

 public static void test(){
 Map<String,List<Core_MDF_Scorecard__c>> budgetTypeToSCList = new Map<String,List<Core_MDF_Scorecard__c>>();
for(Core_MDF_Scorecard__c scorecardData : [select id,Core_MDF_Score_Nbr__c,
Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,
Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c,
Core_MDF_Manual_Recovery_Amount_USD_Amt__c ,
Core_MDF_Case_Id__r.Core_MDF_Claim_Amount_USD__c
from Core_MDF_Scorecard__c where
Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c='Data Center Co-Marketing Fund'
AND Core_MDF_Case_Id__r.Core_MDF_Status__c ='Review Completed'
and Core_MDF_Score_Nbr__c <> null]){
List<Core_MDF_Scorecard__c> scBudgetType = new List<Core_MDF_Scorecard__c>();
if(budgetTypeToSCList != null && budgetTypeToSCList.containsKey(scorecardData.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c)){
scBudgetType = budgetTypeToSCList.get(scorecardData.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c);
}
scBudgetType.add(scorecardData);
budgetTypeToSCList.put(scorecardData.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c,scBudgetType);
}



System.debug('budgetTypeToSCList:'+budgetTypeToSCList);



List<Core_MDF_Partner_Gradient_Detail__c> pgdRecToBeInserted = new List<Core_MDF_Partner_Gradient_Detail__c>();

for(String bt: budgetTypeToSCList.keySet()){
List<Core_MDF_Scorecard__c> scList = budgetTypeToSCList.get(bt);
Decimal recAmt = 0.0;
Core_MDF_Partner_Gradient_Detail__c pgd = new Core_MDF_Partner_Gradient_Detail__c();
pgd.Core_MDF_Budget_Type_nm__c = bt;

for(Core_MDF_Scorecard__c sc: scList){
if(sc.Core_MDF_Score_Nbr__c == 0){
recAmt = recAmt + sc.Core_MDF_Case_Id__r.Core_MDF_Claim_Amount_USD__c+ (sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
}
if(sc.Core_MDF_Score_Nbr__c == 1){
recAmt = recAmt + (0.5* sc.Core_MDF_Case_Id__r.Core_MDF_Claim_Amount_USD__c)+ (sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
}
if(sc.Core_MDF_Score_Nbr__c == 2){
recAmt = recAmt + (0.25*sc.Core_MDF_Case_Id__r.Core_MDF_Claim_Amount_USD__c)+ (sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c == null ? 0 : sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c);
}
pgd.Core_MDF_Region_Cd__c = sc.Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c.split('-')[0].trim();
}

pgd.Core_MDF_Partnership_Grade_Maint_id__c = 'a5Zg0000000yQU2EAM';

pgd.Core_MDF_Total_Amt__c = recAmt;
pgdRecToBeInserted.add(pgd);
system.debug('pgdRecToBeInserted:'+pgd);
}

}
}