/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_ParseOSJSON_Test
* Version     : 1.0 
* Created Date: 21/07/2020
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Deepanshu Singh Rathore             21/07/2020               Test Class for PMP_ParseOSJSON.
******************************************************************************************************************************************************************************************************/
@isTest
public class PMP_ParseOSJSON_Test {
	//IPA 2.0- US-TWC729-7980
    /*testMethod static void ParseOSEngJSONTest(){
        
        List<PMP_Specification__c> uploadableSpecifications = new List<PMP_Specification__c>();//list containing specifications to be uploaded
        List<PMP_Specification_Value__c> uploadableSpecificationValues = new List<PMP_Specification_Value__c>();//list containing specificationValues to be uploaded
        Test.startTest();
		
        PMP_Specification__c mainSpec = new PMP_Specification__c();
        mainSpec.Name = 'Operating Systems';
        mainSpec.PMP_Specification_Name__c = 'Operating Systems';
        mainSpec.PMP_Partner_Product_Specification_Id__c= 'NPP_OperationSystems';
        mainSpec.PMP_Specification_Type_Nm__c = 'Other';
        mainSpec.PMP_Active_Ind__c = true;
        mainSpec.PMP_Display_Type_Nm__c = 'Label';
        mainSpec.PMP_Mandatory_Offering_Category_Nm__c = 'Not minimum requirement. Optional';
        mainSpec.PMP_Partner_Product_Display_Sequence_Nbr__c = 6900;
        mainSpec.PMP_Specification_Chinese_Nm__c = 'OS';
        mainSpec.PMP_Specification_Japanese_Nm__c = 'OS';
        mainSpec.PMP_Partner_Product_Specification_Key__c = 'npp_operationsystems';
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.Name = 'OS Independent';
        Spec1.PMP_Specification_Name__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Id__c= '203701';
        Spec1.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems'; 
        Spec1.PMP_Specification_Type_Nm__c = 'OS'; 
        Spec1.PMP_Active_Ind__c = true;		
        Spec1.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = 120;
        Spec1.PMP_Specification_Chinese_Nm__c = 'OS Independent';
        Spec1.PMP_Specification_Japanese_Nm__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Key__c = '203701';
        
        PMP_Specification__c Spec2 = new PMP_Specification__c();
        Spec2.Name = 'OS Independent family';
        Spec2.PMP_Specification_Name__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Id__c= '21479';
        Spec2.PMP_Product_Parent_Specification_Id__c = '203701';
        Spec2.PMP_Specification_Type_Nm__c = 'OS';
        Spec2.PMP_Active_Ind__c = true;
        Spec2.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec2.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        Spec2.PMP_Specification_Chinese_Nm__c = 'OS Independent family';
        Spec2.PMP_Specification_Japanese_Nm__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Key__c = '21479';
        
        PMP_Specification__c Spec3 = new PMP_Specification__c();
        Spec3.Name = 'Linux*';
        Spec3.PMP_Specification_Name__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Id__c= '203698';
        Spec3.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec3.PMP_Specification_Type_Nm__c = 'OS';
        Spec3.PMP_Active_Ind__c = true;
        Spec3.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec3.PMP_Partner_Product_Display_Sequence_Nbr__c = 126;
        Spec3.PMP_Specification_Chinese_Nm__c = 'Linux*';
        Spec3.PMP_Specification_Japanese_Nm__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Key__c = '203698';

        PMP_Specification__c Spec4 = new PMP_Specification__c();
        Spec4.Name = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Name__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Id__c= '42027';
        Spec4.PMP_Product_Parent_Specification_Id__c = '203698';
        Spec4.PMP_Specification_Type_Nm__c = 'OS';
        Spec4.PMP_Active_Ind__c = true;
        Spec4.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec4.PMP_Partner_Product_Display_Sequence_Nbr__c = 127;
        Spec4.PMP_Specification_Chinese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Japanese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Key__c = '42027';
        
        PMP_Specification__c Spec5 = new PMP_Specification__c();
        Spec5.Name = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Name__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Id__c= '203699';
        Spec5.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec5.PMP_Specification_Type_Nm__c = 'OS';
        Spec5.PMP_Active_Ind__c = true;
        Spec5.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec5.PMP_Partner_Product_Display_Sequence_Nbr__c = 144;
        Spec5.PMP_Specification_Chinese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Japanese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Key__c = '203699';
        
        uploadableSpecifications.add(mainSpec);
        uploadableSpecifications.add(Spec1);
        uploadableSpecifications.add(Spec2);
        uploadableSpecifications.add(Spec3);
        uploadableSpecifications.add(Spec4);
        uploadableSpecifications.add(Spec5);
        
        PMP_Specification_Value__c specValueOS1 = new PMP_Specification_Value__c();
        specValueOS1.Name = 'OS Independent';
        specValueOS1.PMP_Active_Ind__c = true;
        specValueOS1.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS1.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS1.PMP_Product_Specification_Value_Cd__c = '46435';
        specValueOS1.PMP_Product_Specification_Value_Key__c = '46435';
        specValueOS1.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS1.PMP_Specification_Value_Nm__c = 'OS Independent';
        
        PMP_Specification_Value__c specValueOS2 = new PMP_Specification_Value__c();
        specValueOS2.Name = 'Red Hat Linux*';
        specValueOS2.PMP_Active_Ind__c = true;
        specValueOS2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS2.PMP_Product_Specification_Value_Cd__c = '21470';
        specValueOS2.PMP_Product_Specification_Value_Key__c = '21470';
        specValueOS2.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS2.PMP_Specification_Value_Nm__c = 'Red Hat Linux*';
        
        uploadableSpecificationValues.add(specValueOS1);
        uploadableSpecificationValues.add(specValueOS2);
        
        insert uploadableSpecifications;
        insert uploadableSpecificationValues;
        
        PMP_ParseOSJSON.languageCode = 'en_US';
        PMP_ParseOSJSON.parseOSJSON('OS_Attribute_Test');
        PMP_Specification__c spec = [SELECT id, PMP_Active_Ind__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c= '203701'];
        System.assertEquals(false, spec.PMP_Active_Ind__c);
        Test.stopTest();
        
    }

    testMethod static void ParseOSJpnJSONTest(){
        
        List<PMP_Specification__c> uploadableSpecifications = new List<PMP_Specification__c>();//list containing specifications to be uploaded
        List<PMP_Specification_Value__c> uploadableSpecificationValues = new List<PMP_Specification_Value__c>();//list containing specificationValues to be uploaded
        Test.startTest();
		
        PMP_Specification__c mainSpec = new PMP_Specification__c();
        mainSpec.Name = 'Operating Systems';
        mainSpec.PMP_Specification_Name__c = 'Operating Systems';
        mainSpec.PMP_Partner_Product_Specification_Id__c= 'NPP_OperationSystems';
        mainSpec.PMP_Specification_Type_Nm__c = 'Other';
        mainSpec.PMP_Active_Ind__c = true;
        mainSpec.PMP_Display_Type_Nm__c = 'Label';
        mainSpec.PMP_Mandatory_Offering_Category_Nm__c = 'Not minimum requirement. Optional';
        mainSpec.PMP_Partner_Product_Display_Sequence_Nbr__c = 6900;
        mainSpec.PMP_Specification_Chinese_Nm__c = 'OS';
        mainSpec.PMP_Specification_Japanese_Nm__c = 'OS';
        mainSpec.PMP_Partner_Product_Specification_Key__c = 'npp_operationsystems';
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.Name = 'OS Independent';
        Spec1.PMP_Specification_Name__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Id__c= '203701';
        Spec1.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems'; 
        Spec1.PMP_Specification_Type_Nm__c = 'OS'; 
        Spec1.PMP_Active_Ind__c = true;		
        Spec1.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = 120;
        Spec1.PMP_Specification_Chinese_Nm__c = 'OS Independent';
        Spec1.PMP_Specification_Japanese_Nm__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Key__c = '203701';
        
        PMP_Specification__c Spec2 = new PMP_Specification__c();
        Spec2.Name = 'OS Independent family';
        Spec2.PMP_Specification_Name__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Id__c= '21479';
        Spec2.PMP_Product_Parent_Specification_Id__c = '203701';
        Spec2.PMP_Specification_Type_Nm__c = 'OS';
        Spec2.PMP_Active_Ind__c = true;
        Spec2.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec2.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        Spec2.PMP_Specification_Chinese_Nm__c = 'OS Independent family';
        Spec2.PMP_Specification_Japanese_Nm__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Key__c = '21479';
        
        PMP_Specification__c Spec3 = new PMP_Specification__c();
        Spec3.Name = 'Linux*';
        Spec3.PMP_Specification_Name__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Id__c= '203698';
        Spec3.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec3.PMP_Specification_Type_Nm__c = 'OS';
        Spec3.PMP_Active_Ind__c = true;
        Spec3.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec3.PMP_Partner_Product_Display_Sequence_Nbr__c = 126;
        Spec3.PMP_Specification_Chinese_Nm__c = 'Linux*';
        Spec3.PMP_Specification_Japanese_Nm__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Key__c = '203698';

        PMP_Specification__c Spec4 = new PMP_Specification__c();
        Spec4.Name = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Name__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Id__c= '42027';
        Spec4.PMP_Product_Parent_Specification_Id__c = '203698';
        Spec4.PMP_Specification_Type_Nm__c = 'OS';
        Spec4.PMP_Active_Ind__c = true;
        Spec4.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec4.PMP_Partner_Product_Display_Sequence_Nbr__c = 127;
        Spec4.PMP_Specification_Chinese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Japanese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Key__c = '42027';
        
        PMP_Specification__c Spec5 = new PMP_Specification__c();
        Spec5.Name = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Name__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Id__c= '203699';
        Spec5.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec5.PMP_Specification_Type_Nm__c = 'OS';
        Spec5.PMP_Active_Ind__c = true;
        Spec5.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec5.PMP_Partner_Product_Display_Sequence_Nbr__c = 144;
        Spec5.PMP_Specification_Chinese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Japanese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Key__c = '203699';
        
        uploadableSpecifications.add(mainSpec);
        uploadableSpecifications.add(Spec1);
        uploadableSpecifications.add(Spec2);
        uploadableSpecifications.add(Spec3);
        uploadableSpecifications.add(Spec4);
        uploadableSpecifications.add(Spec5);
        
        PMP_Specification_Value__c specValueOS1 = new PMP_Specification_Value__c();
        specValueOS1.Name = 'OS Independent';
        specValueOS1.PMP_Active_Ind__c = true;
        specValueOS1.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS1.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS1.PMP_Product_Specification_Value_Cd__c = '46435';
        specValueOS1.PMP_Product_Specification_Value_Key__c = '46435';
        specValueOS1.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS1.PMP_Specification_Value_Nm__c = 'OS Independent';
        
        PMP_Specification_Value__c specValueOS2 = new PMP_Specification_Value__c();
        specValueOS2.Name = 'Red Hat Linux*';
        specValueOS2.PMP_Active_Ind__c = true;
        specValueOS2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS2.PMP_Product_Specification_Value_Cd__c = '21470';
        specValueOS2.PMP_Product_Specification_Value_Key__c = '21470';
        specValueOS2.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS2.PMP_Specification_Value_Nm__c = 'Red Hat Linux*';
        
        uploadableSpecificationValues.add(specValueOS1);
        uploadableSpecificationValues.add(specValueOS2);
        
        insert uploadableSpecifications;
        insert uploadableSpecificationValues;
        
        PMP_ParseOSJSON.languageCode = 'ja_JP';
        PMP_ParseOSJSON.parseOSJSON('OS_Attribute_Test');
        PMP_Specification__c spec = [SELECT id, PMP_Active_Ind__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c= '203701'];
        System.assertEquals(false, spec.PMP_Active_Ind__c);
        Test.stopTest();
        
    }

    testMethod static void ParseOSChnJSONTest(){
        
        List<PMP_Specification__c> uploadableSpecifications = new List<PMP_Specification__c>();//list containing specifications to be uploaded
        List<PMP_Specification_Value__c> uploadableSpecificationValues = new List<PMP_Specification_Value__c>();//list containing specificationValues to be uploaded
        Test.startTest();
		
        PMP_Specification__c mainSpec = new PMP_Specification__c();
        mainSpec.Name = 'Operating Systems';
        mainSpec.PMP_Specification_Name__c = 'Operating Systems';
        mainSpec.PMP_Partner_Product_Specification_Id__c= 'NPP_OperationSystems';
        mainSpec.PMP_Specification_Type_Nm__c = 'Other';
        mainSpec.PMP_Active_Ind__c = true;
        mainSpec.PMP_Display_Type_Nm__c = 'Label';
        mainSpec.PMP_Mandatory_Offering_Category_Nm__c = 'Not minimum requirement. Optional';
        mainSpec.PMP_Partner_Product_Display_Sequence_Nbr__c = 6900;
        mainSpec.PMP_Specification_Chinese_Nm__c = 'OS';
        mainSpec.PMP_Specification_Japanese_Nm__c = 'OS';
        mainSpec.PMP_Partner_Product_Specification_Key__c = 'npp_operationsystems';
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.Name = 'OS Independent';
        Spec1.PMP_Specification_Name__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Id__c= '203701';
        Spec1.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems'; 
        Spec1.PMP_Specification_Type_Nm__c = 'OS'; 
        Spec1.PMP_Active_Ind__c = true;		
        Spec1.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec1.PMP_Partner_Product_Display_Sequence_Nbr__c = 120;
        Spec1.PMP_Specification_Chinese_Nm__c = 'OS Independent';
        Spec1.PMP_Specification_Japanese_Nm__c = 'OS Independent';
        Spec1.PMP_Partner_Product_Specification_Key__c = '203701';
        
        PMP_Specification__c Spec2 = new PMP_Specification__c();
        Spec2.Name = 'OS Independent family';
        Spec2.PMP_Specification_Name__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Id__c= '21479';
        Spec2.PMP_Product_Parent_Specification_Id__c = '203701';
        Spec2.PMP_Specification_Type_Nm__c = 'OS';
        Spec2.PMP_Active_Ind__c = true;
        Spec2.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec2.PMP_Partner_Product_Display_Sequence_Nbr__c = 200;
        Spec2.PMP_Specification_Chinese_Nm__c = 'OS Independent family';
        Spec2.PMP_Specification_Japanese_Nm__c = 'OS Independent family';
        Spec2.PMP_Partner_Product_Specification_Key__c = '21479';
        
        PMP_Specification__c Spec3 = new PMP_Specification__c();
        Spec3.Name = 'Linux*';
        Spec3.PMP_Specification_Name__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Id__c= '203698';
        Spec3.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec3.PMP_Specification_Type_Nm__c = 'OS';
        Spec3.PMP_Active_Ind__c = true;
        Spec3.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec3.PMP_Partner_Product_Display_Sequence_Nbr__c = 126;
        Spec3.PMP_Specification_Chinese_Nm__c = 'Linux*';
        Spec3.PMP_Specification_Japanese_Nm__c = 'Linux*';
        Spec3.PMP_Partner_Product_Specification_Key__c = '203698';

        PMP_Specification__c Spec4 = new PMP_Specification__c();
        Spec4.Name = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Name__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Id__c= '42027';
        Spec4.PMP_Product_Parent_Specification_Id__c = '203698';
        Spec4.PMP_Specification_Type_Nm__c = 'OS';
        Spec4.PMP_Active_Ind__c = true;
        Spec4.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec4.PMP_Partner_Product_Display_Sequence_Nbr__c = 127;
        Spec4.PMP_Specification_Chinese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Specification_Japanese_Nm__c = 'Red Hat Linux family*';
        Spec4.PMP_Partner_Product_Specification_Key__c = '42027';
        
        PMP_Specification__c Spec5 = new PMP_Specification__c();
        Spec5.Name = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Name__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Id__c= '203699';
        Spec5.PMP_Product_Parent_Specification_Id__c = 'NPP_OperationSystems';
        Spec5.PMP_Specification_Type_Nm__c = 'OS';
        Spec5.PMP_Active_Ind__c = true;
        Spec5.PMP_Display_Type_Nm__c = 'Checkbox';
        Spec5.PMP_Partner_Product_Display_Sequence_Nbr__c = 144;
        Spec5.PMP_Specification_Chinese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Specification_Japanese_Nm__c = 'Microsoft Windows Client*';
        Spec5.PMP_Partner_Product_Specification_Key__c = '203699';
        
        uploadableSpecifications.add(mainSpec);
        uploadableSpecifications.add(Spec1);
        uploadableSpecifications.add(Spec2);
        uploadableSpecifications.add(Spec3);
        uploadableSpecifications.add(Spec4);
        uploadableSpecifications.add(Spec5);
        
        PMP_Specification_Value__c specValueOS1 = new PMP_Specification_Value__c();
        specValueOS1.Name = 'OS Independent';
        specValueOS1.PMP_Active_Ind__c = true;
        specValueOS1.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS1.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS1.PMP_Product_Specification_Value_Cd__c = '46435';
        specValueOS1.PMP_Product_Specification_Value_Key__c = '46435';
        specValueOS1.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS1.PMP_Specification_Value_Nm__c = 'OS Independent';
        
        PMP_Specification_Value__c specValueOS2 = new PMP_Specification_Value__c();
        specValueOS2.Name = 'Red Hat Linux*';
        specValueOS2.PMP_Active_Ind__c = true;
        specValueOS2.PMP_Display_Type_Nm__c = 'Checkbox';
        specValueOS2.PMP_Partner_Off_Roadmap_Ind__c = false;
        specValueOS2.PMP_Product_Specification_Value_Cd__c = '21470';
        specValueOS2.PMP_Product_Specification_Value_Key__c = '21470';
        specValueOS2.PMP_Spec_Value_Type_Nm__c = 'OS';
        specValueOS2.PMP_Specification_Value_Nm__c = 'Red Hat Linux*';
        
        uploadableSpecificationValues.add(specValueOS1);
        uploadableSpecificationValues.add(specValueOS2);
        
        insert uploadableSpecifications;
        insert uploadableSpecificationValues;
        
        PMP_ParseOSJSON.languageCode = 'zh_CN';
        PMP_ParseOSJSON.parseOSJSON('OS_Attribute_Test');
        PMP_Specification__c spec = [SELECT id, PMP_Active_Ind__c FROM PMP_Specification__c WHERE PMP_Partner_Product_Specification_Id__c= '203701'];
        System.assertEquals(false, spec.PMP_Active_Ind__c);
        Test.stopTest();
        
    }*/
}