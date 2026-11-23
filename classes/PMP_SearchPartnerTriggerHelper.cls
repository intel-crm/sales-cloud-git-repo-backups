public without sharing class PMP_SearchPartnerTriggerHelper {
    public static void syncPublishedPartnerCopy(List<PMP_Company__c> triggeredpartners, map<Id,PMP_Company__c> oldMap){
        Map<Id,PMP_Company__c> aprroved_partners_Map = new Map<Id,PMP_Company__c>();
        Boolean isIntelAdmin = PMP_SearchUtilityController.isIntelAdmin();
        //system.debug('isIntelAdmin => '+isIntelAdmin);
        for(PMP_Company__c p : triggeredpartners){
            //As a part of US US682872, added this condition in if -- ||isIntelAdmin
            if(p.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved && (p.PMP_Company_Lifecycle_Status_Nm__c != oldMap.get(p.Id).PMP_Company_Lifecycle_Status_Nm__c || isIntelAdmin ) &&
               p.PMP_Is_Working_Copy_Ind__c == true){                  
                   aprroved_partners_Map.put(p.Id,p);
               }
        }
        //system.debug('aprroved_partners_Map => '+aprroved_partners_Map);
            pushToPublishedCopy(aprroved_partners_Map, triggeredpartners, oldMap);
    }
    
    public static void pushToPublishedCopy(map<Id,PMP_Company__c> aprroved_partners_Map, List<PMP_Company__c> triggeredpartners, map<Id,PMP_Company__c> oldMap){
        List<PMP_Company__c> exsiting_partners_published = new List<PMP_Company__c>();
        List<PMP_Company_Resource__c> exsiting_partner_resources_todelete;
        List<PMP_Company_Translation__c> exsiting_partner_translations_todelete;
        List<PMP_Partner_Category__c> exsiting_partner_categories_todelete;
        List<PMP_Company_Region__c> exsiting_partner_regions_todelete;  
        //List<PMP_Company_Message__c> exsiting_partner_messages_todelete;          
        
        List<PMP_Company_Resource__c> new_partner_resources_cloned = new List<PMP_Company_Resource__c>();
        List<PMP_Company_Translation__c> new_partner_translations_cloned;
        List<PMP_Partner_Category__c> new_partner_categories_cloned;
        List<PMP_Company_Region__c> new_partner_regions_cloned;
        //List<PMP_Company_Message__c> new_partner_messages_cloned;          
        
        Map<Id,Id> partners_published_working_map = new map<Id,Id>();
        Set<Id> partners_published_working_set = new Set<Id>();
        List<PMP_company__c> published_partners = new List<PMP_company__c>();
        if(Schema.sObjectType.PMP_Company__c.isAccessible() && !aprroved_partners_Map.isEmpty()){  //ApexCRUDViolation Fix
            published_partners = [SELECT Id,Name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Account_Application__c,
                                  PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Lead_Gen_Language_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,
                                  PMP_Account_Dsc__c,PMP_Account_Industry__c,PMP_Account_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Information_Language_Nm__c,
                                  PMP_Company_Resource__c,PMP_Working_Copy_Id__c,PMP_Translation_Lifecycle_Status_nm__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c IN: aprroved_partners_Map.keySet()];
        }
        //system.debug('published_partners => '+published_partners);
        for(PMP_company__c p : published_partners){
            PMP_company__c partner_work_copy = aprroved_partners_Map.containsKey(p.PMP_Working_Copy_Id__c) ? aprroved_partners_Map.get(p.PMP_Working_Copy_Id__c) : null;
            //system.debug('partner_work_copy => '+partner_work_copy);
            if(partner_work_copy != null){
                PMP_company__c p_cloned             = partner_work_copy.clone(false,false,true,true);
                p_cloned.Id                   = p.id;
                p_cloned.PMP_Working_Copy_Id__c         = partner_work_copy.Id;
                p_cloned.PMP_Published_Copy_Id__c         = null;                
                p_cloned.PMP_Company_Lifecycle_Status_Nm__c   = PMP_StaticConstants_Partner.Published;
                p_cloned.PMP_Is_Published_Ind__c         = true; 
                p_cloned.PMP_Is_Working_Copy_Ind__c       = false;   
                p_cloned.PMP_Translation_Lifecycle_Status_nm__c = partner_work_copy.PMP_Translation_Lifecycle_Status_nm__c;
                p_cloned.PMP_Translated_Languages_Txt__c       = partner_work_copy.PMP_Translated_Languages_Txt__c;
                p_cloned.PMP_Account_Website__c = partner_work_copy.PMP_Account_Website__c;
                //p_cloned.CreatedById            = partner_work_copy.CreatedById;
                p_cloned.PMP_Company_Status_Update_Dt__c  = system.today();
                //TWC1824-3948 - Added by Vardaan --start
                p_cloned.PMP_Disti_Components_Nm__c= partner_work_copy.PMP_Disti_Components_Nm__c;
                p_cloned.PMP_Disti_Sys_Solutions_Nm__c = partner_work_copy.PMP_Disti_Sys_Solutions_Nm__c;
                //TWC1824-3948 - Added by Vardaan --end
                partners_published_working_set.add(p.PMP_Working_Copy_Id__c);
                partners_published_working_map.put(p.PMP_Working_Copy_Id__c,p.PMP_Working_Copy_Id__c);
                
                exsiting_partners_published.add(p_cloned);
            }
        }
        //system.debug('exsiting_partners_published => '+exsiting_partners_published);
        if(!exsiting_partners_published.isEmpty()){
            // if(Schema.sObjectType.PMP_Company__c.isUpdateable()){ //ApexCRUDViolation Fix
            update exsiting_partners_published;
            //clearPlatformCache(exsiting_partners_published); 
            // }
            clearPlatformCache(exsiting_partners_published); 
        
            // if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()) { //ApexCRUDViolation Fix
            exsiting_partner_resources_todelete = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c IN: exsiting_partners_published]; 
            //AND (PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Partner.IMAGE OR PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Partner.THUMBNAIL_IMAGE)];
            // }
            // if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()) {
            //String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
            exsiting_partner_translations_todelete   = [SELECT Id, PMP_Company_Information_Id__c from PMP_Company_Translation__c where PMP_Company_Information_Id__c IN: exsiting_partners_published]; // AND PMP_Field_Nm__c != :streamIdName]; 
            //  }
            // if(Schema.sObjectType.PMP_Partner_Category__c.isAccessible()) {
            exsiting_partner_categories_todelete   = [SELECT Id, PMP_Partner_Id__c from PMP_Partner_Category__c  where PMP_Partner_Id__c IN: exsiting_partners_published]; 
            //  }
            //   if(Schema.sObjectType.PMP_Company_Region__c.isAccessible()) {
            exsiting_partner_regions_todelete     = [SELECT Id, PMP_Company_Id__c from PMP_Company_Region__c  where PMP_Company_Id__c IN: exsiting_partners_published]; 
            //exsiting_partner_messages_todelete     = [SELECT Id, PMP_Company_Id__c  from PMP_Company_Message__c  where PMP_Company_Id__c IN: exsiting_partners_published];         
            //   }
            
            new_partner_resources_cloned   = createResources(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
            new_partner_translations_cloned = createTranslations(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
            new_partner_categories_cloned   = createCategories(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
            new_partner_regions_cloned     = createRegions(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
            //new_partner_messages_cloned   = createMessages(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
            
        //system.debug('new_resources_cloned before => '+new_partner_resources_cloned);        
        if(new_partner_resources_cloned!=Null && !new_partner_resources_cloned.isEmpty()){
            //  if(Schema.sObjectType.PMP_Company_Resource__c.isCreateable()){  //ApexCRUDViolation Fix
            insert new_partner_resources_cloned;
            // }
        }
        if(new_partner_translations_cloned!=Null && !new_partner_translations_cloned.isEmpty()){
            // if(Schema.sObjectType.PMP_Company_Translation__c.isCreateable()){
            insert new_partner_translations_cloned;
            //}
        }
        if(new_partner_categories_cloned!=Null && !new_partner_categories_cloned.isEmpty()){
            // if(Schema.sObjectType.PMP_Partner_Category__c.isCreateable()){
            insert new_partner_categories_cloned;
            //}
        }
        if(new_partner_regions_cloned!=Null && !new_partner_regions_cloned.isEmpty()){
            //if(Schema.sObjectType.PMP_Company_Region__c.isCreateable()){
            insert new_partner_regions_cloned;
            //}
        }
        }
        /*
if(!new_partner_messages_cloned.isEmpty()){
insert new_partner_messages_cloned;
} 
*/
                      
        if(exsiting_partner_resources_todelete!=Null && !exsiting_partner_resources_todelete.isEmpty()){
            //if(Schema.sObjectType.PMP_Company_Resource__c.isDeletable()){ //ApexCRUDViolation Fix
            Delete exsiting_partner_resources_todelete;
            //}
        }
        if(exsiting_partner_translations_todelete!=Null && !exsiting_partner_translations_todelete.isEmpty()){
            // if(Schema.sObjectType.PMP_Company_Translation__c.isDeletable()){
            Delete exsiting_partner_translations_todelete;
            //}
        }
        if(exsiting_partner_categories_todelete!=Null && !exsiting_partner_categories_todelete.isEmpty()){
            // if(Schema.sObjectType.PMP_Partner_Category__c.isDeletable()){
            Delete exsiting_partner_categories_todelete;
            //}
        }
        if(exsiting_partner_regions_todelete!=Null && !exsiting_partner_regions_todelete.isEmpty()){
            //if(Schema.sObjectType.PMP_Company_Region__c.isDeletable()){
            Delete exsiting_partner_regions_todelete;
            //}
        }
        /*
if(!exsiting_partner_messages_todelete.isEmpty()){
Delete exsiting_partner_messages_todelete;
}
*/
    } 
    
    public static List<PMP_Company_Resource__c> createResources(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Company_Resource__c> cloned_resource_lst = new List<PMP_Company_Resource__c>();
        List<PMP_Company_Resource__c> partners_working_res_list;
        Set<Id> res_workcopy_doc_ids = new Set<Id>(); 
        List<ContentVersion>  versions_workcopy_lst;
        List<ContentVersion> new_version_lst = new List<ContentVersion>();
        Set<Id> new_version_set = new Set<Id>();
        Map<String,Id> workcopy_content_doc_map = new Map<String,Id>();
        Map<Id,Id> new_content_doc_map = new Map<Id,Id>();
        Map<Id, Id> contentIdAndWorkingCopyId = new Map<Id, Id>();
        
        DescribeSObjectResult partner_res_fields = PMP_Company_Resource__c.getSObjectType().getDescribe();   
        List<String> partner_res_field_names = new List<String>( partner_res_fields.fields.getMap().keySet() ); 
        if(!partners_published_working_set.isEmpty()){
        String partner_res_query_str =  ' SELECT ' + String.join( partner_res_field_names, ',' ) + ' FROM ' + partner_res_fields.getName() + ' WHERE ' + ' PMP_Company_Id__c  IN : partners_published_working_set';   
        //system.debug('partner_res_query_str => '+partner_res_query_str);
        //partners_working_res_list = Database.query(partner_res_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        partners_working_res_list = Database.query(String.escapeSingleQuotes(partner_res_query_str));
        //system.debug('partners_working_res_list => '+partners_working_res_list);
        
        
        for(PMP_Company_Resource__c res : partners_working_res_list){
            if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_Partner.IMAGE || res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_Partner.THUMBNAIL_IMAGE){
                res_workcopy_doc_ids.add(res.PMP_Company_Image__c);
                contentIdAndWorkingCopyId.put(res.PMP_Company_Image__c, res.PMP_Company_Id__c);
            }
        }
    }
        
        //system.debug('res_workcopy_doc_ids => '+res_workcopy_doc_ids);
        if(!res_workcopy_doc_ids.isEmpty()){
        versions_workcopy_lst = [SELECT Id, ContentDocumentId,Title, NetworkId, IsLatest, PathOnClient,FirstPublishLocationId, Description, RatingCount, VersionData, FileExtension 
                                 FROM ContentVersion where ContentDocumentId IN: res_workcopy_doc_ids AND IsLatest=true];
        
        //system.debug('versions_workcopy_lst => '+versions_workcopy_lst);
        Map<Id, ContentVersion> wcContentIdAndPubCopyContent = new Map<Id, ContentVersion>();
        if(!versions_workcopy_lst.isEmpty() ){
        for(ContentVersion v : versions_workcopy_lst){
            string blob_to_str;
            ContentVersion new_version = new ContentVersion();
            new_version.Title  = v.Title;
            new_version.PathOnClient  = v.PathOnClient;
            new_version.VersionData = v.VersionData;
            new_version.NetworkId = v.NetworkId;
            blob_to_str = EncodingUtil.base64Encode(v.VersionData);
            workcopy_content_doc_map.put(blob_to_str,v.ContentDocumentId);                   
            new_version_lst.add(new_version);
            wcContentIdAndPubCopyContent.put(v.ContentDocumentId, new_version);
        }
        }
        /*if(!new_version_lst.isEmpty()){
insert new_version_lst;
}
*/
        if(wcContentIdAndPubCopyContent.size() > 0) {
            insert wcContentIdAndPubCopyContent.values();
        }
         
        Map<Id, Id> workingCopyIdAndPubCopyId = new Map<Id, Id>();
        Map<Id, Id> pcContIdAndWorkCopyId = new Map<Id, Id>();
        Set<Id> pubCopyIds = new Set<Id>();
        List<ContentDocumentLink> publishedPartnerLinksToSave = new List<ContentDocumentLink>();
        for(PMP_Company__c ext_partner : exsiting_partners_published){
            workingCopyIdAndPubCopyId.put(ext_partner.PMP_Working_Copy_Id__c, ext_partner.Id);
            pubCopyIds.add(ext_partner.Id);
        }
        
        if(pubCopyIds.size() > 0) {
            List<ContentDocumentLink> deleteContDocLinks = new List<ContentDocumentLink>();
            if(pubCopyIds.size() == 1) {
                deleteContDocLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :pubCopyIds];           
            } else {
                deleteContDocLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :pubCopyIds];
            }
            
            if(deleteContDocLinks.size() > 0) {
                delete deleteContDocLinks;
            }  
        }
        if(!wcContentIdAndPubCopyContent.isEmpty()){
        Map<Id,ContentVersion> contVersions = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :wcContentIdAndPubCopyContent.values()]);
        for(Id wcContId : wcContentIdAndPubCopyContent.keySet()) {
            String docID = contVersions.get(wcContentIdAndPubCopyContent.get(wcContId).Id).ContentDocumentId;
            pcContIdAndWorkCopyId.put(docID, contentIdAndWorkingCopyId.get(wcContId));
        }
        
        
        //system.debug('new_version_lst => '+new_version_lst);
        for(ContentVersion new_ver : contVersions.values()){
            String temp = pcContIdAndWorkCopyId.get(new_ver.ContentDocumentId);
            String entityId = workingCopyIdAndPubCopyId.get(temp);
            if(entityId != NULL) {
                ContentDocumentLink cd_link = new ContentDocumentLink();
                cd_link.ContentDocumentId = new_ver.ContentDocumentId ;//Add ContentDocumentId
                //cd_link.LinkedEntityId = wrkPubIdMap.get(wcId);//Add attachment parentId
                cd_link.LinkedEntityId = entityId; //Add attachment parentId
                cd_link.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                cd_link.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
                publishedPartnerLinksToSave.add(cd_link);   
            }
            new_version_set.add(new_ver.Id);
        }
        }
        
        if(publishedPartnerLinksToSave.size() > 0) {
            insert publishedPartnerLinksToSave;
        }
        if(!new_version_set.isEmpty()){
        for(ContentVersion cv : [SELECT Id, ContentDocumentId,VersionData FROM ContentVersion where Id IN: new_version_set AND IsLatest=true]){
            string blobTostr = EncodingUtil.base64Encode(cv.VersionData);
            new_content_doc_map.put(workcopy_content_doc_map.get(blobTostr),cv.ContentDocumentId);
        } 
        }
        //system.debug('new_content_doc_map => '+new_content_doc_map);
        if(!partners_working_res_list.isEmpty()){
        for(PMP_Company_Resource__c res_workcopy : partners_working_res_list){
            PMP_Company_Resource__c res_cloned = new PMP_Company_Resource__c();
            res_cloned = res_workcopy.clone(false,false,true,true);
            //system.debug('res_cloned => '+res_cloned);
            res_cloned.PMP_Company_Id__c = workingCopyIdAndPubCopyId.get(res_workcopy.PMP_Company_Id__c);
            /*
for(PMP_Company__c ext_partner : exsiting_partners_published){
system.debug('ext_partner.PMP_Working_Copy_Id__c => '+ext_partner.PMP_Working_Copy_Id__c);
system.debug('partners_published_working_map => '+partners_published_working_map);
system.debug('res_workcopy.PMP_Company_Id__c => '+res_workcopy.PMP_Company_Id__c);
if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(res_workcopy.PMP_Company_Id__c))
res_cloned.PMP_Company_Id__c = ext_partner.Id;
}
*/
            res_cloned.CreatedById = res_workcopy.CreatedById;
            res_cloned.PMP_Company_Image__c = new_content_doc_map.get(res_workcopy.PMP_Company_Image__c); 
            cloned_resource_lst.add(res_cloned);
        }
        }
        }
        return cloned_resource_lst;
    }
    
    public static List<PMP_Company_Translation__c> createTranslations(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        List<PMP_Company_Translation__c> cloned_translations_lst = new List<PMP_Company_Translation__c>();    
        DescribeSObjectResult partner_trans_fields = PMP_Company_Translation__c.getSObjectType().getDescribe();   
        List<String> partner_trans_field_names = new List<String>( partner_trans_fields.fields.getMap().keySet() );
        if(!partners_published_working_set.isEmpty()){
        String partner_trans_query_str =    ' SELECT ' + String.join( partner_trans_field_names, ',' ) + ' FROM '+partner_trans_fields.getName() + ' WHERE ' + ' PMP_Company_Information_Id__c  IN : partners_published_working_set AND PMP_Field_Nm__c != :streamIdName';   
        //List<PMP_Company_Translation__c> partners_working_trans_list = Database.query(partner_trans_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Company_Translation__c> partners_working_trans_list = Database.query(String.escapeSingleQuotes(partner_trans_query_str));
        
        for(PMP_Company_Translation__c trans_workcopy : partners_working_trans_list){
            PMP_Company_Translation__c trans_cloned = new PMP_Company_Translation__c();
            trans_cloned = trans_workcopy.clone(false,false,true,true);
            //system.debug('trans_cloned => '+trans_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                // system.debug('ext_partner.PMP_Working_Copy_Id__c_trns => '+ext_partner.PMP_Working_Copy_Id__c);
                // system.debug('partners_published_working_map_trns => '+partners_published_working_map);
                // system.debug('trans_workcopy.PMP_Company_Information_Id__c => '+trans_workcopy.PMP_Company_Information_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(trans_workcopy.PMP_Company_Information_Id__c))
                    trans_cloned.PMP_Company_Information_Id__c = ext_partner.Id;
            }
            trans_cloned.CreatedById = trans_workcopy.CreatedById;
            cloned_translations_lst.add(trans_cloned);
        } 
        }
        return cloned_translations_lst;
    }
    
    public static List<PMP_Partner_Category__c> createCategories(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Partner_Category__c> cloned_categories_lst = new List<PMP_Partner_Category__c>();  
        DescribeSObjectResult partner_cat_fields = PMP_Partner_Category__c.getSObjectType().getDescribe();   
        List<String> partner_cat_field_names = new List<String>( partner_cat_fields.fields.getMap().keySet() );   
        if(!partners_published_working_set.isEmpty()){ 
        String partner_cat_query_str =    ' SELECT ' + String.join( partner_cat_field_names, ',' ) + ' FROM '+partner_cat_fields.getName() + ' WHERE ' + ' PMP_Partner_Id__c  IN : partners_published_working_set';   
        // List<PMP_Partner_Category__c> partners_working_cat_list = Database.query(partner_cat_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Partner_Category__c> partners_working_cat_list = Database.query(String.escapeSingleQuotes(partner_cat_query_str));
        for(PMP_Partner_Category__c cat_workcopy : partners_working_cat_list){
            PMP_Partner_Category__c cat_cloned = new PMP_Partner_Category__c();
            cat_cloned = cat_workcopy.clone(false,false,true,true);
            //system.debug('cat_cloned => '+cat_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                // system.debug('ext_partner.PMP_Working_Copy_Id__c_cat => '+ext_partner.PMP_Working_Copy_Id__c);
                // system.debug('partners_published_working_map_trns_cat => '+partners_published_working_map);
                // system.debug('cat_workcopy.PMP_Company_Id__c => '+cat_workcopy.PMP_Partner_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(cat_workcopy.PMP_Partner_Id__c)){
                    cat_cloned.PMP_Partner_Id__c = ext_partner.Id;
                    //cat_cloned.PMP_Category_Id__c = cat_workcopy.PMP_Category_Id__c;                    
                }
            }
            cat_cloned.CreatedById = cat_workcopy.CreatedById;
            cloned_categories_lst.add(cat_cloned);
        }
    }                   
        return cloned_categories_lst;
    }
    
    public static List<PMP_Company_Region__c> createRegions(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Company_Region__c> cloned_regions_lst = new List<PMP_Company_Region__c>();  
        DescribeSObjectResult partner_region_fields = PMP_Company_Region__c.getSObjectType().getDescribe();   
        List<String> partner_regions_field_names = new List<String>( partner_region_fields.fields.getMap().keySet() ); 
        if(!partners_published_working_set.isEmpty()){
        String partner_reg_query_str =    ' SELECT ' + String.join( partner_regions_field_names, ',' ) + ' FROM '+partner_region_fields.getName() + ' WHERE ' + ' PMP_Company_Id__c  IN : partners_published_working_set';   
        //List<PMP_Company_Region__c> partners_working_regions_list = Database.query(partner_reg_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Company_Region__c> partners_working_regions_list = Database.query(String.escapeSingleQuotes(partner_reg_query_str));
        for(PMP_Company_Region__c reg_workcopy : partners_working_regions_list){
            PMP_Company_Region__c reg_cloned = new PMP_Company_Region__c();
            reg_cloned = reg_workcopy.clone(false,false,true,true);
            //system.debug('reg_cloned => '+reg_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                // system.debug('ext_partner.PMP_Working_Copy_Id__c_reg => '+ext_partner.PMP_Working_Copy_Id__c);
                // system.debug('partners_published_working_map_reg => '+partners_published_working_map);
                // system.debug('reg_workcopy.PMP_Company_Id__c => '+reg_workcopy.PMP_Company_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(reg_workcopy.PMP_Company_Id__c))
                    reg_cloned.PMP_Company_Id__c = ext_partner.Id;
            }
            reg_cloned.CreatedById = reg_workcopy.CreatedById;
            cloned_regions_lst.add(reg_cloned);
        } 
        }
        
        return cloned_regions_lst;
    } 
    /**
* @description This method will be used to clear cache when published partner is updated after 
*              the edited working copy is approved.
* 
* @param List of PMP_Company__c 
* @return Void
* @UserStory PRC Performance
**/
    public static void clearPlatformCache(List <PMP_Company__c> partnerList){
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
        /* cache will be different for different languages. Ex- For english language user - [partnerId+'en']
to dynamically create the key, we need to get the different langauges in which partner can be translated hence we are using the metadata */
        
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMetadata = [Select PMP_Locale_Nm__c from PMP_Locale_To_FieldAPINm_Mapping__mdt
                                                                      Where PMP_Object_Nm__c = 'Partner_Translation'];
        
        //iteratre over the published partners and check clear cache related to the partner.
        for ( PMP_Company__c partner : partnerList ){
            
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt meta : localeMetadata){
                string key;
                if(meta.PMP_Locale_Nm__c == 'ja'){
                    key = partner.id + 'ja';
                }
                else{
                    key = partner.id + meta.PMP_Locale_Nm__c.replace('_', '');
                }
                
                
                if(Cache.Org.contains(partitionInput+'.'+ key)){
                    Cache.Org.remove(partitionInput+'.'+key);
                }
            }
        }
    } 
    
    public static void createTranslationForRSSFeed(List<PMP_Company__c> partners, Map<Id, PMP_Company__c> oldMap) {
        
        if(partners != NULL) {
            
            Set<Id> companyIds = new Set<Id>();
            List<PMP_Company_Translation__c> translations = new List<PMP_Company_Translation__c>();
            String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');      // Get the StreamId name from PMP Static Data
            
            for(PMP_Company__c comp : partners) {
                PMP_Company__c oldComp = oldMap != NULL ? oldMap.get(comp.Id) : new PMP_Company__c();
                /*
if(comp.PMP_Is_Published_Ind__c && comp.PMP_Company_Lifecycle_Status_Nm__c != oldComp.PMP_Company_Lifecycle_Status_Nm__c && 
comp.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Published) { // Collect the publised status company Ids
*/                  
                if(comp.PMP_Is_Working_Copy_Ind__c && comp.PMP_Company_Lifecycle_Status_Nm__c != oldComp.PMP_Company_Lifecycle_Status_Nm__c && 
                   comp.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved) {
                       companyIds.add(comp.Id);
                   }
            }
            
            if(companyIds.size() > 0 && !companyIds.isEmpty()) {
                for(PMP_Company__c comp : [SELECT Id,Name,(SELECT Id FROM PMP_Company_Information_Translations__r WHERE PMP_Field_Nm__c = :streamIdName) FROM PMP_Company__c WHERE Id IN :companyIds]) {    //Query the existing streamId translation record
                    if(comp.PMP_Company_Information_Translations__r.size() == 0) {  // If old record exist no need to create new Translation records
                        translations.add(new PMP_Company_Translation__c(Name=comp.Name,PMP_Company_Information_Id__c=comp.Id,PMP_Field_Nm__c=streamIdName));    // Create the new Translation record
                    }
                }
                if(translations.size() > 0 && Schema.sObjectType.PMP_Company_Translation__c.isCreateable()) {
                    insert translations;    // Insert new Company Translation records
                }
            }
        }
    }
    public static void deactivateIntelAccountMP(List<PMP_Company__c> partners, Map<Id,PMP_Company__c> oldMap){
        
        Set<Id> accIds = new Set<Id>(); 
        Set<Id> intelAccIds = new Set<Id>(); 
        //List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        
		//New code Added by Tilak
		PMP_Utility utilityHelper = new PMP_Utility();
		Map<Id,List<Account>> AllAccountRelatedToMPI = utilityHelper.getAllAccountRelatedToMPI(partners);
		
		
        for(PMP_Company__c part : partners) 
		{
			PMP_Company__c oldPartner = oldMap != null && oldMap.get(part.Id) != null ? oldMap.get(part.Id) : new PMP_Company__c();
            /*
            if(part.PMP_Is_Published_Ind__c && part.PMP_Company_Lifecycle_Status_Nm__c != oldPartner.PMP_Company_Lifecycle_Status_Nm__c && 
               part.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Published && part.PMP_Account_Id__c != null) 
			   {
                   accIds.add(part.PMP_Account_Id__c);
               }
			   */
			//New Code Added by Tilak
			List<Account> partRelatedAccountList = AllAccountRelatedToMPI.get(part.id);
            if(part.PMP_Is_Published_Ind__c && part.PMP_Company_Lifecycle_Status_Nm__c != oldPartner.PMP_Company_Lifecycle_Status_Nm__c && 
               part.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Published ) 
			{
				for(Account singleAccount: partRelatedAccountList)
				{
					accIds.add(singleAccount.Id);
				}
			}			
        }
        
        if(accIds.size() > 0 && Schema.sObjectType.Core_Account_Group_Member__c.isAccessible()){ 
            for(Core_Account_Group_Member__c agm : [SELECT Id,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c 
                                                    FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c IN :accIds]) {
                intelAccIds.add(agm.Core_Intel_Account_Id__c);
            }
            
            if(intelAccIds.size() > 0 && Schema.sObjectType.PRM_AccountBenefitAssociation__c.isAccessible() && Schema.sObjectType.PRM_AccountBenefitAssociation__c.isUpdateable()) {
                List<PRM_AccountBenefitAssociation__c> abas = [SELECT Id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c FROM PRM_AccountBenefitAssociation__c 
                                                               WHERE PRM_Account_Id__c IN :intelAccIds AND PRM_Partner_Benefit_Id__r.Name = 'Solutions Marketplace Basic Access'];
                for(PRM_AccountBenefitAssociation__c aba : abas) {
                    aba.PRM_Status_Nm__c = PMP_StaticConstants_Partner.INACTIVE;
                    aba.PRM_Status_Reason_Txt__c= System.label.PRM_Aba_Inactive;
                }
                if(abas.size() > 0) {
                    update abas;
                }
            }
        }
    }
}