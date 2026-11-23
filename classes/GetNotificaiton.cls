public without sharing  class GetNotificaiton {
    
    
    @AuraEnabled(cacheable=true)
    public static void setReadVisibilityEmail(String id,String type){
        if(id != null && type != null){
            if(type == 'Email'){
                List<PRM_EmailLog__c> emailUpdateList = new List<PRM_EmailLog__c>();   
                PRM_EmailLog__c updateEmail = [select id,PRM_Read__c from PRM_EmailLog__c where id =:id ];
                System.debug('methodca');
                if(updateEmail.PRM_Read__c == false  && updateEmail.id  != null){
                    updateEmail.PRM_Read__c = true;
                    System.debug('insideupdate');
                    emailUpdateList.add(updateEmail);    
                }
                
                if(emailUpdateList.size()>0){
                    update emailUpdateList;
                }
                
            }
            if(type == 'Event'){
                List<PRM_Message_log__c> messageUpdateList = new List<PRM_Message_log__c>();
                PRM_Message_log__c updateMessage = [select id,PRM_Message_Viewed_Ind__c from PRM_Message_log__c where id =:id ];
                System.debug('mess');
                if(updateMessage.PRM_Message_Viewed_Ind__c == false  && updateMessage.id  != null){
                    updateMessage.PRM_Message_Viewed_Ind__c = true;
                    System.debug('insideupdatemessage');
                    messageUpdateList.add(updateMessage);    
                }
                
                if(messageUpdateList.size()>0){
                    update messageUpdateList;
                }
            }
        }
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<UserNotificationInfo>  getNotificationList(Id recordId){
        List<UserNotificationInfo> notificationData = new List<UserNotificationInfo>();
        UserNotificationInfo ndata=new UserNotificationInfo();
        List<message> msgList = new List<message>();
        if(Schema.sObjectType.PRM_EmailLog__c.isAccessible()){ 
            List<PRM_EmailLog__c> getEmailLog = [select id, PRM_Contact__c,PRM_Subject__c,PRM_EmailContent__c,CreatedDate from PRM_EmailLog__c where  PRM_Contact__c =:recordId order by id desc limit 30] ;
            if(getEmailLog.size()>0){
                
                for(PRM_EmailLog__c n:getEmailLog){
                    System.debug('warp1');
                    // wrapperData.add(new notificationData(n));
                    
                    message msgSingle = new message();
                    msgSingle.messageId = n.Id;
                    msgSingle.subject  = n.PRM_Subject__c;
                    // msgSingle.body = n.PRM_EmailContent__c;
                    msgSingle.dates = n.CreatedDate.date();
                    msgSingle.read = false;
                    msgSingle.type =  'Email';
                    msgSingle.iconType = 'Event';
                    ReplyLink replyLinkSingle =  new   ReplyLink();
                    replyLinkSingle.label = 'Reply Link';
                    replyLinkSingle.externalUrl = '#ReplyLink';
                    replyLinkSingle.communityPage = '';
                    replyLinkSingle.objectPage = '';
                    replyLinkSingle.recordId = '';
                    msgSingle.replyLink = replyLinkSingle;
                    msgList.add(msgSingle);
                    
                    
                }
                ndata.title = 'Recent Message';
                ndata.messages = msgList;
                viewLink viewLinks = new viewLink();
                viewLinks.label = 'View All Messages';
                viewLinks.externalUrl = '#';
                viewLinks.communityPage = '';
                viewLinks.objectPage = '';
                viewLinks.recordId = '';
                ndata.viewAllLink = viewLinks;
                notificationData.add(ndata); 
            }
        }
        System.debug('notificationData'+notificationData);
        return notificationData;
    }
    
    
    public class UserNotificationInfo{
        @AuraEnabled public string title{get; set;}
        @AuraEnabled public List<message> messages{get; set;} 
        @AuraEnabled public viewLink viewAllLink{get; set;}
    }
    public class viewLink{
        
        @AuraEnabled public string label{get; set;}  //'View All Messages',
        @AuraEnabled public string externalUrl{get; set;} // '#',
        @AuraEnabled public string communityPage{get; set;} 
        @AuraEnabled public string objectPage{get; set;}
        @AuraEnabled public string recordId{get; set;}
        
    }
    public class message implements Comparable{
        @AuraEnabled public string messageId{get; set;}
        @AuraEnabled public string type{get; set;}
        @AuraEnabled public String iconType{get; set;}
        @AuraEnabled public List<Fields> fields{get; set;}
        @AuraEnabled public date dates{ get; set; } 
        @AuraEnabled public string subject{get; set;}
        @AuraEnabled public string body{get; set; } 
        @AuraEnabled public boolean read {get; set; }
        @AuraEnabled public  ReplyLink replyLink{ get; set; }
        
        public Integer compareTo(Object objToCompare) {
            message that = (message)objToCompare;
            if(this.dates == that.dates){
                return 0;
            } else if(this.dates > that.dates){
                return -1;
            } else {
                return 1;
            }
            
        } 
        
    }
    
    public class Fields 
    {
        @AuraEnabled public string label { get; set; }
        @AuraEnabled public string value { get; set; }
    }
    public class ReplyLink{
        @AuraEnabled public string label { get; set; } //'Reply Link'
        @AuraEnabled public string externalUrl { get; set; } //'#ReplyLink',
        @AuraEnabled public string communityPage { get; set; }
        @AuraEnabled public string objectPage { get; set; }
        @AuraEnabled public string recordId { get; set; }
    }
}