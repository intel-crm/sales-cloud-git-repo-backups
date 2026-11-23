public without sharing class Core_MDF_Camp_1 {
    @AuraEnabled
     
    public static List<PartnerFundRequest> loadPFRRecord(String pfrId){
        Set<String> sQueryfields = new Set<String>();
       // List<PartnerFundRequest> pf = new List<PartnerFundRequest>();
        String sanitiziedpfrId = String.escapeSingleQuotes(pfrId);
        String sQuery='SELECT ';
        for(Schema.FieldSetMember f : Schema.SObjectType.PartnerFundRequest.FieldSets.Core_MDF_Activity_FieldList.getFields()) {
            sQueryfields.add(f.getFieldPath());         
        }  
        for(String fs : sQueryfields){
            sQuery += fs + ',';
        }
        System.debug('sqrrr'+sQuery);
        //Added curency and budget amount field 
        //test code begins for Digital Media
        /* sQuery += 'Core_MDF_LinkRequired_Nm__c,Campaign.Name,Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c,'+
            'Campaign.Core_MDF_Reimbursement_Rate__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id,Core_MDF_Budget_Currency_cd__c,'+
            'Core_MDF_Joint_Content_ind__c, Core_MDF_Budget_Amount_Local_amt__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Priorities__c,'+
            'BudgetId,Core_MDF_Channel_Partner__c,Core_MDF_Channel_Partner_Led__c,Core_MDF_Other_Channel_Partner__c,Core_MDF_Country_nm__c,CreatedDate, '+
            'Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name FROM PartnerFundRequest where Id =:sanitiziedpfrId'; */
        
        /*sQuery += 'Campaign.Name,Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c,'+
            'Campaign.Core_MDF_Reimbursement_Rate__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id,Core_MDF_Budget_Currency_cd__c, Core_MDF_Exchange_Rate_ptc__c,Core_MDF_Region_cd__c, Core_MDF_POP_Requirements_txt__c,  '+
            'Core_MDF_Joint_Content_ind__c, Core_MDF_Budget_Amount_Local_amt__c,Core_MDF_Budget_Type_txt__c,Core_MDF_Priorities__c,CreatedDate,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,'+
            'BudgetId,Core_MDF_Channel_Partner_Led__c,Core_MDF_Other_Channel_Partner__c,Core_MDF_Country_nm__c,ChannelPartner.Core_MDF_Channel_Program__c,'+
            'Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name, Campaign.Core_MDF_Campaign_Status__c,Core_MDF_Technology_txt__c,'+
            'Campaign.Core_MDF_Channel_Program__c,Campaign.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Campaign.Core_MDF_Technology__c, Campaign.Status, Campaign.Core_MDF_Market__c, ' +
            ' Campaign.Core_MDF_Approver_1_id__c, Campaign.Core_MDF_Approver_2_id__c, Campaign.Core_MDF_Approver_3_id__c, Campaign.Core_MDF_Approver_4_id__c, Campaign.Core_MDF_Approver_5_id__c, Campaign.Core_MDF_Approver_6_id__c, Campaign.Core_MDF_Approver_7_id__c, Campaign.Core_MDF_Approver_8_id__c, Campaign.Core_MDF_Approver_9_id__c, Campaign.Core_MDF_Approver_10_id__c, Campaign.Core_MDF_Claims_Created_Ind__c FROM PartnerFundRequest WHERE Id =:sanitiziedpfrId';*/
            sQuery += 'Campaign.Name,Campaign.Core_MDF_Supports_legacy_program__c,Campaign.Core_MDF_Is_Opal__c, Campaign.Core_MDF_Priority__c,Campaign.Core_MDF_Opal_Budget_Type_Txt__c,Campaign.Core_MDF_Budget_Type_txt__c,Campaign.Core_MDF_Priority_2_nm__c,Campaign.Core_MDF_Priority_3_nm__c, '+
            ' Campaign.Core_MDF_Reimbursement_Rate__c,ChannelPartner.Name,RecordType.Name,RecordType.DeveloperName,Id, Campaign.Core_MDF_Product_Type__c, '+
            ' CreatedDate,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, '+
            ' ChannelPartner.Core_MDF_Channel_Program__c,'+
            ' Campaign.StartDate, Campaign.EndDate, Campaign.Core_MDF_Account__c, Campaign.Core_MDF_Account__r.Name, Campaign.Core_MDF_Campaign_Status__c, '+
            ' Campaign.Core_MDF_Channel_Program__c,Campaign.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Campaign.Core_MDF_Technology__c, Campaign.Status, Campaign.Core_MDF_Market__c, ' +
            ' Campaign.Core_MDF_Approver_1_id__c, Campaign.Core_MDF_Approver_2_id__c, Campaign.Core_MDF_Approver_3_id__c, Campaign.Core_MDF_Approver_4_id__c, Campaign.Core_MDF_Approver_5_id__c, '+
            ' Campaign.Core_MDF_Approver_6_id__c, Campaign.Core_MDF_Approver_7_id__c, Campaign.Core_MDF_Approver_8_id__c, Campaign.Core_MDF_Approver_9_id__c, Campaign.Core_MDF_Approver_10_id__c, '+
            ' Campaign.Core_MDF_Claims_Created_Ind__c,Campaign.Core_MDF_Available_BudgetCap_amt__c, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__r.name, tolabel(Campaign.Core_MDF_Opal_Budget_Type_Txt__c) localizedBudType FROM PartnerFundRequest WHERE CampaignId =: pfrId';
        //test code ends for Digital Media
                List<PartnerFundRequest> pfrRecord = Database.query(sQuery);
        system.debug('&&&'+pfrRecord);
        
        return pfrRecord;
    }
}