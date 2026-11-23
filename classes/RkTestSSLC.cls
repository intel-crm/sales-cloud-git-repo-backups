global class RkTestSSLC implements Messaging.InboundEmailHandler {
        global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug ('Result:'+ result);
        return result;
        }
        }