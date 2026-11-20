/****************************************************************************************************************************************
* Class Name  : Core_RestAPI_Opportunities 
* Version     : 1.0 
* Created Date: 05 Aug 2023
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Biswa			        05/08/2023            	Rest API to get opportunity data
GET=>
Sample API call:- /v1.0/opportunity?id=
type => quote (fetch section 1 details)
type => blank, all (fetch all 4 section details)
id => quoteId
*****************************************************************************************************************************************/
@RestResource(urlMapping='/v1.0/opportunity')
global with sharing class Core_RestAPI_Opportunities {
    
    private static final DateTime ENTRY_TIME = System.now();
    private static final String RESTAPI_NAME = Core_RestAPI_Opportunities.class.getName();
    public static Core_SalesCRM_RestAPI_Response response = new Core_SalesCRM_RestAPI_Response();
    public static OpportunityWrapper opportunityWrapper = new OpportunityWrapper();
    public static String type;
    public static String recId;
    public static Id opportunityId;
    
    @HttpGet
    global static Core_SalesCRM_RestAPI_Response doGet(){
        if(validateRequest()){
            //Valid Request
            getAllDetails();
        }else{
            //Not a Valid Request
            Core_SalesCRM_RestAPI_Util.processException(null, MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
        return response;
    }
    
    
    //validating
    private static boolean validateRequest(){
        boolean isValid=false;
        RestRequest restReq = RestContext.request;
        type = String.isEmpty(restReq.params.get('type')) ? 'all' : restReq.params.get('type').toLowerCase();
        recId = restReq.params.get('id');
        try{                             
            if(!String.isEmpty(recId) && (String.isEmpty(type) || type.toLowerCase() == 'all' || type.toLowerCase() == 'opportunity')){
                try{
                    opportunityId = Id.valueOf(recId);
                    isValid=true;
                }catch(Exception  exp){ isValid=false;
                }
            }
            else{
                isValid = false;
            }
            if(!isValid){
                Core_SalesCRM_RestAPI_Util.processException(null, MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);  
            }
            
        }catch(Exception exp){ Core_SalesCRM_RestAPI_Util.processException(exp, ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);
        }finally {
            if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_200; 
            }
            Core_SalesCRM_RestAPI_Util.logTransaction(ENTRY_TIME, response);            
        } 
        return isValid;
    }
    
    public static void getAllDetails(){        
        List<Opportunity> opportunities = getAllOpportunityDetails();
        if(opportunities.size()>0){
            opportunityWrapper.opportunityDetails = new Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails();
            
            //for type = all or empty : get all sections of opportunity
            if(String.isEmpty(type) || type.toLowerCase() == 'all'){
                getOpportunityDetails(opportunities[0], opportunityWrapper.opportunityDetails);  
                getOpportunityProductDetails(opportunityWrapper.opportunityDetails, opportunities[0].OpportunityLineItems );
            }
            //for type = opportunity : get opportunity details only 
            else if(type.toLowerCase() == 'opportunity'){
                getOpportunityDetails(opportunities[0], opportunityWrapper.opportunityDetails);        
            }
            
            response.successContent = new List<OpportunityWrapper>();
            response.successContent.add(opportunityWrapper);
            response.totalRecords= 1;
        }
        else{
            Core_SalesCRM_RestAPI_Util.processException(null, MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
        }
    }
    
    public static List<Opportunity> getAllOpportunityDetails(){
        List<Opportunity> opportunities = new List<Opportunity>();
        //for type = empty or all : query all four sections
        if(String.isEmpty(type) || type.toLowerCase() == 'all'){
            opportunities = Database.query(Label.Core_RestAPI_OpportunityQuery + Label.Core_RestAPI_OpportunityQuery1);
        }            
        //for type = opportunity : query opportunity section
        else if(type.toLowerCase() == 'opportunity'){
            opportunities = Database.query(Label.Core_RestAPI_OpportunityOnlyQuery);
        }        
        return opportunities;
    }
    
    public static void getOpportunityDetails(Opportunity opp, Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails oppDetails){
        
        oppDetails.opportunityId = opp.id;
        oppDetails.opportunityName     = opp.name;
        oppDetails.stage    = opp.stagename;
        oppDetails.accountName = opp.Account.Name;
        oppDetails.opportunityRegion     = opp.Core_Opportunity_Owner_Geo__c;
        oppDetails.designRegistrationId     = opp.Core_Design_Registration_Id__c;
        oppDetails.designRegistrationName     = opp.Core_Design_Registration_Id__r.Name;
        oppDetails.decisionDate     = opp.CloseDate;
        oppDetails.probability     = opp.Probability;
        oppDetails.opportunityType     = opp.Core_Opportunity_Type__c;
        oppDetails.opportunityOwner     = opp.Owner.Name;
        oppDetails.technicalOwner     = opp.Core_Technical_Owner__r.Name;
        oppDetails.productSegment     = opp.Core_Product_Segment__c;
        oppDetails.productApplication     = opp.Core_Product_Application__c;
        oppDetails.amount     = opp.Amount;
        oppDetails.verticalMarket     = opp.Core_Consumption_Market__c;
        oppDetails.competitiveArchitecture     = opp.Core_Competitive_Architecture__c;
        oppDetails.statusUpdate     = opp.Core_Status_Update__c;
        oppDetails.architectureConversion     = opp.Core_Architecture_Conversion__c;
        oppDetails.LossCancelRegion     = opp.Core_Loss_Cancel_Reason__c;
        oppDetails.LossCancelDetails     = opp.Core_Loss_Cancel_Details__c;
        oppDetails.description     = opp.Description;
        //oppDetails.IntelPlatform     = opp.Core_Intel_Platform__c;
        oppDetails.volume     = opp.Core_Volume__c;
        oppDetails.firstCustomerShipDate     = opp.Core_First_Customer_Ship_Date__c;
        oppDetails.productionEndDate     = opp.Core_Production_End_Date__c;
        oppDetails.manufacturingRegion     = opp.Core_Manufacturing_Geo__c;
        oppDetails.areIntelItemsUsedForMINDS     = opp.Core_Military_Aerospace_Govmt_End_Use__c;
        oppDetails.complianceComments     = opp.Core_Compliance_Comments__c;
        oppDetails.complianceStatus     = opp.Core_Compliance_Status__c;
        oppDetails.complianceSubStatus     = opp.Core_Compliance_Sub_Status__c;
        oppDetails.createdBy     = opp.CreatedBy.Name;
        oppDetails.createdDate     = opp.CreatedDate;
        oppDetails.lastModifiedBy     = opp.LastModifiedBy.Name;
        oppDetails.lastModifiedDate     = opp.LastModifiedDate;
    }
    
    public static void getOpportunityProductDetails(Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails oppDetails, List<OpportunityLineItem> OppProducts){
        
        oppDetails.opportunityProducts = new List<Core_RestAPI_OpportunityDetailsWrapper.OpportunityProducts>();
        for(OpportunityLineItem oppProd : OppProducts){
            Core_RestAPI_OpportunityDetailsWrapper.OpportunityProducts oppProdWrapper = new Core_RestAPI_OpportunityDetailsWrapper.OpportunityProducts();
            oppProdWrapper.opportunityProductId = oppProd.id;
            oppProdWrapper.product =oppProd.Product2.Name;
            oppProdWrapper.status =oppProd.Core_Status__c;
            oppProdWrapper.quantity =oppProd.Quantity;
            oppProdWrapper.competitor =oppProd.Core_Competitor__c;
            oppProdWrapper.competitorProduct =oppProd.Core_Competitor_Product__c;
            oppProdWrapper.salesPrice =oppProd.UnitPrice;
            oppProdWrapper.lossCancelRegion =oppProd.Core_Loss_Cancel_Reason__c;
            oppProdWrapper.createdDate =oppProd.CreatedDate;
            oppProdWrapper.lastModifiedDate =oppProd.LastModifiedDate;
            oppProdWrapper.createdBy =oppProd.CreatedBy.Name;
            oppProdWrapper.lastModifiedBy =oppProd.LastModifiedBy.Name;
            oppProdWrapper.designRegistrationProductId = oppProd.Core_Design_Registration_Product_Id__c;
            oppProdWrapper.totalPrice = oppProd.TotalPrice;
            
            oppDetails.opportunityProducts.add(oppProdWrapper);
        }
    }
    
    
    public class OpportunityWrapper implements Core_RestAPI_SuccessContent {
        Core_RestAPI_OpportunityDetailsWrapper.OpportunityDetails opportunityDetails;
    }
    //////////////////////////////////////////////////////////
    @HttpPut
    global static Core_SalesCRM_RestAPI_Response doPut(){
        RestRequest req = RestContext.request;
        processUpdateRequest(req.requestBody.toString()); 
        return response;
    }
    
    public static void processUpdateRequest(String reqBody){
        try {
            Core_RestAPI_OpportunitiesUtility.OpportunityWrapper opp = (Core_RestAPI_OpportunitiesUtility.OpportunityWrapper) JSON.deserialize(reqBody, Core_RestAPI_OpportunitiesUtility.OpportunityWrapper.class);
            Core_RestAPI_OpportunitiesUtility.OpportunityErrorMsg oppErrors = new Core_RestAPI_OpportunitiesUtility.OpportunityErrorMsg();
            Core_RestAPI_OpportunitiesUtility opportunityUtility = new Core_RestAPI_OpportunitiesUtility();
            List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
            boolean isValid = opportunityUtility.validateOpportunity(opp, oppErrors, true); 
            if(isValid){
                Opportunity newOpp = Core_RestAPI_OpportunitiesUtility.createOpportunityRecord(opp);
                newOpp.Id = opp.opportunityId;
                update newOpp;

                if(opp.opportunityProducts != null && opp.stage != 'Design Win'){
                    oppProducts = Core_RestAPI_OpportunitiesUtility.createOpportunityProdctRecords(opp.opportunityProducts);                    
					update oppProducts;                    
                }
                
                List<Core_RestAPI_OpportunitiesUtility.OpportunityPoP> oppPoP = opp.opportunityPoP;
                if(oppPoP != null){ List<ContentVersion> contentVersionList = new List<ContentVersion>();
                    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                    Set<Id> contentVersionIds = new Set<Id>(); //to store all contentVersion.Id values
                    for(Core_RestAPI_OpportunitiesUtility.OpportunityPoP q: oppPoP){String base64String = q.data;
                        String title = q.title;Blob fileBlob = EncodingUtil.base64Decode(base64String);
                        
                        //For File
                        ContentVersion contentVersion = new ContentVersion();contentVersion.ContentLocation = 'S'; // 'S' for Salesforce Files, 'L' for Chatter Files
                        contentVersion.PathOnClient = title; // Replace with your desired file name
                        contentVersion.Title = title; // Replace with your desired title
                        contentVersion.VersionData = fileBlob;
                        contentVersionList.add(contentVersion);
                        
                    }
                    //insert ContentVersion records first
                   	 	//insert contentVersionList;
                    //Insert ContentVersion records with partial success option
                    Database.SaveResult[] contentVersionResults = Database.insert(contentVersionList, false);
                    
                    
                    //After Insert, populate the set with inserted ContentVersion Ids
                    for(Integer i=0; i<contentVersionResults.size(); i++){ if(contentVersionResults[i].isSuccess()){ contentVersionIds.add(contentVersionList[i].Id); //Add ContentVersion.Id to Set   
                        }
                        else{
                            System.debug('Failed to insert ContentVersion:' + contentVersionResults[i].getErrors()[0].getMessage());
                        }
                    }
                    
                    //Query for ContentDocumentId for the inserted contentVersions
                    Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]); 
						                        
                        // Create a ContentDocumentLink to associate the file with a record
                    for(ContentVersion contentVersion : contentVersionList){ if(contentVersionMap.containsKey(contentVersion.Id)){ ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = contentVersionMap.get(contentVersion.Id).ContentDocumentId;
                        cdl.LinkedEntityId = opp.opportunityId; // Replace with the relevant parent record Id
                        cdl.ShareType = 'V'; // 'V' for Viewer Access
                        cdl.Visibility = 'AllUsers'; // Set the visibility as needed
                        cdlList.add(cdl);    
                        }
                        
                    }
                       
                    //}
                    
                    //insert cdlList;
                    Database.SaveResult[] cdlResults = Database.insert(cdlList, false);
                    for(Integer i=0; i<cdlResults.size(); i++){ if(!cdlResults[i].isSuccess()){
                            System.debug('Failed to insert contentDocumentLink:' + cdlResults[i].getErrors()[0].getMessage());
                        }
                    }
                }
                
               	response.totalRecords = 1;
               	response.successContent = new List<OpportunityDetails>();
               	response.successContent.add(new OpportunityDetails(String.valueOf(opp.opportunityId),'Successfully Updated!!'));
            }else {
                Core_SalesCRM_RestAPI_Util.oppErrMsgs = oppErrors;
                Core_SalesCRM_RestAPI_Util.processException(null, MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
            }        
        }catch(Exception exp){ Core_SalesCRM_RestAPI_Util.processException(exp, ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = SUCCESS_CODE_200;
            }
            Core_SalesCRM_RestAPI_Util.logTransaction(ENTRY_TIME, response);            
        }        
    }
    
    public class OpportunityDetails implements Core_RestAPI_SuccessContent {
        public String opportunityId {set;get;} 
        public String message {set;get;}
        
        public OpportunityDetails(String Id, String msg){
            opportunityId = Id;
            message = msg;
        }
    }
    
    public static String ERROR_CODE_500 = '500';
    public static String SUCCESS_CODE_200 = '200';
    public static String MALFORMED_INPUT_9011 = '9011';
    public static String NO_DATA_EXCEPTION_9001 = '9001';
    public static String INVALID_QUOTE_STATUS_9009 = '9009';
    public Static String INVALID_INPUT_PARAM_9010 = '9010';
    public Static String INVALID_URL_404 = '404';
    public Static String NO_ACCESS_9003 = '9003';
    public Static String NULL_VALUE_VALID_EXP_9002 = '9002';
}