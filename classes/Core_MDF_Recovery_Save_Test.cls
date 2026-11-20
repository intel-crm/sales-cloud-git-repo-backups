@isTest(SeeAllData=false)
public class Core_MDF_Recovery_Save_Test {
    @isTest static void testValidateBudgetConsumed() {
        Map<string,decimal> btGeoToAmountMap = new Map<string,decimal>();
        Map<boolean,string> result = new Map<boolean,string>();
        boolean check;
        string message;
        btGeoToAmountMap.put('OEM CMP;APJ',150);
        btGeoToAmountMap.put('OEM CMP;ASMO',150);
        
        List<String> recoveryBudAmtList = new List<String>{'OEM CMP;APJ=200,OEM CMP;ASMO=15'};
        
        result = Core_MDF_Recovery_Save_Functionality.validateBudgetConsumed(btGeoToAmountMap,recoveryBudAmtList);
        for(boolean key: result.keyset()) {
            check = key;
            message = result.get(key);
        }
        System.assertEquals(check,false,'Success');
        
        List<String> recoveryBudAmtList1 = new List<String>{'OEM CMP;APJ=100,OEM CMP;ASMO=15','OEM CMP;APJ=50'};
        result = Core_MDF_Recovery_Save_Functionality.validateBudgetConsumed(btGeoToAmountMap,recoveryBudAmtList1);
        for(boolean key: result.keyset()){
            check = key;
            message = result.get(key);
        }
        System.assertEquals(check,true,'Success');
        
        List<String> recoveryBudAmtList2 = new List<String>{'Service Provider CoMarketing Fund;APJ=15'};
        result = Core_MDF_Recovery_Save_Functionality.validateBudgetConsumed(btGeoToAmountMap,recoveryBudAmtList2);
        for(boolean key: result.keyset()){
            check = key;
            message = result.get(key);
        }
        System.assertEquals(check,false,'Success'); 
    }
    
    @isTest static void testCheckBudgetConsumedFrom() {
        Map<string,decimal> btGeoToAmountMap = new Map<string,decimal>();
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> rrr = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        Map<id,string> result = new Map<id,string>(); 
        btGeoToAmountMap.put('OEM CMP;APJ',150);
        btGeoToAmountMap.put('OEM CMP;ASMO',150);
        btGeoToAmountMap.put('OEM CMP;PRC',40);
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr1 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr1.budgetGeoConsumed = 'OEM CMP;APJ-20:OEM CMP;ASMO-10';
        rr1.recoveryBudAmt = 'OEM CMP;APJ=20,OEM CMP;ASMO=10';
        rr1.recoveryAmount = '30';
        rr1.budgetType='OEM CMP';
        rr1.geo = 'ASMO';
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr2 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr2.budgetGeoConsumed = 'OEM CMP;APJ-30:OEM CMP;ASMO-30';
        rr2.recoveryBudAmt = 'OEM CMP;APJ=30,OEM CMP;ASMO=30';
        rr2.recoveryAmount = '20';
        rr2.budgetType='OEM CMP';
        rr2.geo = 'APJ';
        
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr3 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr3.budgetGeoConsumed = 'OEM CMP;APJ-30';
        rr3.recoveryBudAmt = 'OEM CMP;APJ=30';
        rr3.recoveryAmount = '30';
        rr3.budgetType='OEM CMP';
        rr3.geo = 'ASMO';
        
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr4 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr4.budgetGeoConsumed = 'OEM CMP;APJ-30';
        rr4.recoveryBudAmt = 'OEM CMP;APJ=30';
        rr4.recoveryAmount = '70';
        rr4.budgetType='OEM CMP';
        rr4.geo = 'ASMO';
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr5 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr5.budgetGeoConsumed = 'OEM CMP;APJ-10:OEM CMP;ASMO-14';
        rr5.recoveryBudAmt = 'OEM CMP;APJ=10,OEM CMP;ASMO=14';
        rr5.recoveryAmount = '24';
        rr5.budgetType='OEM CMP';
        rr5.geo = 'EMEA';
        
        Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows rr6 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
        rr6.recoveryBudAmt = 'OEM CMP;ASMO=4';
        rr6.recoveryAmount = '4';
        rr6.budgetType='OEM CMP';
        rr6.geo = 'ASMO';
        
        rrr.add(rr1);
        rrr.add(rr2);
        rrr.add(rr3);
        rrr.add(rr4);
        rrr.add(rr5);
        rrr.add(rr6);
        
        result = Core_MDF_Recovery_Save_Functionality.checkBudgetConsumedFrom(btGeoToAmountMap,rrr);
        System.assert(result.size()>0,'Success');
    }
}