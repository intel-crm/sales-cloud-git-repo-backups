@isTest(SeeAllData=false)
public class UCD_AccountRecordTypeController_Test {
    
    public static testMethod void fetchAccountRecordTypes(){
        List<UCD_AccountRecordTypeController.AccountRecordTypeWrapper> recTypeWrap = UCD_AccountRecordTypeController.fetchAccountRecordTypes();	
        System.assert(recTypeWrap != null, 'Record type list is empty');
    }
}