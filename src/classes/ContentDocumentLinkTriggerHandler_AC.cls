public class ContentDocumentLinkTriggerHandler_AC {

    public static void sendEmail(Set<Id> contentDocumentIds) {
        
        String[] toAddresses = new String[] {System.Label.XmlParserEmailService}; 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Id contentDocId : contentDocumentIds) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('Content Document');
            mail.setPlainTextBody(contentDocId);
            mail.setHtmlBody(contentDocId);
            emails.add(mail);
        }
        
        // Send the emails
        if(!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}