public class Sales_OrderFailureTicketCreation {
    private static final String SAP_TICKET_CREATION_ENDPOINT = 'callout:Sales_IncidentCreation';
    private static final String HTTP_POST = 'POST';
    private static String accessToken;
    private static final String BEARER ='Bearer ';
    private static final boolean sysparm_input_display_value=false;
    private static final boolean  sysparm_display_value=true;
    private static List<Sales_SAP_Token_Detail__c> connectSettingRecordList = new List<Sales_SAP_Token_Detail__c>();
    private static final string ORIGIN = 'Sales_OrderFailureTicketCreation';
    private static final string PROJECT = 'PSG Sales';
    private static final String DEF_TOKEN_ENDPOINT = 'callout:Sales_ITSM_Incident';
    
    //Add comment
    private static void setAccessToken() {
        List<Sales_SAP_Token_Detail__c> connectSettingInfos = [Select Id, Name,Sales_Access_Token__c,Sales_Expires_In_Time__c,Sales_Expires_In_Seconds__c From Sales_SAP_Token_Detail__c 
                                                               Where Name ='SAP Order Failure Token Details'];
        if(connectSettingInfos != null && connectSettingInfos.size()>0 && connectSettingInfos[0].Sales_Expires_In_Time__c >= System.Now()){
            accessToken=connectSettingInfos[0].Sales_Access_Token__c;   
        }
        else{
            Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
            String accessTokenKey = 'access_token';
            HttpResponse response = new Http().send(getAccessTokenRequest());
            if(response.getStatusCode()==200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(responseMap.containsKey(accessTokenKey)) {
                    accessToken = (String) responseMap.get(accessTokenKey);
                    String expiresIn=(String)responseMap.get('expires_in');
                    connectSettingRecord.Sales_Access_Token__c=accessToken;
                    connectSettingRecord.Sales_Expires_In_Seconds__c=Decimal.valueOf(expiresIn);
                    connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(expiresIn));
                    connectSettingRecord.Name ='SAP Order Failure Token Details';//add as final string
                    if(connectSettingInfos!=null && connectSettingInfos.size()>0){
                        connectSettingRecord.Id=connectSettingInfos[0].Id;
                    }
                    connectSettingRecordList.clear();
                    connectSettingRecordList.add(connectSettingRecord); 
                }
            }
        }
    }
    
    //Add comment
    private static HttpRequest getAccessTokenRequest() {
        System.debug('Inside token request');
        String clientId = '{!$Credential.Username}';
        String clientSecret = '{!$Credential.Password}';
        String finalString='';
        // cred='?'+'sysparm_input_display_value='+sysparm_input_display_value+'&sysparm_display_value='+sysparm_display_value;
        String payload = 'scope='+EncodingUtil.urlEncode('api://71c9ae16-9d10-45b7-9c1d-30925311dabf/.default','UTF-8')+'&client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + '&grant_type=client_credentials';
		HttpRequest req = new HttpRequest();
        req.setEndpoint(DEF_TOKEN_ENDPOINT);
        req.setBody(payload);
        finalString=DEF_TOKEN_ENDPOINT;
        system.debug('Endpoint:'+finalString);
        req.setMethod(HTTP_POST);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        return req;
    }
    
    
    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label = 'Invoke Business Logic')
    public static void InvokeService(list<String> OrderNumber) {
        Order order = [SELECT Id, OrderNumber, CreatedById, CreatedBy.Email, AccountId, Account.Name,Sales_Sync_Comments_Txt__c FROM Order WHERE OrderNumber =: OrderNumber LIMIT 1 ];
        system.debug('CallfromProcessBuilder');
        System.enqueueJob(new ItsmTicketCreation(OrderNumber,order.Sales_Sync_Comments_Txt__c,null));
        
        
    }
    
    public class ItsmTicketCreation implements System.Queueable, Database.AllowsCallouts {
        private list<String> OrderNumber;
        private String error;
        private String incomingResponse;
        public ItsmTicketCreation(list<String> OrderNumber, String error,String incomingResponse) {
            this.OrderNumber = OrderNumber;
            this.error = error;
            this.incomingResponse=incomingResponse;
        }
        
        
        
        
        public void execute(System.QueueableContext ctx){
            Sales_ITL3_Supp3_Support_Ticket__mdt ticket=[ select id,caller_id__c, business_service__c, service_offering__c, short_description__c, impact__c, urgency__c, assignment_group__c from Sales_ITL3_Supp3_Support_Ticket__mdt Limit 1];
            String strJson = '';
            
            //System.debug('cred>>'+cred);
            JSONGenerator payloadObj = JSON.createGenerator(false); //Create instance of JSONGenerator class
            payloadObj.writeStartObject();
            payloadObj.writeStringField('caller_id',(ticket.caller_id__c));
            payloadObj.writeStringField('business_service',(ticket.business_service__c));
            payloadObj.writeStringField('service_offering',(ticket.service_offering__c));
            payloadObj.writeStringField('short_description',(ticket.short_description__c+' '+OrderNumber));
            payloadObj.writeStringField('description',(error+' Payload: '+incomingResponse));
            payloadObj.writeStringField('urgency',((ticket.urgency__c)));
            payloadObj.writeStringField('impact',((ticket.impact__c)));
            payloadObj.writeStringField('assignment_group',(ticket.assignment_group__c));
            payloadObj.writeStringField('assigned_to',(''));
            payloadObj.writeStringField('comments',(''));
            payloadObj.writeStringField('work_notes',(''));
            payloadObj.writeEndObject();
            strJson=payloadObj.getAsString();
            System.debug('strJson>>'+strJson);
            setAccessToken();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SAP_TICKET_CREATION_ENDPOINT);       //endpoint
            request.setMethod(HTTP_POST);
            request.setBody(strJson);
            request.setHeader('Authorization', BEARER + accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(120000);
            System.debug('payload generated>>>>>'+strJson);
            HttpResponse response = http.send(request);
            if(connectSettingRecordList.size()>0){
                upsert connectSettingRecordList;
            }
            system.debug('response.getBody()>>>'+response.getBody());
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','',response.getBody(), '', '', '');
            if(response!=null){
                if(response.getStatusCode()==201){
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','ITSM Ticket created Successfully','ITSM Ticket creation - Payload:'+strJson, 'OrderNumber'+OrderNumber, '', '');   //to store response  
                }else{
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','ITSM Ticket creation:','ITSM Ticket creation - Payload:'+strJson, 'OrderNumber'+OrderNumber, '', '');
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','ITSM Ticket creation:','Response StatusCode:'+response.getStatusCode()+' Ticket Creation Submission - Response:'+response.getBody(), 'Ticket Creation:'+OrderNumber, '', '');   //to store response
                }
            }
            
        }
    }
}