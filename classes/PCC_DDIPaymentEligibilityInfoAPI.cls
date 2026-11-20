@RestResource(urlMapping='/ddr-payment-eligibility/*')
global with sharing class PCC_DDIPaymentEligibilityInfoAPI {
    
    @HttpGet
    global static void getPaymentEligibility(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isSuccess = false;
        Boolean isError = false;
        
        String mmid = req.params.get('mmid');
        String orderingCode = req.params.get('orderingcd');
        String oldMMID = req.params.get('oldmmid');
        Id idOfProductMMAttributeMapping;
        Integer paramSize  = RestContext.request.params.keySet().size();
        string queryPart1;
        string queryPart2;
       
        Product_MM_Attribute_Mapping__c l4l5Mapping = new Product_MM_Attribute_Mapping__c();
        //PCC_ParnterLed_Price__c partnerLedPriceDetail = new PCC_ParnterLed_Price__c();
        PCC_Wrapper.PCC_MasterData_ErrorWrapper errWrp = new PCC_Wrapper.PCC_MasterData_ErrorWrapper();
        PCC_Wrapper.PCC_restAPIPayment_Eligible respWrp = new PCC_Wrapper.PCC_restAPIPayment_Eligible();
        
        if(paramSize == 1){
                if(mmid != null || orderingCode != null || oldMMID!= null){
                    try{
                        if(mmid != null){
                           queryPart2 =  'Name =:mmid';
                        }else if(orderingCode != null){
                           queryPart2 = 'Ordering_Code__c =:orderingCode';
                        }else if(oldMMID != null){
                            queryPart2 = 'MMID__c =:oldMMID';
                        }
                        queryPart1 = 'SELECT id,Ordering_Code__c,MMID__c, Name,L4_Product__r.Name,L5_Product__r.Name,Payment_Expiration_Date__c,Eligible_for_DDI_Payment__c,DDI_focused__c,PCC_DDI_Program_Pay_Rate_APJ_PRC__c From Product_MM_Attribute_Mapping__c where ' ;                       
                        queryPart1 +=queryPart2 ;
                        l4l5Mapping = Database.query(queryPart1);
                        
                        system.debug('mmid --> ' + mmid  + ' ordering code --> ' + orderingCode +   'old MMID --> ' + oldMMID);
                        
                        PCC_Wrapper.PCC_paymentInfo_Price plpWrp = new PCC_Wrapper.PCC_paymentInfo_Price();
                        plpWrp.mmid = l4l5mapping.Name;
                        plpWrp.orderingCode = l4l5mapping.Ordering_Code__c;
                        plpWrp.oldMMid = l4l5mapping.MMID__c;
                        plpWrp.DDIProgramPaymentExpirationDate = l4l5mapping.Payment_Expiration_Date__c;
                        plpWrp.DDIProgramPaymentEligible = l4l5mapping.Eligible_for_DDI_Payment__c;
                        plpWrp.DDIProgramPayRateNAREMEA = l4l5mapping.DDI_focused__c;
                        plpWrp.DDIProgramPayRateAPJPRC = l4l5mapping.PCC_DDI_Program_Pay_Rate_APJ_PRC__c;
                       
                        
                        // PCC_Wrapper.PCC_restAPIPayment_Eligible respWrp = new PCC_Wrapper.PCC_restAPIPayment_Eligible();
                        respWrp.StatusCode = 200 ;
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
                        }
                        else if(oldMMID != null){
                                errWrp.ResponseBody = 'No Product tagged with provided oldMMID: '+ oldMMID;
                                errWrp.ErrorCode = 9011;
                                isError = true;
                        }
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