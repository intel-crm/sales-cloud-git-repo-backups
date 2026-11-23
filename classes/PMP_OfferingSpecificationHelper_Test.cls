@isTest

public class PMP_OfferingSpecificationHelper_Test{


    // public static testMethod void createOfferingSpecificationTest(){
    //     List<PMP_Specification__c> specList = New List<PMP_Specification__c>();
    //     List<PMP_Specification_Value__c> specValList = New List<PMP_Specification_Value__c>();
    //     List<PMP_Partner_Offering_Specification__c> offeringSpecificationList = New List<PMP_Partner_Offering_Specification__c>();
    //     PMP_Specification__c spec1 = New PMP_Specification__c(name='Intel Technologies',
    //                                                         PMP_Partner_Product_Specification_Id__c = 'NPP_IntelTechnologies',
    //                                                         PMP_Partner_Product_Specification_Key__c='npp_inteltechnologies');
    //     System.assertEquals( 'Intel Technologies',spec1.name);                                                   
    //     PMP_Specification__c spec2 = New PMP_Specification__c(name='End Customer Type',
    //                                                         PMP_Partner_Product_Specification_Id__c = 'NPP_EndCustomerType',
    //                                                         PMP_Partner_Product_Specification_Key__c='npp_endcustomertype');
    //     System.assertEquals('End Customer Type',spec2.name);
    //     PMP_Specification__c spec3 = New PMP_Specification__c(name='Displays',PMP_Partner_Product_Specification_Id__c = 'DisplaysLevel1',
    //                                                         PMP_Partner_Product_Specification_Key__c='displayslevel1');
    //     System.assertEquals( 'Displays',spec3.name);
    //     specList.add(spec1);
    //     specList.add(spec2);
    //     specList.add(spec3);
    //     PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', null,null,null,true,null,null );
        
    //     PMP_Specification_Value__c specVal1 = New PMP_Specification_Value__c (Name='TestSpec', PMP_Product_Specification_Value_Cd__c='Test');
    //     PMP_Specification_Value__c specVal2 = New PMP_Specification_Value__c (Name='TestSpec12', PMP_Product_Specification_Value_Cd__c='Test21');
    //     PMP_Specification_Value__c specVal3 = New PMP_Specification_Value__c (Name='TestSpec132', PMP_Product_Specification_Value_Cd__c='Test23');
    //     specValList.add(specVal1);
    //     specValList.add(specVal2);
    //     specValList.add(specVal3);
        
    //     insert specList;
    //     insert specValList;
        
    //     PMP_Partner_Offering_Specification__c offeringSpec1 = New PMP_Partner_Offering_Specification__c ();
    //     offeringSpec1.PMP_Specification_Nm__c = spec1.Name;
    //     offeringSpec1.Name = spec1.Name;
    //     offeringSpec1.PMP_Product_Specification_Cd__c = spec1.PMP_Partner_Product_Specification_Id__c;
    //     offeringSpec1.PMP_Offering_Id__c = offering.Id;
    //     offeringSpec1.PMP_Specification_Id__c = spec1.id;
    //     offeringSpec1.PMP_Specification_Value_Cd__c = specVal1.Name;
    //     offeringSpec1.PMP_Specification_Value_Id__c = specVal1.id;
    //     offeringSpecificationList.add(offeringSpec1);
        
    //     PMP_Partner_Offering_Specification__c offeringSpec2 = New PMP_Partner_Offering_Specification__c ();
    //     offeringSpec2.PMP_Specification_Nm__c = spec1.Name;
    //     offeringSpec2.Name = spec1.Name;
    //     offeringSpec2.PMP_Product_Specification_Cd__c = spec1.PMP_Partner_Product_Specification_Id__c;
    //     offeringSpec2.PMP_Offering_Id__c = offering.Id;
    //     offeringSpec2.PMP_Specification_Id__c = spec1.id;
    //     offeringSpec2.PMP_Specification_Value_Cd__c = specVal2.Name;
    //     offeringSpec2.PMP_Specification_Value_Id__c = specVal2.id;
    //     offeringSpecificationList.add(offeringSpec2);
        
    //     PMP_Partner_Offering_Specification__c offeringSpec3 = New PMP_Partner_Offering_Specification__c ();
    //     offeringSpec3.PMP_Specification_Nm__c = spec1.Name;
    //     offeringSpec3.Name = spec1.Name;
    //     offeringSpec3.PMP_Product_Specification_Cd__c = spec1.PMP_Partner_Product_Specification_Id__c;
    //     offeringSpec3.PMP_Offering_Id__c = offering.Id;
    //     offeringSpec3.PMP_Specification_Id__c = spec1.id;
    //     offeringSpec3.PMP_Specification_Value_Cd__c = specVal1.Name;                                                    
    //     offeringSpecificationList.add(offeringSpec3);
        
        
    //     insert offeringSpecificationList;
        
    //     intel_formData formData = New Intel_formData();
    //     Map<string, List<string>> specification_smplTab2 = New Map<string, List<string>>();
        
    //     Map<string, string> specification_txtTab2 = New  Map<string, string> ();
    //     Map<string, List<Intel_SpecificationDataWrapper>> specification_cmplxTab2 = new Map<string, List<Intel_SpecificationDataWrapper>>();
        
    //     List<Intel_SpecificationDataWrapper> wrapperList = New List<Intel_SpecificationDataWrapper>();
    //     Intel_SpecificationDataWrapper specWrapper1 = New Intel_SpecificationDataWrapper();
    //     specWrapper1.id = specVal1.id+ '|'+spec1.id;
    //     Intel_SpecificationDataWrapper specWrapper2 = New Intel_SpecificationDataWrapper();
    //     specWrapper2.id = specVal3.id+ '|'+spec1.id;
        
    //     List<string> smplList = New List<string>{specVal1.id+ '|'+spec2.id,spec2.id };
    //     specification_txtTab2.put(specVal3.id+ '|'+spec2.id, 'TestVal');
    //     specification_txtTab2.put(spec2.id, 'TestVal');
    //     specification_smplTab2.put(spec3.id, smplList);
    //     Intel_SpecificationDataWrapper specWrapper3 = New Intel_SpecificationDataWrapper();
    //     specWrapper3.id = spec1.id;
    //     Intel_SpecificationDataWrapper specWrapper4 = New Intel_SpecificationDataWrapper();
    //     specWrapper4.id = spec1.id;
    //     specWrapper4.value = specVal2.id+ '|'+spec1.id;
    //     wrapperList.add(specWrapper1);
    //     wrapperList.add(specWrapper2);
    //     wrapperList.add(specWrapper3);
    //     wrapperList.add(specWrapper4);
    //     specification_cmplxTab2.put('NPP_IntelTechnologies',wrapperList);
    //     // system.debug('Map-->'+specification_cmplxTab2);
    //     formData.specification_cmplxTab2 = specification_cmplxTab2;
    //     formData.specification_smplTab2 = specification_smplTab2 ;
    //     formData.specification_txtTab2 = specification_txtTab2 ;
        
    //     PMP_OfferingSpecificationHelper.createOfferingSpecification(formData,offering.id,1,0);
        
    // }

}