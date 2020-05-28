/*********************************************************************
Class Name: sendEmailComponentController_Test
Created By: MST - Matt Billups 
Created On: 05-12-2020
Description: Test class for apex class sendEmailComponentController.
*********************************************************************/

@isTest
public class sendEmailComponentController_Test {

    @testSetup
    static void setup() {
    
        /*Folder emailFolder = new Folder();
        emailFolder.DeveloperName = 'RO_OAE';
        emailFolder.Name = 'RO & OAE';        
        emailFolder.Type = 'Email';        
        insert emailFolder;*/
        Folder emailFolder = [SELECT Id, DeveloperName, Name, Type FROM Folder WHERE Name = 'RO & OAE' AND Type = 'Email'];                   
        
        EmailTemplate et = new EmailTemplate();
        et.developerName = 'testingggg';
        et.FolderId = emailFolder.Id;
        et.TemplateType = 'Text';
        et.Name = 'testingggg';
        et.HtmlValue = 'Test HTML';
        insert et;
    }
    
    static testMethod void sendEmailTest() {
        //sendEmailComponentController controller = new sendEmailComponentController();
        Test.startTest();
        Case testCase = new Case(Status = 'Open');
        insert testCase;
        Folder emailFolder = [SELECT Id, DeveloperName, Name FROM Folder WHERE Name = 'RO & OAE' AND Type = 'Email'];
        List<Case> testCases = [SELECT Id FROM Case];
        EmailTemplate template = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name = 'testingggg'];
        List<String> blankList = new List<String>();
        String response = sendEmailComponentController.sendMailMethod('User', '', UserInfo.getUserId(),'test subject', 'test body', testCases[0].Id, emailFolder.Id, template.Id, '', blankList, userInfo.getUserEmail());
        
        // Run the getTemplateFolders method
        List<sendEmailComponentController.emailTemplateWrapper> tempWrapperList = new List<sendEmailComponentController.emailTemplateWrapper>();
        tempWrapperList = sendEmailComponentController.getTemplateFolders();
        
        // Run the getEmailTemplates method
        List<sendEmailComponentController.emailTemplates> tempList = new List<sendEmailComponentController.emailTemplates>();
        tempList = sendEmailComponentController.getTemplates(emailFolder.Id);
        
        // Run the getCaseRec method
        Case caseObj = sendEmailComponentController.getCaseRec(testCases[0].Id);
        
        // Run the getFromAddresses method
        List<String> fromAddresses = sendEmailComponentController.getFromAddresses();
        
        Test.stopTest();
    }
    

    
}