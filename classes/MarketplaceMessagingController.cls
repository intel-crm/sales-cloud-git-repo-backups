public with sharing class MarketplaceMessagingController {

    public class Message {
        public String author { get; set; }
        public String message { get; set; }
        public String timestamp { get; set; }
        public String type { get; set; }
        public String userID { get; set; }
    }
  
    @AuraEnabled(cacheable=true)
    public static String getMessage(String recordId , String channel){
        List<Message> messages = new List<Message>();
        List<PMP_Company_Message__c> companyMessages = new List<PMP_Company_Message__c>();
        // IPA2.0 + US TWC4497-1631
    //     if(channel=='Offering'){
       
    //         if(Schema.sObjectType.PMP_Partner_Offering_Message__c.isAccessible()){
    //             List<PMP_Partner_Offering_Message__c> partnerMessages =[select PMP_Message_By_User_Nm__c, PMP_Message_By_Id__c, PMP_Message_Dtm__c, 
    //                                                            PMP_Message_Txt__c, PMP_Message_Type__c
    //                                                            from PMP_Partner_Offering_Message__c 
    //                                                            where PMP_Partner_Offering_Id__c=:recordId order by PMP_Message_Dtm__c];
          
                
    //         for(PMP_Partner_Offering_Message__c partnerMessage:partnerMessages){
    //             Message msg = new Message();
    //             msg.author=partnerMessage.PMP_Message_By_User_Nm__c;
    //             msg.userID=partnerMessage.PMP_Message_By_Id__c;
    //             msg.timestamp=(partnerMessage.PMP_Message_Dtm__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    //             msg.message=partnerMessage.PMP_Message_Txt__c;
    //             msg.type=(partnerMessage.PMP_Message_Type__c).toLowerCase();
                
              
    //             messages.add(msg);
    //         }
    //      }
    //    }
    // else if(channel=='Solution'){
    //IPA2.0: US-TWC729-7976
    /*if(channel=='Solution'){
                
            if(Schema.sObjectType.PSS_Solution_Message__c.isAccessible()){
                List<PSS_Solution_Message__c> partnerMessages =[select PSS_Message_By_User_Nm__c, PSS_Message_By_Id__c, PSS_Message_dt__c, 
                                                               PSS_Message_Txt__c, PSS_Message_Type_Nm__c
                                                               from PSS_Solution_Message__c 
                                                               where PSS_Ardira_Survey_Result_Id__c=:recordId order by PSS_Message_dt__c];
          
                
            for(PSS_Solution_Message__c partnerMessage:partnerMessages){
                Message msg = new Message();
                msg.author=partnerMessage.PSS_Message_By_User_Nm__c;
                msg.userID=partnerMessage.PSS_Message_By_Id__c;
                msg.timestamp=(partnerMessage.PSS_Message_dt__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                msg.message=partnerMessage.PSS_Message_Txt__c;
                msg.type=(partnerMessage.PSS_Message_Type_Nm__c).toLowerCase();
                
              
                messages.add(msg);
            }
          }
            
        }
         else{*/
            
            
                if(Schema.sObjectType.PMP_Company_Message__c.isAccessible()){
                 try{
                    companyMessages = [select PMP_Message_By_User_Nm__c, PMP_Message_By_Id__c, PMP_Message_Dtm__c, 
                                                               PMP_Message_Txt__c, PMP_Message_Type__c
                                                               from PMP_Company_Message__c 
                                                               where PMP_Company_Id__c=:recordId order by PMP_Message_Dtm__c];
                }     
            catch(Exception e){
                //system.debug('No messages available for the partner : '+e.getMessage());
            }
             }
            
            
            for(PMP_Company_Message__c companyMessage:companyMessages){
                Message msg = new Message();
                msg.author=companyMessage.PMP_Message_By_User_Nm__c;
                msg.userID=companyMessage.PMP_Message_By_Id__c;
                msg.timestamp=(companyMessage.PMP_Message_Dtm__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                msg.message=companyMessage.PMP_Message_Txt__c;
                msg.type=(companyMessage.PMP_Message_Type__c).toLowerCase();
                
              
                messages.add(msg);
            }
        	return JSON.serialize(messages);
            
        }
         
        

    //Gireesh:US371910:Get Posted Message
    @AuraEnabled
    public static Boolean postMessage(String recordId, Map<String,String> message , String channel) {
      //Swathi:US925995:Added if condition to reuse the messaging Component 
      //system.debug('******'+channel);
    //   IPA2.0 + US TWC4497-1631
        // if(channel=='Offering'){
        //     if(Schema.sObjectType.PMP_Partner_Offering_Message__c.isCreateable()){
        //         PMP_Partner_Offering_Message__c offeringMessage=new PMP_Partner_Offering_Message__c();
        //         offeringMessage.PMP_Message_By_Id__c=message.get('userID');
        //         offeringMessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+message.get('timestamp')+'"'),datetime.class);
        //         offeringMessage.PMP_Message_Txt__c=message.get('message');
        //         offeringMessage.PMP_Message_Type__c=message.get('type');
        //         offeringMessage.PMP_Partner_Offering_Id__c=recordId;
        //         insert offeringMessage;
        //     }    
        // }
        //Swathi:US925995:Added if condition to reuse the messaging Component 
        
         //else if(channel=='Solution'){
        /*if(channel=='Solution'){//IPA2.0: US-TWC729-7976
          if(Schema.sObjectType.PSS_Solution_message__C.isCreateable()){
                PSS_Solution_Message__c surveyMessage=new PSS_Solution_Message__c();
                surveyMessage.PSS_Message_By_Id__c=message.get('userID');
                surveyMessage.PSS_Message_dt__c=(DateTime)json.deserialize(('"'+message.get('timestamp')+'"'),datetime.class);
                surveyMessage.PSS_Message_Txt__c=message.get('message');
                surveyMessage.PSS_Message_Type_Nm__c=message.get('type');
                surveyMessage.PSS_Ardira_Survey_Result_Id__c=recordId;
                insert surveyMessage;
            }    
        }
        else{*/
            
          if(Schema.sObjectType.PMP_Company_Message__c.isCreateable()){
                PMP_Company_Message__c partnerMessage = new PMP_Company_Message__c();
                partnerMessage.PMP_Message_By_Id__c=message.get('userID');
                partnerMessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+message.get('timestamp')+'"'),datetime.class);
                partnerMessage.PMP_Message_Txt__c=message.get('message');
                partnerMessage.PMP_Message_Type__c=message.get('type');
                partnerMessage.PMP_Company_Id__c=recordId;
                insert partnerMessage;
            }   
          
        return true;
    }
    
    //Gireesh:US371910:Get User Name
   @AuraEnabled(cacheable=true)
    public static String getUserName() {
        return userinfo.getName();
    }
    
    
}