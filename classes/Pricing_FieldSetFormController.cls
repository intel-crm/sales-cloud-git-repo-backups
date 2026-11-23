/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-09-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Pricing_FieldSetFormController {
    public class FieldSetForm {
        @AuraEnabled
        public List<Pricing_Field> Fields { get; set; }
        @AuraEnabled
        public String sectionLabel { get; set; }
        @AuraEnabled
        public Boolean hideSectionLabel { get; set; }
        
        public FieldSetForm() {
            Fields = new List<Pricing_Field>();
        }
    }
    
    @AuraEnabled
    public static List<FieldSetForm> getFormFieldsAndSectionLabel(Id recordId) {
        SBQQ__QuoteLine__c quoteLine = null;
        if(recordId != null) {
            List<SBQQ__QuoteLine__c> quoteLines = [Select Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Payable_Quantity__c,
                                                   Pricing_Approved_End_Date_Dup_Dt__c,Pricing_Approved_Start_Date_Dup_Dt__c, 
                                                   Pricing_Billing_End_Date_Dt__c, Pricing_Billing_Start_Date_Dt__c, 
                                                   Pricing_End_Date_dt__c, Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Start_Date_dt__c,
                                                   Pricing_Revised_Pricing_Start_Date_D_dt__c,Pricing_Last_Credit_Debit_Date_Dt__c,Pricing_Program_Type_Nm__c 
                                                   from SBQQ__QuoteLine__c 
                                                   WHERE Id =: recordId LIMIT 1];
            if(!quoteLines.isEmpty()) {
                quoteLine = quoteLines[0];
            }
        }
        String quoteLineType;
        if(quoteLine != null){                                
         quoteLineType = quoteLine.Pricing_Program_Type_Nm__c;
        }
        String pfile = [Select Name from Profile where Id =: userinfo.getProfileid()].Name;
        Boolean isPartneruser = !String.isblank(pfile) && pfile == 'Partner' ? true : false;
        String objectName = 'SBQQ__QuoteLine__c';
        List<FieldSetForm> form = new List<FieldSetForm>(); 
        List<Pricing_FieldSet_PageLayout_Config__mdt> metadataResult = new List<Pricing_FieldSet_PageLayout_Config__mdt>();
        
        Boolean isRPMUser = Pricing_CommentsController.isPricingManager();
        
        if(isRPMUser) {
            metadataResult = getFormResult(quoteLineType, 'True');
        } else if(isPartneruser) {
            metadataResult = [SELECT Id,Pricing_IQR_Product_Type_Pkl__c, Pricing_Section_Label_Pkl__c, Pricing_Section_Order__c, Pricing_Field_Set_Nm__c,Pricing_Hide_Blank_Fields_cb__c, 
                      Pricing_IsRPM_User__c FROM Pricing_FieldSet_PageLayout_Config__mdt 
                      WHERE Pricing_Is_Active_cb__c =true AND Pricing_Is_Partner_User_cb__c = true AND (Pricing_IsRPM_User__c = 'Default' OR Pricing_IsRPM_User__c = 'False')  
                              AND (Pricing_IQR_Product_Type_Pkl__c ='Default' OR Pricing_IQR_Product_Type_Pkl__c =:quoteLineType) ORDER BY Pricing_Section_Order__c ASC];
        } else {
            metadataResult = getFormResult(quoteLineType, 'False');
        }
        
        for(Pricing_FieldSet_PageLayout_Config__mdt mdt: metadataResult) {
            if(mdt.Pricing_Section_Label_Pkl__c == Label.Pricing_Client_FieldSet_Metadata_Section_Label && !isReadOnlyUser() && !isRPMUser){
                continue;
            }
            FieldSetForm frm = new FieldSetForm();
            frm.Fields = Pricing_FieldSetUtil.getFields(recordId, objectName, mdt.Pricing_Field_Set_Nm__c,mdt.Pricing_Hide_Blank_Fields_cb__c);
            for(Pricing_Field field:frm.Fields){
                if(quoteLine != null){
                    if(field.Type == 'DATE'){
                        field.fieldValue = date.valueOf(quoteLine.get(field.APIName));
                    }
                    if(field.APIName == 'Pricing_Program_Type_Nm__c'){
                        field.programType = String.valueOf(quoteLine.get(field.APIName));
                    }
                    if(field.Type == 'DOUBLE' && field.APIName == 'Pricing_Payable_Quantity__c'){
                        field.doubleFieldValue = (Double)quoteLine.get(field.APIName);
                        field.fieldDisabled = false;

                    }
                }
            }
            frm.sectionLabel = mdt.Pricing_Section_Label_Pkl__c;
            frm.hideSectionLabel = mdt.Pricing_Section_Label_Pkl__c != null ? false : true;
            
            form.add(frm);
        }

        return form;
    }
    
    public static List<Pricing_FieldSet_PageLayout_Config__mdt> getFormResult (String quoteLineType, String isRPMUserApprovedDetails) {
        List<Pricing_FieldSet_PageLayout_Config__mdt> mdtResult = new List<Pricing_FieldSet_PageLayout_Config__mdt>();
        mdtResult = [SELECT Id,Pricing_IQR_Product_Type_Pkl__c, Pricing_Section_Label_Pkl__c, Pricing_Section_Order__c, Pricing_Field_Set_Nm__c ,Pricing_Hide_Blank_Fields_cb__c,
                     Pricing_IsRPM_User__c FROM Pricing_FieldSet_PageLayout_Config__mdt 
                     WHERE Pricing_Is_Active_cb__c = True AND Pricing_Is_Internal_User_cb__c = True AND (Pricing_IsRPM_User__c = 'Default' OR Pricing_IsRPM_User__c = : isRPMUserApprovedDetails)
                     AND (Pricing_IQR_Product_Type_Pkl__c ='Default' OR Pricing_IQR_Product_Type_Pkl__c =:quoteLineType) ORDER BY Pricing_Section_Order__c ASC];
        return mdtResult;
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLineDetails(Id quoteLineId) {
        SBQQ__QuoteLine__c quoteLineRecord = [SELECT Id,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,
                                              Pricing_Approved_End_Date_Dup_Dt__c,Pricing_Approved_Start_Date_Dup_Dt__c, 
                                              Pricing_Billing_End_Date_Dt__c, Pricing_Billing_Start_Date_Dt__c,Pricing_Req_Discounted_Unit_Price__c,
                                              Pricing_End_Date_dt__c, Pricing_Revised_Pricing_Start_Date_dt__c, 
                                              Pricing_Revised_Pricing_Start_Date_D_dt__c,Pricing_Deal_RFQ_Id__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Deal_RFQ_Id__c,
                                              Pricing_Deal_RFQ_Status_Nm__c,Pricing_Change_Request_cb__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.SBQQ__ProductName__c,
                                              SBQQ__ProductName__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Other_Product_Nm__c,
                                              Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c,
                                              Pricing_Meet_Comp_Price_Amt__c,SBQQ__Quote__c,Pricing_Program_Type_Nm__c,Pricing_ECAP_Price_Amt__c
                                              From SBQQ__QuoteLine__c WHERE Id = : quoteLineId LIMIT 1];
        return quoteLineRecord;
    }
    
    @AuraEnabled
    public static Boolean isReadOnlyUser() {
        Boolean isReadOnlyUser = Pricing_QuoteTeam_SharingController.isDPMLegalFinanceUser();
        return isReadOnlyUser;
    }
}