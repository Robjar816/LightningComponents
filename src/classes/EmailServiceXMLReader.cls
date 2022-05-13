global class EmailServiceXMLReader implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,  Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try{
            if(String.isNotBlank(email.htmlBody)) {
                String contentDocId = email.htmlBody.stripHtmlTags();
                
                XmlFileReader_Batch parseFile = new XmlFileReader_Batch(contentDocId);
                Database.executeBatch(parseFile);
            }
            
        }catch(Exception e) {
            System.debug('Exception error: ' + e.getMessage());
            System.debug('Stack trace ===> ' + e.getStackTraceString());
        }
      
        return result;
    }
}