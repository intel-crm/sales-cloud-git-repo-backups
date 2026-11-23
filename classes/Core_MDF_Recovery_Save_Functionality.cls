public without sharing class Core_MDF_Recovery_Save_Functionality {
    
    //Method to check if the recovery requests lie within the recovered limit for the Account, Program, Quarter
    public static Map<boolean,string> validateBudgetConsumed(Map<string,decimal> btGeoToAmountMap, List<String> recoveryBudAmtList){
        Map<string,decimal> btToAmountMap = new Map<string,decimal>();
        Map<string,decimal> btToRecAmtMap = new Map<string,decimal>();
        boolean issueUpdate =true;
        Map<boolean,string> result= new Map<boolean,string>();
        string message = '';
        boolean noBT;
        try{
            // looping over the btGeoToAmountMap keyset
            for(string key:btGeoToAmountMap.keyset()){
                // setting a map with key as Budget type;geo, value as amount to be recovered
                btToAmountMap.put(key,btGeoToAmountMap.get(key));
            }
            
            if(recoveryBudAmtList != NULL && recoveryBudAmtList.size()>0){
                // looping over the recoveryBudAmtList
                for(string recBudAmt :recoveryBudAmtList){
                    // splitting with , and storing in tempList
                    List<String> tempList = recBudAmt.split(',');
                    // Looping over the tempList
                    for(string st : tempList){
                        // splitting with = and storing in lst
                        List<String> lst = st.trim().split('=');
                        // stores amount
                        decimal amt = decimal.valueof(lst[1]);
                        // setting a map with key as Budget type;geo, value as sum of recovery amount
                        if(btToRecAmtMap.containsKey(lst[0])){
                            decimal recovery = btToRecAmtMap.get(lst[0]);                        
                            btToRecAmtMap.put(lst[0],recovery + amt);
                        }else{
                            btToRecAmtMap.put(lst[0],amt);
                        }
                    }
                }
            }
            
            string budgetTypes = '';   
            // looping over btToRecAmtMap keyset
            for(string key: btToRecAmtMap.keyset()){ 
                // if key doesnt contains in psd or if it contains but sum of recovery amount is greater than psd's to be recovered amount, update the boolean to false
                if(!btToAmountMap.containsKey(key) || ( btToAmountMap.containsKey(key) && btToRecAmtMap.get(key) > btToAmountMap.get(key))){
                    issueUpdate=false;
                    budgetTypes = budgetTypes==''?key : budgetTypes +', ' + key;
                }
            }
            noBT =Label.Core_MDF_No_Budget_Types.split(';').contains(budgetTypes) ?true: false;
            if(issueUpdate){
                message = Label.Core_MDF_Recovery_Save_Successful;
                //Saved successfully! 
            }
            else{
                if(noBT){
                    message = Label.Core_MDF_Recovery_Exceeded_Error_1 +'. '+ Label.Core_MDF_Recovery_Exceeded_Error_2 ; 
                    //'Total Amount that you are trying to Recover is Greater than the Actual Recovery Amount. Please rework the amount that you are trying to Recover.';
                }
                else{
                    message = Label.Core_MDF_Recovery_Exceeded_Error_1 +' for '+ budgetTypes + '. '+ Label.Core_MDF_Recovery_Exceeded_Error_2 ; 
                    //'Total Amount that you are trying to Recover is Greater than the Actual Recovery Amount for '+ budgetTypes +'. Please rework the amount that you are trying to Recover.';
                }   
            }
            result.put(issueUpdate,message);       
            
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return result;   
    }
    
    //Check if the BudgetConsumedFrom is populated correctly for the recovery records or if not present, populate the field
    public static Map<id,string> checkBudgetConsumedFrom(Map<string,decimal> btGeoToAmountMap, List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> rrr){
        Map<id,string> rrToBgtConsumedList = new Map<id,string>();
        try{
            //Loop through the recovery requests
            for(Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows record:rrr){
                rrToBgtConsumedList.put(record.id,record.recoveryBudAmt);                
            }              
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return rrToBgtConsumedList;
    }
}