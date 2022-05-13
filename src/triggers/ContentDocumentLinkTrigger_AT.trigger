trigger ContentDocumentLinkTrigger_AT on ContentDocumentLink (after insert) {

    if(Trigger.isAfter && Trigger.isInsert) {
        Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink attachRec : Trigger.new) {
            if(attachRec.LinkedEntityId == System.Label.XmlFolderId){
                contentDocumentIds.add(attachRec.ContentDocumentId);
            }
        }
        
        if(contentDocumentIds.size() > 0){
            ContentDocumentLinkTriggerHandler_AC.sendEmail(contentDocumentIds);
            /*XmlFileReader_Batch parseFile = new XmlFileReader_Batch(contentDocumentIds[0]);
            Database.executeBatch(parseFile);*/
        }
    }
}