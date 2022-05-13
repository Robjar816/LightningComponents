public class XmlFileReader_Batch implements Database.Batchable<sObject> {
    
    public String contendDocId;
    
    public XmlFileReader_Batch(String contentDocId) {
        this.contendDocId = contentDocId;
    }
    
    public List<ContentVersion> start(Database.BatchableContext bc) {
        return [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: contendDocId AND IsLatest = true];
    }
    
    public void execute(Database.BatchableContext bc, List<ContentVersion> content){
        XmlStreamReader reader = new XmlStreamReader(content[0].VersionData.toString().replace('<!DOCTYPE iccxml SYSTEM "iccxml.dtd">', ''));
        List<Violation_Code__c> violations = XmlFileReader.parseViolations(reader);
        
        System.debug('violations size ===> ' + violations.size());
        if(!violations.isEmpty()) {
            insert violations;
        }
    }
    
    //Deprecate prior active Violation Codes
    public void finish(Database.BatchableContext bc){
        List<Violation_Code__c> depVios = new List<Violation_Code__c>();
        for(Violation_Code__c vioRec : [SELECT Id, Status__c FROM Violation_Code__c WHERE Status__c = 'Active' AND (Version__c = null OR Version__c = '')]) {
            vioRec.Status__c = 'Deprecated';
            depVios.add(vioRec);
        }
        
        if(!depVios.isEmpty()) {
            update depVios;
        }
    }
}