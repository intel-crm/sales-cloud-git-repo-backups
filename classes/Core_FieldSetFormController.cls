/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
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
        //sindu added start
        OpportunityLineItem oppLineItemRec=[Select Id,OpportunityId,Core_Status__c,Product2Id,Quantity,Core_Write_In_Product_Name__c,Core_PW_Quantity__c,Core_Opp_OpportunityType__c,ListPrice,Core_Group__c,UnitPrice,Core_Division__c,Core_PW_Sales_Price__c,Core_Owning_BU_ShortName__c,TotalPrice,Core_KPI_Product_Group__c,Core_Production_Win_Total_Price__c,Core_UCD_Global_Account_Name__c,Core_Loss_Cancel_Reason__c,Core_Opp_Product_Segment__c,Core_Loss_Cancel_Details__c,Core_Product_Application__c,Core_Opportunity_Product_ID__c,Core_Intel_vPro_Platform_Eligibility__c,Core_Vendor__c,Core_Is_Product_EOL__c,Core_UCD_Opportunity_Product_Vendor__c,Core_BU_Short_Name__c,/*Core_Advanced_Technology__c,*/Core_BU_Product_Segment__c,Core_Competitor__c,Core_Vendor_InActive__c,Core_Competitor_Product__c,Core_OtherCompetitor_Product_Txt__c,Core_BU_Mapping_record__c,Core_Opportunity_Type_RecordId__c FROM OpportunityLineItem WHERE id =:recordId];
        String type = oppLineItemRec.Core_Opp_OpportunityType__c.SubStringBefore(':');
        //String type = [Select Id,Core_Opp_OpportunityType__c FROM OpportunityLineItem WHERE id =:recordId].Core_Opp_OpportunityType__c.SubStringBefore(':');
        //sindu added end
        String objectName = recordId.getSObjectType().getDescribe().getName();
        List<FieldSetForm> form = new List<FieldSetForm>(); 
        List<Core_FieldSet_PageLayout_Config__mdt> metadataResult = new List<Core_FieldSet_PageLayout_Config__mdt>();

            metadataResult = [SELECT Id,Core_Field_Set_Nm__c, Core_Section_Label_Nm__c, Core_Section_Order__c, Core_Type_Nm__c, Core_Object_Nm__c, Core_Hide_Blank_Fields_cb__c
                              FROM Core_FieldSet_PageLayout_Config__mdt WHERE Core_Object_Nm__c =: objectName
                              AND (Core_Type_Nm__c ='Default' OR Core_Type_Nm__c =:type) ORDER BY Core_Section_Order__c ASC];

        for(Core_FieldSet_PageLayout_Config__mdt mdt: metadataResult) {
            FieldSetForm frm = new FieldSetForm();
            //sindu code added
            frm.Fields = Core_FieldSetUtil.getFieldsOppRec(oppLineItemRec, objectName, mdt.Core_Field_Set_Nm__c,mdt.Core_Hide_Blank_Fields_cb__c);
            //frm.Fields = Core_FieldSetUtil.getFields(recordId, objectName, mdt.Core_Field_Set_Nm__c,mdt.Core_Hide_Blank_Fields_cb__c);
            //sindu code end
            frm.sectionLabel = mdt.Core_Section_Label_Nm__c;
            frm.hideSectionLabel = mdt.Core_Section_Label_Nm__c != null ? false : true;
            form.add(frm);
        }
        system.debug('Form is:'+form);
        return form;
    }
}