@isTest
public class Modal_SendFilesAsAttachment_TEST {

    static testmethod void emailAttachment() {
        //Id acsLeadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Constant_AC.ACS_LEAD_RT).getRecordTypeId();
        Lead newLead = new Lead(FirstName = 'Rogers', LastName= 'Test', Status = 'Open', Company = 'MST');
        insert newLead;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documentsList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 500];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newLead.id;
        cdl.ContentDocumentId = documentsList[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Modal_SendFilesAsAttachment_Controller.sendFilesAsAttachmentToUsers(newLead.Id, 'testemail@email.com;');
        System.assertEquals(newLead.Status, 'Open');
    }
}