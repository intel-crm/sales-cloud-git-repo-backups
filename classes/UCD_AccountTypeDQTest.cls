@IsTest
public class UCD_AccountTypeDQTest {
    
    private static Account createAccount(){
		Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Core_Customer_Aggregation_Type__c = 'UNFD_GLBL_CUST';
        acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        acc.BillingCountryCode	= 'IND';
        acc.BillingCity = 'TestCity';
        acc.BillingStreet = 'TestStreet';
        acc.Core_Business_Party_Id__c = 'TestBusinessPartyId';
        return acc;
	        
    }
    
    private static List<UCD_AccountTypeDQ.combineWrapper> createCombineWrapper(){
        List<UCD_AccountTypeDQ.combineWrapper> combineWappers = new List<UCD_AccountTypeDQ.combineWrapper>();
        Integer missScore = 0;
        for(integer i=0;i<4;i++){
            
            UCD_AccountTypeDQ.combineWrapper combineWrap = new UCD_AccountTypeDQ.combineWrapper();
            combineWrap.acc = null;
            combineWrap.score = 2;
            combineWrap.coreScore = 100;
            combineWrap.missScore = missScore;
            combineWrap.MissingData = createFieldData('MissingData');
            combineWrap.CoreData = createFieldData('CoreData');
            combineWrap.AccountType = 'TestAccountType';
            combineWappers.add(combineWrap);
            missScore+=30;
        }
        return combineWappers;
    }
    
    private static List<UCD_AccountTypeDQ.fieldData> createFieldData(String dataTypes){
        List<UCD_AccountTypeDQ.fieldData> fieldsData = new List<UCD_AccountTypeDQ.fieldData>();
        if(dataTypes == 'MissingData'){
            for(integer i=0;i<=2;i++){
                UCD_AccountTypeDQ.fieldData fieldData = new UCD_AccountTypeDQ.fieldData();
                fieldData.FieldName = 'TestMissingData '+i;
                fieldData.isFilled = false;
                fieldsData.add(fieldData);
            }
        }else{
            for(integer i=0;i<=2;i++){
                UCD_AccountTypeDQ.fieldData fieldData = new UCD_AccountTypeDQ.fieldData();
                fieldData.FieldName = 'correctData '+i;
                fieldData.isFilled = true;
                fieldsData.add(fieldData);
            }
            
        }
        return fieldsData;
    }
       
    @isTest
    private static void whenDashData_Core(){
        Test.startTest(); 
        List<Integer> integers = UCD_AccountTypeDQ.dashdata_core(createCombineWrapper());
        Test.stopTest();
    }
    @isTest
    private static void whenDashData(){
        Test.startTest();
        List<Integer> integers = UCD_AccountTypeDQ.dashdata(createCombineWrapper());
        Test.stopTest();
    }
    
    @isTest
    private static void whenTypeIPA(){
        Account acc = createAccount();
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert acc;
        Test.startTest();
        List<UCD_AccountTypeDQ.combineWrapper> combineWrappers = UCD_AccountTypeDQ.combineChart_new('ipa');
        Test.stopTest();
    }
    
    @isTest
    private static void whenTypeAandE(){
        Account acc = createAccount();
        acc.Core_B2B_Entitlement__c = true;
        insert acc;
        Test.startTest();
        List<UCD_AccountTypeDQ.combineWrapper> combineWrappers = UCD_AccountTypeDQ.combineChart_new('a&e');
        Test.stopTest();
    }
    
    @isTest
    private static void whenTypePSG(){
        Account acc = createAccount();
        acc.Core_PSG_Account__c = true;
        insert acc;
        Test.startTest();
        List<UCD_AccountTypeDQ.combineWrapper> combineWrappers = UCD_AccountTypeDQ.combineChart_new('psg');
        Test.stopTest();
    }     

}