@isTest
public class ContentDocumentLinkTriggerHandlerTest_AC {
    
    @testSetup
    static void setup() {
        
        String xml = '<iccxml xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:m="http://www.w3.org/1998/Math/MathML">' +
            '<head>' +
            '<title>2012 International Fire Code</title>' +
            '<link href="newICCStylesheet.css" rel="stylesheet" type="text/css"/>' +
            '</head>' +
            '<section id="IFC2012_Pt02" class="part" epub:type="part">' +
            '<header>' +
            '<h1 class="part" epub:type="title"><span class="label" epub:type="label">Part</span> <span class="part_number" epub:type="ordinal">II</span>&#x2014;<span class="part_title" epub:type="title">General Safety Provisions</span></h1>' +
            '</header>' +
            '<section id="IFC2012_Pt02_Ch03" class="chapter" epub:type="chapter">' +
            '<header>' +
            '<h1 class="chapter" epub:type="title"><span class="label" epub:type="label">CHAPTER</span> <span class="chapter_number" epub:type="ordinal">3</span><br /> <span class="chapter_title" epub:type="title">GENERAL REQUIREMENTS</span></h1>' +
            '</header>' +
            '<section id="IFC2012_Pt02_Ch03_Sec301" class="level1">' +
            '<h1 class="level1"><span class="label" epub:type="label">SECTION</span> <span class="section_number" epub:type="ordinal">301</span><br /> <span class="level1_title" epub:type="title">GENERAL</span></h1>' +
            '<section id="IFC2012_Pt02_Ch03_Sec301.1" class="level2">' +
            '<h1 class="level2"><span class="section_number" epub:type="ordinal">301.1</span> <span class="level2_title" epub:type="title">Scope.</span></h1>' +
            '<p>The provisions of this chapter shall govern the occupancy and maintenance of all structures and premises for precautions against fire and the spread of fire and general requirements of fire safety.</p>' +
            '</section>' +
            '<section id="IFC2012_Pt02_Ch03_Sec301.2" class="level2">' +
            '<h1 class="level2"><span class="section_number" epub:type="ordinal">301.2</span> <span class="level2_title" epub:type="title">Permits.</span></h1>' +
            '<p>Permits shall be required as set forth in <a class="section_reference" href="#IFC2012_Pt01_Ch01_SubCh02_Sec105.6">Section 105.6</a> for the activities or uses regulated by <a class="section_reference" href="#IFC2012_Pt02_Ch03_Sec306">Sections 306</a>, <a class="section_reference" href="#IFC2012_Pt02_Ch03_Sec307">307</a>, <a class="section_reference" href="#IFC2012_Pt02_Ch03_Sec308">308</a> and <a class="section_reference" href="#IFC2012_Pt02_Ch03_Sec315">315</a>.</p>' +
            '</section>' +
            '</section>' +
            '</section>' +
            '</section>' +
            '</iccxml>';
        
        //Create ContentVersion record 
        ContentVersion contVersRec = new ContentVersion();
        contVersRec.Title = 'Test XML File';
        contVersRec.PathOnClient = 'TextXMLFile.xml';
        contVersRec.VersionData = Blob.valueOf(xml);
        contVersRec.IsMajorVersion = true;
        insert contVersRec;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //Create ContentDocumentLink record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = System.Label.XmlFolderId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'I';
        cdl.visibility = 'AllUsers';
        insert cdl;
    }
    
    @isTest
    public static void emailServiceTest() {
        
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = document.Id;
        email.htmlBody = document.Id;
        
        Test.startTest();
        EmailServiceXMLReader emailProcess = new EmailServiceXMLReader();
        emailProcess.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<Violation_Code__c> violations = [SELECT ID FROM Violation_Code__c];
        System.assertEquals(false, violations.isEmpty(), 'Violation records were not created.');
    }

}