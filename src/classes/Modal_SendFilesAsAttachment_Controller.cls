public class Modal_SendFilesAsAttachment_Controller {

    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public List<ContentVersion> leadFileList;
    
    @AuraEnabled
    public Modal_SendFilesAsAttachment_Controller controller;
    
    @AuraEnabled
    public static Modal_SendFilesAsAttachment_Controller sendFilesAsAttachmentToUsers(Id leadId, String emailRecp) {
        
        Modal_SendFilesAsAttachment_Controller controller = new Modal_SendFilesAsAttachment_Controller();
        controller.leadFileList = new List<ContentVersion>();
        Set<Id> contentLinkSet = new Set<Id>();
        for(ContentDocumentLink contentDoc : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Lead WHERE Id =: leadId)]) {
            contentLinkSet.add(contentDoc.ContentDocumentId);
        }
        if(contentLinkSet.size() > 0) {
            Set<Id> conDocIdSet = new Set<Id>();
            for(ContentDocument contentDoc : [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN : contentLinkSet]) {
                conDocIdSet.add(contentDoc.Id);
            }
            if(conDocIdSet.size() > 0) {
                for(List<ContentVersion> leadFileList : [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN : conDocIdSet]) {
                    controller.leadFileList.addAll(leadFileList);
                }
                //controller.leadFileList = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE isLatest = true AND ContentDocumentId IN : conDocIdSet];
                
            }
        }
        List<Messaging.singleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.singleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        if(controller.leadFileList.size() > 0) {
            for (ContentVersion contVer : controller.leadFileList) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                Blob WOCFbody = contVer.VersionData;
                efa.setFileName(contVer.Title+'.'+contVer.FileTYpe.toLowerCase());
                efa.setBody(WOCFbody);
                fileAttachments.add(efa);
            }
        }
        if(fileAttachments.size() > 0) {
            mail.setFileAttachments(fileAttachments);
        }
        List<String> emailAdressList = new List<String>();
        for(string emailAddress: emailRecp .split(';')) {
            emailAdressList.add(emailAddress);
        }
        EmailTemplate emailTemplate = [SELECT id FROM EmailTemplate WHERE DeveloperName =: 'Lead_Test_Template' LIMIT 1];     
        mail.setSaveAsActivity(true);
        mail.setTemplateId(emailTemplate.id);
        mail.setTargetObjectId(leadId); 
        mail.setTreatTargetObjectAsRecipient(false);        
        mail.setToAddresses(emailAdressList);
        mails.add(mail);
        try {
            messaging.sendEmail(mails);
        } catch(Exception e){
            controller.hasError = true;
            controller.errorMessage = 'Exception:'+e.getMessage();
        }
        return controller;
    }
}