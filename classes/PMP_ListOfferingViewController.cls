public with sharing class PMP_ListOfferingViewController {

    public with sharing class PRM_WrapperForOffering {
        @auraEnabled public String lifecycle_status {get;set;}//invoice_number
        @auraEnabled public String offering_name {get;set;}//distributor_name
        @auraEnabled public String view_offering {get;set;}//form_factor
        @auraEnabled public string edit_clone_offering {get;set;}//account_number
        @auraEnabled public string category {get;set;}//intel_brand
        @auraEnabled public string subcategory {get;set;}//product_number
        @auraEnabled public Boolean ispublished {get;set;}//invoice_date
        @auraEnabled public DateTime lastodifieddate {get;set;}//sales_out_units
        @auraEnabled public string usersName {get;set;}//sales_type
        @auraEnabled public String partner_programsegment {get;set;}
        @auraEnabled public string translation_status {get;set;}
		@auraEnabled public DateTime createddate {get;set;}
        @auraEnabled public string offeringvisibility {get;set;}
        @auraEnabled public string comapnyInfo {get;set;}
        @auraEnabled public string admin {get;set;}
        @auraEnabled public string companyId {get;set;}
        @auraEnabled public string adminName {get;set;}
        @auraEnabled public string lastmodifiedId {get;set;}
        @auraEnabled public string offeringId {get;set;}
    }

    @AuraEnabled
       public static Integer TotalRecords(){
           return [Select count() from PMP_Partner_Offering__c];
       }
       @AuraEnabled(cacheable=true)
       public static List<PRM_WrapperForOffering> getOfferingList(String filter, String searchkey){ 
        List<PRM_WrapperForOffering> offeringWrapper = new List<PRM_WrapperForOffering>();
        List<PMP_Partner_Offering__c> lstOfOfferingDetails = new List<PMP_Partner_Offering__c>();
        //Integer pgSize = pageSize;
        String tempInput = '%' + searchkey + '%';

        string query = 'SELECT' +
        ' Id, '+
        ' Name, '+
        ' PMP_Partner_Offering_Nm__c,'+
        ' PMP_Active_Step_Txt__c, '+
        ' PMP_Current_Step_Txt__c,'+
        ' PMP_Review_Comment_Txt__c,'+
        ' PMP_Offering_Create_Dt__c,'+
        ' PMP_Partner_Offering_Dsc__c,'+
        ' PMP_Partner_Offering_Tag_Line_Txt__c,'+
        ' PMP_Partner_Offering_Start_Dt__c,'+
        ' toLabel(PMP_Partner_Offering_Visibility_Nm__c),'+
        ' PMP_Partner_Offering_Lifecycle_Status_Nm__c,'+
        ' PMP_Review_Comment_History_Txt__c,'+
        ' toLabel(PMP_Business_Segment_Nm__c),'+
        ' PMP_Partner_Offering_End_Dt__c,'+
        ' PMP_Company_Id__c,'+
        ' PMP_Company_Id__r.Name,'+
        ' PMP_Offering_Language_Nm__c,'+
        ' PMP_Offering_Status_Update_Dt__c,'+
        ' PMP_Category_nm__c,'+
        ' PMP_Pre_Release_Check_Nm__c,'+
        ' PMP_Is_Converted_Ind__c,'+
        ' PMP_View_Offerings__c,'+
        ' PMP_Edit_Clone_Offering__c,'+
        ' PMP_Intel_Admin_Id__c,'+
        ' PMP_Intel_Admin_Id__r.Name,'+
        ' PMP_Is_Published_Ind__c,'+
        ' LastModifiedDate,'+
        ' LastModifiedBy.Name,'+
        ' LastModifiedById,'+
        ' toLabel(PMP_Translation_Lifecycle_Status_nm__c),'+
        ' CreatedDate,'+
        ' PMP_Sub_Category_nm__c,'+
        ' PMP_Working_Copy_Id__c,'+
        ' PMP_Translated_Languages__c'+
        ' FROM PMP_Partner_Offering__c';
        // ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c !=\'Published\''+
        // ' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c != null'+ 
        // ' AND PMP_Partner_Offering_Nm__c != null' +
        // ' AND PMP_Working_Copy_Id__c = null'+
        // ' ORDER BY LastModifiedDate DESC'+
        // ' limit :pgSize';
        System.debug('searchkey-->'+searchkey);
        System.debug('tempinput-->'+tempInput);
         if(filter == 'All Offerings'){
            query+= ' where (PMP_Partner_Offering_Lifecycle_Status_Nm__c !=\'Published\' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c != null AND PMP_Partner_Offering_Nm__c != null AND PMP_Working_Copy_Id__c = null)';
         }else if(filter == 'Retired Offerings'){
            query+= ' where (PMP_Partner_Offering_Lifecycle_Status_Nm__c = \'Retired\' AND PMP_Working_Copy_Id__c = null)';
         }else if(filter == 'Admin Review Queue'){
            query+= ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c = \'Admin Review\'';
         }
         if(String.isNotBlank(searchKey)){
            query+= ' AND Name LIKE: tempInput ORDER BY LastModifiedDate DESC';
         }else{
            query+= ' ORDER BY LastModifiedDate DESC';
         }
         lstOfOfferingDetails= database.query(query);

        // for(PMP_Partner_Offering__c off : database.query(query)){
        //     lstOfOfferingDetails.add(off);
        // } 
        
        PRM_WrapperForOffering wrpr;
        for( PMP_Partner_Offering__c td : lstOfOfferingDetails){
            wrpr = new PRM_WrapperForOffering();
            wrpr.lifecycle_status = td.PMP_Partner_Offering_Lifecycle_Status_Nm__c;
            wrpr.offering_name = td.Name;
            wrpr.view_offering = String.valueof(td.PMP_View_Offerings__c);
            wrpr.edit_clone_offering = td.PMP_Edit_Clone_Offering__c;
            wrpr.category = td.PMP_Category_nm__c;
            wrpr.subcategory = td.PMP_Sub_Category_nm__c;
            wrpr.ispublished = td.PMP_Is_Published_Ind__c;
            wrpr.lastodifieddate =td.LastModifiedDate;
            wrpr.usersName = td.LastModifiedBy.Name;
            wrpr.lastmodifiedId = td.LastModifiedById;
            wrpr.partner_programsegment = td.PMP_Business_Segment_Nm__c;
            wrpr.translation_status = td.PMP_Translation_Lifecycle_Status_nm__c;
            wrpr.createddate = td.CreatedDate;
            wrpr.offeringvisibility = td.PMP_Partner_Offering_Visibility_Nm__c;
            wrpr.comapnyInfo = td.PMP_Company_Id__r.Name;
            wrpr.admin = td.PMP_Intel_Admin_Id__c;
            wrpr.adminName = td.PMP_Intel_Admin_Id__r.Name;
            wrpr.companyId = td.PMP_Company_Id__c;
            wrpr.offeringId = td.Id;
            offeringWrapper.add(wrpr);
        }
        system.debug('offeringWrapper---->'+offeringWrapper);
        system.debug('offeringWrappersize---->'+offeringWrapper.size());
        return offeringWrapper;
    }
        

       @AuraEnabled(cacheable=true)
       public static Integer getNext(Integer v_Offset, Integer v_pagesize){
           v_Offset += v_pagesize;
           return v_Offset;
       }

       @AuraEnabled(cacheable=true)
       public static Integer getPrevious(Integer v_Offset, Integer v_pagesize){
           v_Offset -= v_pagesize;
           return v_Offset;
       }



    @AuraEnabled
    public static List <PMP_Partner_Offering__c> getAccounts() {
        return [SELECT Id, name FROM PMP_Partner_Offering__c ORDER BY createdDate ASC];
    }    
    @AuraEnabled(cacheable=true)
    public static List<PMP_Partner_Offering__c> offeringOnSearch(String searchKey) {
        String name =  '%' + searchKey + '%';
        return [SELECT id, name FROM PMP_Partner_Offering__c WHERE name LIKE :name];
    }

    
}