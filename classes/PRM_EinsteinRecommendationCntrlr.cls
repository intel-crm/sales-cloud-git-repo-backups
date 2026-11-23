public without sharing class PRM_EinsteinRecommendationCntrlr {
   
    Map<Id,Map<String,String>> contactTrainingMap= new Map<Id,Map<String,String>>();
    Map<Id,Map<String,String>> accProductMap= new Map<Id,Map<String,String>>();
    private static final String BASE_URL = 'https://intel--crmdevsls3.sandbox.my.salesforce.com/services/data/v58.0/connect/recommendation-strategies/';
    private static final String CONTENT_TYPE = 'application/json';

    public void processRecommendations(String contactRecordId, String accId, Integer maxResults) {
        //Map<String, String> contactTrainingRecommendations = getTrainingRecommendations(contactRecordId, maxResults);
        Map<String, Partner_Training_Links__c> contactTrainingRecommendations = getTrainingRecommendations(contactRecordId, maxResults);
        Map<String, String> productRecommendations = getProductRecommendations(accId, maxResults);
        if (contactTrainingRecommendations != null && !contactTrainingRecommendations.isEmpty() && 
            productRecommendations != null && !productRecommendations.isEmpty()) {
            createTrainingRec(contactTrainingRecommendations, contactRecordId);
            createProductRec(productRecommendations, accId);
            sendEmail();
            System.debug('accProductMap keys after sending email: ' + accProductMap.keySet());
        }else {
            System.debug('Map is still empty');
        }
        
    }

    
    // Get Training Links
    public Map<String, Partner_Training_Links__c> getTrainingRecommendations(String contactId, Integer maxResults) {   
        Map<String, String> recommendationMap = sendRecommendationRequest('Training_Recommendations_Strategy_Builder',contactId,5);
        System.debug('recommendationMap Training----'+recommendationMap);
        Map<String, Partner_Training_Links__c> partnerTrainingMap = new Map<String, Partner_Training_Links__c>();
        List<String> recordIds = new List<String>(recommendationMap.keySet());
        Map<Id, Partner_Training_Links__c> recordMap = new Map<Id, Partner_Training_Links__c>(
                                                        [SELECT id, Training_Name__c, Training_Description__c,Training_Link__c 
                                                        FROM Partner_Training_Links__c 
                                                        WHERE Id IN :recordIds]
                                                    );
        for (String recordId : recordIds) {
            Partner_Training_Links__c record = recordMap.get(recordId);
            System.debug('record @ 30--'+record);
            partnerTrainingMap.put(recordId, record);
        }
        if (recommendationMap != null && !recommendationMap.isEmpty()) {
            contactTrainingMap.put(contactId, recommendationMap);
        }else {
            System.debug('No training recommendations to send.');
        }  
        return partnerTrainingMap;
    }

    // Get Product Recommendations
    public Map<String, String> getProductRecommendations(String accId, Integer maxResults) {
        Map<String, String> recommendationMap = sendRecommendationRequest('Training_Recommendations_Strategy_Builder', accId, maxResults);
        System.debug('recommendationMap Product----'+recommendationMap);
        if (recommendationMap != null && !recommendationMap.isEmpty()) {
            accProductMap.put(accId, recommendationMap);
            System.debug('accProductMap--------'+accProductMap);
        } else {
            System.debug('No product recommendations to send.');
        }
        return recommendationMap;
    }

    private Map<String, String> sendRecommendationRequest(String recName, String contextRecordId, Integer maxResults) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Map<String, Object> requestBody = new Map<String, Object>();
        
        request.setEndpoint(BASE_URL + recName + '/recommendations');
        request.setMethod('POST');
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', CONTENT_TYPE);
        requestBody.put('contextRecordId', contextRecordId);
        requestBody.put('maxResults', maxResults);
        request.setBody(JSON.serialize(requestBody));
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            String responseBody = response.getBody();
            return parseJSONTrainingLinks(responseBody);
        } else {
            System.debug('Error response: ' + response.getStatusCode() + ' - ' + response.getBody());
            return null;
        }
    }

    private void createTrainingRec(Map<String, Partner_Training_Links__c> recommendationMap, String contextRecordId) {
        List<PRM_PartnerRecommendations__c> partnerRecList = new List<PRM_PartnerRecommendations__c>();
        
        for (String recommendationId : recommendationMap.keySet()) {
            Partner_Training_Links__c currentLink = recommendationMap.get(recommendationId);
            PRM_PartnerRecommendations__c partnerRec = new PRM_PartnerRecommendations__c();
            partnerRec.PRM_Contact__c = contextRecordId;
            partnerRec.PRM_Recommendation_Type__c='Training Link';
            partnerRec.PRM_RecommendationId__c = recommendationId;
            partnerRec.PRM_Training_Links__c = recommendationMap.get(recommendationId).Training_Link__c;
            partnerRec.PRM_Training_Nm__c = recommendationMap.get(recommendationId).Training_Name__c;
            partnerRec.PRM_Training_Desc__c = recommendationMap.get(recommendationId).Training_Description__c;
            partnerRecList.add(partnerRec);
            System.debug('partnerRecList Training-----'+partnerRecList);
        }
        if (!partnerRecList.isEmpty()) {
            Database.insert(partnerRecList);
            System.debug('partnerRecList after insert Training-----'+partnerRecList);
        }
    }
    private void createProductRec(Map<String, String> recommendationMap, String contextRecordId) {
        List<PRM_PartnerRecommendations__c> partnerRecList = new List<PRM_PartnerRecommendations__c>();
        Map<Id, Set<Id>> accountToContactsMap = new Map<Id, Set<Id>>();
        List<Contact> associatedContacts = [SELECT Id, Email, AccountId FROM Contact WHERE AccountId =: contextRecordId AND Email != null];
        for (Contact c : associatedContacts) {
            System.debug('c---'+c);
            if (!accountToContactsMap.containsKey(c.AccountId)) {
                accountToContactsMap.put(c.AccountId, new Set<Id>());
            }
            accountToContactsMap.get(c.AccountId).add(c.Id);
            System.debug('accountToContactsMap---'+accountToContactsMap);
        }
        for (String recommendationId : recommendationMap.keySet()) {
            PRM_PartnerRecommendations__c partnerRec;
            System.debug('recommendationId---'+recommendationId);
            for (Id conId :accountToContactsMap.get(contextRecordId)) {
                System.debug('112---'+accountToContactsMap.get(contextRecordId));
                System.debug('conId 113--'+conId);
                partnerRec=new PRM_PartnerRecommendations__c();
                partnerRec.PRM_Account__c = contextRecordId;
                partnerRec.PRM_Recommendation_Type__c='Product';
                partnerRec.PRM_Contact__c = conId;            
                partnerRec.PRM_RecommendationId__c = recommendationId;
                partnerRec.PRM_Training_Links__c = recommendationMap.get(recommendationId);
                partnerRecList.add(partnerRec);
                System.debug('partnerRecList Product-----'+partnerRecList);
            }
        }
        if (!partnerRecList.isEmpty()) {
           // Database.insert(partnerRecList);
            System.debug('partnerRecList after insert Product-----'+partnerRecList);
        }
    }
    
    private static Map<String,String> parseJSONTrainingLinks(String jsonResponse) {
        Map<String,String> targetIdNameMap = new Map<String,String>();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        if (jsonMap.containsKey('recommendations')) {
            List<Object> recommendationsList = (List<Object>) jsonMap.get('recommendations');
            for (Object recObj : recommendationsList) {
                
                System.debug('recObj--'+recObj);
                Map<String, Object> recommendation = (Map<String, Object>) recObj;
                Map<String, Object> target = (Map<String, Object>) recommendation.get('target');
                if(target != null){
                    System.debug('target--'+target);
                    String id = (String) target.get('id');
                    //Partner_Training_Links__c record = [SELECT id, Training_Name__c, Training_Description__c,Training_Link__c FROM Partner_Training_Links__c WHERE Id = :targetId];
                    //System.debug('Partner Training Link Target Name'+record);
                    String name = (String) target.get('name');
                    if (id != null && name != null) {
                        targetIdNameMap.put(id, name);
                        System.debug('targetIdNameMap----'+targetIdNameMap);
                    }
                }   
            }
        }
        return targetIdNameMap;
    }

    public static void sendEmail() {
        Map<String, List<PRM_PartnerRecommendations__c>> recStagingMap = new Map<String, List<PRM_PartnerRecommendations__c>>();        
        List<PRM_PartnerRecommendations__c> partnerRecListUpdate = new List<PRM_PartnerRecommendations__c>();
        Map<String,List<PRM_PartnerRecommendations__c>> recTypeValueMap;
		//List<PRM_PartnerRecommendations__c> lstdata;
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<string> partRecList = new List<string>();
        Map<String, String> contactNames = new Map<String, String>();
        Map<String, String> contactEmails = new Map<String, String>();

        List<PRM_PartnerRecommendations__c> partnerRecList = [SELECT Id, PRM_Contact__c,PRM_Training_Nm__c,PRM_Training_Links__c,PRM_Training_Desc__c,PRM_Contact__r.Email,PRM_Contact__r.FirstName,PRM_Contact__r.LastName, PRM_Account__c,PRM_Recommendation_Type__c,PRM_Product__c,PRM_IsEmailSent_Ind__c 
                                                             FROM PRM_PartnerRecommendations__c 
                                                             WHERE PRM_Contact__c ='003Df00000e5wP5IAI' limit 7];//PRM_IsEmailSent_Ind__c = false AND  (PRM_Recommendation_Type__c='Training Link' OR PRM_Recommendation_Type__c='Product')];                                                    
        System.debug('partnerRecList---'+partnerRecList);                                                       
        for (PRM_PartnerRecommendations__c rec : partnerRecList) {
            if (rec.PRM_Contact__r.Email != null && !contactEmails.containsKey(rec.PRM_Contact__c)) {
                contactNames.put(rec.PRM_Contact__c, rec.PRM_Contact__r.FirstName + ' ' + rec.PRM_Contact__r.LastName);
                contactEmails.put(rec.PRM_Contact__c, rec.PRM_Contact__r.Email);
                System.debug('contactEmails---'+contactEmails);
            }
        }
        //recStagingMap.put('003Df00000e5wP5IAI', partnerRecList);
        //System.debug('recStagingMap after 186---'+recStagingMap.get('003Df00000e5wP5IAI'));
        for(PRM_PartnerRecommendations__c partnerRec:partnerRecList){
                
            if(recStagingMap.containskey(partnerRec.PRM_Contact__c)){
                List<PRM_PartnerRecommendations__c> existingList = recStagingMap.get(partnerRec.PRM_Contact__c);
                existingList.add(partnerRec);
                recStagingMap.put(partnerRec.PRM_Contact__c, existingList);
                System.debug('recStagingMap if---'+recStagingMap);   
            }else{
                List<PRM_PartnerRecommendations__c> newList = new List<PRM_PartnerRecommendations__c>();
                newList.add(partnerRec);
                recStagingMap.put(partnerRec.PRM_Contact__c, newList);
                System.debug('recStagingMap else---'+recStagingMap);
            }        
        
        System.debug('recStagingMap 201---'+recStagingMap);
        // for(String key:recStagingMap.keyset()){
        //             system.debug('key--> '+key);
        //     if(recStagingMap.get(key).containskey('Training')){
        //         for(String val:recStagingMap.get(key).get('Training')){
        //                 system.debug('Training FINAL----'+val);
        //         }
        //     }
        //     if(recStagingMap.get(key).containskey('Product')){
        //         for(String val:recStagingMap.get(key).get('Product')){
        //                 system.debug('Product FINAL----'+val);
        //         } 
        //     }                 
        // }
        }
            String emailStyle = '<style>'
                + 'table {width: 50%; border: 1px solid #000000; border-collapse: collapse;margin: auto;padding: 10px;}'
                + 'th {background-color: #0072CE; color: white; text-align: center;}'
                + 'td {border-top: 1px solid #000; padding: 8px;vertical-align: top;}'
                + 'tr:nth-child(even) {background-color: #f2f2f2;}'
                + '.small-text {font-size:14px;}'
                + '.blue-footer {background-color:#0072CE; color:white; padding:10px;align:center;}'
                + '.email-container {width:50%; margin:50%; padding:10px;border:1px solid #000;}'
                + '</style>';
                String emailBody; 
                String firstCol = '';
                String secondCol = '';
                Integer counter = 0;
            for(String contactId:recStagingMap.keyset()){
            emailBody= '';
            List<PRM_PartnerRecommendations__c> typeValMap = recStagingMap.get(contactId);
            List<PRM_PartnerRecommendations__c> typeValueList;
            emailBody += emailStyle
                + '<table style="width:100%;"><tr><td style="text-align: center;">'
                + '<table style="width:50%;"><tr><td style="text-align: left;border-style: none;">'
                + '<span style="font-size: 14px; color: grey;">Congratulations, Your membership request has been approved and processed!<br><br>'
                + 'When you login to IPA, navigate to manage benefits to view all the content, resources and benefits available to you.<br><br>'
                + 'Login to https://intel--crmdevsls3.sandbox.my.salesforce-setup.com/ipa/s/post-launch-primary to get started !<br><br>'
                + 'To ensure uninterrupted access to your account, Intel recommends having atleast 2 multi-factor authentication methods.<br> You can add '
                + 'an additional method by visiting the Intel Azure Security Information page and select Add sign-in method.<br><br>'
                + 'Below are some of the key training and Product promotions which u might be interested in.</span> '
                + '</td></tr>';
                emailBody += '<table><tr>';
                Integer count = 0;
                    for(PRM_PartnerRecommendations__c typeValue :typeValMap) {
                        count++;
                        String description = typeValue.PRM_Training_Desc__c;
                        if(description.length() > 60) {
                            description = description.substring(0, 60) + '...';
                        }
                        emailBody += '<td><div class="card" style="width: 10px; border-radius: 5px solid #ddd; padding: 10px; margin: 10px; ">';
                        emailBody += '<h style="color:blue;">' + typeValue.PRM_Training_Nm__c + '</h>';
                        emailBody += '<table style="width: 20%; font-size: 12px;">';
                        emailBody += '<tr><td style="border: 1px solid #ddd; padding: 8px; text-align: left;">Description</td><td style="border: 1px solid #ddd; padding: 8px; text-align: left;">' + description + '</td></tr>';
                        emailBody += '<tr><td style="border: 1px solid #ddd; padding: 8px; text-align: left;">Link </td><td style="border: 1px solid #ddd; padding: 8px; text-align: left;">' + typeValue.PRM_Training_Links__c + '</td></tr>';
                        emailBody += '</table>';
                        emailBody += '</div></td>';
                        if (count == 2) {
                            emailBody += '</tr><tr>';
                            count = 0;
                        }
                    }
                    emailBody += '</tr></table>';
               
                //}
                                    
                // if(typeValMap.containsKey('Product')){
                //     typeValueList = typeValMap.get('Product');
                //     //emailBody += emailStyle    
                //     //emailBody+= '<td><table style="vertical-align: top;"><tr><th>Products running under Promotion </th></tr>';
                //     emailBody += '<table class="card-container">';
                //     for(String typeValue :typeValueList){
                //         System.debug('typeValue Product----'+typeValue);
                //         //emailBody += '<tr><td><span class="small-text">' + typeValue + '</span></td></tr>';    
                //         emailBody += '<tr><td class="card"><span class="small-text">'
                //     //+ typeValue + '</td></tr>';
                //         + 'Product Test'+ '</td></tr>';
                // }
                    
                  //  emailBody += '</table>';
                  //  System.debug('emailBody 2---'+emailBody);
                //}
                //emailBody += '</tr></table>';
                emailBody += '<br><br><div class="blue-footer">'
                        + 'This message was sent to you as an important Business communication related to your current relationship with Intel Partner Alliance<br>'
                        + '2024 Intel Corporation<br>'
                        + 'Intel Corporation,2200 Mission College Blvd., M/SRNB4-145, Santa Clara, CA 95054 USA. www.intel.com<br>'
                       // + '</div>'
                        + '</div></td></tr></table>';
                      
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.setToAddresses(new String[] {contactEmails.get(contactId)});
                mail.setToAddresses(new String[] {'sandhya.dayananda@intel.com'}); 
                mail.setSubject('Thank You for Registering to IPA !');
                mail.setHtmlBody(emailBody);
                emailsToSend.add(mail);
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            boolean sentEmailInd = false;
            
            for (Messaging.SendEmailResult result : results) {
                System.debug('result---'+result);
                if (result.isSuccess()) {
                    sentEmailInd =true;   
                } else {
                    sentEmailInd = false;
                    System.debug('Partner Email failed to send: ' + result.getErrors());
                }
            }
            if(sentEmailInd){
                for (PRM_PartnerRecommendations__c rec : partnerRecList) {
                    //if (rec.PRM_Contact__c == contactId) {
                    rec.PRM_IsEmailSent_Ind__c = true;
                    partnerRecListUpdate.add(rec);
                    //}
                    System.debug('rec--'+rec);
                }
            }
            if (!partnerRecListUpdate.isEmpty()) {
                update partnerRecListUpdate;
                System.debug('partnerRecListUpdate---'+partnerRecListUpdate);
            } 
        }
    //}
}