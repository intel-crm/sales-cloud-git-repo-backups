public class Core_MDF_updateInternalAuditStatus implements Messaging.InboundEmailHandler{

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try{
            system.debug('plainTextBody'+email.plainTextBody);
            String[] emailBodyArray = email.plainTextBody.split('\n',0);
            system.debug('emailBodyArray[0]' +emailBodyArray[0]);
            if(emailBodyArray[1]!=null && emailBodyArray[1]!=''){
                system.debug('emailBodyArray[1]' +emailBodyArray[1]);
            }
           result.success = true;
        }catch(exception e){
            result.success = false;
        }
        return result;
    }
}