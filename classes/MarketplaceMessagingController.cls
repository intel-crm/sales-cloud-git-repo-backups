public with sharing class MarketplaceMessagingController {

    public class Message {
        public String author { get; set; }
        public String message { get; set; }
        public String timestamp { get; set; }
        public String type { get; set; }
        public String userID { get; set; }
    }
  
    @AuraEnabled(cacheable=true)
    public static String getMessage(String recordId , Boolean isPartner){

        List<Message> messages = new List<Message>();
		List<PMP_Company_Message__c> companyMessages = new List<PMP_Company_Message__c>();
       /* Message message1 = new Message();
        message1.author = 'Roberto Fuller';
        message1.userID = '0050n000001wOL9AAM';
        message1.timestamp = '2019-03-29T00:14:36';
        message1.message = 'In vestibulum risus ipsum, et venenatis justo semper sed. Curabitur ullamcorper efficitur ornare. Nam varius lacus eget massa eleifend, eget interdum mi tempor. Fusce magna nisl, ultrices sit amet lectus ut, placerat fringilla erat. Morbi et ligula lobortis, posuere ligula vel, sodales libero. Nulla at laoreet urna, at pharetra magna. Morbi placerat bibendum felis eu imperdiet. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris nec arcu leo. Vivamus pulvinar ultrices augue eget mattis. Proin vulputate nisl aliquet, feugiat nisi eget, consectetur ipsum. Cras posuere nunc sapien. Praesent quis velit porta, aliquet est at, molestie sem. Duis eleifend ultrices neque sit amet porta. Integer ut sagittis purus, eget euismod turpis. Mauris eu arcu ac magna egestas finibus.';
        message1.type = 'message';
        messages.add(message1);

        Message message2 = new Message();
        message2.author = 'Roberto Fuller';
        message2.userID = '0050n000001wOL9AAM';
        message2.timestamp = '2019-03-29T00:14:36';
        message2.message = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis et auctor arcu, et scelerisque purus. Donec viverra commodo imperdiet. Nunc at tellus a diam auctor accumsan eu non nibh. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Suspendisse potenti. Mauris lobortis leo justo, ullamcorper facilisis leo vestibulum sed. Praesent sed efficitur diam, eu eleifend ligula. Aenean scelerisque molestie dolor at sodales. Nam maximus ex at libero consectetur, sit amet elementum velit hendrerit. Integer lacus libero, aliquet id facilisis at, molestie sed tellus. Mauris et sagittis tellus. Pellentesque dignissim pellentesque sem, non condimentum justo viverra sit amet. Phasellus imperdiet pellentesque tortor, nec ornare orci rutrum ac. Nullam nisi lacus, sagittis ornare dapibus at, mollis eu dolor. Maecenas nec imperdiet est.	';
        message2.type = 'message';
        messages.add(message2);

        Message message3 = new Message();
        message3.author = '';
        message3.userID = '';
        message3.timestamp = '2019-03-31T00:13:11';
        message3.message = 'Submitted & pending review';
        message3.type = 'status';
        messages.add(message3);

        Message message4 = new Message();
        message4.author = '';
        message4.userID = '';
        message4.timestamp = '2019-04-02T00:16:59';
        message4.message = 'Updates Required';
        message4.type = 'status';
        messages.add(message4);

        Message message5 = new Message();
        message5.author = 'Alejandro Moore';
        message5.userID = '22222';
        message5.timestamp = '2019-04-02T00:16:59';
        message5.message = 'Hello! there are a few fields we\'d like you to revisit before the offering can be published: 1. On Offering Details, please correct the typo in the description, on the first bullet. 2. On Resources, please upload a higher resolution product image. Thank you!';
        message5.type = 'message';
        messages.add(message5);

        Message message6 = new Message();
        message6.author = 'Roberto Fuller';
        message6.userID = '0050n000001wOL9AAM';
        message6.timestamp = '2019-04-03T00:14:36';
        message6.message = 'OK. I\'ve made those updates, let me know if you have any other input';
        message6.type = 'message';
        messages.add(message6);

        Message message7 = new Message();
        message7.author = '';
        message7.timestamp = '2019-04-03T00:14:37';
        message7.message = 'Submitted & pending review';
        message7.type = 'status';
        messages.add(message7);

        Message message8 = new Message();
        message8.author = 'Alejandro Moore';
        message8.userID = '22222';
        message8.timestamp = '2019-04-03T00:15:11';
        message8.message = 'Thank you for completing that. Everything looks good! I\'ll publish and you will receive a confirmation email shortly.';
        message8.type = 'message';
        messages.add(message8);
        
        Message message9 = new Message();
        message9.author = '';
        message9.userID = '';
        message9.timestamp = '2019-04-03T00:15:14';
        message9.message = 'Published';
        message9.type = 'status';
        messages.add(message9);
       */
        
         
        if(!isPartner){
       
            if(Schema.sObjectType.PMP_Partner_Offering_Message__c.isAccessible()){
                List<PMP_Partner_Offering_Message__c> partnerMessages =[select PMP_Message_By_User_Nm__c, PMP_Message_By_Id__c, PMP_Message_Dtm__c, 
                                                               PMP_Message_Txt__c, PMP_Message_Type__c
                                                               from PMP_Partner_Offering_Message__c 
                                                               where PMP_Partner_Offering_Id__c=:recordId order by PMP_Message_Dtm__c];
          
                
            for(PMP_Partner_Offering_Message__c partnerMessage:partnerMessages){
                Message msg = new Message();
                msg.author=partnerMessage.PMP_Message_By_User_Nm__c;
                msg.userID=partnerMessage.PMP_Message_By_Id__c;
                msg.timestamp=(partnerMessage.PMP_Message_Dtm__c).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                msg.message=partnerMessage.PMP_Message_Txt__c;
                msg.type=(partnerMessage.PMP_Message_Type__c).toLowerCase();
                
              
                messages.add(msg);
            }
         } 
            
        }else{
            
            try{
                if(Schema.sObjectType.PMP_Company_Message__c.isAccessible()){
                    companyMessages = [select PMP_Message_By_User_Nm__c, PMP_Message_By_Id__c, PMP_Message_Dtm__c, 
                                                               PMP_Message_Txt__c, PMP_Message_Type__c
                                                               from PMP_Company_Message__c 
                                                               where PMP_Company_Id__c=:recordId order by PMP_Message_Dtm__c];
                }     
            }catch(Exception e){
                system.debug('No messages available for the partner : '+e.getMessage());
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
            
        }
         
        return JSON.serialize(messages);
    }

    //Gireesh:US371910:Get Posted Message
    @AuraEnabled
    public static Boolean postMessage(String recordId, Map<String,String> message , Boolean isPartner) {
        
        if(!isPartner){
            if(Schema.sObjectType.PMP_Partner_Offering_Message__c.isCreateable()){
                PMP_Partner_Offering_Message__c offeringMessage=new PMP_Partner_Offering_Message__c();
            	offeringMessage.PMP_Message_By_Id__c=message.get('userID');
            	offeringMessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+message.get('timestamp')+'"'),datetime.class);
            	offeringMessage.PMP_Message_Txt__c=message.get('message');
            	offeringMessage.PMP_Message_Type__c=message.get('type');
            	offeringMessage.PMP_Partner_Offering_Id__c=recordId;
            	insert offeringMessage;
            }    
        }else{
            
            if(Schema.sObjectType.PMP_Company_Message__c.isCreateable()){
                PMP_Company_Message__c partnerMessage = new PMP_Company_Message__c();
            	partnerMessage.PMP_Message_By_Id__c=message.get('userID');
            	partnerMessage.PMP_Message_Dtm__c=(DateTime)json.deserialize(('"'+message.get('timestamp')+'"'),datetime.class);
            	partnerMessage.PMP_Message_Txt__c=message.get('message');
            	partnerMessage.PMP_Message_Type__c=message.get('type');
            	partnerMessage.PMP_Company_Id__c=recordId;
            	insert partnerMessage;
            }   
        }    
        return true;
    }
    
    //Gireesh:US371910:Get User Name
   @AuraEnabled(cacheable=true)
    public static String getUserName() {
        return userinfo.getName();
    }
    
    
}