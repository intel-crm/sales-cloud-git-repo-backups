public with sharing class IPS_Agent_EmailService {

    public static void sendEmail(
        String toAddress,
        String subject,
        String body
    ) {

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new List<String>{ toAddress }
        );

        email.setSubject(subject);
        email.setPlainTextBody(body);

        Messaging.sendEmail(
            new Messaging.SingleEmailMessage[] {
                email
            }
        );
    }
}