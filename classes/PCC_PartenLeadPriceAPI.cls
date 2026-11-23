@RestResource(urlMapping='/partner-led-price/*')
global with sharing class PCC_PartenLeadPriceAPI {
    
    @HttpGet
    global static void getPartnerLedPrice(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isSuccess = false;
        Boolean isError = false;
        
        String mmid = req.params.get('mmid');
        String orderingCode = req.params.get('orderingcd');
        //String oldMMID = req.params.get('oldmmid'); /*TWC727-2709 - PCC: Remove all references from old MMID*/
        Id idOfProductMMAttributeMapping;
        Integer paramSize  = RestContext.request.params.keySet().size();
        string queryPart1;
        string queryPart2;
       
        Product_MM_Attribute_Mapping__c l4l5Mapping = new Product_MM_Attribute_Mapping__c();
        PCC_ParnterLed_Price__c partnerLedPriceDetail = new PCC_ParnterLed_Price__c();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        PCC_Wrapper.PCC_restAPIParnterLed_Price respWrp = new PCC_Wrapper.PCC_restAPIParnterLed_Price();
        
        if(paramSize == 1){
            if(mmid != null || orderingCode != null){// || oldMMID!= null){ /*TWC727-2709 - PCC: Remove all references from old MMID*/
                    try{
                        if(mmid != null){
                           queryPart2 =  'Name =:mmid';
                        }else if(orderingCode != null){
                           queryPart2 = 'Ordering_Code__c =:orderingCode';
                        }/*TWC727-2709 - PCC: Remove all references from old MMID*/
                        /*else if(oldMMID != null){
                            queryPart2 = 'MMID__c =:oldMMID';
                        }*/ 
                       // queryPart1 = 'SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where ' ;
                        queryPart1 = 'SELECT id,Ordering_Code__c,Name,L4_Product__r.Name,L5_Product__r.Name From Product_MM_Attribute_Mapping__c where ' ;
                        queryPart1 +=queryPart2 ;
                        l4l5Mapping = Database.query(queryPart1);
                        /*
                        idOfProductMMAttributeMapping = l4l5Mapping.id;
                        partnerLedPriceDetail = [select id, Name, PCC_Recommended_Customer_Price__c, PCC_Standard_Disti_Price__c from PCC_ParnterLed_Price__c where PCC_Product_MM_Attribute_Mapping__c =:idOfProductMMAttributeMapping];
                        */
                        idOfProductMMAttributeMapping = l4l5Mapping.id;
                        partnerLedPriceDetail = [select id, Name, PCC_Recommended_Customer_Price__c, PCC_Standard_Disti_Price__c from PCC_ParnterLed_Price__c where PCC_Product_MM_Attribute_Mapping__c =:l4l5Mapping.id];
                        
                        
                        
                        //system.debug('mmid --> ' + mmid  + ' ordering code --> ' + orderingCode +   'old MMID --> ' + oldMMID);
                        
                        PCC_Wrapper.PCC_parnterLed_Price plpWrp = new PCC_Wrapper.PCC_parnterLed_Price();
                        plpWrp.mmid = l4l5mapping.Name;
                        plpWrp.orderingCode = l4l5mapping.Ordering_Code__c;
                       // plpWrp.oldMMid = l4l5mapping.MMID__c; /*TWC727-2709 - PCC: Remove all references from old MMID*/
                        plpWrp.StandardDistiPrice = partnerLedPriceDetail.PCC_Standard_Disti_Price__c;
                        plpWrp.RecommendedCustomerPrice = partnerLedPriceDetail.PCC_Recommended_Customer_Price__c;
                        
                        // PCC_Wrapper.PCC_restAPIParnterLed_Price respWrp = new PCC_Wrapper.PCC_restAPIParnterLed_Price();
                        respWrp.StatusCode = 200;
                        respWrp.Status = 'SUCCESS';
                        respWrp.ErrorCode = null;
                        respWrp.ResponseBody = plpWrp;
                        respWrp.RecordId = null;
                        isSuccess =  true;
                        system.debug('respWrp-->'+respWrp);
                    }
                    catch(QueryException e){
                        if(mmid != null){
                                errWrp.ResponseBody = 'No Product tagged with provided MMID: '+ mmid;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }
                        else if(orderingCode != null){
                                errWrp.ResponseBody = 'No Product tagged with provided orderingcode: '+ orderingCode;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }/*TWC727-2709 - PCC: Remove all references from old MMID*/
                        /*else if(oldMMID != null){
                                errWrp.ResponseBody = 'No Product tagged with provided oldMMID: '+ oldMMID;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }*/ 
                    }
                }
            }
        	else if(paramSize == 0){
                RestContext.response.addHeader('Content-Type', 'application/json');      
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(PCC_CreateDDRUtilityHandler.setResponseBody(400, 'FAILURE', 400, 'Please provide MMID or ordering code to get L4 &L5 product details ', null))); 
            }
            if(isSuccess){
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrp));      
                RestContext.response.statusCode = 200;
            }else if(isError){
                errWrp.StatusCode = 400;
                errWrp.Status = 'FAILURE';
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(errWrp));      
                RestContext.response.statusCode = 400;
            }           
        }       
    }