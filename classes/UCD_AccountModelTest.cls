@isTest
public class UCD_AccountModelTest {
    public static testMethod void wrappertest(){
    
        UCD_AccountModel.additionalColumns addcol = new UCD_AccountModel.additionalColumns();
        addcol.ApiName='abc__c';
        addcol.isCheckbox = true;
        addcol.UILabel ='abc';
        addcol.textFieldValue = 'abc';
        addcol.checkboxFieldValue = true;
        addcol.showColumn = false;
        List< UCD_AccountModel.additionalColumns> addcolList = new List< UCD_AccountModel.additionalColumns>();
        addcolList.add(addcol);
    
        UCD_AccountModel accmod = new UCD_AccountModel();
        accmod.accName = 'Account Name';
        accmod.accType = 'Distributor';
        accmod.accNTier = 'Tier 1';
        accmod.Industry = 'Gaming';
        system.assertEquals('Gaming', accmod.Industry);
        accmod.IPAFlag = true;
        accmod.accountDeactivated = false;
        accmod.noRecordsFromCim = false;
        accmod.bizOrgType = 'Distributor';
        accmod.partnerRole = 'partner Role';
        accmod.primaryAddressAcc = 'Address';
        accmod.address= 'Address';
        accmod.cimID='231333';
        accmod.sourceSystemCIM = true;
        accmod.searchScore = '55';
        accmod.Country = 'India';
        accmod.State = 'Karnataka';
        accmod.City = 'Bangalore';
        accmod.postalCode = '342342';
        accmod.fullAddress = 'Address Bangalore Karnataka India 342342';
        accmod.salescouldAccount = true;
        accmod.accId = 'sampleid';
        accmod.accOwner = 'SampleOwner';
        accmod.relatedContacts = 3;
        accmod.CountryCode = 'API';
        accmod.stateCode = 'TN';
        accmod.SFaccName = 'sdfsd';
        accmod.RecordTypeId = 'asdfgrtyu';
        accmod.addColList=addcolList;
       
       
       // UCD_AccountModel.fetchIdentifiers();
        
        
        
     
    }
    
    @isTest
    static void test() {
         /*   system.test.startTest(); */
        Account acc1 = new Account(name='Test Account 1', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street');
        Account acc2 = new Account(name='Test Account 2', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street'); 
        Account acc3 = new Account(name='Test Account 3', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street');
        Account acc4 = new Account(name='Test Account 4', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street');
        system.assertEquals('Bangalore', acc1.BillingCity);
        insert acc1;
        insert acc2;
        insert acc3;
        insert acc4;
        UCD_AccountModel mod1 = new UCD_AccountModel(acc1.id, 'NoDup');
        UCD_AccountModel mod2 = new UCD_AccountModel(acc2.id, 'FullDup');
        
        List<UCD_AccountModel> testing =  new List<UCD_AccountModel>();
        testing.add(mod1);
        testing.add(mod2);
        //System.debug('Mod1'+mod1);
        //System.debug('Mod2'+mod1);
        testing.sort();
        //System.debug('Mod1');
        //System.debug('Mod2');
        System.assert(mod2.compareTo(mod1) < 0);
        //testing.clear();
        UCD_AccountModel mod3 = new UCD_AccountModel(acc3.id, 'FullDup');
        UCD_AccountModel mod4 = new UCD_AccountModel(acc3.id, 'NoDup');
        UCD_AccountModel mod5 = new UCD_AccountModel(acc4.id, 'FullDup');
        UCD_AccountModel mod6 = new UCD_AccountModel('', 'FullDup');
        UCD_AccountModel mod7 = new UCD_AccountModel('', 'NoDup');
        testing.add(mod3);
        testing.add(mod4);
        testing.sort();
        testing.add(mod5);
        testing.add(mod6);
        testing.add(mod7);
        testing.sort();
       // System.assert(mod3.compareTo(mod4) < 0);
       // System.assert(mod3.compareTo(mod5) > 0);
        //System.assert(mod3.compareTo(mod3) == 0);
        /*System.assert(mod2.compareTo(mod1) > 0);
        System.assert(mod1.compareTo(mod2) < 0);
        System.assert(mod1.compareTo(mod1) == 0);
        
        System.assert(mod2.compareTo(mod3) > 0);
        System.assert(mod3.compareTo(mod2) < 0);
        System.assert(mod2.compareTo(mod2) == 0);
        
        System.assert(mod4.compareTo(mod3) > 0);
        System.assert(mod3.compareTo(mod4) < 0);
        System.assert(mod3.compareTo(mod3) == 0);
        system.test.stopTest();*/
    }
    @isTest
    static void test1() {
        List<UCD_AccountModel> testing =  new List<UCD_AccountModel>();
        Account acc1 = new Account(name='Test Account 1', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street');
        Account acc2 = new Account(name='Test Account 2', BillingCity = 'Bangalore', BillingCountry = 'IND', BillingStreet = 'sample street'); 
        system.assertEquals('Bangalore', acc1.BillingCity);
        insert acc1;
        insert acc2;
        UCD_AccountModel mod1 = new UCD_AccountModel(acc1.id, 'NoDup');
        UCD_AccountModel mod2 = new UCD_AccountModel(acc2.id, 'FullDup');
        testing.sort();
    }
}