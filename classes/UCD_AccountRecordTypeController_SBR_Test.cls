@isTest(SeeAllData=false)
public class UCD_AccountRecordTypeController_SBR_Test {
    
    public static testMethod void fetchAccountRecordTypes(){
        List<UCD_AccountRecordTypeController_SBR.AccountRecordTypeWrapper> recTypeWrap = UCD_AccountRecordTypeController_SBR.fetchAccountRecordTypes();	
        System.assert(recTypeWrap != null, 'Record type list is empty');
    }
}