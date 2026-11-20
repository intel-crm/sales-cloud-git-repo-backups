@isTest
public class PicklistManagerMetadataService_Test {
    static testMethod void pMMetadataTest(){
        PicklistManagerMetadataService.MetadataPort ins1 = new  PicklistManagerMetadataService.MetadataPort();
        PicklistManagerMetadataService.SessionHeader_element ins2 = new  PicklistManagerMetadataService.SessionHeader_element();
        PicklistManagerMetadataService.CustomField ins3 = new  PicklistManagerMetadataService.CustomField();
        PicklistManagerMetadataService.LookupFilter ins4 = new  PicklistManagerMetadataService.LookupFilter();
        PicklistManagerMetadataService.FilterItem ins5 = new  PicklistManagerMetadataService.FilterItem();
        PicklistManagerMetadataService.ValueSet ins6 = new  PicklistManagerMetadataService.ValueSet();
        PicklistManagerMetadataService.ValueSettings ins7 = new  PicklistManagerMetadataService.ValueSettings();
        PicklistManagerMetadataService.ValueSetValuesDefinition ins8 = new  PicklistManagerMetadataService.ValueSetValuesDefinition();
        PicklistManagerMetadataService.CustomValue ins9 = new  PicklistManagerMetadataService.CustomValue();
        PicklistManagerMetadataService.SaveResult ins10 = new  PicklistManagerMetadataService.SaveResult();
        PicklistManagerMetadataService.Error ins11 = new  PicklistManagerMetadataService.Error();
        PicklistManagerMetadataService.ExtendedErrorDetails ins12 = new  PicklistManagerMetadataService.ExtendedErrorDetails();
        PicklistManagerMetadataService.updateMetadata_element ins13 = new  PicklistManagerMetadataService.updateMetadata_element();
        PicklistManagerMetadataService.updateMetadata_element_RT ins14 = new  PicklistManagerMetadataService.updateMetadata_element_RT();
        PicklistManagerMetadataService.updateMetadataResponse_element ins15 = new  PicklistManagerMetadataService.updateMetadataResponse_element();
        PicklistManagerMetadataService.RecordType ins16 = new  PicklistManagerMetadataService.RecordType();
        PicklistManagerMetadataService.RecordTypePicklistValue ins17 = new  PicklistManagerMetadataService.RecordTypePicklistValue();
        PicklistManagerMetadataService.PicklistValue ins18 = new  PicklistManagerMetadataService.PicklistValue();
        PicklistManagerMetadataService.readMetadataResponse_element ins19 = new  PicklistManagerMetadataService.readMetadataResponse_element();
        PicklistManagerMetadataService.readMetadata_element ins20 = new  PicklistManagerMetadataService.readMetadata_element();
        PicklistManagerMetadataService.ReadResult ins21 = new  PicklistManagerMetadataService.ReadResult();
        PicklistManagerMetadataService.updateMetadata_element_GVS ins22 = new  PicklistManagerMetadataService.updateMetadata_element_GVS();
        PicklistManagerMetadataService.GlobalValueSet ins23 = new  PicklistManagerMetadataService.GlobalValueSet();
   
        system.assert(ins18.type=='PicklistValue');        
    }

}