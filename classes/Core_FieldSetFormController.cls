public with sharing class Core_FieldSetFormController {
    public class FieldSetForm {
            @AuraEnabled
            public List<Core_Field> Fields { get; set; }
            @AuraEnabled
            public String sectionLabel { get; set; }
            @AuraEnabled
            public Boolean hideSectionLabel { get; set; }
            
            public FieldSetForm() {
                Fields = new List<Core_Field>();
            }
        }
    
    @AuraEnabled
    public static List<FieldSetForm> getFormFieldsAndSectionLabel(Id recordId) {
        String type = [Select Id,Core_Opp_OpportunityType__c FROM OpportunityLineItem WHERE id =:recordId].Core_Opp_OpportunityType__c.SubStringBefore(':');
        String objectName = recordId.getSObjectType().getDescribe().getName();
        List<FieldSetForm> form = new List<FieldSetForm>(); 
        List<Core_FieldSet_PageLayout_Config__mdt> metadataResult = new List<Core_FieldSet_PageLayout_Config__mdt>();

            metadataResult = [SELECT Id,Core_Field_Set_Nm__c, Core_Section_Label_Nm__c, Core_Section_Order__c, Core_Type_Nm__c, Core_Object_Nm__c, Core_Hide_Blank_Fields_cb__c
                              FROM Core_FieldSet_PageLayout_Config__mdt WHERE Core_Object_Nm__c =: objectName
                              AND (Core_Type_Nm__c ='Default' OR Core_Type_Nm__c =:type) ORDER BY Core_Section_Order__c ASC];

        for(Core_FieldSet_PageLayout_Config__mdt mdt: metadataResult) {
            FieldSetForm frm = new FieldSetForm();
            frm.Fields = Core_FieldSetUtil.getFields(recordId, objectName, mdt.Core_Field_Set_Nm__c,mdt.Core_Hide_Blank_Fields_cb__c);
            frm.sectionLabel = mdt.Core_Section_Label_Nm__c;
            frm.hideSectionLabel = mdt.Core_Section_Label_Nm__c != null ? false : true;
            form.add(frm);
        }
        system.debug('Form is:'+form);
        return form;
    }
}