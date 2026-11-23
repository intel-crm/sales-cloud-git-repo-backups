/****************************************************************************************************
Apex Class Name : PSG_QuoteRequestController
Created Date    : 12/4/2020
Function        : Apex Controller for Disty Quote Request Form/Quote Line Related List
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ---------------------------------------------------------------------------------------------------                
* Avani                      12/4/2020               Created
*****************************************************************************************************/
public without sharing class PSG_QuoteRequestController {
    public Static Boolean isCustomException=false;
    public Static final String DISTRIBUTOR='Distributor';
    
    /****************************************************************************************************************
    * Method Name:updateQuoteLines
    * Author: Avani
    * Date: 1/4/2020 
    * Description: Method to Save Quote Lines from custom Quote Line related list view(Internal)
    ***************************************************************************************************************************/
    @AuraEnabled  
    public static void updateQuoteLines(List<SBQQ__QuoteLine__c> quoteLineList){  
        try{
            if(isCustomException){
                throw new NullPointerException(); 
            }
            if(!quoteLineList.isEmpty()){
              //  system.debug('quoteLineList-->'+quoteLineList);
                update quoteLineList;  
            }
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
    } 
    
    /*****************************************************************************************************************
    * Class Name: AttWrapper
    * Author: Avani
    * Date: 12/5/2020 
    * Description:Wrapper class to handle attachments.
    *****************************************************************************************************************/
    public without sharing class AttWrapper{
        @AuraEnabled public String strFileName {get;set;}
        @AuraEnabled public String base64Data {get;set;}
        
        
    }
    
    /****************************************************************************************************************
    * Method Name:createQuoteRequest
    * Author: Avani
    * Date: 12/5/2020 
    * Description: Method to Save Quote Header, QL items, Attachments
	***************************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static Id createQuoteRequest(SBQQ__Quote__c quoteRec,List<SBQQ__QuoteLine__c> quoteLineList,List<AttWrapper> attWrapList){
        
        Id quoteId;
        if(isCustomException){
            throw new NullPointerException(); 
        }
        List<ContentVersion> attList= new  List<ContentVersion>();
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        try{
            if(quoteRec!=null){
                quoteRec.core_cpq_requestor_nm__c=UserInfo.getUserId();
                quoteRec.core_cpq_date_submitted_dt__c= system.today();
                quoteRec.core_cpq_origin_txt__c = 'Disty';
                if(quoteRec.SBQQ__Distributor__c==null){
                    List<Contact> conList=fetchDistyDetails();
                    if(!conList.isEmpty()){quoteRec.SBQQ__Distributor__c=conList[0]?.AccountId;}
                }
                Database.UpsertResult result=Database.Upsert(quoteRec,true);
                if(result.isSuccess()){
                    quoteId=result.getId();
                }
            }
            if(quoteId!=null && !quoteLineList.isEmpty()){
                for(SBQQ__QuoteLine__c qlObj : quoteLineList){
                    if(qlObj.SBQQ__Quote__c == null){
                        qlObj.Id = null;
                        qlObj.recordtypeid = PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c','PSG_Quote_Line_Create');
                        qlObj.SBQQ__Quote__c=quoteId;
                        qlObj.core_cpq_origin_txt__c = 'Disty';
                    }
                    if((''+qlObj.Id).contains('row')){
                        qlObj.Id = null;
                    }
                    qlList.add(qlObj);
                }
                if(!qlList.isEmpty()){
                    upsert qlList;
                }
            }
            if(quoteId!=null && !attWrapList.isempty() ){
                for(AttWrapper wrapObj : attWrapList){
                    String base64 = EncodingUtil.urlDecode((wrapObj.base64Data), 'UTF-8');
                    ContentVersion cv = new ContentVersion();
                    cv.Title = wrapObj.strFileName;
                    cv.PathOnClient = '/' + wrapObj.strFileName;
                    cv.FirstPublishLocationId = quoteId;
                    cv.VersionData = EncodingUtil.base64Decode(base64);
                    cv.IsMajorVersion = true;
                    attList.add(cv);
                }
                if(!attList.isEmpty()){
                    //Database.SaveResult[] srList=Database.Insert(attList,true);
                    insert attList;
                }
            }
            return quoteId;
        }
        catch(Exception ex){
            PSG_Utility.logError(ex);
            /*if(ex.getMessage().contains('core_cpq_unique_id__c')){
            ex.setMessage('Unique Field Error');
            
            }*/
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /***************************************************************************************************************************
    * Method Name:fetchRelatedList
    * Author: Avani
    * Date: 12/7/2020
    * Description: Method to Fetch Quote Lines
    ***************************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static List<SBQQ__QuoteLine__c> fetchRelatedList(Id quoteId){
        List<SBQQ__QuoteLine__c> qlList;
        try{
            if(isCustomException){
                throw new NullPointerException(); 
            }
            if(quoteId!=null){
                qlList=[Select Id,Name,SBQQ__Quote__c,core_cpq_distributor_margin_pct__c,
                        price_suggested_resale_amt__c,price_brokencost_amt__c 
                        from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId];
            }
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
        return qlList;
    }
    
    /***************************************************************************************************************************
    * Method Name:fetchFiles
    * Author: Avani
    * Date: 12/8/2020
    * Description: Method to Fetch files
	***************************************************************************************************************************/
    @AuraEnabled(cacheable=false)
    public static List<ContentVersion> fetchFiles(Id quoteId){
        List<ContentVersion> cvList=new List<ContentVersion>();
        List<Id> conDocList = new List<Id>();
        try{
            if(isCustomException){
                throw new NullPointerException(); 
            }
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink
                                               where LinkedEntityId =:quoteId]) {
                                                   conDocList.add(cntLink.ContentDocumentId);
                                               }
            cvList=[SELECT Id,Title,ContentDocumentId,ContentSize,FileType,CreatedDate from ContentVersion
                    where ContentDocumentId IN :conDocList];
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
        return cvList;
    }
    
    
    @AuraEnabled
    public static Decimal fetchContractedPrice(Id contractedPriceId){
        return null;
    }
    
    
    /***************************************************************************************************************************
    * Method Name:fetchDistyDetails
    * Author: Avani
    * Date: 12/7/2020
    * Description: Method to Fetch Logged in Disty's Name and Email
    ***************************************************************************************************************************/
    public static List<Contact> fetchDistyDetails(){
        List<Contact> conList;
        try{
            if(isCustomException){
                throw new NullPointerException(); 
            }
            String emailId=UserInfo.getUserEmail();
            conList=[Select Id,Name,Email,AccountId,Account.Core_Account_Type__c,Account.Name,Account.Core_Geo__c
                     from Contact where Email=:emailId LIMIT 1 ];
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
        return conList;
    }
    
    /***************************************************************************************************************************
    * Method Name:validateGroupMembership
    * Author: Hari Kiran K
    * Date: 4/JAN/2022
    * Description: Verifies the group membership of the logged in user.
    ***************************************************************************************************************************/
    @AuraEnabled(cacheable=true) 
    public static Boolean validateGroupMembership(String quoteId){
        List<SBQQ__Quote__c> quotes=[Select Id,core_cpq_disty_group_name__c from SBQQ__Quote__c where id=:quoteId];
        if(!quotes.isEmpty() && String.isNotBlank(quotes[0].core_cpq_disty_group_name__c)){
            List<GroupMember> grpMembers=[Select id,UserOrGroupId from GroupMember where Group.DeveloperName = :quotes[0].core_cpq_disty_group_name__c and  UserOrGroupId =:Userinfo.getUserId()];
            if(!grpMembers.isEmpty()) 
                return true;
            else
                return false;
        }else{
            return false;
        }        
    }
    
    
    /***************************************************************************************************************************
    * Method Name:validateOPN
    * Author: Avani
    * Date: 12/7/2020
    * Description: Validate OPN for the quote lines.
    ***************************************************************************************************************************/
    @AuraEnabled
    public static PSG_QuoteRequestController.validationWrapper validateOPN(List<SBQQ__QuoteLine__c> quoteLineList){
        try{
            Map<Id,List<String>> quoteColorErrorMap = new Map<Id,List<String>>();
            Set<String> existingOPNSet = new Set<String>();
            Set<String> opnSet = new Set<String>();
            Set<String> designRegistrationProdSet = new Set<String>();
            Set<String> existingDesignRegistrationProdSet = new Set<String>();
            Set<String> invalidDesignRegistrationProdSet = new Set<String>();
            //added
            Set<String> quoteIdSet = new Set<String>();
            Set<String> opptyIdSet = new Set<String>();
            
            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                if(String.isNotBlank(quoteLine.core_cpq_opn__c)){
                    opnSet.add(quoteLine.core_cpq_opn__c);
                }
                if(String.isNotBlank(quoteLine.core_cpq_altera_reg_txt__c)){
                    designRegistrationProdSet.add(quoteLine.core_cpq_altera_reg_txt__c);
                }
                //added
                if(String.isNotBlank(quoteLine.SBQQ__Quote__c)){
                    quoteIdSet.add(quoteLine.SBQQ__Quote__c);
                }
            }
            String result = '';
            if(opnSet != null && !opnSet.isEmpty()){
                for(Product2 prod : [SELECT Id, Core_OPN__c FROM product2 WHERE Core_OPN__c IN: opnSet and isActive = true and Core_Product_Org__c = 'Sales' and Core_Item_Quotable_Ind__c = true /*and Core_Sales_Visible_Flag__c = true*/ and Core_Product_Type__c = 'Intel® FPGAs']){
                    existingOPNSet.add(prod.Core_OPN__c);
                }
            }
            //added
            if(quoteIdSet != null && !quoteIdSet.isEmpty()){
                for(SBQQ__Quote__c quoteRec : [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN: quoteIdSet]){
                    if(quoteRec.SBQQ__Opportunity2__c != null){
                    	opptyIdSet.add(quoteRec.SBQQ__Opportunity2__c);
                    }
                }
            }
            if(designRegistrationProdSet != null && !designRegistrationProdSet.isEmpty()){
                for(Core_Design_Registration_Product__c designRegProd : [SELECT Id,Name FROM Core_Design_Registration_Product__c 
                                                                         WHERE Name IN :designRegistrationProdSet]){
                                                                             existingDesignRegistrationProdSet.add(designRegProd.Name);
                                                                         }
            }      
            
            Boolean opptyBlankError = false;
            Set<String> mandatoryFields = new Set<String>{'core_cpq_opn__c','SBQQ__Quantity__c','core_cpq_years_nbr__c','core_cpq_production_dt__c','price_requested_resale_amt__c'};
            Boolean mandatoryFieldsMissingError = false;
            Integer lineNumber = 1;
            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){ 
                for(String field : mandatoryFields) {         
                    if(quoteLine.get(field) == null || quoteLine.get(field) =='' ) {
                        if(!quoteColorErrorMap.containskey(quoteLine.Id)){
                            quoteColorErrorMap.put(quoteLine.Id,new List<String>{field});
                        }else{
                            quoteColorErrorMap.get(quoteLine.Id).add(field);
                        }
                        mandatoryFieldsMissingError = true;
                    }else if(field == 'core_cpq_opn__c' && !existingOPNSet.contains((String)quoteLine.get(field))){
                        String opn = (String)quoteLine.get(field);
                        if(String.isBlank(result)){
                            result = 'The following OPNs are invalid : '+opn;
                        }else{
                            result = result + ' , '+opn;
                        }
                        if(!quoteColorErrorMap.containskey(quoteLine.Id)){
                            quoteColorErrorMap.put(quoteLine.Id,new List<String>{field});
                        }else{
                            quoteColorErrorMap.get(quoteLine.Id).add(field);
                        }
                    }
                    
                }
                //added
                
                if(opptyIdSet.isEmpty() && quoteLine.core_cpq_altera_reg_txt__c != null && quoteLine.core_cpq_altera_reg_txt__c != ''){
                    opptyBlankError = true;
                    if(!quoteColorErrorMap.containskey(quoteLine.Id)){
                        quoteColorErrorMap.put(quoteLine.Id,new List<String>{'core_cpq_altera_reg_txt__c'});
                    }else{
                        quoteColorErrorMap.get(quoteLine.Id).add('core_cpq_altera_reg_txt__c');
                    }
                }
                else if(!(String.IsBlank(((String)quoteLine.get('core_cpq_altera_reg_txt__c')))) && !existingDesignRegistrationProdSet.contains((String)quoteLine.get('core_cpq_altera_reg_txt__c'))){
                    String drp = (String)quoteLine.get('core_cpq_altera_reg_txt__c');
                    invalidDesignRegistrationProdSet.add(drp);
                    if(!quoteColorErrorMap.containskey(quoteLine.Id)){
                        quoteColorErrorMap.put(quoteLine.Id,new List<String>{'core_cpq_altera_reg_txt__c'});
                    }else{
                        quoteColorErrorMap.get(quoteLine.Id).add('core_cpq_altera_reg_txt__c');
                    }
                }
                lineNumber = lineNumber + 1; 
            }
            Integer invalidDrpNo = 1;
            if(opptyBlankError == true){
                if(String.isBlank(result)){
                    result = 'Design Registration product not allowed without Opportunity assignment. Please associate the appropriate Opportunity in Quote header first.';
                }else{
                    result = result + ', Design Registration product not allowed without Opportunity assignment. Please associate the appropriate Opportunity in Quote header first';
                }
            }
            if(!invalidDesignRegistrationProdSet.isEmpty()){
                if(String.isBlank(result)){
                    result = 'The following DRPs are invalid : ';
                }else{
                    result = result + ', The following DRPs are invalid : ';
                }
                for (String drp : invalidDesignRegistrationProdSet) {
                    if(invalidDrpNo==1){
                        result = result +drp;
                    }else{
                        result = result +' , '+drp;
                    }
                    invalidDrpNo = invalidDrpNo+1;
                }
            }	
            if(mandatoryFieldsMissingError){
                if(String.isBlank(result)){
                    result = 'Please fill the mandatory fields';
                }else{
                    result = result +', Please fill the mandatory fields';
                }
            }
            return (new PSG_QuoteRequestController.validationWrapper(quoteColorErrorMap,result));
        }catch(Exception ex){
            PSG_Utility.logError(ex);
            return null;
        } 
    }
    
    /*****************************************************************************************************************
    * Class Name: validationWrapper
    * Author: Avani
    * Date: 12/5/2020 
    * Description:Wrapper class to handle OPN Validations.
    *****************************************************************************************************************/
    public without sharing class validationWrapper{
        @AuraEnabled public Map<Id,List<String>> quoteColorErrorMap;
        @AuraEnabled public String error;
        public validationWrapper(Map<Id,List<String>> quoteColorErrorMap,String error){
            this.quoteColorErrorMap = quoteColorErrorMap;
            this.error = error;
        }
    } 
}