public with sharing class PMP_ListOfferingViewController {

    // public with sharing class PRM_WrapperForOffering {
    //     @auraEnabled public String lifecycle_status {get;set;}//invoice_number
    //     @auraEnabled public String offering_name {get;set;}//distributor_name
    //     @auraEnabled public String view_offering {get;set;}//form_factor
    //     @auraEnabled public string edit_clone_offering {get;set;}//account_number
    //     @auraEnabled public string category {get;set;}//intel_brand
    //     @auraEnabled public string subcategory {get;set;}//product_number
    //     @auraEnabled public Boolean ispublished {get;set;}//invoice_date
    //     @auraEnabled public DateTime lastodifieddate {get;set;}//sales_out_units
    //     @auraEnabled public string lastmodified_name {get;set;}//sales_type
    //     @auraEnabled public String partner_programsegment {get;set;}
    //     @auraEnabled public string translation_status {get;set;}
	// 	@auraEnabled public DateTime createddate {get;set;}
    //     @auraEnabled public string offeringvisibility {get;set;}
    //     @auraEnabled public string comapnyInfo {get;set;}
    //     @auraEnabled public string admin {get;set;}
    // }

    // @AuraEnabled
    //    public static Integer TotalRecords(){
    //        return [Select count() from PMP_Partner_Offering__c];
    //    }
    //    @AuraEnabled(cacheable=true)
    //    public static List<PRM_WrapperForOffering> getOfferingList(Integer pageSize, String offeringName){ 
    //     List<PRM_WrapperForOffering> offeringWrapper = new List<PRM_WrapperForOffering>();
    //     List<PMP_Partner_Offering__c> lstOfOfferingDetails = new List<PMP_Partner_Offering__c>();
    //     Integer pgSize = pageSize;

    //     string query = 'SELECT' +
    //     ' Id, '+
    //     ' Name, '+
    //     ' PMP_Partner_Offering_Nm__c,'+
    //     ' PMP_Active_Step_Txt__c, '+
    //     ' PMP_Current_Step_Txt__c,'+
    //     ' PMP_Review_Comment_Txt__c,'+
    //     ' PMP_Offering_Create_Dt__c,'+
    //     ' PMP_Partner_Offering_Dsc__c,'+
    //     ' PMP_Partner_Offering_Tag_Line_Txt__c,'+
    //     ' PMP_Partner_Offering_Start_Dt__c,'+
    //     ' toLabel(PMP_Partner_Offering_Visibility_Nm__c),'+
    //     ' PMP_Partner_Offering_Lifecycle_Status_Nm__c,'+
    //     ' PMP_Review_Comment_History_Txt__c,'+
    //     ' toLabel(PMP_Business_Segment_Nm__c),'+
    //     ' PMP_Partner_Offering_End_Dt__c,'+
    //     ' PMP_Company_Id__c,'+
    //     ' PMP_Company_Id__r.Name,'+
    //     ' PMP_Offering_Language_Nm__c,'+
    //     ' PMP_Offering_Status_Update_Dt__c,'+
    //     ' PMP_Category_nm__c,'+
    //     ' PMP_Pre_Release_Check_Nm__c,'+
    //     ' PMP_Is_Converted_Ind__c,'+
    //     ' PMP_View_Offerings__c,'+
    //     ' PMP_Edit_Clone_Offering__c,'+
    //     ' PMP_Intel_Admin_Id__c,'+
    //     ' PMP_Is_Published_Ind__c,'+
    //     ' LastModifiedDate,'+
    //     ' LastModifiedBy.Name,'+
    //     ' toLabel(PMP_Translation_Lifecycle_Status_nm__c),'+
    //     ' CreatedDate,'+
    //     ' PMP_Sub_Category_nm__c,'+
    //     ' PMP_Working_Copy_Id__c,'+
    //     ' PMP_Translated_Languages__c'+
    //     ' FROM PMP_Partner_Offering__c';

        //  if(filter = 'All Offerings'){
        //     query+= ' where (PMP_Partner_Offering_Lifecycle_Status_Nm__c !='Published' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c != null AND PMP_Partner_Offering_Nm__c != null AND PMP_Working_Copy_Id__c = null) ORDER BY LastModifiedDate DESC limit :pgSize';
        //  }else if(filter = 'Retired Offerings'){
        //     query+= ' where (PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Retired' AND PMP_Working_Copy_Id__c = null) ORDER BY LastModifiedDate DESC limit :pgSize';
        //  }else if(filter = 'Admin Review Queue'){
        //     query+= ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c == 'Admin Review' ORDER BY LastModifiedDate DESC limit :pgSize';
        //  }

    //     for(PMP_Partner_Offering__c off : database.query(query)){
    //         lstOfOfferingDetails.add(off);
    //     } 
        
    //     PRM_WrapperForOffering wrpr;
    //     for( PMP_Partner_Offering__c td : lstOfOfferingDetails){
    //         wrpr = new PRM_WrapperForOffering();
    //         wrpr.lifecycle_status = td.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
    //         wrpr.offering_name = td.Name;
    //         wrpr.view_offering = td.PMP_View_Offerings__c;
    //         wrpr.edit_clone_offering = td.PMP_Edit_Clone_Offering__c;
    //         wrpr.category = td.PMP_Category_nm__c;
    //         wrpr.subcategory = td.PMP_Sub_Category_nm__c;
    //         wrpr.ispublished = td.PMP_Is_Published_Ind__c;
    //         wrpr.lastodifieddate =td.LastModifiedDate;
    //         wrpr.lastmodified_name = td.LastModifiedBy.Name;
    //         wrpr.partner_programsegment = td.PMP_Business_Segment_Nm__c;
    //         wrpr.translation_status = td.PMP_Translation_Lifecycle_Status_nm__c;
    //         wrpr.createddate = td.CreatedDate;
    //         wrpr.offeringvisibility = td.PMP_Partner_Offering_Visibility_Nm__c;
    //         wrpr.comapnyInfo = td.PMP_Company_Id__r.Name;
    //         wrpr.admin = td.PMP_Intel_Admin_Id__c;
    //         offeringWrapper.add(wrpr);
    //     }
    //     system.debug('offeringWrapper---->'+offeringWrapper);
    //     system.debug('offeringWrappersize---->'+offeringWrapper.size());
    //     return offeringWrapper;
    // }
        

    //    @AuraEnabled(cacheable=true)
    //    public static Integer getNext(Integer v_Offset, Integer v_pagesize){
    //        v_Offset += v_pagesize;
    //        return v_Offset;
    //    }

    //    @AuraEnabled(cacheable=true)
    //    public static Integer getPrevious(Integer v_Offset, Integer v_pagesize){
    //        v_Offset -= v_pagesize;
    //        return v_Offset;
    //    }



    // @AuraEnabled
    // public static List <PMP_Partner_Offering__c> getAccounts() {
    //     return [SELECT Id, name FROM PMP_Partner_Offering__c ORDER BY createdDate ASC];
    // }    
    // @AuraEnabled(cacheable=true)
    // public static List<PMP_Partner_Offering__c> offeringOnSearch(String searchKey) {
    //     String name =  '%' + searchKey + '%';
    //     return [SELECT id, name FROM PMP_Partner_Offering__c WHERE name LIKE :name];
    // }

    // //get the Logged in Users Accout which are associated to him
    // //will return Account list if contact is part of OPID
    // //otherwise will return Account Id he is part of
    // private static Set<Id> currentUserAccounts(){
    //     Set<Id> accountIds = new Set<Id>();
    //     User user = [select Id, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c from User where Id = :UserInfo.getUserId()];//where Id =: currentUserId
    //     if(user.Core_IPA_One_Partner_Id__c != null){
    //         accountIds.add(user.Core_IPA_One_Partner_Id__c);         
    //     }else{
    //         if(user.Core_IPS_AccountId__c !=null){
    //             accountIds.add(user.Core_IPS_AccountId__c);
    //         }
    //     }
    //     return accountIds;
    // }
    
    // @auraEnabled(Cacheable = true)
    // public static List<PMP_WrapperforOffering> getOfferingData(){//
    //     Set<Id> accountIds = currentUserAccounts();
    //     System.debug('You are inside this method from LWC');
        
    //     List<k_v_f_training_detail_sfdcs__x> kvfTraining = new List<k_v_f_training_detail_sfdcs__x>();
    //     for(k_v_f_training_detail_sfdcs__x kvft : [select business_person_id__r.Name,training_id__c,training_complete_dt__c, training_nm__c, business_organization_party_id__r.AccountNumber,training_credit_qty__c,value_exchange_period_txt__c
    //                                                from  k_v_f_training_detail_sfdcs__x where (business_organization_party_id__c in : accountIds or one_partner_customer_aggregation_id__c in :accountIds) order by training_id__c NULLS LAST]){
    //                                                    kvfTraining.add(kvft);
    //                                                }
    //     if(Test.isRunningTest()){
    //         kvfTraining = trainingMocked;
    //     }
    //     System.debug('from OPID :'+kvfTraining);
    //     List<PMP_WrapperforOffering> wrapper = getWrapperData(kvfTraining, '', '');
    //     return wrapper;
    // }

    // public with sharing class PMP_WrapperforOffering {
    //     @auraEnabled public String account_number {get;set;}//account_number
    //     @auraEnabled public string contact_name {get;set;}//contact_name
    //     @auraEnabled public string training_id {get;set;}//training_id
    //     @auraEnabled public string training_name {get;set;}//training_name
    //     @auraEnabled public Decimal training_credits {get;set;}//training_credits
    //     @auraEnabled public string training_completion_date {get;set;}//training_completion_date
	// 	@auraEnabled public string Measurement_Period {get;set;}
    // }
}