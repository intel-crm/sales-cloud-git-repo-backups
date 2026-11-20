public with sharing class PMP_OfferingSearchController {
@AuraEnabled (cacheable=true)
    public static List<PMP_Partner_Offering__c> retrieveListViewData(String keyword,String objectName){
        try{
        List<SObject> recordsOffering = new List<SObject>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
    //     if (objectName == 'PMP_Partner_Offering__c') {
            
    //     searchResults =  [FIND :keyword IN ALL FIELDS RETURNING PMP_Partner_Offering__c 
    //                                                   (Id,Name,PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Published_Copy_Id_Txt__c,
    //                                                    PMP_Company_Id__c,PMP_Company_Id__r.Name,PMP_Intel_Admin_Id__c,PMP_Intel_Admin_Id__r.Name,PMP_Category_nm__c,
    //                                                    PMP_Sub_Category_nm__c,toLabel(PMP_Business_Segment_Nm__c),PMP_Partner_Offering_End_Dt__c,PMP_Pre_Release_Item_Count_Num__c,
    //                                                    CreatedDate,PMP_Partner_Offering_Nm__c,PMP_Translated_Languages__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,PMP_Is_Published_Ind__c,
    //                                                    toLabel(PMP_Translation_Lifecycle_Status_nm__c),toLabel(PMP_Partner_Offering_Visibility_Nm__c)
    //                                           WHERE PMP_Partner_Offering_Lifecycle_Status_Nm__c != 'Published' 
    //                                           AND PMP_Partner_Offering_Lifecycle_Status_Nm__c != ''
    //                                           AND Name != ''
    //                                           AND PMP_Working_Copy_Id__c = '')];
        
    //     for (List<SObject> searchResult : searchResults) {
    //         recordsOffering.addAll(searchResult);
    //     }   
    // }

    if (objectName == 'PMP_Company__c') {
        searchResults =  [FIND :keyword IN ALL FIELDS RETURNING PMP_Company__c 
                          (Id,Name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Account_Id__c,PMP_Intel_Admin_Id__c,
                           PMP_Intel_Admin_Id__r.Name,CreatedDate,PMP_Account_Program_Membership__c,PMP_Partner_Program_nm__c,
                           PMP_Company_Information_Language_Nm__c,toLabel(PMP_Translation_Lifecycle_Status_nm__c),LastModifiedDate 
                           WHERE (PMP_Benefit_Update_Ind__c=false and PMP_Is_Working_Copy_Ind__c = true))];
    //return (PMP_Company__c[])searchResults[0];
        for (List<SObject> searchResult : searchResults) {
            recordsOffering.addAll(searchResult);
        }
        //system.debug('data returned-->'+recordsOffering);
    }
    //IPA2.0: US-TWC729-7976//
    /*if (objectName == 'partner-solution-list') {
        searchResults =  [FIND :keyword IN ALL FIELDS RETURNING ArdiraSurvey__Survey_Result__c 
                                            (Id,PSS_Solution_Name_Id_Txt__c,PSS_Proposal_Name_Txt__c,PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_View_Offering_Txt__c,PSS_Partner_Offering__c,
                                            PSS_Partner_Offering__r.Name,PSS_Programs_Applicable_Nm__c,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,PSS_Survey_Messages_Txt__c,CreatedById,CreatedBy.Name,CreatedDate,Partner_Status__c
                                            WHERE ArdiraSurvey__Progress__c > 0 )];
    //return (ArdiraSurvey__Survey_Result__c[])searchResults[0];
        for (List<SObject> searchResult : searchResults) {
            recordsOffering.addAll(searchResult);
        }
        system.debug('data returned partner-->'+recordsOffering);
    }*/

    return recordsOffering;
        }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        
    }
  

  

}