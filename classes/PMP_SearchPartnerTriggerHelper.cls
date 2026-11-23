public class PMP_SearchPartnerTriggerHelper {
    public static void syncPublishedPartnerCopy(List<PMP_Company__c> triggeredpartners, map<Id,PMP_Company__c> oldMap){
        Map<Id,PMP_Company__c> aprroved_partners_Map = new Map<Id,PMP_Company__c>();
        for(PMP_Company__c p : triggeredpartners){
            if(p.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved && 
               p.PMP_Company_Lifecycle_Status_Nm__c != oldMap.get(p.Id).PMP_Company_Lifecycle_Status_Nm__c && 
               p.PMP_Is_Working_Copy_Ind__c == true){
                   aprroved_partners_Map.put(p.Id,p);
            }
        }
        system.debug('aprroved_partners_Map => '+aprroved_partners_Map);
        pushToPublishedCopy(aprroved_partners_Map, triggeredpartners, oldMap);
    }
    
    public static void pushToPublishedCopy(map<Id,PMP_Company__c> aprroved_partners_Map, List<PMP_Company__c> triggeredpartners, map<Id,PMP_Company__c> oldMap){
        List<PMP_Company__c> exsiting_partners_published = new List<PMP_Company__c>();
        List<PMP_Company_Resource__c> exsiting_partner_resources_todelete;
        List<PMP_Company_Translation__c> exsiting_partner_translations_todelete;
        List<PMP_Partner_Category__c> exsiting_partner_categories_todelete;
        List<PMP_Company_Region__c> exsiting_partner_regions_todelete;  
        List<PMP_Company_Message__c> exsiting_partner_messages_todelete;          
        
        List<PMP_Company_Resource__c> new_partner_resources_cloned;
        List<PMP_Company_Translation__c> new_partner_translations_cloned;
        List<PMP_Partner_Category__c> new_partner_categories_cloned;
        List<PMP_Company_Region__c> new_partner_regions_cloned;
        List<PMP_Company_Message__c> new_partner_messages_cloned;          
        
        Map<Id,Id> partners_published_working_map = new map<Id,Id>();
    Set<Id> partners_published_working_set = new Set<Id>();
        
        List<PMP_company__c> published_partners = [SELECT Id,Name,PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Account_Application__c,
                                                   PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Company_Lead_Gen_Language_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c,
                                                   PMP_Account_Dsc__c,PMP_Account_Industry__c,PMP_Account_Region__c,PMP_Account_Tag_Line__c,PMP_Company_Information_Language_Nm__c,
                                                   PMP_Company_Resource__c,PMP_Working_Copy_Id__c,PMP_Translation_Lifecycle_Status_nm__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c IN: aprroved_partners_Map.keySet()];
    system.debug('published_partners => '+published_partners);
        for(PMP_company__c p : published_partners){
            PMP_company__c partner_work_copy = aprroved_partners_Map.containsKey(p.PMP_Working_Copy_Id__c) ? aprroved_partners_Map.get(p.PMP_Working_Copy_Id__c) : null;
            system.debug('partner_work_copy => '+partner_work_copy);
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
                //p_cloned.CreatedById            = partner_work_copy.CreatedById;
                p_cloned.PMP_Company_Status_Update_Dt__c  = system.today();
                partners_published_working_set.add(p.PMP_Working_Copy_Id__c);
                partners_published_working_map.put(p.PMP_Working_Copy_Id__c,p.PMP_Working_Copy_Id__c);
                exsiting_partners_published.add(p_cloned);
            }
        }
        system.debug('exsiting_partners_published => '+exsiting_partners_published);
        if(!exsiting_partners_published.isEmpty()){
            update exsiting_partners_published;
        }
        
        exsiting_partner_resources_todelete = [SELECT id, Name from PMP_Company_Resource__c where PMP_Company_Id__c IN: exsiting_partners_published]; 
                                               //AND (PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Partner.IMAGE OR PMP_Company_Resource_Type_Nm__c !=: PMP_StaticConstants_Partner.THUMBNAIL_IMAGE)];
    exsiting_partner_translations_todelete   = [SELECT Id, PMP_Company_Information_Id__c from PMP_Company_Translation__c where PMP_Company_Information_Id__c IN: exsiting_partners_published]; 
        exsiting_partner_categories_todelete   = [SELECT Id, PMP_Partner_Id__c from PMP_Partner_Category__c  where PMP_Partner_Id__c IN: exsiting_partners_published]; 
        exsiting_partner_regions_todelete     = [SELECT Id, PMP_Company_Id__c from PMP_Company_Region__c  where PMP_Company_Id__c IN: exsiting_partners_published]; 
        //exsiting_partner_messages_todelete     = [SELECT Id, PMP_Company_Id__c  from PMP_Company_Message__c  where PMP_Company_Id__c IN: exsiting_partners_published];         
        
        
        new_partner_resources_cloned   = createResources(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
        new_partner_translations_cloned = createTranslations(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
        new_partner_categories_cloned   = createCategories(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
        new_partner_regions_cloned     = createRegions(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
        //new_partner_messages_cloned   = createMessages(exsiting_partners_published, partners_published_working_set, partners_published_working_map);
        
        system.debug('new_resources_cloned before => '+new_partner_resources_cloned);        
        if(!new_partner_resources_cloned.isEmpty()){
            insert new_partner_resources_cloned;
        }
        if(!new_partner_translations_cloned.isEmpty()){
            insert new_partner_translations_cloned;
        }
        if(!new_partner_categories_cloned.isEmpty()){
            insert new_partner_categories_cloned;
        }
        if(!new_partner_regions_cloned.isEmpty()){
            insert new_partner_regions_cloned;
        }
/*
        if(!new_partner_messages_cloned.isEmpty()){
            insert new_partner_messages_cloned;
        } 
*/
        system.debug('new_resources_cloned After => '+new_partner_resources_cloned);
    system.debug('exsiting_partner_resources_todelete => '+exsiting_partner_resources_todelete);                
        if(!exsiting_partner_resources_todelete.isEmpty()){
            Delete exsiting_partner_resources_todelete;
        }
        if(!exsiting_partner_translations_todelete.isEmpty()){
            Delete exsiting_partner_translations_todelete;
        }
        if(!exsiting_partner_categories_todelete.isEmpty()){
            Delete exsiting_partner_categories_todelete;
        }
        if(!exsiting_partner_regions_todelete.isEmpty()){
            Delete exsiting_partner_regions_todelete;
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
        
        DescribeSObjectResult partner_res_fields = PMP_Company_Resource__c.getSObjectType().getDescribe();   
        List<String> partner_res_field_names = new List<String>( partner_res_fields.fields.getMap().keySet() );    
        String partner_res_query_str =  ' SELECT ' + String.join( partner_res_field_names, ',' ) + ' FROM ' + partner_res_fields.getName() + ' WHERE ' + ' PMP_Company_Id__c  IN : partners_published_working_set';   
        system.debug('partner_res_query_str => '+partner_res_query_str);
        //partners_working_res_list = Database.query(partner_res_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        partners_working_res_list = Database.query(String.escapeSingleQuotes(partner_res_query_str));
        system.debug('partners_working_res_list => '+partners_working_res_list);
        for(PMP_Company_Resource__c res : partners_working_res_list){
            if(res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_Partner.IMAGE || res.PMP_Company_Resource_Type_Nm__c == PMP_StaticConstants_Partner.THUMBNAIL_IMAGE){
                res_workcopy_doc_ids.add(res.PMP_Company_Image__c);
            }
        }
        system.debug('res_workcopy_doc_ids => '+res_workcopy_doc_ids);
        versions_workcopy_lst = [SELECT Id, ContentDocumentId,Title, NetworkId, IsLatest, PathOnClient,FirstPublishLocationId, Description, RatingCount, VersionData, FileExtension 
                                                   FROM ContentVersion where ContentDocumentId IN: res_workcopy_doc_ids AND IsLatest=true];
    
        system.debug('versions_workcopy_lst => '+versions_workcopy_lst);
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
        }
        if(!new_version_lst.isEmpty()){
            insert new_version_lst;
        }
        system.debug('new_version_lst => '+new_version_lst);
        for(ContentVersion new_ver : new_version_lst){
/*
            ContentDocumentLink cd_link = new ContentDocumentLink();
            cd_link.ContentDocumentId = new_ver.ContentDocumentId;//Add ContentDocumentId
            cd_link.LinkedEntityId = wrkPubIdMap.get(wcId);//Add attachment parentId
            cd_link.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cd_link.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
            publishedPartnerLinksToSave.add(cd_link);   
*/
            new_version_set.add(new_ver.Id);
        }
        for(ContentVersion cv : [SELECT Id, ContentDocumentId,VersionData FROM ContentVersion where Id IN: new_version_set AND IsLatest=true]){
            string blobTostr = EncodingUtil.base64Encode(cv.VersionData);
            new_content_doc_map.put(workcopy_content_doc_map.get(blobTostr),cv.ContentDocumentId);
        } 
        system.debug('new_content_doc_map => '+new_content_doc_map);
        for(PMP_Company_Resource__c res_workcopy : partners_working_res_list){
            PMP_Company_Resource__c res_cloned = new PMP_Company_Resource__c();
            res_cloned = res_workcopy.clone(false,false,true,true);
            system.debug('res_cloned => '+res_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                system.debug('ext_partner.PMP_Working_Copy_Id__c => '+ext_partner.PMP_Working_Copy_Id__c);
                system.debug('partners_published_working_map => '+partners_published_working_map);
                system.debug('res_workcopy.PMP_Company_Id__c => '+res_workcopy.PMP_Company_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(res_workcopy.PMP_Company_Id__c))
                    res_cloned.PMP_Company_Id__c = ext_partner.Id;
            }
            res_cloned.CreatedById = res_workcopy.CreatedById;
            res_cloned.PMP_Company_Image__c = new_content_doc_map.get(res_workcopy.PMP_Company_Image__c); 
            cloned_resource_lst.add(res_cloned);
        }        
        return cloned_resource_lst;
    }
    
    public static List<PMP_Company_Translation__c> createTranslations(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Company_Translation__c> cloned_translations_lst = new List<PMP_Company_Translation__c>();    
        DescribeSObjectResult partner_trans_fields = PMP_Company_Translation__c.getSObjectType().getDescribe();   
        List<String> partner_trans_field_names = new List<String>( partner_trans_fields.fields.getMap().keySet() );    
        String partner_trans_query_str =    ' SELECT ' + String.join( partner_trans_field_names, ',' ) + ' FROM '+partner_trans_fields.getName() + ' WHERE ' + ' PMP_Company_Information_Id__c  IN : partners_published_working_set';   
        //List<PMP_Company_Translation__c> partners_working_trans_list = Database.query(partner_trans_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Company_Translation__c> partners_working_trans_list = Database.query(String.escapeSingleQuotes(partner_trans_query_str));
        for(PMP_Company_Translation__c trans_workcopy : partners_working_trans_list){
            PMP_Company_Translation__c trans_cloned = new PMP_Company_Translation__c();
            trans_cloned = trans_workcopy.clone(false,false,true,true);
            system.debug('trans_cloned => '+trans_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                system.debug('ext_partner.PMP_Working_Copy_Id__c_trns => '+ext_partner.PMP_Working_Copy_Id__c);
                system.debug('partners_published_working_map_trns => '+partners_published_working_map);
                system.debug('trans_workcopy.PMP_Company_Information_Id__c => '+trans_workcopy.PMP_Company_Information_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(trans_workcopy.PMP_Company_Information_Id__c))
                    trans_cloned.PMP_Company_Information_Id__c = ext_partner.Id;
            }
            trans_cloned.CreatedById = trans_workcopy.CreatedById;
            cloned_translations_lst.add(trans_cloned);
        }           
        return cloned_translations_lst;
    }
    
    public static List<PMP_Partner_Category__c> createCategories(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Partner_Category__c> cloned_categories_lst = new List<PMP_Partner_Category__c>();  
        DescribeSObjectResult partner_cat_fields = PMP_Partner_Category__c.getSObjectType().getDescribe();   
        List<String> partner_cat_field_names = new List<String>( partner_cat_fields.fields.getMap().keySet() );    
        String partner_cat_query_str =    ' SELECT ' + String.join( partner_cat_field_names, ',' ) + ' FROM '+partner_cat_fields.getName() + ' WHERE ' + ' PMP_Partner_Id__c  IN : partners_published_working_set';   
       // List<PMP_Partner_Category__c> partners_working_cat_list = Database.query(partner_cat_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Partner_Category__c> partners_working_cat_list = Database.query(String.escapeSingleQuotes(partner_cat_query_str));
        for(PMP_Partner_Category__c cat_workcopy : partners_working_cat_list){
            PMP_Partner_Category__c cat_cloned = new PMP_Partner_Category__c();
            cat_cloned = cat_workcopy.clone(false,false,true,true);
            system.debug('cat_cloned => '+cat_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                system.debug('ext_partner.PMP_Working_Copy_Id__c_cat => '+ext_partner.PMP_Working_Copy_Id__c);
                system.debug('partners_published_working_map_trns_cat => '+partners_published_working_map);
                system.debug('cat_workcopy.PMP_Company_Id__c => '+cat_workcopy.PMP_Partner_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(cat_workcopy.PMP_Partner_Id__c)){
                    cat_cloned.PMP_Partner_Id__c = ext_partner.Id;
                    //cat_cloned.PMP_Category_Id__c = cat_workcopy.PMP_Category_Id__c;                    
                }
            }
            cat_cloned.CreatedById = cat_workcopy.CreatedById;
            cloned_categories_lst.add(cat_cloned);
        }                   
        return cloned_categories_lst;
    }
    
    public static List<PMP_Company_Region__c> createRegions(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Company_Region__c> cloned_regions_lst = new List<PMP_Company_Region__c>();  
        DescribeSObjectResult partner_region_fields = PMP_Company_Region__c.getSObjectType().getDescribe();   
        List<String> partner_regions_field_names = new List<String>( partner_region_fields.fields.getMap().keySet() );    
        String partner_reg_query_str =    ' SELECT ' + String.join( partner_regions_field_names, ',' ) + ' FROM '+partner_region_fields.getName() + ' WHERE ' + ' PMP_Company_Id__c  IN : partners_published_working_set';   
        //List<PMP_Company_Region__c> partners_working_regions_list = Database.query(partner_reg_query_str); // Commented for US622434 [Sonar Cube Errors Fix]
        List<PMP_Company_Region__c> partners_working_regions_list = Database.query(String.escapeSingleQuotes(partner_reg_query_str));
        for(PMP_Company_Region__c reg_workcopy : partners_working_regions_list){
            PMP_Company_Region__c reg_cloned = new PMP_Company_Region__c();
            reg_cloned = reg_workcopy.clone(false,false,true,true);
            system.debug('reg_cloned => '+reg_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                system.debug('ext_partner.PMP_Working_Copy_Id__c_reg => '+ext_partner.PMP_Working_Copy_Id__c);
                system.debug('partners_published_working_map_reg => '+partners_published_working_map);
                system.debug('reg_workcopy.PMP_Company_Id__c => '+reg_workcopy.PMP_Company_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(reg_workcopy.PMP_Company_Id__c))
                    reg_cloned.PMP_Company_Id__c = ext_partner.Id;
            }
            reg_cloned.CreatedById = reg_workcopy.CreatedById;
            cloned_regions_lst.add(reg_cloned);
        }                   
        
        return cloned_regions_lst;
    } 
/*
    public static List<PMP_Company_Message__c> createMessages(List<PMP_Company__c> exsiting_partners_published, Set<Id> partners_published_working_set, Map<Id,Id> partners_published_working_map){
        List<PMP_Company_Message__c> cloned_messages_lst = new List<PMP_Company_Message__c>();    
        DescribeSObjectResult partner_msg_fields = PMP_Company_Message__c.getSObjectType().getDescribe();   
        List<String> partner_msg_field_names = new List<String>( partner_msg_fields.fields.getMap().keySet() );    
        String partner_msg_query_str =    ' SELECT ' + String.join( partner_msg_field_names, ',' ) + ' FROM '+partner_msg_fields.getName() + ' WHERE ' + ' PMP_Company_Id__c  IN : partners_published_working_set';   
        List<PMP_Company_Message__c> partners_working_msg_list = Database.query(partner_msg_query_str);
        
        for(PMP_Company_Message__c msg_workcopy : partners_working_msg_list){
            PMP_Company_Message__c msg_cloned = new PMP_Company_Message__c();
            msg_cloned = msg_workcopy.clone(false,false,true,true);
            system.debug('msg_cloned => '+msg_cloned);
            for(PMP_Company__c ext_partner : exsiting_partners_published){
                system.debug('ext_partner.PMP_Working_Copy_Id__c_trns => '+ext_partner.PMP_Working_Copy_Id__c);
                system.debug('partners_published_working_map_trns => '+partners_published_working_map);
                system.debug('msg_workcopy.PMP_Company_Information_Id__c => '+msg_workcopy.PMP_Company_Id__c);
                if(ext_partner.PMP_Working_Copy_Id__c == partners_published_working_map.get(msg_workcopy.PMP_Company_Id__c))
                    msg_cloned.PMP_Company_Id__c = ext_partner.Id;
            }
            msg_cloned.CreatedById = msg_workcopy.CreatedById;
            cloned_messages_lst.add(msg_cloned);
        }           
        return cloned_messages_lst;
    }
*/
}