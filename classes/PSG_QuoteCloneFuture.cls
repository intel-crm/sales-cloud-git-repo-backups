/****************************************************************************************************
Apex Class Name : PSG_QuoteCloneFuture
Version         : 1.0 
Created Date    : 04/14/2022
Function        : This class is used to copy all the child object records from parent quote to new quote on revision/clone asynchronously.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              04/14/2022                Created
*****************************************************************************************************/
@isTest
public class PSG_QuoteCloneFuture {    
    /*@future
    public static void copyQuoteChildRecordsFuture(String sObjectId,String newQuoteId,String action,Set<Id> existingOPNForDesignWinSet){
        copyQuoteChildRecords(sObjectId,newQuoteId,action,existingOPNForDesignWinSet);
    }
    public static void copyQuoteChildRecords(String sObjectId,String newQuoteId,String action,Set<Id> existingOPNForDesignWinSet){
        SBQQ__Quote__c parent=[Select Id,Name,core_cpq_quote_type_nm__c from SBQQ__Quote__c where Id=:newQuoteId LIMIT 1];
        Map<Id,SBQQ__QuoteLineGroup__c> quoteLineGroupMap = new Map<Id,SBQQ__QuoteLineGroup__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> childQuoteLineIdToCloneQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Set<Id> currentProdIds=new Set<Id>();
        Set<String> invalidOPNs=new Set<String>();
        Set<String> duplicateOPNs=new Set<String>();
        Set<String> inactiveOPNs=new Set<String>();
        Map<String,Product2> currentIDToProdMap=new Map<String,Product2>();
        Map<String,Product2> existingOPNToProdMap=new Map<String,Product2>();
        List<ContentVersion> notesAndAttachmentsList = new List<ContentVersion>();   
        Map<String,Product2> pridToNewOPNMap = new Map<String,Product2>();
        try{
            SBQQ.TriggerControl.disable();
            String query;
            query = 'SELECT '+String.escapeSingleQuotes(String.join(new List<String>(SBQQ__QuoteLineGroup__c.SObjectType.getDescribe().fields.getMap().keySet()),','))+
                ' FROM '+String.escapeSingleQuotes(String.valueOf(SBQQ__QuoteLineGroup__c.SObjectType))+' WHERE SBQQ__Quote__c = \''+String.escapeSingleQuotes(sObjectId)
                +'\' AND SBQQ__Quote__r.core_cpq_quote_type_nm__c <> \'Contract Pricing\'';
            for(SBQQ__QuoteLineGroup__c child:(List<SBQQ__QuoteLineGroup__c>)Database.query(query)){
                SBQQ__QuoteLineGroup__c newQuoteLineGroup = child.clone(false,true); 
                newQuoteLineGroup.SBQQ__Quote__c = parent.Id; 
                quoteLineGroupMap.put(child.Id,newQuoteLineGroup);
                
            }
            if(!quoteLineGroupMap.isEmpty()){
                DataBase.Insert((quoteLineGroupMap.values()),false);
            }
            query='SELECT '+String.escapeSingleQuotes(String.join( new List<String>(SBQQ__QuoteLine__c.SObjectType.getDescribe().fields.getMap().keySet()),','))+' FROM '+
                String.escapeSingleQuotes(String.valueOf(SBQQ__QuoteLine__c.SObjectType))+
                ' WHERE SBQQ__Quote__c = \''+String.escapeSingleQuotes(sObjectId)+'\' AND Pricing_Status_Nm__c <> \'Revised\' AND SBQQ__Quote__r.core_cpq_quote_type_nm__c <> \'Contract Pricing\'';
            Map<Id,Id> quoteLineToRequiredByIdMap = new Map<Id,Id>();
            Map<Id,SBQQ__QuoteLine__c> originalQuotelineToNewQLMap = new Map<Id,SBQQ__QuoteLine__c>();
            Map<Id,Id> newQLIdMapToOriginalQuotelineId = new Map<Id,Id>();
            List<SBQQ__QuoteLine__c> quoteLineToCloneList = new  List<SBQQ__QuoteLine__c>();
            quoteLineToCloneList = (List<SBQQ__QuoteLine__c>)Database.query(query);
            for(SBQQ__QuoteLine__c ql :quoteLineToCloneList){
                currentProdIds.add(ql.SBQQ__Product__c);
            }
            for(Product2 prod: [Select Id,Core_OPN__c,IsActive,Core_Item_Orderable_Ind__c,Core_Item_Quotable_Ind__c from Product2 where Id in :currentProdIds]){
                currentIDToProdMap.put(prod.Id,prod);
                if(!prod.IsActive || !prod.Core_Item_Orderable_Ind__c || !prod.Core_Item_Quotable_Ind__c){
                    inactiveOPNs.add(prod.Core_OPN__c);
                }
            }
            String query1 = 'Select Id,Core_OPN__c,IsActive,Core_Item_Orderable_Ind__c,Core_Item_Quotable_Ind__c from Product2 where Core_OPN__c in :inactiveOPNs and IsActive=true and Core_Product_Org__c=\'Sales\' and Core_Item_Quotable_Ind__c=true';
            if(parent.core_cpq_quote_type_nm__c != 'Budgetary'){
                query1 = query1 + ' and Core_Item_Orderable_Ind__c = true';
            }
            for(Product2 prod: DataBase.Query(query1)){
                existingOPNToProdMap.put(prod.Core_OPN__c,prod);
            }
            for(SBQQ__QuoteLine__c child : quoteLineToCloneList){
                boolean isOPNvalid = true;
                if(!currentIDToProdMap.get(child.SBQQ__Product__c).isActive){
                    isOPNvalid=false;
                }
                if(!currentIDToProdMap.get(child.SBQQ__Product__c).Core_Item_Quotable_Ind__c){
                    isOPNvalid=false;
                }
                if(parent.core_cpq_quote_type_nm__c != 'Budgetary' && !currentIDToProdMap.get(child.SBQQ__Product__c).Core_Item_Orderable_Ind__c){
                    isOPNvalid=false;
                }
                if(isOPNvalid || (!isOPNvalid && existingOPNToProdMap.containsKey(currentIDToProdMap.get(child.SBQQ__Product__c).Core_OPN__c))){
                    SBQQ__QuoteLine__c newQuoteLine = child.clone(false,true); 
                    newQuoteLine.SBQQ__Quote__c = parent.Id;
                    newQuoteLine.core_cpq_low_yield_cb__c = false;
                    if(existingOPNToProdMap.containsKey(currentIDToProdMap.get(child.SBQQ__Product__c).Core_OPN__c) && !isOPNvalid){
                        newQuoteLine.SBQQ__Product__c = existingOPNToProdMap.get(currentIDToProdMap.get(child.SBQQ__Product__c).Core_OPN__c)?.Id;
                        newQuoteLine.core_cpq_opn__c = existingOPNToProdMap.get(currentIDToProdMap.get(child.SBQQ__Product__c).Core_OPN__c)?.Core_OPN__c;
                        pridToNewOPNMap.put(child.core_cpq_PRID__c, existingOPNToProdMap.get(currentIDToProdMap.get(child.SBQQ__Product__c).Core_OPN__c));
                    }
                    newQuoteLine.RecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create');
                    if(child.SBQQ__RequiredBy__c != null){
                        quoteLineToRequiredByIdMap.put(child.Id,child.SBQQ__RequiredBy__c);
                    }
                    originalQuotelineToNewQLMap.put(child.Id,newQuoteLine);
                    if(newQuoteLine.SBQQ__Group__c != null && quoteLineGroupMap.containsKey(newQuoteLine.SBQQ__Group__c)){
                        newQuoteLine.SBQQ__Group__c = quoteLineGroupMap.get(newQuoteLine.SBQQ__Group__c).Id;
                    }
                    if(action == 'clone'){
                        newQuoteLine.core_cpq_quote_line_type_txt__c = child.core_cpq_quote_line_type_txt__c;
                        for(String fieldName : (Label.PSG_QuoteLineFieldsNull).split(':')){
                            newQuoteLine.put(fieldName,null);
                            
                        }
                        for(String fieldName : (Label.PSG_clone_quoteline_boolean_to_false).split(':')){
                            newQuoteLine.put(fieldName,false);
                            system.debug('clone1-->'+newQuoteLine);
                        }
                    }
                    
                    if(action == 'revision'){
                        //newQuoteLine.core_cpq_dollar_change_flag_cb__c = false; // Dated Sept 30 as per request to copy $change flag on revision
                        newQuoteLine.SBQQ__Source__c = child.Id;
                        
                        for(String fieldName : (Label.PSG_QuoteLineFieldsRevisionNull).split(':')){
                            newQuoteLine.put(fieldName,null);
                        }
                        
                        
                        if(newQuoteLine.SBQQ__Product__c == child.SBQQ__Product__c){
                            if(child.core_cpq_intel_margin_pct__c != null && child.core_cpq_distributor_margin_pct__c != null && child.price_peak_annual_resale_amt__c != null){
                                newQuoteLine.core_cpq_intel_margin_difference__c        =  newQuoteLine.core_cpq_intel_margin_pct__c       - child.core_cpq_intel_margin_pct__c;
                                newQuoteLine.core_cpq_disty_margin_difference__c        =  newQuoteLine.core_cpq_distributor_margin_pct__c       - child.core_cpq_distributor_margin_pct__c;
                                newQuoteLine.core_cpq_peak_annual_resale_Difference__c  =  newQuoteLine.price_peak_annual_resale_amt__c - child.price_peak_annual_resale_amt__c;
                            } 
                        } 
                        if(!existingOPNForDesignWinSet.contains(newQuoteLine.SBQQ__Product__c)){
                            quoteLineList.add(newQuoteLine);
                        }else{
                            duplicateOPNs.add(newQuoteLine.core_cpq_opn__c);
                        }
                    }else{
                        quoteLineList.add(newQuoteLine);
                    }
                    childQuoteLineIdToCloneQuoteLineMap.put(child.Id,newQuoteLine);
                }else{
                    invalidOPNs.add(child.core_cpq_opn__c);
                }
            }
            if(!quoteLineList.isEmpty()){                    
                Set<String> pridIdSet=new Set<String>();
                for(SBQQ__QuoteLine__c ql : quoteLineList){
                    if(ql.core_cpq_PRID__c != null)
                        pridIdSet.add(ql.core_cpq_PRID__c);
                }
                Map<Id,price_PRID__c> pridMap=new Map<Id,price_PRID__c>([Select id,core_cpq_lower_bound_qty_nbr__c, core_cpq_upper_bound_qty_nbr__c, core_cpq_type__c, core_cpq_quantity_eau_nbr__c, price_amt__c, core_cpq_prid_reviewer__c,core_cpq_prid_review_date_dt__c, core_cpq_comments_txt__c, core_cpq_price_end_date_dt__c, core_cpq_price_start_date_dt__c, core_cpq_prid_eligiblity_date_dt__c,core_cpq_active_pricing_cb__c from price_prid__c where Id in :pridIdSet]);
                for(SBQQ__QuoteLine__c ql : quoteLineList){
                    if(ql.core_cpq_PRID__c != null && pridMap.containsKey(ql.core_cpq_PRID__c)){
                        ql.core_cpq_lower_bound_qty_qty__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_lower_bound_qty_nbr__c;
                        ql.core_cpq_upper_bound_qty_nbr__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_upper_bound_qty_nbr__c;
                        ql.SBQQ__Quantity__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_quantity_eau_nbr__c; 
                        ql.core_cpq_quantity_nm__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_quantity_eau_nbr__c;
                        ql.core_cpq_previous_quantity_nm__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_quantity_eau_nbr__c;
                        ql.price_goal_price_amt__c=pridMap.get(ql.core_cpq_PRID__c).price_amt__c;
                        ql.price_suggested_resale_amt__c=pridMap.get(ql.core_cpq_PRID__c).price_amt__c;
                        ql.price_previous_suggested_resale_amt__c=pridMap.get(ql.core_cpq_PRID__c).price_amt__c;
                        ql.price_previous_goal_price_amt__c=pridMap.get(ql.core_cpq_PRID__c).price_amt__c;                        
                        ql.core_cpq_quote_line_type_txt__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_type__c;
                        ql.core_cpq_review_date_dt__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_prid_review_date_dt__c;
                        ql.core_cpq_reviewer__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_prid_reviewer__c;
                        ql.core_cpq_comments_txt__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_comments_txt__c;
                        ql.core_cpq_pricing_end_date_dt__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_price_end_date_dt__c;
                        ql.core_cpq_active_Pricing__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_active_pricing_cb__c;
                        ql.core_cpq_pricing_start_date_dt__c=pridMap.get(ql.core_cpq_PRID__c).core_cpq_price_start_date_dt__c;
                    }
                }
                
                Database.SaveResult[] result = Database.insert(quoteLineList,false);
                for(Id quoteLineId  : originalQuotelineToNewQLMap.keySet()){
                    if(originalQuotelineToNewQLMap.get(quoteLineId).Id != null){
                        newQLIdMapToOriginalQuotelineId.put(originalQuotelineToNewQLMap.get(quoteLineId).Id,quoteLineId);
                    }
                }
                List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c quoteLine  : [Select id,SBQQ__RequiredBy__c from SBQQ__QuoteLine__c where id =:quoteLineList]){
                    if(quoteLine.Id != null){
                        Id originalQuoteLineId = newQLIdMapToOriginalQuotelineId.get(quoteLine.Id);
                        if(quoteLineToRequiredByIdMap.get(originalQuoteLineId) != null){
                            Id requiredQuoteLineId = quoteLineToRequiredByIdMap.get(originalQuoteLineId);
                            if(originalQuotelineToNewQLMap.get(requiredQuoteLineId) != null && originalQuotelineToNewQLMap.get(requiredQuoteLineId).Id != null){
                                quoteLine.SBQQ__RequiredBy__c = originalQuotelineToNewQLMap.get(requiredQuoteLineId).Id;
                                quoteLineToUpdate.add(quoteLine);
                            }
                        }   
                    }
                }
                if(!quoteLineToUpdate.isEmpty()){
                    update quoteLineToUpdate;
                }
                for(Integer i=0;i<result.size();i++){
                    if(!result[i].isSuccess() && !duplicateOPNs.contains(quoteLineList[i].core_cpq_opn__c)){
                        invalidOPNs.add(quoteLineList[i].core_cpq_opn__c);
                    }
                }
                
            }
            if(!pridToNewOPNMap.isEmpty()){
                updateOPN(pridToNewOPNMap);
            }
            if(!invalidOPNs.isEmpty() || !duplicateOPNs.isEmpty()){
                parent.core_cpq_invalid_opns_dup__c=(invalidOPNs.size() >1 ?  new List<String>(invalidOPNs)[0]+'...': String.join(new List<String>(invalidOPNs),','));
                parent.core_cpq_invalid_opn_ta__c=String.join(new List<String>(invalidOPNs),',');
                parent.core_cpq_dup_designwin_opns__c=String.join(new List<String>(duplicateOPNs),',');
                update parent;
            }
            
            
            List<ContentVersion> cvList=new List<ContentVersion>();
            List<Id> conDocList = new List<Id>();
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink
                                               where LinkedEntityId =:sObjectId]) {
                                                   conDocList.add(cntLink.ContentDocumentId);
                                               }
            cvList=[SELECT Id,Title,ContentDocumentId,PathOnClient,FirstPublishLocationId,VersionData,IsMajorVersion
                    from ContentVersion where ContentDocumentId IN :conDocList];
            for(ContentVersion childNotesAndAttachments : cvList){
                ContentVersion newNotesAndAttachments = new ContentVersion();                             
                newNotesAndAttachments.Title = childNotesAndAttachments.Title;
                newNotesAndAttachments.PathOnClient = childNotesAndAttachments.PathOnClient;
                newNotesAndAttachments.FirstPublishLocationId = parent.Id;
                newNotesAndAttachments.VersionData = childNotesAndAttachments.VersionData;
                newNotesAndAttachments.IsMajorVersion = true;          
                notesAndAttachmentsList.add(newNotesAndAttachments); 
            }      
            if(!notesAndAttachmentsList.isEmpty()){
                insert notesAndAttachmentsList; 
            }
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_QuoteCloneFuture','copyQuoteChildRecords','Error while copying child objects on clone/revise from '+sObjectId+' to '+parent.Name,''+e,'SBQQ__Quote__c','High','');
        } finally{
            SBQQ.TriggerControl.enable();
        }       
    }
    
    /**********************************************************************************************************
     * Method Name : updateOPN
     * Description : Method to update Alternate Product available in PRID, Quote Lines & DPA/ALN Lines
     * Author : Adarsh Parashar
     * Created Date : 10/04/2022
    ***********************************************************************************************************/
    /*public static void updateOPN(Map<String,Product2> pridToNewOPNMap){
        List<price_prid__c> pridList = [Select id,core_cpq_device__c from price_prid__c WHERE core_cpq_active_cb__c = true and ID IN :pridToNewOPNMap.keySet()];
        for(price_prid__c prid : pridList){
            prid.core_cpq_device__c = pridToNewOPNMap.get(prid.Id).Id;
        }
        if(!pridList.isEmpty()){
            update pridList;
            List<SBQQ__QuoteLine__c> quoteLineList = [Select id,SBQQ__Product__c,core_cpq_opn__c,core_cpq_PRID__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.core_cpq_active_cb__c = true and SBQQ__Quote__r.SBQQ__Status__c IN ('Approved','In Progress','In Review') and core_cpq_PRID__c IN :pridList];
            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                quoteLine.SBQQ__Product__c = pridToNewOPNMap.get(quoteLine.core_cpq_PRID__c).Id;
                quoteLine.core_cpq_opn__c = pridToNewOPNMap.get(quoteLine.core_cpq_PRID__c).Core_OPN__c;
            }
            if(!quoteLineList.isEmpty()){
                update quoteLineList;
            }
            List<core_cpq_dpa_aln_line__c> dpaAlnLineList = [Select id,core_cpq_device_nm__c,core_cpq_prid__c from core_cpq_dpa_aln_line__c WHERE core_cpq_cis_no_nbr__r.core_cpq_ship_end_date_dt__c > TODAY and core_cpq_cis_no_nbr__r.core_cpq_status_txt__c IN ('Approved','Hold','Extended','New','Failure') and core_cpq_prid__c IN :pridList];
            for(core_cpq_dpa_aln_line__c dpaAlnline : dpaAlnLineList){
                dpaAlnline.core_cpq_device_nm__c = pridToNewOPNMap.get(dpaAlnline.core_cpq_prid__c).Id;
            }
            if(!dpaAlnLineList.isEmpty()){
                update dpaAlnLineList;
            }
        }
    }*/
}